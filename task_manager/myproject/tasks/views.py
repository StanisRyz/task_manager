from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required, user_passes_test
from .models import Task, Comment, Notification
from .forms import TaskForm, EmployeeCreationForm
from django import forms
from django.utils import timezone
from django.contrib.auth.models import User, Group
from django.http import JsonResponse
from django.core.paginator import Paginator
from django.db.models import Count, Q

# Create your views here.

#Форма для добавления комментария
class CommentForm(forms.ModelForm):
    class Meta:
        model = Comment
        fields = ['text']
        labels = {'text': 'Комментарий'}
        widgets = {'text': forms.Textarea(attrs = {'rows': 3})}

class TaskFilterForm(forms.Form):
    #Фильтр по дедлайну
    DEADLINE_CHOICES = [
        ('', 'Все'),
        ('overdue', 'Просроченные'),
        ('today', 'Сегодня'),
        ('future', 'Будущие'),
    ]
    deadline = forms.ChoiceField(choices = DEADLINE_CHOICES, required = False, label = 'Дедлайн')
    #Фильтр по статусу (только менеджеры)
    STATUS_CHOICES =[
        ('', 'Все'),
        ('in_progress', 'В работе'),
        ('on_revision', 'На доработке'),
        ('completed', 'Выполнена'),
    ]
    status = forms.ChoiceField(choices = STATUS_CHOICES, required = False, label = 'Статус')
    #Фильтр по сотруднику (только для менеджеров)
    assigned_to = forms.ModelChoiceField(
        queryset = User.objects.filter(groups__name = 'Сотрудники'),
        required = False,
        label = 'Сотрудник',
        empty_label = 'Все',
    )

def get_notification_context(request):
    return {
        'notifications': Notification.objects.filter(recipient = request.user, is_read = False).order_by('-created_at'),
        'unread_notifications_count': Notification.objects.filter(recipient = request.user, is_read = False).count(),
    }
#Представление для списка задач
@login_required #Пользователь должен быть авторизован
def task_list(request):
    #Исключаем архивированные задачи
    if request.user.groups.filter(name = 'Менеджеры').exists():
        tasks = Task.objects.exclude(status = 'archived')
    else:
        tasks = Task.objects.filter(assigned_to = request.user).exclude(status = 'archived')

    #Форма фильтров
    form = TaskFilterForm(request.GET)
    if form.is_valid():
        deadline = form.cleaned_data['deadline']
        if deadline == 'overdue':
            tasks = tasks.filter(deadline__lt = timezone.now())
        elif deadline == 'today':
            tasks = tasks.filter(deadline__date = timezone.now().date())
        elif deadline == 'future':
            tasks = tasks.filter(deadline__gt = timezone.now())

    #Фильтры для менеджеров
        if request.user.groups.filter(name = 'Менеджеры').exists():
            status = form.cleaned_data['status']
            if status:
                tasks = tasks.filter(status = status)
            assigned_to = form.cleaned_data['assigned_to']
            if 'assigned_to' in request.GET:
                if assigned_to:
                    tasks = tasks.filter(assigned_to = assigned_to)
                else:
                    tasks = tasks

    #Обработка сортировки
    sort = request.GET.get('sort')
    direction = request.GET.get('direction', 'asc')
    if sort == 'deadline':
        if direction == 'desc':
            tasks = tasks.order_by('-deadline')
        else:
            tasks = tasks.order_by('deadline')

    #Проверка просроченные задачи
    now = timezone.now()
    for task in tasks:
        task.is_overdue = task.deadline < now
        if task.is_overdue:
            for assignee in task.assigned_to.all():
                if not Notification.objects.filter(
                    recipient = assignee,
                    task = task,
                    message = f"Задача '{task.title}' просрочена"
                ).exists():
                    Notification.objects.create(
                        recipient = assignee,
                        task = task,
                        message = f"Задача '{task.title}' просрочена"
                    )

    #Количество непрочитанных уведомлений
    unread_notifications_count = Notification.objects.filter(
        recipient = request.user, is_read = False
    ).count()

    #Передаем текущий порядок сортировки в контекст
    context = {
        'tasks': tasks,
        'form': form,
        'sort': sort,
        'direction': direction,
        'now': now,
    }
    context.update(get_notification_context(request))

    return render(request, 'tasks/task_list.html', context)

