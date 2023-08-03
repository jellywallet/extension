import 'dart:typed_data';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/requests/transaction_requests.dart';
import 'package:defi_wallet/services/ledger_signing_service.dart';
import 'package:defi_wallet/services/local_signing_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:hive/hive.dart';

abstract class SigningService {
  Future<Uint8List> getPublicKey();

  Future<String> signTransaction(TransactionBuilder txBuilder,
      List<UtxoModel> utxoModel, String changePath);
}

abstract class SigningWalletService {
  Future<Uint8List> getPublicKey(
      AccountModel accountModel, String address, NetworkType network,
      {ECPair? key});

  Future<String> signTransaction(
      TransactionBuilder txBuilder,
      AccountModel accountModel,
      List<UtxoModel> utxoModel,
      NetworkType network,
      String changePath,
      {ECPair? key});

  Future<String> signMessage(AccountModel accountModel, String address,
      String message, NetworkType network,
      {ECPair? key});
}

class SigningServiceSelector {
  SigningWalletService _local = new LocalSigningService();
  SigningWalletService _ledger =
      new LedgerSigningService(TransactionRequests());

  Future<SigningWalletService> get() async {
    var box = await Hive.openBox(HiveBoxes.client);
    var walletType = box.get(HiveNames.walletType);

    if (walletType == AccountCubit.ledgerWalletType) {
      return _ledger;
    }
    return _local;
  }
}
