# Pubnub ISS - Ruby Edition

Let's be honest. The International Space Station is the coolest thing humans have ever built. We have a giant state-of-the-art laboratory that is flying around the Earth at five-miles-per-second and was constructed by 15 nations that have historically been at war with each other.

However, tracking that thing can be a pain. Not anymore. With this app, you can see the real-time location of the ISS as it speeds around the planet.

First, you the user need a few things:

  - Pubnub Subscribe Key
  - Pubnub Publish Key
  - Pubnub Channel
  - OpenCage API Key

After you fork the repo. Go to your terminal and run 'ruby app.rb'. From there just watch magic happen before your very eyes. With the exception of the Pubnub dependency, the app uses no non-native gems. This keeps the app stable and enforces responsible programming.

When the app runs, the user is asked to input their address. From there, the app sends the address to an OpenCage API where it is geocoded into coordinates. After this, the app sends a GET request to Open Notify's ISS API. It will parse the returned JSON for the coordinates. This is published to the Pubnub channel. After this, the user has the option of running a continuous data stream until the ISS is within 100 miles of the user. If the user chooses yes, the program will run the stream and publish the ISS location to Pubnub every 5 seconds.

I recommend 5 seconds in order to not overwhelm the channel. However, if you are feeling lucky, you can toggle the Until function to return faster results.

Enjoy!
