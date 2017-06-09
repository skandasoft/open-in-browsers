{View} = require 'atom-space-pen-views'
{CompositeDisposable}  = require 'atom'

class OpenInBrowsersView extends View
  constructor: ->
    @subscriptions = new CompositeDisposable
    super

  initialize: ->
    @browsers = require('./config.coffee').browser[process.platform]
    browserList = atom.config.get('open-in-browsers.browsers')
    for browser in browserList
      title = @[browser]?.attr?('title')
      @subscriptions.add atom.tooltips.add(@[browser],{title:title}) if title

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
    @pp = !!~pkgs.indexOf('pp')
    @bp = !!~pkgs.indexOf('browser-plus')
    @span class: 'open-in-browsers', =>
      for browser in browsers
        if atom.config.get("open-in-browsers.#{browser}")
          continue if browser is 'BrowserPlus' and not @bp
          continue if browser is 'BrowserPlus' and @pp and browsers.length > 1
          if browser is 'BrowserPlus'
            browserClass = "mega-octicon octicon-browser"
          else
            browserClass = "fa #{browser}"
          if @curBrowser is browser
            browserClass  =+ " selected "

          if typeof atom.config.get("open-in-browsers.#{browser}") is "object"
            if atom.config.get("open-in-browsers.#{browser}.path").trim() is ''
              browserClass += " hide "
            else
              color = atom.config.get("open-in-browsers.#{browser}.color")
              style = "color: rgb(#{color.red}, #{color.green}, #{color.blue});"
              title = atom.config.get("open-in-browsers.#{browser}.tooltip")
              @span style:"#{style}", title:"#{title}", class:browserClass,'data-browser':"#{browser}", mousedown:'openBrowser'
          else
            title = browser
            @span title:"#{browser}", class:browserClass,'data-browser':"#{browser}", mousedown:'openBrowser',outlet:"#{browser}"

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
    if target
       fpath = target.closest?('.entry')?.getPath?()
    unless fpath
      unless @fileName
        editor = atom.workspace.getActiveTextEditor()
        return unless editor
        fpath = editor.getPath()
      else
        fpath = @fileName
    OpenInBrowsersView.getFilePath(fpath)

  open: (cmd = @curBrowserCmd,evt,target)->
    exec = require('child_process').exec
    if @currBrowser is 'BrowserPlus'
      fpath = @getFilePath(target)
      atom.workspace.open(fpath)
      return false
    unless cmd
      @openBrowser()
      return false
    fpath = @getFilePath(target)
    cmd = "#{cmd}\"#{fpath}\""
    #cmd = cmd.replace "/\\/g", '/'
    exec  cmd if fpath
    @selectList?.cancel()

    return false

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    # @element.remove()
    @subscriptions.dispose()
  getElement: ->
    # @element

  @getFilePath: (fpath)->
    fpath = fpath.replace(/\\/g,'/')
    if atom.config.get('open-in-browsers.LocalHost')
      url = atom.config.get('open-in-browsers.LocalHostURL')
      pub = atom.config.get('open-in-browsers.PublicFolder')
    reqr = atom.config.get('open-in-browsers.project')
    project = require (reqr) if reqr

    foldr = atom.project.getPaths()[0]
    foldr = foldr.replace(/\\/g,'/')

    if project and folder = project[foldr]
      url = folder['url']
      pub = folder['public']


    if pub and fpath.includes pub
      foldr = foldr + "/"+pub
    if url
      url = url.replace(/\\/g,'/')
      fpath = fpath.replace foldr,url
    else
      fpath = "file:///#{fpath}"

module.exports = { OpenInBrowsersView}
