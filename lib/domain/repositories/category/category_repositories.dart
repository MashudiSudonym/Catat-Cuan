/// Segregated repository interfaces for Category operations
///
/// Following Interface Segregation Principle (ISP), these interfaces
/// split the monolithic CategoryRepository into focused, single-responsibility
/// interfaces.
///
/// Clients should depend only on the interfaces they need:
/// - CategoryReadRepository: For reading category data
/// - CategoryWriteRepository: For creating/updating/deleting categories
/// - CategoryManagementRepository: For reordering and active/inactive management
/// - CategorySeedingRepository: For seeding default categories
library;

// Basic CRUD operations
export 'category_read_repository.dart';
export 'category_write_repository.dart';

// Management operations
export 'category_management_repository.dart';

// Seeding operations
export 'category_seeding_repository.dart';
