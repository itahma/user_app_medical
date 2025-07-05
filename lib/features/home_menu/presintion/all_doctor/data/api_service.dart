
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

class ApiServiceAllDoctor {
  final Dio dio;

  // Constructor
  ApiServiceAllDoctor()
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

  Future<List<dynamic>> getAllDoctors() async {
    try {
      final response = await dio.get('/api/user/showallDoctor');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب قائمة الأطباء');
    }
  }
}