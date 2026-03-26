import 'package:catat_cuan/domain/core/result.dart';

/// Repository interface untuk seeding kategori default
///
/// Following Interface Segregation Principle (ISP) - hanya berisi operasi seeding
///
/// Responsibility: Menyiapkan data awal kategori default
abstract class CategorySeedingRepository {
  /// Mengecek apakah perlu seed default categories
  ///
  /// Mengembalikan Result dengan true jika perlu seed, false jika sudah ada data
  Future<Result<bool>> needsSeed();

  /// Seed default categories ke database
  ///
  /// Menambahkan kategori-kategori default untuk income dan expense
  ///
  /// Mengembalikan Result yang sukses jika seeding berhasil
  /// Mengembalikan DatabaseFailure jika terjadi kesalahan database
  Future<Result<void>> seedDefaultCategories();
}
