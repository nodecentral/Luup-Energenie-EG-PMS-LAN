# Luup-Energenie-EG-PMS2-LAN

# Scope

This is a Luup plugin for HTTP control of the Energenie EG PMS2 LAN IP switches

Luup (Lua-UPnP) is a software engine which incorporates Lua, a popular scripting language, and UPnP, the industry standard way to control devices. Luup is the basis of a number of home automation controllers e.g. Micasaverde Vera, Vera Home Control, OpenLuup.

# Compatibility

This plug-in has been tested with the following Energenie switches

* EG PMS2 LAN

# Features

It supports the following functions:

* Creation of child devices in Vera for each switch channel
* Set each channel on or off from Vera (discrete power)
* Poll the device regularly to determine the actual status

# Usage

Create the parent instance and give it the IP address of your Energenie device. The child devices will then be created automatically.

# Limitations

While it has been tested, it has not been tested very much and may not support other related devices or those running different firmware.

# Buy me a coffee

If you choose to use/customise or just like this plug-in, feel free to say thanks with a coffee or two.. 
(God knows I drank enough working on this :-)) 

<a href="https://www.buymeacoffee.com/gbraad" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

# Screenshots

Once installed, and the IP address added, you should see the 4 controllable socket created as child devices.

![DBEC60E5-F18F-484D-A951-3E483E4DF0BC](https://user-images.githubusercontent.com/4349292/148046320-da355f16-bb08-4631-9c89-de4027ecaf19.jpeg)


# License

Copyright © 2021 Chris Parker (nodecentral)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/
