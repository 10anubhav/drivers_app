
import 'dart:io';

import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';
import 'login_screen.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}


class _SignUpScreenState extends State<SignUpScreen>
{
  TextEditingController phoneTextEditingController= TextEditingController();
  TextEditingController userNameTextEditingController= TextEditingController();
  TextEditingController emailTextEditingController= TextEditingController();
  TextEditingController passwordTextEditingController= TextEditingController();
  TextEditingController vehicleModelTextEditingController= TextEditingController();
  TextEditingController vehicleColourTextEditingController= TextEditingController();
  TextEditingController vehicleNumberTextEditingController= TextEditingController();
  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  String urlOfUploadedImage="";

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context); //Used to check Network
    if (imageFile != null) {
      signUpFormValidation();
    }
    else {
      cMethods.displaySnackBar("Please Choose Image", context);
    }
  }


  signUpFormValidation()
  {
    if(userNameTextEditingController.text.trim().length <3)
      {
        cMethods.displaySnackBar("Your name must be 4 or more character ", context);
      }
    else if(phoneTextEditingController.text.trim().length <7)
    {
      cMethods.displaySnackBar("Your number is incorrect ", context);
    }
    else if(!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("Invalid Email ", context);
    }
    else if(passwordTextEditingController.text.trim().length <5)
    {
      cMethods.displaySnackBar("Password is to Small ", context);
    }
    else if(vehicleModelTextEditingController.text.trim().isEmpty)
    {
      cMethods.displaySnackBar("Please Write Your Car Model", context);
    }
    else if(vehicleColourTextEditingController.text.trim().isEmpty)
    {
      cMethods.displaySnackBar("Please Write Your Car Colour ", context);
    }
    else if(vehicleNumberTextEditingController.text.trim().isEmpty)
    {
      cMethods.displaySnackBar("Please Write Your Car Number", context);
    }
    else
      {  uploadImageToStorage();

        //register the User
      }
  }
  uploadImageToStorage() async{
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage= await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });
    registerNewDriver();
  }
  registerNewDriver() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)=> LoadingDialog(messageText: "Registering Your Account...."),
    );
    final User? userFirebase=(
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((errorMsg)
        {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;
    if(!context.mounted)return;
    Navigator.pop(context);

    DatabaseReference userRef= FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);
   Map driverCarInfo =
   {
     "carColour" : vehicleColourTextEditingController.text.trim(),
     "carModel" : vehicleModelTextEditingController.text.trim(),
     "carNumber" : vehicleNumberTextEditingController.text.trim(),
   };

    Map driverDataMap =
    {
      "photo": urlOfUploadedImage,
      "car_details": driverCarInfo,
      "name": userNameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": phoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    userRef.set(driverDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c)=> Dashboard()));

  }
  chooseImageFromGallery() async
  {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if(pickedFile!=null)
        {
          setState(() {
            imageFile=pickedFile;
          });
        }
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              const SizedBox(
                height: 70,
              ),

             imageFile==null ?


             const CircleAvatar(
                radius: 86,
                backgroundImage: AssetImage("assets/images/avatarman.png"),
              ): Container(
               width: 180,
               height: 180,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: Colors.grey,
                 image: DecorationImage(
                   fit: BoxFit.fitHeight,
                   image: FileImage(
                     File(
                       imageFile!.path,
                     ),
                   )
                 )
               ),
             ),

              const SizedBox(
                height: 20,
              ),

              GestureDetector(
                onTap: ()
                {
                      chooseImageFromGallery();
                },
                child: const Text(
                  "Choose Image",
                  style: TextStyle(
                    fontSize: 16,
                      fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //text fields + button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Your Name",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),//userName

                    TextField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Your Phone Number",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),//userPhone

                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Your Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),//userEmail

                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Your Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    TextField(
                      controller: vehicleModelTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Your Car Model",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    TextField(
                      controller: vehicleColourTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Your Car Colour",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    TextField(
                      controller: vehicleNumberTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Your Car Number",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),//userPassword

                    const SizedBox(height: 22,),

                    ElevatedButton(
                      onPressed: ()
                      {
                          checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 80)
                      ),
                      child: const Text(
                        "SignUp"
                      ),
                    )
                    //text button
                  ],
                ),
              ),
              const SizedBox(height: 12,),
              //text button
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>LogInScreen()));
                },
                child: const  Text(
                    "Already have an Account? Login Here",
                    style: TextStyle(
                      color: Colors.grey
                    ),
                ),
              ),
            ],
          ),
        ),
       ),
    );
  }
}
