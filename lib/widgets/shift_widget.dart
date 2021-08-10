import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:wecare/models/user.dart';

const int SNAP_DURATION = 100; // in milliseconds

const double DATE_HEIGHT = 40;
const double DATE_WIDTH = 40;
const double INIT_NAME_WIDTH = 100;
const double NAME_HEIGHT = 40;
const double COLUMN_HEIGHT = NAME_HEIGHT;
const double COLUMN_WIDTH = DATE_WIDTH;
const double SIDE_PADDING = 4;

double NAME_WIDTH = INIT_NAME_WIDTH;

class ScrollingPositions with ChangeNotifier {
  double _horizontalPosition = 0;

  double get horizontalPosition => _horizontalPosition;

  set horizontalPosition(double position) {
    _horizontalPosition = position;
    notifyListeners();
  }

  double _verticalPosition = 0;

  double get verticalPosition => _verticalPosition;

  set verticalPosition(double position) {
    if (_verticalPosition != position) {
      _verticalPosition = position;
      notifyListeners();
    }
  }
}

class MonthList with ChangeNotifier {
  int initialIndex;
  List<DateTime> list;

  int _index = 0;

  MonthList({required this.initialIndex, required this.list})
      : _index = initialIndex;

  int get index => _index;

  set index(int newValue) {
    if (_index != newValue) {
      _index = newValue;
      notifyListeners();
    }
  }
}

class CarerSchedule {
  User? carer;
}

class ResourceScheduler extends StatefulWidget {
  final List<User>? users;
  final Color? datesBackgroundColor;
  final Color? frameColor;
  final int pastMonths;
  final int futureMonths;
  ResourceScheduler({
    required this.pastMonths,
    required this.futureMonths,
    this.users,
    this.datesBackgroundColor,
    this.frameColor,
  });
  @override
  State<ResourceScheduler> createState() => _ResourceScheduler();
}

class _ResourceScheduler extends State<ResourceScheduler> {
  late ScrollingPositions scrollPos;
  late MonthList monthList;
  late List<CarerSchedule> scheduleList;

  @override
  void initState() {
    super.initState();

    // Date info
    List<DateTime> months = <DateTime>[];
    var now = DateTime.now();
    for (int i = -widget.pastMonths; i < widget.futureMonths; i++) {
      int month = now.month + i;
      if (month == 0) {
        months.add(DateTime(now.year - 1, 12, 1));
      } else if (month == 13) {
        months.add(DateTime(now.year + 1, 1, 1));
      } else {
        months.add(DateTime(now.year, month, 1));
      }
    }
    monthList = MonthList(list: months, initialIndex: widget.pastMonths);

    // scrolling positions
    scrollPos = ScrollingPositions();

    // list of the containers of each carer's schedule
    scheduleList = [];
    for (var c in widget.users ?? []) {
      var cs = CarerSchedule();
      cs.carer = c;
      scheduleList.add(cs);
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollPos.dispose();
    monthList.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // adjust the name width based on the width of the current page
    double contentWidth = (width - INIT_NAME_WIDTH - SIDE_PADDING * 2);
    int num_dates = (contentWidth / DATE_WIDTH).floor();
    int reminder = (contentWidth - (num_dates * DATE_WIDTH)).floor();
    NAME_WIDTH = reminder + INIT_NAME_WIDTH;

    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: scrollPos),
          ChangeNotifierProvider.value(value: monthList),
          Provider.value(value: scheduleList),
        ],
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              MonthSelector(),
              Padding(
                padding: const EdgeInsets.only(
                    left: SIDE_PADDING, right: SIDE_PADDING),
                child: DateSelector(
                  bgColor: widget.datesBackgroundColor,
                  frameColor: widget.frameColor,
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: SIDE_PADDING, bottom: SIDE_PADDING),
                      child: NameList(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: SIDE_PADDING, bottom: SIDE_PADDING),
                        child: ScheduleContents(),
                      ),
                    ),
                  ],
                ),
              ),
            ]));
  }
}

