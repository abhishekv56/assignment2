import 'dart:convert';
import 'dart:typed_data';

import 'package:assignment2/Login/login_screen.dart';
import 'package:assignment2/Models/student_model.dart';
import 'package:assignment2/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:assignment2/Utils/reusable_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../Utils/validators.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});


  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _registerKey = GlobalKey<FormState>();

  DatabaseHelper dbhelper = DatabaseHelper();

  String? _name;
  String? _email;
  String? _phone;
  String? _password;
  bool isObscure = true;
  String? image;

  File? imgFile;
  late String base64String="";


  void pickImage(ImageSource imageSource) async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: imageSource);
    Uint8List _bytes = await img!.readAsBytes();
    base64String = base64.encode(_bytes);
    print('Encoded $base64String');

    setState(() {
      imgFile = File(img.path);
    });
    print('File is $imgFile');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: Center(
          child: Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Form(
                  key: _registerKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                     profileImage(),
                     
                      const SizedBox(height: 20,),
                      CustomTextFormWidget(
                          lblText: 'Name',
                          prefixIcon: Icons.person,
                          validator: validateName,
                          keyboardType: TextInputType.text,
                          onSaved: (value) => _name = value
                      ),
                      const SizedBox(height: 10,),
                      CustomTextFormWidget(
                          lblText: 'Email',
                          prefixIcon: Icons.email,
                          validator: validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (value) => _email = value
                      ),
                      const SizedBox(height: 10,),
                      CustomTextFormWidget(
                          lblText: 'Phone',
                          prefixIcon: Icons.phone,
                          validator: validatePhone,
                          keyboardType: TextInputType.phone,
                          onSaved: (value) => _phone = value
                      ),
                      const SizedBox(height: 10,),
                      CustomTextFormWidget(
                        lblText: 'Password',
                        prefixIcon: Icons.password,
                        suffixIcon: IconButton(
                          icon: isObscure
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                        validator: validatePassword,
                        keyboardType: TextInputType.visiblePassword,
                        onSaved: (value) => _password = value,
                        isObscure: isObscure,
                      ),
                      const SizedBox(height: 20,),
                      Container(
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: TextButton(
                          onPressed: ()  async {
                            if(base64String!=""){
                            if(_registerKey.currentState!.validate()){
                              _registerKey.currentState!.save();

                                Student student = Student(
                                  email: _email!,
                                  name: _name!,
                                  phone:_phone!,
                                  password: _password!,
                                  image: base64String,
                                );

                                try{
                                  await dbhelper.insertStudent(student);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Registration Successful !'))
                                  );
                                  _registerKey.currentState!.reset();
                                  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>LoginScreen()));
                                }
                                catch(e){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Email/Phone already exists'),
                                        duration: Duration(seconds: 2),
                                      )
                                  );
                                }
                              }
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please choose your profile Image'))
                              );

                            }
                          },
                          child: const Text('REGISTER',
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ),
        )
    );
  }

  Widget profileImage(){
    return Center(
      child: GestureDetector(
        child: Stack(
          children: [
            CircleAvatar(
                radius: 80,
                backgroundImage: imgFile==null? AssetImage('assets/register_img.jpg'): FileImage(imgFile!) as ImageProvider,
            ),
            Positioned(
                bottom: 20,
                right: 10,
                child: Icon(Icons.camera_alt,size: 40,)
                )
          ],
        ),
        onTap: (){
          showModalBottomSheet(context: context,
              builder: (context)=>bottomSheet());
        },
      ),
    );
  }


  Widget bottomSheet(){
    return Container(
      height: 200,
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Choose Profile Image'),
          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(onPressed: (){
                pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
                icon: Icon(Icons.camera_alt),
                label: Text('Camera'),
              ),
              SizedBox(width: 40,),
              TextButton.icon(onPressed: (){
                pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
                icon: Icon(Icons.image),
                label: Text('Gallery'),
              )
            ],
          )
        ],
      ),
    );
  }
}


