json.array!(@questions) do |question|
  json.extract! question, :id, :name
  json.url question_url(question, format: :json)
end
