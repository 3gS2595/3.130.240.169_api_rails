require './config/environment/'

Mixtape.all.each do |mix|
  new_kernals = mix.content
  @newContents = Content.create(
    contains: new_kernals
  )
  mix.update_attribute(:contents, @newContents.id)
  puts '--'
  puts mix.name
  puts @newContents.id
  puts mix.contents
  puts new_kernals.length
end
