require 'libxml'
require 'libxslt'

module FormatStylesheet

  include LibXML
  include LibXSLT

  def apply_xsl xsl_file_name
    stylesheet_file = xsl_file xsl_file_name
    stylesheet_doc = open(stylesheet_file) { |io| LibXML::XML::Document::io io }
    stylesheet = LibXSLT::XSLT::Stylesheet.new stylesheet_doc

    # apply the xslt
    # TODO make an entire doc out of @jhove?
    tmpDoc = stylesheet.apply @jhove.doc
  end

end
