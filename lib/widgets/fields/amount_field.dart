import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/selectors/asset/asset_selector.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class AmountField extends StatefulWidget {
  final void Function(TokensModel asset) onAssetSelect;
  final TextEditingController controller;
  final TokensModel selectedAsset;
  final List<TokensModel> assets;
  final String? available;
  final String? suffix;

  AmountField({
    required this.onAssetSelect,
    required this.controller,
    required this.selectedAsset,
    required this.assets,
    this.available = '35.02',
    this.suffix = '\$365.50',
    Key? key,
  }) : super(key: key);

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  final FocusNode _focusNode = FocusNode();
  bool _onFocused = false;

  _onFocusChange() {
    setState(() {
      _onFocused = _focusNode.hasFocus;
    });
  }

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Container(
        height: 80,
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: _onFocused ? GradientBoxBorder(
            gradient: gradientWrongMnemonicWord,
          ) : Border.all(
            color: LightColors.amountFieldBorderColor.withOpacity(0.32),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontSize: 20,
                          ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(0.0),
                      ),
                    ),
                  ),
                ),
                AssetSelector(
                  assets: widget.assets,
                  onSelect: (token) {
                    widget.onAssetSelect(token);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$365.50',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .textTheme
                            .headline6!
                            .color!
                            .withOpacity(0.3),
                      ),
                ),
                Text(
                  'Available: ${widget.available}',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .textTheme
                            .headline6!
                            .color!
                            .withOpacity(0.3),
                      ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
