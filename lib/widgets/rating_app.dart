
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarRating extends StatefulWidget {
  final double initialRating;
  final bool allowHalfRating;
  final Function(double) onRatingChanged;

 const StarRating({
  super.key,
  this.initialRating = 3.0,
  this.allowHalfRating = true,
  required this.onRatingChanged,
});

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: widget.allowHalfRating,
          itemCount: 5,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
            widget.onRatingChanged(rating);
          },
        ),
        const SizedBox(height: 10),
        Text(
          'Rating: ${_rating.toStringAsFixed(1)} estrellas',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
