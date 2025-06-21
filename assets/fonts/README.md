# Poppins Font Installation

To complete the Poppins font setup, please download the following font files from Google Fonts and place them in this directory:

## Download Link:

https://fonts.google.com/specimen/Poppins

## Required Font Files:

1. `Poppins-Regular.ttf` (weight: 400)
2. `Poppins-Medium.ttf` (weight: 500)
3. `Poppins-SemiBold.ttf` (weight: 600)
4. `Poppins-Bold.ttf` (weight: 700)
5. `Poppins-Light.ttf` (weight: 300)
6. `Poppins-Italic.ttf` (style: italic)

## Instructions:

1. Go to https://fonts.google.com/specimen/Poppins
2. Click "Download family"
3. Extract the ZIP file
4. Copy the required .ttf files listed above to this directory
5. Run `flutter pub get` to refresh dependencies
6. Use the font in your app with: `fontFamily: 'Poppins'`

## Alternative Method:

You can also use the `google_fonts` package instead of downloading files:

1. Add `google_fonts: ^6.1.0` to your pubspec.yaml dependencies
2. Use it like: `GoogleFonts.poppins(textStyle: TextStyle(...))`
