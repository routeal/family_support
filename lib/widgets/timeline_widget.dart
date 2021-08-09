import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:tuple/tuple.dart';
import 'package:wecare/models/timeline.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/utils/extensions.dart';

class CareItemLabel {
  int? type;
  String label;
  List<CareItemLabel>? items;
  CareItemLabel({this.type, required this.label, this.items});
  double? width;
}

class MainCareItemList {
  static final MainCareItemList _singleton = MainCareItemList._internal();

  factory MainCareItemList() {
    return _singleton;
  }

  MainCareItemList._internal() {
    List<CareItemLabel> list = [];
    // main meal and sub meal under meal
    items.add(CareItemLabel(type: CareItemType.item, label: "Care Item"));

    list.add(CareItemLabel(type: CareItemType.mainMeal, label: "Main"));
    list.add(CareItemLabel(type: CareItemType.subMeal, label: "Sub"));
    items.add(CareItemLabel(items: list, label: "Meal"));

    items.add(CareItemLabel(type: CareItemType.hydration, label: "Hyd"));

    list = [];
    list.add(CareItemLabel(type: CareItemType.urine, label: "One"));
    list.add(CareItemLabel(type: CareItemType.feces, label: "Two"));
    items.add(CareItemLabel(items: list, label: "BM"));

    list = [];
    list.add(CareItemLabel(type: CareItemType.temperature, label: "BBT"));
    list.add(CareItemLabel(type: CareItemType.pressure, label: "BP"));
    list.add(CareItemLabel(type: CareItemType.pulse, label: "Pulse"));
    items.add(CareItemLabel(items: list, label: "Vital Signs"));

    items.add(CareItemLabel(type: CareItemType.bathing, label: "Bath"));
    items.add(CareItemLabel(type: CareItemType.caregiver, label: "Recorder"));
    items.add(CareItemLabel(type: CareItemType.note, label: "Note"));
  }

  List<CareItemLabel> items = [];
}

// Size Info
class SI {
  // padding for both sides
  static const double pagePadding = 2;

  // margin for text in both left and right sides
  static const double textMargin = 16;

  static const double defaultFontSize = 12;

  static double topBarWidth = 0;
  static double topBarHeight = 0;

  static double sideBarWidth = 0;
  static double sideBarHeight = 0;

  static int workHours = 0;
  static int startTime = 0;
}

class CareItemPosition {
  // starting x position
  double x;
  double width;
  int type;
  CareItemPosition({required this.x, required this.width, required this.type});
}

// save the position of each care item
List<CareItemPosition> _careItemPositions = [];

// current selection of care item
class CareItemSelection {
  int timeSlot;
  int itemType;
  CareItemSelection({required this.timeSlot, required this.itemType});
  @override
  bool operator ==(other) {
    return (other is CareItemSelection) &&
        other.timeSlot == timeSlot &&
        other.itemType == itemType;
  }

  @override
  int get hashCode => (timeSlot.hashCode + itemType.hashCode);
}

enum TimelineEventType {
  tap,
  drag,
}

class TimelineEvent {
  TimelineEventType eventType;
  TimelineEvent({required this.eventType});
}

class TapTimelineEvent extends TimelineEvent {
  CareItemSelection item;
  TapTimelineEvent({required int timeSlot, required int itemType})
      : item = CareItemSelection(timeSlot: timeSlot, itemType: itemType),
        super(eventType: TimelineEventType.tap);
}

class DragTimelineEvent extends TimelineEvent {
  List<CareItemSelection> items;
  DragTimelineEvent({required this.items})
      : super(eventType: TimelineEventType.drag);
}

class DayRange {
  List<DateTime> list() {
    List<DateTime> days = [];
    for (int i = -2; i <= 2; i++) {
      if (i == 0) {
        days.add(current);
      } else {
        days.add(DateTime(current.year, current.month, current.day + i));
      }
    }
    return days;
  }

  DateTime current = DateTime.now();

  DateTime get next =>
      current = DateTime(current.year, current.month, current.day + 1);

  DateTime get prev =>
      current = DateTime(current.year, current.month, current.day - 1);
}

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

