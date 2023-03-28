import 'dart:math';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/models/tx_response_model.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:defi_wallet/requests/defichain/dfi_transaction_requests.dart';
import 'package:defichaindart/defichaindart.dart';

import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';

class DFITransactionService {
  static const DUST = 3000;
  static const FEE = 3000;
  static const int AuthTxMin = 200000;
  var networkHelper = NetworkHelper();
  var balanceRequests = BalanceRequests();
  var balancesHelper = BalancesHelper();
  List<UtxoModel> accountUtxoList = [];

  Future<TxErrorModel> removeLiqudity(
      {required String senderAddress,
        required ECPair keyPair,
        required String networkString,
        required LmPoolModel token,
        required int amount}) async {
    await _getUtxoList(senderAddress, networkString);

    var responseModel = await _createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        senderAddress: senderAddress,
        destinationAddress: senderAddress,
        changeAddress: senderAddress,
        amount: 0,
        additional: (txb, nw, newUtxo) {
          txb.addRemoveLiquidityOutput(
              int.parse(token.id), amount, senderAddress);
        });

    return await _prepareTx(responseModel, TxType.removeLiq, networkString);
  }


  Future<TxErrorModel> createAndSendLiqudity(
      {required String senderAddress,
        required ECPair keyPair,
        required String networkString,
        required LmPoolModel token,
        required List<int> amountList}) async {
    await _getUtxoList(senderAddress, networkString);
    TxErrorModel txErrorModel = TxErrorModel(isError: false, txLoaderList: []);

    int? indexDFI;

    if (token.tokens[0].symbol == 'DFI') {
      indexDFI = 0;
    } else if (token.tokens[1].symbol == 'DFI') {
      indexDFI = 1;
    }
//TODO: need to give balance from parent function
    var addressBalanceList = await balanceRequests
        .getAddressBalanceListByAddressList(account.addressList!);

    if (indexDFI != null) {
      var tokenDFIbalanceAll =
      balancesHelper.getBalanceByTokenName(addressBalanceList, 'DFI');

      var coinDFIbalanceAll =
      balancesHelper.getBalanceByTokenName(addressBalanceList, '\$DFI');

      if (tokenDFIbalanceAll + coinDFIbalanceAll < amountList[indexDFI]) {
        return TxErrorModel(
            isError: true,
            error: 'Not enough balance. Wait for approval the previous tx');
      }

      if (tokenDFIbalanceAll < amountList[indexDFI]) {
        var responseModel = await _utxoToAccountTransaction(
            senderAddress:senderAddress,
            keyPair: keyPair,
            amount: amountList[indexDFI] - tokenDFIbalanceAll,
            tokenId: int.parse(token.tokens[indexDFI].id));

        txErrorModel = await _prepareTx(responseModel, TxType.convertUtxo, networkString);
        if (txErrorModel.isError!) {
          return txErrorModel;
        }
      }
    }

    var responseModel = await _createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: senderAddress,
        senderAddress: senderAddress,
        changeAddress: senderAddress,
        amount: 0,
        additional: (txb, nw, newUtxo) {
          txb.addAddLiquidityOutputSingleAddress(
              senderAddress,
              int.parse(token.tokens[0].id),
              amountList[0],
              int.parse(token.tokens[1].id),
              amountList[1],
              senderAddress);
        },
        useAllUtxo: true);

    if (txErrorModel.txLoaderList!.length > 0) {
      txErrorModel.txLoaderList!
          .add(TxLoaderModel(txHex: responseModel.hex, type: TxType.addLiq));
    } else {
      txErrorModel = await _prepareTx(responseModel, TxType.addLiq, networkString);
    }

    return txErrorModel;
  }

  Future<TxResponseModel> _utxoToAccountTransaction(
      {required ECPair keyPair,
        required int amount,
          required String senderAddress,
        required int tokenId}) {
    return _createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: senderAddress,
        senderAddress: senderAddress,
        changeAddress: senderAddress,
        amount: 0,
        reservedBalance: amount,
        additional: (txb, nw, newUtxo) {
          txb.addUtxosToAccountOutput(
              tokenId, senderAddress, amount, nw);
        });
  }

  Future<TxErrorModel> createSendTransaction(
      {required String senderAddress,
      required ECPair keyPair,
      required TokensModel token,
      required String destinationAddress,
      required String networkString,
      required int amount}) async {
    if (token.name == 'DFI') {
      return _createSendUTXOTransaction(
          keyPair: keyPair,
          token: token,
          destinationAddress: destinationAddress,
          amount: amount,
          senderAddress: senderAddress,
          networkString: networkString);
    } else {
      return _createAndSendToken(
          keyPair: keyPair,
          token: token,
          destinationAddress: destinationAddress,
          amount: amount,
          senderAddress: senderAddress,
          networkString: networkString);
    }
  }

  Future<TxErrorModel> _createSendUTXOTransaction(
      {required String senderAddress,
      required ECPair keyPair,
      required String destinationAddress,
      required String networkString,
      required int amount,
      required TokensModel token}) async {
    TxResponseModel? responseModel;
    TxErrorModel txErrorModel = TxErrorModel(isError: false, txLoaderList: []);

    await _getUtxoList(senderAddress, networkString);
//TODO: need to give balance from parent function
    var addressBalanceList =
        await balanceRequests.getAddressBalanceListByAddressList([senderAddress]);
    var tokenDFIbalance =
        balancesHelper.getBalanceByTokenName(addressBalanceList, 'DFI');

    //Swap DFI tokens to UTXO if needed
    if (tokenDFIbalance >= DUST) {
      responseModel = await _createTransaction(
          keyPair: keyPair,
          utxoList: accountUtxoList,
          destinationAddress: destinationAddress,
          changeAddress: senderAddress,
          amount: 0,
          senderAddress: senderAddress,
          additional: (txb, nw, newUtxo) {
            final mintingStartsAt = txb.tx!.outs.length + 1;
            newUtxo.add(UtxoModel(
                address: senderAddress,
                value: tokenDFIbalance,
                mintIndex: newUtxo.length + 1));
            txb.addOutput(senderAddress, tokenDFIbalance);
            txb.addAccountToUtxoOutput(
                token.id, senderAddress, tokenDFIbalance, mintingStartsAt);
          });
      if (responseModel.isError) {
        return TxErrorModel(isError: true, error: responseModel.error);
      }

      txErrorModel = await _prepareTx(responseModel, TxType.convertUtxo, networkString);

      if (txErrorModel.isError!) {
        return txErrorModel;
      }
    }

    var responseTxModel = await _createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: destinationAddress,
        senderAddress: senderAddress,
        changeAddress: senderAddress,
        amount: amount);
    if (responseTxModel.isError) {
      return TxErrorModel(isError: true, error: responseTxModel.error);
    }

    if (txErrorModel.txLoaderList!.length > 0) {
      txErrorModel.txLoaderList!
          .add(TxLoaderModel(txHex: responseTxModel.hex, type: TxType.send));
    } else {
      txErrorModel = await _prepareTx(responseTxModel, TxType.send, networkString);
    }

    return txErrorModel;
  }

  Future<TxErrorModel> _createAndSendToken(
      {required String senderAddress,
      required ECPair keyPair,
      required TokensModel token,
      required String networkString,
      required String destinationAddress,
      required int amount}) async {
    await _getUtxoList(senderAddress, networkString);

    var responseModel = await _createTransaction(
        keyPair: keyPair,
        utxoList: accountUtxoList,
        destinationAddress: senderAddress,
        senderAddress: senderAddress,
        changeAddress: senderAddress,
        amount: 0,
        additional: (txb, nw, newUtxo) {
          txb.addAccountToAccountOutputAt(
              token.id, senderAddress, destinationAddress, amount, 0);
        },
        useAllUtxo: true);
    if (responseModel.isError) {
      return TxErrorModel(isError: true, error: responseModel.error);
    }

    return await _prepareTx(responseModel, TxType.send, networkString);
  }

  Future<TxResponseModel> _createTransaction(
      {required ECPair keyPair,
      required List<UtxoModel> utxoList,
      required String destinationAddress,
      required String changeAddress,
      required int amount,
      required String senderAddress,
      bool useAllUtxo = true,
      int reservedBalance = 0,
      Function(TransactionBuilder, NetworkType, List<UtxoModel>)?
          additional}) async {
    var sum = 0;

    List<UtxoModel> selectedUTXO = [];
    List<UtxoModel> newUTXO = [];

    if (utxoList.length == 0) {
      return TxResponseModel(
          isError: true,
          error: 'Not enough balance. Wait for approval the previous tx',
          usingUTXO: [],
          newUTXO: [],
          hex: '');
    }

    if (useAllUtxo) {
      selectedUTXO = utxoList;
    } else {
      selectedUTXO = _utxoSelector(utxoList, FEE, amount);
    }

    final _txb = TransactionBuilder(
        network: networkHelper.getNetwork(SettingsHelper.settings.network!));
    _txb.setVersion(2);

    selectedUTXO.forEach((utxo) {
      _txb.addInput(
          utxo.mintTxId,
          utxo.mintIndex,
          null,
          P2WPKH(
                  data: PaymentData(pubkey: keyPair.publicKey),
                  network: networkHelper
                      .getNetwork(SettingsHelper.settings.network!))
              .data!
              .output);
      sum += utxo.value!;
    });

    if (sum < amount + FEE) {
      return TxResponseModel(
          isError: true,
          error: 'Not enough balance. Wait for approval the previous tx',
          usingUTXO: [],
          newUTXO: [],
          hex: '');
    }
    if (amount > 0) {
      _txb.addOutput(destinationAddress, amount);
      if (destinationAddress == senderAddress) {
        newUTXO.add(UtxoModel(
            address: destinationAddress,
            value: amount,
            mintIndex: newUTXO.length + 1));
      }
    }
    if (sum - (amount + FEE + reservedBalance) > DUST) {
      newUTXO.add(UtxoModel(
          address: changeAddress,
          value: sum - (amount + FEE + reservedBalance),
          mintIndex: newUTXO.length + 1));
      _txb.addOutput(
          changeAddress, sum - (amount + FEE + reservedBalance)); //money - fee
    }

    if (additional != null) {
      await additional(_txb,
          networkHelper.getNetwork(SettingsHelper.settings.network!), newUTXO);
    }

    selectedUTXO.asMap().forEach((index, utxo) {
      _txb.sign(vin: index, keyPair: keyPair, witnessValue: utxo.value);
    });

    TxResponseModel responseModel = TxResponseModel(
        hex: _txb.build().toHex(),
        usingUTXO: selectedUTXO,
        newUTXO: newUTXO,
        isError: false,
        amount: amount);
    return responseModel;
  }

  List<UtxoModel> _utxoSelector(List<UtxoModel> utxos, int fee, int amount) {
    utxos = _shuffle(utxos);
    List<UtxoModel> selectedUtxo = [];
    int sum = 0;
    int i = 0;
    do {
      selectedUtxo.add(utxos[i]);
      sum += utxos[i].value!;
      if (selectedUtxo.length < utxos.length) {
        i++;
      } else {
        break;
      }
    } while (sum <= amount + fee || sum - (amount + fee) < DUST);
    return selectedUtxo;
  }

  List<UtxoModel> _shuffle(List<UtxoModel> items) {
    var random = new Random();

    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

  Future<List<UtxoModel>> _getUtxoList(
      String address, String networkString) async {
    if (accountUtxoList.isEmpty) {
      accountUtxoList = await DFITransactionRequests.getUTXOs(
          address: address, networkString: networkString);
    }

    return accountUtxoList;
  }

  void _updateUtxoList(TxResponseModel responseModel, String txid) {
    List<UtxoModel> usingUtxo = [];
    responseModel.usingUTXO.forEach((data) {
      Map<dynamic, dynamic> dataJson = data.toJson();
      usingUtxo.add(UtxoModel.fromJson(dataJson));
    });

    for (var i = 0; i < usingUtxo.length; i++) {
      accountUtxoList.removeWhere((item) {
        return item.mintTxId == usingUtxo[i].mintTxId &&
            item.mintIndex == usingUtxo[i].mintIndex;
      });
    }

    responseModel.newUTXO.forEach((element) {
      accountUtxoList.add(UtxoModel(
          address: element.address!,
          mintIndex: element.mintIndex,
          mintTxId: txid,
          value: element.value));
    });
  }

  Future<TxErrorModel> _prepareTx(
      TxResponseModel responseModel, TxType type, String networkString) async {
    TxErrorModel? txid = await DFITransactionRequests.sendTxHex(txHex: responseModel.hex, networkString: networkString);
    if (!txid.isError!) {
      _updateUtxoList(responseModel, txid.txLoaderList![0].txId!);
      txid.txLoaderList![0].type = type;
    }

    return txid;
  }
}
