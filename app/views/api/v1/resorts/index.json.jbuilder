json.array! @resorts do |resort|
  json.extract! resort, :id, :name, :prefecture
end
