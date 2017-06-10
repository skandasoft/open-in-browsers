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

  @content: (browsers = atom.config.get('open-in-browsers.browsers'))->
    browserClass = ''
    pkgs = atom.packages.getAvailablePackageNames()
    @pp = !!~pkgs.indexOf('pp')
    @bp = !!~pkgs.indexOf('browser-plus')
    @span class: 'open-in-browsers', =>
      for browser in browsers
        if atom.config.get("open-in-browsers.#{browser}")
          continue if browser is 'BrowserPlus' and not @bp
          continue if browser is 'BrowserPlus' and @pp and browsers.length > 1
          if browser is 'BrowserPlus'
            browserClass = "browser-plus-icon"
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
    # order of the acceptance
    # 1. setting for localhost
    # 2. project
    # 3. filepath - what ever is passed
    projectPath = atom.project.getPaths()[0]?.replace(/\\/g,'/')
    fpath = fpath.replace(/\\/g,'/')

    loadJson = require('load-json-file')
    try
      projFile = atom.config.get("open-in-browsers.project") or "proj.json"
      proj = loadJson.sync("#{projectPath}/#{projFile}")
      if(proj)
        url = proj.localhost.url
        folder = (proj.localhost.folder)?.replace(/\\/g,'/')
        if folder and fpath.startsWith(folder) and fpath.indexOf(folder) >= 0
          fpath = fpath.replace(folder,url)
        else
          fpath = "#{url}/#{fpath}" if url
      else
        fpath = "file:///#{fpath}"
    catch e
      fpath = "file:///#{fpath}"
module.exports = { OpenInBrowsersView}
