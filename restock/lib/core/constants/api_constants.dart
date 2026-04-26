// lib/core/constants/api_constants.dart
class ApiConstants {
  // Base
  static const String baseUrl = 'https://restock-platform.onrender.com/api/v1';
  //static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
  // -------------------------
  // AUTHENTICATION
  // -------------------------
  static const String loginEndpoint    = '/authentication/sign-in';
  static const String registerEndpoint = '/authentication/sign-up';

  // -------------------------
  // USERS
  // -------------------------
  static const String usersEndpoint = '/users';
  static String userById(int userId) => '/users/$userId';
  static String userSubscription(int userId) =>
      '/users/$userId/subscription';

  // -------------------------
  // PROFILES
  // -------------------------
  static String profileByUserId(int userId) =>
      '/profiles/$userId';

  static String profilePersonal(int userId) =>
      '/profiles/$userId/personal';

  static String profilePassword(int userId) =>
      '/profiles/$userId/password';

  static String profileBusiness(int userId) =>
      '/profiles/$userId/business';

  static String profileDelete(int userId) =>
      '/profiles/$userId';

  // -------------------------
  // SUPPLIES (oficiales)
  // -------------------------
  static const String suppliesEndpoint = '/supplies';
  static String supplyById(int supplyId) =>
      '/supplies/$supplyId';
  static const String supplyCategoriesEndpoint =
      '/supplies/categories';

  // -------------------------
  // CUSTOM SUPPLIES (usuario)
  // -------------------------
  static const String customSuppliesEndpoint = '/custom-supplies';
  static String customSupplyById(int id) =>
      '/custom-supplies/$id';
  static String customSuppliesByUserId(int userId) =>
      '/custom-supplies/user/$userId';

  // -------------------------
  // BATCHES
  // -------------------------
  static const String batchesEndpoint = '/batches';
  static String batchById(String id) => '/batches/$id';
  static String batchesByUserId(int userId) =>
      '/batches/user/$userId';

  // -------------------------
  // BUSINESS CATEGORIES
  // -------------------------
  static const String businessCategoriesEndpoint =
      '/business-categories';

  // -------------------------
  // ROLES
  // -------------------------
  static const String rolesEndpoint = '/roles';

  // -------------------------
  // ORDERS
  // -------------------------
  static const String ordersEndpoint = '/orders';
  static String orderById(int id) => '/orders/$id';
  static String orderDelete(int id) => '/orders/$id';
  static String ordersBySupplierId(int supplierId) =>
      '/orders/supplier/$supplierId';
  static String ordersByAdminRestaurantId(int adminRestaurantId) =>
      '/orders/admin-restaurant/$adminRestaurantId';
  static String orderState(int id) => '/orders/$id/state';

  static String orderUpdateState(int id) => '$ordersEndpoint/$id/state';
 
  static String orderUpdate(int id) => '$ordersEndpoint/$id';
 
  // -------------------------
  // RECIPES
  // -------------------------
  static const String recipesEndpoint = '/recipes';
  static String recipeById(int id) => '/recipes/$id';
  static String recipeSupplies(int id) => '/recipes/$id/supplies';
  static String recipeSupply(int recipeId, int supplyId) =>
      '/recipes/$recipeId/supplies/$supplyId';

  // -------------------------
  // SALES
  // -------------------------
  static const String salesEndpoint = '/sales';
  static String saleById(int id) => '/sales/$id';

  // -------------------------
  // SUBSCRIPTIONS
  // -------------------------
  static const String subscriptionsEndpoint = '/subscriptions';
  static String subscriptionByUserId(int userId) =>
      '/subscriptions/user/$userId';
}
