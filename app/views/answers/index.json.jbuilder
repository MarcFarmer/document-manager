json.array!(@answers) do |answer|
  json.extract! answer, :id, :name, :correct, :type
  json.url answer_url(answer, format: :json)
end
