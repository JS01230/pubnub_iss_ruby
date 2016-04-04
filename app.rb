# Native Dependencies
require 'net/http'
require 'json'

# Our only non-native dependency is PubNub
require 'pubnub'

$pubnub = Pubnub.new(
  subscribe_key: 'subscribe-key',
  publish_key: 'pub-key',
  connect_callback: lambda {|msg| pubnub.publish(channel: 'your-channel', message: "Connected!", http_sync: true)}
)

puts "Welcome to ISS Tracker! By Joel Shooster - 2016\nTracking the ISS for you in real time.\n------------------------------\n"


# Get user address and geocode-convert into coordinates. OpenCage API is helpful here.
def find_user
  puts "Enter your address (This will not be published to PubNub): "
  user_address = gets.chomp
  url = "http://api.opencagedata.com/geocode/v1/json?q=" + "#{user_address}" + "&key=your-key"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  response = JSON.parse(response)
  if response['total_results'] === 0
    puts "That's not a legitimate address. Try again."
    find_user
  else
    $user_latitude = response['results'][1]['geometry']['lat']
    $user_longitude = response['results'][1]['geometry']['lng']
    puts "You are located at latitude: #{$user_latitude}, longitude: #{$user_longitude}"
  end
end

# Let's find that ISS
def find_ISS
  url = 'http://api.open-notify.org/iss-now.json'
  uri = URI(url)
  response = Net::HTTP.get(uri)
  response = JSON.parse(response)
  if response["message"] = "success"
    $iss_latitude = response['iss_position']['latitude']
    $iss_longitude = response['iss_position']['longitude']
    output = "The ISS is currently at latitude: #{$iss_latitude.to_s}, longitude: #{$iss_longitude.to_s}\n"
    puts output
  else
    puts "Couldn't locate the ISS."
  end
  $pubnub.publish(
    channel: "your-channel",
    message: "#{output}"
    )
end

# Here we use the Haversine formula to determine distance between the user and ISS
# Haversine is the best formula because it accounts for Earth's radius/shape
def haversine(lat1, lon1, lat2, lon2)
  dtor = Math::PI/180
  # Distance represented in miles. To change to Km, change r to 6378.14
  r = 3961

  rlat1 = lat1 * dtor
  rlon1 = lon1 * dtor
  rlat2 = lat2 * dtor
  rlon2 = lon2 * dtor

  dlon = rlon1 - rlon2
  dlat = rlat1 - rlat2

  a = power(Math::sin(dlat/2), 2) + Math::cos(rlat1) * Math::cos(rlat2) * power(Math::sin(dlon/2), 2)
  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
  $distance = r * c
  puts "\nYou are #{$distance.round(3)} miles away from the International Space Station.\n"
end

def power(num, pow)
  num ** pow
end

def track_distance?
  while true
    print "Would you like to continuously stream ISS location data until the ISS is within reach of your location? [y/n]: \n"
    case gets.strip
      when 'Y', 'y', 'yes'
        stream_difference
        break
      when /\A[nN]o?\Z/ #n or no
        print "Thanks for playing today!\n"
        break
    end
  end
end

# stream_difference will continuously publish the distance of the ISS every 5
# seconds until it is within 100 miles of you. You can change the distance threshold
# in the until function below.
def stream_difference
  # Distance is set to 100 miles but you can change it to something different.
  until $distance < 100
    sleep(5)
    find_ISS
    haversine($user_latitude, $user_longitude, $iss_latitude.round(4), $iss_longitude.round(4))
  end
  puts "The ISS is #{$distance.round(3)} miles from you! Put the computer down and go outside. Get that telescope handy!"
end

# Main
find_user
find_ISS
haversine($user_latitude, $user_longitude, $iss_latitude.round(4), $iss_longitude.round(4))
track_distance?
