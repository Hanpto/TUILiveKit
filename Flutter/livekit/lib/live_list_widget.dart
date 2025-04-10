import 'package:flutter/material.dart';
import 'package:rtc_room_engine/rtc_room_engine.dart';

import 'component/room_list/widget/room_list_widget.dart';
import 'live_identity_generator.dart';
import 'live_navigator_observer.dart';
import 'live_stream/widget/live_room/live_room_audience_widget.dart';
import 'voice_room/voice_room_widget.dart';

class LiveListWidget extends StatefulWidget {
  final void Function(String roomId, RoomType roomType, bool isOwner)?
      onMinimize;

  const LiveListWidget({super.key, this.onMinimize});

  @override
  State<LiveListWidget> createState() => _LiveListWidgetState();
}

class _LiveListWidgetState extends State<LiveListWidget> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route == null) return;
    TUILiveKitNavigatorObserver.instance.subscribe(this, route);
  }

  @override
  void dispose() {
    TUILiveKitNavigatorObserver.instance.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _refreshRoomList();
  }

  @override
  Widget build(BuildContext context) {
    return RoomListWidget(
        key: UniqueKey(),
        onClickItem: (liveInfo) {
          final roomType = LiveIdentityGenerator.instance
              .getIDType(liveInfo.roomInfo.roomId);
          if (roomType == RoomType.voice) {
            TUILiveKitNavigatorObserver.instance
                .enterVoiceRoomPage(liveInfo, onMinimized: widget.onMinimize);
          } else {
            TUILiveKitNavigatorObserver.instance
                .enterLiveRoomAudiencePage(liveInfo);
          }
        });
  }
}

extension on _LiveListWidgetState {
  void _refreshRoomList() {
    setState(() {});
  }
}
