import 'dart:typed_data';

import 'package:flutter/material.dart';

class DisplayImage extends StatelessWidget {
  const DisplayImage(
      {super.key,
      required this.imageFile,
      required this.isImageProcessing,
      this.probability});
  final Uint8List imageFile;
  final bool isImageProcessing;
  final double? probability;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: width * 0.3,
            maxWidth: width * 0.6,
            maxHeight: height * 0.5,
            minHeight: height * 0.3,
          ),
          child: Image.memory(
            imageFile,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'Error loading image',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 32,
                  ),
                ),
              );
            },
          ),
        ),
        if (isImageProcessing) ...[
          RefreshProgressIndicator(
            color: Colors.blue,
            strokeWidth: 2,
            elevation: 0,
          ),
          const Text(
            'It may take a while to process...',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text.rich(
              TextSpan(
                text: 'The probability that the image is ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
                children: [
                  TextSpan(
                    text: 'AI generated',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' is: ',
                  ),
                  if (probability == null)
                    TextSpan(
                      text: 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    TextSpan(
                      text: '${(probability! * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: probability! <= 0.3
                            ? Colors.green
                            : probability! <= 0.7
                                ? Colors.amber
                                : Colors.redAccent,
                      ),
                    )
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}
