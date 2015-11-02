{$,View} = require 'atom-space-pen-views'
exec = require('child_process').exec
module.exports =
class OpenInBrowsersView extends View
  initialize: (@model)->
    @browser = require('./config.coffee').browser[process.platform]
  @content: ->
    @span class: 'open-in-browsers', click:'openBrowser', =>
      @span class:"icon-chrome",click:'openChrome'
      @span class:"icon-ie",click:'openIE'
      @span class:"icon-firefox",click:'openFirefox'
      @span class:"icon-opera",click:'openOpera'
      @span class:"mega-octicon octicon-browser",click:'openBrowserPlus'

  openChrome: (evt)->
    @open(@browser?.CHROME?.cmd,evt)

  openIE: (evt)->
    @open(@browser?.IE?.cmd,evt)

  openFirefox: (evt)->
    @open(@browser?.FF?.cmd,evt)

  openOpera: (evt)->
    @open(@browser?.OPERA?.cmd,evt)

  openBrowser: (evt)->
    @open(@browser?.CHROME?.cmd,evt)

  openSafari: (evt)->
    @open(@browser?.SAFARI?.cmd,evt)

  openBrowserPlus: (evt)->
    unless atom.packages.getActivePackage('browser-plus')
      atom.notification.addSuccess('APM Install Browser-Plus to display in browser-plus')
      return
    view = atom.views.getView(atom.workspace.getActivePaneItem())
    atom.commands.dispatch(view,'browser-plus:openCurrent') if view
    return false

  open: (cmd,evt)->
    unless cmd
      alert 'Please maintain browser commands for your OS in config'
      return false
    editor = atom.workspace.getActiveTextEditor()
    fpath = editor.getPath()
    ls = exec "#{cmd} #{fpath}"
    li = $(evt.target).closest('li')
    if li.length > 0 and li.data('selectList')?
      # li.data('selectList').cancel()
      li.data('selectList').parent().remove()
    return false

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    # @element.remove()

  getElement: ->
    # @element
