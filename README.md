# open-in-browsers package

Simple Package to Open Current File in Different Browsers - IE,Chrome,Firefox,Opera,BrowserPlus -- With Support for localhost(enable it using settings)

Opening Browsers are available in the status bar/context menu

![open-in-browsers](https://raw.github.com/skandasoft/open-in-browsers/master/open-in-browsers.PNG)

Browser List in context menu
![open-in-browsers](https://raw.github.com/skandasoft/open-in-browsers/master/Context-Menu.PNG)

Update: Ability to add New Browsers
  command open-in-browsers:addBrowser


Update: 05/25/2017  
open-in-browsers:addBrowser - removed the command. as it makes the package complicated.

Adding new browsers can be done by PR(Pull Request).
Check the lib/config.coffee and send the cmd needed for opening the browser. I can also add if you send me the details of browsers/cmd

microsoft-edge doesn't yet allow opening file system files..Once then allow it will start to work automatically.

Possible to use Google Chrome portable if file  path for the exe is maintain with quotes around the path #34 in the config
for eg. C:\\"Program Files\\Mozilla Firefox"\\firefox.exe

__ABILITY TO ADD CUSTOM BROWSERS__

use the filler browser - ChromePortable/FirefoxPortable/SafariPortable to define your own browser in setting. fill the tooltip/color to differentiate the icons from chrome/Firefox/safari
