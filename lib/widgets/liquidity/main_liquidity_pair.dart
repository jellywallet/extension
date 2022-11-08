import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/screens/liquidity/remove_liquidity_screen.dart';
import 'package:defi_wallet/screens/liquidity/select_pool_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:defi_wallet/widgets/liquidity/liquidity_asset_pair.dart';
import 'package:flutter/material.dart';

class MainLiquidityPair extends StatelessWidget {
  final AssetPairModel? assetPair;
  final int? balance;
  final bool isBorder;

  const MainLiquidityPair({
    Key? key,
    this.assetPair,
    this.balance,
    this.isBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: AssetPair(pair: assetPair!.symbol!, size: 25),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              child: Text(
                TokensHelper().getTokenFormat(assetPair!.symbol),
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .apply(fontWeightDelta: 3, fontSizeDelta: 2),
              ),
            ),
          ),
          LiquidityAssetPair(assetPair: assetPair, balance: balance),
          Row(
            children: [
              TextButton(
                onPressed: () => lockHelper.provideWithLockChecker(
                  context,
                  () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          SelectPoolScreen(
                        assetPair: assetPair!,
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: AppTheme.pinkColor,
                ),
                style: ButtonStyle(
                  shadowColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).cardColor,
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.all(10),
                  ),
                  minimumSize: MaterialStateProperty.all(
                    Size(24, 30),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
              ),
              TextButton(
                onPressed: () => lockHelper.provideWithLockChecker(
                  context,
                  () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          RemoveLiquidityScreen(
                        assetPair: assetPair!,
                        balance: balance!,
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: Colors.black,
                ),
                style: ButtonStyle(
                  shadowColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).cardColor,
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.all(10),
                  ),
                  minimumSize: MaterialStateProperty.all(
                    Size(24, 30),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
