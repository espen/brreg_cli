#!/usr/bin/env ruby
# encoding: utf-8

require 'optparse'
require 'net/http'
require 'json'

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

module Brreg
  BrregURI = 'http://hotell.difi.no/api/json/brreg/enhetsregisteret'
  def self.find_by_orgnr(orgnr)
    res = get_json( { :orgnr => orgnr } )
    if res.is_a?(Net::HTTPSuccess)
      jsonres = JSON.parse(res.body)
      if jsonres['posts'].to_i > 0
        company = jsonres['entries'].first
        puts "Viser oppføring for orgnr #{orgnr}"
        puts '...............'
        puts company['navn']
        puts company['forretningsadr']
        puts company['forradrpostnr'] + ' ' + company['forradrpoststed']
        puts company['postadresse']
        puts company['ppostnr'] + ' ' + company['ppoststed']
      else
        puts "Fant ingen oppføring for #{orgnr}"
      end
    end
  end

  def self.find_by_domain(domain)
    res = `whois #{domain}`
    res.encode!('UTF-8', 'UTF-8', :invalid => :replace)
    if res.gsub('Id Type').first
      s = /\Id Number..................:\s(\d{9})/
      Brreg.find_by_orgnr( res.scan(s).first.first.to_i )
      puts "\nBasert på Whois fra domenet #{domain}"
    elsif res.gsub('% No match').first
      puts "Domenet #{domain} er ikke registert"
    else
      puts "Ukjent svar fra Whois. Det er kun mulig å søke på .no domener."
    end
  end

  def self.find(query)
    puts "Søker etter '#{query}'"
    puts '...............'
    res = self.get_json( { :query => query } )
    if res.is_a?(Net::HTTPSuccess)
      jsonres = JSON.parse(res.body)
      if jsonres['posts'].to_i > 0
        for entry in jsonres['entries']
          puts entry['orgnr'] + ' ' + entry['navn']
        end
      else
        puts "Fant ingen oppføringer med navn #{query}"
      end
    end
  end

  private

  def self.get_json(params)
    uri = URI(BrregURI)
    uri.query = URI.encode_www_form(params)
    Net::HTTP.get_response(uri)
  end
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