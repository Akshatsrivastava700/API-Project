require 'csv'
require 'sinatra'
require 'sinatra/cross_origin'
$data = CSV.read( "hotel_bookings.csv", headers: true )
$default_month_arr = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
set :bind, '0.0.0.0'

configure do
  enable :cross_origin
end
before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

options "*" do
  response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end

def cancelled_per_year()
  year        = $data["arrival_date_year"]
  year_uniq   = Hash[year.uniq.collect { |item| [item, 0] } ]
  is_canceled = $data["is_canceled"]
  for itr in 0..is_canceled.length-1
    if is_canceled[itr] == "1"
      year_uniq[ "#{year[itr]}" ] = year_uniq[ "#{year[itr]}" ]+1
    end
  end

  # Finding the percentage of cancelled bookings
  year_uniq.each do |key, value|
    year_uniq["#{key}"] = ( ( year_uniq["#{key}"].to_f / is_canceled.length ) * 100 ).round(1)
  end
  puts(year_uniq)
end

get '/cancelled_per_month' do
  month       = $data["arrival_date_month"]
  month_uniq  = Hash[$default_month_arr.collect { |item| [item, 0] } ]
  is_canceled = $data["is_canceled"]
  for itr in 0..is_canceled.length-1
    if is_canceled[itr] == "1"
      month_uniq[ "#{month[itr]}" ] = month_uniq[ "#{month[itr]}" ]+1
    end
  end

  # Finding the percentage of cancelled bookings
  month_uniq.each do |key, value|
    month_uniq["#{key}"] = ( ( month_uniq["#{key}"].to_f / is_canceled.length ) * 100 ).round(1)
  end
  month_uniq.to_json
end


get '/stay_weekend_nights_per_month' do
  month        = $data["arrival_date_month"]
  month_uniq   = Hash[$default_month_arr.collect { |item| [item, 0] } ]
  weekend_stay = $data["stays_in_weekend_nights"]
  total_stays  = 0
  for itr in 0..weekend_stay.length-1
    if weekend_stay[itr].to_i > 0
      month_uniq[ "#{month[itr]}" ] = month_uniq[ "#{month[itr]}" ] + weekend_stay[itr].to_i
      total_stays += 1
    end
  end

  # Finding the percentage of weekend stays
  month_uniq.each do |key, value|
    month_uniq["#{key}"] = ( ( month_uniq["#{key}"].to_f / total_stays ) * 100 ).round(1)
  end

  month_uniq.to_json
end


get '/stay_weekend_nights_per_hotel' do
  hotel        = $data["hotel"]
  hotel_uniq   = Hash[hotel.uniq.sort.collect { |item| [item, 0] } ]
  weekend_stay = $data["stays_in_weekend_nights"]
  total_stays  = 0
  for itr in 0..weekend_stay.length-1
    if weekend_stay[itr].to_i > 0
      hotel_uniq[ "#{hotel[itr]}" ] = hotel_uniq[ "#{hotel[itr]}" ] + weekend_stay[itr].to_i
      total_stays += weekend_stay[itr].to_i
    end
  end
  puts(total_stays)
  # Finding the percentage of weekend stays
  hotel_uniq.each do |key, value|
    hotel_uniq["#{key}"] = ((hotel_uniq["#{key}"].to_f/total_stays)*100).round(1)
  end
  hotel_uniq.to_json
end


get '/distribution_channels_percentage' do
  distribution_channels      = $data["distribution_channel"]
  distribution_channels_uniq = Hash[distribution_channels.uniq.sort.collect { |item| [item, 0] } ]

  for itr in 0..distribution_channels.length-1
    distribution_channels_uniq[ "#{distribution_channels[itr]}" ] += 1
  end

  distribution_channels_uniq.each do |key, value|
    distribution_channels_uniq["#{key}"] = ( ( distribution_channels_uniq["#{key}"].to_f / distribution_channels.length ) * 100 ).round(1)
  end
  return(distribution_channels_uniq.to_json)
end


get '/repeated_guest_hotel' do
  hotel             = $data["hotel"]
  hotel_uniq        = Hash[hotel.uniq.sort.collect { |item| [item, 0] } ]
  repeated_guest    = $data["is_repeated_guest"]
  total_guest_hotel = Hash[hotel.uniq.sort.collect { |item| [item, 0] } ]
  for itr in 0..repeated_guest.length-1
    total_guest_hotel[ "#{hotel[itr]}" ] += 1
    if repeated_guest[itr].to_i > 0
      hotel_uniq[ "#{hotel[itr]}" ] += 1
    end
  end

  # Finding the percentage of weekend stays
  hotel_uniq.each do |key, value|
    hotel_uniq["#{key}"] = ((hotel_uniq["#{key}"].to_f/total_guest_hotel["#{hotel[itr]}"])*100).round(1)
  end
  hotel_uniq.to_json
end
