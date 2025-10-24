import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const PhonicApp());
}

class PhonicApp extends StatelessWidget {
  const PhonicApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1A1B1E);
    final lightScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    final darkScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF8F9BFF),
      onPrimary: Color(0xFF060606),
      primaryContainer: Color(0xFF181924),
      onPrimaryContainer: Color(0xFFE0E3FF),
      secondary: Color(0xFF7A82A2),
      onSecondary: Color(0xFF050506),
      secondaryContainer: Color(0xFF1D1E28),
      onSecondaryContainer: Color(0xFFD9DBEF),
      tertiary: Color(0xFF85E3D1),
      onTertiary: Color(0xFF001F17),
      tertiaryContainer: Color(0xFF14352D),
      onTertiaryContainer: Color(0xFFA5F5E3),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF000000),
      onSurface: Color(0xFFE5E6EC),
      surfaceTint: Color(0xFF8F9BFF),
      surfaceDim: Color(0xFF101114),
      surfaceBright: Color(0xFF1A1B1F),
      surfaceContainerLowest: Color(0xFF000000),
      surfaceContainerLow: Color(0xFF0E0F13),
      surfaceContainer: Color(0xFF111217),
      surfaceContainerHigh: Color(0xFF16171C),
      surfaceContainerHighest: Color(0xFF1E1F24),
      onSurfaceVariant: Color(0xFFB1B3C3),
      outline: Color(0xFF41434F),
      outlineVariant: Color(0xFF2B2D38),
      inverseSurface: Color(0xFFE5E6EC),
      onInverseSurface: Color(0xFF121317),
      inversePrimary: Color(0xFF3F47B5),
      shadow: Colors.black,
      scrim: Colors.black,
    );

    return MaterialApp(
      title: 'Phonic',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildTheme(lightScheme),
      darkTheme: _buildTheme(darkScheme),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.3),
        thickness: 0.5,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
      ),
      textTheme: Typography.englishLike2021.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
    );
    if (scheme.brightness == Brightness.dark) {
      return base.copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF0D0D0F),
        canvasColor: Colors.black,
        dialogTheme: base.dialogTheme.copyWith(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: base.navigationBarTheme.copyWith(
          backgroundColor: Colors.black,
          indicatorColor: scheme.primary.withValues(alpha: 0.18),
        ),
        dividerTheme: base.dividerTheme.copyWith(
          color: const Color(0xFF1F1F24),
        ),
      );
    }
    return base;
  }
}
