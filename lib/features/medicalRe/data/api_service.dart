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
  final Dio _dio;

  // Constructor
  ApiService()
      : _dio = Dio(BaseOptions(
    // عنوان URL الأساسي للـ API الخاص بك
    baseUrl: '${EndPoint.host}',
    // تحديد نوع المحتوى لجميع الطلبات
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
  )) {
    // يمكنك إضافة Interceptors هنا لمراقبة الطلبات أو إضافة التوكن تلقائيًا
    _dio.interceptors.add(
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

  // دالة لإضافة معلومات المريض
  Future<Map<String, dynamic>> addPatient(Map<String, dynamic> patientData) async {
    try {
      // إرسال طلب POST إلى /user/addPatient
      // Dio يضيف تلقائيًا baseUrl إلى المسار
      final response = await _dio.post('/api/user/addPatient', data: patientData);

      // Dio يعتبر الأكواد غير 2xx كخطأ تلقائيًا، لذا إذا وصل الكود إلى هنا فالطلب ناجح
      if (response.statusCode == 201) {
        return response.data; // إرجاع بيانات المريض التي تم إنشاؤها
      } else {
        // حالة غير متوقعة إذا لم يكن الخطأ ضمن DioException
        throw Exception('فشل إنشاء المريض: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // التعامل مع أخطاء Dio بشكل محدد
      if (e.response != null) {
        // إذا كان هناك استجابة من الخادم (مثل خطأ 400 أو 404)
        print('Error from server: ${e.response?.data}');
        // إرجاع رسالة الخطأ من الخادم
        throw Exception(e.response?.data['message'] ?? 'حدث خطأ من الخادم');
      } else {
        // إذا كان هناك خطأ في الشبكة أو الإعداد
        print('Dio error: ${e.message}');
        throw Exception('خطأ في الاتصال بالشبكة. يرجى التحقق من اتصالك.');
      }
    } catch (e) {
      // للتعامل مع أي أخطاء أخرى غير متوقعة
      print('Unexpected error: $e');
      throw Exception('حدث خطأ غير متوقع.');
    }
  }
  Future<Map<String, dynamic>> updatePatient(Map<String, dynamic> patientData) async {
    try {
      final response = await _dio.put('/api/user/updatePatient', data: patientData);
      if (response.statusCode == 200) { // استجابة التحديث الناجح عادة ما تكون 200 OK
        return response.data;
      } else {
        throw Exception('فشل تحديث المعلومات: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) throw Exception(e.response?.data['message'] ?? 'حدث خطأ من الخادم أثناء التحديث');
      throw Exception('خطأ في الاتصال بالشبكة.');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع أثناء التحديث.');
    }
  }
  Future<Map<String, dynamic>?> getMyPatientInfo() async {
    try {
      // إرسال طلب GET إلى /mypatient
      final response = await _dio.get('/api/user/mypatient');

      if (response.statusCode == 200) {
        // الـ Backend يُرجع مصفوفة (array) بناءً على استخدام Patient.find()
        // حتى لو كان هناك سجل واحد فقط، فإنه سيكون داخل مصفوفة.
        final List<dynamic> patientList = response.data;

        if (patientList.isNotEmpty) {
          // إذا كانت المصفوفة ليست فارغة، نرجع أول عنصر فيها
          return patientList[0] as Map<String, dynamic>;
        } else {
          // إذا كانت المصفوفة فارغة، هذا يعني أن المستخدم لم يضف بياناته بعد
          return null;
        }
      } else {
        throw Exception('فشل جلب البيانات: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // إذا كان الخطأ 404 (Not Found)، فهذا يعني غالبًا أن البروفايل أو المريض غير موجود
      if (e.response?.statusCode == 404) {
        return null; // نعاملها كحالة "لا توجد بيانات"
      }
      if (e.response != null) {
        print('Error from server (get): ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'حدث خطأ من الخادم');
      } else {
        print('Dio error (get): ${e.message}');
        throw Exception('خطأ في الاتصال بالشبكة. يرجى التحقق من اتصالك.');
      }
    } catch (e) {
      print('Unexpected error (get): $e');
      throw Exception('حدث خطأ غير متوقع.');
    }
  }



  // GET /myFamilyHistory
  Future<List<dynamic>> getFamilyHistory() async {
    try {
      final response = await _dio.get('/api/user/myFamilyHistory');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب تاريخ العائلة');
    }
  }

  // POST /add-family-history
  Future<Map<String, dynamic>> addFamilyHistory(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/user/add-family-history', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ في إضافة السجل');
    }
  }

  // PUT /updateFamilyHistory/:id
  Future<Map<String, dynamic>> updateFamilyHistory(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/user/updateFamilyHistory/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ في تحديث السجل');
    }
  }

  // DELETE /deleteFamilyHistory/:id
  Future<void> deleteFamilyHistory(String id) async {
    try {
      await _dio.delete('/api/user/deleteFamilyHistory/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ في حذف السجل');
    }
  }



  // --- بداية: دوال الأمراض المزمنة (Conditions) ---
  Future<List<dynamic>> getMyConditions() async {
    try {
      final response = await _dio.get('/api/user/myConditions');
      return response.data;
    } on DioException catch (e) { throw Exception(e.response?.data['message'] ?? 'خطأ في جلب الأمراض المزمنة'); }
  }

  Future<Map<String, dynamic>> addCondition(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/user/addCondition', data: data);
      return response.data;
    } on DioException catch (e) { throw Exception(e.response?.data['message'] ?? 'خطأ في إضافة المرض'); }
  }

  Future<Map<String, dynamic>> updateCondition(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/user/updateCondition/$id', data: data);
      return response.data;
    } on DioException catch (e) { throw Exception(e.response?.data['message'] ?? 'خطأ في تحديث المرض'); }
  }

  Future<void> deleteCondition(String id) async {
    try {
      await _dio.delete('/api/user/deleteCondition/$id');
    } on DioException catch (e) { throw Exception(e.response?.data['message'] ?? 'خطأ في حذف المرض'); }
  }
  // --- نهاية: دوال الأمراض المزمنة ---

  // --- بداية: دوال الحساسيات (Allergies) ---
  Future<List<dynamic>> getMyAllergies() async {
    try {
      final response = await _dio.get('/api/user/myAllergies');
      return response.data;
    } on DioException catch (e) { throw Exception(e.response?.data['message'] ?? 'خطأ في جلب الحساسيات'); }
  }

  Future<Map<String, dynamic>> addAllergy(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/user/addAllergy', data: data);
      return response.data;
    } on DioException catch (e) { throw Exception(e.response?.data['message'] ?? 'خطأ في إضافة الحساسية'); }
  }

  Future<Map<String, dynamic>> updateAllergy(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/user/updateAllergy/$id', data: data);
      return response.data;
    } on DioException catch (e) { throw Exception(e.response?.data['message'] ?? 'خطأ في تحديث الحساسية'); }
  }

  Future<void> deleteAllergy(String id) async {
    try {
      await _dio.delete('/api/user/deleteAllergy/$id');
    } on DioException catch (e) { throw Exception(e.response?.data['message'] ?? 'خطأ في حذف الحساسية'); }
  }

  // GET /myImmunizations
  Future<List<dynamic>> getImmunizations() async {
    try {
      final response = await _dio.get('/api/user/myImmunizations');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب اللقاحات');
    }
  }

  // POST /addImmunization
  Future<Map<String, dynamic>> addImmunization(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/user/addImmunization', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ في إضافة اللقاح');
    }
  }

  // PUT /updateImmunization/:id
  Future<Map<String, dynamic>> updateImmunization(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/user/updateImmunization/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ في تحديث اللقاح');
    }
  }

  // DELETE /deleteImmunization/:id
  Future<void> deleteImmunization(String id) async {
    try {
      await _dio.delete('/api/user/deleteImmunization/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ في حذف اللقاح');
    }
  }

  Future<Map<String, dynamic>> getEncounterDetails({
    required String userId, // ID المريض
    required String encounterId, // ID اللقاء
  }) async {
    try {
      // استدعاء المسار الجديد بالمعاملات المطلوبة
      final response = await _dio.get('/api/user/encounterDetails/$userId/$encounterId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل جلب تفاصيل اللقاء');
    }
  }

  Future<List<dynamic>> getMyMedications() async {
    try {
      // استدعاء المسار الجديد الذي أنشأناه للتو
      final response = await _dio.get('/api/user/myMedications');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // لا توجد أدوية، وهذا طبيعي
      }
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب الأدوية');
    }
  }
  Future<List<dynamic>> getMyEncounters() async {
    try {
      // استدعاء المسار الجديد الذي أنشأناه
      final response = await _dio.get('/api/user/myEncounters');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب اللقاءات');
    }
  }
  Future<List<dynamic>> getMyChronicConditions() async {
    try {
      final response = await _dio.get('/api/user/myChronicConditions');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب الأمراض المزمنة');
    }
  }

  // GET /myDiagnosedConditions
  Future<List<dynamic>> getMyDiagnosedConditions() async {
    try {
      final response = await _dio.get('/api/user/myDiagnosedConditions');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب التشخيصات');
    }
  }
  Future<List<dynamic>> getMyProcedures() async {
    try {
      // استدعاء المسار الجديد الذي أنشأناه للتو
      final response = await _dio.get('/api/user/myProcedures');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception(e.response?.data['message'] ?? 'خطأ في جلب العمليات الجراحية');
    }
  }
}