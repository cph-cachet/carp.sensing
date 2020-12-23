/*
 * Copyright 2020 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
part of carp_services;

class CarpAuthenticationForm extends StatefulWidget {
  final String username;
  CarpAuthenticationForm({this.username});
  _CarpAuthenticationFormState createState() =>
      _CarpAuthenticationFormState(username: username);
}

class _CarpAuthenticationFormState extends State<CarpAuthenticationForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final String username;

  _CarpAuthenticationFormState({this.username});

  // String validatePassword(String value) {
  //   if (value.isEmpty) {
  //     return "* Required";
  //   } else if (value.length < 6) {
  //     return "Password should be atleast 6 characters";
  //   } else if (value.length > 15) {
  //     return "Password should not be greater than 15 characters";
  //   } else
  //     return null;
  // }

  bool get _isEntryIsValid {
    print('validate() = ${_formkey.currentState?.validate()}');
    return true;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("CARP Login"),
      ),
      body: SingleChildScrollView(
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formkey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Center(
                  child: Container(
                      //width: 300,
                      height: 150,
                      child: Image.asset(
                        'asset/images/carp_logo_small.png',
                        package: 'carp_webservices',
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                    initialValue: username,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'Enter valid email id as abc@cachet.dk'),
                    validator: MultiValidator([
                      RequiredValidator(errorText: "* Required"),
                      EmailValidator(errorText: "Enter valid email."),
                    ])),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        hintText: 'Enter password'),
                    validator: MultiValidator([
                      RequiredValidator(errorText: "* Required"),
                      MinLengthValidator(6,
                          errorText: "Password should be atleast 6 characters"),
                      MaxLengthValidator(15,
                          errorText:
                              "Password should not be greater than 15 characters")
                    ])
                    //validatePassword,        //Function to check validation
                    ),
              ),
              TextButton(
                onPressed: () {
                  //TODO FORGOT PASSWORD SCREEN GOES HERE
                },
                child: Text(
                  'Forgot Password',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.blue, borderRadius: BorderRadius.circular(5)),
                child: TextButton(
                  onPressed: (_isEntryIsValid)
                      ? () {
                          if (_formkey.currentState.validate()) {
                            print("Trying to authenticate....");
                            //TODO - try authentication
                          }
                          Navigator.pop(context);
                        }
                      : null,
                  child: Text(
                    'LOGIN',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                    width: 200,
                    //height: 150,
                    child: Image.asset(
                      'asset/images/cachet_logo.png',
                      package: 'carp_webservices',
                    )),
              ),
              //Text('CACHET Research Platform (CARP)')
            ],
          ),
        ),
      ),
    );
  }
}