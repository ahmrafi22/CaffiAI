class Cafe {
  final String name;
  final String location;
  final List<String> tags;
  final int from;
  final double rating;
  final double lat;
  final double lon;
  final String? image; // optional image id or url-part

  const Cafe({
    required this.name,
    required this.location,
    required this.tags,
    required this.from,
    required this.rating,
    required this.lat,
    required this.lon,
    this.image,
  });
}

// A small sample list reused by HomePage and MapPage. Coordinates are approximate.
const List<Cafe> cafesList = [
  Cafe(
    name: 'BrewLab',
    location: 'Banani • Dhaka',
    tags: ['Specialty brew', 'Pour over', 'Desserts'],
    from: 180,
    rating: 4.8,
    lat: 23.7926,
    lon: 90.4079,
    image: null,
  ),
  Cafe(
    name: 'Roast House',
    location: 'Gulshan • Dhaka',
    tags: ['Single origin', 'Cold brew', 'Bakery'],
    from: 220,
    rating: 4.6,
    lat: 23.7938,
    lon: 90.4067,
    image: null,
  ),
  Cafe(
    name: 'Midnight Bean',
    location: 'Dhanmondi • Dhaka',
    tags: ['Espresso bar', 'Filter', 'Local snacks'],
    from: 140,
    rating: 4.9,
    lat: 23.7465,
    lon: 90.3760,
    image: null,
  ),
  Cafe(
    name: 'Latte Lane',
    location: 'Old Dhaka',
    tags: ['Art café', 'Brunch', 'Signature latte'],
    from: 200,
    rating: 4.7,
    lat: 23.7236,
    lon: 90.4065,
    image: null,
  ),
  Cafe(
    name: 'Caffe Dhaka Central',
    location: 'Banani • Dhaka',
    tags: ['Specialty brew', 'Pour over', 'Desserts'],
    from: 180,
    rating: 4.7,
    lat: 23.7940,
    lon: 90.4090,
    image: null,
  ),
  Cafe(
    name: 'Riverfront Roastery',
    location: 'Gulshan • Dhaka',
    tags: ['Single origin', 'Cold brew', 'Bakery'],
    from: 220,
    rating: 4.9,
    lat: 23.8045,
    lon: 90.4040,
    image: null,
  ),
  Cafe(
    name: 'Old Town Espresso',
    location: 'Old Dhaka',
    tags: ['Espresso bar', 'Filter', 'Local snacks'],
    from: 140,
    rating: 4.5,
    lat: 23.7280,
    lon: 90.4100,
    image: null,
  ),
  Cafe(
    name: 'Gallery Café',
    location: 'Dhanmondi • Dhaka',
    tags: ['Art café', 'Brunch', 'Signature latte'],
    from: 200,
    rating: 4.6,
    lat: 23.7440,
    lon: 90.3600,
    image: null,
  ),
];