#Представление для создания задачи
@login_required
def task_create(request):
    if not request.user.groups.filter(name = 'Менеджеры').exists():
        return redirect('task_list')

    if request.method == 'POST':
        print('POST data: ', request.POST)
        print('assigned_to_ids: ', request.POST.get('assigned_to_ids', ''))
        form = TaskForm(request.POST, request = request)
        if form.is_valid():
            task = form.save(commit = True, user = request.user)
            print('Task saved with assignees:', [user.username for user in task.assigned_to.all()])
            for assignee in task.assigned_to.all():
                if assignee != request.user:
                    Notification.objects.create(
                        recipient = assignee,
                        task = task,
                        message = f"Новая задача '{task.title}' назначена Вам"
                    )
            return redirect('task_list')
        else:
            print('Form errors', form.errors)
    else:
        form = TaskForm(request = request)
    context = {'form': form}
    context.update(get_notification_context(request))
    return render(request, 'tasks/task_form.html', context)

#Представление для деталей задачи
@login_required
def task_detail(request, pk):
    #Получаем задачу по ID или возвращаем 404
    task = get_object_or_404(Task, pk = pk)
    #Проверяем, имеет ли пользователь доступ
    if not (request.user in task.assigned_to.all() or request.user.groups.filter(name = 'Менеджеры').exists()):
        return render(request, 'tasks/error.html', {
            'error_message': 'У вас нет доступа к этой задаче.'
        }, status = 403)

    #Обработка формы комментария
    if request.method == 'POST' and 'comment' in request.POST:
        comment_form = CommentForm(request.POST)
        if comment_form.is_valid():
            comment = comment_form.save(commit = False)
            comment.task = task
            comment.created_by = request.user
            comment.save()
            recipients = set(task.assigned_to.all()) | {task.created_by}
            recipients.discard(request.user)
            for recipient in recipients:
                Notification.objects.create(
                    recipient = recipient,
                    task = task,
                    message = f"Новый комментарий к задаче '{task.title}' от {request.user.username}"
                )
            return redirect('task_detail', pk = pk)
    else:
        comment_form = CommentForm()

    #Обработка изменения статуса
    if request.method == 'POST' and 'status' in request.POST:
        status = request.POST.get('status')
        if status in dict(Task.STATUS_CHOICES).keys():
            #Проверяем права на изменение статуса
            if status == 'completed' and request.user in task.assigned_to.all():
                task.status = status
                if task.created_by not in task.assigned_to.all():
                    Notification.objects.create(
                        recipient = task.created_by,
                        task = task,
                        message = f"Задача '{task.title}' отмечена как выполненная"
                    )
            elif status in ['archived', 'on_revision'] and request.user.groups.filter(name = 'Менеджеры').exists():
                task.status = status
                if status == 'on_revision':
                    for assignee in task.assigned_to.all():
                        if assignee != request.user:
                            Notification.objects.create(
                                recipient = assignee,
                                task = task,
                                message = f"Задача '{task.title}' отправлена на доработку"
                            )
            task.save()
            return redirect('task_detail', pk = pk)

    context = {
        'task': task,
        'comment_form': comment_form,
    }
    context.update(get_notification_context(request))

    #Рендерим шаблон с задачей и формой комментария
    return render(request, 'tasks/task_detail.html', context)

#Представление для архива
@login_required
def task_archived(request):
    #Только менеджеры могут видеть архив
    if not request.user.groups.filter(name = 'Менеджеры').exists():
        return redirect('task_list')
    #Получаем только архивированные задачи
    tasks = Task.objects.filter(status = 'archived')
    context = {'tasks': tasks}
    context.update(get_notification_context(request))
    return render(request, 'tasks/task_archive.html', context)

