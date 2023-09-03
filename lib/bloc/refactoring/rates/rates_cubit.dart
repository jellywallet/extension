import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/error/error_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_network_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_rate_model.dart';
import 'package:defi_wallet/models/network/rates/rates_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/requests/ethereum/eth_rpc_requests.dart';
import 'package:defi_wallet/services/errors/sentry_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'rates_state.dart';

class RatesCubit extends Cubit<RatesState> {
  RatesCubit() : super(RatesState());

  setInitial() {
    emit(state.copyWith(
      status: RatesStatusList.initial,
    ));
  }

  updateActiveAsset(String asset) {
    emit(state.copyWith(
      activeAsset: asset,
    ));
  }

  loadRates(AbstractNetworkModel network) async {
    emit(state.copyWith(
      status: RatesStatusList.loading,
    ));

    RatesModel ratesModel = state.ratesModel ?? RatesModel();

    try {
      EthereumRateModel? ethereumRateModel = state.ethereumRateModel;
      if (network is EthereumNetworkModel) {
        ethereumRateModel = await ETHRPCRequests().loadRates();
      }
      await ratesModel.loadTokens(network);

      emit(state.copyWith(
        status: RatesStatusList.success,
        ratesModel: ratesModel,
        ethereumRateModel: ethereumRateModel,
      ));
    } catch (error, stackTrace) {
      SentryService.captureException(
        ErrorModel(
          file: 'rates_cubit.dart',
          method: 'loadRates',
          exception: error.toString(),
        ),
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        status: RatesStatusList.failure,
      ));
    }
  }

  searchTokens({
    String value = '',
    List<TokenModel> existingTokens = const [],
    List<TokenModel> allTokens = const [],
  }) {
    List<TokenModel> generalTokens =
        allTokens.isNotEmpty ? allTokens : state.ratesModel!.tokens!;
    List<TokenModel> tokens = [];

    if (value.isEmpty) {
      tokens = generalTokens;
    } else {
      for (TokenModel element in generalTokens) {
        if (element.displaySymbol.toLowerCase().contains(value.toLowerCase())) {
          tokens.add(element);
        }
      }
    }
    if (existingTokens.isNotEmpty) {
      existingTokens.forEach((element) {
        tokens.removeWhere((token) => token.symbol == element.symbol);
      });
    }
    emit(state.copyWith(
      tokens: tokens,
      activeAsset: state.activeAsset,
    ));
  }
}
