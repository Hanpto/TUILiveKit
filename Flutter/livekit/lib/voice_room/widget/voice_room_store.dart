import 'package:live_stream_core/live_stream_core.dart';

class VoiceRoomStore {
  VoiceRoomStore._();

  static final VoiceRoomStore _instance = VoiceRoomStore._();

  factory VoiceRoomStore() {
    return _instance;
  }

  final Map<String, SeatGridController> seatGridControllerMap = {};

  void putController(String roomId, SeatGridController controller) {
    seatGridControllerMap[roomId] = controller;
  }

  SeatGridController? getController(String roomId) {
    if (seatGridControllerMap.containsKey(roomId)) {
      return seatGridControllerMap[roomId];
    }
    return null;
  }

  void clear() {
    seatGridControllerMap.clear();
  }
}
