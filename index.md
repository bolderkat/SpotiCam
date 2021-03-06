## What is SpotiCam?
SpotiCam is an iOS app that analyzes the color in photos to get Spotify track recommendations based on that color.


### How does SpotiCam work?

First, you take a picture. SpotiCam takes that picture and calculates the average color in the center portion of the picture. Then, that color value gets fed through SpotiCam’s mathematical model to generate track attribute values for Spotify’s recommendation engine: danceability, energy, and mood.

SpotiCam then makes a request to Spotify for track recommendations that most closely match these values and your selected genres. Spotify’s track database is absolutely massive, and each track’s attribute values are algorithmically generated on their end. You may get some surprising results, especially when it comes to which genres Spotify has assigned to certain tracks. Just keep taking pictures and see what you get— you just might discover something interesting.


### Sounds cool. Where can I get it?

SpotiCam is currently undergoing the App Store review process. Check back here soon for a link to the App Store page!

## Housekeeping


### Get in touch!

SpotiCam is my first app on the App Store. Please do submit any feedback or comments to SpotiCam's [GitHub issues page](https://github.com/bolderkat/SpotiCam/issues). I'd love to hear what you think!


### SpotiCam Privacy Policy

Here's the quick version up front: SpotiCam does not collect your personal information or data. The app does not track you, nor does it serve you ads.

SpotiCam requests your Spotify login, as Spotify's API requires a valid authorization token to allow access to its track recommendation service.

SpotiCam only uses your login details to obtain an authorization token from Spotify. This token is saved locally on your device, and the app does not keep your login credentials stored anywhere. Additionally, SpotiCam only asks for the bare minimum account permissions necessary to get track recommendations from Spotify.

Photo analysis is performed locally, and your photos are never sent off your device. All network requests from this app are made only to Spotify's or Apple's servers for track recommendations or tip jar transactions respectively.
