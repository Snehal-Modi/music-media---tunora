/// Singers offered on the "pick your artists" screen, by language. Names are
/// looked up on JioSaavn for their photo, so a name that is not found is skipped.
const Map<String, List<String>> kPopularArtists = {
  'hindi': [
    'Arijit Singh', 'Shreya Ghoshal', 'Atif Aslam', 'Neha Kakkar', 'Jubin Nautiyal', 'Sonu Nigam',
    'Darshan Raval', 'Badshah', 'A. R. Rahman', 'Pritam', 'Armaan Malik', 'Vishal Mishra',
    'B Praak', 'Sunidhi Chauhan', 'KK', 'Kishore Kumar', 'Lata Mangeshkar', 'Mohammed Rafi',
    'Yo Yo Honey Singh', 'Tulsi Kumar',
  ],
  'english': [
    'Taylor Swift', 'Ed Sheeran', 'The Weeknd', 'Dua Lipa', 'Justin Bieber', 'Billie Eilish',
    'Coldplay', 'Imagine Dragons', 'Bruno Mars', 'Eminem',
  ],
  'punjabi': [
    'Diljit Dosanjh', 'Sidhu Moose Wala', 'AP Dhillon', 'Karan Aujla', 'Guru Randhawa', 'Jassie Gill',
    'Ammy Virk', 'Satinder Sartaaj',
  ],
  'gujarati': [
    'Kinjal Dave', 'Geeta Rabari', 'Jignesh Kaviraj', 'Aishwarya Majmudar', 'Falguni Pathak', 'Parthiv Gohil',
  ],
  'marathi': ['Ajay-Atul', 'Shankar Mahadevan', 'Adarsh Shinde', 'Avadhoot Gupte'],
  'tamil': ['Anirudh Ravichander', 'Sid Sriram', 'Yuvan Shankar Raja', 'Harris Jayaraj', 'Dhanush'],
  'telugu': ['Devi Sri Prasad', 'S. Thaman', 'Sid Sriram', 'M. M. Keeravani'],
  'kannada': ['Vijay Prakash', 'Sanjith Hegde', 'Arjun Janya'],
  'malayalam': ['K. S. Chithra', 'Vineeth Sreenivasan', 'Sushin Shyam'],
  'bengali': ['Anupam Roy', 'Arijit Singh', 'Shaan', 'Ujjaini Mukherjee'],
  'bhojpuri': ['Pawan Singh', 'Khesari Lal Yadav', 'Neelkamal Singh'],
  'haryanvi': ['Sapna Choudhary', 'Renuka Panwar', 'Masoom Sharma'],
  'rajasthani': ['Seema Mishra', 'Mame Khan'],
  'urdu': ['Nusrat Fateh Ali Khan', 'Rahat Fateh Ali Khan', 'Abida Parveen'],
};

/// The names to show for the chosen languages: Hindi first as the base, then
/// each language, without repeats.
List<String> popularArtistsFor(List<String> languages) {
  final out = <String>[];
  for (final l in {...languages, 'hindi'}) {
    for (final name in kPopularArtists[l] ?? const <String>[]) {
      if (!out.contains(name)) out.add(name);
    }
  }
  return out.take(40).toList();
}
