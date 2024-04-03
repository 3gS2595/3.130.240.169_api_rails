require './config/environment/'

usr = User.find('01f7aea6-dea7-4956-ad51-6dae41e705ca')
links = []
nodes = []
# fetches forceGraph data
# if is mixtape
#   all in mixtape
#   check all mixtape for overlap
#       add any overlapping mix
# else build all that are in two or more mix
#   add any overlaping mixtape

class Array
  def grand_intersection
    self.reduce :&
  end
end

# fetch kernals in any mixtape
@kIds = Mixtape.where(id: usr.permission.mixtapes).joins(:content).pluck(:'contents.contains').flatten
puts(@kIds.length())
@kIds = @kIds.group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first)
puts(@kIds.length())
puts('---------')

@kIds.each do |k|
  nodes << { "id" => k, "name" => k, 'val' => '8', "color" => '#ffc0cb' }
end

Mixtape.where(id: usr.permission.mixtapes).each do |mix|
  nodes << { "id" => mix.id, "name" => mix.name, 'val' => '8', "color" => '#3459b1' }
  @kIds.intersection(mix.content.contains).each do |k|
    links << { "source" => k, "target" => mix.id, "color" => "#a3ad99" } 
  end
end


ret = {"nodes" => nodes, "links" => links}
puts(links.length())
puts(nodes.length())
