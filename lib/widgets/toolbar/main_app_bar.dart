import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/buttons/cancel_button.dart';
import 'package:defi_wallet/widgets/ongoing_transaction.dart';
import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double toolbarHeight = 50;
  static const double leadingWidth = 100;
  static const double iconHeight = 20;

  final String? title;
  final Widget? action;
  final double height;
  final bool isShowBottom;
  final bool? isSmall;

  const MainAppBar(
      {Key? key,
      this.title,
      this.action,
      this.height = toolbarHeight,
      this.isShowBottom = false,
      this.isSmall = false})
      : super(key: key);

  @override
  Size get preferredSize {
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      bottom: isShowBottom ? OngoingTransaction() : null,
      shape: !isSmall!
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
      leadingWidth: leadingWidth,
      toolbarHeight: toolbarHeight,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back,
                  size: iconHeight,
                  color: Theme.of(context).appBarTheme.actionsIconTheme!.color),
              splashRadius: 18,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      centerTitle: true,
      title: Text(
        title!,
        style: Theme.of(context).textTheme.headline6,
      ),
      actions: [
        action == null
            ? CancelButton(
                callback: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                    ))
            : action!
      ],
    );
  }
}
