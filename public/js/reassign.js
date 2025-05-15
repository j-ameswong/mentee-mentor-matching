// Get the reassign modal
let reassignModal;

// Wait for DOM to be fully loaded
document.addEventListener('DOMContentLoaded', function() {
  reassignModal = document.getElementById("reassignModal");
  
  // Add event listener for clicking outside the modal
  window.onclick = function(event) {
    if (event.target == reassignModal) {
      closeReassignModal();
    }
  }
  
  // Set up action handlers for the forms
  setupActionHandlers();
});

// Function to open the reassign modal
function openReassignModal(userId, username, currentMentorName) {
  reassignModal.style.display = "block";
  document.getElementById("reassignMenteeName").textContent = username;
  document.getElementById("currentMentorName").textContent = currentMentorName;
}

// Function to close the reassign modal
function closeReassignModal() {
  reassignModal.style.display = "none";
}

// Setup form action handlers
function setupActionHandlers() {
  const forms = document.querySelectorAll('form[action="/accounts/action"]');
  
  forms.forEach(form => {
    form.addEventListener('submit', function(e) {
      const action = form.querySelector('select[name="action"]').value;
      const userId = form.querySelector('input[name="user_id"]').value;
      
      if (action === 'delete') {
        e.preventDefault();
        if (confirm('Are you sure you want to delete this user?')) {
          document.getElementById(`delete-form-${userId}`).submit();
        }
      }
    });
  });
}