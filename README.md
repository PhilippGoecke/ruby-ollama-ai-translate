# ruby-ollama-ai-translate
Ruby Ollama Ai Translate

OLLAMA_HOST="http://0.0.0.0:11434" ollama serve

irb -I . -r translate.rb

translator = AiTranslator.new  
translator.load_model

AiTranslator.test
