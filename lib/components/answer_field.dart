import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Timer(const Duration(milliseconds: 1000), () {
          focusNode.requestFocus();
        });
      });
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        width: (TextPainter(
                text: TextSpan(
                    text: widget.answer,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    )),
                textScaler: MediaQuery.of(context).textScaler,
                textDirection: TextDirection.ltr)
              ..layout())
            .size
            .width,
        child: Form(
          key: _formKey,
          child: TextFormField(
            textInputAction: widget.textInputAction,
            controller: widget.controller,
            enabled: widget.enabled,
            style: TextStyle(
              color: answered
                  ? (currentValue == widget.answer ||
                          widget.controller.text == widget.answer)
                      ? Colors.green
                      : Colors.red
                  : Theme.of(context).textTheme.displayLarge!.color,
              fontSize: 18,
            ),
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
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              counterText: '',
              errorStyle: const TextStyle(height: 0.01),
            ),
          ),
        ),
      ),
    );
  }
}
