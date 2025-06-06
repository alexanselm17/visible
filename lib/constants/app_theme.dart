import 'package:flutter/material.dart';
import 'package:visible/constants/colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData();
  //   useMaterial3: true,
  //   brightness: Brightness.light,
  //   primaryColor: AppColors.darkBlue,
  //   scaffoldBackgroundColor: AppColors.lightBackground,

  //   colorScheme: const ColorScheme.light(
  //     primary: AppColors.darkBlue,
  //     primaryContainer: AppColors.accentOrange,
  //     secondary: AppColors.accentOrange,
  //     secondaryContainer: AppColors.purpleButtonColor,
  //     tertiary: AppColors.purpleButtonColor,
  //     surface: AppColors.lightSurface,
  //     surfaceContainer: AppColors.lightCard,
  //     error: AppColors.errorRed,
  //     onPrimary: AppColors.pureWhite,
  //     onPrimaryContainer: AppColors.pureWhite,
  //     onSecondary: AppColors.pureWhite,
  //     onSecondaryContainer: AppColors.pureWhite,
  //     onTertiary: AppColors.pureWhite,
  //     onSurface: AppColors.lightTextPrimary,
  //     onSurfaceVariant: AppColors.lightTextSecondary,
  //     onError: AppColors.pureWhite,
  //     outline: AppColors.lightBorder,
  //     outlineVariant: AppColors.mediumGrey,
  //   ),

  //   // AppBar Theme
  //   appBarTheme: const AppBarTheme(
  //     backgroundColor: AppColors.pureWhite,
  //     foregroundColor: AppColors.primaryBlack,
  //     elevation: 0,
  //     surfaceTintColor: Colors.transparent,
  //     titleTextStyle: TextStyle(
  //       color: AppColors.primaryBlack,
  //       fontSize: 20,
  //       fontWeight: FontWeight.w600,
  //     ),
  //     iconTheme: IconThemeData(color: AppColors.primaryBlack),
  //     actionsIconTheme: IconThemeData(color: AppColors.primaryBlack),
  //   ),

  //   // Bottom Navigation Theme
  //   bottomNavigationBarTheme: const BottomNavigationBarThemeData(
  //     backgroundColor: AppColors.pureWhite,
  //     selectedItemColor: AppColors.accentOrange,
  //     unselectedItemColor: AppColors.mediumGrey,
  //     type: BottomNavigationBarType.fixed,
  //     elevation: 8,
  //   ),

  //   // Navigation Bar Theme (Material 3)
  //   navigationBarTheme: NavigationBarThemeData(
  //     backgroundColor: AppColors.pureWhite,
  //     indicatorColor: AppColors.accentOrange.withOpacity(0.2),
  //     labelTextStyle: WidgetStateProperty.resolveWith((states) {
  //       if (states.contains(WidgetState.selected)) {
  //         return const TextStyle(
  //           fontSize: 12,
  //           fontWeight: FontWeight.w600,
  //           color: AppColors.accentOrange,
  //         );
  //       }
  //       return const TextStyle(
  //         fontSize: 12,
  //         fontWeight: FontWeight.w500,
  //         color: AppColors.mediumGrey,
  //       );
  //     }),
  //     iconTheme: WidgetStateProperty.resolveWith((states) {
  //       if (states.contains(WidgetState.selected)) {
  //         return const IconThemeData(color: AppColors.accentOrange);
  //       }
  //       return const IconThemeData(color: AppColors.mediumGrey);
  //     }),
  //   ),

  //   // Button Themes
  //   elevatedButtonTheme: ElevatedButtonThemeData(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: AppColors.accentOrange,
  //       foregroundColor: AppColors.pureWhite,
  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       elevation: 2,
  //       shadowColor: AppColors.lightShadow,
  //       textStyle: const TextStyle(
  //         fontSize: 16,
  //         fontWeight: FontWeight.w600,
  //       ),
  //     ),
  //   ),

  //   filledButtonTheme: FilledButtonThemeData(
  //     style: FilledButton.styleFrom(
  //       backgroundColor: AppColors.purpleButtonColor,
  //       foregroundColor: AppColors.pureWhite,
  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //     ),
  //   ),

  //   outlinedButtonTheme: OutlinedButtonThemeData(
  //     style: OutlinedButton.styleFrom(
  //       foregroundColor: AppColors.darkBlue,
  //       side: const BorderSide(color: AppColors.darkBlue, width: 1.5),
  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //     ),
  //   ),

  //   textButtonTheme: TextButtonThemeData(
  //     style: TextButton.styleFrom(
  //       foregroundColor: AppColors.darkBlue,
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //     ),
  //   ),

  //   // Card Theme
  //   cardTheme: CardTheme(
  //     color: AppColors.lightCard,
  //     elevation: 2,
  //     shadowColor: AppColors.lightShadow,
  //     surfaceTintColor: Colors.transparent,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //   ),

  //   // Input Decoration Theme
  //   inputDecorationTheme: InputDecorationTheme(
  //     filled: true,
  //     fillColor: AppColors.pureWhite,
  //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     border: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(12),
  //       borderSide: const BorderSide(color: AppColors.lightBorder),
  //     ),
  //     enabledBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(12),
  //       borderSide: const BorderSide(color: AppColors.lightBorder),
  //     ),
  //     focusedBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(12),
  //       borderSide: const BorderSide(color: AppColors.accentOrange, width: 2),
  //     ),
  //     errorBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(12),
  //       borderSide: const BorderSide(color: AppColors.errorRed),
  //     ),
  //     focusedErrorBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(12),
  //       borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
  //     ),
  //     labelStyle: const TextStyle(color: AppColors.mediumGrey),
  //     hintStyle: const TextStyle(color: AppColors.mediumGrey),
  //   ),

  //   // Floating Action Button Theme
  //   // floatingActionButtonTheme: const FloatingActionButtonThemeData(
  //   //   backgroundColor: AppColors.accentOrange,
  //   //   foregroundColor: AppColors.pureWhite,
  //   //   elevation: 4,
  //   //   shape: CircleBorder(),
  //   // ),

  //   // Checkbox Theme
  //   checkboxTheme: CheckboxThemeData(
  //     fillColor: WidgetStateProperty.resolveWith((states) {
  //       if (states.contains(WidgetState.selected)) {
  //         return AppColors.accentOrange;
  //       }
  //       return AppColors.pureWhite;
  //     }),
  //     checkColor: WidgetStateProperty.all(AppColors.pureWhite),
  //     side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  //   ),

  //   // Radio Theme
  //   radioTheme: RadioThemeData(
  //     fillColor: WidgetStateProperty.resolveWith((states) {
  //       if (states.contains(WidgetState.selected)) {
  //         return AppColors.accentOrange;
  //       }
  //       return AppColors.mediumGrey;
  //     }),
  //   ),

  //   // Switch Theme
  //   switchTheme: SwitchThemeData(
  //     thumbColor: WidgetStateProperty.resolveWith((states) {
  //       if (states.contains(WidgetState.selected)) {
  //         return AppColors.accentOrange;
  //       }
  //       return AppColors.mediumGrey;
  //     }),
  //     trackColor: WidgetStateProperty.resolveWith((states) {
  //       if (states.contains(WidgetState.selected)) {
  //         return AppColors.accentOrange.withOpacity(0.5);
  //       }
  //       return AppColors.lightBorder;
  //     }),
  //   ),

  //   // Slider Theme
  //   sliderTheme: SliderThemeData(
  //     activeTrackColor: AppColors.accentOrange,
  //     inactiveTrackColor: AppColors.lightBorder,
  //     thumbColor: AppColors.accentOrange,
  //     overlayColor: AppColors.accentOrange.withOpacity(0.2),
  //   ),

  //   // Progress Indicator Theme
  //   progressIndicatorTheme: const ProgressIndicatorThemeData(
  //     color: AppColors.accentOrange,
  //     linearTrackColor: AppColors.lightBorder,
  //     circularTrackColor: AppColors.lightBorder,
  //   ),

  //   // Tab Bar Theme
  //   tabBarTheme: const TabBarTheme(
  //     labelColor: AppColors.accentOrange,
  //     unselectedLabelColor: AppColors.mediumGrey,
  //     indicatorColor: AppColors.accentOrange,
  //     indicatorSize: TabBarIndicatorSize.label,
  //   ),

  //   // Divider Theme
  //   dividerTheme: const DividerThemeData(
  //     color: AppColors.lightBorder,
  //     thickness: 1,
  //     space: 1,
  //   ),

  //   // ListTile Theme
  //   listTileTheme: const ListTileThemeData(
  //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //     titleTextStyle: TextStyle(
  //       color: AppColors.lightTextPrimary,
  //       fontSize: 16,
  //       fontWeight: FontWeight.w500,
  //     ),
  //     subtitleTextStyle: TextStyle(
  //       color: AppColors.lightTextSecondary,
  //       fontSize: 14,
  //     ),
  //   ),

  //   // Chip Theme
  //   chipTheme: ChipThemeData(
  //     backgroundColor: AppColors.lightGrey,
  //     selectedColor: AppColors.accentOrange.withOpacity(0.2),
  //     labelStyle: const TextStyle(color: AppColors.lightTextPrimary),
  //     side: const BorderSide(color: AppColors.lightBorder),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //   ),

  //   // BottomSheet Theme
  //   bottomSheetTheme: const BottomSheetThemeData(
  //     backgroundColor: AppColors.pureWhite,
  //     elevation: 8,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //   ),

  //   // Dialog Theme
  //   dialogTheme: const DialogTheme(
  //     backgroundColor: AppColors.pureWhite,
  //     elevation: 8,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.all(Radius.circular(16)),
  //     ),
  //     titleTextStyle: TextStyle(
  //       color: AppColors.lightTextPrimary,
  //       fontSize: 20,
  //       fontWeight: FontWeight.w600,
  //     ),
  //     contentTextStyle: TextStyle(
  //       color: AppColors.lightTextSecondary,
  //       fontSize: 16,
  //     ),
  //   ),

  //   // Snackbar Theme
  //   snackBarTheme: const SnackBarThemeData(
  //     backgroundColor: AppColors.primaryBlack,
  //     contentTextStyle: TextStyle(color: AppColors.pureWhite),
  //     actionTextColor: AppColors.accentOrange,
  //     behavior: SnackBarBehavior.floating,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.all(Radius.circular(8)),
  //     ),
  //   ),
  // );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.accentOrange,
    scaffoldBackgroundColor: AppColors.darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentOrange,
      primaryContainer: AppColors.darkBlue,
      secondary: AppColors.purpleButtonColor,
      secondaryContainer: AppColors.darkBlue,
      tertiary: AppColors.darkBlue,
      surface: AppColors.darkSurface,
      surfaceContainer: AppColors.darkCard,
      error: AppColors.errorRed,
      onPrimary: AppColors.pureWhite,
      onPrimaryContainer: AppColors.pureWhite,
      onSecondary: AppColors.pureWhite,
      onSecondaryContainer: AppColors.pureWhite,
      onTertiary: AppColors.pureWhite,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      onError: AppColors.pureWhite,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkGrey,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.pureWhite,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: AppColors.pureWhite,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.pureWhite),
      actionsIconTheme: IconThemeData(color: AppColors.pureWhite),
    ),

    // Bottom Navigation Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.accentOrange,
      unselectedItemColor: AppColors.mediumGrey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Navigation Bar Theme (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.accentOrange.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accentOrange,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.mediumGrey,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.accentOrange);
        }
        return const IconThemeData(color: AppColors.mediumGrey);
      }),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: AppColors.pureWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: AppColors.darkShadow,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.purpleButtonColor,
        foregroundColor: AppColors.pureWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentOrange,
        side: const BorderSide(color: AppColors.accentOrange, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentOrange,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.darkCard,
      elevation: 2,
      shadowColor: AppColors.darkShadow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.mediumGrey),
      hintStyle: const TextStyle(color: AppColors.mediumGrey),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentOrange,
      foregroundColor: AppColors.pureWhite,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentOrange;
        }
        return AppColors.darkSurface;
      }),
      checkColor: WidgetStateProperty.all(AppColors.pureWhite),
      side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentOrange;
        }
        return AppColors.mediumGrey;
      }),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentOrange;
        }
        return AppColors.mediumGrey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentOrange.withOpacity(0.5);
        }
        return AppColors.darkBorder;
      }),
    ),

    // Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.accentOrange,
      inactiveTrackColor: AppColors.darkBorder,
      thumbColor: AppColors.accentOrange,
      overlayColor: AppColors.accentOrange.withOpacity(0.2),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accentOrange,
      linearTrackColor: AppColors.darkBorder,
      circularTrackColor: AppColors.darkBorder,
    ),

    // Tab Bar Theme
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.accentOrange,
      unselectedLabelColor: AppColors.mediumGrey,
      indicatorColor: AppColors.accentOrange,
      indicatorSize: TabBarIndicatorSize.label,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
    ),

    // ListTile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.accentOrange.withOpacity(0.2),
      labelStyle: const TextStyle(color: AppColors.darkTextPrimary),
      side: const BorderSide(color: AppColors.darkBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // BottomSheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Dialog Theme
    dialogTheme: const DialogTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 16,
      ),
    ),

    // Snackbar Theme
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.darkCard,
      contentTextStyle: TextStyle(color: AppColors.pureWhite),
      actionTextColor: AppColors.accentOrange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  );
}
