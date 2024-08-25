import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_template/firebase_options.dart';
import 'package:starter_template/injectable/injectable.config.dart';
import 'package:starter_template/services/web_service/cache_interceptor/cache_interceptor.dart';
import 'package:starter_template/utils/base_device_info/base_device_info_utils.dart';

final getIt = GetIt.instance;

@injectableInit
Future<void> configuration({required void Function() runApp}) async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await getIt.init();
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(kDebugMode ? false : true);
      FlutterError.onError = (errorDetails) => FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      getIt<Dio>().interceptors.add(PrettyDioLogger(responseBody: false));
      getIt<Dio>().interceptors.add(DioCacheInterceptor(options: cacheOption));
      getIt<Dio>().interceptors.add(RetryInterceptor(dio: getIt<Dio>()));
      runApp();
    },
    (error, stackTrace) => FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true),
    zoneSpecification: ZoneSpecification(
      handleUncaughtError: (Zone zone, ZoneDelegate delegate, Zone parent, Object error, StackTrace stackTrace) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
      },
    ),
  );
}

@module
abstract class RegisterModule {
  @singleton
  Dio dio() => Dio();

  String get baseUrl => const String.fromEnvironment('BASE_URL');

  @preResolve
  Future<SharedPreferences> prefs() => SharedPreferences.getInstance();

  @preResolve
  Future<Directory> temporaryDirectory() => getTemporaryDirectory();

  @preResolve
  Future<PackageInfo> packageInfo() => PackageInfo.fromPlatform();

  @preResolve
  Future<BaseDevice> deviceInfo() => BaseDeviceInfoUtils.baseDeviceInfo();

  @preResolve
  Future<FirebaseApp> initializeFireBase() {
    return Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
}
