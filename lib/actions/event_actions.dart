import 'package:event_bus/event_bus.dart';
import '../models/nippon_color.dart';

EventBus eventBus = EventBus();

// 点击屏幕时更新颜色
class UpdateColorEvent {
  int updatedIndex; // index为在list中的索引 而不是color的id
  NipponColor updatedColor;

  UpdateColorEvent(this.updatedIndex, this.updatedColor);
}

// 选择一个颜色
class SelectColorEvent {
  NipponColor selectedColor;

  SelectColorEvent(this.selectedColor);
}

// 更新我喜欢的颜色
class UpdateFavoriteColors {
  List<String> favoriteColors;

  UpdateFavoriteColors(this.favoriteColors);
}
