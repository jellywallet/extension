import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFields extends StatelessWidget {
  final List<TextEditingController>? controllers;
  final List<FocusNode>? focusNodes;
  final GlobalKey? globalKey;
  final List<int> invalidControllerIndexes;
  final bool enabled;

  const TextFields(
      {Key? key,
      this.controllers,
      this.focusNodes,
      this.globalKey,
      this.invalidControllerIndexes = const [],
      this.enabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const int _defaultTextFieldCount = 8;
    const int _rowsCount = 3;

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 458,
            minWidth: 328,
            maxHeight: 346,
            minHeight: 248,
          ),
          child: Row(
            children: List.generate(
                _rowsCount,
                (index) => ColumnTextFields(
                      controllers: controllers,
                      focusNodes: focusNodes,
                      globalKey: globalKey,
                      columnsCount: _defaultTextFieldCount,
                      depth: index > 0 ? _defaultTextFieldCount * index : 0,
                      enabled: enabled,
                      invalidControllerIndexes: invalidControllerIndexes,
                    )),
          ),
        ),
      ),
    );
  }
}

class ColumnTextFields extends StatelessWidget {
  final List<TextEditingController>? controllers;
  final List<FocusNode>? focusNodes;
  final GlobalKey? globalKey;
  final int? columnsCount;
  final int depth;
  final List<int> invalidControllerIndexes;
  final bool enabled;

  const ColumnTextFields(
      {Key? key,
      this.controllers,
      this.focusNodes,
      this.globalKey,
      this.columnsCount,
      this.depth = 0,
      this.invalidControllerIndexes = const [],
      this.enabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 10,
      child: Column(
        children: List.generate(
          columnsCount!,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                children: [
                  Text(
                    (index + depth + 1 < 10)
                        ? '  ${index + depth + 1}.'
                        : '${index + depth + 1}.',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Spacer(),
                  Expanded(
                    flex: 10,
                    child: RawKeyboardListener(
                        focusNode: focusNodes![(index + depth).toInt()],
                        onKey: (RawKeyEvent event) {
                          if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
                            if (index + depth == controllers!.length - 1) {
                              (globalKey!.currentWidget! as ElevatedButton)
                                  .onPressed!();
                            } else {
                              focusNodes![(index + depth + 1).toInt()]
                                  .requestFocus();
                            }
                          }
                        },
                        child: TextField(
                          enabled: enabled,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: Theme.of(context).textTheme.headline4,
                          onEditingComplete: () => index + depth ==
                                  controllers!.length - 1
                              ? (globalKey!.currentWidget! as ElevatedButton)
                                  .onPressed!()
                              : null,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: invalidControllerIndexes
                                      .contains(index + depth)
                                  ? OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    )
                                  : null),
                          controller: controllers![index + depth],
                        )),
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
