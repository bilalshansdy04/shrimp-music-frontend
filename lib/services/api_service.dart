import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/song.dart';
import '../models/universal_search_data.dart';
import '../models/artist_profile_data.dart';
import '../models/album_profile_data.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl = 'http://127.0.0.1:8080/api/v1';
  final String authUrl = 'http://127.0.0.1:8080/api/auth';
  String? _token;

  ApiService() : _dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8080/api/v1', connectTimeout: const Duration(seconds: 10))) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
    ));
  }

  void setToken(String? token) {
    _token = token;
  }

  Future<String> login(String username, String password) async {
    try {
      final response = await Dio().post('$authUrl/login', data: {
        'username': username,
        'password': password,
        'device_name': 'Web/Desktop Client'
      });
      if (response.statusCode == 200) {
        return response.data['token'];
      }
      throw Exception('Failed to login');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data.toString().trim() ?? 'Login failed');
      }
      throw Exception(e.message);
    }
  }

  Future<void> register(String username, String password) async {
    try {
      final response = await Dio().post('$authUrl/register', data: {
        'username': username,
        'password': password,
      });
      if (response.statusCode != 201) {
        throw Exception('Failed to register');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data.toString().trim() ?? 'Registration failed');
      }
      throw Exception(e.message);
    }
  }

  Future<bool> checkUsername(String username) async {
    final response = await Dio().post('$authUrl/check-username', data: {
      'username': username,
    });
    if (response.statusCode == 200) {
      if (response.data is String) {
        
        return jsonDecode(response.data)['exists'] as bool;
      }
      return response.data['exists'] as bool;
    }
    throw Exception('Failed to check username');
  }

  Future<List<dynamic>> getPlaylists() async {
    final response = await _dio.get('/playlists');
    return response.data;
  }

  Future<void> createPlaylist(String name, String description) async {
    await _dio.post('/playlists', data: {'name': name, 'description': description});
  }

  Future<void> deletePlaylist(String id) async {
    await _dio.delete('/playlists', queryParameters: {'id': id});
  }

  Future<List<dynamic>> getPlaylistTracks(String id) async {
    final response = await _dio.get('/playlists/tracks', queryParameters: {'id': id});
    return response.data;
  }

  Future<void> addTrackToPlaylist(String playlistId, Map<String, dynamic> track) async {
    await _dio.post('/playlists/tracks', queryParameters: {'id': playlistId}, data: {
      'id': track['id'],
      'title': track['title'],
      'artist': track['artist'] ?? '',
      'thumbnail': track['thumbnail'] ?? '',
      'duration_seconds': track['duration'] ?? 0,
    });
  }

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    await _dio.delete('/playlists/tracks', queryParameters: {'id': playlistId, 'track_id': trackId});
  }

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



