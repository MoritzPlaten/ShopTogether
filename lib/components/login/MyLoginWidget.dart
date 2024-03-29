import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/functions/providers/login/MyLoginProvider.dart';

/**
 * Its the login layout, in which the Textfields are generated.
 * */
class MyLoginWidget extends StatefulWidget {

  final String title;
  final List<Function()> buttonFunctions;
  final List<TextEditingController> controllers;
  final List<String> inputLabels;
  final List<String> buttonLabels;
  final List<Color> buttonForegroundColors;
  final List<Color> buttonBackgroundColors;
  final List<bool> isInputPassword;
  final List<TextInputType> textTypes;
  final List<int> maxLengthForTextfields;

  const MyLoginWidget({super.key, required this.buttonFunctions, required this.controllers, required this.inputLabels, required this.buttonLabels, required this.buttonForegroundColors, required this.buttonBackgroundColors, required this.isInputPassword, required this.title, required this.textTypes, required this.maxLengthForTextfields});

  @override
  State<MyLoginWidget> createState() => _MyLoginWidgetState();
}

class _MyLoginWidgetState extends State<MyLoginWidget> {

  @override
  Widget build(BuildContext context) {

    return Consumer<MyLoginProvider>(
        builder: (BuildContext context,
            MyLoginProvider value,
            Widget? child) {

            return Card(
              color: Theme.of(context).cardTheme.color,
              elevation: Theme.of(context).cardTheme.elevation,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0)
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge
                    ),

                    for (int i = 0; i < widget.controllers.length;i++)
                      TextFormField(
                        maxLength: widget.maxLengthForTextfields[i] != -1 ? widget.maxLengthForTextfields[i] : null,
                        controller: widget.controllers[i],
                        style: Theme.of(context).textTheme.bodyMedium,
                        keyboardType: widget.textTypes[i],
                        decoration: InputDecoration(
                          counterStyle: Theme.of(context).textTheme.labelSmall,
                          labelStyle: Theme.of(context).textTheme.bodyMedium,
                          labelText: widget.inputLabels[i],
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                          suffixIcon: IconButton(
                            onPressed: () {

                              if (widget.isInputPassword[i]) {

                                 value.showPasswords![i] = !value.showPasswords![i];
                                 Provider.of<MyLoginProvider>(context, listen: false).updateShowPasswords(value.showPasswords!);
                              } else {

                                widget.controllers[i].clear();
                              }

                            },
                            icon: Icon(
                              widget.isInputPassword[i] ? (value.showPasswords![i] ? Icons.remove_red_eye : Icons.visibility_off) : Icons.clear,
                              size: Theme.of(context).iconTheme.size,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ),
                        obscureText: value.showPasswords![i],
                      ),
                    const SizedBox(height: 30),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        for (int i = 0;i < widget.buttonLabels.length;i++)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              ElevatedButton(
                                  onPressed: widget.buttonFunctions[i],
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(widget.buttonBackgroundColors[i]),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                                    child: Text(
                                      widget.buttonLabels[i],
                                      style: GoogleFonts.tiltNeon(
                                          fontSize: 19,
                                          color: widget.buttonForegroundColors[i]
                                      ),
                                    ),
                                  )
                              ),
                              const SizedBox(height: 2,),

                            ],
                          )
                      ],
                    )
                  ],
                ),
              ),
            );
        });
  }
}