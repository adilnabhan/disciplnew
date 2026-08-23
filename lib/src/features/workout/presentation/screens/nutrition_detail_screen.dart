import 'package:flutter/material.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';

class NutritionDetailScreen extends StatelessWidget {
  const NutritionDetailScreen({
    super.key,
    this.foodName = "Salmon",
    this.mealType = "Dinner",
    this.serving = "100 g",
    this.calories = 146,
    this.proteinGrams = 22,
    this.carbsGrams = 0,
    this.fatGrams = 6,
    this.description = "Fresh Atlantic salmon fillet, a nutrient-dense source of high-quality protein and omega-3 fatty acids.",
    this.ingredients = "Salmon",
    this.imageUrl,
  });

  final String foodName;
  final String mealType;
  final String serving;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final String description;
  final String ingredients;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberWorkoutTheme.bgVoid,
      body: CustomScrollView(
        slivers: [
          // Hero Sliver App Bar with Food Image & Gradient
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: CyberWorkoutTheme.bgVoid,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: CircleAvatar(
                backgroundColor: const Color(0x66000000),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Food Artwork / Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2C3240), Color(0xFF16161F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 90,
                        color: CyberWorkoutTheme.goldPrimary.withOpacity(0.4),
                      ),
                    ),
                  ),

                  // Dark gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, CyberWorkoutTheme.bgVoid],
                        stops: [0.5, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Food Name & Meal Label
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mealType,
                          style: const TextStyle(
                            color: CyberWorkoutTheme.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Serving Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: CyberWorkoutTheme.glassCard(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "SERVING",
                          style: TextStyle(
                            color: CyberWorkoutTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          serving,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nutrition Dashboard Card (146 kcal / 22g Protein / 0g Carbs / 6g Fat)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: CyberWorkoutTheme.glassCard(
                      borderColor: CyberWorkoutTheme.borderGold,
                      glow: true,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Nutrition",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "For your logged serving ($serving)",
                          style: const TextStyle(
                            color: CyberWorkoutTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Calories Big Metric
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$calories",
                                  style: const TextStyle(
                                    color: CyberWorkoutTheme.goldPrimary,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "kcal",
                                  style: TextStyle(
                                    color: CyberWorkoutTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            // Protein
                            _buildMacroStat("${proteinGrams}g", "Protein", CyberWorkoutTheme.goldAccent),

                            // Carbs
                            _buildMacroStat("${carbsGrams}g", "Carbs", CyberWorkoutTheme.crimsonRed),

                            // Fat
                            _buildMacroStat("${fatGrams}g", "Fat", Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // About & Ingredients Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: CyberWorkoutTheme.glassCard(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            color: CyberWorkoutTheme.textPrimary,
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "INGREDIENTS",
                          style: TextStyle(
                            color: CyberWorkoutTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ingredients,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Health Rating Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: CyberWorkoutTheme.glassCard(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "How healthy is this?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Green is better • Red means more caution",
                          style: TextStyle(
                            color: CyberWorkoutTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF142B1D),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.eco, color: CyberWorkoutTheme.neonGreen, size: 24),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Excellent Protein Quality",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Rich in Omega-3 DHA/EPA fatty acids.",
                                    style: TextStyle(color: CyberWorkoutTheme.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroStat(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: CyberWorkoutTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
