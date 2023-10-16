import 'dart:async';

import 'package:catfacts/feature/cat_facts/data/model/visibility.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'firebase_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  static String _tableName = 'cat_facts';
  bool isSyncing = false;

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
      if (await isAlreadyPresent(visibilty.fact)) return;
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
      unawaited(syncDataToFirebase());
    } catch (e) {
      debugPrint('error inserting cat fact ${e.toString()}');
    }
  }

  Future<void> syncDataToFirebase() async {
    try {
      final data = await getAllCatFacts();

      if (data.length < 20 || isSyncing)
        return;
      else {
        isSyncing = true;
        debugPrint('syncing data to firebase ...');
        final firestoreHelper = FirestoreHelper();
        final isUpdated = await firestoreHelper.syncDataToFirebase(data);
        if (isUpdated) {
          debugPrint('data synced to firebase');
          final isDeleted = await deleteData(data.length);
          if (isDeleted) {
            debugPrint('data deleted from local database');
            isSyncing = false;
          }
        }
      }
    } catch (e) {
      isSyncing = true;
      debugPrint('error syncing data to firebase ${e.toString()}');
    }
  }

  Future<bool> isAlreadyPresent(String fact) async {
    final db = _database;
    final data =
        await db!.rawQuery('SELECT * FROM $_tableName WHERE fact = "$fact"');
    if (data.isNotEmpty) {
      debugPrint('$fact already present');
      return true;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getAllCatFacts() async {
    final db = await _database;
    return await db!.query(_tableName);
  }

  Future<bool> deleteData(int numb) async {
    try {
      final db = await _database;
      await db!.rawDelete(
          'DELETE FROM $_tableName WHERE id IN (SELECT id FROM $_tableName ORDER BY id ASC LIMIT $numb)');

      return true;
    } catch (e) {
      debugPrint('error deleting cat fact ${e.toString()}');
      return false;
    }
  }
}
