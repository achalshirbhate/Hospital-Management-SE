// ignore_for_file: type=lint
// Hand-written mock — avoids build_runner dependency.
import 'package:mockito/mockito.dart';
import 'package:telepatient_app/models/user_model.dart';
import 'package:telepatient_app/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#login, [], {#email: email, #password: password}),
        returnValue: Future.value(UserModel(
            id: 0, fullName: '', email: '', role: '')),
        returnValueForMissingStub: Future.value(UserModel(
            id: 0, fullName: '', email: '', role: '')),
      ) as Future<UserModel>;

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(
            #register, [], {#fullName: fullName, #email: email, #password: password}),
        returnValue: Future.value(UserModel(
            id: 0, fullName: '', email: '', role: '')),
        returnValueForMissingStub: Future.value(UserModel(
            id: 0, fullName: '', email: '', role: '')),
      ) as Future<UserModel>;

  @override
  Future<void> forgotPassword(String email) =>
      super.noSuchMethod(
        Invocation.method(#forgotPassword, [email]),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> resetPasswordOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) =>
      super.noSuchMethod(
        Invocation.method(#resetPasswordOtp, [],
            {#email: email, #otp: otp, #newPassword: newPassword}),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> resetPasswordTemp({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) =>
      super.noSuchMethod(
        Invocation.method(#resetPasswordTemp, [], {
          #email: email,
          #currentPassword: currentPassword,
          #newPassword: newPassword,
        }),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;
}
