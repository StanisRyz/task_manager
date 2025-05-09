from django.urls import path
from . import views

#Список маршрутов
urlpatterns = [
    #Список задач
    path('', views.task_list, name = 'task_list'),
    #Создание задачи
    path('create/', views.task_create, name = 'task_create'),
    #Детали задачи
    path('task/<int:pk>/', views.task_detail, name = 'task_detail'),
    path('task/<int:pk>/edit/', views.task_edit, name = 'task_edit'),
    path('task/<int:pk>/delete/', views.task_delete, name = 'task_delete'),
    #Архив задач
    path('archive/', views.task_archived, name = 'task_archive'),
    #Проверка чтения уведомления
    path('notifications/mark-read/', views.mark_notifications_read, name = 'mark_notifications_read'),
    path('notifications', views.notifications_list, name = 'notifications_list'),
    path('notifications/clear/', views.clear_notifications, name = 'clear_notifications'),
    path('employees/', views.employee_list, name = 'employee_list'),
    path('employees/create/', views.employee_create, name = 'employee_create'),
    path('employees/<int:user_id>/edit/', views.employee_edit, name = 'employee_edit'),
    path('employees/<int:user_id>/delete/', views.employee_delete, name = 'employee_delete'),
]