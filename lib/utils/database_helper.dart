import 'package:catfacts/feature/cat_facts/data/model/visibility.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  static String _tableName = 'cat_facts';

  DatabaseHelper._privateConstructor();

  Future<void> initialize() async {
    if (_database == null) {
      _database = await _initDatabase();
    }
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'catfacts_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fact TEXT,
        appearance_time DATETIME DEFAULT CURRENT_TIMESTAMP,
        visible_duration INTEGER
      )
    ''');
  }

  Future<void> insertCatFact(VisibilityModel visibilty) async {
    try {
      debugPrint('inserting cat fact ${visibilty.fact}');

      final db = await _database;
      await db!.insert(
        _tableName,
        {
          'fact': visibilty.fact,
          'appearance_time': visibilty.appearanceTime.toIso8601String(),
          'visible_duration': visibilty.visibleDuration,
        },
      );
    } catch (e) {
      debugPrint('error inserting cat fact ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCatFacts() async {
    final db = await _database;
    return await db!.query(_tableName);
  }
}
