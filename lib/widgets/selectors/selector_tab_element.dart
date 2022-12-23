import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SelectorTabElement extends StatelessWidget {
  final String title;
  final bool isSelect;
  final Function callback;
  final double? indicatorWidth;

  const SelectorTabElement({
    Key? key,
    required this.title,
    required this.callback,
    this.indicatorWidth,
    this.isSelect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => callback(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          child: Center(
            child: Column(
              children: [
                Text(
                  title,
                  style: isSelect
                      ? headline5.copyWith(fontSize: 12)
                      : headline5.copyWith(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .headline5!
                              .color!
                              .withOpacity(0.3),
                        ),
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  width: indicatorWidth ?? 20,
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: isSelect
                        ? gradientButton
                        : LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
