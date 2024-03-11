import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';


void main() async {
  runApp(ExpenseTrackerApp());
}
// 129638651997-9js0p8j9j0nitgoabs2md2qvtio9v8b5.apps.googleusercontent.com
class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExpenseTrackerHome(),
    );
  }
}

class ExpenseTrackerHome extends StatefulWidget {
  @override
  _ExpenseTrackerHomeState createState() => _ExpenseTrackerHomeState();
}

class _ExpenseTrackerHomeState extends State<ExpenseTrackerHome> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _amountController = TextEditingController();
  TextEditingController _paymentModeController = TextEditingController();
  TextEditingController _paidToController = TextEditingController();
  TextEditingController _reasonController = TextEditingController();


  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/drive.file',
        'https://www.googleapis.com/auth/spreadsheets'
      ]
  );

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  void _checkIfLoggedIn() {
    setState(() {
      _isLoggedIn = _googleSignIn.currentUser != null;
    });
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      _checkIfLoggedIn();
      print("Logged In");
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _googleSignIn.disconnect();
      _checkIfLoggedIn();
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Tracker',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: !_isLoggedIn  ?
        ElevatedButton(
          onPressed: _handleSignIn,
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          ),
          child: Text('Sign in to Google'),
        )
            :SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Expense',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount Spent in INR',
                    hintText: '500',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount spent.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _paymentModeController,
                  decoration: InputDecoration(
                    labelText: 'Mode of Payment',
                    hintText: 'E.g Apple Pay, UPI or Cash',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _paidToController,
                  decoration: InputDecoration(
                    labelText: 'Paid To',
                    hintText: 'E.g Amazon',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    hintText: 'E.g Shoes',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Save data to Google Sheets
                                await submitDataToGoogleSheet();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 32.0),
                            ),
                            child: Text('Submit Spendings to Sheets'),
                          ),
                          ElevatedButton(
                            onPressed: _handleSignOut,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 32.0),
                            ),
                            child: Text('Logout'),
                          ),
                        ],
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }




    // Future<void> signIn() async {
    //   try{
        // final scopes = [
        //   'email',
        //   'https://www.googleapis.com/auth/drive.file',
        //   'https://www.googleapis.com/auth/spreadsheets'
        // ];
        //
        // GoogleSignIn googleSignIn = GoogleSignIn(
        //   clientId:
        //   "129638651997-9js0p8j9j0nitgoabs2md2qvtio9v8b5.apps.googleusercontent.com.apps.googleusercontent.com",
        //   scopes: scopes
        // );


        // if ( kIsWeb ||Platform.isAndroid ) {
        //    googleSignIn = GoogleSignIn(
        //       clientId:
        //       "129638651997-9js0p8j9j0nitgoabs2md2qvtio9v8b5.apps.googleusercontent.com.apps.googleusercontent.com",
        //       scopes: scopes
        //   );
        // }

        //IOS
        // if (Platform.isIOS || Platform.isMacOS) {
        //   final googleSignIn = GoogleSignIn(
        //     clientId:
        //     "YOUR_CLIENT_ID.apps.googleusercontent.com",
        //     scopes: [
        //       'email',
        //     ],
        //   );
        // }

      //   final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
      //   final GoogleSignInAuthentication  = await googleAccount!.authentication;
      //   print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxxx");
      //   print(GoogleSignInAuthentication);
      //   print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxxx");
      //
      // }catch (e) {
      //   print('Error submitting data to Google Sheet: $e');
      //   // Handle any errors that occur during the submission
    //   }
    // }

  Future<String> createSpreadsheet(sheets.SheetsApi sheetsApi) async {
    final spreadsheet = sheets.Spreadsheet.fromJson({
      'properties': {
        'title': 'My Spendings',
      },
      'sheets': [
        {
          'properties': {
            'title': 'Sheet1',
          },
          'data': [
            {
              'rowData': [
                {
                  'values': [
                    {'userEnteredValue': {'stringValue': 'Amount'}},
                    {'userEnteredValue': {'stringValue': 'Mode of Payment'}},
                    {'userEnteredValue': {'stringValue': 'Paid To'}},
                    {'userEnteredValue': {'stringValue': 'Reason'}},
                    {'userEnteredValue': {'stringValue': 'Date and Time'}}, // Added field for date and time
                  ],
                },
              ],
            },
          ],
        },
      ],
    });
    final createdSpreadsheet = await sheetsApi.spreadsheets.create(spreadsheet);
    return createdSpreadsheet.spreadsheetId!;
  }


  Future<void> submitDataToGoogleSheet() async {
    try {
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      //
      // final client = http.Client();
      var httpClient = (await _googleSignIn.authenticatedClient());
      final sheetsApi = await sheets.SheetsApi(httpClient!);


      final spreadsheetId = await createSpreadsheet(sheetsApi);
      print(spreadsheetId);

      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      final values = [
        [ _amountController.text,  _paymentModeController.text,
          _paidToController.text, _reasonController.text,
          formattedDate
        ],
      ];

      final range = 'Sheet1!A1:E1'; // Updated range to include date and time

      final requestBody = sheets.ValueRange()..values = values;

      await sheetsApi.spreadsheets.values.append(
        requestBody,
        spreadsheetId,
        range,
        valueInputOption: 'RAW',
      );

      httpClient.close();
    }catch (e) {
          print('Error submitting data to Google Sheet: $e');
          // Handle any errors that occur during the submission
        }

    }


}

