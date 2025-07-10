// This function will be called when the page loads
document.addEventListener('DOMContentLoaded', function() {
    // Replace this with the actual Invoke URL of your API Gateway stage
    const apiUrl = 'https://l6dtmjrwb6.execute-api.us-east-1.amazonaws.com/visit';

    // Make a POST request to the API
    fetch(apiUrl, {
        method: 'POST'
    })
    .then(response => {
        // Check if the response is successful
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        // Update the visitor count on the page
        const countElement = document.getElementById('visitor-count');
        if (data && typeof data.count !== 'undefined') {
            countElement.textContent = data.count;
        } else {
            countElement.textContent = "N/A";
        }
    })
    .catch(error => {
        console.error('There was a problem with the fetch operation:', error);
        // Display an error message if the API call fails
        const countElement = document.getElementById('visitor-count');
        countElement.textContent = "Error";
    });
});