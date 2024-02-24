

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dynatrace_poc/constants.dart';
import 'package:flutter_dynatrace_poc/product_screen.dart';
import 'package:flutter_dynatrace_poc/profile_screen.dart';
import 'package:http/http.dart';

import 'package:dynatrace_flutter_plugin/dynatrace_flutter_plugin.dart';
import 'package:flutter/material.dart';




main() {

  Dynatrace().startWithoutWidget();
  runApp(MyApp());
 //Dynatrace().start(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynatrace Test App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => UndefinedView(
                name: settings.name!,
              )),
      initialRoute: Constants.HOME_NAV,
      routes: {
        Constants.HOME_NAV: (context) => MyHomePage(),
        Constants.TEST_NAV: (context) => TestNav(),
        Constants.PRODUCTPAGE_NAV: (context) => const ProductScreen(),
        Constants.PROFILEPAGE_NAV: (context) => const ProfileScreen(),
      },
      navigatorObservers: [DynatraceNavigationObserver()],
      home: MyHomePage(),
    );
  }
}

class TestNav extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FloatingActionButton(
          child: Icon(Icons.navigate_before),
          onPressed: () {
            Navigator.pushNamed(context, Constants.HOME_NAV);
          },
        ),
      ),
    );
  }
}

class UndefinedView extends StatelessWidget {
  final String? name;
  const UndefinedView({Key? key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text('No route defined here!'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var appBarText = new Text("Dynatrace Proof of Concept");
  static var _context;

  static Map<String, VoidCallback> actionsMap = {
    'Tag user': _tagUser,
    'Tag user1': _tagUser1,
    'Tag user2': _tagUser2,
    'Single Action': _singleAction,
    'Make Navigation': _makeNavigation,
    'Navigation to ProductPage': _makeProcutPageNavigation,
    'Navigation to ProfilePage': _makeProfilePageNavigation,
    'End Session': _endSession,
    'Start Session': _startSession,
    'Report crash': _reportCrash,
    'Web Action': _webAction,
    'Report values': _reportAll,
   'Force errors': _forceErrors,


    //'Sub Action': _subAction,
    // 'Web Action Override': _webActionOverrideHeader,
    // 'Web Action Full Manual': _webActionFullManualInstr,
        // 'Force errors': _forceErrors,
    // 'Report crash': _reportCrash,
    // 'Report crash exception': _reportCrashException,
    // 'Flush data': _flushData,
    
    // // 'End Session': _endSession,
    // 'setGpsLocation: Hawaii': _setGpsLocationHawaii,
    // 'User Privacy Options : All Off': _userPrivacyOptionsAllOff,
    // 'User Privacy Options : All On': _userPrivacyOptionsAllOn,
    // 'getUserPrivacyOptions': () async {
    //   UserPrivacyOptions options = await Dynatrace().getUserPrivacyOptions();
    //   print('User Privacy Options Crash:');
    //   print(options.crashReportingOptedIn);
    //   print('User Privacy Options Level:');
    //   print(options.dataCollectionLevel);
    // }
  };

  @override
  Widget build(BuildContext context) {
    _context = context;

    final ScrollController sController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: appBarText,
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
      ),
      body: Scrollbar(
        controller: sController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: sController,
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i = 0; i < actionsMap.keys.length; i++)
                  Container(
                    width: 280.0,
                    height: 60.0,
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: actionsMap.values.elementAt(i),
                      child: Text(actionsMap.keys.elementAt(i)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _makeNavigation() {
    Navigator.pushNamed(_context, Constants.TEST_NAV);
  }
  static void _makeProcutPageNavigation() {
    Navigator.pushNamed(_context, Constants.PRODUCTPAGE_NAV);
  }
  static void _makeProfilePageNavigation() {
    Navigator.pushNamed(_context, Constants.PROFILEPAGE_NAV);
  }

  static void _singleAction() {
    DynatraceRootAction myAction =
        Dynatrace().enterAction("MyButton tapped - Single Action");
    myAction.leaveAction();
  }

  static void _subAction() {
    DynatraceRootAction myAction =
        Dynatrace().enterAction("MyButton tapped - Sub Action");
    DynatraceAction mySubAction = myAction.enterAction("MyButton Sub Action");
    mySubAction.leaveAction();
    myAction.leaveAction();
  }

  static void _webAction() async {
    var client = Dynatrace().createHttpClient();
    var url = 'https://dynatrace.com';
    DynatraceRootAction webAction =
        Dynatrace().enterAction('Web Action - $url');

    try {
      await client.get(Uri.parse(url));
    } catch (error) {
      // insert error handling here
    } finally {
      client.close();
      webAction.leaveAction();
    }
  }

  static void _webActionOverrideHeader() async {
    HttpClient client = HttpClient();
    DynatraceRootAction action =
        Dynatrace().enterAction("MyButton tapped - Web Action Override");
    final request = await client.getUrl(Uri.parse('https://dynatrace.com'));
    request.headers.set(action.getRequestTagHeader(),
        await action.getRequestTag('https://dynatrace.com'));
    final response = await request.close();
    print(response);
    action.leaveAction();
  }

  static void _webActionFullManualInstr() async {
    HttpClient client = HttpClient();

    DynatraceRootAction action =
        Dynatrace().enterAction("MyButton tapped - Web Action Full Manual");
    WebRequestTiming timing =
        await action.createWebRequestTiming('https://dynatrace.com');

    final request = await client.getUrl(Uri.parse('https://dynatrace.com'));
    request.headers.add(timing.getRequestTagHeader(), timing.getRequestTag());
    timing.startWebRequestTiming();
    final response = await request.close();
    timing.stopWebRequestTiming(response.statusCode, response.reasonPhrase);
    print(response);
    action.leaveAction();
  }

  static void _reportAll() {
    DynatraceRootAction myAction =
    Dynatrace().enterAction("MyButton tapped - Report values");
    myAction.reportStringValue("ValueNameString", "ImportantValue");
    myAction.reportIntValue("ValueNameInt", 1234);
    myAction.reportDoubleValue("ValueNameDouble", 123.4567);
    myAction.reportEvent("ValueNameEvent");
    myAction.reportError("ValueNameError", 408);
    myAction.leaveAction();
  }

  static void _forceErrors() {
    String input = '12,34';
    double.parse(input);
  }

  static void _reportCrash() {
    Dynatrace().reportCrash(
        "FormatException", "Invalid Double", "WHOLE_STACKTRACE_AS_STRING");
  }

  static void _reportCrashException() {
    Dynatrace().reportCrashWithException(
        "FormatException",
        Exception(
            "FormatException, Invalid Double, WHOLE_STACKTRACE_AS_STRING"));
  }

  static void _flushData() {
    Dynatrace().flushEvents();
  }

  static void _tagUser() {
    Dynatrace().identifyUser("Bhuvaneshwari");
  }

  static void _tagUser1() {
    Dynatrace().identifyUser("Govindasamy");
  }

  static void _tagUser2() {
    Dynatrace().identifyUser("Mohamed Afzal Kasim");
  }

  static void _endSession() {
    Dynatrace().endSession();
  }

   static void _startSession() {
    Dynatrace().start(MyApp());
  }

  static void _setGpsLocationHawaii() {
    // set GPS coords to Hawaii
    Dynatrace().setGPSLocation(19, 155);
  }

  static void _userPrivacyOptionsAllOff() {
    Dynatrace().applyUserPrivacyOptions(
        UserPrivacyOptions(DataCollectionLevel.Off, false));
  }

  static void _userPrivacyOptionsAllOn() {
    Dynatrace().applyUserPrivacyOptions(
        UserPrivacyOptions(DataCollectionLevel.UserBehavior, true));
  }
}

