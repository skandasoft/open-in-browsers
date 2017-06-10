# open-in-browsers package

Simple Package to Open Current File in Different Browsers - IE,Chrome,Firefox,Opera,BrowserPlus -- With Support for localhost(enable it using settings)

Opening Browsers are available in the status bar/context menu

![open-in-browsers](https://raw.github.com/skandasoft/open-in-browsers/master/open-in-browsers.PNG)

Browser List in context menu(Can be limit the list of browsers by settings)    

![open-in-browsers](https://raw.github.com/skandasoft/open-in-browsers/master/Context-Menu.PNG)  



~~Update: Ability to add New Browsers~~  
~~command open-in-browsers:addBrowser~~


Update: 05/25/2017  
~~open-in-browsers:addBrowser - removed the command. as it makes the package complicated.~~

~~Adding new browsers can be done by PR(Pull Request).
Check the lib/config.coffee and send the cmd needed for opening the browser. I can also add if you send me the details of browsers/cmd~~  

__Microsoft-Edge__ doesn't yet allow opening file system files..Once it allows this plugin will start to work automatically.  

### How to Add Your Browser
ChromePortable/FirefoxPortable/SafariPortable to define your own browser in setting. fill the path for the browser / tooltip/color to differentiate the icons from chrome/Firefox/safari

fix to issue #34  
The path for browser has to be maintained with quotes if there are spaces in the path  
for eg. C:\\"Program Files\\Mozilla Firefox"\\firefox.exe


__How to View from local host?__  
Maintain "proj.json" file in the root directory of the project root folder. The file name can be configured from settings. But has to be in the root folder.  
Here is sample structure of the file
```
{
	"localhost": {
		"url": "http://localhost:8000",
		"folder": "C:/Users/admin/myproj/public"
	}
}
```
There are 2 parameters:
1. url: This is base url against which the file path will be shown. Just maintaining url would make the file path be added with the url.
2. folder: folder directory will be compared with the path of the file being displayed and will be replaced for eg. in the above case view a file under the root directory
```
/public/view/hello.html  
would be shown as
http://localhost:8000/view/hello.html
```   

This can be maintained differently for each project under it root directory.
