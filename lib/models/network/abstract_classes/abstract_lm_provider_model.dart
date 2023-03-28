import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'abstract_account_model.dart';


abstract class AbstractLmProviderModel {
  Future<List<LmPoolModel>> getAvailableLmPools(AbstractNetwork network);
  List<LmPoolModel> getPinnedLmPools(AbstractAccountModel account);
  void pinLmPool(AbstractAccountModel account, LmPoolModel pool);
  void unpinLmPool(AbstractAccountModel account, LmPoolModel pool);

  String addBalance(AbstractAccountModel account, String password, LmPoolModel pool,
      TokensModel token, double amount);
  String removeBalance(AbstractAccountModel account, String password,
      LmPoolModel pool, double percentage);
}
