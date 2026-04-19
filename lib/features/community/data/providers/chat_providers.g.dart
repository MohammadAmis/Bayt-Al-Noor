// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatRepositoryHash() => r'ca32eabb7b3c4142b258fc42f8a0d92c6ebfb3c8';

/// See also [chatRepository].
@ProviderFor(chatRepository)
final chatRepositoryProvider = Provider<ChatRepository>.internal(
  chatRepository,
  name: r'chatRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatRepositoryRef = ProviderRef<ChatRepository>;
String _$chatListHash() => r'9fa6c56bf5077f635398ee2c5837d05846f9245c';

/// See also [chatList].
@ProviderFor(chatList)
final chatListProvider = StreamProvider<List<ChatEntity>>.internal(
  chatList,
  name: r'chatListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$chatListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatListRef = StreamProviderRef<List<ChatEntity>>;
String _$profileListHash() => r'df692bbb03fed2e72d7b69c96bd4f99178699d69';

/// See also [profileList].
@ProviderFor(profileList)
final profileListProvider = FutureProvider<List<ProfileEntity>>.internal(
  profileList,
  name: r'profileListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$profileListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileListRef = FutureProviderRef<List<ProfileEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
