import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class CircleSelectorTile extends StatefulWidget {
  final bool isSelected;
  final Function() callback;
  final String text;
  final double width;
  final double height;

  const CircleSelectorTile({
    Key? key,
    required this.isSelected,
    required this.callback,
    required this.text,
    this.width = double.infinity,
    this.height = 61,
  }) : super(key: key);

  @override
  State<CircleSelectorTile> createState() => _CircleSelectorTileState();
}

class _CircleSelectorTileState extends State<CircleSelectorTile>
    with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.callback();
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.isSelected
                ? Theme.of(context).selectedRowColor.withOpacity(0.07)
                : Colors.transparent,
            border: widget.isSelected
                ? GradientBoxBorder(
                    gradient: gradientBottomToUpCenter,
                  )
                : Border.all(
                    color: Theme.of(context).selectedRowColor.withOpacity(0.24),
                  ),
          ),
          child: Center(
            child: Container(
              child: Row(
                children: [
                  SizedBox(
                    width: 13,
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? null
                          : Theme.of(context).dividerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      gradient:
                          widget.isSelected ? gradientBottomToUpCenter : null,
                    ),
                    child: Center(
                      child: Container(
                        width: widget.isSelected ? 8 : 12,
                        height: widget.isSelected ? 8 : 12,
                        decoration: BoxDecoration(
                          color: widget.isSelected
                              ? Theme.of(context).scaffoldBackgroundColor
                              : isDarkTheme()
                                  ? DarkColors.scaffoldBgColor
                                  : LightColors.scaffoldBgColor,
                          borderRadius:
                              BorderRadius.circular(widget.isSelected ? 4 : 6),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 13,
                  ),
                  Text(
                    widget.text,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
