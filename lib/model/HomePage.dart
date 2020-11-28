import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'package:date_format/date_format.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _height;
  double _width;

  double _payRate = 0.00;
  String _currency = '\$';

  Map<DateTime, List> _events;
  List _selectedEvents;
  DateTime _currentSelectedDay;
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  double _timeDiff;
  String _setStartTime, _setEndTime;
  TimeOfDay _startTime, _endTime;
  String _hour, _minute, _time;
  int _timeDiffHour, _timeDiffMinute;

  bool _showInvalidTime = false;

  CalendarController _calendarController;
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _payRateController = TextEditingController();
  TextEditingController _currencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();

    // load previous data
    _events = {
      // _selectedDay.subtract(Duration(days: 0)): [],
      // _selectedDay.add(Duration(days: 0)): [],
    };

    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();
    // _currentSelectedDay = _selectedDay;

    _startTimeController.text = '00 : 00';
    _endTimeController.text = '00 : 00';
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    setState(() {
      _selectedEvents = events;
      _currentSelectedDay = day;
    });
    print('CALLBACK: _onDaySelected KEY:'+_currentSelectedDay.toString());
    print(_getWeek(_currentSelectedDay));
  }

  Future<Null> _selectStartTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        _startTime = picked;
        _hour = _startTime.hour.toString().length > 1
            ? _startTime.hour.toString()
            : '0' + _startTime.hour.toString();
        _minute = _startTime.minute.toString().length > 1
            ? _startTime.minute.toString()
            : '0' + _startTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _startTimeController.text = _time;
      });
  }

  Future<Null> _selectEndTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null)
      setState(() {
        _endTime = picked;
        _hour = _endTime.hour.toString().length > 1
            ? _endTime.hour.toString()
            : '0' + _endTime.hour.toString();
        _minute = _endTime.minute.toString().length > 1
            ? _endTime.minute.toString()
            : '0' + _endTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _endTimeController.text = _time;
      });
  }

  double _calculateTimeDifference(TimeOfDay start, TimeOfDay end) {
    double _doubleStart =
        start.hour.toDouble() + (start.minute.toDouble() / 60);
    double _doubleEnd = end.hour.toDouble() + (end.minute.toDouble() / 60);

    double _timeDiff = _doubleEnd - _doubleStart;

    _timeDiffHour = _timeDiff.truncate();
    _timeDiffMinute = ((_timeDiff - _timeDiff.truncate()) * 60).truncate();

    print(
        'Here your Happy $_timeDiffHour Hour and also $_timeDiffMinute min');
    return _timeDiff;
  }

  double _calculateWages(DateTime day){
    if(!_events.containsKey(day)){
      return 0.0;
    }
    double wage = 0.0;
    _events[day].forEach((element) {
      wage += element[0]*_payRate;
    });
    return wage;
  }

  List<DateTime> _getWeek(DateTime date){
    int day = date.weekday;
    List<DateTime> allDays = [];
    switch(day){
      case 7:
        for(int i = 0; i<7; i++){
          allDays += [date.add(Duration(days: i))];
        }
        break;
      case 6:
        for(int i = 0; i<7; i++){
          allDays += [date.subtract(Duration(days: i))];
        }
        break;
      default:
        DateTime sunday = date.subtract(Duration(days:day));
        for(int i = 0; i<7; i++){
          allDays += [sunday.add(Duration(days: i))];
        }
        break;
    }
    return allDays;
  }

  double _getWeeklySalary(DateTime date){
    final daysInWeek = _getWeek(date);
    double weeklySalary = 0.0;
    daysInWeek.forEach((day) {
      weeklySalary += _calculateWages(day);
    });
    return weeklySalary;
  }

  void _onAddButtonPressed() {
    print("CALLBACK: _onAddButtonPressed() KEY:"+_currentSelectedDay.toString());
    _startTimeController.text = '';
    _endTimeController.text = '';
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _currentSelectedDay.toString().split(" ")[0],
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5),
                  ),
                ),
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
                    margin: EdgeInsets.fromLTRB(0, 12, 0, 30),
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
                    margin: EdgeInsets.fromLTRB(0, 12, 0, 30),
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
                  padding: const EdgeInsets.all(0.0),
                  child: RaisedButton(
                    child: Text("Confirm"),
                    onPressed: () {
                      //todo
                      _timeDiff =
                          _calculateTimeDifference(_startTime, _endTime);
                      if (_timeDiff <= 0) {
                        setState(() {
                          _showInvalidTime = true;
                        });
                        print(_showInvalidTime);
                      } else {
                        Navigator.of(context).pop();
                        _confirmSave();
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _confirmSave() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm'),
            content: Text(
                'The total working hour is${_timeDiffHour > 0 ? " $_timeDiffHour hour(s)" : ""}${_timeDiffMinute > 0 ? " $_timeDiffMinute minute(s)" : ""} on ${_currentSelectedDay.toString().split(" ")[0]}.'),
            actions: [
              FlatButton(
                textColor: Color(0xFF6200EE),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('NO'),
              ),
              FlatButton(
                textColor: Color(0xFF6200EE),
                onPressed: () {
                  _saveToEvents();
                  Navigator.of(context).pop();
                },
                child: Text('YES'),
              ),
            ],
          );
        });
  }

  void _saveToEvents() {
    print("CALLBACK: _saveToEvents KEY:"+_currentSelectedDay.toString()+' EVENT_KEY'+_events[_currentSelectedDay].toString()+' ALL_EVENT:'+_events.toString());
    setState(() {
      _events.update(_currentSelectedDay,
              (value) => value + [[_timeDiff, _timeDiffHour, _timeDiffMinute]],
          ifAbsent: () => [
            [_timeDiff, _timeDiffHour, _timeDiffMinute]
          ]);
    });
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      calendarStyle: CalendarStyle(
        markersColor: Colors.red[300],
        outsideDaysVisible: false,
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
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
                  title: Text('${event[1]>0?"${event[1]} hours ":""}${event[2]>0?"${event[2]} minutes ":""}\tWages: $_currency ${(event[0]*_payRate).toStringAsFixed(2)}'),
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
            Container(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("You've earned: "+_currency+' '+_calculateWages(_currentSelectedDay).toStringAsFixed(2)+" today!"),
                    SizedBox(height: 5.0),
                    Text("This week's earning: "+_currency+' '+_getWeeklySalary(_currentSelectedDay).toStringAsFixed(2)),
                    SizedBox(height: 5.0),
                  ]
              ),
            ),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'User #001',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    'Pay Rate: ' + _currency + " " + _payRate.toStringAsFixed(2),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                ],
              )),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Change Pay Rate'),
              onTap: () {
                _payRateController.text = _payRate.toString();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Pay Rate'),
                        content: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('This will set your pay rate to'),
                            SizedBox(height: 20.0),
                            TextField(
                              style: TextStyle(fontSize: 40),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              controller: _payRateController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('CANCEL'),
                          ),
                          FlatButton(
                            onPressed: () {
                              setState(() {
                                _payRate =
                                    double.parse(_payRateController.text);
                                Navigator.pop(context);
                              });
                            },
                            child: Text('ACCEPT'),
                          ),
                        ],
                      );
                    });
              },
            ),
            ListTile(
              title: Text('Change Currency'),
              onTap: () {
                _currencyController.text = _currency;
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Currency'),
                        content: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('This will set your currency to'),
                            SizedBox(height: 20.0),
                            TextField(
                              style: TextStyle(fontSize: 40),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              controller: _currencyController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('CANCEL'),
                          ),
                          FlatButton(
                            onPressed: () {
                              setState(() {
                                _currency = _currencyController.text;
                                Navigator.pop(context);
                              });
                            },
                            child: Text('ACCEPT'),
                          ),
                        ],
                      );
                    });
              },
            ),
            ListTile(
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
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
