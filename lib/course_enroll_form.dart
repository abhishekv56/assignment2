import 'package:flutter/material.dart';
import 'package:assignment2/Provider/logged_student.dart';
import 'package:assignment2/database_helper.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../Utils/location.dart';

class CourseEnrollForm extends StatefulWidget {
  const CourseEnrollForm({super.key});

  @override
  State<CourseEnrollForm> createState() => _CourseEnrollFormState();
}

class _CourseEnrollFormState extends State<CourseEnrollForm> {
  DatabaseHelper db = DatabaseHelper();
  List<Map<String, dynamic>> courses = [];
  List<int> selectedCourses = [];
  List<int> enrolledCourseList = [];



  final updateKey=GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getCourses();
    var studentId = Provider.of<LoggedStudent>(context, listen: false).logStudent!.id;
    _enrolledCourses(studentId!);

  }

  Future<void> getCourses() async {
    final courseList = await db.getCourses();
    setState(() {
      courses = courseList;
    });
  }

  Future<void> _enrolledCourses(int studentId) async {
    try {
      final enrolledCourses = await db.getEnrolledCourse(studentId);
      print("Enrolled courses from DB: $enrolledCourses");

      if (enrolledCourses.isNotEmpty) {
        setState(() {
          enrolledCourseList = enrolledCourses.map<int>((course) {
            var courseId = course['cou_id'];
            return courseId;
          }).toList();
        });
      }
      print("enrolledCourseList: $enrolledCourseList");
    } catch (e) {
      print("Error loading enrolled courses: $e");
    }
  }


  void _onCourseSelected(bool? selected, int courseId) {
    setState(() {
      if (selected == true) {
        selectedCourses.add(courseId);
      } else {
        selectedCourses.remove(courseId);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Course Selection")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<LoggedStudent>(
          builder: (context, loggedStudent, child) {
            final studentId = loggedStudent.logStudent!.id;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: loggedStudent.logStudent!.name,
                    decoration: InputDecoration(labelText: "Student Name"),
                    readOnly: true,
                  ),
                  SizedBox(height: 20),
                  const Text(
                    "Available Courses",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                         Expanded(
                           child: ListView.builder(
                           shrinkWrap: true,
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              bool isDisabled = enrolledCourseList.contains(course['id']);
                              String initialValue = course['name'];
                              TextEditingController nameUpdate=TextEditingController(text: initialValue);
                              return  CheckboxListTile(
                                 controlAffinity: ListTileControlAffinity.leading,
                                  title: Text(course['name']),
                                  value: selectedCourses.contains(course['id']),
                                  onChanged: isDisabled
                                      ? null
                                      : (bool? selected) {
                                    _onCourseSelected(selected, course['id']);
                                  },
                                  subtitle: isDisabled
                                      ? Text("Already enrolled")
                                      : null,
                                  secondary: TextButton(
                                    onPressed: (){
                                      showDialog(context: context,
                                          builder:(context)=>Form(
                                            key: updateKey,
                                            child: AlertDialog(
                                              title: Text('Edit Course'),
                                              content: TextFormField(
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                controller: nameUpdate,
                                                validator: (value){
                                                  if(value==null||value.isEmpty)
                                                    {
                                                      return 'Value cant be empty';
                                                    }
                                                  return null;
                                                },
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: ()  {
                                                      if(updateKey.currentState!.validate()){
                                                        db.updateCourseName(course['id'], nameUpdate.text);
                                                        getCourses();
                                                        Navigator.pop(context);
                                                        }
                                                      },
                                                    child: Text('Edit')
                                                ),
                                                TextButton(
                                                    onPressed: (){Navigator.pop(context);},
                                                    child: Text('Cancel')
                                                )
                                              ],
                                            ),
                                          )
                                       );
                                    }, child: Text('Edit')),
                                 );
                              },
                           ),
                         ),

                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedCourses.isNotEmpty) {
                          Position? position = await determinePosition();

                          List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude,position.longitude);

                          // final currentAddress =
                          //     placemarks.reversed.first.administrativeArea.toString()+","
                          //         +placemarks.reversed.first.subAdministrativeArea.toString()
                          //         +","+placemarks.reversed.first.postalCode.toString();

                          String positionString = "${position.longitude}, ${position.latitude}";


                          for (var courseId in selectedCourses) {
                            await db.insertEnrolledCourse(studentId!, courseId, positionString);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Courses enrolled successfully")),

                          );

                          List<Map<String, dynamic>> updatedCourses = await db.getEnrolledCourse(studentId!);

                          Navigator.pop(context, updatedCourses);
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please select at least one course")),
                          );
                        }
                      },
                      child: Text("Enroll"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
