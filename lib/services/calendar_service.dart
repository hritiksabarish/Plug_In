import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/event.dart';
import 'package:app/models/schedule_entry.dart';
import 'package:app/services/role_database_service.dart';

class CalendarService {
  final String _baseUrl = 'http://192.168.1.3:8080/api';

  Future<List<dynamic>> fetchAllCalendarItems() async {
    try {
      final eventsFuture = _fetchEvents();
      final scheduleFuture = _fetchSchedule();
      
      final results = await Future.wait([eventsFuture, scheduleFuture]);
      
      final allItems = <dynamic>[];
      allItems.addAll(results[0] as List<Event>);
      allItems.addAll(results[1] as List<ScheduleEntry>);
      
      return allItems;
    } catch (e) {
      print('Error fetching calendar items: $e');
      return [];
    }
  }

  Future<List<Event>> _fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/events'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
    return [];
  }

  Future<List<ScheduleEntry>> _fetchSchedule() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/schedule'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ScheduleEntry.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching schedule: $e');
    }
    return [];
  }

  Future<bool> createScheduleEntry(ScheduleEntry entry) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(entry.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error creating schedule: $e');
      return false;
    }
  }
  
  Future<bool> deleteScheduleEntry(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/schedule/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    }
  }
}
