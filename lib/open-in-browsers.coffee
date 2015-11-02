OpenInBrowsersView = require './open-in-browsers-view'
{CompositeDisposable} = require 'atom'
path = require 'path'
module.exports = OpenInBrowsers =
  openInBrowsersView: null
  subscriptions: null
  config:
    fileTypes:
      title: 'HTML File Types'
      type: 'array'
      default: ['.html','.htm']
    IE:
      title: 'IE'
      type: 'boolean'
      default: true
    Chrome:
      title: 'Chrome'
      type: 'boolean'
      default: true
    FireFox:
      title: 'FireFox'
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

  activate: (state) ->
    @openInBrowsersView or= new OpenInBrowsersView(state.openInBrowsersViewState)
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'open-in-browsers:toggle': => @toggle()
    atom.commands.add 'atom-workspace', 'open-in-browsers:IE', ({target}) =>
      @openInBrowsersView.openIE(null,target)
    atom.commands.add 'atom-workspace', 'open-in-browsers:Chrome', ({target}) =>
      @openInBrowsersView.openChrome(null,target)
    atom.commands.add 'atom-workspace', 'open-in-browsers:FF', ({target}) =>
      @openInBrowsersView.openFirefox(null,target)
    atom.commands.add 'atom-workspace', 'open-in-browsers:Opera', ({target}) =>
      @openInBrowsersView.openOpera(null,target)
    atom.commands.add 'atom-workspace', 'open-in-browsers:Safari', ({target}) =>
      @openInBrowsersView.openSafari(null,target)
    atom.commands.add 'atom-workspace', 'open-in-browsers:BP', ({target}) =>
      @openInBrowsersView.openBrowserPlus(null,target)


    atom.workspace.onDidChangeActivePaneItem (activePane)=>
      @updateStatusBar(activePane)
      activePane?.onDidChangeTitle?  => @updateStatusBar()
  consumeStatusBar: (@statusBar)->
    @openInBrowsersView or= new OpenInBrowsersView()
    @updateStatusBar()

  updateStatusBar: (editor = atom.workspace.getActivePaneItem())->
    filePath = editor?.buffer?.file?.path
    if filePath and path.extname(filePath) in atom.config.get('open-in-browsers').fileTypes
      @browserBar = @statusBar.addLeftTile item: @openInBrowsersView, priority:100
    else
      @browserBar?.destroy()

  deactivate: ->
    @openInBrowsersView.destroy()

  serialize: ->
    openInBrowsersViewState: @openInBrowsersView.serialize()

  toggle: ->
