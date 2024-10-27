import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6, // Number of skeleton items
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // Changes position of shadow
                ),
              ],
            ),
            child: Row(
              children: [
                // Placeholder for the music note icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Placeholder color
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 40,
                    color: Colors.grey, // Icon color
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title skeleton with loading text
                      SizedBox(
                        height: 6,
                        width: double.infinity,
                        child: Container(
                          color: Colors.grey[300], // Placeholder for title
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Subtitle skeleton with loading text
                      SizedBox(
                        height: 6,
                        width: double.infinity,
                        child: Container(
                          color: Colors.grey[300], // Placeholder for title
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 6,
                        width: double.infinity,
                        child: Container(
                          color: Colors.grey[300], // Placeholder for title
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 6,
                        width: double.infinity,
                        child: Container(
                          color: Colors.grey[300], // Placeholder for title
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 6,
                        width: 80,
                        child: Container(
                          color: Colors.grey[300], // Placeholder for subtitle
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Container with shimmer text effect for additional loading text
                      SizedBox(
                        height: 6,
                        width: 100,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Text(
                            'Loading...', // Placeholder text
                            style: TextStyle(
                              color: const Color.fromARGB(255, 15, 6, 6),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                        width: 100,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Text(
                            'Loading...', // Placeholder text
                            style: TextStyle(
                              color: const Color.fromARGB(255, 15, 6, 6),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                        width: 100,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Text(
                            'Loading...', // Placeholder text
                            style: TextStyle(
                              color: const Color.fromARGB(255, 15, 6, 6),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                        width: 100,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Text(
                            'Loading...', // Placeholder text
                            style: TextStyle(
                              color: const Color.fromARGB(255, 15, 6, 6),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
