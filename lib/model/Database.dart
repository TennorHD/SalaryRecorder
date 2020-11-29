import 'dart:async';
import 'dart:io' show Directory;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;


class DBHelper {
  static final _databaseName = "wage_database.db";
  static final _databaseVersion = 1;

  static final table = 'records';
  static final table2 = 'user';

  static final columnId = '_id';
  static final columnDay = 'day';
  static final columnTime = 'time';
  static final columnHour = 'hour';
  static final columnMinute = 'minute';

  static final columnUserId = '_uid';
  static final columnUsername = 'username';
  static final columnCurrency = 'currency';
  static final columnPayRate = 'pay_rate';

  // make this a singleton class
  DBHelper._privateConstructor();

  static final DBHelper instance = DBHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    print(documentsDirectory.path);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnDay TEXT NOT NULL,
            $columnTime DOUBLE NOT NULL,
            $columnHour INTEGER NOT NULL,
            $columnMinute INTEGER NOT NULL
          );
          ''');
  }
}