import 'package:event_bus/event_bus.dart';
import '../models/nippon_color.dart';

EventBus eventBus = EventBus();

class UpdateColorEvent {
  int updatedIndex;
  NipponColor updatedColor;

  UpdateColorEvent(this.updatedIndex, this.updatedColor);
}

class SelectColorEvent {
  NipponColor selectedColor;
  bool active;

  SelectColorEvent(this.selectedColor, this.active);
}
