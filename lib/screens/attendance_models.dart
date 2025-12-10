// This file holds the "single source of truth" for your data models.
// Both the AttendanceScreen and AttendanceRecordsScreen will import this.

class Member {
  final String name;
  bool isPresent;

  Member({required this.name, this.isPresent = false});

  // Helper method for deep copying the member state upon submission
  Member copyWith({String? name, bool? isPresent}) {
    return Member(
      name: name ?? this.name,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}

class AttendanceRecord {
  final DateTime date;
  final List<Member> members;

  AttendanceRecord({required this.date, required this.members});

  // Computed properties for convenience
  List<Member> get presentMembers => members.where((m) => m.isPresent).toList();
  List<Member> get absentMembers => members.where((m) => !m.isPresent).toList();

  String get status {
    if (presentMembers.length == members.length) {
      return 'All Present';
    } else if (absentMembers.length == members.length) {
      return 'All Absent';
    } else if (presentMembers.isNotEmpty) {
      return 'Partial';
    } else {
      return 'No Records'; // Should ideally not happen if members list is not empty
    }
  }
}