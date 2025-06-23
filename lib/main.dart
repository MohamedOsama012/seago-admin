import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/authentication/auth_cubit.dart';
import 'package:sa7el/Cubit/bloc_observer.dart';
import 'package:sa7el/Cubit/malls/malls_cubit.dart';
import 'package:sa7el/controller/cashe/cashe_Helper.dart';
import 'package:sa7el/controller/dio/dio_helper.dart';
import 'package:sa7el/views/Authentication/login_page.dart';
import 'package:sa7el/views/Home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await CacheHelper.init();
  DioHelper.init();
  Widget? startWidget;
  // CacheHelper.removeData(key: 'token');
  final token = CacheHelper.getData(key: 'token');

  if (token != null) {
    startWidget = const HomeScreen();
  } else {
    startWidget = const LoginScreen();
  }
  runApp(MaterialCall(startWidget: startWidget));
}

class MaterialCall extends StatelessWidget {
  const MaterialCall({super.key, required this.startWidget});
  final Widget startWidget;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MallsCubit()),
        BlocProvider(create: (context) => VillageCubit()..getData()),
        BlocProvider(create: (context) => AuthenticationCubit()),
        BlocProvider(create: (context) => MallsCubit()..getData()),
        BlocProvider(create: (context) => VillageCubit()),
      ],
      child: MaterialApp(home: startWidget, debugShowCheckedModeBanner: false),
    );
  }
}
