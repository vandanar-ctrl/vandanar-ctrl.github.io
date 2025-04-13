// Redirect to login page if not logged in (for protected pages)
if (sessionStorage.getItem("isLoggedIn") !== "true" && !window.location.href.includes("index.html")) {
    window.location.href = "../index.html";
}

// Prevent back navigation to login page
if (!window.location.href.includes("../index.html")) {
    history.pushState(null, null, location.href);
    window.onpopstate = function () {
        history.go(1);
    };
}

// Logout function to clear session and redirect to login page
function logout() {
    sessionStorage.removeItem("isLoggedIn"); // Clear login state
    window.location.href = "../index.html"; // Redirect to login page
}

// Login function for the login page
function login() {
    const validUsername = "user";
    const validPassword = "password";

    const username = document.getElementById("username").value;
    const password = document.getElementById("password").value;
    const message = document.getElementById("message");

    if (username === validUsername && password === validPassword) {
        sessionStorage.setItem("isLoggedIn", "true"); // Set login state
        window.location.href = "../Auth/home.html"; // Redirect to home page
    } else {
        message.style.color = "red";
        message.textContent = "Invalid username or password.";
    }
}

// Load components dynamically
document.addEventListener("DOMContentLoaded", function () {
    // Function to load a component into a target element
    function loadComponent(filePath, targetId) {
        fetch(filePath)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`Failed to load ${filePath}`);
                }
                return response.text();
            })
            .then(data => {
                document.getElementById(targetId).innerHTML = data;
            })
            .catch(error => console.error(`Error loading ${filePath}:`, error));
    }

    // Load multiple components
    loadComponent("../common/common_navbar.html", "navbar"); // Load navbar
    // loadComponent("common_footer.html", "footer"); // Load footer
    // loadComponent("common_sidebar.html", "sidebar"); // Load sidebar (if needed)
});