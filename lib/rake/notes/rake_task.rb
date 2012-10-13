require 'rake'
require 'rake/tasklib'

require 'rake/notes/source_annotation_extractor'

module Rake
  module Notes
    class RakeTask < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      def initialize(*args)
        yield self if block_given?

        desc "Enumerate all annotations (use notes:optimize, :fixme, :todo for focus)"
        task :notes do
          SourceAnnotationExtractor.enumerate "OPTIMIZE|FIXME|TODO", :tag => true
        end

        namespace :notes do
          ["OPTIMIZE", "FIXME", "TODO"].each do |annotation|
            desc "Enumerate all #{annotation} annotations"
            task annotation.downcase.intern do
              SourceAnnotationExtractor.enumerate annotation
            end
          end

          desc "Enumerate a custom annotation, specify with ANNOTATION=CUSTOM"
          task :custom do
            SourceAnnotationExtractor.enumerate ENV['ANNOTATION']
          end
        end
      end
    end
  end
end

Rake::Notes::RakeTask.new
