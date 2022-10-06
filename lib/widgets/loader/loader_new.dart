import 'dart:async';

import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

class LoaderNew extends StatefulWidget {
  final String secondStepLoaderText;
  bool isFullSize;
  String currentStatus;
  Function()? callback;

  LoaderNew({
    Key? key,
    required this.secondStepLoaderText,
    this.callback,
    this.isFullSize = false,
    this.currentStatus = 'first-step',
  }) : super(key: key);

  @override
  State<LoaderNew> createState() => _LoaderNewState();
}

class _LoaderNewState extends State<LoaderNew> {
  String firstStepText = 'One second, Jelly is preparing your transaction!';
  String secondStepText = '';
  String thirdStepText = 'Argh... Blockchains are not the fastest!';
  String currentText = '';
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    secondStepText = widget.secondStepLoaderText;
    if (widget.currentStatus == 'first-step') {
      currentText = firstStepText;
    }
    if (widget.currentStatus == 'first-step'){
      timer = Timer.periodic(Duration(seconds: 3), (_timer) {
        print('timer step');
        getStatusText(widget.currentStatus, _timer);
        if (widget.currentStatus == 'third-step') {
          _timer.cancel();
          timer = null;
        }
      });
    }
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  SettingsHelper.settings.theme == 'Light'
                      ? widget.isFullSize
                          ? 'assets/images/ledger_loading_light_white.gif'
                          : 'assets/images/ledger_loading_light_gray.gif'
                      : widget.isFullSize
                          ? 'assets/images/ledger_loading_dark.gif'
                          : 'assets/images/ledger_loading_dark.gif',
                  width: 180,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  currentText,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getStatusText(currentStatus, timer) async {
    print(widget.currentStatus);
    if (currentStatus == 'first-step') {
      setState(() {
        widget.currentStatus = 'second-step';
        currentText = secondStepText;
      });
    }
    if (currentStatus == 'second-step') {
      setState(() {
        widget.currentStatus = 'third-step';
        currentText = thirdStepText;
        timer.cancel();
        widget.callback!();
      });
    }
  }
}
