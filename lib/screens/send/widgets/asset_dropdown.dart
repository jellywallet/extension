import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/widgets/fields/decoration_text_field.dart';
import 'package:flutter/material.dart';

class AssetDropdown extends StatelessWidget {
  final GlobalKey<AssetSelectState>? selectKeyFrom;
  final TextEditingController? amountController;
  final FocusNode? focusNode;
  final FocusModel? focusModel;
  final List<String>? assets;
  final String? assetFrom;
  final Function(String)? onSelect;
  final Function(String)? onChanged;
  final Function()? onPressedMax;
  final Function()? onPressedHalf;
  final Function()? onAnotherSelect;
  final bool? isMaxOnly;
  final bool? isFixedWidthAssetSelectorText;
  final String? amountInUsd;
  final void Function()? hideOverlay;

  const AssetDropdown({
    Key? key,
    this.selectKeyFrom,
    this.amountController,
    this.focusNode,
    this.focusModel,
    this.assets,
    this.assetFrom,
    this.onSelect,
    this.onChanged,
    this.onPressedMax,
    this.onPressedHalf,
    this.onAnotherSelect,
    this.isFixedWidthAssetSelectorText = false,
    this.isMaxOnly = false,
    this.amountInUsd = '0.0',
    this.hideOverlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AssetSelect(
            onAnotherSelect: onAnotherSelect,
            key: selectKeyFrom,
            tokensForSwap: assets!,
            selectedToken: assetFrom!,
            onSelect: onSelect!,
            isFixedWidthText: isFixedWidthAssetSelectorText!,
          ),
        ),
        Expanded(
          flex: SettingsHelper.isBitcoin() ? 2 : 1,
          child: DecorationTextField(
            hideOverlay: hideOverlay,
            controller: amountController,
            focusNode: focusNode,
            focusModel: focusModel,
            onChanged: onChanged,
            suffixIcon: SettingsHelper.isBitcoin() ? Container(
              height: 40,
              padding: EdgeInsets.only(top: 10, bottom: 8, right: 12, left: 0),
              child: Text('BTC ≈ \$$amountInUsd'),
            ) : Container(
              padding: isMaxOnly!
                  ? EdgeInsets.only(top: 8, bottom: 8, right: 12, left: 0)
                  : EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
              child: isMaxOnly!
                  ? Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // added line
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 30,
                          child: TextButton(
                            child: Text(
                              '50%',
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            onPressed: () {
                              if (onAnotherSelect != null) {
                                onAnotherSelect!();
                              }
                              onPressedHalf!();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          // height: 30,
                          child: TextButton(
                            child: Text(
                              'MAX',
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            onPressed: () {
                              if (onAnotherSelect != null) {
                                onAnotherSelect!();
                              }
                              onPressedMax!();
                            },
                          ),
                        ),

                        //
                      ],
                    )
                  : TextButton(
                      child: Text('MAX'),
                      onPressed: onPressedMax,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
