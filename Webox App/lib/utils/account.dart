import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  return userId;
}

Future<void> setUserId(String userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId);
}

Future<void> clearUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
}

Future<bool> isLogined() async {
  String? userId = await getUserId();
  return userId != null;
}
