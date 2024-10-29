class Music {
  final String title;
  final String songUrl;
  final String albumImageUrl;
  final String genre;
  final int noOfPlays;

  Music({
    required this.title,
    required this.songUrl,
    required this.albumImageUrl,
    required this.genre,
    required this.noOfPlays,
  });

  // Add a factory constructor to parse JSON data
  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      title: json['Title'],
      songUrl: json['upload song']['value'],
      albumImageUrl: json['upload album image']['value'],
      genre: json['Genre'],
      noOfPlays: int.parse(json['no of plays']),
    );
  }

  // Override toString to print the Music instance values
  @override
  String toString() {
    return 'Music(title: $title, songUrl: $songUrl, albumImageUrl: $albumImageUrl, genre: $genre, noOfPlays: $noOfPlays)';
  }
}
