module FFMPEG
  class EncodingOptions < Hash
    def initialize(options = {})
      merge!(options)
    end

    def to_s
      params = collect do |key, value|
        send("convert_#{key}", value) if value && supports_option?(key)
      end

      # codecs should go before the presets so that the files will be matched successfully
      # all other parameters go after so that we can override whatever is in the preset
      codecs = params.select { |p| p =~ /codec/ }
      presets = params.select { |p| p =~ /\-.pre/ }
      watermarkoptions = params.select { |p| p =~ /i / || p=~ /filter_complex/ }  
      other = params - codecs - presets - watermarkoptions
      params = watermarkoptions + codecs + presets + other

      params_string = params.join(" ")
      params_string << " #{convert_aspect(calculate_aspect)}" if calculate_aspect?
      params_string
    end

    def width
      self["resolution"].split("x").first.to_i rescue nil
    end

    def height
      self["resolution"].split("x").last.to_i rescue nil
    end

    def reverse_resolution
      return "Resolution not found" if height.nil? || width.nil? 
      @reverse_resolution = height.to_s + "x" + width.to_s
      self["resolution"] = @reverse_resolution
    end

    private
    def supports_option?(option)
      option = RUBY_VERSION < "1.9" ? "convert_#{option}" : "convert_#{option}".to_sym
      private_methods.include?(option)
    end

    def convert_aspect(value)
      "-aspect #{value}"
    end

    def calculate_aspect
      width, height = self[:resolution].split("x")
      width.to_f / height.to_f
    end

    def calculate_aspect?
      self[:aspect].nil? && self[:resolution]
    end

    def convert_video_codec(value)
      "-vcodec #{value}"
    end

    def convert_frame_rate(value)
      "-r #{value}"
    end

    def convert_resolution(value)
      "-s #{value}"
    end

    def convert_video_bitrate(value)
      "-b:v #{k_format(value)}"
    end

    def convert_audio_codec(value)
      "-acodec #{value}"
    end

    def convert_audio_bitrate(value)
      "-b:a #{k_format(value)}"
    end

    def convert_audio_sample_rate(value)
      "-ar #{value}"
    end

    def convert_audio_channels(value)
      "-ac #{value}"
    end

    def convert_video_max_bitrate(value)
      "-maxrate #{k_format(value)}"
    end

    def convert_video_min_bitrate(value)
      "-minrate #{k_format(value)}"
    end

    def convert_buffer_size(value)
      "-bufsize #{k_format(value)}"
    end

    def convert_video_bitrate_tolerance(value)
      "-bt #{k_format(value)}"
    end

    def convert_threads(value)
      "-threads #{value}"
    end

    def convert_target(value)
      "-target #{value}"
    end

    def convert_duration(value)
      "-t #{value}"
    end

    def convert_video_preset(value)
      "-vpre #{value}"
    end

    def convert_audio_preset(value)
      "-apre #{value}"
    end

    def convert_file_preset(value)
      "-fpre #{value}"
    end

    def convert_keyframe_interval(value)
      "-g #{value}"
    end

    def convert_seek_time(value)
      "-ss #{value}"
    end

    def convert_screenshot(value)
      vframes = '-vframes 1 ' unless self[:vframes]
      value ? "#{vframes}-f image2" : ""
    end

    def convert_quality(value)
      "-q:v #{value}"
    end

    def convert_vframes(value)
      "-vframes #{value}"
    end

    def convert_x264_vprofile(value)
      "-vprofile #{value}"
    end

    def convert_x264_preset(value)
      "-preset #{value}"
    end

    def convert_watermark(value)
      "-i #{value}"
    end

    #---------------------------------

    def convert_cpu_used(value)
      "-cpu-used #{value}"
    end

    def convert_quality(value)
      "-deadline #{value}"
    end

    def convert_qmin(value)
      "-qmin #{value}"
    end

    def convert_qmax(value)
      "-qmax #{value}"
    end

    def convert_pass(value)
      "-pass #{value}"
    end

    def convert_passlogfile(value)
      "-passlogfile #{value}"
    end

    def convert_video_profile(value)
      "-profile:v #{value}"
    end

    def convert_crf(value)
      "-crf #{value}"
    end

    def convert_strict(value)
      "-strict #{value}"
    end

    def convert_transpose(value)
      "-vf transpose=#{value}"
    end

    #---------------------------------

    def convert_watermark_filter(value)
      case value[:position].to_s
      when "LT"
        "-filter_complex 'scale=#{self[:resolution]},overlay=x=#{value[:padding_x]}:y=#{value[:padding_y]}'"
      when "RT"
        "-filter_complex 'scale=#{self[:resolution]},overlay=x=main_w-overlay_w-#{value[:padding_x]}:y=#{value[:padding_y]}'"
      when "LB"
        "-filter_complex 'scale=#{self[:resolution]},overlay=x=#{value[:padding_x]}:y=main_h-overlay_h-#{value[:padding_y]}'"
      when "RB"
        "-filter_complex 'scale=#{self[:resolution]},overlay=x=main_w-overlay_w-#{value[:padding_x]}:y=main_h-overlay_h-#{value[:padding_y]}'"
      end  
    end

    def convert_custom(value)
      value
    end

    def k_format(value)
      value.to_s.include?("k") ? value : "#{value}k"
    end
  end
end
