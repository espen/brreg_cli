#!/usr/bin/env ruby
# encoding: utf-8

require 'optparse'
require 'brreg'

cli_params = {}

opts = OptionParser.new do |opt|
  opt.banner = "Usage: brreg [options] OR brreg orgnr/query/domain"

  opt.on('-n', '--orgnr ORGNR', 'Organisasjonsnummer') do |orgnr|
    cli_params[:orgnr] = orgnr.to_i
  end

  opt.on('-q', '--query QUERY', 'Firmanavn') do |query|
    cli_params[:query] = query
  end

  opt.on('-d', '--domain DOMAIN', 'Domenenavn (kun .no)') do |domain|
    cli_params[:domain] = domain
  end

  opt.on('-v', '--version', 'Versjon') { puts "Brreg query version 0.1.2"; exit }
end
begin
  opts.parse!
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts opts
  exit
end

def numeric?(object)
  true if Float(object) rescue false
end


if cli_params.length > 0
  if cli_params[:orgnr]
    Brreg.find_by_orgnr(cli_params[:orgnr])
  elsif cli_params[:query]
    Brreg.find( cli_params[:query])
  elsif cli_params[:domain]
    Brreg.find_by_domain( cli_params[:domain])
  end
elsif ARGV.length > 0
  input = ARGV.first
  if numeric?(input)
    Brreg.find_by_orgnr( input.to_i )
  elsif input.include?('.no')
    Brreg.find_by_domain( input )
  else
    Brreg.find( input )
  end
else
  puts opts
end