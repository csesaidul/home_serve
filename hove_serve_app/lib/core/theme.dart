import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff0f6681),
      surfaceTint: Color(0xff0f6681),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffbce9ff),
      onPrimaryContainer: Color(0xff004d63),
      secondary: Color(0xff0c6780),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffbaeaff),
      onSecondaryContainer: Color(0xff004d62),
      tertiary: Color(0xff805611),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffddb4),
      onTertiaryContainer: Color(0xff633f00),
      error: Color(0xff904a43),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad5),
      onErrorContainer: Color(0xff73342d),
      surface: Color(0xfff7f9ff),
      onSurface: Color(0xff181c20),
      onSurfaceVariant: Color(0xff41484d),
      outline: Color(0xff71787e),
      outlineVariant: Color(0xffc1c7ce),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3135),
      inversePrimary: Color(0xff8ad0ee),
      primaryFixed: Color(0xffbce9ff),
      onPrimaryFixed: Color(0xff001f29),
      primaryFixedDim: Color(0xff8ad0ee),
      onPrimaryFixedVariant: Color(0xff004d63),
      secondaryFixed: Color(0xffbaeaff),
      onSecondaryFixed: Color(0xff001f29),
      secondaryFixedDim: Color(0xff89d0ed),
      onSecondaryFixedVariant: Color(0xff004d62),
      tertiaryFixed: Color(0xffffddb4),
      onTertiaryFixed: Color(0xff291800),
      tertiaryFixedDim: Color(0xfff5bc6f),
      onTertiaryFixedVariant: Color(0xff633f00),
      surfaceDim: Color(0xffd7dadf),
      surfaceBright: Color(0xfff7f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f4f9),
      surfaceContainer: Color(0xffebeef3),
      surfaceContainerHigh: Color(0xffe5e8ed),
      surfaceContainerHighest: Color(0xffe0e3e8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003b4d),
      surfaceTint: Color(0xff0f6681),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff287591),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003b4c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff277590),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4d3000),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff916420),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff5e231e),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffa25850),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff7f9ff),
      onSurface: Color(0xff0e1215),
      onSurfaceVariant: Color(0xff30373c),
      outline: Color(0xff4d5359),
      outlineVariant: Color(0xff676e74),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3135),
      inversePrimary: Color(0xff8ad0ee),
      primaryFixed: Color(0xff287591),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff005c76),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff277590),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff005c75),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff916420),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff754c05),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc3c7cc),
      surfaceBright: Color(0xfff7f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f4f9),
      surfaceContainer: Color(0xffe5e8ed),
      surfaceContainerHigh: Color(0xffdadde2),
      surfaceContainerHighest: Color(0xffcfd2d7),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00313f),
      surfaceTint: Color(0xff0f6681),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff005066),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff00313f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff005065),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff402700),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff664100),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff511a15),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff76362f),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff7f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff262d32),
      outlineVariant: Color(0xff434a4f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3135),
      inversePrimary: Color(0xff8ad0ee),
      primaryFixed: Color(0xff005066),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003848),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff005065),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff003848),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff664100),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff482d00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb6b9be),
      surfaceBright: Color(0xfff7f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeef1f6),
      surfaceContainer: Color(0xffe0e3e8),
      surfaceContainerHigh: Color(0xffd1d5da),
      surfaceContainerHighest: Color(0xffc3c7cc),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff8ad0ee),
      surfaceTint: Color(0xff8ad0ee),
      onPrimary: Color(0xff003545),
      primaryContainer: Color(0xff004d63),
      onPrimaryContainer: Color(0xffbce9ff),
      secondary: Color(0xff89d0ed),
      onSecondary: Color(0xff003545),
      secondaryContainer: Color(0xff004d62),
      onSecondaryContainer: Color(0xffbaeaff),
      tertiary: Color(0xfff5bc6f),
      onTertiary: Color(0xff452b00),
      tertiaryContainer: Color(0xff633f00),
      onTertiaryContainer: Color(0xffffddb4),
      error: Color(0xffffb4ab),
      onError: Color(0xff561e19),
      errorContainer: Color(0xff73342d),
      onErrorContainer: Color(0xffffdad5),
      surface: Color(0xff101417),
      onSurface: Color(0xffe0e3e8),
      onSurfaceVariant: Color(0xffc1c7ce),
      outline: Color(0xff8b9298),
      outlineVariant: Color(0xff41484d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e3e8),
      inversePrimary: Color(0xff0f6681),
      primaryFixed: Color(0xffbce9ff),
      onPrimaryFixed: Color(0xff001f29),
      primaryFixedDim: Color(0xff8ad0ee),
      onPrimaryFixedVariant: Color(0xff004d63),
      secondaryFixed: Color(0xffbaeaff),
      onSecondaryFixed: Color(0xff001f29),
      secondaryFixedDim: Color(0xff89d0ed),
      onSecondaryFixedVariant: Color(0xff004d62),
      tertiaryFixed: Color(0xffffddb4),
      onTertiaryFixed: Color(0xff291800),
      tertiaryFixedDim: Color(0xfff5bc6f),
      onTertiaryFixedVariant: Color(0xff633f00),
      surfaceDim: Color(0xff101417),
      surfaceBright: Color(0xff363a3e),
      surfaceContainerLowest: Color(0xff0b0f12),
      surfaceContainerLow: Color(0xff181c20),
      surfaceContainer: Color(0xff1c2024),
      surfaceContainerHigh: Color(0xff262a2e),
      surfaceContainerHighest: Color(0xff313539),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffabe5ff),
      surfaceTint: Color(0xff8ad0ee),
      onPrimary: Color(0xff002a37),
      primaryContainer: Color(0xff5299b6),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffa9e5ff),
      onSecondary: Color(0xff002a36),
      secondaryContainer: Color(0xff519ab5),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd5a2),
      onTertiary: Color(0xff372100),
      tertiaryContainer: Color(0xffb98740),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff48130f),
      errorContainer: Color(0xffcc7b72),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff101417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd7dde4),
      outline: Color(0xffacb3b9),
      outlineVariant: Color(0xff8a9197),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e3e8),
      inversePrimary: Color(0xff004e65),
      primaryFixed: Color(0xffbce9ff),
      onPrimaryFixed: Color(0xff00131b),
      primaryFixedDim: Color(0xff8ad0ee),
      onPrimaryFixedVariant: Color(0xff003b4d),
      secondaryFixed: Color(0xffbaeaff),
      onSecondaryFixed: Color(0xff00141b),
      secondaryFixedDim: Color(0xff89d0ed),
      onSecondaryFixedVariant: Color(0xff003b4c),
      tertiaryFixed: Color(0xffffddb4),
      onTertiaryFixed: Color(0xff1c0e00),
      tertiaryFixedDim: Color(0xfff5bc6f),
      onTertiaryFixedVariant: Color(0xff4d3000),
      surfaceDim: Color(0xff101417),
      surfaceBright: Color(0xff414549),
      surfaceContainerLowest: Color(0xff05080b),
      surfaceContainerLow: Color(0xff1a1e22),
      surfaceContainer: Color(0xff24282c),
      surfaceContainerHigh: Color(0xff2f3337),
      surfaceContainerHighest: Color(0xff3a3e42),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffddf3ff),
      surfaceTint: Color(0xff8ad0ee),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff86ccea),
      onPrimaryContainer: Color(0xff000d14),
      secondary: Color(0xffddf4ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff85cce9),
      onSecondaryContainer: Color(0xff000d13),
      tertiary: Color(0xffffeddb),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xfff1b86c),
      onTertiaryContainer: Color(0xff140900),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220000),
      surface: Color(0xff101417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeaf1f7),
      outlineVariant: Color(0xffbdc3ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e3e8),
      inversePrimary: Color(0xff004e65),
      primaryFixed: Color(0xffbce9ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff8ad0ee),
      onPrimaryFixedVariant: Color(0xff00131b),
      secondaryFixed: Color(0xffbaeaff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff89d0ed),
      onSecondaryFixedVariant: Color(0xff00141b),
      tertiaryFixed: Color(0xffffddb4),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfff5bc6f),
      onTertiaryFixedVariant: Color(0xff1c0e00),
      surfaceDim: Color(0xff101417),
      surfaceBright: Color(0xff4c5055),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1c2024),
      surfaceContainer: Color(0xff2d3135),
      surfaceContainerHigh: Color(0xff383c40),
      surfaceContainerHighest: Color(0xff43474b),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );

  /// success
  static const success = ExtendedColor(
    seed: Color(0xff2e7d53),
    value: Color(0xff2e7d53),
    light: ColorFamily(
      color: Color(0xff2a6a47),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffaef2c5),
      onColorContainer: Color(0xff0a5131),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff2a6a47),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffaef2c5),
      onColorContainer: Color(0xff0a5131),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff2a6a47),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffaef2c5),
      onColorContainer: Color(0xff0a5131),
    ),
    dark: ColorFamily(
      color: Color(0xff93d5aa),
      onColor: Color(0xff00391f),
      colorContainer: Color(0xff0a5131),
      onColorContainer: Color(0xffaef2c5),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff93d5aa),
      onColor: Color(0xff00391f),
      colorContainer: Color(0xff0a5131),
      onColorContainer: Color(0xffaef2c5),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff93d5aa),
      onColor: Color(0xff00391f),
      colorContainer: Color(0xff0a5131),
      onColorContainer: Color(0xffaef2c5),
    ),
  );

  /// warning
  static const warning = ExtendedColor(
    seed: Color(0xffc77800),
    value: Color(0xffc77800),
    light: ColorFamily(
      color: Color(0xff855317),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdcbc),
      onColorContainer: Color(0xff683c00),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff855317),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdcbc),
      onColorContainer: Color(0xff683c00),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff855317),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdcbc),
      onColorContainer: Color(0xff683c00),
    ),
    dark: ColorFamily(
      color: Color(0xfffbb974),
      onColor: Color(0xff492900),
      colorContainer: Color(0xff683c00),
      onColorContainer: Color(0xffffdcbc),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xfffbb974),
      onColor: Color(0xff492900),
      colorContainer: Color(0xff683c00),
      onColorContainer: Color(0xffffdcbc),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xfffbb974),
      onColor: Color(0xff492900),
      colorContainer: Color(0xff683c00),
      onColorContainer: Color(0xffffdcbc),
    ),
  );

  /// info
  static const info = ExtendedColor(
    seed: Color(0xff2f6fb5),
    value: Color(0xff2f6fb5),
    light: ColorFamily(
      color: Color(0xff3a608f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd3e3ff),
      onColorContainer: Color(0xff1f4876),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff3a608f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd3e3ff),
      onColorContainer: Color(0xff1f4876),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff3a608f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd3e3ff),
      onColorContainer: Color(0xff1f4876),
    ),
    dark: ColorFamily(
      color: Color(0xffa4c9fe),
      onColor: Color(0xff00315c),
      colorContainer: Color(0xff1f4876),
      onColorContainer: Color(0xffd3e3ff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffa4c9fe),
      onColor: Color(0xff00315c),
      colorContainer: Color(0xff1f4876),
      onColorContainer: Color(0xffd3e3ff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffa4c9fe),
      onColor: Color(0xff00315c),
      colorContainer: Color(0xff1f4876),
      onColorContainer: Color(0xffd3e3ff),
    ),
  );

  /// verified
  static const verified = ExtendedColor(
    seed: Color(0xff00897b),
    value: Color(0xff00897b),
    light: ColorFamily(
      color: Color(0xff006b5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff9ef2e3),
      onColorContainer: Color(0xff005048),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff006b5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff9ef2e3),
      onColorContainer: Color(0xff005048),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff006b5f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff9ef2e3),
      onColorContainer: Color(0xff005048),
    ),
    dark: ColorFamily(
      color: Color(0xff82d5c7),
      onColor: Color(0xff003731),
      colorContainer: Color(0xff005048),
      onColorContainer: Color(0xff9ef2e3),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff82d5c7),
      onColor: Color(0xff003731),
      colorContainer: Color(0xff005048),
      onColorContainer: Color(0xff9ef2e3),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff82d5c7),
      onColor: Color(0xff003731),
      colorContainer: Color(0xff005048),
      onColorContainer: Color(0xff9ef2e3),
    ),
  );

  /// ratingStar
  static const ratingStar = ExtendedColor(
    seed: Color(0xffffb300),
    value: Color(0xffffb300),
    light: ColorFamily(
      color: Color(0xff7d570d),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdeac),
      onColorContainer: Color(0xff604100),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff7d570d),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdeac),
      onColorContainer: Color(0xff604100),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff7d570d),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffdeac),
      onColorContainer: Color(0xff604100),
    ),
    dark: ColorFamily(
      color: Color(0xfff0be6d),
      onColor: Color(0xff432c00),
      colorContainer: Color(0xff604100),
      onColorContainer: Color(0xffffdeac),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xfff0be6d),
      onColor: Color(0xff432c00),
      colorContainer: Color(0xff604100),
      onColorContainer: Color(0xffffdeac),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xfff0be6d),
      onColor: Color(0xff432c00),
      colorContainer: Color(0xff604100),
      onColorContainer: Color(0xffffdeac),
    ),
  );

  /// online
  static const online = ExtendedColor(
    seed: Color(0xff43a047),
    value: Color(0xff43a047),
    light: ColorFamily(
      color: Color(0xff3b6939),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffbcf0b4),
      onColorContainer: Color(0xff235024),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff3b6939),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffbcf0b4),
      onColorContainer: Color(0xff235024),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff3b6939),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffbcf0b4),
      onColorContainer: Color(0xff235024),
    ),
    dark: ColorFamily(
      color: Color(0xffa1d39a),
      onColor: Color(0xff0a390f),
      colorContainer: Color(0xff235024),
      onColorContainer: Color(0xffbcf0b4),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffa1d39a),
      onColor: Color(0xff0a390f),
      colorContainer: Color(0xff235024),
      onColorContainer: Color(0xffbcf0b4),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffa1d39a),
      onColor: Color(0xff0a390f),
      colorContainer: Color(0xff235024),
      onColorContainer: Color(0xffbcf0b4),
    ),
  );


  List<ExtendedColor> get extendedColors => [
    success,
    warning,
    info,
    verified,
    ratingStar,
    online,
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
