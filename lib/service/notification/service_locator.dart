import 'package:get_it/get_it.dart';
import 'package:visible/service/notification/NavigationService.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  // Timer(Duration(milliseconds: 500), () => NotificationService().initialize());
}
