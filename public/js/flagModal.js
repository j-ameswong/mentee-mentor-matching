  // Get the modal
  const modal = document.getElementById("flagModal");
  const modalUsername = document.getElementById("modalUsername");
  const modalUserId = document.getElementById("modalUserId");
  
  // Open the modal with the user's info
  function openFlagModal(userId, username) {
    modal.style.display = "block";
    modalUsername.textContent = username;
    modalUserId.value = userId;
  }
  
  // Close the modal
  function closeModal() {
    modal.style.display = "none";
  }
  
  // Close the modal if clicked outside
  window.onclick = function(event) {
    if (event.target == modal) {
      closeModal();
    }
  }