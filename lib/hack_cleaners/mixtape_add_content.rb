require './config/environment/'

Mixtape.all.each do |mix|
  @cont = Content.find(mix.contents)
  @cont.assign_attributes(:permissions => Mixtape.find(mix.id).permissions)
  @cont.save
  puts @cont.permissions.instance_of? Array
  puts Content.find(mix.contents).permissions
  puts @cont.errors.inspect
  puts ''

end

