import 'dart:io';

import 'package:dio/dio.dart';
import 'package:newappgradu/core/database/api/end_points.dart';
import 'package:shared_preferences/shared_preferences.dart';

// افترض أن هذه الدالة تحصل على التوكن. استبدلها بالمنطق الفعلي لديك.
Future<String?> _getAuthToken() async {
  // مثال:
  // final prefs = await SharedPreferences.getInstance();
  // return prefs.getString('user_token');
  // بما أنك ذكرت أن التوكن هو 'x-jwt'، سنفترض أنه مخزن بنفس الاسم.
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('x-jwt');
}

class ApiServiceChat {
  final Dio dio;

  // Constructor
  ApiServiceChat()
      : dio = Dio(BaseOptions(
    // عنوان URL الأساسي للـ API الخاص بك
    baseUrl: '${EndPoint.host}',
    // تحديد نوع المحتوى لجميع الطلبات
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
  )) {
    // يمكنك إضافة Interceptors هنا لمراقبة الطلبات أو إضافة التوكن تلقائيًا
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // جلب التوكن وإضافته إلى الهيدر قبل إرسال الطلب
          final token = await _getAuthToken();
          if (token != null) {
            // استخدام 'x-jwt' كهيدر للمصادقة كما طلبت
            options.headers['x-jwt'] = token;
          }
          return handler.next(options); // استكمال الطلب
        },
        onResponse: (response, handler) {
          // يمكنك التعامل مع الاستجابات هنا
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // يمكنك التعامل مع الأخطاء هنا
          return handler.next(e);
        },
      ),
    );
  }

  
  // GET /getCommunications - جلب قائمة المحادثات
  Future<List<dynamic>> getConversations() async {
    try {
      final response = await dio.get('/api/user/getCommunications');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب المحادثات');
    }
  }

  // GET /getCommunications/:id - جلب كل الرسائل بين طرفين
  Future<List<dynamic>> getChatHistory(String otherUserId) async {
    try {
      final response = await dio.get('/api/user/getCommunications/$otherUserId');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب سجل المحادثة');
    }
  }

  // POST /addCommunication/:id - إرسال رسالة جديدة
  Future<void> sendMessage({
    required String receiverId,
    String? message,
    File? image,
    File? pdf, // يمكنك إضافة دعم للـ pdf إذا أردت
  }) async {
    try {
      final formData = FormData.fromMap({
        if (message != null && message.isNotEmpty) 'message': message,
      });

      if (image != null) {
        formData.files.add(MapEntry('image', await MultipartFile.fromFile(image.path)));
      }
      if (pdf != null) {
        formData.files.add(MapEntry('pdf', await MultipartFile.fromFile(pdf.path)));
      }

      // إذا لم يتم إرسال رسالة أو ملف، لا ترسل الطلب
      if (formData.fields.isEmpty && formData.files.isEmpty) return;

      await dio.post('/api/user/addCommunication/$receiverId', data: formData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل إرسال الرسالة');
    }
  }


}