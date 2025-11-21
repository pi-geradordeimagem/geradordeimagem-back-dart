import 'package:dotenv/dotenv.dart';

loadDotEnv() {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  return env;
}