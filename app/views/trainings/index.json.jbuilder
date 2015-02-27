json.array!(@trainings) do |training|
  json.extract! training, :id
  json.url training_url(training, format: :json)
end
