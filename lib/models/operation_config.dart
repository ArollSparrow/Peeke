// lib/models/operation_config.dart
// Complete translation of OPERATION_CONFIG from operations.py

import 'package:flutter/material.dart';

/// Field types for operation forms
enum FieldType {
  text,
  time,
  floatNumber,
  dropdown,
}

/// Field definition for operation forms
class OperationField {
  final String id;
  final String label;
  final FieldType type;
  final List<String>? dropdownOptions;

  const OperationField({
    required this.id,
    required this.label,
    required this.type,
    this.dropdownOptions,
  });

  factory OperationField.fromList(List<dynamic> fieldData) {
    final id = fieldData[0] as String;
    final label = fieldData[1] as String;
    final typeStr = fieldData[2] as String;
    
    FieldType type;
    switch (typeStr) {
      case 'text':
        type = FieldType.text;
        break;
      case 'time':
        type = FieldType.time;
        break;
      case 'float':
        type = FieldType.floatNumber;
        break;
      case 'dropdown':
        type = FieldType.dropdown;
        break;
      default:
        type = FieldType.text;
    }
    
    List<String>? options;
    if (fieldData.length > 3 && fieldData[3] is List) {
      options = (fieldData[3] as List).cast<String>();
    }
    
    return OperationField(
      id: id,
      label: label,
      type: type,
      dropdownOptions: options,
    );
  }
}

/// Operation mode configuration
class OperationMode {
  final String mode;
  final List<OperationField> fields;

  const OperationMode({
    required this.mode,
    required this.fields,
  });
}

/// Complete operation type configuration
class OperationType {
  final String key;
  final String name;
  final List<String> modes;
  final IconData icon;
  final Color color;
  final Map<String, List<OperationField>> fields;

  const OperationType({
    required this.key,
    required this.name,
    required this.modes,
    required this.icon,
    required this.color,
    required this.fields,
  });
}

