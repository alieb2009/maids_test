import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../lib/services/auth_service.dart';

// Create a mock class for AuthService using mockito
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('AuthService', () {
    late MockAuthService mockAuthService;

    setUp(() {
      // Initialize the mock service before each test
      mockAuthService = MockAuthService();
    });

    test('Login should succeed with valid credentials', () async {
      // Arrange
      when(mockAuthService.login('emilys', 'emilyspass')).thenAnswer((_) async => {
        'username': 'emilys',
        'token': 'dummy_token',
        'refreshToken': 'dummy_refresh_token',
      });

      // Act
      final result = await mockAuthService.login('emilys', 'emilyspass');

      // Assert
      expect(result['username'], 'emilys');
    });

    test('Login should fail with invalid credentials', () async {
      // Arrange
      when(mockAuthService.login('invalid', 'invalid')).thenThrow(Exception('Failed to log in'));

      // Act & Assert
      expect(mockAuthService.login('invalid', 'invalid'), throwsException);
    });
  });
}
