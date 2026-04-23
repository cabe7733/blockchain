import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Servicio de autenticación con Firebase Auth.
/// Maneja registro, inicio de sesión, cierre de sesión y recuperación de contraseña.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actualmente autenticado
  User? get currentUser => _auth.currentUser;

  /// Inicia sesión con email y contraseña.
  /// Lanza [String] con mensaje de error en español si falla.
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e.code);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  /// Registra un nuevo usuario y crea su documento en Firestore.
  Future<User> register({
    required String name,
    required String company,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;

      // Actualizar displayName en Firebase Auth
      await user.updateDisplayName(name.trim());

      // Guardar datos adicionales en Firestore
      final userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        company: company.trim(),
        email: email.trim(),
        role: UserRole.viewer, // Rol por defecto: viewer
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e.code);
    } catch (e) {
      throw 'Error al registrar usuario: $e';
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Envía email de recuperación de contraseña.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e.code);
    }
  }

  /// Obtiene el [UserModel] del usuario actual desde Firestore.
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(uid, doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Traduce códigos de error de Firebase Auth a mensajes en español.
  String _translateAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'invalid-email':
        return 'El formato del correo no es válido';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
