#!/usr/bin/env ruby
# encoding: utf-8

require 'optparse'
require 'net/http'
require 'json'

cli_params = {}

opts = OptionParser.new do |opt|
  opt.on('-n', '--orgnr ORGNR', 'Organisasjonsnummer') do |orgnr|
    cli_params[:orgnr] = orgnr.to_i
  end

  opt.on('-q', '--query QUERY', 'Firmanavn') do |query|
    cli_params[:query] = query
  end

  opt.on('-d', '--domain DOMAIN', 'Domenenavn (kun .no)') do |domain|
    cli_params[:domain] = domain
  end

  opt.on('-v', '--version', 'Versjon') { puts "Brreg query version 0.1"; exit }
end
opts.parse!

module Brreg
  BrregURI = 'http://hotell.difi.no/api/json/brreg/enhetsregisteret'
  def self.find_by_orgnr(orgnr)
    res = get_json( { :orgnr => orgnr } )
    if res.is_a?(Net::HTTPSuccess)
      jsonres = JSON.parse(res.body)
      if jsonres['posts'].to_i > 0
        puts "Viser oppføring for orgnr #{orgnr}"
        puts '...............'
        puts jsonres['entries'].first['navn']
        puts jsonres['entries'].first['forretningsadr']
        puts jsonres['entries'].first['forradrpostnr'] + ' ' + jsonres['entries'].first['forradrpoststed']
        puts jsonres['entries'].first['postadresse']
        puts jsonres['entries'].first['ppostnr'] + ' ' + jsonres['entries'].first['ppoststed']
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


if cli_params.length > 0
  if cli_params[:orgnr]
    Brreg.find_by_orgnr(cli_params[:orgnr])
  elsif cli_params[:query]
    Brreg.find( cli_params[:query])
  elsif cli_params[:domain]
    Brreg.find_by_domain( cli_params[:domain])
  end
end