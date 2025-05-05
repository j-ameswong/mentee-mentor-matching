document.addEventListener('DOMContentLoaded', function() {
    const container = document.getElementById('expertises-container');
    const addButton = document.getElementById('add-expertise');

    function createExpertiseSelect(selectedId = null) {
        const wrapper = document.createElement('div');
        wrapper.className = 'expertise-select-wrapper';

        const select = document.createElement('select');
        select.className = 'expertise-select';
        select.name = 'user_expertises[]';

        // from @languages
        expertisesData.forEach(row => {
            const option = document.createElement('option');
            option.value = row.id;
            option.textContent = row.category + ' - ' + row.skill;
            if (selectedId && row.id === selectedId) {
                option.selected = true;
            }
            select.appendChild(option);
        });

        const removeBtn = document.createElement('button');
        removeBtn.type = 'button';
        removeBtn.textContent = 'Remove';
        removeBtn.className = 'remove-expertise';
        removeBtn.addEventListener('click', () => wrapper.remove());

        wrapper.appendChild(select);
        wrapper.appendChild(removeBtn);

        return wrapper;
    }

    // So that removing works on both new array of lang and also the embedded ruby list
    container.addEventListener('click', function(e) {
        if (e.target.classList.contains('remove-expertise')) {
            e.target.closest('.expertise-select-wrapper').remove();
            if (container.children.length === 0) {
                container.appendChild(createLanguageSelect());
            }
        }
    });

    // add new language
    addButton.addEventListener('click', function() {
        container.appendChild(createExpertiseSelect());
    });

    // start with at least one select if empty
    if (container.children.length === 0) {
        container.appendChild(createExpertiseSelect());
    }
});
