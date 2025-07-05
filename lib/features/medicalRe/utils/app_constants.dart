// Map لربط القيم المعروضة (العربية) بالقيم المرسلة للـ API (الإنجليزية)
const Map<String, String> familyRelationOptions = {
  'الأب': 'father',
  'الأم': 'mother',
  'الأخ': 'brother',
  'الأخت': 'sister',
  'الجد/الجدة': 'grandparent',
  'آخر': 'other',
};

// Map معكوس تم إنشاؤه تلقائيًا لترجمة القيم القادمة من الـ API إلى العربية بسهولة
final Map<String, String> familyRelationDisplayValues =
familyRelationOptions.map((key, value) => MapEntry(value, key));

// دالة مساعدة للحصول على النص العربي من القيمة الإنجليزية
String getRelationDisplayText(String? apiValue) {
  if (apiValue == null) return 'غير محدد';
  // البحث في الـ Map المعكوس. إذا لم يجد القيمة، يعرضها كما هي كحل احتياطي.
  return familyRelationDisplayValues[apiValue] ?? apiValue;
}
// --- بداية الإضافة: ثوابت الأمراض المزمنة ---
const Map<String, String> clinicalStatusOptions = {
  'نشط': 'active',
  'غير نشط': 'inactive',
  'تم الشفاء': 'resolved',
};
final Map<String, String> clinicalStatusDisplayValues =
clinicalStatusOptions.map((key, value) => MapEntry(value, key));

String getClinicalStatusDisplayText(String? apiValue) {
  if (apiValue == null) return 'غير محدد';
  return clinicalStatusDisplayValues[apiValue] ?? apiValue;
}
// --- نهاية الإضافة ---

// --- بداية الإضافة: ثوابت الحساسيات ---
const Map<String, String> allergyTypeOptions = {
  'حساسية دواء': 'medication',
  'حساسية طعام': 'food',
  'حساسية بيئية': 'environment',
};
final Map<String, String> allergyTypeDisplayValues =
allergyTypeOptions.map((key, value) => MapEntry(value, key));

String getAllergyTypeDisplayText(String? apiValue) {
  if (apiValue == null) return 'غير محدد';
  return allergyTypeDisplayValues[apiValue] ?? apiValue;
}