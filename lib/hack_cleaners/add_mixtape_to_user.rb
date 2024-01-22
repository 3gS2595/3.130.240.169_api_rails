require './config/environment/'

perm = User.find('01f7aea6-dea7-4956-ad51-6dae41e705ca').permission
puts perm.id

new_mixtapes = []
Mixtape.all.each do |mix|
  new_mixtapes << mix.id
end
puts new_mixtapes
    perm.update(mixtapes: new_mixtapes)
