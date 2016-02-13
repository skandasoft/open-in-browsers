module.exports =
    browser:
      title: 'Browser'
      type: 'boolean'
      default: true
      win32:
        IE:
          cmd: 'start iexplore '
        Edge:
          cmd: 'start microsoft-edge '
        Chrome:
          cmd:  'start chrome '
        Firefox:
          cmd:  'start firefox '
        Opera:
          cmd: 'start opera '
        Safari:
          cmd: 'start safari '
      win64:
        Edge:
          cmd: 'start microsoft-edge '
        IE:
          cmd: 'start iexplore '
        Chrome:
          cmd:  'start chrome '
        Firefox:
          cmd:  'start firefox '
        Opera:
          cmd: 'start opera '
        Safari:
          cmd: 'start safari '

      darwin:
        Chrome:
          cmd: 'open -a "Google Chrome" '
        Firefox:
          cmd: 'open -a "Firefox" '
        Safari:
          cmd: 'open -a "Safari" '
        Opera:
          cmd: 'open -a "Opera" '

      linux:
        Chrome:
          cmd: 'chrome '
        Firefox:
          cmd: 'firefox '
        Safari:
          cmd: 'safari '
        Opera:
          cmd: 'opera '
