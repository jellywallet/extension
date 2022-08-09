import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/screens/earn_screen/widgets/earn_card.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_screen.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EarnScreen extends StatefulWidget {
  const EarnScreen({Key? key}) : super(key: key);

  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldConstrainedBox(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: MainAppBar(
                title: "Earn with DeFiChain",
              ),
              body: _buildBody(),
            );
          } else {
            return Container(
              padding: const EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: MainAppBar(
                  title: "Earn with DeFiChain",
                  isSmall: true,
                ),
                body: _buildBody(isFullSize: true),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBody({isFullSize = false}) {
    return BlocBuilder<AccountCubit, AccountState>(
        builder: (accountContext, accountState) {
          return BlocBuilder<TokensCubit, TokensState>(
              builder: (tokensContext, tokensState) {
                double totalPairsBalance = 0;
                String maxApr =
                TokensHelper().getAprFormat(getMaxAPR(tokensState.tokensPairs!));

                accountState.activeAccount!.balanceList!.forEach((element) {
                  if (!element.isHidden! && !element.isPair!) {
                  } else if (element.isPair!) {
                    var foundedAssetPair = List.from(tokensState.tokensPairs!
                        .where((item) => element.token == item.symbol))[0];

                    double baseBalance = element.balance! *
                        (1 / foundedAssetPair.totalLiquidityRaw) *
                        foundedAssetPair.reserveA!;
                    double quoteBalance = element.balance! *
                        (1 / foundedAssetPair.totalLiquidityRaw) *
                        foundedAssetPair.reserveB!;

                    totalPairsBalance += tokenHelper.getAmountByUsd(
                      tokensState.tokensPairs!,
                      baseBalance,
                      foundedAssetPair.tokenA,
                    );
                    totalPairsBalance += tokenHelper.getAmountByUsd(
                      tokensState.tokensPairs!,
                      quoteBalance,
                      foundedAssetPair.tokenB,
                    );
                  }
                });

                return SingleChildScrollView(
                  child: Container(
                    color: isFullSize ? Theme.of(context).dialogBackgroundColor : null,
                    padding:
                    const EdgeInsets.only(left: 18, right: 18, top: 24, bottom: 24),
                    child: Center(
                      child: isFullSize
                          ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              EarnCard(
                                title: 'STAKING',
                                titleWidget: Row(
                                  children: [
                                    SvgPicture.asset('assets/tokens/defi.svg'),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      'DFI',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .apply(fontWeightDelta: 2),
                                    )
                                  ],
                                ),
                                smallTitleWidget: Row(
                                  children: [
                                    SvgPicture.asset('assets/tokens/defi.svg'),
                                  ],
                                ),
                                percent: '43% APY',
                                balance: '1749',
                                currency: 'DFI',
                                status: 'staked',
                                firstBtnTitle: 'STAKE',
                                secondBtnTitle: 'UNSTAKE',
                                firstBtnCallback: () {},
                                isCheckLockSecond: false,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              EarnCard(
                                title: 'LIQUIDITY MINING',
                                titleWidget: AssetPair(
                                  pair: 'BTC-DFI',
                                  size: 24,
                                  isTransform: false,
                                ),
                                smallTitleWidget: AssetPair(
                                  pair: 'BTC-DFI',
                                  size: 24,
                                  isTransform: false,
                                ),
                                percent: maxApr,
                                balance: balancesHelper.numberStyling(
                                    totalPairsBalance,
                                    fixed: true),
                                currency: 'USD',
                                status: 'pooled',
                                firstBtnTitle: 'ADD',
                                secondBtnTitle: 'REMOVE',
                                firstBtnCallback: liquidityCallback,
                                isCheckLockSecond: false,
                              ),
                            ],
                          ),
                        ],
                      )
                          : StretchBox(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                EarnCard(
                                  title: 'STAKING',
                                  titleWidget: Row(
                                    children: [
                                      SvgPicture.asset('assets/tokens/defi.svg'),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        'DFI',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .apply(fontWeightDelta: 2),
                                      )
                                    ],
                                  ),
                                  smallTitleWidget: Row(
                                    children: [
                                      SvgPicture.asset('assets/tokens/defi.svg'),
                                    ],
                                  ),
                                  percent: '43% APY',
                                  balance: '1749',
                                  currency: 'DFI',
                                  status: 'staked',
                                  firstBtnTitle: 'STAKE',
                                  secondBtnTitle: 'UNSTAKE',
                                  firstBtnCallback: () {},
                                  isCheckLockSecond: false,
                                  isSmall: true,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                EarnCard(
                                  title: 'LIQUIDITY MINING',
                                  titleWidget: AssetPair(
                                    pair: 'BTC-DFI',
                                    size: 24,
                                    isTransform: false,
                                  ),
                                  smallTitleWidget: AssetPair(
                                    pair: 'BTC-DFI',
                                    size: 24,
                                    isTransform: false,
                                  ),
                                  percent: maxApr,
                                  balance: balancesHelper.numberStyling(
                                      totalPairsBalance,
                                      fixed: true),
                                  currency: 'USD',
                                  status: 'pooled',
                                  firstBtnTitle: 'ADD',
                                  secondBtnTitle: 'REMOVE',
                                  firstBtnCallback: liquidityCallback,
                                  isCheckLockSecond: false,
                                  isSmall: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  double getMaxAPR(List<AssetPairModel> tokenPairs) {
    double maxValue = 0;

    tokenPairs.forEach((element) {
      if (maxValue < element.apr!) {
        maxValue = element.apr!;
      }
    });
    return maxValue;
  }

  liquidityCallback() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => LiquidityScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
