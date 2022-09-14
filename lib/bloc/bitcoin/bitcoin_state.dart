part of 'bitcoin_cubit.dart';

enum BitcoinStatusList { initial, loading, success, failure }

class BitcoinState extends Equatable {
  final BitcoinStatusList status;
  final int totalBalance;
  final int availableBalance;
  final int activeFee;
  final NetworkFeeModel? networkFee;

  BitcoinState({
    this.status = BitcoinStatusList.initial,
    this.totalBalance = 0,
    this.availableBalance = 0,
    this.activeFee = 0,
    this.networkFee,
  });

  BitcoinState copyWith({
    BitcoinStatusList? status,
    int? totalBalance,
    int? availableBalance,
    int? activeFee,
    NetworkFeeModel? networkFee,
  }) {
    return BitcoinState(
      status: status ?? this.status,
      totalBalance: totalBalance ?? this.totalBalance,
      availableBalance: availableBalance ?? this.availableBalance,
      activeFee: activeFee ?? this.activeFee,
      networkFee: networkFee ?? this.networkFee,
    );
  }

  @override
  List<Object?> get props => [
    status,
    totalBalance,
    availableBalance,
    activeFee,
    networkFee,
  ];
}
