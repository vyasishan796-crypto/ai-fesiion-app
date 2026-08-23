class ApiConstants {
  ApiConstants._();

  // NVIDIA NIM API (keys moved to backend)
  static const String nvidiaBaseUrl = 'https://ai.api.nvidia.com/v1/genai';

  // FLUX.2 [klein] 4B
  static const String flux2Klein4b = '$nvidiaBaseUrl/black-forest-labs/flux.2-klein-4b';

  // AI Horde
  static const String aiHordeBaseUrl = 'https://stablehorde.net/api/v2';
  static const String aiHordeApiKey = '0000000000';
  static const String aiHordeModel = 'AlbedoBase XL (SDXL)';

  // Google Gemini API (use --dart-define at build time for production)
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String geminiModel = 'gemini-1.5-flash';

  // Hugging Face - Image Generation (use --dart-define at build time for production)
  static const String huggingFaceInferenceUrl = 'https://api-inference.huggingface.co/models/black-forest-labs/FLUX.1-schnell';
  static const String huggingFaceApiKey = String.fromEnvironment('HF_API_KEY', defaultValue: '');

  // Pollinations - Free Image Generation
  static const String pollinationsBaseUrl = 'https://image.pollinations.ai/prompt';

  // Kolors Virtual Try-On
  static const String kolorsTryOnBase = 'https://kwai-kolors-kolors-virtual-try-on.hf.space';
  static const String kolorsTryOnSubmit = '$kolorsTryOnBase/gradio_api/call/infer';

  // DataYuge - Free Price Comparison API
  static const String dataYugeBaseUrl = 'https://price-api.datayuge.com/api/v1';
  static const String dataYugeApiKey = '';

  // OpenRouter - Free LLM API (use --dart-define at build time for production)
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterApiKey = String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');
  static const String openRouterModel = 'meta-llama/llama-3-8b-instruct:free';

  // ─── Backend API ───
  // Replace with your Render backend URL after deploy
  // USB: run `adb reverse tcp:8000 tcp:8000` then use http://127.0.0.1:8000/api
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );
  static const String virtualTryOnEndpoint = '$backendBaseUrl/virtual-tryon/';
  static const String virtualTryOnHistoryEndpoint = '$backendBaseUrl/virtual-tryon/history/';
}
