import 'package:flutter_test/flutter_test.dart';
import 'package:rit_erp/services/data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('exportAllData then importAllData restores data', () async {
    final dataService = DataService.instance;

    // Insert some dummy data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('test_key', 'test_value');
    await prefs.setBool('test_bool', true);
    await prefs.setInt('test_int', 42);

    // Export
    final json = await dataService.exportAllData();
    expect(json, isNotEmpty);
    expect(json, contains('test_key'));

    // Clear prefs
    await prefs.clear();

    // Import
    final count = await dataService.importAllData(json);
    expect(count, greaterThan(0));

    // Verify data restored
    final restoredPrefs = await SharedPreferences.getInstance();
    expect(restoredPrefs.getString('test_key'), 'test_value');
    expect(restoredPrefs.getBool('test_bool'), true);
    expect(restoredPrefs.getInt('test_int'), 42);
  });
}