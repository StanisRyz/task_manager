document.addEventListener('DOMContentLoaded', () => {

    const employeeFields = document.getElementById('employee-fields');
    const addEmployeeBtn = document.getElementById('add-employee');
    const assignedToIdsInput = document.querySelector('input[name="assigned_to_ids"]');
    let employeeCounter = document.querySelectorAll('.employee-select').length || 1;

    if (!employeeFields || !addEmployeeBtn || !assignedToIdsInput) {
        return;
    }

    const employeeOptions = Array.from(document.querySelector('.employee-select').options)
        .slice(1)
        .map(opt => `<option value="${opt.value}">${opt.text}</option>`).join('');

    function updateAssignedToIds() {
        const selects = employeeFields.querySelectorAll('.employee-select');
        const selectedIds = Array.from(selects)
            .map(select => select.value)
            .filter(val => val);
        assignedToIdsInput.value = selectedIds.join(',');
    }

    function updateEmployeeOptions() {
        const allSelects = employeeFields.querySelectorAll('.employee-select');
        const selectedValues = Array.from(allSelects)
            .map(select => select.value)
            .filter(val => val);
        allSelects.forEach(select => {
            const currentValue = select.value;
            select.innerHTML = '<option value="" disabled>Выберите сотрудника</option>' + employeeOptions;
            Array.from(select.options).forEach(option => {
                if (selectedValues.includes(option.value) && option.value !== currentValue) {
                    option.style.display = 'none';
                } else {
                    option.style.display = '';
                }
                if (option.value === currentValue) {
                    option.selected = true;
                }
            });
            if (!currentValue) {
                select.options[0].selected = true;
            }
        });
    }

    addEmployeeBtn.addEventListener('click', () => {
        const newField = document.createElement('div');
        newField.className = 'employee-field mb-2 d-flex align-items-center';
        newField.innerHTML = `
            <select name="employee_select_${employeeCounter}" class="form-select employee-select me-2" required>
                <option value="" disabled selected>Выберите сотрудника</option>
                ${employeeOptions}
            </select>
            <button type="button" class="btn btn-danger btn-sm remove-employee">Удалить</button>
        `;
        employeeFields.appendChild(newField);
        employeeCounter++;
        updateEmployeeOptions();
        updateAssignedToIds();
    });

    employeeFields.addEventListener('change', (e) => {
        if (e.target.classList.contains('employee-select')) {
            updateEmployeeOptions();
            updateAssignedToIds();
        }
    });

    employeeFields.addEventListener('click', (e) => {
        if (e.target.classList.contains('remove-employee')) {
            e.target.closest('.employee-field').remove();
            updateEmployeeOptions();
            updateAssignedToIds();
        }
    });

    updateEmployeeOptions();
    updateAssignedToIds();

});