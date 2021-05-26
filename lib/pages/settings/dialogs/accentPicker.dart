// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/provider/preferencesProvider.dart';

// UI
import 'package:songtube/ui/animations/fadeIn.dart';
import 'package:songtube/ui/animations/showUp.dart';

class AccentPicker extends StatefulWidget {
  final ValueChanged<Color> onColorChanged;
  AccentPicker({
    @required this.onColorChanged
  });
  @override
  _AccentPickerState createState() => _AccentPickerState();
}

class _AccentPickerState extends State<AccentPicker> {
  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs = Provider.of<PreferencesProvider>(context);
    Color favoriteColor;
    if(prefs.favoriteColor == 0){
      favoriteColor = Colors.red;
    }else{
      favoriteColor = new Color(prefs.favoriteColor);
    }

    return FadeInTransition(
      duration: Duration(milliseconds: 250),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
        clipBehavior: Clip.hardEdge,
        child: Container(
          height: 400,
          width: 300,
          child: Column(
            children: <Widget>[
              Container(
                width: 300,
                padding: EdgeInsets.only(top: 24, bottom: 16),
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  color: Theme.of(context).accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.10),
                      offset: Offset(0, 3), //(x,y)
                      blurRadius: 6.0,
                      spreadRadius: 0.11 
                    )
                  ]
                ),
                child: ShowUpTransition(
                  forward: true,
                  delay: Duration(milliseconds: 100),
                  duration: Duration(milliseconds: 200),
                  child: Text(
                    Languages.of(context).labelChooseColor,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: FadeInTransition(
                  delay: Duration(milliseconds: 200),
                  duration: Duration(milliseconds: 200),
                  child: MaterialColorPicker(
                    
                    circleSize: 50,
                    spacing: 10,
                    colors: const <ColorSwatch>[
                      Colors.red,
                      Colors.redAccent,
                      Colors.pinkAccent,
                      Colors.pink,
                      Colors.purple,
                      Colors.purpleAccent,
                      Colors.deepPurpleAccent,
                      Colors.indigo,
                      Colors.indigoAccent,
                      Colors.blue,
                      Colors.blueAccent,
                      Colors.lightBlue,
                      Colors.lightBlueAccent,
                      Colors.cyan,
                      Colors.cyanAccent,
                      Colors.teal,
                      Colors.green,
                      Colors.tealAccent,
                      Colors.greenAccent,
                      Colors.lightGreen,
                      Colors.lightGreenAccent,
                      Colors.lime,
                      Colors.limeAccent,
                      Colors.yellow,
                      Colors.yellowAccent,
                      Colors.amber,
                      Colors.amberAccent,
                      Colors.orange,
                      Colors.orangeAccent,
                      Colors.deepOrangeAccent,
                    ],
                    onMainColorChange: (color) => {
                      widget.onColorChanged(color),
                      prefs.favoriteColor = color.value
                    },
                    selectedColor: favoriteColor
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}