class CareTimelineMatrix extends StatelessWidget {
  final dayList = DayRange();
  final scrollPos = ScrollingPositions();
  final User recipient;
  final Color? topBarBackgroundColor;
  final Color? sideBarBackgroundColor;
  final Color? frameColor;
  final double? chooserFontSize;
  final double? topBarFontSize;
  final double? sideBarFontSize;
  final double? matrixFontSize;
  final int? startTime;
  final int? workHours;
  CareTimelineMatrix({
    Key? key,
    this.topBarBackgroundColor,
    this.sideBarBackgroundColor,
    this.frameColor,
    this.chooserFontSize,
    this.topBarFontSize,
    this.sideBarFontSize,
    this.matrixFontSize,
    this.startTime,
    this.workHours,
    required this.recipient,
  }) : super(key: key) {
    SI.workHours = workHours ?? 24;
    SI.startTime = startTime ?? 0;
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: scrollPos),
          Provider.value(value: dayList),
        ],
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              DayChooser(
                  recipient: recipient,
                  fontSize: chooserFontSize ?? SI.defaultFontSize),
              Padding(
                padding: const EdgeInsets.only(
                    left: SI.pagePadding, right: SI.pagePadding),
                child: CareItemList(
                  fontSize: topBarFontSize ?? SI.defaultFontSize,
                  backgroundColor: topBarBackgroundColor,
                  frameColor: frameColor,
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: SI.pagePadding, bottom: SI.pagePadding),
                      child: Timeline(
                          backgroundColor: sideBarBackgroundColor,
                          fontSize: sideBarFontSize ?? SI.defaultFontSize),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: SI.pagePadding, bottom: SI.pagePadding),
                        child: CareItemMatrix(
                            fontSize: matrixFontSize ?? SI.defaultFontSize),
                      ),
                    ),
                  ],
                ),
              ),
            ]));
  }
}

class DayChooser extends StatefulWidget {
  final User recipient;
  final double fontSize;
  const DayChooser({Key? key, required this.recipient, required this.fontSize})
      : super(key: key);
  @override
  State<DayChooser> createState() => _DaySelector();
}

// let select a day for the care, it will show the current recipient as well
class _DaySelector extends State<DayChooser> {
  @override
  void initState() {
    super.initState();
  }

  void decrement() {
    DayRange day = Provider.of<DayRange>(context, listen: false);
    setState(() {
      day.prev;
    });
  }

  void increment() {
    DayRange day = Provider.of<DayRange>(context, listen: false);
    setState(() {
      day.next;
    });
  }

