import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:medical_reminder/models/verification.dart';
import 'dart:io' show Platform;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medical_reminder.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE verifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicationId TEXT,
        patientId TEXT,
        caregiverId TEXT,
        verificationStatement TEXT,
        timestamp TEXT,
        verified INTEGER
      )
    ''');
  }

  Future<int> insertVerification(Verification verification) async {
    final db = await database;
    return await db.insert('verifications', verification.toJson());
  }

  Future<List<Map<String, dynamic>>> queryVerificationsByPatient(
      String patientId) async {
    final db = await database;
    return await db.query(
      'verifications',
      where: 'patientId = ?',
      whereArgs: [patientId],
    );
  }

  Future<int> updateVerification(Verification verification) async {
    final db = await database;
    return await db.update(
      'verifications',
      verification.toJson(),
      where: 'id = ?',
      whereArgs: [verification.toJson()['id']],
    );
  }

  Future<int> deleteVerification(int id) async {
    final db = await database;
    return await db.delete(
      'verifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
