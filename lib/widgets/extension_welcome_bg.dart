import 'package:defi_wallet/bloc/easter_egg/easter_egg_cubit.dart';
import 'package:defi_wallet/widgets/easter_eggs/egg_dialog.dart';
import 'package:defi_wallet/widgets/easter_eggs/single_easter_egg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ExtensionWelcomeBg extends StatefulWidget {
  const ExtensionWelcomeBg({Key? key}) : super(key: key);

  @override
  State<ExtensionWelcomeBg> createState() => _ExtensionWelcomeBgState();
}

class _ExtensionWelcomeBgState extends State<ExtensionWelcomeBg> {
  final String coordsLink = 'https://www.google.com/maps/place/7%C2%B009\''
      '39.8%22N+134%C2%B022\'36.0%22E/@7.1642247,134.3802637,13.92z/'
      'data=!4m5!3m4!1s0x0:0xded8284159939dd5!8m2!3d7.161057!4d134.376672';

  @override
  void initState() {
    EasterEggCubit easterEggCubit = BlocProvider.of<EasterEggCubit>(context);
    Future.delayed(Duration.zero, () async {
      await easterEggCubit.getStatuses();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        height: 600,
        child: Stack(
          children: [
            Image.asset('assets/images/welcome_background.png'),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 8),
              child: Text(
                'version',
                style: TextStyle(
                  fontFamily: 'GalanoGrotesque',
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 8),
              child: Text(
                '2.1.3',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 54),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/welcome_logo.svg'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 83,
                left: 202,
              ),
              child: GestureDetector(
                onTap: () {
                  launch(coordsLink);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Stack(
                    children: [
                      Text(
                        '7° 9\' 39.8052\'\' N',
                        style: TextStyle(
                          // fontFamily: 'GalanoGrotesque',
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          '134° 22\' 36.0192\'\' E',
                          style: TextStyle(
                            // fontFamily: 'GalanoGrotesque',
                            fontWeight: FontWeight.w700,
                            fontSize: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 87,
              top: 285,
              child: SingleEasterEgg(
                index: 1,
                width: 20,
                height: 27,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
