import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();

  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'money_manager.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accounts (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            opening_balance REAL NOT NULL,
            note TEXT,
            enabled INTEGER NOT NULL,
            sort_order INTEGER NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            name TEXT NOT NULL,
            icon INTEGER NOT NULL,
            color_hex INTEGER NOT NULL,
            enabled INTEGER NOT NULL,
            sort_order INTEGER NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            category_id TEXT,
            account_id TEXT NOT NULL,
            transfer_in_account_id TEXT,
            occurred_at TEXT NOT NULL,
            note TEXT,
            tags TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE budgets (
            id TEXT PRIMARY KEY,
            month TEXT NOT NULL,
            total_amount REAL NOT NULL,
            warning_threshold REAL NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE recurring_tasks (
            id TEXT PRIMARY KEY,
            template_json TEXT NOT NULL,
            rule TEXT NOT NULL,
            next_run_at TEXT NOT NULL,
            auto_generate INTEGER NOT NULL,
            enabled INTEGER NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE accounts ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0;',
          );
          await db.execute(
            'ALTER TABLE categories ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0;',
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return db.query(table);
  }

  Future<void> insert(String table, Map<String, dynamic> data,
      {ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await database;
    await db.insert(table, data, conflictAlgorithm: conflictAlgorithm);
  }

  Future<void> update(String table, Map<String, dynamic> data,
      {required String where, required List<Object?> whereArgs}) async {
    final db = await database;
    await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<void> delete(String table,
      {required String where, required List<Object?> whereArgs}) async {
    final db = await database;
    await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> replaceAll(String table, List<Map<String, dynamic>> rows) async {
    final db = await database;
    final batch = db.batch();
    batch.delete(table);
    for (final row in rows) {
      batch.insert(table, row);
    }
    await batch.commit(noResult: true);
  }

  static String encodeTags(List<String> tags) => jsonEncode(tags);

  static List<String> decodeTags(String raw) {
    final data = jsonDecode(raw);
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }
}
