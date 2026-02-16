/// Αρχείο δοκιμών widget για την εφαρμογή Smart Gallery
///
/// Περιέχει βασικές δοκιμές Flutter widgets (smoke tests).
/// Χρησιμοποιεί το WidgetTester για αλληλεπίδραση με widgets,
/// αναζήτηση child widgets στο widget tree και επαλήθευση τιμών.
///
/// Σημείωση: Οι τρέχουσες δοκιμές είναι προεπιλογή Flutter και
/// ενδέχεται να χρειάζονται προσαρμογή για την Smart Gallery.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smartgallery/main.dart';

void main() {
  // Δοκιμή smoke για την εφαρμογή - έλεγχος ότι το MyApp φορτώνει
  testWidgets('Η εφαρμογή φορτώνει χωρίς σφάλματα', (WidgetTester tester) async {
    // Κατασκευή της εφαρμογής και ενεργοποίηση ενός frame
    await tester.pumpWidget(const MyApp());

    // Έλεγχος ότι η εφαρμογή εμφανίζει το MainNavigation (με κάμερα ή home)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
