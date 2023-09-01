require './config/environment/'

Arena.configure do |config|
    config.access_token = 'XC3fJj8wxLJIi0Bt39sxsoMpJ_39WpQtrLC7tD9ACwg'
end


flag = false
i = 0
e = Arena.user_channels('494214', options={page: i}).channels
while e.length > 0
  e.each do |a| 
    title = a.title
    chId = a.id
    puts(title)
    if !Mixtape.exists?(name: title)
      @mix = Mixtape.create(
        name: title
      )
    end

    n = 0
    b = Arena.channel(chId, options={page: n}).contents
    while b.length > 0
      b.each do |a| 
        puts(a.class)
      end
      n = n + 1
      b = Arena.channel(chId, options={page: n}).contents
    end
  end
  i = i + 1
  e = Arena.user_channels('494214', options={page: i}).channels
end
