import 'package:drivers_app/authentication/signup_screen.dart';
import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}


class _LogInScreenState extends State<LogInScreen>
{
  TextEditingController emailTextEditingController= TextEditingController();
  TextEditingController passwordTextEditingController= TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvaliable()
  {
    cMethods.checkConnectivity(context);

    signInFormValidation();
  }
  signInFormValidation() {
     if(!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("Invalid Email ", context);
    }
    else if(passwordTextEditingController.text.trim().length <5)
    {
      cMethods.displaySnackBar("Password is to Small ", context);
    }
    else
    {
      signInUser();

    }
  }
  signInUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)=> LoadingDialog(messageText: "Allowing You to Login"),
    );

    final User? userFirebase=(
        await FirebaseAuth.instance.signInWithEmailAndPassword(
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

    if(userFirebase!= null)
      {
        DatabaseReference userRef= FirebaseDatabase.instance.ref().child("drivers").child(userFirebase.uid);
        userRef.once().then((snap)
        {
          if(snap.snapshot.value!=null)
            {
              if((snap.snapshot.value as Map)["blockStatus"]=="no")
                {
                  //userName = (snap.snapshot.value as Map)["name"];
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> Dashboard()));
                }
              else
                {
                  FirebaseAuth.instance.signOut();
                  cMethods.displaySnackBar("You are Blocked. Contact Admin : 2019anubhavbhatnagar@gmail.com", context);
                }
            }
          else
            {
              FirebaseAuth.instance.signOut();
              cMethods.displaySnackBar("your record do not exist as a Driver", context);
            }
        });
      }

  }


  @override
  Widget build(BuildContext context)
  {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              const SizedBox(
                height: 60,
              ),

              Image.asset(""
                  "assets/images/uberexec.png",
                  width: 220,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Login as a Driver",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //text fields + button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Driver Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Driver Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    ElevatedButton(
                      onPressed: ()
                      {
                          checkIfNetworkIsAvaliable();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 80)
                      ),
                      child: const Text(
                          "Login"
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
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>SignUpScreen()));
                },
                child: const  Text(
                  "Don\'t have an Account? Register Here ",
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
