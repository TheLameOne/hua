import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/poppins_text_styles.dart';

/// Example page demonstrating how to use Poppins fonts
class PoppinsFontExample extends StatelessWidget {
  const PoppinsFontExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Poppins Font Examples',
          style: PoppinsTextStyles.h3,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Method 1: Using PoppinsTextStyles helper class
            Text(
              'Method 1: Using PoppinsTextStyles',
              style: PoppinsTextStyles.h4,
            ),
            const SizedBox(height: 16),

            Text('Heading 1', style: PoppinsTextStyles.h1),
            Text('Heading 2', style: PoppinsTextStyles.h2),
            Text('Heading 3', style: PoppinsTextStyles.h3),
            Text('Body Large', style: PoppinsTextStyles.bodyLarge),
            Text('Body Medium', style: PoppinsTextStyles.bodyMedium),
            Text('Body Small', style: PoppinsTextStyles.bodySmall),
            Text('Light Weight', style: PoppinsTextStyles.light),
            Text('Medium Weight', style: PoppinsTextStyles.medium),
            Text('Semi Bold', style: PoppinsTextStyles.semiBold),
            Text('Bold Weight', style: PoppinsTextStyles.bold),

            const SizedBox(height: 32),

            // Method 2: Using GoogleFonts directly
            Text(
              'Method 2: Using GoogleFonts directly',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'This is Poppins Regular',
              style: GoogleFonts.poppins(),
            ),
            Text(
              'This is Poppins Medium',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'This is Poppins Bold',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'This is Poppins with custom size and color',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 32),

            // Method 3: Using extension
            Text(
              'Method 3: Using extension on TextStyle',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'This uses the extension',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
              ).poppins,
            ),

            const SizedBox(height: 32),

            // Method 4: Theme's default (automatically Poppins)
            Text(
              'Method 4: Using Theme\'s default text styles',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'This uses Theme.of(context).textTheme.headlineMedium',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'This uses Theme.of(context).textTheme.bodyLarge',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'This uses Theme.of(context).textTheme.bodyMedium',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 32),

            // Button examples
            ElevatedButton(
              onPressed: () {},
              child: Text('Button with Poppins'),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () {},
              child: Text(
                'Outlined Button',
                style: PoppinsTextStyles.button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
