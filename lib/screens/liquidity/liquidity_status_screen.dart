import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/services/logger_service.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair_details.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class LiquidityStatusScreen extends StatefulWidget {
  final AssetPairModel assetPair;
  final bool isRemove;
  final double amountA;
  final double amountB;
  final double balanceA;
  final double balanceB;
  final double amountUSD;
  final double balanceUSD;
  final TxErrorModel txError;
  final bool isBalanceDetails;

  const LiquidityStatusScreen({
    Key? key,
    required this.assetPair,
    required this.isRemove,
    required this.amountA,
    required this.amountB,
    required this.amountUSD,
    required this.balanceUSD,
    required this.balanceA,
    required this.balanceB,
    required this.txError,
    this.isBalanceDetails = true,
  }) : super(key: key);

  @override
  _LiquidityStatusScreenState createState() => _LiquidityStatusScreenState();
}

class _LiquidityStatusScreenState extends State<LiquidityStatusScreen> {
  String appBarTitle = 'Add Recipient';
  double homeButtonWidth = 150;
  double statusImageWidth = 104;
  double statusImageHeight = 106;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        var actionName = widget.isRemove ? 'remove liquidity' : 'add liquidity';
        if (widget.txError.isError) {
          LoggerService.invokeInfoLogg(
            'user was $actionName token failed: ${widget.txError.error}',
          );
        } else {
          LoggerService.invokeInfoLogg(
            'user was $actionName token successfully',
          );
          TransactionCubit transactionCubit =
              BlocProvider.of<TransactionCubit>(context);
          transactionCubit.setOngoingTransaction(widget.txError.txid!);
        }
        return Scaffold(
          appBar: MainAppBar(
            isShowNavButton: false,
            title: appBarTitle,
            isSmall: isFullScreen,
          ),
          body: Container(
            color: Theme.of(context).dialogBackgroundColor,
            padding: AppTheme.screenPadding,
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 24),
                              child: Column(
                                children: [
                                  widget.txError.isError
                                      ? Image.asset(
                                          'assets/error_gif.gif',
                                          height: statusImageHeight,
                                          width: statusImageWidth,
                                        )
                                      : Image.asset(
                                          'assets/status_reload_icon.png',
                                          height: statusImageHeight,
                                          width: statusImageWidth,
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 32),
                                    child: Text(
                                      widget.txError.isError
                                          ? 'Something went wrong!'
                                          : widget.isRemove
                                              ? 'Liquidity has been removed successfully!'
                                              : 'Liquidity has been added successfully!',
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                    ),
                                    child: Text(
                                      'Your account balance will be updated in a few minutes.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .apply(
                                            color: Color(0xFFC4C4C4),
                                            fontWeightDelta: 2,
                                          ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 22),
                              child: AssetPairDetails(
                                assetPair: widget.assetPair,
                                isRemove: widget.isRemove,
                                amountA: widget.amountA,
                                amountB: widget.amountB,
                                balanceA: widget.balanceA,
                                balanceB: widget.balanceB,
                                totalAmountInUsd: widget.amountUSD,
                                totalBalanceInUsd: widget.balanceUSD,
                                isBalanceDetails: widget.isBalanceDetails,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: homeButtonWidth,
                      child: PrimaryButton(
                        label: 'Home',
                        callback: () => Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (
                              context,
                              animation1,
                              animation2,
                            ) =>
                                HomeScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    widget.txError.isError
                        ? Text(
                            widget.txError.error.toString() ==
                                    'txn-mempool-conflict (code 18)'
                                ? 'Wait for approval the previous tx'
                                : widget.txError.error.toString(),
                            style: Theme.of(context).textTheme.button,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/explorer_icon.svg',
                                color: AppTheme.pinkColor,
                              ),
                              SizedBox(width: 10),
                              InkWell(
                                child: Text(
                                  'View on Explorer',
                                  style: AppTheme.defiUnderlineText,
                                ),
                                onTap: () => launch(
                                  'https://defiscan.live/transactions/${widget.txError.txid}?network=${SettingsHelper.settings.network!}',
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