  void update(DateTime newDay) {
    DayRange day = Provider.of<DayRange>(context, listen: false);
    if (day.current != newDay) {
      setState(() {
        day.current = newDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DayRange day = Provider.of<DayRange>(context, listen: false);
    return Row(
      children: <Widget>[
        IconButton(
            onPressed: decrement, icon: const Icon(Icons.arrow_back_outlined)),
        SizedBox(
          width: widget.fontSize,
        ),
        DropdownButton<DateTime>(
          value: day.current,
          icon: const Icon(Icons.arrow_drop_down_outlined),
          iconSize: widget.fontSize * 2,
          style: TextStyle(fontSize: widget.fontSize),
          underline: Container(),
          onChanged: (DateTime? newValue) => update(newValue!),
          items: day.list().map<DropdownMenuItem<DateTime>>((DateTime value) {
            return DropdownMenuItem<DateTime>(
              value: value,
              child: Text(
                intl.DateFormat('M/d (E)').format(value),
                style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: value.isToday() ? FontWeight.bold : FontWeight.normal,
                    color: getDayColor(value.year, value.month, value.day)),
              ),
            );
          }).toList(),
        ),
        SizedBox(
          width: widget.fontSize,
        ),
        Text(
          'Care Level ' + widget.recipient.careLevel.toString(),
          style: TextStyle(fontSize: widget.fontSize),
        ),
        const Spacer(),
        IconButton(
            onPressed: increment,
            icon: const Icon(Icons.arrow_forward_outlined)),
      ],
    );
  }
}

class CareItemList extends StatefulWidget {
  final Color? backgroundColor;
  final Color? frameColor;
  final double fontSize;
  const CareItemList({
    Key? key,
    required this.fontSize,
    this.backgroundColor,
    this.frameColor,
  }) : super(key: key);
  @override
  State<CareItemList> createState() => _CareItemHeader();
}

class _CareItemHeader extends State<CareItemList> {
  final ScrollController _scrollController = ScrollController();

  void _scrollListener() {
    final scrollData = Provider.of<ScrollingPositions>(context, listen: false);
    scrollData.horizontalPosition = _scrollController.position.pixels;
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_scrollListener);

    // time size
    var style = TextStyle(fontSize: widget.fontSize);
    Size size = '00:00'.textWidth(style);
    SI.sideBarWidth = size.width + SI.textMargin;
    SI.sideBarHeight = size.height * 2 + SI.textMargin;

    // careitem header size
    final careItemList = MainCareItemList();

    // size for sub items
    for (CareItemLabel item in careItemList.items) {
      calcSize(item);
    }

    // save the x positions
    double x = 0;
    for (CareItemLabel item in careItemList.items) {
      if (item.items != null) {
        for (CareItemLabel subItem in item.items!) {
          _careItemPositions.add(CareItemPosition(
              x: x, width: subItem.width!, type: subItem.type!));
          x += subItem.width!;
        }
      } else {
        _careItemPositions
            .add(CareItemPosition(x: x, width: item.width!, type: item.type!));
        x += item.width!;
      }
    }

    // header width
    SI.topBarWidth = 0;
    for (CareItemLabel item in careItemList.items) {
      SI.topBarWidth += item.width ?? 0;
    }

    // header height
    SI.topBarHeight = (widget.fontSize + SI.textMargin) * 2;
  }

  void calcSize(CareItemLabel item) {
    if (item.items != null) {
      double w = 0;
      for (CareItemLabel subItem in item.items!) {
        calcSize(subItem);
        w += subItem.width!;
      }
      item.width = w;
    } else {
      final style = TextStyle(fontSize: widget.fontSize);
      Size size = item.label.textWidth(style);
      if (item.type == CareItemType.item) {
        item.width = size.width + SI.textMargin * 2;
      } else if (item.type == CareItemType.note) {
        item.width = size.width * 5 + SI.textMargin;
      } else if (item.type == CareItemType.pressure) {
        size = '000'.textWidth(style);
        item.width = (size.width + SI.textMargin) * 2;
      } else {
        item.width = size.width + SI.textMargin;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: CustomPaint(
          painter: CareItemListPainter(
              fontSize: widget.fontSize,
              backgroundColor: widget.backgroundColor,
              frameColor: widget.frameColor),
          size: Size(SI.sideBarWidth + SI.topBarWidth, SI.topBarHeight),
        ));
  }
}

class CareItemListPainter extends CustomPainter {
  final Color? backgroundColor;
  final Color? frameColor;
  final double fontSize;
  const CareItemListPainter(
      {this.backgroundColor, this.frameColor, required this.fontSize});
  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      // background
      var bgPaint = Paint()..color = backgroundColor!;

      canvas.drawRect(
          Rect.fromLTWH(
              SI.sideBarWidth, 0, size.width - SI.sideBarWidth, size.height),
          bgPaint);
    }

    double iconSize = fontSize * 2;
    drawIcon(canvas, Icons.arrow_left_sharp, SI.sideBarWidth - iconSize,
        (SI.topBarHeight - iconSize) / 2, iconSize);

    drawIcon(canvas, Icons.arrow_drop_up_sharp,
        (SI.sideBarWidth - iconSize) / 2, SI.topBarHeight - iconSize, iconSize);

    // frame
    var paint = Paint()
      ..color = frameColor ?? Colors.grey[400]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var path = Path();

    double height = size.height / 2;

    // upper line
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // left bar
    path.moveTo(0, 0);
    path.lineTo(0, size.height);

    // bottom line
    //path.moveTo(0, height);
    //path.lineTo(size.width, height);

    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);

