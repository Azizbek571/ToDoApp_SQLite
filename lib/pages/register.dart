import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/app_textfield.dart';
import '../widgets/dialogs.dart';
// import 'package:sqlite_provider_starter/widgets/app_textfield.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late TextEditingController usernameController;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple, Colors.blue],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30.0),
                      child: Text(
                        'Register User',
                        style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w200,
                            color: Colors.white),
                      ),
                    ),
                    Focus(
                      onFocusChange: (value) async {
                        if (!value) {
                          String result = await context
                              .read<UserService>()
                              .checkifUserExists(
                                  usernameController.text.trim());
                                  if (result == 'OK'){
                                    context.read<UserService>().userExists = true;
                                  }
                                  else{
                                    context.read<UserService>().userExists = false;
                                    if (result.contains('The user does not exist in the database. Please register first.')){
                                      showSnackBar(context, result);
                                    }
                                  }
                        }
                      },
                      child: AppTextField(
                        controller: usernameController,
                        labelText: 'Please enter your username',
                      ),
                    ),
                    Selector<UserService, bool>(
                      selector: (context, value) => value.userExists,
                      builder: (context, value, child) {
                        return value ? Text(
                        'username exists, please choose another',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w800),
                      ): Container();
                      },
                    ),
                    AppTextField(
                      controller: nameController,
                      labelText: 'Please enter your name',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple),
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (usernameController.text.isEmpty ||
                              nameController.text.isEmpty) {
                            showSnackBar(context, 'Please emter all fields');
                          } else {
                            User user = User(
                                username: usernameController.text.trim(),
                                name: nameController.text.trim());
                            String result = await context
                                .read<UserService>()
                                .createUser(user);
                            if (result != 'OK') {
                              showSnackBar(context, result);
                            } else {
                              showSnackBar(
                                  context, 'New user succesfully created!');
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 30,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          Selector<UserService,bool>(
            selector: (context, value) => value.busyCreate,
            builder: (context, value, child) {
            return value ? AppProgressIndicator() : Container();
          })
        ],
      ),
    );
  }
}

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white.withOpacity(0.5),
      child: const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.purple,
          ),
        ),
      ),
    );
  }
}
