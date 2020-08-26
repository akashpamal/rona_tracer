import 'dart:core';
class Contact {
  int _id;
  int _their24HourContactCount;
  int _theirID;
  String _dateTime;

  Contact(this._their24HourContactCount, this._theirID, this._dateTime);

  Contact.withoutTime(this._their24HourContactCount, this._theirID) {
    this._dateTime = DateTime.now().toString();
  }

  Contact.withId(this._id, this._their24HourContactCount, this._theirID, this._dateTime);

  int get id => _id;
  int get their24HourContactCount => this._their24HourContactCount;
  int get theirID => this._theirID;
  String get dateTime => this._dateTime;

  set their24HourContactCount(int newContactCount) {
      this._their24HourContactCount = newContactCount;
  }

  set theirID(int theirNewID) {
      this._theirID = theirNewID;
  }

  set dateTime(String newDate) {
    this._dateTime = newDate;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['their_24_hour_contact_count'] = _their24HourContactCount;
    map['their_id'] = _theirID;
    map['date_time'] = _dateTime;

    return map;
  }

  Contact.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._their24HourContactCount = map['their_24_hour_contact_count'];
    this._theirID = map['their_id'];
    this._dateTime = map['date_time'];
  }

  @override
  String toString() {
    DateTime contactTime = DateTime.parse(this.dateTime);
    Duration elapsedTime = DateTime.now().difference(contactTime);

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitHours = twoDigits(elapsedTime.inHours.remainder(60));
    String twoDigitMinutes = twoDigits(elapsedTime.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(elapsedTime.inSeconds.remainder(60));

    return '$twoDigitHours hours, $twoDigitMinutes minutes, and $twoDigitSeconds seconds ago, you contacted $theirID. They contacted $their24HourContactCount people in the last 24 hours.';
  }

}