    // right bar
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);

    // Name bar
    path.moveTo(SI.sideBarWidth, 0);
    path.lineTo(SI.sideBarWidth, size.height);

    double prevX = SI.sideBarWidth;
    for (CareItemLabel item in MainCareItemList().items) {
      // end of vertical line
      double x = prevX + (item.width ?? 0);
      path.moveTo(x, 0);
      path.lineTo(x, size.height);

      if (item.items == null) {
        paintCenterText(canvas, item.label, Colors.black87, fontSize, prevX, 0,
            item.width!, size.height);
      } else {
        // center line
        path.moveTo(prevX, height);
        path.lineTo(prevX + item.width!, height);

        // main label
        paintCenterText(canvas, item.label, Colors.black87, fontSize, prevX, 0,
            item.width!, height);

        double startX = prevX;
        for (CareItemLabel subItem in item.items!) {
          // sub label
          paintCenterText(canvas, subItem.label, Colors.black87, fontSize,
              startX, height, subItem.width!, height);

          // divider
          startX += subItem.width!;
          path.moveTo(startX, height);
          path.lineTo(startX, height * 2);
        }
      }

      prevX = x;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

  void drawIcon(Canvas canvas, IconData icon, double x, double y,
      [double fontSize = 12, Color color = Colors.grey]) {
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: icon.fontFamily,
        package:
            icon.fontPackage, // This line is mandatory for external icon packs
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }
}

class Timeline extends StatefulWidget {
  final Color? backgroundColor;
  final Color? frameColor;
  final double fontSize;
  const Timeline(
      {Key? key, this.backgroundColor, this.frameColor, required this.fontSize})
      : super(key: key);
  @override
  State<Timeline> createState() => _Timeline();
}

class _Timeline extends State<Timeline> {
  final ScrollController _scrollController = ScrollController();

  void _scrollListener() {
    final scrollData = Provider.of<ScrollingPositions>(context, listen: false);
    scrollData.verticalPosition = _scrollController.position.pixels;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      child: CustomPaint(
        painter: TimelinePainter(
            fontSize: widget.fontSize, backgroundColor: widget.backgroundColor),
        size: Size(SI.sideBarWidth, SI.sideBarHeight * SI.workHours),
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final Color? backgroundColor;
  final double fontSize;
  TimelinePainter({this.backgroundColor, required this.fontSize});
  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      // background
      var bgPaint = Paint()..color = backgroundColor!;

      canvas.drawRect(
          Rect.fromLTWH(0, 0, SI.sideBarWidth, size.height), bgPaint);
    }

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
    for (int i = 0; i < SI.workHours; i++) {
      path.moveTo(0, SI.sideBarHeight * i);
      path.lineTo(size.width, SI.sideBarHeight * i);

      int hour = i + SI.startTime;
      String str = hour.toString().padLeft(2, '0');

      paintCenterText(canvas, str + ':00', Colors.black, fontSize, 0,
          SI.sideBarHeight * i, size.width, SI.sideBarHeight);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

class CareItemMatrix extends StatefulWidget {
  final double fontSize;
  const CareItemMatrix({Key? key, required this.fontSize}) : super(key: key);
  @override
  State<CareItemMatrix> createState() => _CareItemMatrix();
}

class _CareItemMatrix extends State<CareItemMatrix> {
  double _vpos = 0;
  double _hpos = 0;

  TimelineEvent? event;

  final ScrollController _vscrollController = ScrollController();
  final ScrollController _hscrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  Tuple2<int, CareItemPosition> translatePosition(double x, double y) {
    int slot = y.floor() ~/ SI.sideBarHeight.floor();

    CareItemPosition item = _careItemPositions
        .firstWhere((item) => item.x <= x && (item.x + item.width) >= x);

    return Tuple2(slot, item);
  }

  void saveEvent(double x, double y) {
    final pos = translatePosition(x, y);

    final item =
        CareItemSelection(timeSlot: pos.item1, itemType: pos.item2.type);

    if (_timedCareItems.isEmpty) {
      _timedCareItems.add(item);
    } else if (!_timedCareItems.contains(item)) {
      if ((_timedCareItems.last.itemType == item.itemType) &&
          (_timedCareItems.last.timeSlot == (item.timeSlot - 1))) {
        _timedCareItems.add(item);
      } else {
        _timedCareItems.clear();
        _timedCareItems.add(item);
      }
    }
  }

  void gestureTapDownCallback(TapDownDetails details) {
    final pos = translatePosition(
        details.localPosition.dx + _hpos, details.localPosition.dy + _vpos);

    print('tap down: ' + pos.item1.toString());

    _timedCareItems.clear();

    saveEvent(
        details.localPosition.dx + _hpos, details.localPosition.dy + _vpos);
  }

  void gestureTapUpCallback(TapUpDetails details) {
    final pos = translatePosition(
        details.localPosition.dx + _hpos, details.localPosition.dy + _vpos);
    print('tap up: ' + pos.item1.toString());

    if (_timedCareItems.isNotEmpty) {
      setState(() {
        event = TapTimelineEvent(
            timeSlot: _timedCareItems.last.timeSlot,
            itemType: _timedCareItems.last.itemType);
      });
    }

    _timedCareItems.clear();
  }

  final List<CareItemSelection> _timedCareItems = [];

  void gestureDragStartCallback(DragStartDetails details) {
    final pos = translatePosition(
        details.localPosition.dx + _hpos, details.localPosition.dy + _vpos);
    print('drag start: ' + pos.item1.toString());
    //_timedCareItems.clear();
  }

  void gestureDragEndCallback(DragEndDetails details) {
    print(' drag end: ');
    /*
    setState(() {
      event = DragTimelineEvent(items: _timedCareItems);
    });
    */
  }

  void gestureDragUpdateCallback(DragUpdateDetails details) {
    saveEvent(
        details.localPosition.dx + _hpos, details.localPosition.dy + _vpos);

    final pos = translatePosition(
        details.localPosition.dx + _hpos, details.localPosition.dy + _vpos);

    print('drag update: ' + pos.item1.toString());

    setState(() {
      event = DragTimelineEvent(items: _timedCareItems);
    });
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

    return GestureDetector(
        onTapDown: gestureTapDownCallback,
        onTapUp: gestureTapUpCallback,
        onVerticalDragStart: gestureDragStartCallback,
        onVerticalDragEnd: gestureDragEndCallback,
        onVerticalDragUpdate: gestureDragUpdateCallback,
        child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _vscrollController,
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _hscrollController,
              scrollDirection: Axis.horizontal,
              child: CustomPaint(
                painter: MatrixPainter(),
                size: Size(SI.topBarWidth, SI.sideBarHeight * SI.workHours),
                foregroundPainter: CurrentEventPainter(event: event),
              ),
            )));
  }
}

class MatrixPainter extends CustomPainter {
  MatrixPainter();
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

