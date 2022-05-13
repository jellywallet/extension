import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/tx_list_model.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:defi_wallet/requests/history_requests.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:bip32_defichain/bip32.dart' as bip32;

class WalletsHelper {
  HDWalletService _hdWalletService = HDWalletService();
  HistoryRequests _historyRequests = HistoryRequests();
  BalanceRequests _balanceRequests = BalanceRequests();
  final SettingsHelper settingsHelper = SettingsHelper();

  Future<AccountModel> createNewAccount(
      bip32.BIP32 masterKeyPair, int accountIndex, String network) async {
    AccountModel account = AccountModel(index: accountIndex);

    List<AddressModel> addressList = [];
    addressList.add(await _hdWalletService.getAddressModelFromKeyPair(
        masterKeyPair, accountIndex, network));
    account.addressList = addressList;
    account.balanceList = [BalanceModel(token: 'DFI', balance: 0)];
    account.historyList = [];
    account.index = accountIndex;
    account.activeToken = 'DFI';
    return account;
  }

//TODO: restore for HD-wallets.
  Future<List<AccountModel>> restoreWallet(bip32.BIP32 masterKeyPair, String network, Function(int, int) statusBar) async {
    List<AccountModel> accountList = [];
    int lastIndexWithHistory = 0;
    for (var accountIndex = 0; accountIndex < 10; accountIndex++) {
      statusBar(10, accountIndex);
      List<AddressModel> addressList = [];
      List<HistoryModel> historyList = [];
      addressList.add(await _hdWalletService.getAddressModelFromKeyPair(
          masterKeyPair, accountIndex, network));
      var balances =
          await _balanceRequests.getBalanceListByAddressList(addressList, network);
      TxListModel txListModel = await _historyRequests.getFullHistoryList(
          addressList[0], 'DFI', network);
      historyList.addAll(txListModel.list!);
      if (balances.length == 0) {
        balances.add(BalanceModel(token: 'DFI', balance: 0));
      } else {
        lastIndexWithHistory = accountIndex;
      }
      accountList.add(AccountModel(
        index: accountIndex,
        addressList: addressList,
        balanceList: balances,
        historyList: historyList,
        transactionNext: txListModel.transactionNext,
        historyNext: txListModel.historyNext,
        activeToken: balances[0].token,
      ));
    }
    List<AccountModel> resultList = [];
    accountList.forEach((element) async {
      if (element.index! <= lastIndexWithHistory) {
        resultList.add(element);
      }
    });
    return resultList;
  }
}
