import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/create_edit_account/create_edit_account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class SelectedAccount extends StatefulWidget {
  final String accountName;
  final Function()? onEdit;

  const SelectedAccount({
    Key? key,
    required this.accountName,
    this.onEdit,
  }) : super(key: key);

  @override
  State<SelectedAccount> createState() => _SelectedAccountState();
}

class _SelectedAccountState extends State<SelectedAccount> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 16,
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                AppColors.redViolet.withOpacity(0.16),
                AppColors.razzmatazz.withOpacity(0.16),
              ],
            ),
          ),
          child: Center(
            child: GradientText(
              '${widget.accountName[0]}',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.w700),
              gradientType: GradientType.linear,
              gradientDirection: GradientDirection.btt,
              colors: [
                AppColors.electricViolet,
                AppColors.hollywoodCerise,
              ],
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.accountName}',
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(width: 8,),
              Container(
                width: 14,
                height: 14,
                child: IconButton(
                  iconSize: 14,
                  padding: EdgeInsets.all(0),
                  icon: SvgPicture.asset(
                    'assets/icons/edit_gradient.svg',
                  ),
                  onPressed: widget.onEdit,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 14,
        ),
      ],
    );
  }
}
