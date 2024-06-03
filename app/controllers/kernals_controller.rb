class KernalsController < ApplicationController
  before_action :authenticate_user!
  require "selenium-webdriver"
  include S3Signer
  
  # GET
  def index
    if !params.has_key?(:forceGraph)
      if (!params.has_key?(:src_url_subset_id))
        if params.has_key?(:mixtape)
          # fetch specific mixtape's kernals
          @q = Kernal.order(time_posted: :desc).where(id: Mixtape.find(params[:mixtape]).content.contains)
        else
          # fetch kernals in any mixtape
          if params[:feed] == 'true'
            @q = Kernal.order(time_posted: :desc).where(id: Mixtape.where(id: current_user.user_feed.feed_mixtape).joins(:content).pluck(:'contents.contains').flatten)
          else
            @q = Kernal.order(time_posted: :desc).where(id: Mixtape.where(id: current_user.permission.mixtapes).joins(:content).pluck(:'contents.contains').flatten)
          end
        end
      else 
        if(params[:src_url_subset_id] != "-1")
          # fetch specific src_url_subset's kernals 
          @q = Kernal.where(src_url_subset_id: params[:src_url_subset_id]).order(time_posted: :desc)
        else
          if params[:feed] == 'true'
            @q = Kernal.where(src_url_subset_id: current_user.user_feed.feed_sources).order(time_posted: :desc)
          else
            @q = Kernal.where(src_url_subset_id: current_user.permission.src_url_subsets).order(time_posted: :desc)
          end
        end
      end; nil

      # page, search, and presign media
      if params.has_key?(:tags)
        @q = @q.where(label: 'iconography')
      end
      @q = params.has_key?(:q) ? @q.ransack(search_params).result : @q
      @page = @q.page(params[:page]).per(@page_size).fast_page
      @page = s3_signer_batch(@page) 
      render json: @page

    # FORCE GRAPH DATA GENERATION
    else
      # fetches forceGraph data
      if params.has_key?(:mixtape)
        @q = Mixtape.where(id: params[:mixtape]).joins(:content).pluck(:'contents.contains').flatten
      else
        @q = Mixtape.where(id: current_user.permission.mixtapes).joins(:content).pluck(:'contents.contains').flatten
        @q = @q.group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first)
      end
      # fetch kernals in any mixtape
      @q = Kernal.where(id: @q).pluck(:'id').flatten
      links = []
      nodes = []
      Kernal.where(id: @q).each do |k|
        nodes << { "id" => k.id, "name" => k.id, 'val' => '8', "color" => '#ffc0cb' }
      end
      Mixtape.where(id: current_user.permission.mixtapes).each do |mix|
        if (@q.intersection(mix.content.contains).any? )
          nodes << { "id" => mix.id, "name" => mix.name, 'val' => '8', "color" => '#3459b1' }
        end
        @q.intersection(mix.content.contains).each do |k|
          links << { "source" => k, "target" => mix.id, "color" => "#a3ad99" } 
        end
      end
      ret = {"nodes" => nodes, "links" => links}
      render json: ret
    end; nil
  end

  # GET
  def show
    @kernal = Kernal.find(params[:id])
    render json: @kernal
  end

  # POST /kernals
  def create
    uuid = SecureRandom.uuid
    @kernal = Kernal.new(
      file_path: uuid + params[:file_type],
      file_type: params[:file_type],
      time_posted: DateTime.now(),
      permissions: [current_user.id]
    )
    @kernal.id = uuid
    @kernal.save
    if (params.has_key?(:image))
      File.open(params[:image]) do |file| 
        if (params[:image].original_filename.include?("gif"))
            uploader = GifUploader.new(@kernal)
            uploader.store!(file) 
          else
            uploader = ImageUploader.new(@kernal)
            uploader.store!(file) 
          end
      end
    end
    if (params.has_key?(:pdf))
      uploader = PdfUploader.new(@kernal)
      @kernal.update_attribute(:file_type, ".pdf")
      File.open(params[:pdf]) do |file| 
        uploader.store!(file) end
    end
    if (params.has_key?(:text))
      @kernal.update_attribute(:description, params[:text])
    end
    if params.has_key?(:mixtape) 
      @content = Mixtape.find(params[:mixtape]).content
      new = @content.contains.append(@kernal.id)
      Content.update(@content.id, :contains => new)
    end
    if params.has_key?(:url) 
      options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
      driver = Selenium::WebDriver.for(:firefox, options: options) 
      driver.manage.window.resize_to(1080, 1080)
      driver.navigate.to params[:url]
      sleep(3) 
      @kernal.update_attribute(:url, params[:url])
      driver.save_screenshot("selenium.png")
      driver.quit
      file = File.open("./selenium.png")
      uploader = ImageUploader.new(@kernal)
      uploader.store!(file)
    end
    @kernal.save

    # presign urls
    @kernal = s3_signer_single(@kernal)
    render json: @kernal, status: :created, location: @kernal
  end

  # PATCH/PUT
  def update
    @kernal = Kernal.find(params[:id])
    if @kernal.update(kernal_params)
      render json: @kernal
    else
      render json: @kernal.errors, status: :unprocessable_entity
    end
  end

  # DELETE
  def destroy
    @kernal = Kernal.find(params[:id])
    Mixtape.where(id: current_user.permission.mixtapes).each do |mix|
      if mix.content.contains.include? params[:id]
        new = mix.content.contains
        new.delete(params[:id]) 
        Content.update(mix.content.id, :contains => new)
      end
    end
    SrcUrlSubset.where(id: current_user.permission.src_url_subsets).each do |src|
      if src.content.contains.include? params[:id]
        new = src.content.contains 
        new.delete(params[:id])
        Content.update(src.content.id, :contains => new)
      end
    end
    @kernal.destroy
  end

  private
    def search_params
      qkey = ''
      Kernal.column_names.each do |e|
        if e != 'size' && e != 'permissions'
          qkey = qkey + e + '_or_'
        end
      end
      qkey =  qkey.chomp('_or_') + '_i_cont_any'
      default_params = {qkey => params[:q]}
    end

    def search_tags_params
      qkey = 'hashtags_i_cont_any'
      default_params = {qkey => params[:tags]}
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_kernal
      @kernal = Kernal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def kernal_params
      params.permit(
        :image, 
        :forceGraph, 
        :src_url_subset_id, 
        :src_url_subset_assigned_id,
        :mixtape, 
        :hypertext_id, 
        :source_url_id, 
        :signed_url, 
        :signed_url_m, 
        :signed_url_s, 
        :signed_url_l, 
        :file_type, 
        :file_name, 
        :file_path, 
        :url, 
        :size, 
        :author, 
        :description,
        :time_posted, 
        :time_scraped, 
        :description, 
        :key_words, 
        :hashtags, 
        :likes, 
        :reposts,
        :id,
      )
    end
end
