import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/sonarr.dart';

class SonarrTagsTagTile extends StatefulWidget {
    final SonarrTag tag;

    SonarrTagsTagTile({
        Key key,
        @required this.tag,
    }) : super(key: key);

    @override
    State<SonarrTagsTagTile> createState() => _State();
}

class _State extends State<SonarrTagsTagTile> with LunaLoadCallbackMixin {
    List<String> seriesList;

    Future<void> loadCallback() async {
        await context.read<SonarrState>().series.then((series) {
            List<String> _series = [];
            series.forEach((element) {
                if(element.tags.contains(widget.tag.id)) _series.add(element.title);
            });
            _series.sort();
            if(mounted) setState(() {
                seriesList = _series;
            });
        })
        .catchError((error) {
            if(mounted) setState(() {
                seriesList = null;
            });
        });
    }

    @override
    Widget build(BuildContext context) {
        return LunaListTile(
            context: context,
            title: LunaText.title(text: widget.tag.label),
            subtitle: LunaText.subtitle(text: subtitle()),
            trailing: seriesList == null || seriesList.length != 0
                ? null
                : LunaIconButton(
                    icon: Icons.delete,
                    color: LunaColours.red,
                    onPressed: _handleDelete,
                ),
            onTap: _handleInfo,
        );
    }

    String subtitle() {
        if(seriesList == null) return 'Loading...';
        if(seriesList.length == 0) return 'No Series';
        return '${seriesList.length} Series';
    }

    Future<void> _handleInfo() async {
        return LunaDialogs().textPreview(
            context,
            'Series List',
            seriesList == null || seriesList.length == 0 ? 'No Series' : seriesList.join('\n'),
        );
    }

    Future<void> _handleDelete() async {
        if(seriesList == null || seriesList.length != 0) {
            showLunaErrorSnackBar(title: 'Cannot Delete Tag', message: 'The tag must not be attached to any series');
        } else {
            bool result = await SonarrDialogs().deleteTag(context);
            if(result) context.read<SonarrState>().api.tag.deleteTag(id: widget.tag.id)
            .then((_) {
                showLunaSuccessSnackBar(title: 'Deleted Tag', message: widget.tag.label);
                context.read<SonarrState>().resetTags();
            })
            .catchError((error, stack) {
                LunaLogger().error('Failed to delete tag: ${widget.tag.id}', error, stack);
                showLunaErrorSnackBar(title: 'Failed to Delete Tag', error: error);
            });
        }
    }
}