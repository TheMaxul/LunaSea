import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/sabnzbd.dart';

class SABnzbdHistoryHideButton extends StatefulWidget {
    @override
    State<SABnzbdHistoryHideButton> createState() => _State();
}

class _State extends State<SABnzbdHistoryHideButton> {    
    @override
    Widget build(BuildContext context) => LSCard(
        child: Padding(
            child: Consumer<SABnzbdModel>(
                builder: (context, model, widget) => LSIconButton(
                    icon: model.historyHideFailed ? Icons.visibility_off : Icons.visibility,
                    onPressed: () => model.historyHideFailed = !model.historyHideFailed,
                ), 
            ),
            padding: EdgeInsets.all(1.0),
        ),
        margin: EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 12.0),
        color: Theme.of(context).canvasColor,
    );
}
