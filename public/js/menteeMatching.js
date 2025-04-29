document.addEventListener("DOMContentLoaded", function () {
    const applyButton = document.getElementById('apply-mentor');
    const wrapper = document.getElementById('matching-wrapper');
    function createTextarea() {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '/matches/mentee';

        const textArea = document.createElement('textarea');
        textArea.name = 'message';
        textArea.rows = 5;
        textArea.columns = 45;
        form.appendChild(textArea);

        const mentorInfo = document.createElement('input');
        mentorInfo.name = 'mentor_id';
        mentorInfo.style.display = 'none';
        mentorInfo.value = wrapper.className;
        form.appendChild(mentorInfo);

        const submitButton = document.createElement('button');
        submitButton.type = 'submit';
        submitButton.value = 'Submit';
        submitButton.textContent = 'Submit';
        form.appendChild(submitButton);

        return form;
    }

    applyButton.addEventListener('click', function () {
        wrapper.appendChild(createTextarea());
    })
})