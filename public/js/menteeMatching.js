
    function createTextarea(wrapper) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '/matches/mentee';
        form.classList = "application-message-form"

        const textArea = document.createElement('textarea');
        textArea.name = 'message';
        textArea.rows = 5;
        textArea.classList = 'application-message';
        textArea.columns = 145;
        textArea.style.resize = 'none';
        form.appendChild(textArea);

        const mentorInfo = document.createElement('input');
        const mentorId = wrapper.dataset.mentorId;
        mentorInfo.name = 'mentor_id';
        mentorInfo.style.display = 'none';
        mentorInfo.value = mentorId;
        form.appendChild(mentorInfo);

        const submitButton = document.createElement('button');
        submitButton.type = 'submit';
        submitButton.value = 'Submit';
        submitButton.classList = 'mentee-submit';
        submitButton.textContent = 'Submit';
        submitButton.disabled = true;
        form.appendChild(submitButton);

        textArea.onchange = function () {
            submitButton.disabled = false;
        }

        return form;
    }

function openMatching(userId) {
    const popup = document.getElementById(`matchPopup${userId}`);
    if (popup) {
        document.querySelectorAll('.match-popup').forEach(p => p.style.display = 'none');
        popup.style.display = "block";

        const wrapper = document.getElementById(`${userId}-application-wrapper`);
        if (wrapper) {
            wrapper.innerHTML = '';
            wrapper.appendChild(createTextarea(wrapper));
        }
    }
}

document.addEventListener("DOMContentLoaded", function () {
    document.addEventListener('click', function (e) {
        if (e.target.classList.contains('apply-mentor')) {
            var closestWrapper = e.target.closest('.application-wrapper');

            if (closestWrapper && !closestWrapper.querySelector('form')) {
                closestWrapper.appendChild(createTextarea(closestWrapper));
            }
        }
    })
})

document.querySelectorAll('.match-popup').forEach(popup => {
    popup.addEventListener('click', function (event) {
        const content = popup.querySelector('.match-popup-content');
        if (!content.contains(event.target)) {
            popup.style.display = 'none';
        }
    });
});