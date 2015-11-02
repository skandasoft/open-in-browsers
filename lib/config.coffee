module.exports = 
    browser:
      title: 'Browser'
      type: 'boolean'
      default: true
      win32:
        IE:
          cmd: 'start iexplore '
        CHROME:
          cmd:  'start chrome '
        FF:
          cmd:  'start firefox '
        OPERA:
          cmd: 'start opera '
        SAFARI:
          cmd: 'start safari '
      win64:
        IE:
          cmd: 'start iexplore '
        CHROME:
          cmd:  'start chrome '
        FF:
          cmd:  'start firefox '
        OPERA:
          cmd: 'start opera '
        SAFARI:
          cmd: 'start safari '
      darwin:
        CHROME:
          cmd: 'open -a "Google Chrome" '
        FF:
          cmd: 'open -a "Firefox" '
        SAFARI:
          cmd: 'open -a "Safari" '
        OPERA:
          cmd: 'open -a "Opera" '
      linux:
        CHROME:
          cmd: 'chrome '
        FF:
          cmd: 'firefox '
        SAFARI:
          cmd: 'safari '
        OPERA:
          cmd: 'opera '
