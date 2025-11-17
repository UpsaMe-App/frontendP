import 'package:flutter/foundation.dart';

/// Estado global de la app: tab activo en MainTabs
class AppState {
  AppState._private();
  static final AppState instance = AppState._private();

  final ValueNotifier<int> activeTabIndex = ValueNotifier<int>(0);

  /// Cambiar al tab Home (index 0)
  void goToHome() {
    activeTabIndex.value = 0;
  }

  /// Cambiar al tab Buscar (index 1)
  void goToSearch() {
    activeTabIndex.value = 1;
  }

  /// Cambiar al tab Publicar (index 2)
  void goToCreate() {
    activeTabIndex.value = 2;
  }

  /// Cambiar al tab Perfil (index 3)
  void goToProfile() {
    activeTabIndex.value = 3;
  }
}
