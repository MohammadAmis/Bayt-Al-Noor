// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resourceViewModelHash() => r'a550dff80f76f5a3a01d374a9789d6ef2d51fd5d';

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

abstract class _$ResourceViewModel
    extends BuildlessAutoDisposeNotifier<ResourceState> {
  late final String chatId;

  ResourceState build(
    String chatId,
  );
}

/// See also [ResourceViewModel].
@ProviderFor(ResourceViewModel)
const resourceViewModelProvider = ResourceViewModelFamily();

/// See also [ResourceViewModel].
class ResourceViewModelFamily extends Family<ResourceState> {
  /// See also [ResourceViewModel].
  const ResourceViewModelFamily();

  /// See also [ResourceViewModel].
  ResourceViewModelProvider call(
    String chatId,
  ) {
    return ResourceViewModelProvider(
      chatId,
    );
  }

  @override
  ResourceViewModelProvider getProviderOverride(
    covariant ResourceViewModelProvider provider,
  ) {
    return call(
      provider.chatId,
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
  String? get name => r'resourceViewModelProvider';
}

/// See also [ResourceViewModel].
class ResourceViewModelProvider
    extends AutoDisposeNotifierProviderImpl<ResourceViewModel, ResourceState> {
  /// See also [ResourceViewModel].
  ResourceViewModelProvider(
    String chatId,
  ) : this._internal(
          () => ResourceViewModel()..chatId = chatId,
          from: resourceViewModelProvider,
          name: r'resourceViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$resourceViewModelHash,
          dependencies: ResourceViewModelFamily._dependencies,
          allTransitiveDependencies:
              ResourceViewModelFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  ResourceViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final String chatId;

  @override
  ResourceState runNotifierBuild(
    covariant ResourceViewModel notifier,
  ) {
    return notifier.build(
      chatId,
    );
  }

  @override
  Override overrideWith(ResourceViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ResourceViewModelProvider._internal(
        () => create()..chatId = chatId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ResourceViewModel, ResourceState>
      createElement() {
    return _ResourceViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ResourceViewModelProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ResourceViewModelRef on AutoDisposeNotifierProviderRef<ResourceState> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _ResourceViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<ResourceViewModel, ResourceState>
    with ResourceViewModelRef {
  _ResourceViewModelProviderElement(super.provider);

  @override
  String get chatId => (origin as ResourceViewModelProvider).chatId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
