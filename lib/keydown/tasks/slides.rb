require 'sass'
require 'compass'

module Keydown
  class Tasks < Thor

    desc "slides FILE", "Convert a Keydown FILE into an HTML presentation"

    def slides(file)

      file += '.md' unless file.match(/\.md$/)

      unless File.exist?(file)
        say "#{file} not found. Please call with a KeyDown Markdown file: keydown slides my_file.md", :red
        return
      end

      @@template_dir = File.join(Keydown::Tasks.source_root, 'templates', 'deck.js')

      say "Creating Keydown presentation from #{file}", :yellow

      slide_deck = SlideDeck.new(File.new(file).read)
      backgrounds = slide_deck.slides.collect do |slide|
        slide.background_image unless slide.background_image.empty?
      end.compact

      context = OpenStruct.new({ :backgrounds => backgrounds })
      scss_template = Tilt.new(File.join(Tasks.template_dir, '..', 'keydown.scss.erb'))
      scss = scss_template.render(context)

      # compass_path = File.join(Gem.loaded_specs['compass'].full_gem_path, 'frameworks', 'compass', 'stylesheets')
      

      Compass.sass_engine_options[:load_paths].each do |path|
        Sass.load_paths << path
      end
      
      puts "load paths: ", Sass.load_paths

      load_path = File.join(File.expand_path(File.dirname(__FILE__)), "features", "compass", "stylesheets")
      
      create_file 'css/keydown.css', :force => true do
        Sass::Engine.new(scss, :syntax => :scss, :load_paths => [load_path]).render
      end

      presentation = file.gsub('md', 'html')

      create_file presentation, :force => true do
        slide_deck.to_html
      end
    end
  end
end
