```
cd /src
mkdir l10dev_tmp
cd l10dev_tmp
composer create-project "laravel/laravel=10.*" . --prefer-dist

cd /src
mv l10dev_tmp/* ./
mv l10dev_tmp/.* ./
rm l10dev_tmp -rf

cd /src
composer install
npm install

chmod -R guo+w storage
php artisan storage:link
```