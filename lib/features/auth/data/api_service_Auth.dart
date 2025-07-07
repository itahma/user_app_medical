import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceAuth {
  final Dio dio;

  ApiServiceAuth()
      : dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.52.128:8000', // !! استبدل هذا بعنوان الخادم لديك
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    ),
  ) {
    // Interceptor لإضافة التوكن تلقائيًا لكل طلب مصادق عليه
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final prefs = await SharedPreferences.getInstance();
      // استخدام مفتاح توكن خاص بالمريض لتجنب التضارب مع تطبيق الطبيب
      final token = prefs.getString('x-jwt');
      if (token != null) {
        options.headers['x-jwt'] = token;
      }
      return handler.next(options);
    }));
  }

  // --- دوال المصادقة الخاصة بالمريض ---

  // دالة تسجيل الدخول
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final response = await dio.post('/api/Auth/login', data: {'email': email, 'password': password});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل تسجيل الدخول');
    }
  }

  // دالة حفظ توكن الإشعارات
  Future<void> saveFCMToken(String fcmToken) async {
    try {
      // الـ Interceptor سيضيف توكن المصادقة المحفوظ تلقائيًا
      await dio.post('/api/notification/save-token', data: {'fcmToken': fcmToken});
      print("FCM Token saved successfully on server for patient.");
    } on DioException catch (e) {
      // فشل صامت في الخلفية
      print("Failed to save FCM token for patient: ${e.response?.data}");
    }
  }

  // الخطوة 1: إرسال الإيميل للحصول على كود
  Future<void> registerPatient(String email) async {
    try {
      await dio.post('/api/Auth/register', data: {'email': email, 'role': 'User'});
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'فشل إرسال الطلب');
    }
  }
  Future<Map<String, dynamic>> verifyAndCompleteProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/api/user/adduserProfile', data: data);

      // --- بداية الإضافة: أسطر الطباعة التشخيصية ---
      print("--- RAW SERVER RESPONSE FROM /adduserProfile ---");
      print("Status Code: ${response.statusCode}");
      print("Response Data Type: ${response.data.runtimeType}");
      print("Response Data: ${response.data}");
      print("Response Headers: ${response.headers}");
      print("------------------------------------------");
      // --- نهاية الإضافة ---

      final token = response.headers.value('x-jwt');

      // التأكد من أن جسم الاستجابة هو خريطة
      if (token != null && response.data is Map<String, dynamic>) {
        return {'token': token, 'user': response.data};
      } else {
        throw Exception('استجابة الخادم غير متوقعة أو ينقصها التوكن.');
      }

    } on DioException catch (e) {
      // طباعة الخطأ من الخادم في حالة فشل الطلب
      print("--- DIO EXCEPTION in verifyAndCompleteProfile ---");
      print("Server Response Data: ${e.response?.data}");
      print("--------------------------------------------");
      throw Exception(e.response?.data['message'] ?? 'فشل استكمال الملف الشخصي');
    }
  }

  Future<void> forgotPasswordSendCode(String email) async {
    try {
      await dio.post('/api/Auth/sendcode', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل إرسال الكود');
    }
  }
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await dio.put(
          '/api/Auth/registerwithcode',
          data: {
            'email': email,
            'code': int.parse(code), // الـ backend يتوقع الكود كرقم
            'password': newPassword
          }
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل إعادة تعيين كلمة المرور');
    }
  }
}