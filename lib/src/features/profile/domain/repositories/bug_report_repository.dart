import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';

final class BugReportRepository {
  factory BugReportRepository() {
    _instance ??= BugReportRepository._internal();
    return _instance!;
  }

  BugReportRepository._internal();

  static BugReportRepository? _instance;
  final Dio _dio = DioClient().dio;

  Future<Either<ApiException, BugReportItem>> submitBugReport({
    required String text,
    String? title,
    String? description,
    List<XFile>? images,
    XFile? image,
    String status = 'not_resolved',
  }) async {
    try {
      final titleText = (title != null && title.trim().isNotEmpty)
          ? title.trim()
          : text.trim();
      final descText = (description != null && description.trim().isNotEmpty)
          ? description.trim()
          : text.trim();

      final formData = FormData.fromMap({
        'title': titleText,
        'subject': titleText,
        'text': titleText,
        'description': descText,
        'status': status,
      });

      final filesToUpload = <XFile>[];
      if (images != null && images.isNotEmpty) {
        filesToUpload.addAll(images);
      } else if (image != null) {
        filesToUpload.add(image);
      }

      for (int i = 0; i < filesToUpload.length; i++) {
        final img = filesToUpload[i];
        final filename = img.name.isNotEmpty
            ? img.name
            : 'bug_screenshot_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(img.path, filename: filename),
          ),
        );

        if (i == 0) {
          formData.files.add(
            MapEntry(
              'image',
              await MultipartFile.fromFile(img.path, filename: filename),
            ),
          );
        }
      }

      final response = await _dio.post<dynamic>(
        ApiUris.bugReport,
        data: formData,
        options: Options(
          headers: {
            'X-Platform': platformSource,
          },
        ).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        if (response.data != null) {
          if (response.data is Map) {
            final map = Map<String, dynamic>.from(response.data as Map);
            final dataObj = map['data'] ?? map;
            if (dataObj is Map) {
              return right(
                BugReportItem.fromJson(Map<String, dynamic>.from(dataObj)),
              );
            }
          }
        }
        return right(
          BugReportItem(
            title: titleText,
            subject: titleText,
            text: titleText,
            description: descText,
            status: status,
            statusDisplay: 'Not Resolved',
          ),
        );
      }

      return left(
        ApiException.unknown(
          msg: 'Unable to submit bug report. Please try again later.',
        ),
      );
    } on DioException catch (e) {
      debugPrint('BugReportRepository submit error: $e');
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.isNotEmpty) {
          final msg = data['message'] ?? data['detail'] ?? data['error'];
          if (msg != null) {
            return left(ApiException.unknown(msg: msg.toString()));
          }
          final firstKey = data.keys.first;
          final val = data[firstKey];
          final msgStr = (val is List && val.isNotEmpty)
              ? val.first.toString()
              : val.toString();
          return left(ApiException.unknown(msg: AppErrorHandler.formatUserFriendlyMessage(msgStr, fallback: 'Invalid bug report details.')));
        } else if (data is String && data.isNotEmpty) {
          return left(ApiException.unknown(msg: AppErrorHandler.extractSafeValidationMessage(data, fallback: 'Unable to submit bug report.')));
        }
      }
      return left(ApiException.unknown(msg: AppErrorHandler.extractSafeMessage(e, fallback: 'Network error occurred while submitting report.')));
    } catch (e) {
      debugPrint('BugReportRepository submit unknown error: $e');
      return left(const ApiException.unknown(msg: 'Unable to complete bug report request. Please try again.'));
    }
  }

  Future<Either<ApiException, List<BugReportItem>>> getBugReports() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiUris.bugReport,
        options: Options(
          headers: {
            'X-Platform': platformSource,
          },
        ).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200) {
        final reports = <BugReportItem>[];
        dynamic listData;
        if (response.data is Map) {
          final map = response.data as Map;
          if (map['data'] is List) {
            listData = map['data'];
          } else if (map['results'] is List) {
            listData = map['results'];
          } else if (map['data'] is Map && (map['data'] as Map)['results'] is List) {
            listData = (map['data'] as Map)['results'];
          } else if (map['data'] is Map) {
            final inner = map['data'] as Map;
            for (final key in ['reports', 'items', 'bug_reports', 'data']) {
              if (inner[key] is List) {
                listData = inner[key];
                break;
              }
            }
          }
        } else if (response.data is List) {
          listData = response.data;
        }

        if (listData is List) {
          for (final item in listData) {
            if (item is Map) {
              reports.add(BugReportItem.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
        return right(reports);
      }

      return left(
        ApiException.unknown(
          msg: 'Unable to fetch bug reports. Please try again later.',
        ),
      );
    } on DioException catch (e) {
      debugPrint('BugReportRepository get error: $e');
      return left(ApiException.unknown(msg: AppErrorHandler.extractSafeMessage(e, fallback: 'Network error occurred while submitting report.')));
    } catch (e) {
      debugPrint('BugReportRepository get unknown error: $e');
      return left(const ApiException.unknown(msg: 'Unable to complete bug report request. Please try again.'));
    }
  }

  Future<Either<ApiException, bool>> deleteBugReport(int id) async {
    try {
      final response = await _dio.delete<dynamic>(
        ApiUris.bugReportDetail(id),
        options: Options(
          headers: {
            'X-Platform': platformSource,
          },
        ).token,
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) {
        return right(true);
      }
      return left(
        ApiException.unknown(
          msg: 'Unable to delete bug report. Please try again later.',
        ),
      );
    } on DioException catch (e) {
      debugPrint('BugReportRepository delete error: $e');
      return left(ApiException.unknown(msg: AppErrorHandler.extractSafeMessage(e, fallback: 'Network error occurred while submitting report.')));
    } catch (e) {
      return left(const ApiException.unknown(msg: 'Unable to complete bug report request. Please try again.'));
    }
  }
}

