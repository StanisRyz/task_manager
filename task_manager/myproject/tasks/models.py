from django.db import models
from django.contrib.auth.models import User

# Create your models here.

#Модель для задач
class Task(models.Model):
    #Список возможных статусов задачи
    STATUS_CHOICES = [
        ('in_progress', 'В работе'), #Сотрудник работает над задачей
        ('on_revision', 'На доработке'), #Задача возвращена на доработку
        ('completed', 'Выполнена'), #Сотрудник закончил задачу
        ('archived', 'В архиве'), #Задача одобрена и завершена
    ]
    #Поле для заголовка задачи
    title = models.CharField(max_length = 200)
    #Поле для подробного описания
    description = models.TextField()
    #Ссылка на сотрудника, кому назначена задача
    assigned_to = models.ManyToManyField(User, related_name = 'assigned_tasks')
    #Ссылка на руководителя
    created_by = models.ForeignKey(User, on_delete = models.CASCADE, related_name = 'created_tasks')
    #Поле для дедлайна
    deadline = models.DateTimeField()
    #Статус задачи, выбирается из STATUS_CHOICES
    status = models.CharField(max_length = 20, choices = STATUS_CHOICES, default = 'in_progress')
    #Дата создания задачи
    created_at = models.DateTimeField(auto_now_add = True)
    #Дата последнего обновления
    updated_at = models.DateTimeField(auto_now = True)

    #Метод для отображения задачи в админ-палени
    def __str__(self):
        return self.title #Возвращает заголовок задачи

#Модель для комментариев
class Comment(models.Model):
    #Ссылка на задачу, к которой относится комментарий
    task = models.ForeignKey(Task, on_delete = models.CASCADE, related_name = 'comments')
    #Ссылка на пользователя, кто оставил комментарий
    created_by = models.ForeignKey(User, on_delete = models.CASCADE)
    #Текст комментария
    text = models.TextField()
    #Дата создания комментария
    created_at = models.DateTimeField(auto_now_add = True)

    #Метод для отображения комментария в админ-панели
    def __str__(self):
        return f"Комментарий от {self.created_by} к {self.task}"

#Модель для уведомлений
class Notification(models.Model):
    recipient = models.ForeignKey(User, related_name = 'notifications', on_delete = models.CASCADE)
    task = models.ForeignKey(Task, related_name = 'notifications', on_delete = models.CASCADE, null = True, blank = True)
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add = True)
    is_read = models.BooleanField(default = False)

    def __str__(self):
        return f"Уведомление для {self.recipient}: {self.message}"

    class Meta:
        ordering = ['-created_at']