import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/config/splash/splash.dart';
import 'package:flutter_application_1/logic/cubits/settings/cubit/settings_cubit.dart';
import 'package:flutter_application_1/logic/cubits/settings/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/bookmark_repository.dart';
import 'data/repositories/highlight_repository.dart';
import 'core/utils/app_localizations.dart';
import 'logic/cubits/auth/auth_cubit.dart';
import 'logic/cubits/auth/auth_state.dart';
import 'logic/cubits/library/library_cubit.dart';
import 'logic/cubits/reader/reader_cubit.dart';
import 'presentation/screens/auth/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  final authService = AuthService(storageService);
  final bookmarkRepository = BookmarkRepository(storageService);
  final highlightRepository = HighlightRepository(storageService);

  runApp(
    MyApp(
      storageService: storageService,
      authService: authService,
      bookmarkRepository: bookmarkRepository,
      highlightRepository: highlightRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final AuthService authService;
  final BookmarkRepository bookmarkRepository;
  final HighlightRepository highlightRepository;

  const MyApp({
    super.key,
    required this.storageService,
    required this.authService,
    required this.bookmarkRepository,
    required this.highlightRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SettingsCubit(storageService)),
        BlocProvider(create: (context) => LibraryCubit(storageService)),
        BlocProvider(create: (context) => AuthCubit(authService)),
        BlocProvider(
          create: (context) => ReaderCubit(
            bookmarkRepository,
            highlightRepository,
            context.read<LibraryCubit>(),
          ),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.themeMode != current.themeMode ||
            previous.languageCode != current.languageCode,
        builder: (context, settingsState) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              return MaterialApp(
                title: 'Flutter Reader',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: settingsState.themeMode,
                locale: Locale(settingsState.languageCode),
                localizationsDelegates: const [
                  AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en', ''), Locale('fa', '')],
                home: authState.status == AuthStatus.locked
                    ? const LockScreen()
                    : const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
