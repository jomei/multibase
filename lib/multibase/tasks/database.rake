namespace :db do
  namespace :second_base do
    task :test do
      p 'teststs!!'
      binding.pry
    end
  end
end