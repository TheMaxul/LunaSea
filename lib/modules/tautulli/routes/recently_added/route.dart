import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/tautulli.dart';

class TautulliRecentlyAddedRouter extends TautulliPageRouter {
    TautulliRecentlyAddedRouter() : super('/tautulli/recentlyadded');

    @override
    void defineRoute(FluroRouter router) => super.noParameterRouteDefinition(router, _TautulliRecentlyAddedRoute());
}

class _TautulliRecentlyAddedRoute extends StatefulWidget {
    @override
    State<_TautulliRecentlyAddedRoute> createState() => _State();
}

class _State extends State<_TautulliRecentlyAddedRoute> with LunaScrollControllerMixin {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

    Future<void> _refresh() async {
        context.read<TautulliState>().resetRecentlyAdded();
        await context.read<TautulliState>().recentlyAdded;
    }

    @override
    void initState() {
        super.initState();
        SchedulerBinding.instance.scheduleFrameCallback((_) => _refresh());
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: _appBar(),
            body: _body(),
        );
    }

    Widget _appBar() {
        return LunaAppBar(
            title: 'Recently Added',
            scrollControllers: [scrollController],
        );
    }

    Widget _body() {
        return LunaRefreshIndicator(
            context: context,
            key: _refreshKey,
            onRefresh: _refresh,
            child: Selector<TautulliState, Future<List<TautulliRecentlyAdded>>>(
                selector: (_, state) => state.recentlyAdded,
                builder: (context, stats, _) => FutureBuilder(
                    future: stats,
                    builder: (context, AsyncSnapshot<List<TautulliRecentlyAdded>> snapshot) {
                        if(snapshot.hasError) {
                            if(snapshot.connectionState != ConnectionState.waiting) LunaLogger().error(
                                'Unable to fetch Tautulli recently added',
                                snapshot.error,
                                snapshot.stackTrace,
                            );
                            return LunaMessage.error(onTap: _refreshKey.currentState.show);
                        }
                        if(snapshot.hasData) return _list(snapshot.data);
                        return LunaLoader();
                    },
                ),
            ),
        );
    }

    Widget _list(List<TautulliRecentlyAdded> added) {
        if((added?.length ?? 0) == 0) return LunaMessage(
            text: 'No Content Found',
            buttonText: 'Refresh',
            onTap: _refreshKey.currentState?.show,
        );
        return LunaListViewBuilder(
            controller: scrollController,
            itemCount: added.length,
            itemBuilder: (context, index) => TautulliRecentlyAddedContentTile(recentlyAdded: added[index]),
        );
    }
}