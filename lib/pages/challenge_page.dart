// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aigrove/services/profile_service.dart';
import '../theme/app_theme.dart';
import 'dart:async';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  List<QuizCategory> _categories = [];
  Set<String> _completedCategories = {}; // Track sa na-complete na categories

  @override
  void initState() {
    super.initState();
    _loadCompletedCategories();
    _loadQuizCategories();
  }

  // I-load ang na-complete na categories gikan sa database
  Future<void> _loadCompletedCategories() async {
    try {
      final profileService = context.read<ProfileService>();
      final completed = await profileService.getCompletedCategories();
      setState(() {
        _completedCategories = completed;
      });
    } catch (e) {
      debugPrint('Error loading completed categories: $e');
    }
  }

  // Check kung unlocked ba ang category based sa difficulty progression
  bool _isCategoryUnlocked(QuizCategory category) {
    switch (category.difficulty) {
      case QuizDifficulty.easy:
        return true; // Easy is always unlocked
      case QuizDifficulty.medium:
        // Medium unlocked kun na-complete na ang easy
        return _categories
            .where((cat) => cat.difficulty == QuizDifficulty.easy)
            .every((cat) => _completedCategories.contains(cat.id));
      case QuizDifficulty.hard:
        // Hard unlocked kun na-complete na ang easy ug medium
        return _categories
            .where(
              (cat) =>
                  cat.difficulty == QuizDifficulty.easy ||
                  cat.difficulty == QuizDifficulty.medium,
            )
            .every((cat) => _completedCategories.contains(cat.id));
    }
  }

  // Load quiz categories - base sa mangrove data from map ug homepage
  void _loadQuizCategories() {
    setState(() {
      _categories = [
        QuizCategory(
          id: 'easy_species',
          name: 'Mangrove Species',
          description:
              'Test your knowledge about different mangrove species found in Caraga region',
          difficulty: QuizDifficulty.easy,
          icon: Icons.eco,
          color: Colors.green,
          questions: _getMangroveSpeciesQuestions(),
        ),
        QuizCategory(
          id: 'medium_impact',
          name: 'Environmental Impact',
          description: 'Learn about the environmental benefits of mangroves',
          difficulty: QuizDifficulty.medium,
          icon: Icons.co2,
          color: Colors.teal,
          questions: _getEnvironmentalImpactQuestions(),
        ),
        QuizCategory(
          id: 'hard_conservation',
          name: 'Conservation Challenges',
          description:
              'Advanced topics about mangrove conservation and restoration',
          difficulty: QuizDifficulty.hard,
          icon: Icons.waves,
          color: Colors.indigo,
          questions: _getConservationQuestions(),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: AppTheme.getPageGradient(context),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Improved App Bar with better design
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor:
                    Colors.green.shade700, // Mas visible ang background
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(
                    left: 20,
                    bottom: 16,
                    top: 8,
                  ), // Gi-add ang top padding
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                    ), // Extra padding para balanced
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40, // Fixed width para centered ang icon
                          height: 40, // Fixed height para centered ang icon
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              0.25,
                            ), // Mas visible ang background
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            // I-center ang icon
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Quiz Challenges',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26, // Gi-balik sa original size
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors
                                    .black45, // Mas dark ang shadow para mas visible
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.shade800,
                          Colors.green.shade600,
                          Colors.teal.shade600,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated background pattern
                        Positioned(
                          right: -50,
                          top: -30,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -40,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        // Decorative icons
                        Positioned(
                          right: 20,
                          top: 40,
                          child: Icon(
                            Icons.quiz,
                            size: 60,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Positioned(
                          left: 30,
                          bottom: 60,
                          child: Icon(
                            Icons.eco,
                            size: 50,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Info banner - updated message
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade400, Colors.orange.shade400],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_open,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progressive Learning!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Complete each difficulty to unlock the next level',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Available Challenges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.grey[800],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          '${_categories.length} Categories',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quiz Categories - with lock/unlock status
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final category = _categories[index];
                    final isUnlocked = _isCategoryUnlocked(category);
                    final isCompleted = _completedCategories.contains(
                      category.id,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildCategoryCard(
                        category,
                        isUnlocked,
                        isCompleted,
                      ),
                    );
                  }, childCount: _categories.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    QuizCategory category,
    bool isUnlocked,
    bool isCompleted,
  ) {
    String difficultyText = category.difficulty.name.toUpperCase();
    Color difficultyColor = _getDifficultyColor(category.difficulty);

    return Material(
      elevation: isUnlocked ? 8 : 2,
      borderRadius: BorderRadius.circular(20),
      shadowColor: category.color.withOpacity(isUnlocked ? 0.3 : 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isUnlocked
            ? () => _startQuiz(category)
            : () => _showLockedDialog(category),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isUnlocked
                  ? [
                      category.color.withOpacity(0.9),
                      category.color,
                      category.color.withOpacity(0.8),
                    ]
                  : [
                      Colors.grey.shade400,
                      Colors.grey.shade500,
                      Colors.grey.shade400,
                    ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: -10,
                child: Icon(
                  isUnlocked ? category.icon : Icons.lock,
                  size: 100,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),

              // Completed badge
              if (isCompleted)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isUnlocked ? category.icon : Icons.lock,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                                decoration: isUnlocked
                                    ? null
                                    : TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: difficultyColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getDifficultyIcon(category.difficulty),
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    difficultyText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isUnlocked
                          ? category.description
                          : 'Complete previous difficulty to unlock',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                        fontStyle: isUnlocked
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isUnlocked ? Icons.quiz : Icons.lock,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isUnlocked
                                  ? '${category.questions.length} questions'
                                  : 'Locked',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isUnlocked ? Icons.arrow_forward : Icons.lock,
                          color: isUnlocked ? category.color : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show dialog kun nag-tap sa locked category
  void _showLockedDialog(QuizCategory category) {
    String requirement = '';

    switch (category.difficulty) {
      case QuizDifficulty.medium:
        requirement =
            'Complete the Easy difficulty first to unlock this category.';
        break;
      case QuizDifficulty.hard:
        requirement =
            'Complete both Easy and Medium difficulties to unlock this category.';
        break;
      default:
        requirement = '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Expanded(child: Text('Category Locked')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(requirement),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Progressive learning helps you master mangrove knowledge step by step!',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return Icons.trending_up;
      case QuizDifficulty.medium:
        return Icons.whatshot;
      case QuizDifficulty.hard:
        return Icons.local_fire_department;
    }
  }

  Color _getDifficultyColor(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return Colors.green;
      case QuizDifficulty.medium:
        return Colors.orange;
      case QuizDifficulty.hard:
        return Colors.red;
    }
  }

  void _startQuiz(QuizCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          category: category,
          onQuizCompleted: () {
            // I-reload ang completed categories after finishing quiz
            _loadCompletedCategories();
          },
        ),
      ),
    );
  }

  // Quiz questions base sa map page ug homepage data - expanded to 10 questions each
  List<QuizQuestion> _getMangroveSpeciesQuestions() {
    return [
      QuizQuestion(
        question:
            'Which mangrove species is commonly found in Masao Mangrove Park?',
        correctAnswer: 'Rhizophora mucronata',
        wrongAnswers: [
          'Sonneratia alba',
          'Avicennia marina',
          'Bruguiera gymnorrhiza',
        ],
        explanation:
            'Rhizophora mucronata is the primary species found in Masao Mangrove Park, Agusan del Norte.',
        points: 10,
      ),
      QuizQuestion(
        question:
            'How many mangrove species are commonly found in Dinagat Islands?',
        correctAnswer: '5 species',
        wrongAnswers: ['3 species', '7 species', '2 species'],
        explanation:
            'Dinagat Islands has 5 common mangrove species including Rhizophora mucronata, Sonneratia alba, Avicennia marina, Xylocarpus granatum, and Ceriops tagal.',
        points: 10,
      ),
      QuizQuestion(
        question:
            'What is the scientific name of the mangrove species found in Siargao?',
        correctAnswer: 'Bruguiera gymnorrhiza',
        wrongAnswers: [
          'Rhizophora stylosa',
          'Ceriops tagal',
          'Lumnitzera racemosa',
        ],
        explanation:
            'Siargao Mangrove Forest is known for Bruguiera gymnorrhiza species.',
        points: 10,
      ),
      QuizQuestion(
        question: 'Which mangrove species has distinctive knee-like roots?',
        correctAnswer: 'Bruguiera gymnorrhiza',
        wrongAnswers: [
          'Rhizophora mucronata',
          'Avicennia marina',
          'Sonneratia alba',
        ],
        explanation:
            'Bruguiera gymnorrhiza is characterized by its distinctive knee-like pneumatophores (aerial roots).',
        points: 10,
      ),
      QuizQuestion(
        question: 'What is the local name for Rhizophora mucronata?',
        correctAnswer: 'Bakauan',
        wrongAnswers: ['Piapi', 'Bungalon', 'Tabigi'],
        explanation:
            'Rhizophora mucronata is locally known as Bakauan in the Philippines.',
        points: 10,
      ),
      QuizQuestion(
        question: 'Which mangrove species tolerates the highest salinity?',
        correctAnswer: 'Avicennia marina',
        wrongAnswers: [
          'Rhizophora mucronata',
          'Bruguiera gymnorrhiza',
          'Ceriops tagal',
        ],
        explanation:
            'Avicennia marina has the highest salt tolerance among mangrove species.',
        points: 10,
      ),
      QuizQuestion(
        question: 'What type of fruit does Sonneratia alba produce?',
        correctAnswer: 'Bell-shaped fruit',
        wrongAnswers: ['Elongated pods', 'Round berries', 'Flat seeds'],
        explanation:
            'Sonneratia alba produces distinctive bell-shaped fruits that are edible.',
        points: 10,
      ),
      QuizQuestion(
        question: 'Which mangrove species has buttress roots?',
        correctAnswer: 'Xylocarpus granatum',
        wrongAnswers: [
          'Avicennia marina',
          'Ceriops tagal',
          'Lumnitzera racemosa',
        ],
        explanation:
            'Xylocarpus granatum is characterized by its prominent buttress root system.',
        points: 10,
      ),
      QuizQuestion(
        question:
            'What is the flowering season for most mangrove species in Caraga?',
        correctAnswer: 'March to May',
        wrongAnswers: [
          'June to August',
          'September to November',
          'December to February',
        ],
        explanation:
            'Most mangrove species in the Caraga region flower during the dry season from March to May.',
        points: 10,
      ),
      QuizQuestion(
        question: 'Which mangrove species is best for coastal protection?',
        correctAnswer: 'Rhizophora mucronata',
        wrongAnswers: [
          'Lumnitzera racemosa',
          'Ceriops tagal',
          'Excoecaria agallocha',
        ],
        explanation:
            'Rhizophora mucronata with its extensive prop root system provides the best coastal protection.',
        points: 10,
      ),
    ];
  }

  List<QuizQuestion> _getEnvironmentalImpactQuestions() {
    return [
      QuizQuestion(
        question: 'How much carbon can mangroves capture annually per hectare?',
        correctAnswer: '25.3 tons/hectare',
        wrongAnswers: [
          '15.2 tons/hectare',
          '35.8 tons/hectare',
          '10.5 tons/hectare',
        ],
        explanation:
            'Mangroves can sequester approximately 25.3 tons of carbon per hectare annually, making them highly efficient carbon sinks.',
        points: 15,
      ),
      QuizQuestion(
        question:
            'What percentage of wave energy can mangroves reduce for coastal protection?',
        correctAnswer: '70%',
        wrongAnswers: ['50%', '85%', '40%'],
        explanation:
            'Mangrove forests can reduce wave energy by up to 70%, significantly protecting coastlines from erosion.',
        points: 15,
      ),
      QuizQuestion(
        question: 'How many species are supported by mangrove ecosystems?',
        correctAnswer: '1,300+ species',
        wrongAnswers: ['800+ species', '500+ species', '2,000+ species'],
        explanation:
            'Mangrove ecosystems support over 1,300 species, making them biodiversity hotspots.',
        points: 15,
      ),
      QuizQuestion(
        question: 'How much sediment can mangroves trap annually per hectare?',
        correctAnswer: '5-10 tons',
        wrongAnswers: ['1-3 tons', '15-20 tons', '25-30 tons'],
        explanation:
            'Mangrove roots can trap 5-10 tons of sediment per hectare annually, helping prevent coastal erosion.',
        points: 15,
      ),
      QuizQuestion(
        question:
            'What percentage of marine fish depend on mangroves as nurseries?',
        correctAnswer: '80%',
        wrongAnswers: ['60%', '90%', '50%'],
        explanation:
            'Approximately 80% of marine fish species depend on mangroves as nursery habitats during their juvenile stage.',
        points: 15,
      ),
      QuizQuestion(
        question: 'How much oxygen can one mangrove tree produce daily?',
        correctAnswer: '40 kg',
        wrongAnswers: ['20 kg', '60 kg', '15 kg'],
        explanation:
            'A mature mangrove tree can produce approximately 40 kg of oxygen per day.',
        points: 15,
      ),
      QuizQuestion(
        question:
            'What is the water filtration capacity of mangroves per hectare?',
        correctAnswer: '2 million liters/day',
        wrongAnswers: [
          '500,000 liters/day',
          '5 million liters/day',
          '1 million liters/day',
        ],
        explanation:
            'Mangrove forests can filter up to 2 million liters of water per hectare daily.',
        points: 15,
      ),
      QuizQuestion(
        question: 'How much nitrogen can mangroves remove from water annually?',
        correctAnswer: '1,500 kg/hectare',
        wrongAnswers: ['800 kg/hectare', '2,500 kg/hectare', '500 kg/hectare'],
        explanation:
            'Mangroves can remove approximately 1,500 kg of nitrogen per hectare annually from coastal waters.',
        points: 15,
      ),
      QuizQuestion(
        question: 'What is the storm surge reduction capacity of mangroves?',
        correctAnswer: '50-90%',
        wrongAnswers: ['20-40%', '95-100%', '10-30%'],
        explanation:
            'Mangrove forests can reduce storm surge heights by 50-90% depending on forest width and density.',
        points: 15,
      ),
      QuizQuestion(
        question:
            'How many people globally depend on mangrove ecosystems for their livelihood?',
        correctAnswer: '120 million',
        wrongAnswers: ['80 million', '200 million', '50 million'],
        explanation:
            'Approximately 120 million people worldwide depend directly on mangrove ecosystems for their livelihood.',
        points: 15,
      ),
    ];
  }

  List<QuizQuestion> _getConservationQuestions() {
    return [
      QuizQuestion(
        question:
            'What is the potential annual marine expansion rate in mangrove areas?',
        correctAnswer: '12.5 km²/year',
        wrongAnswers: ['8.3 km²/year', '20.1 km²/year', '5.7 km²/year'],
        explanation:
            'With proper conservation efforts, mangrove areas can expand at a rate of 12.5 km² per year in suitable coastal zones.',
        points: 20,
      ),
      QuizQuestion(
        question:
            'Which province in Caraga region has the highest mangrove species diversity?',
        correctAnswer: 'Surigao del Norte',
        wrongAnswers: [
          'Agusan del Norte',
          'Dinagat Islands',
          'Surigao del Sur',
        ],
        explanation:
            'Surigao del Norte has the highest diversity with 5 major mangrove species and highest population counts.',
        points: 20,
      ),
      QuizQuestion(
        question:
            'What is the main threat to mangrove conservation in coastal areas?',
        correctAnswer: 'Coastal development and aquaculture',
        wrongAnswers: [
          'Natural disasters',
          'Climate change only',
          'Tourism activities',
        ],
        explanation:
            'The primary threats to mangroves include coastal development, aquaculture expansion, and conversion to other land uses.',
        points: 20,
      ),
      QuizQuestion(
        question:
            'What is the minimum buffer zone required for mangrove protection?',
        correctAnswer: '20 meters',
        wrongAnswers: ['10 meters', '50 meters', '5 meters'],
        explanation:
            'Philippine law requires a minimum 20-meter buffer zone from the mangrove forest edge for protection.',
        points: 20,
      ),
      QuizQuestion(
        question:
            'How long does it take for a mangrove forest to fully mature?',
        correctAnswer: '15-20 years',
        wrongAnswers: ['5-10 years', '25-30 years', '3-5 years'],
        explanation:
            'A mangrove forest typically takes 15-20 years to reach full maturity and ecological function.',
        points: 20,
      ),
      QuizQuestion(
        question:
            'What is the success rate of mangrove restoration projects in the Philippines?',
        correctAnswer: '10-20%',
        wrongAnswers: ['50-60%', '80-90%', '30-40%'],
        explanation:
            'Unfortunately, only 10-20% of mangrove restoration projects succeed long-term due to various factors.',
        points: 20,
      ),
      QuizQuestion(
        question: 'Which law protects mangroves in the Philippines?',
        correctAnswer: 'Presidential Decree 1067',
        wrongAnswers: [
          'Republic Act 9275',
          'Republic Act 7586',
          'Presidential Decree 705',
        ],
        explanation:
            'Presidential Decree 1067 (Water Code) specifically protects mangrove swamps in the Philippines.',
        points: 20,
      ),
      QuizQuestion(
        question:
            'What is the ideal planting density for mangrove restoration?',
        correctAnswer: '1 seedling per m²',
        wrongAnswers: [
          '5 seedlings per m²',
          '0.5 seedlings per m²',
          '2 seedlings per m²',
        ],
        explanation:
            'The optimal planting density for mangrove restoration is approximately 1 seedling per square meter.',
        points: 20,
      ),
      QuizQuestion(
        question:
            'How much global mangrove cover has been lost in the last 50 years?',
        correctAnswer: '50%',
        wrongAnswers: ['30%', '70%', '25%'],
        explanation:
            'Approximately 50% of global mangrove coverage has been lost over the past 50 years.',
        points: 20,
      ),
      QuizQuestion(
        question:
            'What is the economic value of mangrove ecosystem services per hectare annually?',
        correctAnswer: '\$33,000-57,000',
        wrongAnswers: ['\$10,000-20,000', '\$70,000-100,000', '\$5,000-15,000'],
        explanation:
            'The economic value of mangrove ecosystem services ranges from \$33,000-57,000 per hectare annually.',
        points: 20,
      ),
    ];
  }
}

// Quiz Screen para sa actual quiz taking
class QuizScreen extends StatefulWidget {
  final QuizCategory category;
  final VoidCallback? onQuizCompleted; // Callback para i-notify ang parent

  const QuizScreen({super.key, required this.category, this.onQuizCompleted});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<String> _selectedAnswers = [];
  Timer? _timer;
  int _timeLeft = 1200; // 20 minutes = 1200 seconds para sa whole quiz
  int _totalTimeSpent = 0;
  bool _isAnswered = false;
  List<String> _shuffledAnswers = [];
  List<QuizQuestion> _shuffledQuestions = [];

  @override
  void initState() {
    super.initState();
    // I-shuffle ang questions kada start
    _shuffledQuestions = List.from(widget.category.questions)..shuffle();
    _selectedAnswers = List.filled(_shuffledQuestions.length, '');
    _prepareAnswersForCurrentQuestion();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _timeLeft--;
        _totalTimeSpent++;
      });

      // Kung naubos na ang time, auto-finish ang quiz
      if (_timeLeft <= 0) {
        _finishQuiz();
      }
    });
  }

  // I-prepare ang answers para sa current question (one time lang para dili mag-shuffle)
  void _prepareAnswersForCurrentQuestion() {
    final question = _shuffledQuestions[_currentQuestionIndex];
    _shuffledAnswers = [question.correctAnswer, ...question.wrongAnswers];
    _shuffledAnswers.shuffle();
  }

  void _nextQuestion() {
    // Wala na'y timer cancel kay continuous na ang timer

    if (_currentQuestionIndex < _shuffledQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
      });
      _prepareAnswersForCurrentQuestion();
      // Wala na'y _startTimer() kay continuous na
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    _timer?.cancel();

    try {
      final profileService = context.read<ProfileService>();

      // I-show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      debugPrint('Nag-finish og quiz, score: $_score');

      // Calculate results - FIXED: base sa number of correct answers
      int correctAnswers = 0;
      for (int i = 0; i < _shuffledQuestions.length; i++) {
        if (_selectedAnswers[i] == _shuffledQuestions[i].correctAnswer) {
          correctAnswers++;
        }
      }

      // Check if passing (minimum 60% to unlock next level)
      // FIXED: percentage base sa number of questions, dili sa points
      double percentage = (correctAnswers / _shuffledQuestions.length) * 100;
      bool isPassing = percentage >= 60;

      // I-save sa database ang complete quiz results
      await Future.wait([
        profileService.addPoints(_score),
        profileService.addCompletedChallenge(),
        if (isPassing)
          profileService.markCategoryAsCompleted(widget.category.id),
        profileService.saveQuizHistory(
          categoryId: widget.category.id,
          categoryName: widget.category.name,
          score: _score,
          totalQuestions: _shuffledQuestions.length,
          correctAnswers: correctAnswers,
          timeSpent: _totalTimeSpent,
          difficulty: widget.category.difficulty.name,
          isPassing: isPassing,
        ),
      ]);

      debugPrint('Successfully na-save ang quiz results');

      // I-close ang loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      // I-call ang callback para i-refresh ang parent
      widget.onQuizCompleted?.call();

      // I-navigate sa results screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            category: widget.category,
            score: _score,
            totalQuestions: _shuffledQuestions.length,
            timeSpent: _totalTimeSpent,
            selectedAnswers: _selectedAnswers,
            shuffledQuestions: _shuffledQuestions,
            isPassing: isPassing,
          ),
        ),
      );
    } catch (e) {
      debugPrint('May error sa pag-save pero proceed pa rin: $e');

      // I-close ang loading dialog
      if (mounted) Navigator.pop(context);

      // I-show warning message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nag-save pero may konting problema: ${e.toString().split(':').last}',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );

      // Calculate kung passing ba
      int correctAnswers = 0;
      for (int i = 0; i < _shuffledQuestions.length; i++) {
        if (_selectedAnswers[i] == _shuffledQuestions[i].correctAnswer) {
          correctAnswers++;
        }
      }
      double percentage = (correctAnswers / _shuffledQuestions.length) * 100;
      bool isPassing = percentage >= 60;

      // I-proceed pa rin sa results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            category: widget.category,
            score: _score,
            totalQuestions: _shuffledQuestions.length,
            timeSpent: _totalTimeSpent,
            selectedAnswers: _selectedAnswers,
            shuffledQuestions: _shuffledQuestions,
            isPassing: isPassing,
          ),
        ),
      );
    }
  }

  void _selectAnswer(String answer) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answer;
      _isAnswered = true;
    });

    // Check if correct
    if (answer == _shuffledQuestions[_currentQuestionIndex].correctAnswer) {
      _score += _shuffledQuestions[_currentQuestionIndex].points;
    }

    // Auto proceed after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _nextQuestion();
    });
  }

  // Helper method para format ang time display
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final question = _shuffledQuestions[_currentQuestionIndex];
    final isTimeRunningOut = _timeLeft <= 60; // Last 1 minute warning

    return WillPopScope(
      onWillPop: () async {
        // I-confirm if gusto jud mu-quit
        final shouldPop =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Quit Quiz?'),
                content: const Text(
                  'Your progress will be lost. Are you sure?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Quit'),
                  ),
                ],
              ),
            ) ??
            false;
        return shouldPop;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header with progress ug overall timer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.category.color,
                      widget.category.color.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () async {
                            final shouldPop = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Quit Quiz?'),
                                content: const Text(
                                  'Your progress will be lost. Are you sure?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Quit'),
                                  ),
                                ],
                              ),
                            );
                            if (shouldPop == true && mounted) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            }
                          },
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value:
                                (_currentQuestionIndex + 1) /
                                _shuffledQuestions.length,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Overall timer display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isTimeRunningOut
                                ? Colors.red.withOpacity(0.3)
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isTimeRunningOut
                                  ? Colors.red
                                  : Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: isTimeRunningOut
                                    ? Colors.red
                                    : Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(_timeLeft),
                                style: TextStyle(
                                  color: isTimeRunningOut
                                      ? Colors.red
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${_shuffledQuestions.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Score: $_score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Time warning banner
              if (isTimeRunningOut)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.red.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Time is running out!',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Question content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Answer options
                      Expanded(
                        child: ListView.builder(
                          itemCount: _shuffledAnswers.length,
                          itemBuilder: (context, index) {
                            final answer = _shuffledAnswers[index];
                            final isSelected =
                                _selectedAnswers[_currentQuestionIndex] ==
                                answer;
                            final isCorrect = answer == question.correctAnswer;

                            Color? cardColor;
                            if (_isAnswered) {
                              if (isCorrect) {
                                cardColor = Colors.green;
                              } else if (isSelected && !isCorrect) {
                                cardColor = Colors.red;
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _selectAnswer(answer),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: cardColor ?? Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? widget.category.color
                                            : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: cardColor != null
                                                  ? Colors.white
                                                  : Colors.grey.shade400,
                                            ),
                                            color: isSelected
                                                ? (cardColor ??
                                                      widget.category.color)
                                                : Colors.transparent,
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            answer,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: cardColor != null
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Quiz Result Screen
class QuizResultScreen extends StatelessWidget {
  final QuizCategory category;
  final int score;
  final int totalQuestions;
  final int timeSpent;
  final List<String> selectedAnswers;
  final List<QuizQuestion> shuffledQuestions;
  final bool isPassing;

  const QuizResultScreen({
    super.key,
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.timeSpent,
    required this.selectedAnswers,
    required this.shuffledQuestions,
    required this.isPassing,
  });

  @override
  Widget build(BuildContext context) {
    // FIXED: Calculate correct answers from selected answers
    int correctAnswers = 0;
    for (int i = 0; i < totalQuestions; i++) {
      if (selectedAnswers[i] == shuffledQuestions[i].correctAnswer) {
        correctAnswers++;
      }
    }

    // FIXED: Percentage base sa number of correct answers, max is 100%
    double percentage = (correctAnswers / totalQuestions) * 100;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [category.color, category.color.withOpacity(0.8)],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                  ),
                  const Expanded(
                    child: Text(
                      'Quiz Complete!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Score display
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            percentage >= 80
                                ? Icons.emoji_events
                                : percentage >= 60
                                ? Icons.thumb_up
                                : Icons.refresh,
                            size: 60,
                            color: category.color,
                          ),
                          const SizedBox(height: 16),
                          // FIXED: Show correct answers out of total questions
                          Text(
                            '$correctAnswers / $totalQuestions',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: category.color,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getPerformanceMessage(percentage),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          // Unlock notification
                          if (isPassing) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber.shade700,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_open,
                                    color: Colors.amber.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Congratulations! Next difficulty unlocked! 🎉',
                                      style: TextStyle(
                                        color: Colors.amber.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Score 60% or higher to unlock the next level',
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Time Spent',
                            '${timeSpent ~/ 60}:${(timeSpent % 60).toString().padLeft(2, '0')}',
                            Icons.timer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Questions',
                            '$totalQuestions',
                            Icons.quiz,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Action buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      QuizScreen(category: category),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: category.color,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Try Again',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: category.color),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Back to Challenges',
                              style: TextStyle(
                                fontSize: 16,
                                color: category.color,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: category.color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: category.color,
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  String _getPerformanceMessage(double percentage) {
    if (percentage >= 90) {
      return 'Excellent! You\'re a mangrove expert! 🌿';
    } else if (percentage >= 80) {
      return 'Great job! You know your mangroves well! 👏';
    } else if (percentage >= 70) {
      return 'Good work! Keep learning about mangroves! 📚';
    } else if (percentage >= 60) {
      return 'Not bad! Study more about mangrove conservation! 🌱';
    } else {
      return 'Keep practicing! Learning about mangroves is important! 💪';
    }
  }
}

// Models
enum QuizDifficulty { easy, medium, hard }

class QuizCategory {
  final String id;
  final String name;
  final String description;
  final QuizDifficulty difficulty;
  final IconData icon;
  final Color color;
  final List<QuizQuestion> questions;

  QuizCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

class QuizQuestion {
  final String question;
  final String correctAnswer;
  final List<String> wrongAnswers;
  final String explanation;
  final int points;

  QuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.wrongAnswers,
    required this.explanation,
    required this.points,
  });
}
