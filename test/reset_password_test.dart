import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocaller/schoolAdmin/ResetPassword.dart';

// ✅ Manual fake class for FirebaseAuth (no build_runner needed)
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    print('Mock: Password reset link sent to $email');
  }
}

/* void main() {
  testWidgets('Reset Password UI validation test', (WidgetTester tester) async {
    final fakeAuth = FakeFirebaseAuth();

    await tester.pumpWidget(MaterialApp(
      home: ResetPasswordPage(auth: fakeAuth),
    ));

    final emailField = find.byKey(const Key('email_field'));
    final resetButton = find.byKey(const Key('reset_password'));

    // Test 1: empty email
    await tester.tap(resetButton);
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);

    // Test 2: invalid email
    await tester.enterText(emailField, 'invalidemail');
    await tester.tap(resetButton);
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsOneWidget);

    // Test 3: email with space
    await tester.enterText(emailField, 'email with space@gmail.com');
    await tester.tap(resetButton);
    await tester.pump();
    expect(find.text('Spaces are not allowed in emails.'), findsOneWidget);

    // Test 4: valid email
    await tester.enterText(emailField, 'test@example.com');
    await tester.tap(resetButton);
    await tester.pump();
    expect(find.text('Password reset link sent to your email!'), findsOneWidget);
  });
} */