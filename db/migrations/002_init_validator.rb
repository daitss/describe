require "rubygems"
require "active_record"

class Validator < ActiveRecord::Base
  set_table_name :validators
end

class InitValidator < ActiveRecord::Migration
  def self.up
    Validator.create(
    :name => "PDF", 
    :routine => "extract",
    :arguments => "pdf-hul",
    :priority => "1")
    
    Validator.create(
    :name => "RXML",
    :routine => "extract",
    :arguments => "xml-hul",
    :priority => "1")

    Validator.create(
    :name => "FormatBase",
    :routine => "extract",
    :arguments => "html-hul",
    :priority => "1")

    Validator.create(
    :name => "ASCII",
    :routine => "extract",
    :arguments => "ascii-hul",
    :priority => "1")

    Validator.create(
    :name => "UTF8",
    :routine => "extract",
    :arguments => "utf8-hul",
    :priority => "2")

    Validator.create(
    :name => "Tiff",
    :routine => "extract",
    :arguments => "tiff-hul",
    :priority => "1")

    Validator.create(
    :name => "Jpeg",
    :routine => "extract",
    :arguments => "jpeg-hul",
    :priority => "1")

    Validator.create(
    :name => "Image",
    :routine => "extract",
    :arguments => "jpeg2000-hul",
    :priority => "1")

    Validator.create(
    :name => "Image",
    :routine => "extract",
    :arguments => "gif-hul",
    :priority => "1")

    Validator.create(
    :name => "Audio",
    :routine => "extract",
    :arguments => "aiff-hul",
    :priority => "1")

    Validator.create(
    :name => "Audio",
    :routine => "extract",
    :arguments => "wave-hul",
    :priority => "1")     
    
    #setting the lookup string which map the format result from validation back to format id
    execute "update formats set formats.lookup = 'TIFF 3.0' where formats.rid = 'fmt/7' ";
    execute "update formats set formats.lookup = 'TIFF 4.0' where formats.rid = 'fmt/8' ";
    execute "update formats set formats.lookup = 'TIFF 5.0' where formats.rid = 'fmt/9' ";
    execute "update formats set formats.lookup = 'TIFF 6.0' where formats.rid = 'fmt/10' ";
    execute "update formats set formats.lookup = 'PDF 1.0' where formats.rid = 'fmt/14' ";
    execute "update formats set formats.lookup = 'PDF 1.1' where formats.rid = 'fmt/15' ";
    execute "update formats set formats.lookup = 'PDF 1.2' where formats.rid = 'fmt/16' ";
    execute "update formats set formats.lookup = 'PDF 1.3' where formats.rid = 'fmt/17' ";
    execute "update formats set formats.lookup = 'PDF 1.4' where formats.rid = 'fmt/18' ";
    execute "update formats set formats.lookup = 'PDF 1.5' where formats.rid = 'fmt/19' ";
    execute "update formats set formats.lookup = 'PDF 1.6' where formats.rid = 'fmt/20' ";
  end

  def self.down
    Validator.delete_all
  end
  
  InitValidator.migrate(:up)
end
