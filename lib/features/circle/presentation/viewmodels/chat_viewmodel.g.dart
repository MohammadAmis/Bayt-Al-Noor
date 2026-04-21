// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatViewModelHash() => r'c4cc232a112d01bced11cc509107e5ef152a93a9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChatViewModel extends BuildlessAutoDisposeNotifier<ChatState> {
  late final String chatId;
  late final String? chatName;
  late final ProfileEntity? initialProfile;

  ChatState build(
    String chatId, {
    String? chatName,
    ProfileEntity? initialProfile,
  });
}

/// See also [ChatViewModel].
@ProviderFor(ChatViewModel)
const chatViewModelProvider = ChatViewModelFamily();

/// See also [ChatViewModel].
class ChatViewModelFamily extends Family<ChatState> {
  /// See also [ChatViewModel].
  const ChatViewModelFamily();

  /// See also [ChatViewModel].
  ChatViewModelProvider call(
    String chatId, {
    String? chatName,
    ProfileEntity? initialProfile,
  }) {
    return ChatViewModelProvider(
      chatId,
      chatName: chatName,
      initialProfile: initialProfile,
    );
  }

  @override
  ChatViewModelProvider getProviderOverride(
    covariant ChatViewModelProvider provider,
  ) {
    return call(
      provider.chatId,
      chatName: provider.chatName,
      initialProfile: provider.initialProfile,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatViewModelProvider';
}

/// See also [ChatViewModel].
class ChatViewModelProvider
    extends AutoDisposeNotifierProviderImpl<ChatViewModel, ChatState> {
  /// See also [ChatViewModel].
  ChatViewModelProvider(
    String chatId, {
    String? chatName,
    ProfileEntity? initialProfile,
  }) : this._internal(
          () => ChatViewModel()
            ..chatId = chatId
            ..chatName = chatName
            ..initialProfile = initialProfile,
          from: chatViewModelProvider,
          name: r'chatViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatViewModelHash,
          dependencies: ChatViewModelFamily._dependencies,
          allTransitiveDependencies:
              ChatViewModelFamily._allTransitiveDependencies,
          chatId: chatId,
          chatName: chatName,
          initialProfile: initialProfile,
        );

  ChatViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
    required this.chatName,
    required this.initialProfile,
  }) : super.internal();

  final String chatId;
  final String? chatName;
  final ProfileEntity? initialProfile;

  @override
  ChatState runNotifierBuild(
    covariant ChatViewModel notifier,
  ) {
    return notifier.build(
      chatId,
      chatName: chatName,
      initialProfile: initialProfile,
    );
  }

  @override
  Override overrideWith(ChatViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatViewModelProvider._internal(
        () => create()
          ..chatId = chatId
          ..chatName = chatName
          ..initialProfile = initialProfile,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
        chatName: chatName,
        initialProfile: initialProfile,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ChatViewModel, ChatState> createElement() {
    return _ChatViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatViewModelProvider &&
        other.chatId == chatId &&
        other.chatName == chatName &&
        other.initialProfile == initialProfile;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);
    hash = _SystemHash.combine(hash, chatName.hashCode);
    hash = _SystemHash.combine(hash, initialProfile.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatViewModelRef on AutoDisposeNotifierProviderRef<ChatState> {
  /// The parameter `chatId` of this provider.
  String get chatId;

  /// The parameter `chatName` of this provider.
  String? get chatName;

  /// The parameter `initialProfile` of this provider.
  ProfileEntity? get initialProfile;
}

class _ChatViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<ChatViewModel, ChatState>
    with ChatViewModelRef {
  _ChatViewModelProviderElement(super.provider);

  @override
  String get chatId => (origin as ChatViewModelProvider).chatId;
  @override
  String? get chatName => (origin as ChatViewModelProvider).chatName;
  @override
  ProfileEntity? get initialProfile =>
      (origin as ChatViewModelProvider).initialProfile;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
