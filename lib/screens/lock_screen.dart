import 'dart:convert' as Convert;
import 'dart:convert';
import 'package:crypt/crypt.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/screens/auth/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/services/storage/hive_service.dart';
import 'package:defi_wallet/services/storage/storage_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/dialogs/restore_wallet_dialog.dart';
import 'package:defi_wallet/widgets/extension_welcome_bg.dart';
import 'package:defi_wallet/widgets/fields/password_text_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/services/logger_service.dart';

class LockScreen extends StatefulWidget {
  final String? savedMnemonic;

  const LockScreen({Key? key, this.savedMnemonic}) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SnackBarMixin {
  SettingsHelper settingsHelper = SettingsHelper();
  bool isPasswordObscure = true;
  bool isEnable = true;
  bool isValid = true;
  bool isVisiblePasswordField = true;
  bool isFailed = false;
  Convert.Codec<String, String> stringToBase64 =
      Convert.utf8.fuse(Convert.base64);
  GlobalKey globalKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordController = TextEditingController();

  PasswordStatusList passwordStatus = PasswordStatusList.initial;

  @override
  Widget build(BuildContext context) {
    bool isFullScreen = MediaQuery.of(context).size.width > ScreenSizes.medium;
    return Scaffold(
      body: Stack(
        children: [
          if (!isFullScreen)
            ExtensionWelcomeBg()
          else
            Center(
              child: Image.asset(
                'assets/images/jelly_protect.png',
                width: 191,
                height: 306,
              ),
            ),
          Container(
            padding: const EdgeInsets.only(bottom: 42),
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: authPaddingContainer.copyWith(
                        top: 0,
                        bottom: 0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            PasswordTextField(
                              onlyEngCharacters: false,
                              isOpasity: !isFullScreen,
                              height: 71,
                              controller: _passwordController,
                              status: passwordStatus,
                              hint: 'Your password',
                              label: 'Password',
                              isShowObscureIcon: true,
                              isCaptionShown: false,
                              onEditComplete: () =>
                                  (globalKey.currentWidget! as ElevatedButton)
                                      .onPressed!(),
                              isObscure: isPasswordObscure,
                              onChanged: (val) {},
                              onPressObscure: () {
                                setState(() =>
                                    isPasswordObscure = !isPasswordObscure);
                              },
                              validator: (val){
                                return isValid ? null : "Incorrect password";
                              },
                            ),
                            StretchBox(
                              maxWidth: ScreenSizes.xSmall,
                              child: PendingButton(
                                'Unlock',
                                pendingText: 'Pending...',
                                isCheckLock: false,
                                globalKey: globalKey,
                                callback: (parent) => _restoreWallet(parent),
                              ),
                            ),
                            SizedBox(height: 20),
                            InkWell(
                              child: Text(
                                'Forgot password?',
                                style: AppTheme.defiUnderlineText,
                              ),
                              onTap: isEnable
                                  ? () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                      RecoveryScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _restoreWallet(parent) async {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);

    setState(() {
      isValid = true;
      _formKey.currentState!.validate();
      isFailed = false;
      isEnable = false;
    });

    if (widget.savedMnemonic == null) {
      var applicationModel = await StorageService.loadApplication();
      if (applicationModel.validatePassword(_passwordController.text)) {
        setState(() {
          isValid = true;
          _formKey.currentState!.validate();
        });

        parent.emitPending(true);
        await walletCubit.loadWalletDetails();
        parent.emitPending(false);
        LoggerService.invokeInfoLogg('user was unlock wallet');

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                HomeScreen(isLoadTokens: true),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        _setInvalidPasswordField();
      }
    } else {
      var encryptedPassword = await HiveService.getData(HiveNames.password);
      if (Crypt(encryptedPassword).match(_passwordController.text)) {
        await _restoreExistingWallet(_passwordController.text, context, parent);
      } else {
        _setInvalidPasswordField();
      }
    }
  }

  _restoreExistingWallet(
    String password,
    BuildContext context,
    dynamic parent,
  ) async {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);

    showDialog(
      barrierColor: AppColors.tolopea.withOpacity(0.06),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return RestoreWalletDialog(
          callbackOk: () async {
            parent.emitPending(true);

            List<String> mnemonic = EncryptHelper.getDecryptedData(
              widget.savedMnemonic,
              _passwordController.text,
            ).split(',');

            try {
              var lastSent = await HiveService.getData(HiveNames.lastSent);
              var addressBook = await HiveService.getData(HiveNames.addressBook);
              List<AddressBookModel> lastSentAddressBook = [];
              List<AddressBookModel> mainAddressBook = [];

              if (lastSent != null) {
                var lastSentList = json.decode(lastSent);
                lastSentAddressBook = List.generate(
                  lastSentList.length,
                  (index) => AddressBookModel.fromJson(
                    lastSentList[index],
                  ),
                );
              }
              if (addressBook != null) {
                var mainAddressBookList = json.decode(addressBook);
                mainAddressBook = List.generate(
                  mainAddressBookList.length,
                      (index) => AddressBookModel.fromJson(
                        mainAddressBookList[index],
                  ),
                );
              }
              await HiveService.clearBox(HiveBoxes.client);
              await walletCubit.restoreWallet(
                mnemonic,
                _passwordController.text,
                lastSent: lastSentAddressBook,
                addressBook: mainAddressBook,
              );
              parent.emitPending(false);

              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => HomeScreen(
                    isLoadTokens: true,
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            } catch (err) {
              parent.emitPending(false);
              showSnackBar(
                context,
                title: 'Something went wrong',
                color: AppColors.txStatusError.withOpacity(0.1),
                prefix: Icon(
                  Icons.close,
                  color: AppColors.txStatusError,
                ),
              );
            }
          },
        );
      },
    );
  }

  _setInvalidPasswordField() {
    setState(() {
      isValid = false;
      _formKey.currentState!.validate();
      passwordStatus = PasswordStatusList.error;
      isFailed = true;
      isEnable = true;
    });
  }
}
