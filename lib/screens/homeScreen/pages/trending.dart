import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/lib.dart';
import 'package:songtube/provider/managerProvider.dart';
import 'package:songtube/ui/components/emptyIndicator.dart';
import 'package:songtube/ui/layout/streamsLargeThumbnail.dart';

class HomePageTrending extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ManagerProvider manager = Provider.of<ManagerProvider>(context);
    if(Lib.DOWNLOADING_ENABLED) {
      return StreamsLargeThumbnailView(
          infoItems: manager.homeTrendingVideoList
      );
    }else{
      return Container(
          alignment: Alignment.topCenter,
          child: EmptyIndicator()
      );
    }
  }
}