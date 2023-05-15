import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';

class BalanceModel {
  TokenModel? token;
  LmPoolModel? lmPool;
  int balance;

  BalanceModel({
    required this.balance,
    this.token,
    this.lmPool,
  }) {
    if (this.token == null && this.lmPool == null) {
      throw 'Empty token or LMPool';
    }
  }

  static List<BalanceModel> fromJSONList(
    List<dynamic> jsonList,
    AbstractNetworkModel network,
      List<TokenModel> tokens
  ) {
    List<BalanceModel> balances = List.generate(
      jsonList.length,
      (index) => BalanceModel.fromJSON(jsonList[index], network, tokens),
    );

    return balances;
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['balance'] = this.balance;
    if (this.token != null) {
      data['token'] = this.token!.toJSON();
    }
    if (this.lmPool != null) {
      data['lmPool'] = this.lmPool!.toJSON();
    }
    return data;
  }

  factory BalanceModel.fromJSON(
    Map<String, dynamic> json,
    AbstractNetworkModel network,
      List<TokenModel> tokens
  ) {
    TokenModel? token;
    LmPoolModel? lmPool;
    if (json['isLPS'] == false) {
      token = TokenModel.fromJSON(json, network.networkType.networkName);
    } else {
      lmPool = LmPoolModel.fromJSON(json, network.networkType.networkName, tokens);
    }
    return BalanceModel(
      balance: network.toSatoshi(double.parse(json['amount'])),
      token: token,
      lmPool: lmPool,
    );
  }

  bool compare(BalanceModel otherBalance) {
    if(this.lmPool != null && otherBalance.lmPool != null){
      return this.lmPool!.id == otherBalance.lmPool!.id;
    } else if(this.token != null && otherBalance.token != null){
      return this.token!.id == otherBalance.token!.id;
    } else {
      return false;
    }
  }
}
