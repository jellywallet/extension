part of 'wallet_cubit.dart';

enum WalletStatusList { initial, loading, success, restore, failure }

class WalletState extends Equatable {
  final WalletStatusList status;
  final ApplicationModel? applicationModel;

  WalletState({
    this.status = WalletStatusList.initial,
    this.applicationModel,
  });

  List<BalanceModel> getBalances() {
    //TODO: add active network
    List<BalanceModel> balances = this.applicationModel!.activeAccount!.getPinnedBalances(applicationModel!.networks.first);
    return balances;
  }

  String get activeAddress => this.applicationModel!.activeAccount!.getAddress(this.applicationModel!.activeNetwork!.networkType.networkName)!;

  AbstractNetworkModel get activeNetwork =>
      this.applicationModel!.activeNetwork!;

  AbstractAccountModel get activeAccount => this.applicationModel!.activeAccount!;

  @override
  List<Object?> get props => [
        status,
        applicationModel,
      ];

  WalletState copyWith({
    WalletStatusList? status,
    ApplicationModel? applicationModel,
  }) {
    return WalletState(
      status: status ?? this.status,
      applicationModel: applicationModel ?? this.applicationModel,
    );
  }
}