/// Complete operation configuration - equivalent to OPERATION_CONFIG
class OperationConfig {
  static final Map<String, OperationType> operations = {
    'gen_pump': OperationType(
      key: 'gen_pump',
      name: 'Generator - Pumping',
      modes: ['start', 'stop'],
      icon: Icons.settings,
      color: const Color(0xFF33B333),
      fields: {
        'start': [
          OperationField(
            id: 'start_time',
            label: 'Start Time',
            type: FieldType.time,
          ),
          OperationField(
            id: 'bh_attendant',
            label: 'Attendant',
            type: FieldType.text,
          ),
          OperationField(
            id: 'hour_meter',
            label: 'Gen Hour Meter (Hrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'p_meter',
            label: 'Gen Power Meter (kWHrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'w_meter',
            label: 'Water Flow Meter (M³)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'status',
            label: 'Status',
            type: FieldType.dropdown,
            dropdownOptions: ['Normal', 'Faulty'],
          ),
        ],
        'stop': [
          OperationField(
            id: 'stop_time',
            label: 'Stop Time',
            type: FieldType.time,
          ),
          OperationField(
            id: 'bh_attendant',
            label: 'Attendant',
            type: FieldType.text,
          ),
          OperationField(
            id: 'hour_meter',
            label: 'Gen Hour Meter (Hrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'p_meter',
            label: 'Gen Power Meter (kWHrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'w_meter',
            label: 'Water Flow Meter (M³)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'status',
            label: 'Status',
            type: FieldType.dropdown,
            dropdownOptions: ['Normal', 'Faulty'],
          ),
        ],
      },
    ),
    
    'solar_pump': OperationType(
      key: 'solar_pump',
      name: 'Solar - Pumping',
      modes: ['start', 'stop'],
      icon: Icons.wb_sunny,
      color: const Color(0xFFE6B31A),
      fields: {
        'start': [
          OperationField(
            id: 'start_time',
            label: 'Start Time',
            type: FieldType.time,
          ),
          OperationField(
            id: 'bh_attendant',
            label: 'Attendant',
            type: FieldType.text,
          ),
          OperationField(
            id: 'pi_hour_meter',
            label: 'Pump Inv Hour Meter (Hrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'pi_p_meter',
            label: 'Pump Inv Power Meter (kWHrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'w_meter',
            label: 'Flow Meter (M³)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'status',
            label: 'Status',
            type: FieldType.dropdown,
            dropdownOptions: ['Normal', 'Faulty'],
          ),
        ],
        'stop': [
          OperationField(
            id: 'stop_time',
            label: 'Stop Time',
            type: FieldType.time,
          ),
          OperationField(
            id: 'bh_attendant',
            label: 'Attendant',
            type: FieldType.text,
          ),
          OperationField(
            id: 'pi_hour_meter',
            label: 'Pump Inv Hour Meter (Hrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'pi_p_meter',
            label: 'Power Meter (kWHrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'w_meter',
            label: 'Water Flow Meter (M³)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'status',
            label: 'Status',
            type: FieldType.dropdown,
            dropdownOptions: ['Normal', 'Faulty'],
          ),
        ],
      },
    ),
    
    'gen_utility': OperationType(
      key: 'gen_utility',
      name: 'Generator - Power Utility',
      modes: ['start', 'stop'],
      icon: Icons.bolt,
      color: const Color(0xFFCC4D4D),
      fields: {
        'start': [
          OperationField(
            id: 'start_time',
            label: 'Start Time',
            type: FieldType.time,
          ),
          OperationField(
            id: 'utils_attendant',
            label: 'Attendant',
            type: FieldType.text,
          ),
          OperationField(
            id: 'hour_meter',
            label: 'Hour Meter (Hrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'p_meter',
            label: 'Power Meter (kWHrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'status',
            label: 'Status',
            type: FieldType.dropdown,
            dropdownOptions: ['Normal', 'Faulty'],
          ),
        ],
        'stop': [
          OperationField(
            id: 'stop_time',
            label: 'Stop Time',
            type: FieldType.time,
          ),
          OperationField(
            id: 'utils_attendant',
            label: 'Attendant',
            type: FieldType.text,
          ),
          OperationField(
            id: 'hour_meter',
            label: 'Hour Meter (Hrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'p_meter',
            label: 'Power Meter (kWHrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'status',
            label: 'Status',
            type: FieldType.dropdown,
            dropdownOptions: ['Normal', 'Faulty'],
          ),
        ],
      },
    ),
    
    'pv_utility': OperationType(
      key: 'pv_utility',
      name: 'PV Inverter - Power Utility',
      modes: ['single'],
      icon: Icons.solar_power,
      color: const Color(0xFF4D99E6),
      fields: {
        'single': [
          OperationField(
            id: 'utils_attendant',
            label: 'Attendant',
            type: FieldType.text,
          ),
          OperationField(
            id: 'start_time',
            label: 'Start Time',
            type: FieldType.time,
          ),
          OperationField(
            id: 'stop_time',
            label: 'Stop Time',
            type: FieldType.time,
          ),
          OperationField(
            id: 'start_hour_meter',
            label: 'Start Hour Meter (Hrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'stop_hour_meter',
            label: 'Stop Hour Meter (Hrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'start_pv_meter',
            label: 'Start PV Meter (kWHrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'stop_pv_meter',
            label: 'Stop PV Meter (kWHrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'status',
            label: 'Status',
            type: FieldType.dropdown,
            dropdownOptions: ['Normal', 'Faulty'],
          ),
        ],
      },
    ),
    
    'gen_fueling': OperationType(
      key: 'gen_fueling',
      name: 'Generator - Fueling',
      modes: ['single'],
      icon: Icons.local_gas_station,
      color: const Color(0xFF9966CC),
      fields: {
        'single': [
          OperationField(
            id: 'fuel_attendant',
            label: 'Fuel Attendant',
            type: FieldType.text,
          ),
          OperationField(
            id: 'last_hour_meter',
            label: 'Last Hour Meter (Hrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'current_hour_meter',
            label: 'Current Hour Meter (Hrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'current_p_meter',
            label: 'Current Power Meter (kWHrs)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'fuel_added',
            label: 'Fuel Added (L)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'fuel_capacity',
            label: 'Fuel Capacity (L)',
            type: FieldType.floatNumber,
          ),
          OperationField(
            id: 'consumption',
            label: 'Consumption (L/Hr)',
            type: FieldType.floatNumber,
          ),
        ],
      },
    ),
  };
  
  /// Get all operation types as a list
  static List<OperationType> getAll() {
    return operations.values.toList();
  }
  
  /// Get operation type by key
  static OperationType? getByKey(String key) {
    return operations[key];
  }
  
  /// Get fields for specific operation and mode
  static List<OperationField>? getFields(String operationKey, String mode) {
    return operations[operationKey]?.fields[mode];
  }
}
