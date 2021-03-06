# encoding: utf-8

### NOTE: wrap gli config into a class
##  see github.com/davetron5000/gli/issues/153

module MrHyde

class Tool
  def initialize
    LogUtils::Logger.root.level = :info   # set logging level to info 
  end

  def run( args )
    puts MrHyde.banner
    Toolii.run( args )
  end
end

## NOTE: gli added function are class methods (thus, wrap class Toolii in Tool for now)

class Toolii
  extend GLI::App

  def self.logger=(value) @@logger=value; end
  def self.logger()       @@logger; end

  ## todo: find a better name e.g. change to settings? config? safe_opts? why? why not?
  def self.opts=(value)  @@opts = value; end
  def self.opts()        @@opts; end


logger = LogUtils::Logger.root
opts   = Opts.new 


program_desc 'jekyll command line tool .:. the static site quick starter script wizard'
version VERSION


## desc 'Use only local (offline) cached data; no (online) remote network access'
## switch [:l, :local], negatable: false

desc '(Debug) Show debug messages'
switch [:verbose], negatable: false    ## todo: use -w for short form? check ruby interpreter if in use too?

desc '(Debug) Dry run; run script in simulation for testing'
switch [:test, :dry_run], negatable: false


def self.fetch_script( name )

  ## first try local version in working folder

  text = ''
  local_script = "./#{name}.rb"
  if File.exist?( local_script )
    text = File.read_utf8( local_script )
  else  ## fetch remote script
    url = "https://github.com/mrhydescripts/scripts/raw/master/#{name}.rb"

    puts "GET #{url}"    ##  todo - add color e.g. .bold.green
    
    ## assume utf8 text encoding for now
    worker = Fetcher::Worker.new
    text = worker.read_utf8!( url )
  end

  text
end


desc "Run static site quick starter script"
arg_name 'NAME'   # required theme name
command [:new,:n] do |c|

  c.action do |g,o,args|

    name = args[0] || 'starter'

    script = fetch_script( name )
    if opts.test?
      puts "dry (test) run:"
      Builder.load( script, test: true )
    else
      Builder.load( script )
    end

    puts 'Done.'
  end # action
end  # command setup



desc '(Debug) Test command suite'
command :test do |c|
  c.action do |g,o,args|

    puts "hello from test command"
    puts "args (#{args.class.name}):"
    pp args
    puts "o (#{o.class.name}):"
    pp o
    puts "g (#{g.class.name}):"
    pp g
    
    LogUtils::Logger.root.debug 'test debug msg'
    LogUtils::Logger.root.info 'test info msg'
    LogUtils::Logger.root.warn 'test warn msg'
    
    puts 'Done.'
  end
end



pre do |g,c,o,args|
  opts.merge_gli_options!( g )
  opts.merge_gli_options!( o )

  puts MrHyde.banner

  if opts.verbose?
    LogUtils::Logger.root.level = :debug
  end

  logger.debug "Executing #{c.name}"   
  true
end

post do |global,c,o,args|
  logger.debug "Executed #{c.name}"
  true
end


on_error do |e|
  puts
  puts "*** error: #{e.message}"

  if opts.verbose?
    puts e.backtrace
  end

  false # skip default error handling
end


### exit run(ARGV)  ## note: use Toolii.run( ARGV ) outside of class

end  # class Toolii

end # module MrHyde
