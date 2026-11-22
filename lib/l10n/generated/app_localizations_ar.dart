// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'باك إيزي';

  @override
  String get welcome => 'مرحبا بك في باك إيزي';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get home => 'الرئيسية';

  @override
  String get favorites => 'المفضلة';

  @override
  String get history => 'السجل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get darkTheme => 'الوضع الداكن';

  @override
  String get language => 'اللغة';

  @override
  String get search => 'ابحث عن مدينة أو بلد...';

  @override
  String get destinations => 'الوجهات';

  @override
  String get programs => 'البرامج والإقامات';

  @override
  String get trips => 'الرحلات القادمة';

  @override
  String get noDestination => 'لم يتم العثور على وجهة';

  @override
  String get noProgram => 'لا يوجد برنامج متاح';

  @override
  String get noTrip => 'لا توجد رحلة مخططة';

  @override
  String get loading => 'جاري تحضير رحلتك...';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get admin => 'مدير';

  @override
  String get user => 'مسافر';

  @override
  String get addDestination => 'إضافة وجهة';

  @override
  String get addProgram => 'إنشاء برنامج';

  @override
  String get addTrip => 'إضافة رحلة';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get errorEmail => 'البريد الإلكتروني غير صالح';

  @override
  String get errorPassword => 'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل';

  @override
  String get errorPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get monEspace => 'مساحتي';

  @override
  String get discover => 'اكتشف';

  @override
  String get profileTab => 'الملف الشخصي';

  @override
  String get backToApp => 'العودة إلى التطبيق';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get users => 'المستخدمون';

  @override
  String get upcomingDepartures => 'الرحلات القادمة';

  @override
  String get noUpcomingTrip => 'لا توجد رحلات قادمة.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errorLoading => 'تعذر تحميل البيانات';

  @override
  String get errorNetwork => 'تحقق من اتصالك بالإنترنت';

  @override
  String get add => 'إضافة';

  @override
  String get create => 'إنشاء';

  @override
  String get close => 'إغلاق';

  @override
  String get deleted => 'تم الحذف';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get loginRequired => 'سجّل الدخول للمتابعة';

  @override
  String get view => 'عرض';

  @override
  String get guest => 'زائر';

  @override
  String get errorRequired => 'هذا الحقل مطلوب';

  @override
  String get errorNumber => 'أدخل رقمًا صالحًا';

  @override
  String get errorPositive => 'أدخل قيمة أكبر من 0';

  @override
  String errorMinLength(int min) {
    return '$min أحرف على الأقل';
  }

  @override
  String get errorUrl => 'رابط غير صالح (يبدأ بـ http أو https)';

  @override
  String get errorDate => 'تاريخ غير صالح (يوم/شهر/سنة)';

  @override
  String get errorDateOrder => 'يجب أن يكون تاريخ النهاية بعد تاريخ البداية';

  @override
  String get errorAmount => 'أدخل مبلغًا صالحًا (أكبر من 0)';

  @override
  String get errorBudget => 'أدخل ميزانية صالحة (رقم أكبر من 0)';

  @override
  String get errorDestination => 'أدخل وجهة (حرفان على الأقل)';

  @override
  String get errorName => 'أدخل اسمك (حرفان على الأقل)';

  @override
  String get errorItemExists => 'هذا الغرض موجود بالفعل';

  @override
  String get authInvalidCredential =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get authUserNotFound => 'لا يوجد حساب بهذا البريد الإلكتروني';

  @override
  String get authEmailInUse => 'هذا البريد الإلكتروني مستخدم بالفعل';

  @override
  String get authWeakPassword => 'كلمة المرور ضعيفة جدًا';

  @override
  String get authNetwork => 'مشكلة في الاتصال بالإنترنت';

  @override
  String get authTooMany => 'محاولات كثيرة، حاول لاحقًا';

  @override
  String get authCancelled => 'تم إلغاء تسجيل الدخول عبر جوجل';

  @override
  String get authUnknown => 'فشلت المصادقة';

  @override
  String get loginSuccess => 'تم تسجيل الدخول';

  @override
  String get welcomeBack => 'سعداء برؤيتك مجددًا في باك إيزي!';

  @override
  String get registerSuccess => 'تم إنشاء الحساب';

  @override
  String get welcomeNew => 'مرحبًا! تم إنشاء حسابك بنجاح.';

  @override
  String get loginTitle => 'مرحبًا بعودتك!';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get continueGoogle => 'المتابعة عبر جوجل';

  @override
  String get noAccount => 'ليس لديك حساب؟ سجّل الآن';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get resetTitle => 'إعادة التعيين';

  @override
  String get resetHint => 'أدخل بريدك الإلكتروني لتلقي رابط.';

  @override
  String get sendLink => 'إرسال الرابط';

  @override
  String get resetSent => 'تم إرسال البريد، تحقق من صندوق الوارد';

  @override
  String get onbTitle => 'دليلك الأفضل للسفر.';

  @override
  String get onbSubtitle =>
      'اعثر على الوجهة المناسبة لميزانيتك، وخطط لزياراتك وجهّز حقائبك.';

  @override
  String get start => 'ابدأ';

  @override
  String destinationsCount(int count) {
    return '$count وجهة - 5 قارات';
  }

  @override
  String get phrase1 => 'إلى أين تريد الذهاب؟';

  @override
  String get phrase2 => 'شواطئ الأحلام';

  @override
  String get phrase3 => 'مدن لا تُنسى';

  @override
  String get phrase4 => 'مغامرات الطبيعة';

  @override
  String get phrase5 => 'الثقافة والتاريخ';

  @override
  String get changeTheme => 'تغيير المظهر';

  @override
  String get all => 'الكل';

  @override
  String get africa => 'أفريقيا';

  @override
  String get europe => 'أوروبا';

  @override
  String get asia => 'آسيا';

  @override
  String get america => 'أمريكا';

  @override
  String get oceania => 'أوقيانوسيا';

  @override
  String get beach => 'شاطئ';

  @override
  String get culture => 'ثقافة';

  @override
  String get nature => 'طبيعة';

  @override
  String get city => 'مدينة';

  @override
  String get practicalInfo => 'معلومات عملية';

  @override
  String get bestSeason => 'أفضل موسم';

  @override
  String get avgTemp => 'متوسط الحرارة';

  @override
  String get languages => 'اللغات';

  @override
  String get currency => 'العملة';

  @override
  String get mustSee => 'لا تفوّت';

  @override
  String budgetIndicative(int budget) {
    return 'الميزانية التقريبية: ~$budget € للشخص';
  }

  @override
  String get createTrip => 'إنشاء رحلة';

  @override
  String tripCreated(String destination) {
    return 'تم إنشاء رحلة إلى $destination';
  }

  @override
  String get reservationConfirmed => 'تم تأكيد الحجز';

  @override
  String reservationBody(String destination) {
    return 'تم حجز رحلتك إلى $destination بنجاح.';
  }

  @override
  String addedToFavorites(String name) {
    return 'تمت إضافة $name إلى المفضلة';
  }

  @override
  String removedFromFavorites(String name) {
    return 'تمت إزالة $name من المفضلة';
  }

  @override
  String get liveWeather => 'الطقس الآن';

  @override
  String get weatherUnavailable => 'الطقس غير متوفر لهذه الوجهة';

  @override
  String wind(String speed) {
    return 'الرياح: $speed كم/س';
  }

  @override
  String get weatherClear => 'سماء صافية';

  @override
  String get weatherCloudy => 'غائم';

  @override
  String get weatherFog => 'ضباب';

  @override
  String get weatherRain => 'مطر';

  @override
  String get weatherSnow => 'ثلج';

  @override
  String get weatherStorm => 'عاصفة رعدية';

  @override
  String get mySpace => 'مساحتي كمسافر';

  @override
  String get myTrips => 'رحلاتي';

  @override
  String get budget => 'الميزانية';

  @override
  String get myBag => 'حقيبتي';

  @override
  String get exploreDestinations => 'استكشف الوجهات';

  @override
  String hello(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get readyAdventure => 'هل أنت مستعد لمغامرتك القادمة؟';

  @override
  String get noTripPlanned => 'لا توجد رحلة مخططة';

  @override
  String get noTripHint => 'استكشف الوجهات أو أنشئ رحلتك الأولى.';

  @override
  String get explore => 'استكشاف';

  @override
  String get newTrip => 'رحلة جديدة';

  @override
  String get expense => 'مصروف';

  @override
  String get item => 'غرض';

  @override
  String get tripsLabel => 'الرحلات';

  @override
  String get spent => 'المصروف';

  @override
  String get bag => 'الحقيبة';

  @override
  String get quickAccess => 'وصول سريع';

  @override
  String daysLeft(int days) {
    return 'متبقي $days يوم';
  }

  @override
  String get today => 'اليوم';

  @override
  String get ongoing => 'جارية';

  @override
  String daysAndBudget(int days, int budget) {
    return '$days أيام • الميزانية $budget €';
  }

  @override
  String get upcoming => 'القادمة';

  @override
  String get noUpcomingTrips => 'لا توجد رحلات قادمة';

  @override
  String get noPastTrips => 'لا توجد رحلات سابقة';

  @override
  String get destination => 'الوجهة';

  @override
  String get budgetEuro => 'الميزانية (€)';

  @override
  String get chooseDates => 'اختر التواريخ';

  @override
  String get chooseDatesError => 'اختر تواريخ الرحلة';

  @override
  String tripDeleted(String destination) {
    return 'تم حذف الرحلة إلى $destination';
  }

  @override
  String get createFirstTrip => 'أنشئ رحلة أولاً';

  @override
  String get budgetLinked => 'الميزانية مرتبطة برحلتك القادمة.';

  @override
  String budgetOf(int amount) {
    return 'الميزانية: $amount €';
  }

  @override
  String spentOf(int amount) {
    return 'المصروف: $amount €';
  }

  @override
  String remaining(int amount) {
    return 'المتبقي: $amount €';
  }

  @override
  String overBudget(int amount) {
    return 'تجاوز الميزانية: $amount €';
  }

  @override
  String get byCategory => 'حسب الفئة';

  @override
  String get expenses => 'المصروفات';

  @override
  String get noExpense => 'لا توجد مصروفات بعد';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get description => 'الوصف';

  @override
  String get amountEuro => 'المبلغ (€)';

  @override
  String get category => 'الفئة';

  @override
  String get expenseAdded => 'تمت إضافة المصروف';

  @override
  String get catTransport => 'نقل';

  @override
  String get catLodging => 'إقامة';

  @override
  String get catFood => 'طعام';

  @override
  String get catActivities => 'أنشطة';

  @override
  String get catOther => 'أخرى';

  @override
  String packedCount(int done, int total) {
    return '$done / $total أغراض جاهزة';
  }

  @override
  String get readyToFly => 'جاهز للإقلاع!';

  @override
  String get bagEmpty => 'حقيبتك فارغة';

  @override
  String get addItem => 'إضافة غرض';

  @override
  String get itemHint => 'مثال: مظلة';

  @override
  String get sugPassport => 'جواز السفر';

  @override
  String get sugCharger => 'شاحن الهاتف';

  @override
  String get sugToiletries => 'حقيبة أدوات النظافة';

  @override
  String get sugClothes => 'ملابس';

  @override
  String get sugUmbrella => 'مظلة';

  @override
  String get sugSwimsuit => 'ملابس سباحة';

  @override
  String get sugAdapter => 'محول كهرباء';

  @override
  String get sugSunglasses => 'نظارات شمسية';

  @override
  String get sugSunscreen => 'واقي الشمس';

  @override
  String get sugMedicine => 'أدوية';

  @override
  String get sugHeadphones => 'سماعات';

  @override
  String get sugBankCard => 'بطاقة بنكية';

  @override
  String get tripDetails => 'تفاصيل الرحلة';

  @override
  String get dates => 'التواريخ';

  @override
  String durationDays(int days) {
    return '$days أيام';
  }

  @override
  String get tripExpenses => 'مصروفات الرحلة';

  @override
  String get deleteTrip => 'حذف الرحلة';

  @override
  String get confirmDelete => 'تأكيد الحذف؟';

  @override
  String tripFromTo(String start, String end) {
    return 'من $start إلى $end';
  }

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get role => 'الدور';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeLabel => 'السمة';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get offersNotif => 'تلقي العروض والأخبار';

  @override
  String get testNotification => 'تجربة إشعار';

  @override
  String get testNotifBody => 'اضغط هنا لفتح رحلاتك.';

  @override
  String get about => 'حول التطبيق';

  @override
  String get aboutText =>
      'باك إيزي يساعدك على اختيار رحلاتك والتخطيط لها وتجهيز حقائبك.';

  @override
  String get version => 'الإصدار';

  @override
  String get noFavorites => 'لا توجد مفضلات بعد';

  @override
  String get noFavoritesHint => 'اضغط على القلب في أي وجهة لإضافتها هنا.';

  @override
  String get currencyConverter => 'محول العملات';

  @override
  String get amount => 'المبلغ';

  @override
  String get baseCurrency => 'العملة الأصلية';

  @override
  String get exchangeRates => 'أسعار الصرف';

  @override
  String get ratesError => 'تعذر تحميل أسعار الصرف';

  @override
  String lastUpdate(String date) {
    return 'آخر تحديث: $date';
  }

  @override
  String get adminGreeting => 'مرحبًا أيها المشرف';

  @override
  String get adminTitle => 'مشرف باك إيزي';

  @override
  String get name => 'الاسم';

  @override
  String get country => 'البلد';

  @override
  String get flagEmoji => 'رمز العلم';

  @override
  String get continent => 'القارة';

  @override
  String get imageUrl => 'رابط الصورة';

  @override
  String get programTitle => 'عنوان البرنامج';

  @override
  String get programType => 'نوع البرنامج';

  @override
  String get durationField => 'المدة (أيام)';

  @override
  String get priceEuro => 'السعر (€)';

  @override
  String get tripTitle => 'عنوان الرحلة';

  @override
  String get startDate => 'تاريخ البداية (يوم/شهر/سنة)';

  @override
  String get endDate => 'تاريخ النهاية (يوم/شهر/سنة)';

  @override
  String departure(String date) {
    return 'المغادرة: $date';
  }

  @override
  String get noNotification => 'لا توجد إشعارات';

  @override
  String get importSamples => 'استيراد وجهات تجريبية';

  @override
  String samplesImported(int count) {
    return 'تم استيراد $count وجهة';
  }

  @override
  String get typeSeminar => 'ندوة';

  @override
  String get typeGroup => 'رحلة جماعية';

  @override
  String get typeEurope => 'جولة أوروبية';

  @override
  String get typeAdventure => 'مغامرة';

  @override
  String get typeRelax => 'استرخاء';

  @override
  String get typeOther => 'أخرى';

  @override
  String durationShort(int days) {
    return '$days يوم';
  }
}
