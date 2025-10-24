import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:trivia/models/category.dart';
import 'package:trivia/ui/widgets/rating_stars.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onPress,
  });

  final Category category;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          GestureDetector(
            onTap: onPress,
            child: Card(
              elevation: 2,
              shadowColor: Colors.grey.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${NumberFormat().format(category.numberOfQuestions)} questions",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    RatingStars(
                      score: category.highestScore,
                      numberOfQuestions: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -7,
            left: 15,
            child: Column(
              children: [
                SvgPicture.asset(
                  "assets/images/${category.categoryId}.svg",
                  width: 70,
                  height: 70,
                ),

                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade800,
                        spreadRadius: 1,
                        blurRadius: 25,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
