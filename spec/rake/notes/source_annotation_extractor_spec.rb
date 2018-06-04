require 'spec_helper'

require 'rake/notes/source_annotation_extractor'

describe Rake::Notes::SourceAnnotationExtractor do
  let(:fixture_path) { "#{Dir.pwd}/.tmp" }

  before do
    @current_path = Dir.pwd
    Dir.mkdir(fixture_path) unless Dir.exist?(fixture_path)
    Dir.chdir(fixture_path)
  end

  after do
    Dir.chdir(@current_path)
  end

  context 'extracting notes based on file type' do
    subject do
      subj = StringIO.new
      described_class.enumerate('TODO', :out => subj)
      subj.string
    end

    before(:all) do
      fixture_file "index.html.erb", "<% # TODO: note in erb %>"
      fixture_file "index.html.haml", "- # TODO: note in haml"
      fixture_file "index.html.slim", "/ TODO: note in slim"
      fixture_file "application.js.coffee", "# TODO: note in coffee"
      fixture_file "application.js", "// TODO: note in js"
      fixture_file "application.css", "// TODO: note in css"
      fixture_file "application.css.scss", "// TODO: note in scss"
      fixture_file "component.tsx", "// TODO: note in tsx"
      fixture_file "application.ts", "// TODO note in ts"
      fixture_file "application_controller.rb", 1000.times.map { "" }.join("\n") << "# TODO: note in ruby"
      fixture_file "task.rake", "# TODO: note in rake"
      fixture_file "init.pp", "# TODO: note in puppet"
      fixture_file "config.yml", "# TODO: note in yml"
      fixture_file "config.yaml", "# TODO: note in yaml"
      fixture_file "gem.gemspec", "# TODO: note in gemspec"
      fixture_file "Vagrantfile", "# TODO: note in vagrantfile"
      fixture_file "Rakefile", "# TODO: note in rakefile"
      fixture_file "Puppetfile", "# TODO: note in puppetfile"
      fixture_file "Gemfile", "# TODO: note in gemfile"
      fixture_file "feature.feature", "# TODO: note in cucumber feature"
    end

    it { should match(/note in erb/) }
    it { should match(/note in haml/) }
    it { should match(/note in slim/) }
    it { should match(/note in ruby/) }
    it { should match(/note in coffee/) }
    it { should match(/note in js/) }
    it { should match(/note in css/) }
    it { should match(/note in scss/) }
    it { should match(/note in tsx/) }
    it { should match(/note in ts/) }
    it { should match(/note in rake/) }
    it { should match(/note in puppet/) }
    it { should match(/note in yml/) }
    it { should match(/note in yaml/) }
    it { should match(/note in gemspec/) }
    it { should match(/note in vagrantfile/) }
    it { should match(/note in rakefile/) }
    it { should match(/note in puppetfile/) }
    it { should match(/note in gemfile/) }
    it { should match(/note in cucumber feature/) }
  end

  def fixture_file(path, contents)
    FileUtils.mkdir_p File.dirname("#{fixture_path}/#{path}")
    File.open("#{fixture_path}/#{path}", 'w') do |f|
      f.puts contents
    end
  end
end
