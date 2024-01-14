require './config/environment/'

mixedKernals = []
Mixtape.all.each do |mix|
  mixedKernals.concat(mix.content)
end

unused = Kernal.where.not(id: mixedKernals)
unused.where(src_url_subset_id:  '18653fe9-0a1f-4759-9743-02b87100e82b').delete_all

