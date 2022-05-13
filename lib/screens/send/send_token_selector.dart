import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/screens/send/widgets/address_field.dart';
import 'package:defi_wallet/screens/send/widgets/asset_dropdown.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/account/account_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/screens/send/send_confirm_screen.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendTokenSelector extends StatefulWidget {
  @override
  State<SendTokenSelector> createState() => _SendConfirmState();
}

class _SendConfirmState extends State<SendTokenSelector> {
  TokensHelper tokenHelper = TokensHelper();
  BalancesHelper balancesHelper = BalancesHelper();
  TransactionService transactionService = TransactionService();
  GlobalKey<AssetSelectState> _selectKeyFrom =
      GlobalKey<AssetSelectState>();
  TextEditingController _amountController =
      TextEditingController(text: '0');
  FocusNode _amountFocusNode = new FocusNode();
  FocusModel _amountFocusModel = new FocusModel();
  AddressesHelper addressHelper = AddressesHelper();
  TextEditingController addressController = TextEditingController();
  bool isFailed = false;
  bool isFailedAddress = false;
  bool _isBalanceError = false;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  String assetFrom = '';
  String assetTo = '';

  void dispose() {
    hideOverlay();
    super.dispose();
  }

  void hideOverlay() {
    try {
      _selectKeyFrom.currentState!.hideOverlay();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TransactionCubit, TransactionState>(
    builder: (context, state) => ScaffoldConstrainedBox(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: MainAppBar(
                title: 'Send',
                isShowBottom: !(state is TransactionInitialState),
                height: !(state is TransactionInitialState)
                    ? toolbarHeightWithBottom
                    : toolbarHeight,
              ),
              body: _buildBody(context),
            );
          } else {
            return Container(
              padding: const EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: MainAppBar(
                  title: 'Send',
                  action: null,
                  isSmall: true,
                ),
                body: _buildBody(context, isCustomBgColor: true),
              ),
            );
          }
        })
    ),
  );

  Widget _buildBody(context, {isCustomBgColor = false}) => BlocBuilder<AccountCubit, AccountState>(
    builder: (context, state) {
      if (state is AccountLoadedState) {
        assetFrom = (assetFrom.isEmpty) ? state.activeToken : assetFrom;
        List<String> assets = [];
        state.activeAccount.balanceList!.forEach((el) => assets.add(el.token!));

        return Container(
          color: isCustomBgColor ? Theme.of(context).dialogBackgroundColor : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: StretchBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Text('Address', style: Theme.of(context).textTheme.headline6),
                        SizedBox(height: 16),
                        AddressField(
                          addressController: addressController,
                          onChanged: (value) {
                            if (isFailed) {
                              setState(() {
                                isFailed = false;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Address is invalid',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline4!
                              .copyWith(
                            color: isFailedAddress
                                ? AppTheme.redErrorColor
                                : Colors.transparent,
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 12),
                        Text(
                          'Amount',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        SizedBox(height: 16),
                        AssetDropdown(
                          selectKeyFrom: _selectKeyFrom,
                          amountController: _amountController,
                          focusNode: _amountFocusNode,
                          focusModel: _amountFocusModel,
                          assets: assets,
                          assetFrom: assetFrom,
                          onSelect: (String asset) {
                            setState(() => {assetFrom = asset});
                          },
                          onChanged: (value) {
                            if (isFailed) {
                              setState(() {
                                isFailed = false;
                              });
                            }
                          },
                          onPressed: () {
                            setState(() {
                              int balance = state.activeAccount.balanceList!
                                  .firstWhere((el) => el.token! == assetFrom)
                                  .balance!;
                              final int fee = 3000;
                              double amount = convertFromSatoshi(balance - fee);
                              _amountController.text = amount.toString();
                            });
                          },
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Amount is invalid',
                          style: Theme.of(context).textTheme.headline4!.copyWith(
                            color: isFailed
                                ? AppTheme.redErrorColor
                                : Colors.transparent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Insufficient funds',
                            style: Theme.of(context).textTheme.headline4!.copyWith(
                              color: _isBalanceError
                                  ? AppTheme.redErrorColor
                                  : Colors.transparent,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  PrimaryButton(
                    label: 'Continue',
                    callback: () => submitToConfirm(state),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return Loader();
      }
    },
  );

  submitToConfirm(state) async {
    var valid = await addressHelper
        .validateAddress(addressController.text);
    if (valid) {
      int balance = state.activeAccount.balanceList!
          .firstWhere((el) => el.token! == assetFrom)
          .balance!;
      final int fee = 3000;
      double amount = convertFromSatoshi(balance - fee);
      if (double.parse(_amountController.text
          .replaceAll(',', '.')) > 0) {
        if (double.parse(_amountController.text.replaceAll(',', '.')) < amount) {
          hideOverlay();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SendConfirmScreen(
                addressController.text,
                assetFrom,
                double.parse(_amountController.text.replaceAll(',', '.')),
              ),
            ),
          );
        } else {
          if (!_isBalanceError) {
            setState(() {
              _isBalanceError = true;
            });
          }
        }
      } else {
        if (!isFailed) {
          setState(() {
            isFailed = true;
          });
        }
      }
    } else {
      if (!isFailedAddress) {
        setState(() {
          isFailedAddress = true;
        });
      }
    }
  }
}
