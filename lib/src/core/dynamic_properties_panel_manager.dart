import 'component_registry.dart';
import 'icon_registry.dart';
import 'navigation_controller.dart';

/// Global manager for the dynamic properties panel ecosystem.
///
/// Holds the shared instances of:
/// - [NavigationController] — nested property drill-in navigation
/// - [IconRegistry] — named icon lookup for icon pickers
/// - [ComponentRegistry] — project component listing for slot pickers
///
/// A default global [instance] is provided for convenience. Consumers
/// can also create custom instances when isolation is needed (e.g. tests).
///
/// ```dart
/// // Use the global instance (auto-initialized with Material icons)
/// final manager = DynamicPropertiesPanelManager.instance;
/// manager.iconRegistry.register('my_icon', Icons.ac_unit);
/// manager.componentRegistry.register(ComponentInfo(id: 'btn', name: 'Button'));
///
/// // Observe navigation
/// manager.navigationController.addListener(() {
///   print('Navigated to: ${manager.navigationController.currentLevel}');
/// });
///
/// // Create a scoped instance (e.g. for testing)
/// final testManager = DynamicPropertiesPanelManager();
/// ```
class DynamicPropertiesPanelManager {
  /// The shared global instance.
  static final DynamicPropertiesPanelManager instance =
      DynamicPropertiesPanelManager._default();

  /// Navigation controller for nested property drill-in.
  final NavigationController navigationController;

  /// Icon registry for icon picker controls.
  final IconRegistry iconRegistry;

  /// Component registry for widget slot picker controls.
  final ComponentRegistry componentRegistry;

  DynamicPropertiesPanelManager._default()
    : navigationController = NavigationController(),
      iconRegistry = IconRegistry.withMaterialDefaults(),
      componentRegistry = ComponentRegistry();

  /// Create a custom manager with optional overrides.
  ///
  /// Any parameter not provided gets a fresh default instance.
  DynamicPropertiesPanelManager({
    NavigationController? navigationController,
    IconRegistry? iconRegistry,
    ComponentRegistry? componentRegistry,
  }) : navigationController = navigationController ?? NavigationController(),
       iconRegistry = iconRegistry ?? IconRegistry(),
       componentRegistry = componentRegistry ?? ComponentRegistry();
}
