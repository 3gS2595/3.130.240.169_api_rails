require './config/environment/'
require 'mini_magick'
require 'numo/narray'
require 'onnxruntime'


model = OnnxRuntime::Model.new("/home/ubuntu/crystal.hair-backend-rails/lib/onxx/model1.onnx")

SrcUrlSubset.all.each do |src|
  puts(src.name)
  cur = 0

  # image collect
  @q = Kernal.where(src_url_subset_id: src.id)
  cnt = @q.count
  
  # preprocessing
  @q.each do |k|
    if(!k.signed_url_s.nil? && (k.signed_url_s.include?("webp") || k.signed_url_s.include?("pnj")  || k.signed_url_s.include?("png") || k.signed_url_s.include?("jpg") || k.signed_url_s.include?("jpeg")))
      begin
        # preprocessing
        img = MiniMagick::Image.open(k.signed_url_s)
        img.combine_options do |b|
          b.resize '224x224!'
        end
        img_data = Numo::SFloat.cast(img.get_pixels)
        img_data /= 255.0
        image_data = img_data.expand_dims(0).to_a

        # inference
        output = model.predict({input: image_data})
        
        # postprocessing
        scores = output.values
        if (scores[0][0][1] > 0.995 )
          @content = Mixtape.find('778a904d-76aa-4e62-a5f3-b0e11a4df2e7').content
          if (!@content.contains.include?(k.id))
            new = @content.contains.append(k.id)
            Content.update(@content.id, :contains => new)
            puts(k.signed_url_s)
            puts(scores[0][0][1])
            puts()
          end
        elsif (scores[0][0][1] > 0.98 )
          @content = Mixtape.find('7efabc59-fab1-48b6-8aa0-c4ce76519db9').content
          if (!@content.contains.include?(k.id))
            new = @content.contains.append(k.id)
            Content.update(@content.id, :contains => new)
            puts(k.signed_url_s)
            puts(scores[0][0][1])
            puts()
          end
        elsif (scores[0][0][1] > 0.95 )
          @content = Mixtape.find('082d00b6-199a-4a2d-8963-f2e0e48fe188').content
          if (!@content.contains.include?(k.id))
            new = @content.contains.append(k.id)
            Content.update(@content.id, :contains => new)
            puts(k.signed_url_s)
            puts(scores[0][0][1])
            puts()
          end
        elsif (scores[0][0][1] > 0.90 )
          @content = Mixtape.find('e4c32460-1d0b-4762-b0e8-af0b5ab3d622').content
          if (!@content.contains.include?(k.id))
            new = @content.contains.append(k.id)
            Content.update(@content.id, :contains => new)
            puts(k.signed_url_s)
            puts(scores[0][0][1])
            puts()
          end
        elsif (scores[0][0][1] > 0.85 )
          @content = Mixtape.find('7cac1137-c6a8-43b3-80fb-51f1482091c6').content
          if (!@content.contains.include?(k.id))
            new = @content.contains.append(k.id)
            Content.update(@content.id, :contains => new)
            puts(k.signed_url_s)
            puts(scores[0][0][1])
            puts()
          end
        elsif (scores[0][0][1] > 0.80 )
          @content = Mixtape.find('96e63e0d-6bf4-48fe-a090-01f2fa8dd19f').content
          if (!@content.contains.include?(k.id))
            new = @content.contains.append(k.id)
            Content.update(@content.id, :contains => new)
            puts(k.signed_url_s)
            puts(scores[0][0][1])
            puts()
          end
        end
      rescue
        puts("ERROR:skipping")
      ensure 
        cur = cur + 1
        puts(cur.to_s + " /" + cnt.to_s)
      end
    end
  end
end

