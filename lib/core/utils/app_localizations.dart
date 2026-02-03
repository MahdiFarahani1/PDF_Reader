import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'loading': 'Loading',
      'failed_load_pdf': 'Failed to load PDF',
      'loading_epub': 'Loading EPUB...',
      'unsupported_file_type': 'Unsupported file type',
      'supported_types_info':
          'The app currently supports PDF, EPUB, TXT, Word, and Excel files.',
      'error_reading_file': 'Error reading file',
      'external_app_support': 'This file format is supported via external app',
      'could_not_open_file': 'Could not open file',
      'pick_color': 'Pick a color',
      'more_colors': 'More colors',
      'select': 'Select',
      'search_files_hint': 'Search files...',
      'no_files_found': 'No files found',
      'no_files_found_desc':
          'Try adding files to your Documents or Downloads folder',
      'files_param': 'Files',
      'error_importing': 'Error importing file',
      'biometric_auth_failed': 'Biometric authentication failed',
      '6-digit PIN': '6-digit PIN',
      'Re-enter PIN': 'Re-enter PIN',
      'PIN must be at least 4 digits': 'PIN must be at least 4 digits',
      'PINs do not match': 'PINs do not match',
      'Create a PIN to secure your app': 'Create a PIN to secure your app',

      'Set up PIN': 'Set up PIN',
      'preparing_page_image': 'Preparing page image...',
      'offf': 'of',
      'importing_file': 'Importing file...',
      'app_name': 'Document Reader',
      'my_library': 'My Library',
      'no_documents': 'No documents found',
      'tap_to_import': 'Tap + to import a file',
      'import': 'Import',
      'settings': 'Settings',
      'search': 'Search',
      'bookmarks': 'Bookmarks',
      'highlights': 'Highlights',
      'font_size': 'Font Size',
      'reading_mode': 'Reading Mode',
      'vertical': 'Vertical',
      'horizontal': 'Horizontal',
      'app_lock': 'App Lock',
      'set_pin': 'Set PIN',
      'change_pin': 'Change PIN',
      'enable_biometrics': 'Enable Biometrics',
      'language': 'Language',
      'english': 'English',
      'persian': 'فارسی',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'add_bookmark': 'Add Bookmark',
      'highlight_text': 'Highlight Text',
      'add_note': 'Add Note',
      'search_in_document': 'Search in document...',
      'no_bookmarks': 'No bookmarks yet',
      'no_highlights': 'No highlights yet',
      'enter_pin': 'Enter PIN',
      'unlock': 'Unlock',
      'use_biometrics': 'Use Biometrics',
      'reading_preferences': 'Reading Preferences',
      'line_height': 'Line Height',
      'margins': 'Margins',
      'font_family': 'Font Family',
      'background_color': 'Background Color',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'ok': 'OK',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'name': 'Name',
      'share': 'Share',
      'open_with_external': 'Open with External App',
      'move_to_category': 'Move to Category',
      'details': 'Details',
      'rename': 'Rename',
      'PDFDocument': 'PDF Document',
      'epubDocument': 'EPUB Document',
      'txtDocument': 'Text Document',
      'wordDocument': 'Word Document',
      'sheetDocument': 'Sheet Document',
      'others': 'Others',
      'imported': 'Imported',
      'scan_device': 'Scan Device',
      'select_cat': 'Select a category to find files on your device',
      'no_docs_in_category': 'No documents in this category',
      'clear_filter': 'Clear Filter',
      'new_category': 'New Category',
      'enter_category_name': 'Enter category name:',
      'category_created': 'Category created',
      'all': 'All',
      'delete_category': 'Delete Category',
      'delete_category_desc': 'Are you sure? Files will not be deleted.',
      'unknown': 'Unknown',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'days_ago': 'days ago',
      'rename_file': 'Rename File',
      'enter_new_name': 'Enter a new name for',
      'file_renamed': 'File renamed successfully',
      'delete_file': 'Delete File',
      'delete_file_desc': 'Are you sure you want to delete',
      'file_deleted': 'File deleted',
      'file_details': 'File Details',
      'no_categories': 'No categories found. Create one first!',
      'move_to_category_title': 'Move to Category',
      'uncategorized': 'Uncategorized',
      'moved_to_uncategorized': 'Moved to Uncategorized',
      'moved_to': 'Moved to',
      'share_text': 'Check out this document:',
      'share_image': 'Share Image',
      'share_page_as_image': 'Share Page as Image',
      'path': 'Path',
      'size': 'Size',
      'type': 'Type',
      'added': 'Added',
      'page': 'Page',
      'PIN set successfully': 'PIN set successfully',
      'invalidPin': 'Invalid PIN',
    },

    'fa': {
      'loading': 'در حال بارگذاری',
      'failed_load_pdf': 'خطا در بارگذاری PDF',
      'loading_epub': 'در حال بارگذاری EPUB...',
      'unsupported_file_type': 'فرمت فایل پشتیبانی نمی‌شود',
      'supported_types_info':
          'این برنامه فعلا از PDF, EPUB, TXT, Word و Excel پشتیبانی می‌کند.',
      'error_reading_file': 'خطا در خواندن فایل',
      'external_app_support': 'این فرمت فایل توسط برنامه خارجی پشتیبانی می‌شود',
      'could_not_open_file': 'امکان باز کردن فایل وجود ندارد',
      'pick_color': 'انتخاب رنگ',
      'more_colors': 'رنگ‌های بیشتر',
      'select': 'انتخاب',
      'search_files_hint': 'جستجوی فایل‌ها...',
      'no_files_found': 'فایلی یافت نشد',
      'no_files_found_desc':
          'سعی کنید فایل‌ها را به پوشه اسناد یا دانلودها اضافه کنید',
      'files_param': 'فایل‌های',
      'error_importing': 'خطا در وارد کردن فایل',
      'biometric_auth_failed': 'احراز هویت بیومتریک ناموفق بود',
      '6-digit PIN': 'حداکثر 6 رقم',
      'Re-enter PIN': 'رمز خود را تایید کنید',
      'PIN must be at least 4 digits': 'رمز باید حداقل 4 رقم باشد',
      'PINs do not match': 'رمز ها یکی نیستند',
      'Create a PIN to secure your app': 'ساخت یک رمز برای امنیت اطلاعات شما',
      'Set up PIN': 'تنظیم رمز',
      'offf': 'از',
      'preparing_page_image': 'در حال آماده کردن تصویر صفحه',
      'path': 'مسیر',
      'size': 'حجم',
      'type': 'نوع',
      'added': 'اضافه شده',
      'page': 'صفحه',
      'no_docs_in_category': 'سندی در این دسته وجود ندارد',
      'clear_filter': 'پاک کردن فیلتر',
      'new_category': 'دسته‌بندی جدید',
      'enter_category_name': 'نام دسته‌بندی را وارد کنید:',
      'category_created': 'دسته‌بندی ایجاد شد',
      'all': 'همه',
      'delete_category': 'حذف دسته‌بندی',
      'delete_category_desc': 'آیا مطمئن هستید؟ فایل‌ها حذف نخواهند شد.',
      'unknown': 'نامشخص',
      'today': 'امروز',
      'yesterday': 'دیروز',
      'days_ago': 'روز پیش',
      'rename_file': 'تغییر نام فایل',
      'enter_new_name': 'نام جدید را وارد کنید',
      'file_renamed': 'نام فایل با موفقیت تغییر کرد',
      'delete_file': 'حذف فایل',
      'delete_file_desc': 'آیا از حذف این فایل مطمئن هستید',
      'file_deleted': 'فایل حذف شد',
      'file_details': 'جزئیات فایل',
      'no_categories': 'دسته‌بندی‌ای وجود ندارد. ابتدا یکی بسازید!',
      'move_to_category_title': 'انتقال به دسته‌بندی',
      'uncategorized': 'بدون دسته‌بندی',
      'moved_to_uncategorized': 'به بدون دسته‌بندی منتقل شد',
      'moved_to': 'منتقل شد به',
      'share_text': 'این سند را ببین:',

      'select_cat': 'انتخاب یک دسته برای پیدا کردن فایل ها در دستگاه شما',
      'importing_file': 'در حال وارد کردن فایل...',
      'epubDocument': 'اسناد EPUB',
      'txtDocument': 'اسناد Text',
      'wordDocument': 'اسناد Word',
      'sheetDocument': 'اسناد Sheet',
      'others': 'سایر',
      'PDFDocument': 'اسناد PDF',
      'app_name': 'خواننده اسناد',
      'my_library': 'کتابخانه من',
      'no_documents': 'سندی یافت نشد',
      'tap_to_import': 'برای وارد کردن فایل + را بزنید',
      'import': 'وارد کردن',
      'settings': 'تنظیمات',
      'search': 'جستجو',
      'bookmarks': 'نشانک‌ها',
      'highlights': 'هایلایت‌ها',
      'font_size': 'اندازه فونت',
      'reading_mode': 'حالت خواندن',
      'vertical': 'عمودی',
      'horizontal': 'افقی',
      'app_lock': 'قفل برنامه',
      'set_pin': 'تنظیم رمز',
      'change_pin': 'تغییر رمز',
      'enable_biometrics': 'فعال‌سازی بیومتریک',
      'language': 'زبان',
      'english': 'English',
      'persian': 'فارسی',
      'theme': 'تم',
      'light': 'روشن',
      'dark': 'تیره',
      'system': 'سیستم',
      'add_bookmark': 'افزودن نشانک',
      'highlight_text': 'هایلایت متن',
      'add_note': 'افزودن یادداشت',
      'search_in_document': 'جستجو در سند...',
      'no_bookmarks': 'هنوز نشانکی ندارید',
      'no_highlights': 'هنوز هایلایتی ندارید',
      'enter_pin': 'رمز را وارد کنید',
      'unlock': 'باز کردن قفل',
      'use_biometrics': 'استفاده از بیومتریک',
      'reading_preferences': 'تنظیمات خواندن',
      'line_height': 'فاصله خطوط',
      'margins': 'حاشیه',
      'font_family': 'نوع فونت',
      'background_color': 'رنگ پس‌زمینه',
      'cancel': 'لغو',
      'save': 'ذخیره',
      'delete': 'حذف',
      'edit': 'ویرایش',
      'close': 'بستن',
      'ok': 'تایید',
      'confirm': 'تایید',
      'yes': 'بله',
      'no': 'خیر',
      'name': 'نام',
      'share': 'اشتراک‌گذاری',
      'open_with_external': 'باز کردن با برنامه خارجی',
      'move_to_category': 'انتقال به دسته‌بندی',
      'details': 'جزئیات',
      'rename': 'تغییر نام',
      'imported': 'وارد شده',
      'scan_device': 'اسکن دستگاه',
      'share_image': 'اشتراک گذاری تصویر',
      'share_page_as_image': 'اشتراک گذاری صفحه به عنوان تصویر',
      'PIN set successfully': 'رمز با موفقیت تنظیم شد',
      'invalidPin': 'رمز اشتباه است',
    },
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }

  String get appName => translate('app_name');
  String get myLibrary => translate('my_library');
  String get noDocuments => translate('no_documents');
  String get tapToImport => translate('tap_to_import');
  String get import => translate('import');
  String get settings => translate('settings');
  String get search => translate('search');
  String get bookmarks => translate('bookmarks');
  String get highlights => translate('highlights');
  String get fontSize => translate('font_size');
  String get readingMode => translate('reading_mode');
  String get vertical => translate('vertical');
  String get horizontal => translate('horizontal');
  String get appLock => translate('app_lock');
  String get setPin => translate('set_pin');
  String get changePin => translate('change_pin');
  String get enableBiometrics => translate('enable_biometrics');
  String get language => translate('language');
  String get english => translate('english');
  String get persian => translate('persian');
  String get theme => translate('theme');
  String get light => translate('light');
  String get dark => translate('dark');
  String get system => translate('system');
  String get addBookmark => translate('add_bookmark');
  String get highlightText => translate('highlight_text');
  String get addNote => translate('add_note');
  String get searchInDocument => translate('search_in_document');
  String get noBookmarks => translate('no_bookmarks');
  String get noHighlights => translate('no_highlights');
  String get enterPin => translate('enter_pin');
  String get unlock => translate('unlock');
  String get useBiometrics => translate('use_biometrics');
  String get readingPreferences => translate('reading_preferences');
  String get lineHeight => translate('line_height');
  String get margins => translate('margins');
  String get fontFamily => translate('font_family');
  String get backgroundColor => translate('background_color');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get close => translate('close');
  String get ok => translate('ok');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get name => translate('name');
  String get share => translate('share');
  String get openWithExternal => translate('open_with_external');
  String get moveToCategory => translate('move_to_category');
  String get details => translate('details');
  String get rename => translate('rename');
  String get pdfDocument => translate('PDFDocument');
  String get importingFile => translate('importing_file');
  String get epubDocument => translate('epubDocument');
  String get txtDocument => translate('txtDocument');
  String get wordDocument => translate('wordDocument');
  String get sheetDocument => translate('sheetDocument');
  String get others => translate('others');
  String get imported => translate('imported');
  String get scanDevice => translate('scan_device');
  String get selectCat => translate('select_cat');
  String get noDocsInCategory => translate('no_docs_in_category');
  String get clearFilter => translate('clear_filter');
  String get newCategory => translate('new_category');
  String get enterCategoryName => translate('enter_category_name');
  String get categoryCreated => translate('category_created');
  String get all => translate('all');
  String get deleteCategory => translate('delete_category');
  String get deleteCategoryDesc => translate('delete_category_desc');
  String get unknown => translate('unknown');
  String get today => translate('today');
  String get yesterday => translate('yesterday');
  String get daysAgo => translate('days_ago');
  String get renameFile => translate('rename_file');
  String get enterNewName => translate('enter_new_name');
  String get fileRenamed => translate('file_renamed');
  String get deleteFile => translate('delete_file');
  String get deleteFileDesc => translate('delete_file_desc');
  String get fileDeleted => translate('file_deleted');
  String get fileDetails => translate('file_details');
  String get noCategories => translate('no_categories');
  String get moveToCategoryTitle => translate('move_to_category_title');
  String get uncategorized => translate('uncategorized');
  String get movedToUncategorized => translate('moved_to_uncategorized');
  String get movedTo => translate('moved_to');
  String get shareText => translate('share_text');
  String get path => translate('path');
  String get size => translate('size');
  String get type => translate('type');
  String get added => translate('added');
  String get shareImage => translate('share_image');
  String get sharePageAsImage => translate('share_page_as_image');
  String get page => translate('page');
  String get offf => translate('offf');
  String get preparingPageImage => translate('preparing_page_image');
  String get setUpPin => translate('Set up PIN');
  String get createPin => translate('Create a PIN to secure your app');
  String get digitPIN => translate('6-digit PIN');
  String get reenterPIN => translate('Re-enter PIN');
  String get pINmustbeatleastdigits =>
      translate('PIN must be at least 4 digits');
  String get pinsNotMatch => translate('PINs do not match');
  String get pINsetsuccessfully => translate('PIN set successfully');
  String get invalidPin => translate('invalidPin');

  String get loading => translate('loading');
  String get failedLoadPdf => translate('failed_load_pdf');
  String get loadingEpub => translate('loading_epub');
  String get unsupportedFileType => translate('unsupported_file_type');
  String get supportedTypesInfo => translate('supported_types_info');
  String get errorReadingFile => translate('error_reading_file');
  String get externalAppSupport => translate('external_app_support');
  String get couldNotOpenFile => translate('could_not_open_file');
  String get pickColor => translate('pick_color');
  String get moreColors => translate('more_colors');
  String get select => translate('select');
  String get searchFilesHint => translate('search_files_hint');
  String get noFilesFound => translate('no_files_found');
  String get noFilesFoundDesc => translate('no_files_found_desc');
  String get filesParam => translate('files_param');
  String get errorImporting => translate('error_importing');
  String get biometricAuthFailed => translate('biometric_auth_failed');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fa'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
