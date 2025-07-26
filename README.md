# Talkie - Your AI-Powered Voice Assistant

"Talkie" is a Flutter application that provides an interactive, voice-driven AI experience. It leverages the power of AI to generate text based on your voice commands, with a unique feature that allows you to customize the AI's persona.

## Live Demo & Releases

- 🌐 **Live Website**: [talkie](https://talkie-bot.netlify.app/)  
- 📦 **Latest Release**: [GitHub Releases](https://github.com/sumanthd032/Talkie/releases/tag/v1.0.0)

## Features

* **Voice Interaction:** Speak your commands and prompts.
* **AI Text Generation:** Get intelligent and context-aware text responses powered by the Gemini API.
* **Character Customization:** Define a character or persona for the AI's responses.
* **Text-to-Speech:** Listen to the AI's responses with built-in text-to-speech functionality.
* **User-Friendly Interface:** Intuitive and easy-to-use design.
* **Microphone Permission Handling:** Seamlessly requests and manages microphone permissions.

## Tech Stack

* **Flutter:** Cross-platform mobile development framework.
* **Dart:** Programming language.
* **Gemini API:** For text generation.
* **Hugging Face API:** For image generation.
* **`flutter_tts`:** Text-to-speech plugin.
* **`speech_to_text`:** Speech-to-text plugin.

## Getting Started

1.  **Clone the Repository:**

    ```bash
    git clone [repository URL]
    cd talkie
    ```

2.  **Install Dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Set Up API Keys:**

    * Create a `secrets.dart` file in the root directory of the `lib` folder.
    * Add your Gemini and Hugging Face API keys to the `secrets.dart` file:

        ```dart
          const String gemini = 'YOUR_GEMINI_API_KEY';
          const String hugFace = 'YOUR_HUGGING_FACE_API_KEY';
        ```

    * Replace `YOUR_GEMINI_API_KEY` and `YOUR_HUGGING_FACE_API_KEY` with your actual API keys.
    * **Important:** Add `secrets.dart` to your `.gitignore` file to prevent your API keys from being committed to version control.

4.  **Run the App:**

    ```bash
    flutter run
    ```

## Proposed Improvements

* **Backend Server Implementation:** To enhance security, it's highly recommended to implement a backend server that acts as an intermediary between the app and the external APIs. This will secure API keys and improve scalability.

