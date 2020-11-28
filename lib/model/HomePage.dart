import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:date_format/date_format.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _height;
  double _width;
  
  Map<DateTime, List> _events;
  List _selectedEvents;
  DateTime _currentSelectedDay;
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  String _setStartTime, _setEndTime;
  TimeOfDay _startTime, _endTime;
  String _hour, _minute, _time;

  CalendarController _calendarController;
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();
    _events = {
      // _selectedDay.subtract(Duration(days: 0)): [],
      // _selectedDay.add(Duration(days: 0)): [],
      _selectedDay: ['Event A0', 'Event B0', 'Event C0'],
    };

    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();
    _currentSelectedDay = _selectedDay;

    _startTimeController.text = '00 : 00';
    _endTimeController.text = '00 : 00';
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
      _currentSelectedDay = day;
    });
  }

  Future<Null> _selectStartTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        _startTime = picked;
        _hour = _startTime.hour.toString();
        _minute = _startTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _startTimeController.text = _time;
      });
  }

  Future<Null> _selectEndTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        _endTime = picked;
        _hour = _endTime.hour.toString();
        _minute = _endTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _endTimeController.text = _time;
      });
  }

  void _onAddButtonPressed() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Choose Start Time',
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5),
                ),
                InkWell(
                  onTap: () {
                    _selectStartTime(context);
                  },
                  child: Container(
                    width: _width / 1.7,
                    height: _height / 9,
                    margin: EdgeInsets.symmetric(vertical: 30),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child: TextFormField(
                      style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                      enabled: false,
                      keyboardType: TextInputType.text,
                      controller: _startTimeController,
                      onSaved: (String val) {
                        _setStartTime = val;
                      },
                      decoration: InputDecoration(
                          disabledBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          // labelText: 'Time',
                          contentPadding: EdgeInsets.only(top: 0.0)),
                    ),
                  ),
                ),
                Text(
                  'Choose End Time',
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5),
                ),
                InkWell(
                  onTap: () {
                    _selectEndTime(context);
                  },
                  child: Container(
                    width: _width / 1.7,
                    height: _height / 9,
                    margin: EdgeInsets.symmetric(vertical: 30),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child: TextFormField(
                      style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                      enabled: false,
                      keyboardType: TextInputType.text,
                      controller: _endTimeController,
                      onSaved: (String val) {
                        _setEndTime = val;
                      },
                      decoration: InputDecoration(
                          disabledBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          // labelText: 'Time',
                          contentPadding: EdgeInsets.only(top: 0.0)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text("Submitß"),
                    onPressed: () {
                      //todo
                    },
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      onDaySelected: _onDaySelected,
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.toString()),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildTableCalendar(),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddButtonPressed,
        child: Icon(Icons.add),
      ),
    );
  }
}