    double prevX = 0;

    final careItemList = MainCareItemList();

    for (CareItemLabel item in careItemList.items) {
      double x = prevX + (item.width ?? 0);
      path.moveTo(x, 0);
      path.lineTo(x, size.height);

      if (item.items != null) {
        double startX = prevX;
        for (CareItemLabel subItem in item.items!) {
          // divider
          startX += subItem.width!;
          path.moveTo(startX, 0);
          path.lineTo(startX, size.height);
        }
      }

      prevX = x;
    }

    for (int i = 0; i < SI.workHours; i++) {
      path.moveTo(0, SI.sideBarHeight * i);
      path.lineTo(size.width, SI.sideBarHeight * i);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // ~TODO: implement shouldRepaint
    return false;
  }
}

class CurrentEventPainter extends CustomPainter {
  TimelineEvent? event;

  CurrentEventPainter({this.event});

  @override
  void paint(Canvas canvas, Size size) {
    if (event == null) {
      return;
    }
    if (event!.eventType == TimelineEventType.tap) {
      TapTimelineEvent tevent = event! as TapTimelineEvent;

      double y = tevent.item.timeSlot * SI.sideBarHeight;
      final item = _careItemPositions
          .firstWhere((element) => element.type == tevent.item.itemType);

      var bgpaint = Paint()..color = Colors.blue[100]!;

      canvas.drawRect(
          Rect.fromLTWH(item.x, y, item.width, SI.sideBarHeight), bgpaint);
    } else if (event!.eventType == TimelineEventType.drag) {
      DragTimelineEvent devent = event! as DragTimelineEvent;
      for (CareItemSelection item in devent.items) {
        double y = item.timeSlot * SI.sideBarHeight;
        final pos = _careItemPositions
            .firstWhere((element) => element.type == item.itemType);

        var bgpaint = Paint()..color = Colors.blue[100]!;

        canvas.drawRect(
            Rect.fromLTWH(pos.x, y, pos.width, SI.sideBarHeight), bgpaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
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
