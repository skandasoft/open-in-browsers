{CompositeDisposable} = require 'atom'
{OpenInBrowsersView} = require './open-in-browsers-view'

module.exports = OpenInBrowsers =
  openInBrowsersView: null
  subscriptions: null
  config:

    browsers:
      title: 'List of Browsers'
      type: 'array'
      default: [ 'IE', 'Edge', 'Chrome', 'ChromePortable', 'Firefox', 'FirefoxPortable', 'Opera', 'Safari', 'SafariPortable', 'BrowserPlus' ]

    defBrowser:
      title: 'Default Browser'
      type: 'string'
      default: 'Chrome'
      enum: [ 'IE', 'Edge', 'Chrome', 'ChromePortable', 'Firefox', 'FirefoxPortable', 'Opera', 'Safari', 'SafariPortable', 'BrowserPlus']

    fileTypes:
      title: 'HTML File Types'
      type: 'array'
      default: ['html','htm','xhtml']
    IE:
      title: 'IE'
      type: 'boolean'
      default: true

    Edge:
      title: 'Edge'
      type: 'boolean'
      default: false

    Chrome:
      title: 'Chrome'
      type: 'boolean'
      default: true

    Firefox:
      title: 'Firefox'
      type: 'boolean'
      default: true

    Opera:
      title: 'Opera'
      type: 'boolean'
      default: true

    Safari:
      title: 'Safari'
      type: 'boolean'
      default: true

    BrowserPlus:
      title: 'Browser Plus'
      type: 'boolean'
      default: true

    ChromePortable:
      title: 'Chrome Portable'
      type: 'object'
      properties:
        path:
          type: 'string'
          default: ''
          description: 'eg. C:\\Users\\Admin\\AppData\\Local\\Google\\"Chrome SxS"\\Application\\chrome.exe'
        tooltip:
          type: 'string'
          default : 'Chrome Canary'
        color:
          type: 'color'
          default: 'red'

    FirefoxPortable:
      title: 'Firefox Portable'
      type: 'object'
      properties:
        path:
          type: 'string'
          default: ''
        tooltip:
          type: 'string'
          default : 'Firefox Developer'
        color:
          type: 'color'
          default: 'blue'

    SafariPortable:
      title: 'Safari Portable'
      type: 'object'
      properties:
        path:
          type: 'string'
          default: ''
        tooltip:
          type: 'string'
          default : 'Safari Portable'
        color:
          type: 'color'
          default: 'green'

    project:
      title: 'Project/Local Host Combination Config File'
      type: 'string'
      description: 'contains the url and home folder'
      default: 'proj.json'

  getPosition: ->
    activePane = atom.workspace.paneForItem atom.workspace.getActiveTextEditor()
    return unless activePane
    paneAxis = activePane.getParent()
    return unless paneAxis
    paneIndex = paneAxis.getPanes().indexOf(activePane)
    orientation = paneAxis.orientation ? 'horizontal'
    if orientation is 'horizontal'
      if  paneIndex is 0 then 'right' else 'left'
    else
      if  paneIndex is 0 then 'down' else 'up'

  consumeAddPreview: (@addPreview)->
    requires =
      pkgName: 'open-in-browsers'
      fileTypes: do->
        types = atom.config.get('open-in-browsers.fileTypes')
        # types.concat ['htm','html'] #filetypes against which this compileTo Option will show
      browser:
        noPreview: true
        hyperLive: ->
          # if false
          #   atom.notifications.addSuccess('Live Not Availble')
          #   return false
          return true
        quickPreview: true
        viewClass: OpenInBrowsersView
        viewArgs: ['BrowserPlus']
        exe: (src,options,data,fileName,quickPreview,hyperLive,editor,view)->
          unless atom.packages.getActivePackage('browser-plus')
            atom.notifications.addSuccess('APM Install Browser-Plus to display in browser-plus')
            return
          unless  pp = atom.packages.getLoadedPackage('pp')
            atom.notifications.addSuccess('APM Install PP(Preview-Plus) to display in browser-plus')
            return
          split = module.exports.getPosition()
          if options.url
            atom.workspace.open options.url, {searchAllPanes:true,split:split}
            return false
          else
            fpath = OpenInBrowsersView.getFilePath(fileName)
            editor = atom.workspace.paneForURI(fpath)?.getItems()?.find (pane)-> pane.getURI() is fpath
            unless editor
              fpath = fpath.replace(/\\/g,"/")
              editor = atom.workspace.paneForURI(fpath)?.getItems()?.find (pane)-> pane.getURI() is fpath
            if quickPreview or hyperLive or fileName.indexOf "~pp~"
              # src = src.split('\n').join('<br/>')
              # src = """
              #   <pre style="word-wrap: break-word; white-space: pre-wrap;">
              #   #{src}
              #   </pre>
              #   """
              if editor
                editor.setText(src)
              else
                atom.workspace.open fpath, {src,split}
            else
              if target?.dataset?.path?
                fpath = target.dataset.path
              if editor
                editor.setText('')
                editor.refresh()
              else
                atom.workspace.open fpath,{split}
            return false

      # localhost:
      #
      browsers:
        noPreview: true
        hyperLive: false
        quickPreview: false
        viewClass: OpenInBrowsersView
        exe: (src,options,data,fileName,quickPreview,hyperLive,editor,view)->
          if options['url']
            @vw.htmlURL = options['url']
          else
            @vw.htmlURL = undefined
          @vw.fileName = fileName
          @vw.open()
    @ids = @addPreview requires

  activate: (state) ->
    # bring back to life new browsers added
    # if atom.config.get('open-in-browsers.requires')
      # req = require atom.config.get('open-in-browsers.requires')
      # for key,val of req.config
      #   properties = atom.config.getSchema('open-in-browsers').properties
      #   if properties[key]
      #     properties.enum.concat val
      #   else
      #     properties[key] = {}
      #     properties[key]['default'] = val
      #     properties[key]['type'] = 'string'
      #     properties[key]['title'] = key

    @openInBrowsersView = new OpenInBrowsersView()
      # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    submenu = []
    # Register command that toggles this view
    # @subscriptions.add atom.commands.add 'atom-workspace', 'open-in-browsers:addBrowser': (target)=>
      # open input view for browser name/command/default
    @subscriptions.add atom.commands.add 'atom-workspace', 'open-in-browsers:toggle': (target)=>
      @openInBrowsersView.openBrowser(null,target)
    browsers = atom.config.get('open-in-browsers.browsers')
    pkgs = atom.packages.getAvailablePackageNames()
    for browser in browsers
      if atom.config.get("open-in-browsers.#{browser}")
          unless (typeof atom.config.get("open-in-browsers.#{browser}") is "object" and atom.config.get("open-in-browsers.#{browser}.path").trim() is '')
            continue if browser is 'BrowserPlus' and pkgs.indexOf('browser-plus') is -1
            atom.commands.add 'atom-workspace', "open-in-browsers:#{browser}", do(browser) =>
              return ({target}) =>
                @openInBrowsersView.openBrowser(null,target,browser)
            title = atom.config.get("open-in-browsers.#{browser}").tooltip or browser
            submenu.push {label: "Open in #{title}", command:  "open-in-browsers:#{browser}"}

    for fileType in atom.config.get('open-in-browsers.fileTypes')
      sel = {}
      sel['.tree-view .file .name[data-name$=".'+fileType+'"]'] =
                 [
                   {
                     label: 'Open in Browsers',
                     submenu: submenu
                   }
                 ]

      atom.contextMenu.add sel


    atom.workspace.onDidChangeActivePaneItem (activePane)=>
      if @pp is undefined
        pkgs = atom.packages.getAvailablePackageNames()
        @pp = !!~pkgs.indexOf('pp')
      unless @pp
        @updateStatusBar(activePane)
        activePane?.onDidChangeTitle?  => @updateStatusBar()

  consumeStatusBar: (@statusBar)->
      if @pp is undefined
        pkgs = atom.packages.getAvailablePackageNames()
        @pp = !!~pkgs.indexOf('pp')
      if @pp
        return "</span>"
      else
        @openInBrowsersView or= new OpenInBrowsersView()
        @updateStatusBar()

  updateStatusBar: (editor = atom.workspace.getActivePaneItem())->
    path = require 'path'
    filePath = editor?.buffer?.file?.path
    if filePath and path.extname(filePath).substr(1) in atom.config.get('open-in-browsers.fileTypes')
      @browserBar = @statusBar.addLeftTile item: @openInBrowsersView, priority:100
    else
      @browserBar?.destroy()

  deactivate: ->
    @openInBrowsersView.destroy()

  serialize: ->
    openInBrowsersViewState: @openInBrowsersView.serialize()

  toggle: ->
