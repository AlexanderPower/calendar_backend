# Придумать заголовок.
Бекэнд для календаря https://github.com/tkachevgit/pr_calendar

## Аутентификация
Для аутентификации пользователя используется JWT(JSON Web Token). Чтобы зарегистрировать пользователя надо выполнить post запрос на адрес /register с параметрами login/password, в ответе будет содержаться id пользователя и токен. Этот токен надо сохранить и при последующих запросах вставлять его в заголовок. Например так 
```
curl --header "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiNTVhN2E1MTg3NDY5Njc1NGViMDAwMDA4In0.Z6VtA_x1BfrJ-FsiiE9Gnh_F6ViHSly5gQ6Q_LIk9s4" localhost:4567/user
```

Или в ангуляре
```javascript
app.factory('AuthInterceptor', function($q, $injector) {
  return {
    request: function(config) {
      var LocalService = $injector.get('LocalService');
      var token;
      if (LocalService.get('auth_token')) {
        token = angular.fromJson(LocalService.get('auth_token')).token;
      }
      if (token) {
        config.headers.Authorization = 'Bearer ' + token;
      }
      return config;
    },
    responseError: function(response) {
      if (response.status === 401 || response.status === 403) {
        LocalService.unset('auth_token');
        $injector.get('$state').go('anon.login');
      }
      return $q.reject(response);
    }
  };
});
```
К запросам на адреса /register /login токен добавлять не надо.
