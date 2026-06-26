1. Introduction to Styling in Flutter
In Flutter, "everything is a widget," and that includes the way you define your app's visual identity. Instead of
manually styling every individual button, text field, and app bar across dozens of screens, Flutter uses a
centralized Theme system.
At the core of this theme system is the handling of Color. With the introduction of Material Design 3 (MD3),
Flutter shifted from a static color palette to a dynamic, algorithm-driven system called Color Roles.

2. Working with Colors
Before understanding themes, you must understand how Flutter handles raw colors. Flutter represents colors
using the Color class, which takes a 32-bit integer representing Alpha, Red, Green, and Blue (ARGB).

The ARGB Hex Format
In web development, you might use #FF5733 . In Flutter, you replace the # with 0xFF (where FF is
100% opacity). So, `#FF5733` becomes Color(0xFFFF5733) .

The Built-in Palette
Flutter provides a built-in set of Material Design colors via the Colors class. You can access primary
swatches and their varying shades (from 50 to 900).

// Example of using static colors
Container(
color: Colors.blue, // The primary blue swatch
child: Text(
'Static Color',
style: TextStyle(color: Colors.blue[900]), // A dark shade of blue
),
);

Flutter Masterclass: Colors & Themes Page 1 of 5

3. Material Design 3 and Color Schemes
While static colors are easy to use, building a massive app with them leads to inconsistencies. MD3 solves
this with ColorScheme . Instead of picking 20 different colors for your app, you provide a single Seed Color,
and Flutter generates a complete, mathematically accessible palette.

4. Defining a Theme (ThemeData)
A Theme binds your ColorScheme, Typography, and Component behaviors into a single ThemeData object.
You pass this object to your root MaterialApp widget. Once defined, all Material widgets automatically
inherit these rules.
Color Role Purpose Example Use Case
Primary High-emphasis elements. Floating Action Buttons, active states.
OnPrimary Text/icons that sit on top of Primary. Text inside a primary-colored button.
Secondary Less prominent components. Filter chips, selection controls.
Surface Backgrounds of elements. The background of a Card or a BottomSheet.
Error Destructive or invalid states. Text field borders when validation fails.

Flutter Masterclass: Colors & Themes Page 2 of 5

import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
const MyApp({super.key});
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Theme Demo',
// Enable Light Mode Theme
theme: ThemeData(
useMaterial3: true,
// 1. Define the Global Color Palette
colorScheme: ColorScheme.fromSeed(
seedColor: const Color(0xFF6200EE), // Deep Purple
brightness: Brightness.light,
),
// 2. Define Global Typography
textTheme: const TextTheme(
displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
),
// 3. Override Specific Widget Behaviors
appBarTheme: const AppBarTheme(
centerTitle: true,
elevation: 0,
),
),
home: const HomeScreen(),
);
}
}

5. Implementing Dark Mode
Supporting dark mode in Flutter is incredibly simple when using `ThemeData` and `ColorScheme`. You create
a second `ThemeData` object specifically for dark mode and assign it to the darkTheme property of
MaterialApp .

Flutter Masterclass: Colors & Themes Page 3 of 5

MaterialApp(
theme: lightThemeData, // Your light theme setup
darkTheme: ThemeData(
useMaterial3: true,
colorScheme: ColorScheme.fromSeed(
seedColor: const Color(0xFF6200EE),
brightness: Brightness.dark, // Generates a dark tonal palette
),
),
// Automatically switches based on iOS/Android system settings
themeMode: ThemeMode.system,
);

6. Accessing the Theme in Widgets
The true power of themes comes from consuming them in your custom widgets. Instead of hardcoding colors
deep in your UI tree, you request the current theme using Theme.of(context) .
By doing this, your custom widgets will automatically recolor themselves instantly when the user switches
between light and dark modes!

class CustomCard extends StatelessWidget {
const CustomCard({super.key});
@override
Widget build(BuildContext context) {
// Retrieve the active theme for the current context
final theme = Theme.of(context);
return Container(
padding: const EdgeInsets.all(16.0),
// Use the theme's surface color for the background
color: theme.colorScheme.surfaceContainer,
child: Text(
'Dynamic Theming is Awesome!',
// Use the theme's typography and color it dynamically
style: theme.textTheme.bodyLarge?.copyWith(
color: theme.colorScheme.onSurface,
),
),
);
}
}

Flutter Masterclass: Colors & Themes Page 4 of 5

Best Practice: Avoid Hardcoded Colors
If you find yourself writing Colors.grey[300] or Color(0xFFE0E0E0) inside a standard screen
widget, step back. Ask yourself: "What semantic role does this color play?" Usually, you should be using
Theme.of(context).colorScheme.outlineVariant or surfaceContainerHighest instead. This
ensures your app remains adaptable and accessible.