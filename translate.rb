require 'ollama-ai'

class AiTranslator
  def initialize
    @client = Ollama.new(
      credentials: { address: 'http://localhost:11434' },
      options: { server_sent_events: true, temperature: 0 }
    )
  end

  def load_model
    result = @client.pull(
      { name: 'qwen3:8b' }
    ) do |event, raw|
      puts event
    end
  end

  def prompt_response(prompt)
    response = @client.generate({
      model: 'qwen3:8b',
      prompt:,
      stream: false
    })

    response.first['response']
  end

  def translate(text, source_lang: 'de', target_lang: 'en', glossary: {})
    glossary_prompt = glossary.map { |term, translation| "#{term} => #{translation}" }.join(", ")

    response_text = prompt_response("Please translate this #{source_lang} text to #{target_lang} using the following glossary: #{glossary_prompt}. Ensure glossary terms are translated strictly according to the glossary. Text: '#{text}' and return the result solely as json with response format: {\"translation\": <value>}.")
    #puts "Ai Response: #{response_text}"

    # Clean and parse JSON
    cleaned = clean_json_string(response_text)
    #puts "Cleaned: #{cleaned.inspect}"
    parsed = parse_json(cleaned)
    #puts "Parsed JSON: #{parsed.inspect}"
    parsed['translation'] || 'Lost in translation'
  end

  def text_similarity(text1, text2)
    response_text = prompt_response("Evaluate the semantic similarity between the following two texts and return the result as a JSON object with a score from 0 to 10:\nText 1: '#{text1}'\nText 2: '#{text2}'\nResponse format: {\"similarity_score\": <value>}.")
    #puts "Ai Response: #{response_text}"

    # Clean and parse JSON
    cleaned = clean_json_string(response_text)
    #puts "Cleaned: #{cleaned.inspect}"
    parsed = parse_json(cleaned)
    #puts "Parsed JSON: #{parsed.inspect}"
    parsed['similarity_score']
  end

  def parse_json(json_string)
    begin
      JSON.parse(json_string)
    rescue JSON::ParserError
      {}
    end
  end

  def clean_json_string(text)
    # Extract JSON content from text using regex
    json_match = text.match(/(\{.*?\})/)
    json_match ? json_match[1] : ''
  end

  # AiTranslator.test
  def self.test
    translator = AiTranslator.new
    text = "Entdecke das neue aPhone 42 von Guple. Es hat eine gigantische Batterielaufzeit, einen rasanten CPU, unbegrenzt RAM und deaktivierte KI."
    puts "German: #{text}"
    
    # Define a glossary for specific terms
    glossary = {
      'aPhone': 'Smartphone',
      'Guple': 'Guplotech',
      'RAM': 'Random Access Memorial',
      'KI': 'Artificial Stupidity'
    }

    # Translate with glossary
    english = translator.translate(text, source_lang: 'de', target_lang: 'en', glossary: glossary)
    puts "English (with glossary): #{english}"

    # Backtranslate
    german_back = translator.translate(english, source_lang: 'en', target_lang: 'de', glossary: glossary.invert)
    puts "German back translation: #{german_back}"

    puts "Similarity: #{translator.text_similarity(text, german_back)}/10"

    # Negative test
    lorem = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    puts "Lorem Similarity: #{translator.text_similarity(text, lorem)}/10"

    # Similar test
    similar = "Das neue bPhone 21 von Elpug Two. Es hat eine riesige Batterielaufzeit, einen flotten Prozessor und limitiert RAM."
    puts "Similar Text Similarity: #{translator.text_similarity(text, similar)}/10"
  end
end

# Example usage:
# AiTranslator.load_model
#
# translator = AiTranslator.new
# puts translator.translate("Hallo, wie geht's?")
#
# AiTranslator.test
