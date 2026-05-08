import 'data.dart';

class Slot {
  String dept = '';
  int section = 0 , room = 0;
  String subject = '';
  String teacher = '';
  bool isEmpty = true;

  void clear(){
    dept = '';
    section = 0;
    room = 0;
    subject = '';
    isEmpty = true;
    teacher = '';
  }
  void removeteacher(){
    teacher = '';
  }
}

class Timetable {
  List<List<Slot>> slot = List.generate(totaldays,
        (_) => List.generate(totalslots, (_) => Slot()),
  );

  String dept = '';
  int section = 0;

 void clearData(){
    for (int i = 0; i < totaldays; i++) {
      for (int j = 0; j < totalslots; j++) {
        slot[i][j].clear();
      }
    }
    dept = '';
    section = 0;
  }
  void removeTeacher() {
    for (int i = 0; i < totaldays; i++) {
      for (int j = 0; j < totalslots; j++) {
        slot[i][j].removeteacher();
      }
    }
  }
}
