document.addEventListener('DOMContentLoaded', function() {
    const container = document.getElementById('languages-container');
    const addButton = document.getElementById('add-language');

    function createLanguageSelect(selectedId = null) {
        const wrapper = document.createElement('div');
        wrapper.className = 'language-select-wrapper';

        const select = document.createElement('select');
        select.className = 'language-select';
        select.name = 'user_languages[]';

        // from @languages
        languagesData.forEach(lang => {
            const option = document.createElement('option');
            option.value = lang.id;
            option.textContent = lang.language_name;
            if (selectedId && lang.id === selectedId) {
                option.selected = true;
            }
            select.appendChild(option);
        });

        const removeBtn = document.createElement('button');
        removeBtn.type = 'button';
        removeBtn.textContent = 'Remove';
        removeBtn.className = 'remove-language';
        removeBtn.addEventListener('click', () => wrapper.remove());

        wrapper.appendChild(select);
        wrapper.appendChild(removeBtn);

        return wrapper;
    }

    // So that removing works on both new array of lang and also the embedded ruby list
    container.addEventListener('click', function(e) {
        if (e.target.classList.contains('remove-language')) {
            e.target.closest('.language-select-wrapper').remove();
            if (container.children.length === 0) {
                container.appendChild(createLanguageSelect());
            }
        }
    });

    // add new language
    addButton.addEventListener('click', function() {
        container.appendChild(createLanguageSelect());
    });

    // start with at least one select if empty
    if (container.children.length === 0) {
        container.appendChild(createLanguageSelect());
    }
});
