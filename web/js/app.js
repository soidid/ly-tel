/* App Module */

var ivodApp = angular.module("ivodApp", [
  'ui.router',
  'lyServices',
  'ivodControllers'
]);

ivodApp.config(['$stateProvider', '$urlRouterProvider',
  function($stateProvider, $urlRouterProvider){
    $urlRouterProvider.otherwise("/");
    $stateProvider.
      state('index',{
      url: '/',
      templateUrl: 'partials/index.html',
      controller: 'indexCtrl'
    }).
      state('list',{
      url: '/list',
      templateUrl: 'partials/list.html',
      controller: 'indexCtrl'
    }).
      state('about',{
      url: '/about',
      templateUrl: 'partials/about.html',
      controller: 'aboutCtrl'
    }).
      state('data',{
      url: '/data',
      templateUrl: 'partials/data.html'
    }).
      state('contact',{
      url: '/contact',
      templateUrl: 'partials/contact.html'
    });
}]);


