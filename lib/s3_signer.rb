require './config/environment/'

module S3Signer
  def s3_signer_batch(page)
    signer = Aws::Sigv4::Signer.new(
      service: "s3",
      access_key_id: Rails.application.credentials.aws[:access_key_id],
      secret_access_key: Rails.application.credentials.aws[:secret_access_key],
      region: 'us-east-1'
    )
    page.each do |kernal|
      if !kernal.file_path.nil? && kernal.file_path.length > 0  && kernal.signed_url.nil?
        key = kernal.file_path
        nailKey = kernal.file_path

        if kernal.file_type == ".pdf"
          key = kernal.id + ".pdf"
          nailKey = kernal.id + ".avif"
        end
        kernal.assign_attributes({ 
          :signed_url => 
            signer.presign_url(
              http_method: "GET",
              url: "https://crystal-hair.nyc3.digitaloceanspaces.com/#{key}",
              expires_in: 600,
              body_digest: "UNSIGNED-PAYLOAD"
            ),
          :signed_url_s => 
            signer.presign_url(
              http_method: "GET",
              url: "https://crystal-hair-s.nyc3.digitaloceanspaces.com/s_160_#{nailKey}",
              expires_in: 600,
              body_digest: "UNSIGNED-PAYLOAD"
            ), 
          :signed_url_m => 
            signer.presign_url(
              http_method: "GET",
              url: "https://crystal-hair-m.nyc3.digitaloceanspaces.com/m_400_#{nailKey}",
              expires_in: 600,
              body_digest: "UNSIGNED-PAYLOAD"
            ),
          :signed_url_l => 
            signer.presign_url(
              http_method: "GET",
              url: "https://crystal-hair-l.nyc3.digitaloceanspaces.com/l_1000_#{nailKey}",
              expires_in: 600,
              body_digest: "UNSIGNED-PAYLOAD"
            )
        })      
      end
    end
    return page
  end
  
  def s3_signer_single(kernal)
    if !kernal.file_path.nil? && kernal.file_path.length > 0
      key = kernal.file_path
      nailKey = kernal.file_path
      if kernal.file_type == ".pdf"
        key = kernal.id + ".pdf"
        nailKey = kernal.id + ".avif"
      end

      signer = Aws::Sigv4::Signer.new(
        service: "s3",
        access_key_id: Rails.application.credentials.aws[:access_key_id],
        secret_access_key: Rails.application.credentials.aws[:secret_access_key],
        region: 'us-east-1'
      )
      kernal.assign_attributes({ 
        :signed_url => 
          signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair.nyc3.digitaloceanspaces.com/#{key}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          ),
        :signed_url_s => 
          signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair-s.nyc3.digitaloceanspaces.com/s_160_#{nailKey}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          ), 
        :signed_url_m => 
          signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair-m.nyc3.digitaloceanspaces.com/m_400_#{nailKey}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          ),
        :signed_url_l => 
          signer.presign_url(
            http_method: "GET",
            url: "https://crystal-hair-l.nyc3.digitaloceanspaces.com/l_1000_#{nailKey}",
            expires_in: 600,
            body_digest: "UNSIGNED-PAYLOAD"
          )
      })    
    end
    return kernal
  end
end


