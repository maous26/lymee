import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lym_nutrition/core/services/speech_to_text_service.dart';
import 'package:lym_nutrition/core/services/image_generation_service.dart';
import 'package:lym_nutrition/core/services/gamification_service.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({Key? key}) : super(key: key);

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen>
    with TickerProviderStateMixin {
  final SpeechToTextService _speechService = SpeechToTextService();
  final ImageGenerationService _imageService = ImageGenerationService();
  late GamificationService _gamificationService;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _transcriptionController = TextEditingController();

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;

  // État
  bool _isListening = false;
  bool _isGeneratingImage = false;
  bool _isPublishing = false;
  int _currentStep = 0;
  int _difficulty = 3;
  int _preparationTime = 30;
  String? _generatedImageUrl;
  bool _imageApproved = false;

  // Speech recognition
  String _transcription = '';
  String _partialTranscription = '';
  Duration _listeningDuration = Duration.zero;
  static const Duration _maxListeningDuration = Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    _initServices();
    _setupAnimations();
  }

  Future<void> _initServices() async {
    final prefs = await SharedPreferences.getInstance();
    _gamificationService = GamificationService(prefs);
    await _speechService.initialize();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _transcriptionController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreshTheme.cloudWhite,
      appBar: AppBar(
        title: const Text('Créer une recette',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: FreshTheme.primaryMint,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case 0:
        return _buildNameStep();
      case 1:
        return _buildSpeechStep();
      case 2:
        return _buildDetailsStep();
      case 3:
        return _buildImageStep();
      case 4:
        return _buildPreviewStep();
      default:
        return _buildNameStep();
    }
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nom de votre recette',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FreshTheme.midnightGray,
                ),
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 16),
          Text(
            'Donnez un nom appétissant à votre création culinaire',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: FreshTheme.midnightGray.withOpacity(0.7),
                ),
          ).animate(delay: 200.ms).fadeIn().slideX(),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Ex: Salade de quinoa aux légumes grillés',
              prefixIcon: const Icon(Icons.restaurant_menu, color: FreshTheme.primaryMint),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: FreshTheme.primaryMint.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: FreshTheme.primaryMint, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
            ),
            style: const TextStyle(fontSize: 16),
            textCapitalization: TextCapitalization.words,
          ).animate(delay: 400.ms).fadeIn().slideY(),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nameController.text.trim().isEmpty ? null : () => _nextStep(),
              style: ElevatedButton.styleFrom(
                backgroundColor: FreshTheme.primaryMint,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Continuer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ).animate(delay: 600.ms).fadeIn().slideY(),
        ],
      ),
    );
  }

  Widget _buildSpeechStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Décrivez votre recette',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FreshTheme.midnightGray,
                ),
          ).animate().fadeIn(),
          const SizedBox(height: 16),
          Text(
            'Appuyez sur le micro et décrivez les ingrédients, quantités et étapes de préparation',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: FreshTheme.midnightGray.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 32),

          // Bouton micro animé
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.red : FreshTheme.primaryMint,
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : FreshTheme.primaryMint).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: _isListening ? 10 : 5,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                size: 50,
                color: Colors.white,
              ),
            ).animate(
              onPlay: (controller) => _isListening ? controller.repeat() : controller.stop(),
            ).scale(
              duration: 1000.ms,
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
            ),
          ),

          const SizedBox(height: 24),

          // Durée d'écoute
          if (_isListening)
            Text(
              '${_listeningDuration.inSeconds}s / ${_maxListeningDuration.inSeconds}s',
              style: TextStyle(
                color: FreshTheme.midnightGray.withOpacity(0.7),
                fontSize: 16,
              ),
            ).animate().fadeIn(),

          const SizedBox(height: 24),

          // Zone de transcription
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: FreshTheme.primaryMint.withOpacity(0.2)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _transcription.isEmpty
                      ? (_partialTranscription.isEmpty
                          ? 'Votre transcription apparaîtra ici...'
                          : _partialTranscription)
                      : _transcription,
                  style: TextStyle(
                    fontSize: 16,
                    color: _transcription.isEmpty
                        ? FreshTheme.midnightGray.withOpacity(0.5)
                        : FreshTheme.midnightGray,
                    fontStyle: _transcription.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Boutons de contrôle
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _previousStep(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FreshTheme.primaryMint,
                    side: const BorderSide(color: FreshTheme.primaryMint),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _transcription.isEmpty ? null : () => _nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FreshTheme.primaryMint,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continuer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de la recette',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FreshTheme.midnightGray,
                ),
          ).animate().fadeIn(),
          const SizedBox(height: 32),

          // Difficulté
          Text('Difficulté', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _difficulty = index + 1),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.star,
                    color: index < _difficulty ? Colors.amber : Colors.grey[300],
                    size: 32,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          // Temps de préparation
          Text('Temps de préparation', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Slider(
            value: _preparationTime.toDouble(),
            min: 5,
            max: 180,
            divisions: 35,
            activeColor: FreshTheme.primaryMint,
            label: '${_preparationTime} min',
            onChanged: (value) => setState(() => _preparationTime = value.round()),
          ),
          Text(
            '${_preparationTime} minutes',
            style: TextStyle(color: FreshTheme.midnightGray.withOpacity(0.7)),
          ),

          const SizedBox(height: 32),

          // Transcription éditable
          Text('Recette (éditable)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _transcriptionController..text = _transcription,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Modifiez ou complétez votre recette...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: FreshTheme.primaryMint.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: FreshTheme.primaryMint, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(20),
              ),
              onChanged: (value) => _transcription = value,
            ),
          ),

          const SizedBox(height: 24),

          // Boutons navigation
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _previousStep(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FreshTheme.primaryMint,
                    side: const BorderSide(color: FreshTheme.primaryMint),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FreshTheme.primaryMint,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Générer image'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Image de la recette',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FreshTheme.midnightGray,
                ),
          ).animate().fadeIn(),
          const SizedBox(height: 16),
          Text(
            'Génération d\'une image appétissante de votre recette',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: FreshTheme.midnightGray.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 32),

          // Zone d'image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: FreshTheme.primaryMint.withOpacity(0.2)),
              ),
              child: _buildImageContent(),
            ),
          ),

          const SizedBox(height: 24),

          // Boutons d'action
          if (_generatedImageUrl != null) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isGeneratingImage ? null : _regenerateImage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FreshTheme.primaryMint,
                      side: const BorderSide(color: FreshTheme.primaryMint),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Régénérer'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _imageApproved = true);
                      _nextStep();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FreshTheme.primaryMint,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _previousStep(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: FreshTheme.primaryMint,
                      side: const BorderSide(color: FreshTheme.primaryMint),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Retour'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _imageApproved = false);
                      _nextStep();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FreshTheme.primaryMint,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Continuer sans image'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (_isGeneratingImage) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: FreshTheme.primaryMint),
            SizedBox(height: 16),
            Text('Génération de l\'image en cours...'),
            SizedBox(height: 8),
            Text('Cela peut prendre quelques secondes', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    if (_generatedImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: _generatedImageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 50, color: Colors.grey),
                SizedBox(height: 8),
                Text('Erreur de chargement'),
              ],
            ),
          ),
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 50, color: Colors.grey),
          SizedBox(height: 16),
          Text('L\'image sera générée automatiquement'),
        ],
      ),
    );
  }

  Widget _buildPreviewStep() {
    return const Center(
      child: Text('Preview Step - À implémenter'),
    );
  }

  // Méthodes de navigation
  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      if (_currentStep == 3) {
        _generateImage();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // Méthodes speech-to-text
  Future<void> _startListening() async {
    if (!_speechService.isAvailable) return;

    setState(() {
      _isListening = true;
      _listeningDuration = Duration.zero;
    });

    _pulseController.repeat();
    _startListeningTimer();

    await _speechService.startListening(
      onResult: (result) {
        setState(() {
          _transcription = result;
          _partialTranscription = '';
        });
      },
      onPartialResult: (partial) {
        setState(() => _partialTranscription = partial);
      },
      timeout: _maxListeningDuration,
    );
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() => _isListening = false);
    _pulseController.stop();
  }

  void _startListeningTimer() {
    Future.doWhile(() async {
      if (!_isListening) return false;
      
      await Future.delayed(const Duration(seconds: 1));
      if (_isListening) {
        setState(() {
          _listeningDuration = _listeningDuration + const Duration(seconds: 1);
        });
        
        if (_listeningDuration >= _maxListeningDuration) {
          await _stopListening();
          return false;
        }
      }
      return _isListening;
    });
  }

  // Méthodes génération d'image
  Future<void> _generateImage() async {
    setState(() => _isGeneratingImage = true);

    try {
      final imageUrl = await _imageService.generateRecipeImage(
        recipeName: _nameController.text,
        ingredients: _extractIngredients(_transcription),
        description: _transcription,
      );

      setState(() {
        _generatedImageUrl = imageUrl;
        _isGeneratingImage = false;
      });
    } catch (e) {
      setState(() => _isGeneratingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _regenerateImage() async {
    await _generateImage();
  }

  String _extractIngredients(String transcription) {
    // Logique simple pour extraire les ingrédients
    // À améliorer avec de l'IA pour une meilleure extraction
    return transcription.split('.').first;
  }
}
