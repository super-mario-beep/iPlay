import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:songtube/lib.dart';
import 'package:songtube/provider/configurationProvider.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ConfigurationProvider config = Provider.of<ConfigurationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "About us",
          style: TextStyle(
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Theme.of(context).textTheme.bodyText1.color),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: ListView(
          children: [
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(100)),
                  padding: EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100)),
                    padding: EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: MediaQuery.of(context).size.width * 0.15,
                    ),
                  ),
                ),
                SizedBox(width: 32),
                /*Text(
                  "iPlay",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Product Sans'),
                ),*/
                RichText(
                  text: TextSpan(
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyText1.color, fontWeight: FontWeight.w600,
                      fontFamily: 'Product Sans',),
                      children: [
                        TextSpan(
                            text: "iPlay"),
                        TextSpan(
                            text: "\nv. " + Lib.VERSION,
                            style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14))
                      ]),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 16),
            RichText(
              text: TextSpan(
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyText1.color),
                  children: [
                    TextSpan(
                        text: "It's an app for media downloading "
                            "or streaming purposes. Meant to be a beautiful, "
                            "fast and functional alternative to other Youtube "
                            "Clients. \n\nCreated by "),
                    TextSpan(
                        text: "Neoblast",
                        style: TextStyle(fontWeight: FontWeight.w700))
                  ]),
            ),
            SizedBox(height: 60),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Text(
                  "Flutter",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Product Sans'),
                ),
                SizedBox(width: 32),
                Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 0, 10, 28),
                      borderRadius: BorderRadius.circular(100)),
                  padding: EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 0, 10, 28),
                        borderRadius: BorderRadius.circular(100)),
                    padding: EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/flutter_icon.png',
                      width: MediaQuery.of(context).size.width * 0.15,
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Flutter is Google’s UI toolkit for building beautiful, "
                  "natively compiled applications for mobile, web, and "
                  "desktop from a single codebase. \n\nYou can also embed Flutter!",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Divider(),
            ListTile(
              onTap: () {
                launch('mailto:info@neoblast-official.com');
              },
              leading: Icon(
                EvaIcons.emailOutline,
                color: Colors.lightBlue,
                size: 28,
              ),
              title: Text("Email",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Product Sans',
                      color: Theme.of(context).textTheme.bodyText1.color)),
              subtitle: Text(
                "info@neoblast-official.com",
                style: TextStyle(
                    fontFamily: 'Product Sans',
                    color: Theme.of(context).textTheme.bodyText1.color),
              ),
            ),
            ListTile(
              onTap: () {
                launch('mailto:neoblast-apps@gmail.com');
              },
              leading: Icon(
                Icons.email_outlined,
                color: Colors.red,
                size: 28,
              ),
              title: Text("Neoblast Gmail",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Product Sans',
                      color: Theme.of(context).textTheme.bodyText1.color)),
              subtitle: Text(
                "neoblast-apps@gmail.com",
                style: TextStyle(
                    fontFamily: 'Product Sans',
                    color: Theme.of(context).textTheme.bodyText1.color),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
