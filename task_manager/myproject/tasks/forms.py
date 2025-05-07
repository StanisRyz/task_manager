from django import forms
from .models import Task
from django.contrib.auth.models import User

#Форма для создания задач
class TaskForm(forms.ModelForm):
    assigned_to_ids = forms.CharField(
        widget = forms.HiddenInput(),
        required = False,
        label = 'Назначенные сотрудники'
    )

    deadline = forms.DateTimeField(
        widget = forms.DateTimeInput(attrs = {'type': 'datetime-local'}),
        label = 'Дедлайн'
    )

    #Мета-данные формы
    class Meta:
        model = Task
        fields = ['title', 'description', 'deadline']
        labels = {
            'title': 'Заголовок',
            'description': 'Описание',
        }
        widgets = {
            'description': forms.Textarea(attrs = {'rows': 4}),
        }

    def __init__(self, *args, **kwargs):
        self.request = kwargs.pop('request', None)
        super().__init__(*args, **kwargs)
        self.available_employees = User.objects.filter(groups__name = 'Сотрудники')
        if self.instance and self.instance.pk:
            self.initial['assigned_to_ids'] = ','.join(str(user.id) for user in self.instance.assigned_to.all())

    def clean_assigned_to_ids(self):
        assigned_to_ids = self.cleaned_data.get('assigned_to_ids', '')
        if not assigned_to_ids:
            return []
        try:
            ids = [int(id_str) for id_str in assigned_to_ids.split(',') if id_str]
            users = User.objects.filter(id__in = ids, groups__name = 'Сотрудники')
            if len(users) != len(ids):
                raise forms.ValidationError('Один или несколько выбранных сотрудников недействительны')
            if len(ids) != len(set(ids)):
                raise forms.ValidationError('Сотрудники не могут быть выбраны повторно')
            print('Cleaned assigned_to_ids: ', [user.id for user in users])
            return users
        except ValueError:
            raise forms.ValidationError('Недействительные ID сотрудников')

    def save(self, commit = True, user = None):
        task = super().save(commit = False)
        if user:
            task.created_by = user
        if commit:
            task.save()
            assigned_users = self.cleaned_data.get('assigned_to_ids', [])
            print('Assigned users:', [user.id for user in assigned_users])
            task.assigned_to.set(assigned_users)
        return task