import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/transaction/tx_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/mixins/network_mixin.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/screens/send/send_summary_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/dialogs/create_edit_contact_dialog.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:defi_wallet/widgets/fields/address_field_new.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/refactoring/fields/amount_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/fees_selector.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({Key? key}) : super(key: key);

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen>
    with ThemeMixin, NetworkMixin, SnackBarMixin {
  TextEditingController addressController = TextEditingController();
  TextEditingController amountController = TextEditingController(text: '0');
  FocusNode addressFocusNode = FocusNode();
  AddressBookModel contact = AddressBookModel();
  String suffixText = '';
  String? balanceInUsd;
  String titleText = 'Send';
  String subtitleText = 'Please enter the recipient and amount';
  bool isAddNewContact = false;
  bool isShowCheckbox = false;

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
        TransactionState transactionState,
      ) {
        return BlocBuilder<TxCubit, TxState>(
          builder: (context, txState) {
            final walletCubit = BlocProvider.of<WalletCubit>(context);
            AbstractNetworkModel activeNetwork =
                walletCubit.getCurrentNetwork();

            TxCubit txCubit = BlocProvider.of<TxCubit>(context);
            if (txState.status == TxStatusList.initial) {
              txCubit.init(context, TxType.send);
            }

            if (txState.status == TxStatusList.success) {
              return Scaffold(
                drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                endDrawer: isFullScreen
                    ? null
                    : AccountDrawer(
                        width: buttonSmallWidth,
                      ),
                appBar: isFullScreen
                    ? null
                    : NewMainAppBar(
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
                      bottomLeft: Radius.circular(isFullScreen ? 20 : 0),
                      bottomRight: Radius.circular(isFullScreen ? 20 : 0),
                    ),
                  ),
                  child: Center(
                    child: StretchBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              PageTitle(
                                title: titleText,
                                isFullScreen: isFullScreen,
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
                              AddressFieldNew(
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
                              SizedBox(
                                height: 16,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Asset',
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              AmountField(
                                type: TxType.send,
                                balance: txState.activeBalance,
                                onChanged: (value) {
                                  setState(() {
                                    //TODO: fix USD balance
                                    // balanceInUsd = getUsdBalance(context);
                                  });
                                },
                                available: txState.availableBalance,
                                // available: true,
                                isDisabledSelector:
                                    !activeNetwork.isTokensPresent(),
                                suffix: balanceInUsd ?? '0.00',
                                // ?? getUsdBalance(context), //TODO: fix it
                                onAssetSelect: (asset) async {
                                  txCubit.changeActiveBalance(
                                      context, asset, TxType.send);
                                },
                                controller: amountController,
                                assets: txState.balances!,
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              if (!activeNetwork.isTokensPresent()) ...[
                                Row(
                                  children: [
                                    Text(
                                      'Fees',
                                      style:
                                          Theme.of(context).textTheme.headline5,
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
                                  activeFee: txState.activeFee,
                                  fees: [
                                    txState.networkFee!.low!,
                                    txState.networkFee!.medium!,
                                    txState.networkFee!.high!,
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
                                callback: isDisable(txState)
                                    ? null
                                    : () => _submit(
                                          context,
                                          transactionState,
                                          txState,
                                          activeNetwork,
                                        ),
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
              return Loader();
            }
          },
        );
      },
      isUpdate: true,
    );
  }

  bool isDisable(TxState txState) {
    double amount = double.tryParse(amountController.text) ?? 0;
    return amount == 0 || txState.availableBalance! < amount;
  }

  _submit(
    BuildContext context,
    TransactionState transactionState,
    TxState txState,
    AbstractNetworkModel activeNetwork,
  ) {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    if (BalancesHelper().isAmountEmpty(amountController.text)) {
      showSnackBar(
        context,
        title: 'Amount is empty',
        color: AppColors.txStatusError.withOpacity(0.1),
        prefix: Icon(
          Icons.close,
          color: AppColors.txStatusError,
        ),
      );
    } else {
      if (transactionState is! TransactionLoadingState ||
          walletCubit.state.isSendReceiveOnly) {
        _send(txState, activeNetwork);
      } else {
        showSnackBar(
          context,
          title: 'Please wait for the previous transaction',
          color: AppColors.txStatusError.withOpacity(0.1),
          prefix: Icon(
            Icons.close,
            color: AppColors.txStatusError,
          ),
        );
      }
    }
  }

  _send(
    TxState state,
    AbstractNetworkModel activeNetwork,
  ) async {
    AddressBookCubit addressBookCubit =
        BlocProvider.of<AddressBookCubit>(context);
    if (addressController.text != '') {
      late bool isValidAddress =
          activeNetwork.checkAddress(addressController.text);

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
                    context,
                    AddressBookModel(
                      name: name,
                      address: address,
                      network: network,
                    ),
                  );
                  NavigatorService.push(
                      context,
                      SendSummaryScreen(
                        address: addressController.text,
                        isAfterAddContact: true,
                        amount: double.parse(amountController.text),
                        token: state.currentAsset!,
                        fee: state.activeFee,
                        // fee: state.activeFee,
                      ));
                  Navigator.pop(dialogContext);
                },
              );
            },
          );
        } else {
          NavigatorService.push(
              context,
              SendSummaryScreen(
                address: addressController.text,
                amount: double.parse(amountController.text),
                token: state.currentAsset!,
                fee: state.activeFee,
                // fee: state.activeFee,
              ));
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
      NavigatorService.push(
          context,
          SendSummaryScreen(
            amount: double.parse(amountController.text),
            token: state.currentAsset!,
            contact: contact,
            fee: state.activeFee,
            // fee: state.activeFee,
          ));
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
}
