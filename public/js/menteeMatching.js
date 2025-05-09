document.addEventListener("DOMContentLoaded", function () {
    function createTextarea(wrapper) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '/matches/mentee';

        const textArea = document.createElement('textarea');
        textArea.name = 'message';
        textArea.rows = 5;
        textArea.columns = 145;
        textArea.style.resize = 'none';
        form.appendChild(textArea);

        const mentorInfo = document.createElement('input');
        mentorInfo.name = 'mentor_id';
        mentorInfo.style.display = 'none';
        mentorInfo.value = wrapper.id;
        form.appendChild(mentorInfo);

        const submitButton = document.createElement('button');
        submitButton.type = 'submit';
        submitButton.value = 'Submit';
        submitButton.textContent = 'Submit';
        submitButton.disabled = true;
        form.appendChild(submitButton);

        textArea.onchange = function () {
            submitButton.disabled = false;
        }

        return form;
    }

    document.addEventListener('click', function (e) {
        if (e.target.classList.contains('apply-mentor')) {
            e.target.disabled = true;
            var closestWrapper = e.target.closest('.matching-wrapper');

            if (closestWrapper) {
                closestWrapper.appendChild(createTextarea(closestWrapper));
            }
        }
    })
})
