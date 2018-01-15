require 'colored'
require 'yaml'

module Rake
  module Notes
    # From:
    # https://github.com/rails/rails/blob/master/railties/lib/rails/source_annotation_extractor.rb
    #
    # Implements the logic behind the rake tasks for annotations like
    #
    #   rake notes
    #   rake notes:optimize
    #
    # and friends. See <tt>rake -T notes</tt>.
    #
    # Annotation objects are triplets <tt>:line</tt>, <tt>:tag</tt>, <tt>:text</tt> that
    # represent the line where the annotation lives, its tag, and its text. Note
    # the filename is not stored.
    #
    # Annotations are looked for in comments and modulus whitespace they have to
    # start with the tag optionally followed by a colon. Everything up to the end
    # of the line (or closing ERB comment tag) is considered to be their text.
    class SourceAnnotationExtractor
      RUBYFILES = %w( Vagrantfile Rakefile Puppetfile Gemfile )
      # `gem install --standalone` puts gems into $project/bundle and it really slows
      # down the rake task
      DEFAULT_IGNORE_DIRS = { 'ignore' => [ './bundle', './vendor' ] }

      def self.ignore_dirs
        @ignore_dirs ||= begin
          config = DEFAULT_IGNORE_DIRS
          config = config.merge(YAML.safe_load(File.read('./.rake-notes.yml'))) if File.exist?('./.rake-notes.yml')
          config['ignore'] || []
        end
      end

      class Annotation < Struct.new(:line, :tag, :text)
        COLORS = {
          'OPTIMIZE' => 'cyan',
          'FIXME' => 'red',
          'TODO' => 'yellow'
        }

        # Returns a representation of the annotation that looks like this:
        #
        #   [126] [TODO] This algorithm is simple and clearly correct, make it faster.
        #
        # If +options+ has a flag <tt>:tag</tt> the tag is shown as in the example above.
        # Otherwise the string contains just line and text.
        def to_s(options={})
          colored_tag = COLORS[tag.to_s].nil? ? tag : tag.send(COLORS[tag.to_s])
          s = "[#{line.to_s.rjust(options[:indent]).green}] "
          s << "[#{colored_tag}] " if options[:tag]
          s << text
        end
      end

      # Prints all annotations with tag +tag+ under the current directory. Only
      # known file types are taken into account. The +options+ hash is passed
      # to each annotation's +to_s+.
      #
      # This class method is the single entry point for the rake tasks.
      def self.enumerate(tag, options={})
        extractor = new(tag)
        extractor.display(extractor.find, options)
      end

      attr_reader :tag

      def initialize(tag)
        @tag = tag
      end

      # Returns a hash that maps filenames to arrays with their annotations.
      def find
        find_in('.')
      end

      # Returns a hash that maps filenames under +dir+ (recursively) to arrays
      # with their annotations. Only files with annotations are included, and only
      # known file types are taken into account.
      def find_in(dir)
        results = {}
        Dir.glob("#{dir}/*") do |item|
          next if File.basename(item)[0] == ?.

          if File.directory?(item)
            next if SourceAnnotationExtractor.ignore_dirs.include?(item)
            results.update(find_in(item))
          elsif item =~ /\.(builder|rb|coffee|rake|pp|ya?ml|gemspec|feature)$/ || RUBYFILES.include?(File.basename(item))
            results.update(extract_annotations_from(item, /#\s*(#{tag}):?\s*(.*)$/))
          elsif item =~ /\.(css|scss|js)$/
            results.update(extract_annotations_from(item, /\/\/\s*(#{tag}):?\s*(.*)$/))
          elsif item =~ /\.erb$/
            results.update(extract_annotations_from(item, /<%\s*#\s*(#{tag}):?\s*(.*?)\s*%>/))
          elsif item =~ /\.haml$/
            results.update(extract_annotations_from(item, /-\s*#\s*(#{tag}):?\s*(.*)$/))
          elsif item =~ /\.slim$/
            results.update(extract_annotations_from(item, /\/\s*\s*(#{tag}):?\s*(.*)$/))
          end
        end

        results
      end

      # If +file+ is the filename of a file that contains annotations this method returns
      # a hash with a single entry that maps +file+ to an array of its annotations.
      # Otherwise it returns an empty hash.
      def extract_annotations_from(file, pattern)
        lineno = 0
        result = File.readlines(file).inject([]) do |list, line|
          lineno += 1
          next list unless line =~ pattern
          list << Annotation.new(lineno, $1, $2)
        end
        result.empty? ? {} : { file => result }
      end

      # Prints the mapping from filenames to annotations in +results+ ordered by filename.
      # The +options+ hash is passed to each annotation's +to_s+.
      def display(results, options={})
        options[:indent] = results.map { |f, a| a.map(&:line) }.flatten.max.to_s.size
        out = options.delete(:out) || $stdout
        results.keys.sort.each do |file|
          out.puts "#{file[2..-1]}:"
          results[file].each do |note|
            out.puts "  * #{note.to_s(options)}"
          end
          out.puts
        end
      end
    end
  end
end
