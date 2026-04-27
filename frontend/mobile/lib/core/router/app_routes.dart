class AppRoutes {
  static const String splash = '/';
  static const String authPrefix = '/auth';
  static const String volunteerPrefix = '/volunteer';
  static const String ngoPrefix = '/ngo';
  static const String sponsorPrefix = '/sponsor';
  static const String adminPrefix = '/admin';

  static const String authVolunteer = '/auth/volunteer';
  static const String authNgo = '/auth/ngo';

  static const String volunteerMap = '/volunteer/map';
  static const String volunteerTasks = '/volunteer/tasks';
  static const String volunteerWallet = '/volunteer/wallet';
  static const String volunteerProfile = '/volunteer/profile';
  static const String volunteerVerifyBase = '/volunteer/verify';

  static const String ngoDashboard = '/ngo/dashboard';
  static const String ngoTasks = '/ngo/tasks';
  static const String ngoVolunteers = '/ngo/volunteers';
  static const String ngoReports = '/ngo/reports';

  static const String sponsorDashboard = '/sponsor/dashboard';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminTasks = '/admin/tasks';
  static const String adminReports = '/admin/reports';

  static String volunteerVerify(String id) => '$volunteerVerifyBase/$id';
}
