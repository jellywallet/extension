import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_bridge_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_exchange_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_on_off_ramp_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_staking_provider_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bridge_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_exchange_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/defichain_lm_provider_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/lock_staking_provider_model.dart';
import 'package:defi_wallet/models/network/defichain_implementation/yield_machine_staking_provider_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/staking_enum.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/requests/defichain/dfi_balance_requests.dart';
import 'package:defi_wallet/requests/defichain/dfi_token_requests.dart';
import 'package:defi_wallet/services/defichain/dfi_transaction_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;
import 'package:defichaindart/src/models/networks.dart' as networks;

class DefichainNetworkModel extends AbstractNetworkModel {
  static const int DUST = 3000;
  static const int FEE = 3000;
  static const int RESERVED_BALANCES = 1000000;


  DefichainNetworkModel(NetworkTypeModel networkType)
      : super(_validationNetworkName(networkType)) {
    if (!networkType.isTestnet) {
      this.stakingList.add(new LockStakingProviderModel());
      this.stakingList.add(new YieldMachineStakingProviderModel());
    }

    this.lmList.add(new DefichainLmProviderModel());

    this.exchangeList.add(new DefichainExchangeModel());
  }

  Future<NetworkFeeModel> getNetworkFee() async {
    throw 'Not available for this network';
  }

  factory DefichainNetworkModel.fromJson(Map<String, dynamic> json) {
    final stakingListJson = json['stakingList'];

    final stakingList = List.generate(
      stakingListJson.length,
      (index) {
        if (StakingEnum.staking.isCompare(stakingListJson[index]['type'])) {
          return LockStakingProviderModel.fromJson(stakingListJson[index]);
        } else {
          return YieldMachineStakingProviderModel.fromJson(
            stakingListJson[index],
          );
        }
      },
    );
    return DefichainNetworkModel(
      NetworkTypeModel.fromJson(json['networkType']),
    )
      ..stakingList = stakingList
      ..lmList = [DefichainLmProviderModel()]
      ..exchangeList = [DefichainExchangeModel()];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['networkType'] = this.networkType.toJson();
    data['stakingList'] = List.generate(
      this.stakingList.length,
      (index) => this.stakingList[index].toJson(),
    );

    return data;
  }

  static NetworkTypeModel _validationNetworkName(NetworkTypeModel networkType) {
    if (networkType.networkName != NetworkName.defichainTestnet &&
        networkType.networkName != NetworkName.defichainMainnet) {
      throw 'Invalid network';
    }
    return networkType;
  }

  String createAddress(String publicKey, int accountIndex) {
    var publicKeypair =
        bip32.BIP32.fromBase58(publicKey, _getNetworkTypeBip32());

    return this._createAddressString(publicKeypair, accountIndex);
  }

  Future<List<TokenModel>> getAvailableTokens() async {
    return await DFITokenRequests.getTokens(networkType: this.networkType);
  }

  List<HistoryModel> getHistory(String networkName, String? txid) {
    return [];
  }

  List<AbstractOnOffRamp> getRamps() {
    return rampList;
  }

  Uri getTransactionExplorer(String tx) {
    final query = {
      'network': networkType.networkStringLowerCase,
    };

    return Uri.https(Hosts.defiScanHome, '/transactions/$tx', query);
  }

  Uri getAccountExplorer(String address) {
    final query = {
      'network': networkType.networkStringLowerCase,
    };

    return Uri.https(Hosts.defiScanHome, '/address/$address', query);
  }

  List<AbstractBridge> getBridges() {
    try {
      return [BridgeModel(this.networkType)];
    } catch (err) {
      return [];
    }
  }

  List<AbstractExchangeModel> getExchanges() {
    return exchangeList;
  }

  List<AbstractStakingProviderModel> getStakingProviders() {
    return stakingList;
  }

  List<AbstractLmProviderModel> getLmProviders() {
    return lmList;
  }