class MonthSelector extends StatefulWidget {
  State<MonthSelector> createState() => _MonthSelector();
}

class _MonthSelector extends State<MonthSelector> {
  late final List<int> menuList;

  @override
  void initState() {
    super.initState();
    MonthList months = Provider.of<MonthList>(context, listen: false);
    menuList = Iterable<int>.generate(months.list.length).toList();
  }

  void decrementIndex() {
    MonthList months = Provider.of<MonthList>(context, listen: false);
    updateMonth((months.index > 0) ? (months.index - 1) : 0);
  }

  void incrementIndex() {
    MonthList months = Provider.of<MonthList>(context, listen: false);
    updateMonth((months.index < (months.list.length - 1))
        ? (months.index + 1)
        : months.index);
  }

  void updateMonth(int month) {
    MonthList months = Provider.of<MonthList>(context, listen: false);
    setState(() {
      months.index = month;
    });
  }

  @override
  Widget build(BuildContext context) {
    MonthList months = Provider.of<MonthList>(context, listen: false);
    return Row(
      children: <Widget>[
        IconButton(
            onPressed: () => decrementIndex(),
            icon: Icon(Icons.arrow_back_outlined)),
        Spacer(),
        DropdownButton<int>(
          value: months.index,
          icon: const Icon(Icons.arrow_drop_down_outlined),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(),
          onChanged: (int? newValue) => updateMonth(newValue!),
          items: menuList.map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(intl.DateFormat('MMMM yyyy').format(months.list[value])),
            );
          }).toList(),
        ),
        Spacer(),
        IconButton(
            onPressed: () => incrementIndex(),
            icon: Icon(Icons.arrow_forward_outlined)),
      ],
    );
  }
}

class DateSelector extends StatefulWidget {
  final Color? bgColor;
  final Color? frameColor;
  DateSelector({this.bgColor, this.frameColor});
  @override
  State<DateSelector> createState() => _DateSelector();
}

class _DateSelector extends State<DateSelector> {
  double width = NAME_WIDTH + DATE_HEIGHT * 31;
  double height = DATE_HEIGHT;
  double _pos = 0;

  late ScrollController _scrollController;

  void _scrollListener() {
    final scrollData = Provider.of<ScrollingPositions>(context, listen: false);
    scrollData.horizontalPosition = _scrollController.position.pixels;
    _pos = _scrollController.position.pixels;
  }

  bool _enableScrollingNotifier = true;

  Timer? _snapTimer;

  void _snapVerticalScroll() {
    _snapTimer?.cancel();
    setState(() {
      int threshhold = COLUMN_WIDTH.toInt() ~/ 2;
      int newpos =
          ((_pos.floor() + threshhold) ~/ COLUMN_WIDTH.toInt()).toInt() *
              COLUMN_WIDTH.toInt();
      _scrollController.jumpTo(newpos.toDouble());
      _enableScrollingNotifier = false;
    });
  }

  void _scrollingVerticalNotifier() {
    if (!_enableScrollingNotifier) {
      _enableScrollingNotifier = true;
      return;
    }
    if (!_scrollController.position.isScrollingNotifier.value) {
      _snapTimer =
          Timer(Duration(milliseconds: SNAP_DURATION), _snapVerticalScroll);
    }
  }

  void attached() {
    _scrollController.position.isScrollingNotifier
        .addListener(_scrollingVerticalNotifier);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance?.addPostFrameCallback((_) => attached());
  }

  @override
  Widget build(BuildContext context) {
    // disable scroll by content
    /*
    final scrollData = Provider.of<ScrollData>(context, listen: true);

    if (_pos != scrollData.horizontalPosition) {
      setState(() {
        _scrollController.jumpTo(scrollData.horizontalPosition);
        _pos = scrollData.horizontalPosition;
      });
    }
    */

    MonthList months = Provider.of<MonthList>(context, listen: true);
    DateTime currentDate = months.list[months.index];
    int numDays = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    width = NAME_WIDTH + DATE_WIDTH * numDays;

    return SingleChildScrollView(
        //physics: NeverScrollableScrollPhysics(),
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: CustomPaint(
          painter: DatePainter(
              month: currentDate,
              days: numDays,
              bgColor: widget.bgColor,
              frameColor: widget.frameColor),
          size: Size(width, height),
        ));
  }
}

