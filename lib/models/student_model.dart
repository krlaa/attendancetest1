import 'dart:collection';
import 'dart:convert';

class Student {
  Map attendance;
  String currentSecret;
  String name;
  String grade;
  Student({this.attendance, this.currentSecret, this.name, this.grade});

  Map<String, dynamic> toMap() {
    return {
      'attendance': attendance,
      'currentSecret': currentSecret,
      'name': name,
      'grade': grade,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      attendance: map['attendance'],
      currentSecret: map['currentSecret'],
      name: map['name'],
      grade: map['grade'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Student.fromJson(String source) =>
      Student.fromMap(json.decode(source));

  Student copyWith({
    Map attendance,
    String currentSecret,
    String name,
    String grade,
  }) {
    return Student(
      attendance: attendance ?? this.attendance,
      currentSecret: currentSecret ?? this.currentSecret,
      name: name ?? this.name,
      grade: grade ?? this.grade,
    );
  }

  @override
  String toString() {
    return 'Student(attendance: $attendance, currentSecret: $currentSecret, name: $name, grade: $grade)';
  }
}
