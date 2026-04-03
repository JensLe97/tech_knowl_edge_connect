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

    bool isCorrectInput = (currentValue.toLowerCase() ==
            widget.answer.toLowerCase() ||
        widget.controller.text.toLowerCase() == widget.answer.toLowerCase());

    bool isFieldEnabled = widget.enabled && !(answered && isCorrectInput);

    Color textColor = Theme.of(context).colorScheme.primary;
    Color borderColor = Theme.of(context).colorScheme.primary;

    if (!widget.enabled) {
      textColor = Colors.green;
      borderColor = Colors.green;
    } else if (answered) {
      if (isCorrectInput) {
        textColor = Colors.green;
        borderColor = Colors.green;
      } else {
        textColor = Theme.of(context).colorScheme.error;
        borderColor = Theme.of(context).colorScheme.error;
      }
    }

    double calculatedWidth = (TextPainter(
                    text: TextSpan(
                        text: widget.answer,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                    textScaler: MediaQuery.of(context).textScaler,
                    textDirection: TextDirection.ltr)
                  ..layout())
                .size
                .width *
            1.02 +
        28; // Extra padding for web font rendering and cursor

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        width: calculatedWidth < 45 ? 45 : calculatedWidth,
        child: Form(
          key: _formKey,
          child: TextFormField(
            textInputAction: widget.textInputAction,
            controller: widget.controller,
            enabled: isFieldEnabled,
            maxLines: 1,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              height: 1.2,
            ),
            maxLength: answerLength > 0 ? answerLength : 50,
            buildCounter: (context,
                    {required currentLength, required isFocused, maxLength}) =>
                null,
            onChanged: (value) {
              if (answered) {
                setState(() {
                  answered = false;
                });
              }
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
                if (widget.setAllCorrect != null) {
                  widget.setAllCorrect!();
                }
              });
              setState(() {
                _formKey.currentState!.validate();
              });
            },
            cursorHeight: 18,
            cursorColor: Theme.of(context).colorScheme.primary,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.only(left: 4, right: 4, top: 6, bottom: 6),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary, width: 2),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: borderColor.withAlpha(100),
                  width: 2,
                ),
              ),
              errorStyle: const TextStyle(height: 0.01, fontSize: 1),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error, width: 2),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