  Future<double> getBalance({
    required AbstractAccountModel account,
    required TokenModel token,
  }) async {
    List<BalanceModel> balances = account.getPinnedBalances(this);
    late BalanceModel balance;

    if (token.symbol == 'DFI') {
      BalanceModel balanceUTXO = await getBalanceUTXO(
        balances,
        account.getAddress(this.networkType.networkName)!,
      );
      BalanceModel balanceToken = await getBalanceToken(
        balances,
        token,
        account.getAddress(this.networkType.networkName)!,
      );
      return fromSatoshi(balanceUTXO.balance + balanceToken.balance);
    } else {
      balance = await getBalanceToken(
        balances,
        token,
        account.getAddress(this.networkType.networkName)!,
      );
      return fromSatoshi(balance.balance);
    }
  }

  Future<List<BalanceModel>> getAllBalances({
    required String addressString,
  }) async {
    var tokens = await this.getAvailableTokens();
    var balanceList = await DFIBalanceRequests.getBalanceList(
      network: this,
      addressString: addressString,
      tokens: tokens
    );

    return balanceList;
  }

  TokenModel getDefaultToken(){
    return TokenModel(
      isUTXO: true,
      name: 'Default Defi token',
      symbol: 'DFI',
      displaySymbol: 'DFI',
      id: '-1',
      networkName: this.networkType.networkName,
    );
  }

  bool isTokensPresent(){
    return true;
  }

  Future<double> getAvailableBalance({
    required AbstractAccountModel account,
    required TokenModel token,
    required TxType type,
  }) async {
    List<BalanceModel> balances = account.getPinnedBalances(this, mergeCoin: false);

    double available = 0;

    if (token.symbol == 'DFI') {
      //TODO: change names
      BalanceModel coinDFIBalance = await getBalanceUTXO(
        balances,
        account.getAddress(this.networkType.networkName)!,
      );
      BalanceModel tokenDFIBalance = await getBalanceToken(
        balances,
        token,
        account.getAddress(this.networkType.networkName)!,
      );

      switch (type) {
        case TxType.send:
          if (tokenDFIBalance.balance > FEE+RESERVED_BALANCES) {
            available = fromSatoshi(coinDFIBalance.balance + tokenDFIBalance.balance - (FEE * 2)-RESERVED_BALANCES);
            break;
          } else {
            available = fromSatoshi(coinDFIBalance.balance - (FEE));
            break;
          }
        case TxType.swap:
          if (coinDFIBalance.balance > (FEE * 2) + DUST+RESERVED_BALANCES) {
            available = fromSatoshi(coinDFIBalance.balance + tokenDFIBalance.balance - (FEE * 2)-RESERVED_BALANCES);
            break;
          } else {
            available = fromSatoshi(tokenDFIBalance.balance);
            break;
          }
        case TxType.addLiq:
          if (coinDFIBalance.balance > (FEE * 2) + DUST+RESERVED_BALANCES) {
            available = fromSatoshi(coinDFIBalance.balance + tokenDFIBalance.balance - (FEE * 2)-RESERVED_BALANCES);
            break;
          } else {
            available = fromSatoshi(tokenDFIBalance.balance);
            break;
          }
        default:
          available = 0;
      }
    } else {
      BalanceModel balance = await getBalanceToken(
        balances,
        token,
        account.getAddress(this.networkType.networkName)!,
      );
      available = fromSatoshi(balance.balance);
    }
    return available > 0 ? available : 0;
  }

  bool checkAddress(String address) {
    return Address.validateAddress(
      address,
      getNetworkType(),
    );
  }

  Future<ECPair> getKeypair(String password, AbstractAccountModel account, ApplicationModel applicationModel) async {
    var mnemonic = applicationModel.sourceList[account.sourceId]!.getMnemonic(password);
    var masterKey = getMasterKeypairFormMnemonic(mnemonic);
    return _getKeypairForPathPrivateKey(masterKey, account.accountIndex);
  }

