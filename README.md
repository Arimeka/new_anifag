# New view of anifag.com

Move along.

### To-Do List ###

1. Tests, tests, test. There is no tests.
2. DRY-DRY-DRY
3. Bake a cake.

### Used gems ###

* [Russian](https://github.com/yaroslav/russian "Russian") - Russian language support for Ruby and Rails, using I18n library.
* [Bootstrap for Sass](https://github.com/thomas-mcdonald/bootstrap-sass "Bootstrap for Sass") - Sass-powered version of Twitter's Bootstrap.
* [bcrypt-ruby](https://github.com/codahale/bcrypt-ruby "bcrypt-ruby") - To keep users' passwords secure.
* [will_paginate](https://github.com/mislav/will_paginate "will_paginate") - pagination library.
* [bootstrap-will_paginate](https://github.com/yrgoldteeth/bootstrap-will_paginate "bootstrap-will_paginate") - Will Paginate link renderer styles for Twitter Bootstrap.
* [Dalli](https://github.com/mperham/dalli "Dalli") - High performance memcached client for Ruby.
* [pg](https://bitbucket.org/ged/ruby-pg "pg") - an interface to the PostgreSQL Relational Database Management System.
* [pg_search](https://github.com/Casecommons/pg_search "pg_search") - builds ActiveRecord named scopes that take advantage of PostgreSQL's full text search.
...and so on. I too lazy to write this thing.

### Не забыть ###

/lib/tasks/create_data.rake - переносит статьи из блоггера на сайт, попутно создавая пользователя с админскими правами. Суть работы кода: из файла бэкапа блоггера находятся релевантные данные по урлу автора на гуглоплюсе и тегу id. Не забыть убрать из attr_accessible created_at и updated_at в article.rb после переноса.

### Проблемы ###

* Регистрация должна работать по инвайтам, но нет уверености в работе мэйлера. Точнее, есть увереность, что он не работает.
* Без тестов все очень печально.
* Код ужасен.