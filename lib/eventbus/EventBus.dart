import 'package:event_bus/event_bus.dart';

import '../model/VideoSource.dart';

class ChangeVideoSourceEvent {
  final VideoSource source;

  ChangeVideoSourceEvent(this.source);
}

class GotoVideoPage { }

class ALL_EVENTS {
  static EventBus eventBus = new EventBus();
}