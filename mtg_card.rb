#!/usr/bin/env ruby
require 'sinatra'
require 'sinatra/json'
require 'net/http'
require 'json'

def card_info(text)
  uri = URI.parse('https://api.deckbrew.com/mtg/cards')
  uri.query = URI.encode_www_form(name: text)
  data = JSON.parse(Net::HTTP.get(uri))
  card = data.first

  return {
    text: "Could not match `#{text}` to any cards.", # send a text response (replies to channel if not blank)
    attachments: [], # add attatchments: https://api.slack.com/docs/attachments
    username: 'MTG Bot', # overwrite configured username (ex: MyCoolBot)
    icon_url: 'http://seeklogo.com/images/M/magic-the-gathering-logo-E672A43B2E-seeklogo.com.gif', # overwrite configured icon (ex: https://mydomain.com/some/image.png
    icon_emoji: '', # overwrite configured icon (ex: :smile:)
  } if card.nil?

  cost = nil
  cost = {
    title: 'Cost',
    value: card['cost'],
    short: true
  } unless card['cost'].empty?

  type_text = ''
  card['supertypes'].each do |t|
    type_text << "#{t.capitalize} "
  end unless card['supertypes'].nil?

  card['types'].each do |t|
    type_text << "#{t.capitalize} "
  end unless card['types'].nil?

  type_text << '- ' unless card['subtypes'].nil?

  card['subtypes'].each do |t|
    type_text << "#{t.capitalize} "
  end unless card['subtypes'].nil?

  type = {
    title: 'Type',
    value: type_text.strip,
    short: true
  }

  card_text = nil
  card_text = {
    title: 'Card Text',
    value: card['text'],
    short: false
  } unless card['text'].empty?

  p_t = nil
  p_t = {
    title: 'P/T',
    value: "#{card['power']}/#{card['toughness']}",
    short: true
  } unless card['power'].nil? || card['toughness'].nil?

  loyalty = nil
  loyalty = {
    title: 'Loyalty',
    value: card['loyalty'],
    short: true
  } unless card['loyalty'].nil?

  rarity = {
    title: 'Rarity',
    value: card['editions'].last['rarity'].capitalize,
    short: true
  }

  fields = []
  fields << cost
  fields << type
  fields << card_text
  fields << p_t unless p_t.nil?
  fields << loyalty unless loyalty.nil?
  fields << rarity

  {
    text: '', # send a text response (replies to channel if not blank)
    attachments: [{
      title: card['name'],
      fields: fields,
      image_url: card['editions'].last['image_url']
    }], # add attatchments: https://api.slack.com/docs/attachments
    username: 'MTG Bot', # overwrite configured username (ex: MyCoolBot)
    icon_url: 'http://seeklogo.com/images/M/magic-the-gathering-logo-E672A43B2E-seeklogo.com.gif', # overwrite configured icon (ex: https://mydomain.com/some/image.png
    icon_emoji: '', # overwrite configured icon (ex: :smile:)
    response_type: 'in_channel'
  }
end

def combo_info(cards)
  attachments = []
  cards.each do |card_name|
    card_name.strip!
    uri = URI.parse('https://api.deckbrew.com/mtg/cards')
    uri.query = URI.encode_www_form(name: card_name)
    data = JSON.parse(Net::HTTP.get(uri))
    card = data.first

    return {
      text: "Could not match `#{card_name}` to any cards.", # send a text response (replies to channel if not blank)
      attachments: [], # add attatchments: https://api.slack.com/docs/attachments
      username: 'MTG Bot', # overwrite configured username (ex: MyCoolBot)
      icon_url: 'http://seeklogo.com/images/M/magic-the-gathering-logo-E672A43B2E-seeklogo.com.gif', # overwrite configured icon (ex: https://mydomain.com/some/image.png
      icon_emoji: '', # overwrite configured icon (ex: :smile:)
    } if card.nil?

    attachments << {
      title: card['name'],
      image_url: card['editions'].last['image_url']
    }
  end

  {
    text: 'Combo',
    attachments: attachments,
    username: 'MTG Bot', # overwrite configured username (ex: MyCoolBot)
    icon_url: 'http://seeklogo.com/images/M/magic-the-gathering-logo-E672A43B2E-seeklogo.com.gif', # overwrite configured icon (ex: https://mydomain.com/some/image.png
    icon_emoji: '', # overwrite configured icon (ex: :smile:)
    response_type: 'in_channel'
  }
end

post '/' do
  cards = params['text'].split '+'
  if cards.length == 1
    json card_info(cards.first)
  else
    json combo_info(cards)
  end
end
