import 'dart:async';
import 'dart:ui';

import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/screens/address_book/delete_contact_dialog.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/address_book/contact_tile.dart';
import 'package:defi_wallet/widgets/address_book/create_edit_contact_dialog.dart';
import 'package:defi_wallet/widgets/address_book/last_sent_tile.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/create_edit_account/create_edit_account_dialog.dart';
import 'package:defi_wallet/widgets/fields/decoration_text_field_new.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../widgets/fields/custom_text_form_field.dart';

class AddressBookScreenNew extends StatefulWidget {
  const AddressBookScreenNew({Key? key}) : super(key: key);

  @override
  State<AddressBookScreenNew> createState() => _AddressBookScreenNewState();
}

class _AddressBookScreenNewState extends State<AddressBookScreenNew>
    with ThemeMixin {
  int iterator = 0;
  TextEditingController controller = TextEditingController();
  List<AddressBookModel>? viewList = [];
  bool isSelectedContacts = true;
  bool isSelectedLastSent = false;
  bool isDeleted = false;

  showDeletedTooltip() {
    setState(() {
      isDeleted = true;

    });
    Timer(Duration(milliseconds: 1500), () {
      setState(() {
        isDeleted = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        AddressBookCubit addressBookCubit =
            BlocProvider.of<AddressBookCubit>(context);
        if (iterator == 0) {
          iterator++;

          addressBookCubit.loadAddressBook();
        }
        return BlocBuilder<AddressBookCubit, AddressBookState>(
          builder: (context, addressBookState) {
            if (iterator == 1 &&
                addressBookState.status == AddressBookStatusList.success) {
              viewList = addressBookState.addressBookList;
              iterator++;
            }
            return Scaffold(
              drawerScrimColor: Color(0x0f180245),
              endDrawer: AccountDrawer(
                width: buttonSmallWidth,
              ),
              appBar: NewMainAppBar(
                isShowLogo: false,
              ),
              body: Container(
                margin: EdgeInsets.only(top: 5),
                padding: EdgeInsets.only(
                  top: 22,
                  bottom: 0,
                  left: 16,
                  right: 0,
                ),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkTheme()
                      ? DarkColors.scaffoldContainerBgColor
                      : LightColors.scaffoldContainerBgColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Address Book',
                                    style: headline3,
                                  ),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        print(addressBookState
                                            .addressBookList!.length);
                                        showDialog(
                                          barrierColor: Color(0x0f180245),
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CreateEditContactDialog(
                                              isEdit: false,
                                              confirmCallback: (name, address) {
                                                setState(() {
                                                  addressBookCubit.addAddress(
                                                      AddressBookModel(
                                                          name: name,
                                                          address: address,
                                                          network:
                                                              'DefiChain Mainnet'));
                                                  controller.text = '';
                                                  viewList = addressBookState
                                                      .addressBookList;
                                                  Navigator.pop(context);
                                                });
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.portage
                                              .withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(Icons.add),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              CustomTextFormField(
                                prefix: Icon(Icons.search),
                                addressController: controller,
                                hintText: 'Name or Contact Address',
                                isBorder: true,
                                onChanged: (value) {
                                  print(
                                      addressBookState.addressBookList!.length);
                                  setState(() {
                                    if (addressBookState.addressBookList !=
                                        null) {
                                      List<AddressBookModel>? list = [];
                                      addressBookState.addressBookList!
                                          .forEach((element) {
                                        if (element.name!.contains(value) ||
                                            element.address!.contains(value)) {
                                          list.add(element);
                                        }
                                      });
                                      viewList = list;
                                    }
                                  });
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 8,
                                      ),
                                      SelectorTabElement(
                                        callback: () {
                                          setState(() {
                                            isSelectedContacts = true;
                                            isSelectedLastSent = false;
                                          });
                                        },
                                        title: 'Contacts',
                                        isSelect: isSelectedContacts,
                                      ),
                                      SizedBox(
                                        width: 24,
                                      ),
                                      SelectorTabElement(
                                        callback: () {
                                          setState(() {
                                            isSelectedContacts = false;
                                            isSelectedLastSent = true;
                                          });
                                        },
                                        isSelect: isSelectedLastSent,
                                        title: 'Last sent',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/filter_icon.svg',
                                        color: AppColors.darkTextColor,
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 9,
                              ),
                            ],
                          ),
                        ),
                        if (isSelectedContacts)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: (viewList != null && viewList!.isNotEmpty)
                                  ? ListView.builder(
                                      itemCount: viewList!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 16),
                                          child: Column(
                                            children: [
                                              ContactTile(
                                                contactName:
                                                    viewList![index].name!,
                                                contactAddress:
                                                    viewList![index].address!,
                                                networkName:
                                                    viewList![index].network!,
                                                editCallback: () {
                                                  showDialog(
                                                    barrierColor:
                                                        Color(0x0f180245),
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return CreateEditContactDialog(
                                                        contactName:
                                                            viewList![index]
                                                                .name!,
                                                        address:
                                                            viewList![index]
                                                                .address!,
                                                        isEdit: true,
                                                        confirmCallback:
                                                            (name, address) {
                                                          setState(() {
                                                            addressBookCubit.editAddress(
                                                                AddressBookModel(
                                                                    name: name,
                                                                    address:
                                                                        address,
                                                                    network: viewList![
                                                                            index]
                                                                        .network),
                                                                viewList![index]
                                                                    .id);
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                        deleteCallback: () {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                            barrierColor: Color(
                                                                0x0f180245),
                                                            barrierDismissible:
                                                                true,
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return DeleteContactDialog(
                                                                confirmCallback:
                                                                    () {
                                                                  setState(() {
                                                                    addressBookCubit
                                                                        .deleteAddress(
                                                                            viewList![index]);
                                                                    Navigator.pop(
                                                                        context);
                                                                    showDeletedTooltip();
                                                                  });
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              if (!(viewList!.length ==
                                                  index + 1))
                                                Divider(
                                                  height: 1,
                                                  color: AppColors
                                                      .lavenderPurple
                                                      .withOpacity(0.16),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Text(
                                        'Oops!',
                                      ),
                                    ),
                            ),
                          ),
                        if (isSelectedLastSent)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: (true)
                                  ? ListView.builder(
                                      itemCount: 12,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 16),
                                          child: Column(
                                            children: [
                                              LastSentTile(
                                                address:
                                                    'df1q3lyukeychd55pt2u3xknnuxqzwuhdasgvwuuhc',
                                              ),
                                              Divider(
                                                height: 1,
                                                color: AppColors.lavenderPurple
                                                    .withOpacity(0.16),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Text(
                                        'Oops!',
                                      ),
                                    ),
                            ),
                          ),
                      ],
                    ),
                    if (isDeleted)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 223,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.4),
                                color: AppColors.malachite.withOpacity(0.08),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.4),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 5.0, sigmaY: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.done,
                                        color: Color(0xFF00CF21),
                                        size: 24,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Contact has been deleted',
                                        style: headline5.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}