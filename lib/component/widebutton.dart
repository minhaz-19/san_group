import 'package:flutter/material.dart';

class WideButton extends StatefulWidget {
  const WideButton(
    this.text, {
    Key? key,
    this.padding = 0.0,
    this.textColor = Colors.black,
    this.height = 45,
    this.borderColor ,
    required this.onPressed,
    required this.backgroundcolor,
  }) : super(key: key);

  final String text;
  final double padding;
  final double height;
  final Color backgroundcolor;
  final Color textColor;
  final dynamic borderColor;
  final Function() onPressed;

  @override
  State<WideButton> createState() => _WideButtonState();
}

class _WideButtonState extends State<WideButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: MediaQuery.of(context).size.width <= 500
          ? MediaQuery.of(context).size.width
          : 350,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.padding),
        child: ElevatedButton(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0.0),
            backgroundColor: MaterialStateProperty.all(widget.backgroundcolor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                 side:(widget.borderColor != null)? BorderSide(color: Theme.of(context).primaryColor): BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          onPressed: widget.onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.text,
                  style: TextStyle(color: widget.textColor, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
