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
    loadComponent("common_navbar.html", "navbar"); // Load navbar
    // loadComponent("common_footer.html", "footer"); // Load footer
    // loadComponent("common_sidebar.html", "sidebar"); // Load sidebar (if needed)
});