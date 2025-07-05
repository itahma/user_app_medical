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

class ApiService {
  final Dio dio;

  // Constructor
  ApiService()
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

  // POST /searchDoctors
  Future<List<dynamic>> searchDoctors(Map<String, dynamic> filters) async {
    try {
      // إزالة أي مفاتيح لها قيم فارغة من الفلاتر قبل إرسالها
      filters.removeWhere((key, value) => value == null || value == '');

      final response = await dio.post('/api/user/searchDoctors', data: filters);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      // إذا كان الخطأ 404، يعني لا يوجد نتائج، نرجع قائمة فارغة
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception(e.response?.data['message'] ?? 'فشل البحث');
    }
  }

  // GET /showDoctorInfo/:id
  Future<Map<String, dynamic>> getDoctorDetails(String doctorId) async {
    try {
      final response = await dio.get('/api/user/showDoctorInfo/$doctorId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل جلب تفاصيل الطبيب');
    }
  }
  Future<void> rateDoctor({
    required String doctorId,
    required double rating,
  }) async {
    try {
      // بناءً على قائمة المسارات السابقة، هذا هو المسار الصحيح
      await dio.post(
        '/api/user/rateDoctor/$doctorId',
        data: {'rating': rating},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل إرسال التقييم');
    }
  }
  // --- بداية الإضافة: دالة جلب أقرب موعد متاح ---
  Future<Map<String, dynamic>> getNextAvailableSlot(String doctorId, {String? centerId}) async {
    try {
      // بناء المسار مع centerId الاختياري
      String path = '/api/user/nextAvailableSlot/$doctorId';
      if (centerId != null) {
        path += '/$centerId';
      }

      final response = await dio.get(path);
      // الـ backend يرجع كائن يحتوي على تاريخ ووقت الموعد
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // التعامل مع رسائل الخطأ مثل "No available slots found"
      throw Exception(e.response?.data['message'] ?? 'فشل العثور على موعد متاح');
    }
  }
}