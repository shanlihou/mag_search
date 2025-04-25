import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SearchResult {
  final String title;
  final String url;
  final String size;
  final String date;

  SearchResult(
      {required this.title,
      required this.url,
      required this.size,
      required this.date});

  Widget toWidget() {
    return Row(
      children: [
        Container(
            margin: EdgeInsets.only(right: 1.w),
            width: 60.w,
            child: Text(title,
                maxLines: 1,
                style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black))),
        Container(
            width: 20.w,
            margin: const EdgeInsets.only(right: 10),
            child: Text(size,
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black))),
        Text(date,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
      ],
    );
  }
}
