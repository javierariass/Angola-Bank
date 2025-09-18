import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarRating extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;

  const StarRating({
    super.key,
    this.initialRating = 3.0,
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
    return SizedBox(
      width: 220,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 32,
            ratingWidget: RatingWidget(
              full: const Icon(Icons.star, color: Colors.amber),
              half: const Icon(Icons.star_half, color: Colors.amber),
              empty: const Icon(Icons.star_border, color: Colors.amber),
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
            updateOnDrag: false,
          ),
          const SizedBox(height: 10),
          Text(
            'Avaliação: ${_rating.toStringAsFixed(1)} estrelas',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              widget.onRatingChanged(_rating);
            },
            child: const Text('Avaliar'),
          ),
        ],
      ),
    );
  }
}
