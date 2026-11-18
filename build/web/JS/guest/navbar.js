const currentPage = window.location.pathname.split('/').pop() || 'dashboard.html';
document.querySelectorAll('.site-navbar .nav-link').forEach((link) => {
    const targetPage = link.getAttribute('href');
    const isActive = targetPage === currentPage;
    link.classList.toggle('active', isActive);
    if (isActive) {
        link.setAttribute('aria-current', 'page');
    } else {
        link.removeAttribute('aria-current');
    }
});

// Logout prompt
document.getElementById('logoutButton').addEventListener('click', () => {
    if (window.confirm('Are you sure you want to log out?')) {
        window.location.href = 'logout';
    }
});