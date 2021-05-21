import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialLinksRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 12, right: 12, top: 16),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                  onTap: () => launch("https://play.google.com/store/apps/details?id=com.neoblast.android.iplay"),
                  child: Image.asset('assets/images/playstore.png')),
              GestureDetector(
                  onTap: () => launch("https://instagram.com/neoblastofficial"),
                  child: Image.asset('assets/images/instagram.png')),
              GestureDetector(
                  onTap: () => launch("https://neoblast-official.com/iplay"),
                  child: Image.asset('assets/images/weblogo.png')),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 12, right: 12, top: 1),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => launch("https://play.google.com/store/apps/details?id=com.neoblast.android.iplay"),
                  child: Text(
                    "Google Play",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'YTSans',
                        color: Theme.of(context).textTheme.bodyText1.color
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => launch("https://instagram.com/neoblastofficial"),
                  child: Text(
                    "Instagram",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'YTSans',
                        color: Theme.of(context).textTheme.bodyText1.color
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => launch("https://google.com"),
                  child: Text(
                    "Web",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'YTSans',
                        color: Theme.of(context).textTheme.bodyText1.color
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
