import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/languages.dart';
import 'package:songtube/provider/preferencesProvider.dart';
import 'package:songtube/ui/components/styledBottomSheet.dart';
import 'package:url_launcher/url_launcher.dart';

class JoinTelegramSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PreferencesProvider prefs =
        Provider.of<PreferencesProvider>(context, listen: false);
    return StyledBottomSheet(
      actionsPadding: EdgeInsets.only(right: 24, left: 24, bottom: 12),
      addBottomPadding: true,
      leading: Icon(
        Icons.star,
        size: 22,
        color: Colors.yellowAccent,
      ),
      title: "Rate us",
      content: Text(
        Languages.of(context).labelJoinTelegramJustification,
        style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1.color, fontSize: 16),
      ),
      actions: [
        TextButton(
          child: Text("Yes",
              style: TextStyle(fontWeight: FontWeight.w600,color: Theme.of(context).accentColor)),
          onPressed: () {
            prefs.showJoinTelegramDialog = false;
            launch("https://play.google.com/store/apps/details?id=com.neoblast.android.iplay");
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("Later",
              style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).accentColor)),
          onPressed: () {
            prefs.showJoinTelegramDialog = false;
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
