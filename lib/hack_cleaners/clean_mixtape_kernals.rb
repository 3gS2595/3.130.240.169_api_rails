require './config/environment/'

Mixtape.all.each do |mix|
  mix.content.each do |k|
    if !Kernal.exists?(k)
      mix.update_attribute(:content, (mix.content - [k]))
    end
  end
end
