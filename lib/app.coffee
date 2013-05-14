express = require('express')
http = require('http')
path = require('path')
coffeescript = require('connect-coffee-script');
fs = require('fs')
child_process = require('child_process')
exec = child_process.exec

app = express()

app.configure ->
  app.set('port', process.env.PORT or 3000)
  app.set('views', __dirname + '/../views')
  app.set('view engine', 'jade')
  app.set('config dir', path.resolve(__dirname, '../config'))
  app.set('config path', app.get('config dir') + '/config.json')
  app.use(express.favicon())
  app.use(express.logger('dev'))
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(require('less-middleware')({ src: __dirname + '/../public' }))
  app.use(coffeescript(prefix: __dirname + '/..', src: __dirname + '/../app', dest: __dirname + '/../public', sourceMap: true, bare: true, force: true, sourceFiles: ['app.coffee']))
  app.use(express.static(path.join(__dirname, '../public')))
  app.use(express.static(path.join(__dirname, '../app')))

class Config
  @read: (cb) ->
    fs.exists app.get('config path'), (exists) ->
      if exists
        fs.readFile(app.get('config path'), { encoding: 'utf8' }, (err, data) -> cb(err, JSON.parse(data)))
      else
        cb(null, { hosts: [], proxies: [{ name: 'None', url: '' }], selectedProxy: 0 })
  @write: (data, cb) ->
    fs.writeFile(app.get('config path'), JSON.stringify(data), { encoding: 'utf8' }, cb)

setProxy = ->
  p = "http://localhost:#{app.get('port')}/proxy.pac?#{Math.random()}"
  console.log "Setting proxy to #{p}"
  child = exec("networksetup -setautoproxyurl 'Wi-Fi' #{p}")

app.configure 'development', ->
  app.use(express.errorHandler())

app.get '/', (req, res) ->
  res.render('index', { proxies: ['None', 'Charles'], hosts: ['foo', 'bar', 'baz'] })

app.get '/config.json', (req, res) ->
  Config.read (err, data) ->
    console.log('err', err, 'data', data)
    throw err if err
    res.json JSON.stringify(data)

app.post '/config.json', (req, res) ->
  Config.write req.body.config, (err) ->
    throw err if err
    res.json(status: 'ok')
    setProxy()

template = """
function FindProxyForURL(url, host) {
  if (_HOSTS_) {
    return "PROXY _PROXY_; DIRECT;"
  }

  return "DIRECT";
}
"""

app.get '/proxy.pac', (req, res) ->
  Config.read (err, config) ->
    throw err if err
    active_hosts = config.hosts.filter((h) -> h.active)
    hosts = if active_hosts.length > 0 and config.selectedProxy != 0
      active_hosts.map((h) -> "shExpMatch(host, '#{h.value}')").join(' || ')
    else
      'false'
    res.end template.replace('_HOSTS_', hosts).replace('_PROXY_', config.proxies[config.selectedProxy].url)

http.createServer(app).listen app.get('port'), ->
  console.log("ProMan server listening on port " + app.get('port'))
  setProxy()
