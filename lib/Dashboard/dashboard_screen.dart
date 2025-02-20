import 'dart:convert';
import 'dart:typed_data';

import 'package:assignment2/Provider/logged_student.dart';
import 'package:assignment2/course_enroll_form.dart';
import 'package:assignment2/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Login/login_screen.dart';

class Dashboard extends StatefulWidget {

  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  List<Map<String,dynamic>> enrolledList=[];

  DatabaseHelper db= DatabaseHelper();




  @override
  Widget build(BuildContext context) {
    return Consumer<LoggedStudent>(
      builder: (context, loggedStudent, child){
        int? curLoggedStudentId= loggedStudent.logStudent!.id;
        String? image= loggedStudent.logStudent!.image;
        print(image);
        Uint8List imageBytes = base64.decode(image!);
        Image.memory(imageBytes);
          return Scaffold(
            drawer: Drawer(
                child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                                child: image==null?
                                const CircleAvatar(
                                  radius: 80,
                                  backgroundImage:
                                  AssetImage('assets/profile.webp'),
                                ):
                                CircleAvatar(
                                  radius: 80,
                                  backgroundImage:MemoryImage(imageBytes)
                                  ,
                                     )
                                ),

                              SizedBox(height: 20,),
                              Text(
                                '${loggedStudent.logStudent!.name}',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                '${loggedStudent.logStudent!.email}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey
                                ),
                              ),
                              SizedBox(height: 30,),
                              Container(
                                height: 55,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                                  },
                                  child: const Text('LOG OUT',
                                    style: TextStyle(
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20,),
                              ListTile(
                                leading: Icon(Icons.person,  size: 30,),
                                title: Text('${loggedStudent.logStudent!.name}'),
                                subtitle: Text('Name'),
                              ),
                              ListTile(
                                leading: Icon(Icons.email,  size: 30,),
                                title: Text('${loggedStudent.logStudent!.email}'),
                                subtitle: Text('Email'),
                              ),
                              ListTile(
                                leading: Icon(Icons.phone,  size: 30,),
                                title: Text('${loggedStudent.logStudent!.phone}'),
                                subtitle: Text('Contact'),
                              )
                          ],
                       ),
                    )
                 )
             ),

            appBar: AppBar(
              title:Text('The Courses Enrolled'),
            ),

         body: FutureBuilder(
              future: db.getEnrolledCourse(curLoggedStudentId!),
              builder: (context, snapshot) {

                if (snapshot.data!.isEmpty) {
                  return Center(child: Text('No courses enrolled.'));
                }
                enrolledList = snapshot.data!;

                return ListView.builder(
                  itemCount: enrolledList.length,
                  itemBuilder: (context, index) {
                    var course = enrolledList[index];
                    String courseName = course['name'];
                    String courseLocation = course['location'];

                    return GestureDetector(
                      child: ListTile(
                        title: Text(courseName),
                        subtitle: Text('Enrolled Location :$courseLocation'),
                      ),
                      onTap: (){
                        showDialog(context: context,
                            builder:(context)=>AlertDialog(
                              title: Text(courseName),
                              content: Text('This course is enrolled'),
                              actions: [
                                TextButton(
                                    onPressed: (){
                                      print(course['Eid']);
                                      setState(() {
                                        db.deleteEnrollCourse(course['Eid']);
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text('Delete Enrollment')
                                ),
                                TextButton(
                                    onPressed: (){Navigator.pop(context);},
                                    child: Text('Cancel')
                                )
                              ],
                            )
                          );
                        },
                     );
                   },
                );
              }
           ),

            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                List<Map<String, dynamic>>? updatedCourses = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CourseEnrollForm()),
                );
                  setState(() {
                    if(updatedCourses!=null)
                    enrolledList = updatedCourses;
                  });
               },
            ),
          );
       },
    );
  }
}
