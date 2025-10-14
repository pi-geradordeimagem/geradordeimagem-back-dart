import 'package:geradordeimagem_back_dart/utils/env.dart';
import 'package:mongo_dart/mongo_dart.dart';

mongoConnect() async {
  final db = await Db.create(loadDotEnv()['MONGO_URL']);
  await db.open();
  return db;
}