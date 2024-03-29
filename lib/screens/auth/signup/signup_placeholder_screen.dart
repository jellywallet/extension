import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/storage_phrase_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/auth/signup/signup_account_screen.dart';
import 'package:defi_wallet/screens/auth/signup/signup_phrase_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class SignupPlaceholderScreen extends StatefulWidget {
  final String password;

  SignupPlaceholderScreen({
    Key? key,
    required this.password,
  }) : super(key: key);

  @override
  State<SignupPlaceholderScreen> createState() =>
      _SignupPlaceholderScreenState();
}

class _SignupPlaceholderScreenState extends State<SignupPlaceholderScreen>
    with ThemeMixin, StoragePhraseMixin {
  static const int _mnemonicStrength = 256;
  final double _progress = 0.7;
  final double _coverWidth = 296.0;
  final double _coverHeight = 258.0;
  final double _logoWidth = 210.0;
  final double _logoHeight = 200.0;
  final double _logoRotateDeg = 17.5;

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
            progress: _progress,
          ),
          body: Center(
            child: Container(
              padding: authPaddingContainer,
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Text(
                            'Secure your wallet',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Secure your wallet’s seed phrase.',
                            style: Theme.of(context).textTheme.headline5!.apply(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .color!
                                      .withOpacity(0.6),
                                ),
                          ),
                          SizedBox(
                            height: 21,
                          ),
                          Stack(
                            children: [
                              Positioned(
                                child: Image.asset(
                                  'assets/images/jelly_protect.png',
                                  width: 191,
                                  height: 306,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  child: Text(
                                    'Remind me later ',
                                    style: jellyLink,
                                  ),
                                  onTap: () {
                                    List<String> mnemonic = generateMnemonic(
                                            strength: _mnemonicStrength)
                                        .split(' ');
                                    savePhraseToStorage(mnemonic.join(','));
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                            SignupAccountScreen(
                                              password: widget.password,
                                              mnemonic: mnemonic,
                                            ),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration: Duration.zero,
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  ' (not recommended)',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .apply(
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .color!
                                            .withOpacity(0.3),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: NewPrimaryButton(
                              width: isFullScreen ? buttonFullWidth : buttonSmallWidth,
                              title: 'Continue',
                              callback: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          SignupPhraseScreen(
                                    password: widget.password,
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
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
