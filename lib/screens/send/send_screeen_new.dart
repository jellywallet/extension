import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/transaction/tx_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/netwrok_mixin.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/screens/error_screen.dart';
import 'package:defi_wallet/screens/send/send_summary_screen.dart';
import 'package:defi_wallet/screens/settings/settings.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/dialogs/create_edit_contact_dialog.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/fields/address_field_new.dart';
import 'package:defi_wallet/widgets/refactoring/fields/amount_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/fees_selector.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendScreenNew extends StatefulWidget {
  const SendScreenNew({Key? key}) : super(key: key);

  @override
  State<SendScreenNew> createState() => _SendScreenNewState();
}

class _SendScreenNewState extends State<SendScreenNew>
    with ThemeMixin, NetworkMixin, SnackBarMixin {
  TextEditingController addressController = TextEditingController();
  TextEditingController assetController = TextEditingController(text: '0');
  FocusNode addressFocusNode = FocusNode();
  AddressBookModel contact = AddressBookModel();
  String suffixText = '';
  String? balanceInUsd;
  String titleText = 'Send';
  String subtitleText = 'Please enter the recipient and amount';
  bool isAddNewContact = false;
  bool isShowCheckbox = false;
  int iterator = 0;


  // Future<void> setAvailableBalance(
  //   List<BalanceModel> balances,
  //   TokenModel currentAsset,
  //   ApplicationModel applicationModel,
  //   AbstractAccountModel accountModel,
  // ) async {
  //   double balance = await applicationModel.networks[0].getAvailableBalance(
  //     account: accountModel,
  //     token: currentAsset,
  //     type: TxType.send,
  //   );
  //   setState(() {
  //     availableBalance = balance;
  //   });
  // }

  // String getUsdBalance(context) {
  //   TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
  //   try {
  //     var amount = tokenHelper.getAmountByUsd(
  //       tokensCubit.state.tokensPairs!,
  //       double.parse(assetController.text.replaceAll(',', '.')),
  //       currentAsset!.symbol!,
  //     );
  //     return balancesHelper.numberStyling(amount, fixedCount: 2, fixed: true);
  //   } catch (err) {
  //     return '0.00';
  //   }
  // }

  sendSubmit(addressBookCubit, TxState state, AbstractNetworkModel activeNetwork) async {
    if (addressController.text != '') {
      late bool isValidAddress = activeNetwork.checkAddress(addressController.text);

      if (isValidAddress) {
        if (isAddNewContact) {
          showDialog(
            barrierColor: AppColors.tolopea.withOpacity(0.06),
            barrierDismissible: false,
            context: context,
            builder: (BuildContext dialogContext) {
              return CreateEditContactDialog(
                isDisableEditAddress: true,
                address: addressController.text,
                isEdit: false,
                confirmCallback: (name, address, network) {
                  addressBookCubit.addAddress(
                    AddressBookModel(
                      name: name,
                      address: address,
                      network: network,
                    ),
                  );
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          SendSummaryScreen(
                        address: addressController.text,
                        isAfterAddContact: true,
                        amount: double.parse(assetController.text),
                        token: state.currentAsset!,
                        fee: 0,
                        // fee: state.activeFee,
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                  Navigator.pop(dialogContext);
                },
              );
            },
          );
        } else {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SendSummaryScreen(
                address: addressController.text,
                amount: double.parse(assetController.text),
                token: state.currentAsset!,
                fee: 0,
                // fee: state.activeFee,
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      } else {
        showSnackBar(
          context,
          title: 'Invalid address!',
          color: AppColors.txStatusError.withOpacity(0.1),
          prefix: Icon(
            Icons.close,
            color: AppColors.txStatusError,
          ),
        );
      }
    } else if (contact.name != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SendSummaryScreen(
            amount: double.parse(assetController.text),
            token: state.currentAsset!,
            contact: contact,
            fee: 0,
            // fee: state.activeFee,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      showSnackBar(
        context,
        title: 'Address is empty',
        color: AppColors.txStatusError.withOpacity(0.1),
        prefix: Icon(
          Icons.close,
          color: AppColors.txStatusError,
        ),
      );
    }
  }

  @override
  void initState() {
    addressController.addListener(() {
      if (addressController.text != '') {
        setState(() {
          isShowCheckbox = true;
        });
      } else {
        setState(() {
          isShowCheckbox = false;
          isAddNewContact = false;
        });
      }
    });
    TxCubit txCubit = BlocProvider.of<TxCubit>(context);
    txCubit.setInitial();
    super.initState();
  }

  @override
  void dispose() {
    addressController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<TxCubit, TxState>(
          builder: (context, state) {
            final walletCubit = BlocProvider.of<WalletCubit>(context);
            AbstractNetworkModel activeNetwork = walletCubit.getCurrentNetwork();
            bool isBitcoin = activeNetwork.networkType.networkName == NetworkName.bitcoinTestnet ||
                activeNetwork.networkType.networkName == NetworkName.bitcoinMainnet;
            TxCubit txCubit = BlocProvider.of<TxCubit>(context);
                  AddressBookCubit addressBookCubit =
                      BlocProvider.of<AddressBookCubit>(context);
                  if(state.status == TxStatusList.initial){
                    txCubit.init(context, TxType.send);
                  }

                  if (state.status == TxStatusList.success){
                    // setAvailableBalance(
                    //   state.getBalances(),
                    //   currentAsset!,
                    //   state.applicationModel!,
                    //   state.activeAccount!,
                    // );
                    // print(availableBalance);

                    return Scaffold(
                      drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
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
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          subtitleText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .apply(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color!
                                                    .withOpacity(0.6),
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 24,
                                    ),
                                    GestureDetector(
                                      onDoubleTap: () {
                                        addressFocusNode.requestFocus();
                                        if (addressController.text.isNotEmpty) {
                                          addressController.selection =
                                              TextSelection(
                                                  baseOffset: 0,
                                                  extentOffset:
                                                      addressController
                                                          .text.length);
                                        }
                                      },
                                      child: AddressFieldNew(
                                        addressFocusNode: addressFocusNode,
                                        clearPrefix: () {
                                          setState(() {
                                            contact = AddressBookModel();
                                          });
                                        },
                                        onChange: (val) {
                                          if (val == '') {
                                            setState(() {
                                              isAddNewContact = false;
                                            });
                                          }
                                        },
                                        controller: addressController,
                                        getAddress: (val) {
                                          addressController.text = val;
                                        },
                                        getContact: (val) {
                                          setState(() {
                                            addressController.text = '';
                                            contact = val;
                                          });
                                        },
                                        contact: contact,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Asset',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    AmountField(
                                      type: TxType.send,
                                      balance: state.activeBalance,
                                      onChanged: (value) {
                                        setState(() {
                                          //TODO: fix USD balance
                                          // balanceInUsd = getUsdBalance(context);
                                        });
                                      },
                                      available: state.availableBalance,
                                      // available: true,
                                      isDisabledSelector: isBitcoin,
                                      suffix: balanceInUsd ?? '0.00',
                                    // ?? getUsdBalance(context), //TODO: fix it
                                      onAssetSelect: (asset) async {
                                        txCubit.changeActiveBalance(context, asset, TxType.send);
                                      },
                                      controller: assetController,
                                      assets: state.balances!,
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    if (isBitcoin)
                                      ...[
                                              Row(
                                        children: [
                                          Text(
                                            'Fees',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      FeesSelector(
                                        onSelect: (int fee) {
                                          txCubit.changeActiveFee(fee);
                                        },
                                        activeFee: state.activeFee,
                                        fees: [
                                          state.networkFee!.low!,
                                          state.networkFee!.medium!,
                                          state.networkFee!.high!,
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                                Column(
                                  children: [
                                    if (isShowCheckbox)
                                      DefiCheckbox(
                                        callback: (val) {
                                          setState(() {
                                            isAddNewContact = val!;
                                          });
                                        },
                                        value: isAddNewContact,
                                        width: 250,
                                        isShowLabel: false,
                                        textWidget: Text(
                                          'Add contact to Address Book',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .copyWith(
                                                fontWeight: FontWeight.w400,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color!
                                                    .withOpacity(0.8),
                                              ),
                                        ),
                                      ),
                                    if (addressController.text != '')
                                      SizedBox(
                                        height: 18.5,
                                      ),
                                    NewPrimaryButton(
                                      width: buttonSmallWidth,
                                      callback: BalancesHelper().isAmountEmpty(
                                              assetController.text)
                                          ? () {
                                              showSnackBar(
                                                context,
                                                title: 'Amount is empty',
                                                color: AppColors.txStatusError
                                                    .withOpacity(0.1),
                                                prefix: Icon(
                                                  Icons.close,
                                                  color:
                                                      AppColors.txStatusError,
                                                ),
                                              );
                                            }
                                          : () {
                                              if (txState
                                                  is! TransactionLoadingState) {
                                                sendSubmit(addressBookCubit,
                                                    state, activeNetwork);
                                              } else {
                                                showSnackBar(
                                                  context,
                                                  title:
                                                      'Please wait for the previous '
                                                      'transaction',
                                                  color: AppColors.txStatusError
                                                      .withOpacity(0.1),
                                                  prefix: Icon(
                                                    Icons.close,
                                                    color:
                                                        AppColors.txStatusError,
                                                  ),
                                                );
                                              }
                                            },
                                      title: 'Continue',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
          },
        );
      },
    );
  }
}
