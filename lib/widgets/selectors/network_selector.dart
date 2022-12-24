import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/helpers/menu_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum NetworkTabs { all, test }

class NetworkSelector extends StatefulWidget {
  final void Function() onSelect;

  NetworkSelector({Key? key, required this.onSelect}) : super(key: key);

  @override
  _NetworkSelectorState createState() => _NetworkSelectorState();
}

class _NetworkSelectorState extends State<NetworkSelector> with ThemeMixin {
  CustomPopupMenuController controller = CustomPopupMenuController();
  MenuHelper menuHelper = MenuHelper();

  bool isShowAllNetworks = true;
  NetworkTabs activeTab = NetworkTabs.all;
  String currentNetworkItem = 'DefiChain Mainnet';

  final List<dynamic> menuItems = [
    {'name': 'DefiChain Mainnet'},
    {'name': 'DefiChain Testnet'},
    {'name': 'Bitcoin Mainnet'},
    {'name': 'Bitcoin Testnet'},
    {'name': 'Defi-Meta-Chain Testnet'},
  ];

  Color getMarkColor(String item) {
    if (currentNetworkItem == item) {
      return AppColors.networkMarkColor;
    } else {
      return isDarkTheme()
          ? DarkColors.networkMarkColor
          : LightColors.networkMarkColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    double horizontalMargin = menuHelper.getHorizontalMargin(context);

    return CustomPopupMenu(
      menuOnChange: (b) => widget.onSelect(),
      child: Container(
        height: 24,
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xFF00CF21),
              ),
            ),
            SizedBox(
              width: 6,
            ),
            Text(
              'DefiChain Mainnet',
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              width: 6,
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFFB7B2C1),
              size: 14,
            )
          ],
        ),
      ),
      menuBuilder: () => Container(
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              spreadRadius: 4,
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: CustomPaint(
          isComplex: true,
          willChange: true,
          painter: ArrowPainter(),
          child: ClipPath(
            clipper: ArrowClipper(),
            child: Container(
              color: isDarkTheme()
                ? DarkColors.networkDropdownBgColor
                : LightColors.networkDropdownBgColor,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: 260,
              child: Container(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 8,
                ),
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/network_icon.svg',
                                width: 18,
                                height: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Network',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .apply(
                                  fontSizeDelta: 2,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          Text(
                            'Jelly speaks more than one language. Select the network you want to use:',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .color!
                                  .withOpacity(0.8),
                            ),
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          Row(
                            children: [
                              SelectorTabElement(
                                title: 'Show/Hide',
                                callback: () {
                                  setState(() {
                                    activeTab = NetworkTabs.all;
                                  });
                                },
                                isSelect: activeTab == NetworkTabs.all,
                                indicatorWidth: 65,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              SelectorTabElement(
                                title: 'Test Networks',
                                callback: () {
                                  setState(() {
                                    activeTab = NetworkTabs.test;
                                  });
                                },
                                isSelect: activeTab == NetworkTabs.test,
                                indicatorWidth: 60,
                              ),
                            ],
                          ),
                          Divider(
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.1),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: menuItems
                            .map(
                              (item) => Column(
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    controller.hideMenu();
                                    setState(() {
                                      currentNetworkItem = item['name'];
                                    });
                                  },
                                  child: Container(
                                    height: 44,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(
                                                8),
                                            color: getMarkColor(item['name']),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          item['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            .toList(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      showArrow: false,
      barrierColor: Colors.transparent,
      pressType: PressType.singleClick,
      verticalMargin: -5,
      horizontalMargin: horizontalMargin,
      controller: controller,
    );
  }
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double startMargin = 0;

    final double s1 = height * 0.3;
    final double s2 = height * 0.7;

    Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startMargin, 0, width - startMargin, height),
          const Radius.circular(16),
        ),
      )
      ..lineTo(startMargin, s1)
      ..lineTo(startMargin, s2)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class ArrowPainter extends CustomPainter {
  final CustomClipper<Path> clipper = ArrowClipper();

  @override
  void paint(Canvas canvas, Size size) {
    var path = clipper.getClip(size);
    Paint paint = new Paint()
      ..color = AppColors.white.withOpacity(0.04)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}