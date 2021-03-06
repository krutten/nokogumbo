$:.unshift('lib')
$:.unshift('ext/nokogumboc')

require 'nokogumbo'
require 'test/unit'

class TestNokogumbo < Test::Unit::TestCase
  def test_element_text
    doc = Nokogiri::HTML5(buffer)
    assert_equal "content", doc.at('span').text
  end

  def test_element_cdata
    doc = Nokogiri::HTML5(buffer)
    assert_equal "foo<x>bar", doc.at('textarea').text.strip
  end

  def test_attr_value
    doc = Nokogiri::HTML5(buffer)
    assert_equal "utf-8", doc.at('meta')['charset']
  end

  def test_comment
    doc = Nokogiri::HTML5(buffer)
    assert_equal " test comment ", doc.xpath('//comment()').text
  end

  def test_unknown_element
    doc = Nokogiri::HTML5(buffer)
    assert_equal "main", doc.at('main').name
  end

  def test_IO
    require 'stringio'
    doc = Nokogiri::HTML5(StringIO.new(buffer))
    assert_equal 'textarea', doc.at('form').element_children.first.name
  end

  def test_nil
    doc = Nokogiri::HTML5(nil)
    assert_equal 1, doc.search('body').count
  end

  if ''.respond_to? 'encoding'
    def test_macroman_encoding
      mac="<span>\xCA</span>".force_encoding('macroman')
      doc = Nokogiri::HTML5(mac)
      assert_equal '<span>&#xA0;</span>', doc.at('span').to_xml
    end

    def test_iso8859_encoding
      iso8859="<span>Se\xF1or</span>".force_encoding(Encoding::ASCII_8BIT)
      doc = Nokogiri::HTML5(iso8859)
      assert_equal '<span>Se&#xF1;or</span>', doc.at('span').to_xml
    end

    def test_charset_encoding
      utf8="<meta charset='utf-8'><span>Se\xC3\xB1or</span>".
        force_encoding(Encoding::ASCII_8BIT)
      doc = Nokogiri::HTML5(utf8)
      assert_equal '<span>Se&#xF1;or</span>', doc.at('span').to_xml
    end

    def test_bogus_encoding
      bogus="<meta charset='bogus'><span>Se\xF1or</span>".
        force_encoding(Encoding::ASCII_8BIT)
      doc = Nokogiri::HTML5(bogus)
      assert_equal '<span>Se&#xF1;or</span>', doc.at('span').to_xml
    end
  end

  def test_html5_doctype
    doc = Nokogumbo.parse("<!DOCTYPE html><html></html>")
    assert_match /<!DOCTYPE html>/, doc.to_html
  end

private

  def buffer
    <<-EOF.gsub(/^      /, '')
      <html>
        <head>
          <meta charset="utf-8"/>
          <title>hello world</title>
        </head>
        <body>
          <h1>hello world</h1>
          <main>
            <span>content</span>
          </main>
          <!-- test comment -->
          <form>
            <textarea>foo<x>bar</textarea>
          </form>
        </body>
      </html>
    EOF
  end

end
