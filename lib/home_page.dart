import 'package:talkie/feature_box.dart';
import 'package:talkie/combined_service.dart';
import 'package:talkie/pallete.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final CombinedService combinedService = CombinedService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  bool _isCurrentlySpeaking = false;
  bool _isApiCallInProgress = false;
  final TextEditingController _characterController = TextEditingController();
  String _character = "";
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    flutterTts.setCompletionHandler(() {
      setState(() {
        _isCurrentlySpeaking = false;
      });
    });
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    if (_isCurrentlySpeaking) {
      await flutterTts.stop();
      setState(() {
        _isCurrentlySpeaking = false;
      });
    }
    if (_isApiCallInProgress) {
      _isApiCallInProgress = false;
    }

    generatedContent = null;
    generatedImageUrl = null;
    setState(() {});
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    setState(() {
      _isCurrentlySpeaking = true;
    });
    await flutterTts.speak(content);
  }

  Future<void> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();

    if (status == PermissionStatus.granted) {
      logger.i('Microphone permission granted');
    } else if (status == PermissionStatus.denied) {
      logger.w('Microphone permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text('talkie'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/virtualAssistant.png',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent == null
                          ? 'Please enter a character or persona.'
                          : generatedContent!,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextField(
                  controller: _characterController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Character/Persona',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _character = value;
                    });
                  },
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'ChatBot',
                      descriptionText:
                          'Enables intelligent and context-aware text responses',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Character Emulation',
                      descriptionText:
                          'Allows the AI to respond in the persona of a character defined by the user.',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          ' Provides hands-free interaction through voice commands.',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await requestMicrophonePermission();
              if (await Permission.microphone.isGranted) {
                await startListening();
              } else {
                logger.e("Microphone Permission not granted");
              }
            } else if (speechToText.isListening) {
              await stopListening();
              setState(() {
                _isApiCallInProgress = true;
              });
              final isImage = await combinedService.isImagePrompt(lastWords);
              if (isImage.toLowerCase() == 'yes') {
                final image = await combinedService.generateImageHuggingFace(lastWords);
                if (_isApiCallInProgress) {
                  if (image.startsWith("data:image/")) {
                    generatedImageUrl = image;
                    generatedContent = null;
                    setState(() {});
                  } else {
                    generatedContent = image;
                    generatedImageUrl = null;
                    setState(() {});
                    await systemSpeak(image);
                  }
                }
              } else {
                final text = await combinedService.generateTextGemini(lastWords, _character);
                if (_isApiCallInProgress) {
                  generatedImageUrl = null;
                  generatedContent = text;
                  setState(() {});
                  await systemSpeak(text);
                }
              }
              setState(() {
                _isApiCallInProgress = false;
              });
            } else {
              initSpeechToText();
            }
          },
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
          ),
        ),
      ),
    );
  }
}