  Future<TxErrorModel> send(
      {required AbstractAccountModel account,
      required String address,
      required String password,
      required TokenModel token,
      required double amount,
        required ApplicationModel applicationModel,
        int satPerByte = 0}) async {
    ECPair keypair = await getKeypair(
      password,
      account,
      applicationModel
    );

    List<BalanceModel> balances = account.getPinnedBalances(this, mergeCoin: false);
    BalanceModel balanceUTXO = await getBalanceUTXO(
      balances,
      account.getAddress(this.networkType.networkName)!,
    );
    BalanceModel balanceToken = await getBalanceToken(
      balances,
      token,
      account.getAddress(this.networkType.networkName)!,
    );

    return DFITransactionService().createSendTransaction(
      senderAddress: account.getAddress(this.networkType.networkName)!,
      keyPair: keypair,
      balanceUTXO: balanceUTXO,
      balance: balanceToken,
      destinationAddress: address,
      network: this,
      amount: toSatoshi(amount),
    );
  }

  Future<String> signMessage(
    AbstractAccountModel account,
    String message,
    String password,
   ApplicationModel applicationModel
  ) async {
    ECPair keypair = await getKeypair(
      password,
      account,
      applicationModel
    );

    return keypair.signMessage(message, getNetworkType());
  }

  Future<BalanceModel> getBalanceUTXO(
    List<BalanceModel> balances,
    String addressString,
  ) async {
    late BalanceModel? balance;
    try {
      balance = balances.firstWhere((element) => element.token!.isUTXO);
    } catch (_) {
      //not realistic case
      balance = await DFIBalanceRequests.getUTXOBalance(
        network: this,
        addressString: addressString,
      );
    }
    return balance;
  }

  Future<BalanceModel> getBalanceToken(
    List<BalanceModel> balances,
    TokenModel token,
    String addressString,
  ) async {
    late BalanceModel? balance;
    try {
      //TODO: add filter by token or pair
      balance = balances.where((element) => element.token != null).firstWhere((element) => element.token!.compare(token) && !element.token!.isUTXO);
    } catch (_) {
      //if not exist in balances we check blockchain
      var tokens = await this.getAvailableTokens();
      List<BalanceModel> balanceList = await DFIBalanceRequests.getBalanceList(
        network: this,
        addressString: addressString,
          tokens: tokens
      );
      try {
        //TODO: add filter by token or pair
        balance = balanceList.where((element) => element.token != null).firstWhere(
          (element) => element.token!.compare(token) && !element.token!.isUTXO,
        );
      } catch (_) {
        //if in blockchain balance doesn't exist - we return 0
        balance = BalanceModel(balance: 0, token: token);
      }
    }
    return balance;
  }

  String _createAddressString(bip32.BIP32 masterKeyPair, int accountIndex) {
    final keyPair = _getKeypairForPathPublicKey(masterKeyPair, accountIndex);
    return _getAddressFromKeyPair(keyPair);
  }

  // private
  NetworkType getNetworkType() {
    return this.networkType.isTestnet
        ? networks.defichain_testnet
        : networks.defichain;
  }

  bip32.BIP32 getMasterKeypairFormMnemonic(List<String> mnemonic) {
    final seed = mnemonicToSeed(mnemonic.join(' '));
    return bip32.BIP32.fromSeedWithCustomKey(seed, "@defichain/jellyfish-wallet-mnemonic", _getNetworkTypeBip32());
  }

  ECPair _getKeypairForPathPublicKey(bip32.BIP32 masterKeypair, int account) {
    return ECPair.fromPublicKey(
        masterKeypair.derivePath(_derivePath(account)).publicKey,
        network: getNetworkType());
  }

  ECPair _getKeypairForPathPrivateKey(
    bip32.BIP32 masterKeypair,
    int account,
  ) {
    return ECPair.fromPrivateKey(
        masterKeypair.derivePath(_derivePath(account)).privateKey!,
        network: getNetworkType());
  }

  String _derivePath(int account) {
    return "1129/0/0/$account";
  }

  String _getAddressFromKeyPair(ECPair keyPair) {
    return P2WPKH(
      data: PaymentData(
        pubkey: keyPair.publicKey,
      ),
      network: getNetworkType(),
    ).data!.address!;
  }

  bip32.NetworkType _getNetworkTypeBip32() {
    var network = getNetworkType();
    return bip32.NetworkType(
      bip32: bip32.Bip32Type(
        private: network.bip32.private,
        public: network.bip32.public,
      ),
      wif: network.wif,
    );
  }
}
