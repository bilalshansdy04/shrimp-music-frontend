import 'package:dio/dio.dart';
import '../models/song.dart';
import '../models/universal_search_data.dart';
import '../models/artist_profile_data.dart';
import '../models/album_profile_data.dart';

class ApiService {
  final Dio _dio;

  // Assuming Go backend is running locally on port 8080.
  // For Android emulator, use 10.0.2.2. For Windows/iOS simulator, use 127.0.0.1.
  static const String baseUrl = 'http://127.0.0.1:8080/api/v1';

  ApiService() : _dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10)));

  Future<UniversalSearchData> searchSongs(String query) async {
    try {
      final response = await _dio.get('/search', queryParameters: {'q': query, 'type': 'all'});
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UniversalSearchData.fromJson(data);
      }
      return UniversalSearchData(tracks: [], artists: [], albums: []);
    } catch (e) {
      throw Exception('Failed to search: $e');
    }
  }

  Future<ArtistProfileData> getArtist(String id) async {
    try {
      final response = await _dio.get('/artist', queryParameters: {'id': id});
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ArtistProfileData.fromJson(data);
      }
      throw Exception('Failed to load artist');
    } catch (e) {
      throw Exception('Failed to get artist: $e');
    }
  }

  Future<AlbumProfileData> getAlbum(String id) async {
    try {
      final response = await _dio.get('/album', queryParameters: {'id': id});
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return AlbumProfileData.fromJson(data);
      }
      throw Exception('Failed to load album');
    } catch (e) {
      throw Exception('Failed to get album: $e');
    }
  }

  Future<String> resolveStreamUrl(String videoId, {bool isVideo = false}) async {
    try {
      final type = isVideo ? 'video' : 'audio';
      final response = await _dio.get('/resolve/$videoId', queryParameters: {'format': type});
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data['stream_url'] as String;
      }
      throw Exception('Failed to resolve stream URL');
    } catch (e) {
      throw Exception('Resolve error: $e');
    }
  }
}
