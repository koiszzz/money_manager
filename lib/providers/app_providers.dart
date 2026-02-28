import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_state.dart';

final appStateProvider = ChangeNotifierProvider<AppState>((ref) {
  return AppState();
});
