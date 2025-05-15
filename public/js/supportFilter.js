document.addEventListener('DOMContentLoaded', () => {
    let select = document.getElementById('account-filter');
    let form = document.getElementById('filter-form');

    select.addEventListener('change', () => {
        form.submit();
    })
})