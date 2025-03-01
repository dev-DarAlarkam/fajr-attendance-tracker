class Dictionary {

  static const String title = "برنامج المحاسبة الرمضاني";

  //general messaages
  static const String welcome = "السلام عليكم";
  static const String signIn = "تسجيل الدخول";
  static const String googleSignIn = "تسجيل الدخول باستخدام جوجل";
  static const String signUp = 'إنشاء حساب جديد';

  //Email Messages
  static const String email = "البريد الإلكتروني";
  static const String emailInput = "أدخل بريدك الإلكتروني";
  static const String emailConfirmation = "تأكيد البريد الإلكتروني";
  static const String emailFormatErrorMessage = "الرجاء إدخال بريد إلكتروني صالح";
  static const String emailConfirmationErrorMessage = "الرجاء إدخال بريد إلكتروني مطابق";
  static const String emailVerificationMessage = "تم إرسال رسالة تأكيد لبريدك الإلكتروني";


  //Password Messages
  static const String password = "كلمة المرور";
  static const String passwordInput = "أدخل كلمة المرور";
  static const String passwordConfirmation = "تأكيد كلمة المرور";
  static const String passwordLengthErrorMessage = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
  static const String passwordFormatErrorMessage = 'يجب أن تحتوي كلمة المرور على أحرف بالانجليزية وأرقام';
  static const String passwordConfirmationErrorMessage = "الرجاء إدخال كلمة مرور مطابقة";
  
  //Forgot Password Messages
  static const String forgetPassword = 'نسيت كلمة المرور؟';
  static const String resetPassword = 'اعادة ضبط كلمة المرور';
  static const String resetPasswordSuccess = 'تم إرسال رسالة لبريدك الالكتروني';

  //Form Messages
  static const String emptyFieldErrorMessage = 'هذا الحقل مطلوب';
  static const String nonArabicErrorMessage = 'الرجاء إدخال نص باللغة العربية فقط';

  //Profile Messages
  static const String profile = "الملف الشخصي";
  static const String createProfile = "إنشاء ملف شخصي";


  //Group Messages
  static const String createGroup = "إنشاء مجموعة";
  static const String createGroupSuccess = "تم إنشاء مجموعة جديدة بنجاح";
  static const String joinGroup = "إنضم لمجموعة";
  static const String joinGroupInput = "أدخل رمز المجموعة";
  
  
  //Attendance Messages
  static const String attendanceTracker = "تسجيل حضور لصلاة الفجر";
  static const String createAttendanceRecord = "تسجيل الحضور";
  static const String attendanceRecordSuccess = "تم التسجيل بنجاح";
  static const String attendanceRecordDuplicate = "لقد قمت بالتسجيل هذا اليوم";
  static const String attendanceRecordBlocked = "هذه الخاصية مغلقة حالياً";

  //days of week
  static const List<String> daysOfWeek = [
    "الأحد",
    "الإثنين",
    "الثلاثاء",
    "الأربعاء",
    "الخميس",
    "الجمعة",
    "السبت",
  ];


  static const List<String> prayerDoneTypes = [
    "جماعة",
    "حاضر",
    "قضاء",
    "لم أصلي"
  ];
  
}