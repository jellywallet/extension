import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair_details.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:defi_wallet/services/logger_service.dart';

class LiquidityStatus extends StatefulWidget {
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

  const LiquidityStatus(
      {Key? key,
      required this.assetPair,
      required this.isRemove,
      required this.amountA,
      required this.amountB,
      required this.amountUSD,
      required this.balanceUSD,
      required this.balanceA,
      required this.balanceB,
      required this.txError,
      this.isBalanceDetails = true})
      : super(key: key);

  @override
  _LiquidityStatusState createState() => _LiquidityStatusState();
}

class _LiquidityStatusState extends State<LiquidityStatus> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldConstrainedBox(
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < ScreenSizes.medium) {
          return Scaffold(
            appBar: MainAppBar(
              title: 'Add Recipient',
              action: IconButton(
                      padding: const EdgeInsets.all(0),
                      splashRadius: 18,
                      color:
                          Theme.of(context).appBarTheme.actionsIconTheme!.color,
                      onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          ),
                      icon: Icon(Icons.clear)),
            ),
            body: _buildBody(context),
          );
        } else {
          return Container(
            padding: const EdgeInsets.only(top: 20),
            child: Scaffold(
                appBar: MainAppBar(
                  title: 'Add Recipient',
                  action: IconButton(
                      padding: const EdgeInsets.all(0),
                      splashRadius: 18,
                      color:
                      Theme.of(context).appBarTheme.actionsIconTheme!.color,
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      ),
                      icon: Icon(Icons.clear)),
                  isSmall: true,
                ),
              body: _buildBody(context),
            ),
          );
        }
      }),
    );
  }

  Widget _buildBody(context) {
    var actionName = widget.isRemove ? 'remove liquidity' : 'add liquidity';
    if (widget.txError.isError) {
      LoggerService.invokeInfoLogg('user was $actionName token failed: ${widget.txError.error}');
    } else {
      LoggerService.invokeInfoLogg('user was $actionName token successfully');

      TransactionCubit transactionCubit =
        BlocProvider.of<TransactionCubit>(context);

      transactionCubit.setOngoingTransaction(widget.txError.txid!);
    }
    return Container(
      color: Theme
          .of(context)
          .dialogBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: StretchBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        children: [
                          widget.txError.isError
                              ? Image.asset(
                            'assets/error_gif.gif',
                            height: 126,
                            width: 124,
                          )
                              : Image.asset(
                            'assets/status_reload_icon.png',
                            height: 126,
                            width: 124,
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
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline6,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Your account balance will be updated in a few minutes.', style: Theme
                                .of(context)
                                .textTheme
                                .headline4!.apply(color: Color(0xFFC4C4C4), fontWeightDelta: 2)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 42),
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
              widget.txError.isError ? Text(
                widget.txError.error.toString() ==
                    'txn-mempool-conflict (code 18)'
                    ? 'Wait for approval the previous tx'
                    : widget.txError.error.toString(),
                style: Theme
                    .of(context)
                    .textTheme
                    .button,
              ) : Row(
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
                    onTap: () =>
                        launch(
                            'https://defiscan.live/transactions/${widget.txError
                                .txid}?network=${SettingsHelper.settings
                                .network!}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
