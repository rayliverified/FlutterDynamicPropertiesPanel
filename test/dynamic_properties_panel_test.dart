import 'package:dynamic_properties_panel/dynamic_properties_panel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses enum and object properties', () {
    final props = DynamicPropertyDefinition.listFromJson([
      {
        'name': 'variant',
        'type': 'String',
        'enumValues': ['primary', 'secondary'],
      },
      {
        'name': 'layout',
        'type': 'object',
        'properties': {
          'padding': {'type': 'int'},
        },
      },
    ]);

    expect(props, hasLength(2));
    expect(props.first.kind, DynamicPropertyKind.enumValue);
    expect(props.last.kind, DynamicPropertyKind.object);
    expect(props.last.properties, isNotNull);
    expect(props.last.properties!.first.name, 'padding');
  });

  test('infers widget list and map property kinds', () {
    final props = DynamicPropertyDefinition.listFromJson([
      {'name': 'children', 'type': 'List<Widget>'},
      {'name': 'attributes', 'type': 'Map<String, dynamic>'},
      {
        'name': 'audiences',
        'type': 'List<String>',
        'multiSelect': true,
        'enumValues': ['a', 'b'],
      },
    ]);

    expect(props, hasLength(3));
    expect(props[0].kind, DynamicPropertyKind.widgetList);
    expect(props[1].kind, DynamicPropertyKind.map);
    expect(props[2].kind, DynamicPropertyKind.multiEnum);
  });
}
