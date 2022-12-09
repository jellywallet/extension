import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DefiTextFormField extends StatefulWidget {
  double? width;
  TextEditingController? controller;
  Function(String)? onFieldSubmitted;
  bool autofocus;
  bool readOnly;
  FocusNode? focusNode;

  DefiTextFormField({
    Key? key,
    this.controller,
    this.width,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.onFieldSubmitted,
  }) : super(key: key);

  @override
  State<DefiTextFormField> createState() => _DefiTextFormFieldState();
}

class _DefiTextFormFieldState extends State<DefiTextFormField> {
  GlobalKey _formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Form(
        key: _formKey,
        child: TextFormField(
          readOnly: widget.readOnly,
          controller: widget.controller,
          onFieldSubmitted: widget.onFieldSubmitted,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            suffixIconConstraints: BoxConstraints(minWidth: 34, maxHeight: 44),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            hintText: 'Enter your seed phrase',
            hintStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xff12052F).withOpacity(0.3),
            ),
            suffixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    child: Container(
                      child: SvgPicture.asset(
                        'assets/icons/arrow_phrase.svg',
                        width: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          validator: (s) {
          },
        ),
      ),
    );
  }
}
