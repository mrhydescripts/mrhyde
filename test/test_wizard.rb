# encoding: utf-8

require 'helper'


class EchoIO
  def initialize( buf )
    @io = StringIO.new( buf )
  end
  
  def gets
    str = @io.gets
    puts "|>#{str.chomp}<|"   ## remove newline (w/ chomp) in debug/echo output 
    str
  end
end


class TestWizard < MiniTest::Test

  include MrHyde::Wizard   ## lets you use ask etc.

  def test_ask

    $MRHYDE_WIZARD_IN = EchoIO.new( <<EOS )
Another Beautiful Static Site

H. J.

2
n
y
EOS

    say "Hello, Wizard!"

    title = ask "What's your site's title", "Your Site Title"
    assert_equal 'Another Beautiful Static Site', title

    title = ask "What's your site's title", "Your Site Title"
    assert_equal 'Your Site Title', title

    name = ask "Your Name"
    assert_equal 'H. J.', name

    theme = select "Select your theme", ["Starter", "Bootstrap", "Minimal"]
    assert_equal 'Starter', theme

    theme = select "Select your theme", ["Starter", "Bootstrap", "Minimal"]
    assert_equal 'Bootstrap', theme

    assert_equal false, yes?( "Add to GitHub" )
    assert_equal false, no?( "Add to GitHub" )

    assert true  ## if we get here; everything is ok
  end

end # class TestWizard