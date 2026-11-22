// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PackEasy';

  @override
  String get welcome => 'Welcome to PackEasy';

  @override
  String get login => 'Sign in';

  @override
  String get register => 'Sign up';

  @override
  String get logout => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get home => 'Home';

  @override
  String get favorites => 'Favorites';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get language => 'Language';

  @override
  String get search => 'Search a city, a country...';

  @override
  String get destinations => 'Destinations';

  @override
  String get programs => 'Programs & stays';

  @override
  String get trips => 'Upcoming trips';

  @override
  String get noDestination => 'No destination found';

  @override
  String get noProgram => 'No program available';

  @override
  String get noTrip => 'No trip planned';

  @override
  String get loading => 'Preparing your trip...';

  @override
  String get profile => 'Profile';

  @override
  String get admin => 'Administrator';

  @override
  String get user => 'Traveler';

  @override
  String get addDestination => 'Add a destination';

  @override
  String get addProgram => 'Create a program';

  @override
  String get addTrip => 'Add a trip';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get errorEmail => 'Invalid email';

  @override
  String get errorPassword => 'Password must be at least 6 characters';

  @override
  String get errorPasswordMismatch => 'Passwords do not match';

  @override
  String get monEspace => 'My Space';

  @override
  String get discover => 'Discover';

  @override
  String get profileTab => 'Profile';

  @override
  String get backToApp => 'Back to app';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get users => 'Users';

  @override
  String get upcomingDepartures => 'Upcoming departures';

  @override
  String get noUpcomingTrip => 'No upcoming trip.';

  @override
  String get retry => 'Try again';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorLoading => 'Unable to load data';

  @override
  String get errorNetwork => 'Check your internet connection';

  @override
  String get add => 'Add';

  @override
  String get create => 'Create';

  @override
  String get close => 'Close';

  @override
  String get deleted => 'Deleted';

  @override
  String get saved => 'Saved';

  @override
  String get loginRequired => 'Sign in to continue';

  @override
  String get view => 'View';

  @override
  String get guest => 'Guest';

  @override
  String get errorRequired => 'This field is required';

  @override
  String get errorNumber => 'Enter a valid number';

  @override
  String get errorPositive => 'Enter a value greater than 0';

  @override
  String errorMinLength(int min) {
    return 'At least $min characters';
  }

  @override
  String get errorUrl => 'Invalid URL (start with http or https)';

  @override
  String get errorDate => 'Invalid date (DD/MM/YYYY)';

  @override
  String get errorDateOrder => 'End date must be after the start date';

  @override
  String get errorAmount => 'Enter a valid amount (greater than 0)';

  @override
  String get errorBudget => 'Enter a valid budget (number greater than 0)';

  @override
  String get errorDestination => 'Enter a destination (at least 2 characters)';

  @override
  String get errorName => 'Enter your name (at least 2 characters)';

  @override
  String get errorItemExists => 'This item already exists';

  @override
  String get authInvalidCredential => 'Incorrect email or password';

  @override
  String get authUserNotFound => 'No account found for this email';

  @override
  String get authEmailInUse => 'This email is already in use';

  @override
  String get authWeakPassword => 'Password is too weak';

  @override
  String get authNetwork => 'Network problem';

  @override
  String get authTooMany => 'Too many attempts, try again later';

  @override
  String get authCancelled => 'Google sign-in cancelled';

  @override
  String get authUnknown => 'Authentication failed';

  @override
  String get loginSuccess => 'Signed in';

  @override
  String get welcomeBack => 'Welcome back to PackEasy!';

  @override
  String get registerSuccess => 'Account created';

  @override
  String get welcomeNew => 'Welcome! Your account was created successfully.';

  @override
  String get loginTitle => 'Welcome back!';

  @override
  String get createAccount => 'Create an account';

  @override
  String get continueGoogle => 'Continue with Google';

  @override
  String get noAccount => 'No account? Sign up';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get resetTitle => 'Password reset';

  @override
  String get resetHint => 'Enter your email to receive a link.';

  @override
  String get sendLink => 'Send link';

  @override
  String get resetSent => 'Email sent, check your inbox';

  @override
  String get onbTitle => 'Your ultimate travel guide.';

  @override
  String get onbSubtitle =>
      'Find the destination that fits your budget, plan your visits and pack your bags.';

  @override
  String get start => 'Get started';

  @override
  String destinationsCount(int count) {
    return '$count destinations - 5 continents';
  }

  @override
  String get phrase1 => 'Where do you want to go?';

  @override
  String get phrase2 => 'Dream beaches';

  @override
  String get phrase3 => 'Unforgettable cities';

  @override
  String get phrase4 => 'Nature adventures';

  @override
  String get phrase5 => 'Culture and history';

  @override
  String get changeTheme => 'Change theme';

  @override
  String get all => 'All';

  @override
  String get africa => 'Africa';

  @override
  String get europe => 'Europe';

  @override
  String get asia => 'Asia';

  @override
  String get america => 'America';

  @override
  String get oceania => 'Oceania';

  @override
  String get beach => 'Beach';

  @override
  String get culture => 'Culture';

  @override
  String get nature => 'Nature';

  @override
  String get city => 'City';

  @override
  String get practicalInfo => 'Practical info';

  @override
  String get bestSeason => 'Best season';

  @override
  String get avgTemp => 'Average temperature';

  @override
  String get languages => 'Languages';

  @override
  String get currency => 'Currency';

  @override
  String get mustSee => 'Must see';

  @override
  String budgetIndicative(int budget) {
    return 'Estimated budget: ~€$budget / person';
  }

  @override
  String get createTrip => 'Create a trip';

  @override
  String tripCreated(String destination) {
    return 'Trip to $destination created';
  }

  @override
  String get reservationConfirmed => 'Booking confirmed';

  @override
  String reservationBody(String destination) {
    return 'Your trip to $destination has been booked.';
  }

  @override
  String addedToFavorites(String name) {
    return '$name added to favorites';
  }

  @override
  String removedFromFavorites(String name) {
    return '$name removed from favorites';
  }

  @override
  String get liveWeather => 'Live weather';

  @override
  String get weatherUnavailable => 'Weather unavailable for this destination';

  @override
  String wind(String speed) {
    return 'Wind: $speed km/h';
  }

  @override
  String get weatherClear => 'Clear sky';

  @override
  String get weatherCloudy => 'Cloudy';

  @override
  String get weatherFog => 'Fog';

  @override
  String get weatherRain => 'Rain';

  @override
  String get weatherSnow => 'Snow';

  @override
  String get weatherStorm => 'Thunderstorm';

  @override
  String get mySpace => 'My traveler space';

  @override
  String get myTrips => 'My trips';

  @override
  String get budget => 'Budget';

  @override
  String get myBag => 'My suitcase';

  @override
  String get exploreDestinations => 'Explore destinations';

  @override
  String hello(String name) {
    return 'Hello, $name';
  }

  @override
  String get readyAdventure => 'Ready for your next adventure?';

  @override
  String get noTripPlanned => 'No trip planned';

  @override
  String get noTripHint => 'Explore destinations or create your first trip.';

  @override
  String get explore => 'Explore';

  @override
  String get newTrip => 'New trip';

  @override
  String get expense => 'Expense';

  @override
  String get item => 'Item';

  @override
  String get tripsLabel => 'Trips';

  @override
  String get spent => 'Spent';

  @override
  String get bag => 'Suitcase';

  @override
  String get quickAccess => 'Quick access';

  @override
  String daysLeft(int days) {
    return 'D-$days';
  }

  @override
  String get today => 'Today';

  @override
  String get ongoing => 'Ongoing';

  @override
  String daysAndBudget(int days, int budget) {
    return '$days days • Budget €$budget';
  }

  @override
  String get upcoming => 'Upcoming';

  @override
  String get noUpcomingTrips => 'No upcoming trips';

  @override
  String get noPastTrips => 'No past trips';

  @override
  String get destination => 'Destination';

  @override
  String get budgetEuro => 'Budget (€)';

  @override
  String get chooseDates => 'Choose dates';

  @override
  String get chooseDatesError => 'Choose the trip dates';

  @override
  String tripDeleted(String destination) {
    return 'Trip to $destination deleted';
  }

  @override
  String get createFirstTrip => 'Create a trip first';

  @override
  String get budgetLinked => 'The budget is linked to your next trip.';

  @override
  String budgetOf(int amount) {
    return 'Budget: €$amount';
  }

  @override
  String spentOf(int amount) {
    return 'Spent: €$amount';
  }

  @override
  String remaining(int amount) {
    return 'Remaining: €$amount';
  }

  @override
  String overBudget(int amount) {
    return 'Over budget: €$amount';
  }

  @override
  String get byCategory => 'By category';

  @override
  String get expenses => 'Expenses';

  @override
  String get noExpense => 'No expenses yet';

  @override
  String get addExpense => 'Add an expense';

  @override
  String get description => 'Description';

  @override
  String get amountEuro => 'Amount (€)';

  @override
  String get category => 'Category';

  @override
  String get expenseAdded => 'Expense added';

  @override
  String get catTransport => 'Transport';

  @override
  String get catLodging => 'Accommodation';

  @override
  String get catFood => 'Food';

  @override
  String get catActivities => 'Activities';

  @override
  String get catOther => 'Other';

  @override
  String packedCount(int done, int total) {
    return '$done / $total items packed';
  }

  @override
  String get readyToFly => 'Ready for takeoff!';

  @override
  String get bagEmpty => 'Your suitcase is empty';

  @override
  String get addItem => 'Add an item';

  @override
  String get itemHint => 'E.g. Umbrella';

  @override
  String get sugPassport => 'Passport';

  @override
  String get sugCharger => 'Phone charger';

  @override
  String get sugToiletries => 'Toiletry bag';

  @override
  String get sugClothes => 'Clothes';

  @override
  String get sugUmbrella => 'Umbrella';

  @override
  String get sugSwimsuit => 'Swimsuit';

  @override
  String get sugAdapter => 'Plug adapter';

  @override
  String get sugSunglasses => 'Sunglasses';

  @override
  String get sugSunscreen => 'Sunscreen';

  @override
  String get sugMedicine => 'Medicines';

  @override
  String get sugHeadphones => 'Headphones';

  @override
  String get sugBankCard => 'Bank card';

  @override
  String get tripDetails => 'Trip details';

  @override
  String get dates => 'Dates';

  @override
  String durationDays(int days) {
    return '$days days';
  }

  @override
  String get tripExpenses => 'Trip expenses';

  @override
  String get deleteTrip => 'Delete trip';

  @override
  String get confirmDelete => 'Confirm deletion?';

  @override
  String tripFromTo(String start, String end) {
    return 'From $start to $end';
  }

  @override
  String get fullName => 'Full name';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get role => 'Role';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get notifications => 'Notifications';

  @override
  String get offersNotif => 'Receive offers and news';

  @override
  String get testNotification => 'Test a notification';

  @override
  String get testNotifBody => 'Tap here to open your trips.';

  @override
  String get about => 'About';

  @override
  String get aboutText =>
      'PackEasy helps you choose, plan and pack for your trips.';

  @override
  String get version => 'Version';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get noFavoritesHint =>
      'Tap the heart on a destination to add it here.';

  @override
  String get currencyConverter => 'Currency converter';

  @override
  String get amount => 'Amount';

  @override
  String get baseCurrency => 'From currency';

  @override
  String get exchangeRates => 'Exchange rates';

  @override
  String get ratesError => 'Unable to load exchange rates';

  @override
  String lastUpdate(String date) {
    return 'Updated: $date';
  }

  @override
  String get adminGreeting => 'Hello, Admin';

  @override
  String get adminTitle => 'PackEasy Admin';

  @override
  String get name => 'Name';

  @override
  String get country => 'Country';

  @override
  String get flagEmoji => 'Flag emoji';

  @override
  String get continent => 'Continent';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get programTitle => 'Program title';

  @override
  String get programType => 'Program type';

  @override
  String get durationField => 'Duration (days)';

  @override
  String get priceEuro => 'Price (€)';

  @override
  String get tripTitle => 'Trip title';

  @override
  String get startDate => 'Start date (DD/MM/YYYY)';

  @override
  String get endDate => 'End date (DD/MM/YYYY)';

  @override
  String departure(String date) {
    return 'Departure: $date';
  }

  @override
  String get noNotification => 'No notifications';

  @override
  String get importSamples => 'Import sample destinations';

  @override
  String samplesImported(int count) {
    return '$count destinations imported';
  }

  @override
  String get typeSeminar => 'Seminar';

  @override
  String get typeGroup => 'Group trip';

  @override
  String get typeEurope => 'Europe tour';

  @override
  String get typeAdventure => 'Adventure';

  @override
  String get typeRelax => 'Relaxation';

  @override
  String get typeOther => 'Other';

  @override
  String durationShort(int days) {
    return '$days d';
  }
}
