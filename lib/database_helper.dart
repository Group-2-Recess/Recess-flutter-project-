import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'records';

  static final columnId = '_id';
  static final columnPatientName = 'patientName';
  static final columnGender = 'gender';
  static final columnMedicationName = 'medicationName';
  static final columnTime = 'time';
  static final columnDate = 'date';
  static final columnTaken = 'taken';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnPatientName TEXT NOT NULL,
            $columnGender TEXT NOT NULL,
            $columnMedicationName TEXT NOT NULL,
            $columnTime TEXT NOT NULL,
            $columnDate TEXT NOT NULL,
            $columnTaken INTEGER NOT NULL
          )
          ''');
  }

  Future<int> insertRecord(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryRecordsByPatient(
      String patientName) async {
    Database? db = await instance.database;
    return await db!.query(table,
        where: "$columnPatientName = ?", whereArgs: [patientName]);
  }
}
