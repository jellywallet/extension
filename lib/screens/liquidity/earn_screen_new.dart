import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/error_screen.dart';
import 'package:defi_wallet/screens/liquidity/earn_card.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_screen_new.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/screens/staking/kyc/staking_kyc_start_screen.dart';
import 'package:defi_wallet/screens/staking/staking_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EarnScreenNew extends StatefulWidget {
  const EarnScreenNew({Key? key}) : super(key: key);

  @override
  State<EarnScreenNew> createState() => _EarnScreenNewState();
}

class _EarnScreenNewState extends State<EarnScreenNew>
    with ThemeMixin, SnackBarMixin {
  BalancesHelper balancesHelper = BalancesHelper();
  String titleText = 'Earn';
  int iterator = 0;

  @override
  void initState() {
    super.initState();
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await tokensCubit.calculateEarnPage(context);
      await fiatCubit.loadUserDetails(accountCubit.state.accounts!.first);
      await lockCubit.loadAnalyticsDetails(accountCubit.state.accounts!.first);
      await lockCubit.loadUserDetails(accountCubit.state.accounts!.first);
      await lockCubit.loadStakingDetails(accountCubit.state.accounts!.first);
    });
  }

  @override
  Widget build(BuildContext context) {
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<LockCubit, LockState>(
            builder: (lockContext, lockState) {
              var isLoading = lockState.status == LockStatusList.initial || lockState.status == LockStatusList.loading;
          if (lockState.status == LockStatusList.expired) {
            accountCubit.clearAccessTokens();
            LockHelper().lockWallet();
            Future.microtask(() => Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      LockScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                )));
            return Container();
          } else if (lockState.status == LockStatusList.success || isLoading) {
            return Scaffold(
              drawerScrimColor: Color(0x0f180245),
              endDrawer: AccountDrawer(
                width: buttonSmallWidth,
              ),
              appBar: NewMainAppBar(
                isShowLogo: false,
              ),
              body: Container(
                padding: EdgeInsets.only(
                  top: 22,
                  bottom: 24,
                  left: 16,
                  right: 16,
                ),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkTheme()
                      ? DarkColors.drawerBgColor
                      : LightColors.scaffoldContainerBgColor,
                  border: isDarkTheme()
                      ? Border.all(
                          width: 1.0,
                          color: Colors.white.withOpacity(0.05),
                        )
                      : null,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: StretchBox(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              titleText,
                              style: headline2.copyWith(
                                  fontWeight: FontWeight.w700),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 19,
                        ),
                        // stakingCard(lockState, isLoading),
                        SizedBox(
                          height: 18,
                        ),
                        BlocBuilder<TokensCubit, TokensState>(
                            builder: (tokensContext, tokensState) {
                              print(tokensState.status);
                          return Container();
                          // return liqudityMiningCard(tokensState, tokensState.status == TokensStatusList.success);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else  {
            return ErrorScreen();
          }
        });
      },
    );
  }

  Widget liqudityMiningCard(TokensState tokensState, bool isLoading) {
    print(tokensState.averageAccountAPR);
    String avaragePairsAPR =
        TokensHelper().getAprFormat(tokensState.averageAccountAPR!, false);
    return EarnCard(
        isLoading: isLoading,
        title: 'Liquidity mining',
        subTitle:
            'up to ${TokensHelper().getAprFormat(tokensState.maxAPR!, true)} APR',
        imagePath: 'assets/pair_icons/dfi_btc.png',
        firstColumnNumber: balancesHelper
            .numberStyling(tokensState.totalPairsBalance!, fixed: true),
        firstColumnAsset: 'USD',
        firstColumnSubTitle: 'Pooled',
        secondColumnNumber: avaragePairsAPR,
        secondColumnAsset: '%',
        secondColumnSubTitle: 'Portfolio APR',
        isStaking: false,
        callback: () => liquidityCallback(avaragePairsAPR));
  }

  Widget stakingCard(LockState lockState, bool isLoading) {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    if (lockState.status == LockStatusList.success ||
        isLoading) {
      return EarnCard(
          isLoading: isLoading,
          title: 'Staking',
          subTitle: lockState.status == LockStatusList.loading
              ? ''
              : 'up to '
                  '${BalancesHelper().numberStyling(
                  (lockState.lockAnalyticsDetails!.apy! * 100),
                  fixed: true,
                  fixedCount: 2,
                )}% APY',
          imagePath: 'assets/images/dfi_staking.png',
          firstColumnNumber: lockState.status == LockStatusList.loading
              ? ''
              : lockCubit.checkVerifiedUser()
                  ? balancesHelper.numberStyling(
                      lockState.lockStakingDetails!.balance!,
                      fixed: true,
                      fixedCount: 2,
                    )
                  : '0.00',
          firstColumnAsset: lockCubit.checkVerifiedUser()
              ? lockState.lockStakingDetails!.asset!
              : 'DFI',
          firstColumnSubTitle: 'Staked',
          isStaking: true,
          callback: () => lockState.status == LockStatusList.loading
              ? () => {}
              : stakingCallback());
    } else {
      return ErrorScreen();
    }
  }

  stakingCallback() async {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    if (lockCubit.checkVerifiedUser(isCheckOnlyKycStatus: true)) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => StakingScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      if (lockCubit.checkValidKycLink()) {
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
        await lockCubit.loadKycDetails(accountCubit.state.activeAccount!);
        await lockCubit.loadUserDetails(accountCubit.state.activeAccount!);
      }
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              StakingKycStartScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  liquidityCallback(String avaragePairsAPR) {
    Widget redirectTo = LiquidityScreenNew(averageARP: avaragePairsAPR);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => redirectTo,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