class DatePainter extends CustomPainter {
  DateTime month;
  int days;
  Color? bgColor;
  Color? frameColor;
  DatePainter(
      {required this.month, required this.days, this.bgColor, this.frameColor});
  @override
  void paint(Canvas canvas, Size size) {
    // background
    var bgpaint = Paint()..color = bgColor ?? Colors.white24;

    canvas.drawRect(
        Rect.fromLTWH(NAME_WIDTH, 0, size.width-NAME_WIDTH, size.height), bgpaint);

    // frame
    var paint = Paint()
      ..color = frameColor ?? Colors.black12
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var path = Path();

    // upper line
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // left bar
    path.moveTo(0, 0);
    path.lineTo(0, DATE_HEIGHT);

    // bottom line
    path.moveTo(0, DATE_HEIGHT);
    path.lineTo(size.width, DATE_HEIGHT);

    // right bar
    path.moveTo(size.width, 0);
    path.lineTo(size.width, DATE_HEIGHT);

    // Name bar
    path.moveTo(NAME_WIDTH, 0);
    path.lineTo(NAME_WIDTH, DATE_HEIGHT);

    for (double i = 1; i <= days; i++) {
      path.moveTo(NAME_WIDTH + DATE_WIDTH * i, 0);
      path.lineTo(NAME_WIDTH + DATE_WIDTH * i, DATE_HEIGHT);
    }

    canvas.drawPath(path, paint);

    // paint the first date with month
    Color color = getDayColor(month.year, month.month, 1);
    paintCenterText(canvas, month.month.toString() + '/1', color, 12,
        NAME_WIDTH, 0, DATE_WIDTH, DATE_HEIGHT);

    // paint the rest of the dates
    for (int i = 2; i <= days; i++) {
      Color color = getDayColor(month.year, month.month, i);
      paintCenterText(canvas, i.toString(), color, 12,
          NAME_WIDTH + DATE_WIDTH * (i - 1), 0, DATE_WIDTH, DATE_HEIGHT);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

  Color getDayColor(int year, int month, int day) {
    var date = DateTime(year, month, day);
    Color? color;
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      color = Colors.red;
    } else {
      color = Colors.black;
    }
    return color;
  }
}

void paintCenterText(Canvas canvas, String text, Color color, double fontSize,
    double x, double y, double width, double height) {
  var textSpan = TextSpan(
    style: TextStyle(
      color: color,
      fontSize: fontSize,
    ),
    text: text,
  );
  final textPainter = TextPainter(
    text: textSpan,
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  double cx = (width - textPainter.width) * 0.5;
  double cy = (height - textPainter.height) * 0.5;
  var offset = Offset(x + cx, y + cy);
  textPainter.paint(canvas, offset);
}

class NameList extends StatefulWidget {
  State<NameList> createState() => _NameList();
}

class _NameList extends State<NameList> {
  double _pos = 0;

  Timer? _snapTimer;

  late ScrollController _scrollController;

  void _scrollListener() {
    final scrollData = Provider.of<ScrollingPositions>(context, listen: false);
    scrollData.verticalPosition = _scrollController.position.pixels;
    _pos = _scrollController.position.pixels;
  }

  bool _enableScrollingNotifier = true;

  void _snapScroll() {
    _snapTimer?.cancel();
    setState(() {
      print(_pos);
      int newpos = ((_pos.floor() + 20) ~/ COLUMN_WIDTH.toInt()).toInt() *
          COLUMN_WIDTH.toInt();
      print(newpos);
      _scrollController.jumpTo(newpos.toDouble());
      _enableScrollingNotifier = false;
    });
  }

  void _scrollingNotifier() {
    if (!_enableScrollingNotifier) {
      _enableScrollingNotifier = true;
      return;
    }
    if (!_scrollController.position.isScrollingNotifier.value) {
      print('scroll is stopped');
      _snapTimer = Timer(Duration(milliseconds: SNAP_DURATION), _snapScroll);
    } else {
      print('scroll is started');
    }
  }

  void attached() {
    _scrollController.position.isScrollingNotifier
        .addListener(_scrollingNotifier);
  }

  double width = 0;
  double height = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance?.addPostFrameCallback((_) => attached());
  }

  @override
  Widget build(BuildContext context) {
    // disable scroll by contents
    /*
    final scrollData = Provider.of<ScrollData>(context, listen: true);

    if (_pos != scrollData.verticalPosition) {
      setState(() {
        _scrollController.jumpTo(scrollData.verticalPosition);
        _pos = scrollData.verticalPosition;
      });
    }
    */

    final list = Provider.of<List<CarerSchedule>>(context, listen: false);

    width = NAME_WIDTH;
    height = NAME_HEIGHT * list.length;

    return SingleChildScrollView(
      //physics: NeverScrollableScrollPhysics(),
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      child: CustomPaint(
        painter: NamePainter(list: list),
        size: Size(width, height),
      ),
    );
  }
}

class NamePainter extends CustomPainter {
  List<CarerSchedule> list;
  NamePainter({required this.list});
  @override
  void paint(Canvas canvas, Size size) {
    // frame painting
    var paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var path = Path();

    // left line
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // top line
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);

