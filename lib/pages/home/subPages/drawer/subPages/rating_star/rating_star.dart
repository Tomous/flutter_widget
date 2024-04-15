import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

class RatingStar extends StatefulWidget {
  const RatingStar({super.key});

  @override
  State<RatingStar> createState() => _RatingStarState();
}

class _RatingStarState extends State<RatingStar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评分'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Center(
              child: RatingStars(
                value: 3.6,
                starBuilder: (index, color) {
                  return Icon(
                    Icons.star,
                    color: color,
                  );
                },
                starCount: 5,
                starSize: 20,
                valueLabelColor: const Color(0xff9b9b9b),
                valueLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 12.0),
                valueLabelRadius: 10,
                maxValue: 5,
                starSpacing: 2,
                maxValueVisibility: true,
                valueLabelVisibility: false,
                animationDuration: const Duration(milliseconds: 1000),
                valueLabelPadding:
                    const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                valueLabelMargin: const EdgeInsets.only(right: 8),
                starOffColor: const Color(0xffe7e8ea),
                starColor: Colors.yellow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
