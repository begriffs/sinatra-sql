require 'turn/autorun'

load 'Rakefile'

describe "Rakefile" do
  describe "migration_path" do
    it "generates a correct up-migration path" do
      migration_path([0,2,4,6], 2, 6).must_equal [4,6]
    end
    it "does not generate a path when source = target" do
      migration_path([0,2,4,6], 0, 0).must_equal []
    end
    it "generates a correct down-migration path" do
      migration_path([0,2,4,6], 6, 2).must_equal [6,4]
    end
    it "works with strings" do
      migration_path(['0','2','4','6'], '2', '6').must_equal ['4','6']
    end
    it "disallows unknown migration sources" do
      lambda { migration_path([0,2,4,6], 42, 0) }.must_raise RuntimeError
    end
    it "disallows unknown migration targets" do
      lambda { migration_path([0,2,4,6], 2, 42) }.must_raise RuntimeError
    end
  end

  describe "db:create" do
    it "starts at schema version 0" do
      Rake::Task["db:create"].execute 'env' => 'test'
      current_schema_version('test').must_equal '0'
      Rake::Task["db:drop"].execute 'env' => 'test'
    end
  end

  describe "db:migrate" do
    before do
      Rake::Task["db:create"].execute 'env' => 'test'
      sh 'cp spec/fixtures/migrations/1.{up,down}.sql db'
    end
    after do
      sh 'rm db/1.{up,down}.sql'
      Rake::Task["db:drop"].execute 'env' => 'test'
    end

    it "migrates up" do
      Rake::Task["db:migrate"].execute 'ver' => '1', 'env' => 'test'
      current_schema_version('test').must_equal '1'
    end
    it "is idempotent" do
      Rake::Task["db:migrate"].execute 'ver' => '1', 'env' => 'test'
      Rake::Task["db:migrate"].execute 'ver' => '1', 'env' => 'test'
      current_schema_version('test').must_equal '1'
    end
    it "migrates down" do
      Rake::Task["db:migrate"].execute 'ver' => '1', 'env' => 'test'
      Rake::Task["db:migrate"].execute 'ver' => '0', 'env' => 'test'
      current_schema_version('test').must_equal '0'
    end
  end
end