    // right line
    path.moveTo(0, 0);
    path.lineTo(0, size.height);

    // bottom line
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);

    // each line
    for (double i = 1; i <= list.length; i++) {
      path.moveTo(0, NAME_HEIGHT * i);
      path.lineTo(size.width, NAME_HEIGHT * i);
    }

    canvas.drawPath(path, paint);

    // name painting
    for (int i = 0; i < list.length; i++) {
      var carer = list[i].carer;
      paintCenterText(canvas, carer!.displayName!, Colors.black, 12, 0,
          NAME_HEIGHT * i, NAME_WIDTH, NAME_HEIGHT);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

class ScheduleContents extends StatefulWidget {
  @override
  State<ScheduleContents> createState() => _ScheduleContents();
}

class _ScheduleContents extends State<ScheduleContents> {
  double width = 0;
  double height = 0;

  double _vpos = 0;
  double _hpos = 0;

  late ScrollController _vscrollController;
  late ScrollController _hscrollController;

/*
  Timer? _snapTimer;

  void _vscrollListener() {
    final scrollData = Provider.of<ScrollData>(context, listen: false);
    scrollData.verticalPosition = _vscrollController.position.pixels;
    _vpos = _vscrollController.position.pixels;
  }

  void _hscrollListener() {
    final scrollData = Provider.of<ScrollData>(context, listen: false);
    scrollData.horizontalPosition = _hscrollController.position.pixels;
    _hpos = _hscrollController.position.pixels;
  }

  bool _enableScrollingNotifier = true;

  void _snapVerticalScroll() {
    _snapTimer?.cancel();
    setState(() {
      print(_vpos);
      int newpos = ((_vpos.floor() + 20) / COLUMN_WIDTH.toInt()).toInt() *
          COLUMN_WIDTH.toInt();
      print(newpos);
      _vscrollController.jumpTo(newpos.toDouble());
      _enableScrollingNotifier = false;
    });
  }

  void _snapHorizontalScroll() {
    _snapTimer?.cancel();
    setState(() {
      print(_hpos);
      int newpos = ((_hpos.floor() + 20) / 40).toInt() * 40;
      print(newpos);
      _hscrollController.jumpTo(newpos.toDouble());
      _enableScrollingNotifier = false;
    });
  }

  void _scrollingVerticalNotifier() {
    if (!_enableScrollingNotifier) {
      _enableScrollingNotifier = true;
      return;
    }
    if (!_vscrollController.position.isScrollingNotifier.value) {
      print('scroll is stopped');
      _snapTimer =
          Timer(Duration(milliseconds: SNAP_DURATION), _snapVerticalScroll);
    } else {
      print('scroll is started');
    }
  }

  void _scrollingHorizontalNotifier() {
    if (!_enableScrollingNotifier) {
      _enableScrollingNotifier = true;
      return;
    }
    if (!_hscrollController.position.isScrollingNotifier.value) {
      print('scroll is stopped');
      _snapTimer =
          Timer(Duration(milliseconds: SNAP_DURATION), _snapHorizontalScroll);
    } else {
      print('scroll is started');
    }
  }

  void attached() {
    _vscrollController.position.isScrollingNotifier
        .addListener(_scrollingVerticalNotifier);
    _hscrollController.position.isScrollingNotifier
        .addListener(_scrollingHorizontalNotifier);
  }
*/

  @override
  void initState() {
    super.initState();
    _vscrollController = ScrollController();
    //_vscrollController.addListener(_vscrollListener);
    _hscrollController = ScrollController();
    //_hscrollController.addListener(_hscrollListener);
    //WidgetsBinding.instance?.addPostFrameCallback((_) => attached());
  }

  void GestureTapDownCallback(TapDownDetails details) {
    print('tapDown x:' + details.localPosition.dx.toString() + ' y:' + details.localPosition.dy.toString());
  }

  void GestureDragStartCallback(DragStartDetails details) {
    print('horizontal drag start: ');
  }

  void GestureDragEndCallback(DragEndDetails details) {
    print('horizontal drag end: ');
  }

  @override
  Widget build(BuildContext context) {
    final scrollData = Provider.of<ScrollingPositions>(context, listen: true);

    if (_hpos != scrollData.horizontalPosition) {
      setState(() {
        _hscrollController.jumpTo(scrollData.horizontalPosition);
        _hpos = scrollData.horizontalPosition;
      });
    }

    if (_vpos != scrollData.verticalPosition) {
      setState(() {
        _vscrollController.jumpTo(scrollData.verticalPosition);
        _vpos = scrollData.verticalPosition;
      });
    }

    MonthList currentDate = Provider.of<MonthList>(context, listen: true);

    DateTime dt = currentDate.list[currentDate.index];

    int numDays = DateTime(dt.year, dt.month + 1, 0).day;

    width = COLUMN_WIDTH * numDays;

    final scheduleList =
        Provider.of<List<CarerSchedule>>(context, listen: false);

    height = COLUMN_HEIGHT * scheduleList.length;

    return GestureDetector(
        onTapDown: GestureTapDownCallback,
        onHorizontalDragStart: GestureDragStartCallback,
        onHorizontalDragEnd: GestureDragEndCallback,
        child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        controller: _vscrollController,
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          controller: _hscrollController,
          scrollDirection: Axis.horizontal,
          child: CustomPaint(
            painter: SchedulePainter(numDays: numDays, list: scheduleList),
            size: Size(width, height),
            foregroundPainter: CurrentEventPainter(),
          ),
        )));
  }
}

class SchedulePainter extends CustomPainter {
  int numDays;
  List<CarerSchedule> list;
  SchedulePainter({required this.numDays, required this.list});
  @override
  void paint(Canvas canvas, Size size) {
    // frame paint
    var paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);

    path.moveTo(0, 0);
    path.lineTo(0, size.height);

    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);

    for (double i = 1; i <= numDays; i++) {
      path.moveTo(COLUMN_WIDTH * i, 0);
      path.lineTo(COLUMN_WIDTH * i, size.height);
    }

    for (double i = 1; i <= list.length; i++) {
      path.moveTo(0, COLUMN_HEIGHT * i);
      path.lineTo(size.width, COLUMN_HEIGHT * i);
    }

    canvas.drawPath(path, paint);

    // current schedule
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

class CurrentEventPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
