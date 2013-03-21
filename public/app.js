//@ sourceMappingURL=/app.map

var proman;

proman = angular.module('proman', []);

proman.directive('promanBlur', function() {
  return function(scope, elem, attrs) {
    return elem.bind('blur', function() {
      return scope.$apply(attrs.promanBlur);
    });
  };
});

proman.directive('promanFocus', function($timeout) {
  return function(scope, elem, attrs) {
    return scope.$watch(attrs.promanFocus, function(newVal) {
      if (newVal) {
        return $timeout(function() {
          return elem[0].focus();
        }, 0, false);
      }
    });
  };
});

proman.controller('ConfigCtrl', function($scope, $http) {
  var loadConfig, saveConfig;

  $scope.loading = false;
  saveConfig = function() {
    var config;

    console.log('saving config');
    $scope.loading = true;
    config = {
      hosts: $scope.hosts,
      proxies: $scope.proxies,
      selectedProxy: +$scope.selectedProxy
    };
    return $http.post('/config.json', {
      config: config
    }).success(function() {
      return $scope.loading = false;
    });
  };
  loadConfig = function() {
    if ($scope.loading) {
      return;
    }
    $scope.loading = true;
    return $http.get('/config.json').success(function(config) {
      config = JSON.parse(JSON.parse(config));
      console.log(config);
      $scope.hosts = config.hosts || [];
      $scope.proxies = config.proxies || [
        {
          name: 'None',
          url: ''
        }
      ];
      $scope.selectedProxy = +config.selectedProxy || 0;
      return $scope.loading = false;
    });
  };
  loadConfig();
  $scope.editedHost = null;
  $scope.editedProxy = null;
  $scope.editHost = function(host) {
    return $scope.editedHost = host;
  };
  $scope.doneEditing = function(host) {
    if (host.value === '') {
      $scope.removeHost(host);
    }
    saveConfig();
    return $scope.editedHost = null;
  };
  $scope.removeHost = function(host) {
    $scope.hosts.splice($scope.hosts.indexOf(host), 1);
    return saveConfig();
  };
  $scope.toggleHost = function(host) {
    host.active = !host.active;
    return saveConfig();
  };
  $scope.addHost = function() {
    var host;

    host = {
      value: '',
      active: true
    };
    $scope.hosts.push(host);
    return $scope.editHost(host);
  };
  $scope.selectProxy = function(index) {
    $scope.selectedProxy = index;
    return saveConfig();
  };
  $scope.editProxy = function(proxy) {
    if (proxy.name !== 'None') {
      return $scope.editedProxy = proxy;
    }
  };
  $scope.doneEditingProxy = function(proxy) {
    if (proxy.name === '' || proxy.url === '') {
      $scope.removeProxy(proxy);
    }
    saveConfig();
    return $scope.editedProxy = null;
  };
  $scope.removeProxy = function(proxy) {
    if (proxy.name !== 'None') {
      $scope.proxies.splice($scope.proxies.indexOf(proxy), 1);
      return saveConfig();
    }
  };
  return $scope.addProxy = function() {
    var proxy;

    proxy = {
      name: '',
      url: ''
    };
    $scope.proxies.push(proxy);
    return $scope.editProxy(proxy);
  };
});
