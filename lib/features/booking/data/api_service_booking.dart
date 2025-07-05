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

class ApiServiceBooking {
  final Dio dio;

  // Constructor
  ApiServiceBooking()
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

  // GET /availableDays/:doctorId
  Future<List<dynamic>> getAvailableDays(String doctorId) async {
    try {
      final response = await dio.get('/api/user/availableDays/$doctorId');
      // الـ backend يرجع كائن يحتوي على قائمة، لذا نستخلصها
      return response.data['availableDays'] as List<dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب الأيام المتاحة');
    }
  }

  // GET /availableSlots/:doctorId/:date
  Future<List<dynamic>> getAvailableSlots({required String doctorId, required String date}) async {
    try {
      final response = await dio.get('/api/user/availableSlots/$doctorId/$date');
      return response.data['availableSlots'] as List<dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) return [];
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب الأوقات المتاحة');
    }
  }

  // POST /bookSlot/:doctorId
  Future<Map<String, dynamic>> bookSlot({
    required String doctorId,
    required String date,
    required String startTime,
  }) async {
    try {
      final response = await dio.post(
        '/api/user/bookSlot/$doctorId',
        data: {'date': date, 'start': startTime},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل إتمام الحجز');
    }
  }


  // GET /showMyBockings
  Future<List<dynamic>> getMyBookings() async {
    try {
      final response = await dio.get('/api/user/showMyBockings');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return []; // لا توجد حجوزات، وهذا طبيعي
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب الحجوزات');
    }
  }

  // POST /cancelBooking/:bookingId
  Future<void> cancelBooking(String bookingId) async {
    try {
      // الـ backend يتوقع طلب POST لإلغاء الحجز
      await dio.post('/api/user/cancelBooking/$bookingId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل إلغاء الحجز');
    }
  }


}