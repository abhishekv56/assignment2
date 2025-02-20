import 'package:assignment2/Models/enrolled_course_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Models/student_model.dart';

class DatabaseHelper {

  final databaseName = "app2.db";

  String tblStudent = 'students';
  String colStudentId = "id";
  String colStudentName = "name";
  String colStudentEmail = "email";
  String colStudentPhone = "phone";
  String colStudentPassword = 'password';
  String colStudentImage ='image';

  String tblCourse = 'courses';
  String colCourseId = 'id';
  String colCourseName = 'name';

  String tblEnrolledCourse = 'enrolled';
  String colEnrollId = 'Eid';
  String colStudId='stud_id';
  String colCourId='cou_id';
  String colLoc = 'location';

  Database? _database;
  DatabaseHelper._constructor();
  static final DatabaseHelper _instance = DatabaseHelper._constructor();
  factory DatabaseHelper() => _instance;

  Future<Database> getDB() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON');

        await db.execute(
         "CREATE TABLE $tblStudent("
             "$colStudentId INTEGER PRIMARY KEY AUTOINCREMENT,"
             " $colStudentName TEXT, "
             "$colStudentEmail TEXT UNIQUE,"
             "$colStudentPhone TEXT UNIQUE,"
             "$colStudentPassword TEXT,"
             "$colStudentImage TEXT )"

          // 'CREATE TABLE $tblStudent('
          //     '$colStudentId INTEGER PRIMARY KEY AUTOINCREMENT,'
          //     '$colStudentName TEXT, '
          //     '$colStudentEmail TEXT UNIQUE, '
          //     '$colStudentPhone TEXT UNIQUE, '
          //     '$colStudentPassword TEXT'
          //     ')',
        );

        await db.execute(
          'CREATE TABLE $tblCourse('
              '$colCourseId INTEGER PRIMARY KEY AUTOINCREMENT, '
              '$colCourseName TEXT UNIQUE'
              ')',
        );

        await db.execute(
          'CREATE TABLE $tblEnrolledCourse('
              '$colEnrollId INTEGER PRIMARY KEY AUTOINCREMENT, '
              '$colStudId INTEGER, '
              '$colCourId INTEGER, '
              '$colLoc TEXT, '
              'FOREIGN KEY($colStudId) REFERENCES $tblStudent($colStudentId), '
              'FOREIGN KEY($colCourId) REFERENCES $tblCourse($colCourseId)'
              ')',
        );
      },
    );
  }

  Future<void> insertStudent(Student student) async {
    final db = await getDB();
    try {
      await db.insert(
        tblStudent,
        student.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      print("User  inserted successfully: ${student.email}");
    } catch (e) {
      print("Error inserting user: $e");
      throw e;
    }
  }


  Future<void> insertPredefinedCourses() async {
    final db = await getDB();

    var res = await db.rawQuery('SELECT * FROM $tblCourse');

    if (res.isEmpty) {
      List<Map<String, dynamic>> predefinedCourses = [
        {'name': 'Mobile Development'},
        {'name': '.NET Development'},
        {'name': 'Power App Development'},
        {'name': 'Software Testing'},
        {'name': 'Java Development'},
        {'name': 'WordPress'},
        {'name': 'Digital Marketing'},
        {'name': 'Python'},
      ];

      for (var course in predefinedCourses) {
        await db.insert(
          tblCourse,
          course,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      print("Predefined courses inserted successfully");
    } else {
      print("Courses already exist in the database");
    }
  }


  Future<bool> autheticateStudent(Student student) async{
    final db = await getDB();
    String email = student.email.trim();
    String password = student.password!.trim();
    var res = await db.rawQuery(
        'SELECT * from $tblStudent where $colStudentEmail=? and $colStudentPassword=?',[email,password]
    );

    return res.isNotEmpty;
  }

  Future<Student> getLoggedStudent(Student student) async {
    final db = await getDB();
    String email=student.email.trim();
    var res = await db.rawQuery(
      'SELECT * FROM $tblStudent WHERE $colStudentEmail = ?',
      [email],
    );
      return Student.fromMap(res.first);
    }

  Future<List<Map<String, dynamic>>> getCourses() async {
    final db = await getDB();
    var res = await db.query(tblCourse);
    return res;
  }


  Future<void> insertEnrolledCourse(int studentId, int courseId, String location) async {
    final db = await getDB();
    try {
      print('Inserting Enrolled Course: StudentId: $studentId, CourseId: $courseId, Location: $location');

      await db.insert(
          tblEnrolledCourse,
          EnrolledCourse(studentId: studentId, courseId: courseId, location: location).toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort
      );

      print('Insert successful');
    } catch (e) {
      print('Error inserting enrolled course: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getEnrolledCourse(int studentId) async {
    final db = await getDB();
    final res = await db.rawQuery(
        'SELECT * FROM $tblEnrolledCourse JOIN $tblCourse ON $colCourId=$colCourseId WHERE $colStudId=?', [studentId]
    );
    print("Enrolled Courses Data: $res");

    return res;
  }


  Future<void> deleteEnrollCourse(int enrollId) async{
    final db= await getDB();
    await db.rawQuery(
      'DELETE FROM $tblEnrolledCourse where $colEnrollId=?',[enrollId]
    );
  }


  Future<void> updateCourseName(int courseId, String name) async{
    final db= await getDB();
    await db.rawQuery(
      'UPDATE $tblCourse SET $colCourseName= ? WHERE $colCourseId=?',[name, courseId]
    );
  }

}

