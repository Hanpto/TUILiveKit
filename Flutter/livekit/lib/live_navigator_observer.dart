import 'package:flutter/material.dart';
import 'package:rtc_room_engine/rtc_room_engine.dart';
import 'package:tencent_live_uikit/voice_room/index.dart';

import '../../common/index.dart';
import 'live_identity_generator.dart';
import 'live_stream/widget/live_room/index.dart';

class TUILiveKitNavigatorObserver extends RouteObserver {
  static final TUILiveKitNavigatorObserver instance =
      TUILiveKitNavigatorObserver._internal();

  factory TUILiveKitNavigatorObserver() {
    return instance;
  }

  static bool isRepeatClick = false;

  TUILiveKitNavigatorObserver._internal() {
    LiveKitLogger.info('TUILiveKitNavigatorObserver Init');
    Boot.instance;
  }

  BuildContext getContext() {
    return navigator!.context;
  }

  void enterLiveRoomAudiencePage(TUILiveInfo liveInfo) {
    if (isRepeatClick) {
      return;
    }
    Navigator.push(
        getContext(),
        MaterialPageRoute(
          settings: const RouteSettings(name: Constants.routeLiveRoomAudience),
          builder: (context) {
            return TUILiveRoomAudienceWidget(roomId: liveInfo.roomInfo.roomId);
          },
        ));
    isRepeatClick = false;
  }

  void backToLiveRoomAudiencePage() {
    Navigator.popUntil(getContext(), (route) {
      if (route.settings.name == Constants.routeLiveRoomAudience) {
        return true;
      }
      return false;
    });
  }

  void enterVoiceRoomPage(TUILiveInfo liveInfo,
      {void Function(String roomId, RoomType roomType, bool isOwner)?
          onMinimized,
      bool isRestore = false}) {
    if (isRepeatClick) {
      return;
    }

    Navigator.push(
        getContext(),
        MaterialPageRoute(
          settings: const RouteSettings(name: Constants.routeVoiceRoom),
          builder: (context) {
            final isOwner =
                liveInfo.roomInfo.ownerId == TUIRoomEngine.getSelfInfo().userId;
            return TUIVoiceRoomWidget(
              roomId: liveInfo.roomInfo.roomId,
              behavior: isOwner ? RoomBehavior.autoCreate : RoomBehavior.join,
              onMinimize: onMinimized,
              isRestore: isRestore,
            );
          },
        ));

    isRepeatClick = false;
  }

  void backToVoiceRoomPage() {
    Navigator.popUntil(getContext(), (route) {
      if (route.settings.name == Constants.routeVoiceRoom) {
        return true;
      }
      return false;
    });
  }
}
