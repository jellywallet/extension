import 'package:defi_wallet/bloc/refactoring/lock/lock_cubit.dart';
import 'package:defi_wallet/models/network/staking/staking_model.dart';
import 'package:defi_wallet/widgets/fields/invested_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RewardRoutesList extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isDisabled;

  const RewardRoutesList({
    Key? key,
    required this.controllers,
    required this.focusNodes,
    required this.isDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<LockCubit, LockState>(
      builder: (context, lockState) {
        LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
        List<RewardRouteModel> rewards =
            lockState.stakingModel!.rewardRoutes;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(rewards.length, (index) {
            return InvestedField(
              label: rewards[index].label ?? '',
              tokenName: rewards[index].targetAsset!,
              controller: controllers[index],
              focusNode: focusNodes[index],
              isDeleteBtn: isDisabled,
              isDisable: !isDisabled,
              isReinvest: rewards[index].label == 'Reinvest',
              onRemove: () {
                if (rewards[index].label != 'Reinvest') {
                  lockCubit.removeRewardRoute(index);
                }
              },
              onChange: (value) {
                if (value.isNotEmpty) {
                  List<double> rewardPercentages =
                    controllers.map((e) => double.parse(e.text) / 100).toList();
                  lockCubit.updateRewardPercentages(
                    rewardPercentages,
                    index: index,
                  );
                }
              },
            );
          }),
        );
      },
    );
  }
}