@login_required
def task_edit(request, pk):
    task = get_object_or_404(Task, pk = pk)
    if not request.user.groups.filter(name = 'Менеджеры').exists():
        return redirect('task_detail', pk = pk)
    if request.method == "POST":
        form = TaskForm(request.POST, instance = task, request = request)
        if form.is_valid():
            updated_task = form.save(commit = True, user = request.user)
            print('Task saved with assignees:', list(task.assigned_to.all()))
            old_assignees = set(task.assigned_to.all())
            new_assignees = set(updated_task.assigned_to.all())
            for assignee in new_assignees - old_assignees:
                if assignee != request.user:
                    Notification.objects.create(
                        recipient = assignee,
                        task = updated_task,
                        message = f"Задача '{updated_task.title}' была назначена Вам"
                    )
            for assignee in old_assignees - new_assignees:
                if assignee != request.user:
                    Notification.objects.create(
                        recipient = assignee,
                        task = updated_task,
                        message = f"Задача '{updated_task.title}' была снята с Вас"
                    )
            for assignee in new_assignees & old_assignees:
                if assignee != request.user:
                    Notification.objects.create(
                        recipient = assignee,
                        task = updated_task,
                        message = f"Задача '{updated_task.title}' была обновлена"
                    )
            return redirect('task_detail', pk = pk)
        else:
            print('Form errors:', form.errors)
    else:
        form = TaskForm(instance = task, request = request)
    context = {'form': form, 'task': task}
    context.update(get_notification_context(request))
    return render(request, 'tasks/task_edit.html', context)

@login_required
def mark_notifications_read(request):
    if request.method == "POST":
        Notification.objects.filter(
            recipient = request.user, is_read = False
        ).update(is_read = True)
        return JsonResponse({'status': 'success'})
    return JsonResponse({'status': 'error'}, status = 400)

@login_required
def notifications_list(request):
    notifications = Notification.objects.filter(recipient = request.user)

    Notification.objects.filter(recipient = request.user, is_read = False).update(is_read = True)

    paginator = Paginator(notifications, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)

    context = {
        'page_obj': page_obj,
    }
    context.update(get_notification_context(request))
    return render(request, 'tasks/notifications_list.html', context)

@login_required
def clear_notifications(request):
    if request.method == 'POST':
            Notification.objects.filter(recipient = request.user).delete()
            return JsonResponse({'status': 'success'})
    return JsonResponse({'status': 'error'}, status = 400)

def is_manager(user):
    return user.groups.filter(name = 'Менеджеры').exists()

@login_required
@user_passes_test(is_manager, login_url = 'task_list')
def employee_list(request):
    employees = User.objects.filter(groups__name = 'Сотрудники').order_by('username').annotate(
        task_count = Count('assigned_tasks'),
        overdue_count = Count('assigned_tasks', filter = Q(
            assigned_tasks__deadline__lt = timezone.now(),
            assigned_tasks__status__in = ['in_progress', 'on_revision']
        ))
    )
    context = {
        'employees': employees,
    }
    context.update(get_notification_context(request))
    return render(request, 'tasks/employee_list.html', context)

@login_required
@user_passes_test(is_manager, login_url = 'task_list')
def employee_create(request):
    if request.method == 'POST':
        form = EmployeeCreationForm(request.POST)
        if form.is_valid():
            username = form.cleaned_data['username']
            first_name = form.cleaned_data['first_name']
            last_name = form.cleaned_data['last_name']
            password = f"1234{username[0].upper()}"
            user = User.objects.create_user(
                username = username,
                first_name = first_name,
                last_name = last_name,
                password = password
            )
            employee_group = Group.objects.get(name = 'Сотрудники')
            user.groups.add(employee_group)
            return redirect('employee_list')
    else:
        form = EmployeeCreationForm()
    context = {'form': form}
    context.update(get_notification_context(request))
    return render(request, 'tasks/employee_form.html', context)