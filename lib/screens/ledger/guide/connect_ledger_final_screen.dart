import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/auth/welcome_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ConnectLedgerFinalScreen extends StatefulWidget {
  const ConnectLedgerFinalScreen({Key? key}) : super(key: key);

  @override
  State<ConnectLedgerFinalScreen> createState() => _ConnectLedgerFinalScreenState();
}

class _ConnectLedgerFinalScreenState extends State<ConnectLedgerFinalScreen> with ThemeMixin {
  String subtitleText = 'You’ve successfully connected Jellywallet to your Ledger device. Remember to keep your Secret Recovery Phrase safe!';

  Future init() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.ledgerWalletSetup, true);
    await box.close();
  }

  initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: WelcomeAppBar(
            progress: 0.0,
          ),
          body: Container(
            padding: EdgeInsets.only(
              top: 27,
              bottom: 24,
              left: 16,
              right: 16,
            ),
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/defi_love_ledger.png',
                          width: 304.99,
                          height: 247.3,
                        ),
                        SizedBox(
                          width: 23,
                        ),
                      ],
                    ),
                    Container(
                      child: Column(
                        children: [
                          Text(
                            'Congratulations',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            height: 162,
                            child: Text(
                              subtitleText,
                              style: Theme.of(context).textTheme.headline5!.copyWith(
                                    color: Theme.of(context).textTheme.headline5!.color!.withOpacity(0.6),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          NewPrimaryButton(
                            width: buttonSmallWidth,
                            callback: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1, animation2) => new HomeScreen(
                                    isLoadTokens: true,
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            title: 'Next',
                          ),
                        ],
                      ),
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
