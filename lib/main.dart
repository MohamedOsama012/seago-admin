import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/authentication/auth_cubit.dart';
import 'package:sa7el/Cubit/bloc_observer.dart';
import 'package:sa7el/Cubit/maintenance_providers/maintenance_cubit.dart';
import 'package:sa7el/Cubit/malls/malls_cubit.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_cubit.dart';
import 'package:sa7el/controller/cashe/cashe_Helper.dart';
import 'package:sa7el/controller/dio/dio_helper.dart';
import 'package:sa7el/views/Authentication/login_page.dart';
import 'package:sa7el/views/Home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  Bloc.observer = MyBlocObserver();
  DioHelper.init();
  Widget? startWidget;
  // CacheHelper.removeData(key: 'token');
  final token = CacheHelper.getData(key: 'token');
  log(token.toString());

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
        BlocProvider(create: (context) => VillageCubit()..getData()),
        BlocProvider(create: (context) => AuthenticationCubit()),
        BlocProvider(create: (context) => MallsCubit()..getData()),
        BlocProvider(create: (context) => ServiceProviderCubit()..getData()),
        BlocProvider(create: (context) => MaintenanceCubit()..getData()),
      ],
      child: MaterialApp(home: startWidget, debugShowCheckedModeBanner: false),
    );
  }
}
