require "rubygems"
require "active_record"
require "droid"

class Registry < ActiveRecord::Base
  set_table_name :registries
end

class Setup < ActiveRecord::Migration
  def self.up
    create_table :registries, :force => true do |t|
      t.column "name",      :string
      t.column "url",       :string
    end
    
    create_table :formats, :force => true do |t|
      t.column "registry",   :string
      t.column "rid", :string
      t.column "info", :string
      t.column "extensions", :text
      t.column "mime_type",  :string
      t.column "validator",  :integer
      t.column "lookup", :string
    end

    create_table :validators, :force => true do |t|
      t.column "name",      :string
      t.column "routine",   :string
      t.column "arguments", :string
      t.column "priority", :integer
    end

    #initialize registries
    registry = Registry.new
    registry.name = 'PRONOM'
    registry.url = 'http://www.nationalarchives.gov.uk/pronom'
    registry.save!
    
    #importing V13 data
    droid = Droid.new("conf/DROID_SignatureFile_V13.xml")
    droid.extract_V13
  end

  def self.down
    drop_table :registrie
    drop_table :formats
    drop_table :validators
  end
  
  Setup.migrate(:up)
end



