import 'package:flutter/material.dart';

class AnswerField extends StatefulWidget {
  final String answer;
  final bool enabled;
  final TextEditingController? controller;
  final void Function()? setAllCorrect;

  const AnswerField({
    super.key,
    required this.answer,
    required this.enabled,
    required this.setAllCorrect,
    this.controller,
  });

  @override
  State<AnswerField> createState() => _AnswerFieldState();
}

class _AnswerFieldState extends State<AnswerField> {
  String currentValue = "";
  bool answered = false;

  @override
  void dispose() {
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
        child: TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          style: TextStyle(
            color: answered
                ? (currentValue == widget.answer ||
                        (widget.controller != null
                            ? widget.controller!.text == widget.answer
                            : false))
                    ? Colors.green
                    : Colors.red
                : Theme.of(context).textTheme.displayLarge!.color,
            fontSize: 18,
          ),
          maxLength: answerLength,
          onChanged: (value) => setState(() {
            answered = false;
          }),
          onFieldSubmitted: (value) => setState(() {
            answered = true;
            currentValue = value;
            widget.setAllCorrect!();
          }),
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
          ),
        ),
      ),
    );
  }
}
