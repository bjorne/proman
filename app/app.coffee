proman = angular.module 'proman', []

proman.directive 'promanBlur', ->
  (scope, elem, attrs) ->
    elem.bind 'blur', ->
      scope.$apply(attrs.promanBlur)

proman.directive 'promanFocus', ($timeout) ->
  (scope, elem, attrs) ->
    scope.$watch attrs.promanFocus, (newVal) ->
      if newVal
        $timeout ->
          elem[0].focus()
        , 0, false


proman.controller 'ConfigCtrl', ($scope, $http) ->
  $scope.loading = false

  saveConfig = ->
    console.log 'saving config'
    $scope.loading = true
    config = { hosts: $scope.hosts, proxies: $scope.proxies, selectedProxy: +$scope.selectedProxy }
    $http.post('/config.json', config: config).success ->
      $scope.loading = false
  loadConfig = ->
    return if $scope.loading
    $scope.loading = true
    $http.get('/config.json').success (config) ->
      config = JSON.parse(JSON.parse(config))
      console.log config
      $scope.hosts = config.hosts or []
      $scope.proxies = config.proxies or [{ name: 'None', url: '' }]
      $scope.selectedProxy = +config.selectedProxy or 0
      $scope.loading = false
  loadConfig()

  $scope.editedHost = null
  $scope.editedProxy = null

  $scope.editHost = (host) ->
    $scope.editedHost = host
  $scope.doneEditing = (host) ->
    if host.value == ''
      $scope.removeHost host
    saveConfig()
    $scope.editedHost = null
  $scope.removeHost = (host) ->
    $scope.hosts.splice $scope.hosts.indexOf(host), 1
    saveConfig()
  $scope.toggleHost = (host) ->
    host.active = !host.active
    saveConfig()
  $scope.addHost = () ->
    host = value: '', active: true
    $scope.hosts.push(host)
    $scope.editHost(host)

  # $scope.selectedProxy = 1
  $scope.selectProxy = (index) ->
    $scope.selectedProxy = index
    saveConfig()
  # $scope.$watch 'selectedProxy', saveConfig
  $scope.editProxy = (proxy) ->
    unless proxy.name == 'None'
      $scope.editedProxy = proxy
  $scope.doneEditingProxy = (proxy) ->
    if proxy.name == '' or proxy.url == ''
      $scope.removeProxy proxy
    saveConfig()
    $scope.editedProxy = null
  $scope.removeProxy = (proxy) ->
    unless proxy.name == 'None'
      $scope.proxies.splice $scope.proxies.indexOf(proxy), 1
      saveConfig()
  $scope.addProxy = ->
    proxy = name: '', url: ''
    $scope.proxies.push(proxy)
    $scope.editProxy(proxy)