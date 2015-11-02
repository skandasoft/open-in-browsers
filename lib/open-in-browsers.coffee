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

  activate: (state) ->
    @openInBrowsersView or= new OpenInBrowsersView(state.openInBrowsersViewState)
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'open-in-browsers:toggle': => @toggle()

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
