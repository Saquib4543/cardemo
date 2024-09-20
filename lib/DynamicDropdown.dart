import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DynamicDropdown extends StatefulWidget {
  @override
  _DynamicDropdownState createState() => _DynamicDropdownState();
}

class _DynamicDropdownState extends State<DynamicDropdown> {
  Map<String, List<String>> carData = {};
  List<String> policyMakes = [];
  List<String> models = [];
  String? selectedPolicyMake;
  String? selectedModel;

  // New variables for the accident types dropdown
  List<Map<String, dynamic>> categories = [];
  String? selectedAccidentType;

  // Color scheme
  static const Color primaryColor = Color(0xFF3F51B5);  // Indigo
  static const Color accentColor = Color(0xFFFFA726);   // Orange
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light grey

  @override
  void initState() {
    super.initState();
    loadJsonData();
    loadAccidentData();
  }

  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/file.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    setState(() {
      carData = Map.from(jsonData.map((key, value) => MapEntry(key,
          (value as List).map((item) => item.toString()).toList())));
      policyMakes = carData.keys.toList();
    });
  }

  Future<void> loadAccidentData() async {
    String jsonString = await rootBundle.loadString('assets/Coa.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    setState(() {
      categories = List<Map<String, dynamic>>.from(jsonData['categories']);
    });
  }

  void filterModels(String policyMake) {
    setState(() {
      models = carData[policyMake] ?? [];
      selectedModel = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Vehicle and Accident Type', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Container(
        color: backgroundColor,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDropdown(
                    hint: 'Select Company',
                    value: selectedPolicyMake,
                    items: policyMakes,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPolicyMake = newValue;
                        if (newValue != null) {
                          filterModels(newValue);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildDropdown(
                    hint: 'Select Model',
                    value: selectedModel,
                    items: models,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedModel = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildGroupedDropdown(
                    hint: 'Select Accident Type',
                    value: selectedAccidentType,
                    groupedItems: categories,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAccidentType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton(
                    onPressed: _onConfirmSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm Selection',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Text(hint, style: TextStyle(color: primaryColor.withOpacity(0.6))),
            value: value,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: primaryColor),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: primaryColor, fontSize: 16),
            dropdownColor: Colors.white,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedDropdown({
    required String hint,
    required String? value,
    required List<Map<String, dynamic>> groupedItems,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Text(hint, style: TextStyle(color: primaryColor.withOpacity(0.6))),
            value: value,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: primaryColor),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: primaryColor, fontSize: 16),
            dropdownColor: Colors.white,
            items: groupedItems.expand((category) {
              return [
                DropdownMenuItem<String>(
                  enabled: false,
                  child: Text(
                    category['name'] as String,
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                ),
                ...(category['types'] as List<dynamic>).map<DropdownMenuItem<String>>((type) =>
                    DropdownMenuItem<String>(
                      value: type as String,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(type as String),
                      ),
                    )
                ),
              ];
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  void _onConfirmSelection() {
    if (selectedPolicyMake != null && selectedModel != null && selectedAccidentType != null) {
      Navigator.pushNamed(
        context,
        '/upload',
        arguments: {
          'make': selectedPolicyMake,
          'model': selectedModel,
          'accidentType': selectedAccidentType,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected: $selectedPolicyMake - $selectedModel\nAccident Type: $selectedAccidentType'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}