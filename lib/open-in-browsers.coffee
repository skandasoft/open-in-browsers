{OpenInBrowsersView} = require './open-in-browsers-view'
module.exports = OpenInBrowsers =
  openInBrowsersView: null
  subscriptions: null
  config:
    browsers:
      title: 'List of Browsers'
      type: 'array'
      default: [ 'IE', 'Edge','Chrome', 'Firefox', 'Opera', 'Safari','BrowserPlus' ]

    defBrowser:
      title: 'Default Browser'
      type: 'string'
      default: ['Chrome']

    fileTypes:
      title: 'HTML File Types'
      type: 'array'
      default: ['html','htm','xhtml']
    IE:
      title: 'IE'
      type: 'boolean'
      default: true
    Edge:
      title: 'IE'
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
    LocalHost:
      title: 'Switch LocalHost'
      type: 'boolean'
      default: true
    LocalHostURL:
      title: 'LocalHost URL'
      type: 'string'
      default: 'http://localhost:3000'

  consumeAddPreview: (@addPreview)->
    requires =
      pkgName: 'open-in-browsers'
      fileTypes: do->
        types = atom.config.get('open-in-browsers.fileTypes')
        # types.concat ['htm','html'] #filetypes against which this compileTo Option will show
      browser:
        noPreview: true
        hyperLive: ->
          if atom.config.get('open-in-browsers.LocalHost')
            atom.notifications.addSuccess('Live Not Availble for LocalHost')
            return false
          return true
        quickPreview: true
        viewClass: OpenInBrowsersView
        viewArgs: ['BrowserPlus']
        exe: (src,options,data,fileName,quickPreview,hyperLive,editor,view)->
          unless atom.packages.getActivePackage('browser-plus')
            atom.notifications.addSuccess('APM Install Browser-Plus to display in browser-plus')
            return
          pp = atom.packages.getLoadedPackage('pp')
          if options.url
            pp.mainModule.bp.open(options.url)
            return false
          else
            if quickPreview or hyperLive
              lines = src.split('\n')
              src = lines.join('<br/>')
              html = """
                <pre style="word-wrap: break-word; white-space: pre-wrap;">
                #{src}
                </pre>
                """
              pp.mainModule.bp.open(null,html)
              return false
            else
              if target?.dataset?.path?
                fpath = target.dataset.path
              else
                if atom.config.get('open-in-browsers.LocalHost')
                  url = atom.config.get('open-in-browsers.LocalHostURL')
                  pub = atom.config.get('open-in-browsers.PublicFolder')
                  foldr = atom.project.getPaths()[0]
                  if pub and fileName.has pub
                    foldr = foldr + pub
                  fpath = fileName.replace foldr,url
                else
                  fpath = "file:///#{fileName}"

              pp.mainModule.bp.open(fpath)
              return false

      # localhost:
      #
      browsers:
        noPreview: true
        hyperLive: true
        quickPreview: false
        viewClass: OpenInBrowsersView
        exe: (src,options,data,fileName,quickPreview,hyperLive,editor,view)->
          if options['url']
            @vw.htmlURL = options['url']
          else
            @vw.htmlURL = undefined
          @vw.open()
    @ids = @addPreview requires

  activate: (state) ->
    {CompositeDisposable} = require 'atom'
    @openInBrowsersView = new OpenInBrowsersView()
      # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    submenu = []
    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'open-in-browsers:toggle': (target)=>
      @openInBrowsersView.openBrowser(null,target)
    browsers = atom.config.get('open-in-browsers.browsers')
    for browser in browsers
      if atom.config.get("open-in-browsers.#{browser}")
        atom.commands.add 'atom-workspace', "open-in-browsers:#{browser}", do(browser) =>
          return ({target}) =>
            @openInBrowsersView.openBrowser(null,target,browser)
        submenu.push {label: "Open in #{browser}", command:  "open-in-browsers:#{browser}"}

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
      _ = require 'lodash'
      pkgs = atom.packages.getAvailablePackageNames()
      unless _.contains(pkgs,'pp')
        @updateStatusBar(activePane)
        activePane?.onDidChangeTitle?  => @updateStatusBar()

  consumeStatusBar: (@statusBar)->
      _ = require 'lodash'
      pkgs = atom.packages.getAvailablePackageNames()
      unless _.contains(pkgs,'pp')
        @openInBrowsersView or= new OpenInBrowsersView()
        @updateStatusBar()
      else
        return "</span>"

  updateStatusBar: (editor = atom.workspace.getActivePaneItem())->
    path = require 'path'
    filePath = editor?.buffer?.file?.path
    if filePath and path.extname(filePath).substr(1) in atom.config.get('open-in-browsers').fileTypes
      @browserBar = @statusBar.addLeftTile item: @openInBrowsersView, priority:100
    else
      @browserBar?.destroy()

  deactivate: ->
    @openInBrowsersView.destroy()

  serialize: ->
    openInBrowsersViewState: @openInBrowsersView.serialize()

  toggle: ->
