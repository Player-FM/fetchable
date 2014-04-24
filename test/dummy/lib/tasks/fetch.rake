task :fetch => :environment do
  Fetchable::Runners::LoopRunner.new.run(Document)
end
