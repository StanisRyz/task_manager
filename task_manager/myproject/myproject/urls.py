from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

#Список маршрутов проекта
urlpatterns = [
    #Админ-панель по адресу /admin/
    path('admin/', admin.site.urls),
    #Маршруты аутентификации
    path('accounts/', include('django.contrib.auth.urls')),
    #Подключаем URL приложения
    path('', include('tasks.urls')),
]