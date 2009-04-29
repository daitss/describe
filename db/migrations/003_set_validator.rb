require "rubygems"
require "active_record"

class SetValidator < ActiveRecord::Migration
  def self.up
    execute "update formats set formats.validator = 
    (select validators.id from validators where validators.arguments like '%aif%' limit 1) 
    where formats.extensions like '%aif%' ";

    execute "update formats set formats.validator = 
    (select validators.id from validators where validators.arguments like '%pdf%' limit 1) 
    where formats.extensions like '%pdf%' ";

    execute "update formats set formats.validator = 
    (select validators.id from validators where validators.arguments like '%wav%' limit 1) 
    where formats.extensions like '%wav%' ";

    execute "update formats set formats.validator = 
    (select validators.id from validators where validators.arguments like '%xml%' limit 1) 
    where formats.extensions like '%xml%' ";

    execute "update formats set formats.validator = 
    (select validators.id from validators where validators.arguments like '%htm%' limit 1) 
    where formats.extensions like '%htm%' ";

    execute "update formats set formats.validator = 
    (select validators.id from validators where validators.arguments like '%tif%' limit 1) 
    where formats.extensions like '%tif%' ";

    execute "update formats set formats.validator = 
    (select validators.id from validators where validators.arguments like '%gif%' limit 1) 
    where formats.extensions like '%gif%' ";

    execute "update formats set formats.validator = 
    (select validators.id from validators where validators.arguments like '%jpeg%' limit 1) 
    where formats.extensions like '%jpeg%' ";

    execute "update formats set formats.validator = 
    (select validators.id from validators where validators.arguments like '%jpeg2000%' limit 1) 
    where formats.extensions like '%jp2%' ";
    
    execute "update formats set formats.validator = 
     (select validators.id from validators where validators.arguments like '%ascii%' limit 1) 
     where formats.extensions like '%txt%' ";
     
     execute "update formats set formats.validator = 
      (select validators.id from validators where validators.arguments like '%utf8%' limit 1) 
      where formats.info like '%Unicode%' ";
  end
  
  def self.down
    execute "update formats set validator = NULL";
  end
  
  SetValidator.migrate(:up)

end