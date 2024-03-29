import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/access_token_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/staking/staking_model.dart';
import 'package:defi_wallet/models/network/staking/staking_token_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';

import 'abstract_account_model.dart';

abstract class  AbstractStakingProviderModel {
  Map<int, AccessTokenModel> accessTokensMap = {};

  AbstractStakingProviderModel();

  // List<String> getRequiredKycInfo();
  //
  // void saveKycData(AbstractAccountModel account, Map<String, String> kycData);
  //
  // Map<String, String> getSavedKycData(AbstractAccountModel account);

  // void deleteSavedKycData(
  //     AbstractAccountModel account, Map<String, String> kycData);

  Future<bool> isKycDone(AbstractAccountModel account);

  AccessTokenModel? getAccessToken(AbstractAccountModel account){
    return accessTokensMap[account.accountIndex];
  }

  Future<List<StakingTokenModel>> getAvailableStakingTokens(
    AbstractAccountModel account,
    AbstractNetworkModel networkModel,
  );

  Future<StakingTokenModel> getDefaultStakingToken(
    AbstractAccountModel account,
    AbstractNetworkModel networkModel,
  );

  Future<BigInt> getAmountStaked(
      AbstractAccountModel account, TokenModel token);

  Future<StakingModel> getStaking(AbstractAccountModel account);

  Future<TxErrorModel> stakeToken(
      AbstractAccountModel account,
      String password,
      StakingTokenModel token,
      StakingModel stakingModel,
      AbstractNetworkModel network,
      double amount,
      String asset,
      ApplicationModel applicationModel);

  Future<bool> unstakeToken(
      AbstractAccountModel account,
      String password,
      StakingTokenModel token,
      StakingModel stakingModel,
      AbstractNetworkModel network,
      double amount,
      String asset,
      ApplicationModel applicationModel);

  Map<String, dynamic> toJson();
}
