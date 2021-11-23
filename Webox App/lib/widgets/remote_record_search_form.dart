import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:intl/intl.dart';

class RemoteRecordSearchForm extends StatefulWidget {
  final Future<void> Function(
      {DateTime? startDateTime,
      DateTime? endDateTime,
      LatLng? location,
      List<String>? matchObjects}) onChange;

  final Future<void> Function() onSearch;

  const RemoteRecordSearchForm(
      {Key? key, required this.onChange, required this.onSearch})
      : super(key: key);

  @override
  _RemoteRecordSearchFormState createState() => _RemoteRecordSearchFormState();
}

class _RemoteRecordSearchFormState extends State<RemoteRecordSearchForm> {
  List<SearchObjectItem> objectItems = [
    SearchObjectItem('police_car', '경찰차'),
    SearchObjectItem('ambulance', '구급차'),
    SearchObjectItem('etc_car', '기타특장차'),
    SearchObjectItem('adult', '성인(어른)'),
    SearchObjectItem('child', '어린이'),
    SearchObjectItem('bicycle', '자전거'),
    SearchObjectItem('motorcycle', '오토바이'),
    SearchObjectItem('personal_mobility', '킥보드'),
    SearchObjectItem('van', '승합차/SUV'),
    SearchObjectItem('bus', '버스'),
    SearchObjectItem('sedan', '세단'),
    SearchObjectItem('school_bus', '통학버스'),
    SearchObjectItem('truck', '트럭')
  ];

  DateTime? startDatetime;
  DateTime? endDatetime;

  PickResult? pickResult;

  void callOnChange() {
    widget.onChange(
        startDateTime: startDatetime,
        endDateTime: endDatetime,
        location: pickResult != null
            ? LatLng(pickResult!.geometry!.location.lat,
                pickResult!.geometry!.location.lng)
            : null,
        matchObjects: objectItems
            .where((element) => element.selected)
            .map((e) => e.name)
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
              )
            ]),
        child: Column(children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기간 :',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Column(children: [
                  Row(children: [
                    InkWell(
                        onTap: () {
                          DatePicker.showDateTimePicker(context,
                              currentTime: startDatetime,
                              showTitleActions: true, onConfirm: (date) {
                            setState(() {
                              startDatetime = date;
                              if (endDatetime == null)
                                endDatetime =
                                    startDatetime!.add(Duration(days: 1));
                            });
                            callOnChange();
                          });
                        },
                        child: Container(
                            width: 270,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              color: Colors.white54,
                            ),
                            padding: EdgeInsets.all(6.0),
                            child: Text(startDatetime != null
                                ? DateFormat('yyyy년 MM월 dd일 hh:mm a')
                                    .format(startDatetime!)
                                : '<클릭하여 시간 설정하기>'))),
                    Text(
                      ' 에서',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  ]),
                  SizedBox(height: 5),
                  Row(children: [
                    InkWell(
                        onTap: () {
                          DatePicker.showDateTimePicker(context,
                              currentTime: endDatetime,
                              showTitleActions: true, onConfirm: (date) {
                            setState(() {
                              endDatetime = date;
                              if (startDatetime == null)
                                startDatetime =
                                    endDatetime!.subtract(Duration(days: 1));
                            });
                            callOnChange();
                          });
                        },
                        child: Container(
                            width: 270,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              color: Colors.white54,
                            ),
                            padding: EdgeInsets.all(6.0),
                            child: Text(endDatetime != null
                                ? DateFormat('yyyy년 MM월 dd일 hh:mm a')
                                    .format(endDatetime!)
                                : '<클릭하여 시간 설정하기>'))),
                    Text(
                      ' 까지',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  ])
                ])
              ]),
          SizedBox(height: 8),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('장소 :',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlacePicker(
                                    apiKey:
                                        '<API Key Here>',
                                    autocompleteLanguage: 'ko',
                                    onPlacePicked: (result) {
                                      setState(() {
                                        pickResult = result;
                                      });
                                      callOnChange();
                                      Navigator.of(context).pop();
                                    },
                                    initialPosition:
                                        LatLng(126.875011, 37.524496),
                                    useCurrentLocation: true,
                                  )));
                    },
                    child: Container(
                        width: 300,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.white54,
                        ),
                        padding: EdgeInsets.all(6.0),
                        child: Text(
                            pickResult?.formattedAddress ?? '<클릭하여 장소 설정하기>'))),
              ]),
          SizedBox(height: 4),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('사물 :',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Container(
                    width: 300,
                    child: Wrap(
                      spacing: -2,
                      runSpacing: -10,
                      children: objectItems
                          .map((o) => ObjectFilterChip(
                                searchObjectItem: o,
                                onSelected: (s) {
                                  setState(() {
                                    o.selected = s;
                                  });
                                  callOnChange();
                                },
                              ))
                          .toList(),
                    ))
              ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text(
                  '검색조건 초기화',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    startDatetime = null;
                    endDatetime = null;
                    pickResult = null;
                    objectItems.forEach((element) {
                      element.selected = false;
                    });
                  });
                  callOnChange();
                  widget.onSearch();
                },
              ),
              SizedBox(
                width: 12,
              ),
              OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.primary,
                      backgroundColor: Colors.white),
                  icon: Icon(
                    Icons.search,
                  ),
                  label: Text(
                    '검색',
                  ),
                  onPressed: () {
                    widget.onSearch();
                  }),
            ],
          )
        ]));
  }
}

class DatetimeSearchFormItem extends StatefulWidget {
  const DatetimeSearchFormItem({Key? key}) : super(key: key);

  @override
  _DatetimeSearchFormItemState createState() => _DatetimeSearchFormItemState();
}

class _DatetimeSearchFormItemState extends State<DatetimeSearchFormItem> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class SearchObjectItem {
  final String name;
  final String label;
  bool selected = false;

  SearchObjectItem(this.name, this.label);
}

class ObjectFilterChip extends StatelessWidget {
  final SearchObjectItem searchObjectItem;
  final ValueChanged<bool>? onSelected;

  const ObjectFilterChip(
      {Key? key, required this.searchObjectItem, this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
        transform: Matrix4.identity()..scale(0.85),
        child: FilterChip(
          showCheckmark: false,
          label: Text(searchObjectItem.label),
          selected: searchObjectItem.selected,
          selectedColor: Colors.white54,
          onSelected: onSelected,
        ));
  }
}
