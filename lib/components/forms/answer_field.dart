import 'package:flutter/material.dart';

class AnswerField extends StatefulWidget {
  final String answer;
  final bool enabled;
  final TextEditingController controller;
  final void Function()? setAllCorrect;
  final TextInputAction textInputAction;
  final bool autofocus;

  const AnswerField(
      {super.key,
      required this.answer,
      required this.enabled,
      required this.setAllCorrect,
      required this.controller,
      this.textInputAction = TextInputAction.done,
      this.autofocus = false});

  @override
  State<AnswerField> createState() => _AnswerFieldState();
}

class _AnswerFieldState extends State<AnswerField> {
  String currentValue = "";
  bool answered = false;
  final _formKey = GlobalKey<FormState>();
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();
    if (widget.autofocus) {
      focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int answerLength = widget.answer.length;
    final baseStyle = Theme.of(context).textTheme.bodyLarge!;
    TextStyle textStyle = baseStyle.copyWith(
      color: !widget.enabled
          ? Colors.green
          : answered
              ? (currentValue.toLowerCase() == widget.answer.toLowerCase() ||
                      widget.controller.text.toLowerCase() ==
                          widget.answer.toLowerCase())
                  ? Colors.green
                  : Colors.red
              : Theme.of(context).textTheme.displayLarge!.color,
    );

    double calculatedWidth = (TextPainter(
                text: TextSpan(text: widget.answer, style: textStyle),
                textScaler: MediaQuery.of(context).textScaler,
                textDirection: TextDirection.ltr)
              ..layout())
            .size
            .width +
        10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        width: calculatedWidth < 30 ? 30 : calculatedWidth,
        child: Form(
          key: _formKey,
          child: TextFormField(
            textInputAction: widget.textInputAction,
            controller: widget.controller,
            enabled:
                widget.enabled && !(answered && currentValue == widget.answer),
            style: textStyle,
            maxLength: answerLength,
            onChanged: (value) {
              setState(() {
                answered = false;
              });
              setState(() {
                _formKey.currentState!.validate();
              });
            },
            validator: (value) {
              if (answered &&
                  widget.enabled &&
                  value != null &&
                  value.toLowerCase() != widget.answer.toLowerCase()) {
                return "";
              }
              return null;
            },
            focusNode: focusNode,
            onFieldSubmitted: (value) {
              setState(() {
                answered = true;
                if (value.toLowerCase() == widget.answer.toLowerCase()) {
                  currentValue = widget.answer;
                  widget.controller.text = widget.answer;
                } else {
                  currentValue = value;
                  focusNode.requestFocus();
                }
                widget.setAllCorrect!();
              });
              setState(() {
                _formKey.currentState!.validate();
              });
            },
            cursorColor: Theme.of(context).textTheme.displayLarge!.color,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.displayLarge!.color!),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              counterText: '',
              errorStyle: const TextStyle(height: 0.01, fontSize: 1),
              errorBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.error),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
