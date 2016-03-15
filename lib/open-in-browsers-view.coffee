{$,View} = require 'atom-space-pen-views'
exec = require('child_process').exec
_ = require 'lodash'

class OpenInBrowsersView extends View
  initialize: ->
    @browsers = require('./config.coffee').browser[process.platform]
    pkgs = atom.packages.getAvailablePackageNames()
    @pp = _.contains(pkgs,'pp')
    atom.config.onDidChange 'open-in-browsers.LocalHost',(obj)=>
      if obj.newValue
        @children('sup').removeClass('hide')
      else
        @children('sup').addClass('hide')

  @content: (browsers = atom.config.get('open-in-browsers.browsers'))->
    localhost = "localhost"
    browserClass = ''
    unless atom.config.get('open-in-browsers.LocalHost')
      localhost += " hide "
    pkgs = atom.packages.getAvailablePackageNames()
    @pp = _.contains(pkgs,'pp')

    @span class: 'open-in-browsers', =>
      for browser in browsers
        if atom.config.get("open-in-browsers.#{browser}")
          continue if browser is 'BrowserPlus' and @pp and browsers.length > 1
          if browser is 'BrowserPlus'
            browserClass = "mega-octicon octicon-browser"
          else
            browserClass = "fa #{browser}"
          if @curBrowser is browser
            browserClass  =+ " selected "

          @span class:browserClass,'data-browser':"#{browser}", mousedown:'openBrowser'
      @sup class:localhost, "L"

  openBrowser: (evt,target,browser)->
    if browser
      @currBrowser = browser
    else
      @currBrowser = target.data('browser') if target?.data?('browser')

    unless @currBrowser
      @currBrowser = atom.config.get('open-in-browsers.defBrowser') or 'Chrome'

    @curBrowserCmd = @browsers["#{@currBrowser}"]?.cmd

    @children?().removeClass("selected")
    @children?(".#{@currBrowser}").addClass('selected')
    unless @pp
      @open(@curBrowserCmd,evt,target)
      return
    unless evt
      @open(@curBrowserCmd,evt,target)
      return

  getFilePath: (target)->
    return @htmlURL if @htmlURL
    if target?.dataset?.path
       fpath = target.dataset.path
    else
      editor = atom.workspace.getActiveTextEditor()
      return unless editor
      fpath = editor.getPath()
    if atom.config.get('open-in-browsers.LocalHost')
      url = atom.config.get('open-in-browsers.LocalHostURL')
      pub = atom.config.get('open-in-browsers.PublicFolder')
      foldr = atom.project.getPaths()[0]
      if pub and fpath.has pub
        foldr = foldr + pub
      fpath = fpath.replace foldr,url
    else
      fpath = "file:///#{fpath}"

  open: (cmd = @curBrowserCmd,evt,target)->
    if @currBrowser is 'BrowserPlus'
      fpath = @getFilePath()
      bp = atom.packages.getLoadedPackage('browser-plus')
      bp.mainModule.open(fpath)
      return false
    unless cmd
      @openBrowser()
      return false
    fpath = @getFilePath(target)
    cmd = "#{cmd} \"#{fpath}\""
    cmd = cmd.replace '\\', '/'
    exec  cmd if fpath
    @selectList?.cancel()

    return false

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    # @element.remove()

  getElement: ->
    # @element

module.exports = { OpenInBrowsersView}
