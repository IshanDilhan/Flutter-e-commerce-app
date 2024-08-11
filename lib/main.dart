import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:myapp/providers/car_list_provider.dart';
import 'package:myapp/providers/payment_provider.dart';
import 'package:myapp/providers/profile_provider.dart';
import 'package:myapp/providers/user_cars_provider.dart';
import 'package:myapp/screens/Sign_In_Pages/splash_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env['PUBLISHABLE_KEY']!;
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => UserInfoProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => CarProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => CarListProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => PaymentProvider(),
    )
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
