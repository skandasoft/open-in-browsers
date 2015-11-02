{$,View} = require 'atom-space-pen-views'
exec = require('child_process').exec
module.exports =
class OpenInBrowsersView extends View
  initialize: (@model)->
    @browser = require('./config.coffee').browser[process.platform]
  @content: ->
    @span class: 'open-in-browsers', click:'openBrowser', =>
      if atom.config.get('open-in-browsers.Chrome')
        @span class:"icon-chrome",click:'openChrome'
      if atom.config.get('open-in-browsers.IE')
        @span class:"icon-ie",click:'openIE'
      if atom.config.get('open-in-browsers.FireFox')
        @span class:"icon-firefox",click:'openFirefox'
      if atom.config.get('open-in-browsers.Opera')
        @span class:"icon-opera",click:'openOpera'
      if atom.config.get('open-in-browsers.BrowserPlus')
        @span class:"mega-octicon octicon-browser",click:'openBrowserPlus'

  openChrome: (evt,target)->
    @open(@browser?.CHROME?.cmd,evt,target)

  openIE: (evt,target)->
    @open(@browser?.IE?.cmd,evt,target)

  openFirefox: (evt,target)->
    @open(@browser?.FF?.cmd,evt,target)

  openOpera: (evt,target)->
    @open(@browser?.OPERA?.cmd,evt,target)

  openBrowser: (evt,target)->
    @open(@browser?.CHROME?.cmd,evt,target)

  openSafari: (evt,target)->
    @open(@browser?.SAFARI?.cmd,evt,target)

  openBrowserPlus: (evt,target)->
    unless atom.packages.getActivePackage('browser-plus')
      atom.notification.addSuccess('APM Install Browser-Plus to display in browser-plus')
      return
    view = atom.views.getView(atom.workspace.getActivePaneItem())
    atom.commands.dispatch(view,'browser-plus:openCurrent') if view
    return false

  open: (cmd,evt,target)->
    unless cmd
      alert 'Please maintain browser commands for your OS in config'
      return false
    if target?.dataset?.path?
      fpath = target.dataset.path
    else
      editor = atom.workspace.getActiveTextEditor()
      fpath = editor.getPath()
    exec "#{cmd} #{fpath}" if fpath
    return false

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    # @element.remove()

  getElement: ->
    # @element
