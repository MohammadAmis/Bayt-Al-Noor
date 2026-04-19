import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<AuthState> supabaseAuthState(Ref ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
}

@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(supabaseAuthStateProvider).value;
  return authState?.session?.user ?? Supabase.instance.client.auth.currentUser;
}

@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(currentUserProvider) != null;
}
