<%@page contentType="text/html" pageEncoding="UTF-8" %>

<!-- Backdrop for mobile sidebar toggle -->
<div class="side-backdrop" id="backdrop"></div>

    <!-- Sidebar Component (Slider Navigation) -->
    <aside class="side" id="sidebar">
        <a class="navbar-brand d-flex align-items-center gap-2 text-decoration-none"
            href="${pageContext.request.contextPath}/admin/dashboard" aria-label="GRANDSTAY Admin Dashboard">
            <div class="brand-monogram">
                <span class="brand-monogram-text">GS</span>
            </div>
            <div class="d-flex flex-column">
                <span class="brand-title">GRANDSTAY</span>
                <span class="brand-subtitle">Hotel &amp; Residences &bull; Admin</span>
            </div>
        </a>

        <div class="nav-container">
            <nav class="nav" aria-label="Main Navigation">
                <div class="nav-section-title">Core Management</div>

                <a href="${pageContext.request.contextPath}/admin/dashboard"
                    class="${pageContext.request.requestURI.contains('dashboard') ? 'on' : ''}">
                    <i class="bi bi-speedometer2"></i>
                    <span>Dashboard</span>
                </a>

                <a href="${pageContext.request.contextPath}/admin/rooms"
                    class="${pageContext.request.requestURI.contains('room') ? 'on' : ''}">
                    <i class="bi bi-door-open"></i>
                    <span>Rooms Inventory</span>
                </a>

                <a href="${pageContext.request.contextPath}/admin/customers"
                    class="${pageContext.request.requestURI.contains('customer') || pageContext.request.requestURI.contains('guest') ? 'on' : ''}">
                    <i class="bi bi-people"></i>
                    <span>Customer Directory</span>
                </a>

                <div class="nav-section-title" style="margin-top: 14px;">Shortcuts &amp; Portal</div>

                <a href="${pageContext.request.contextPath}/guest/room" target="_blank" title="Open Guest Room View">
                    <i class="bi bi-box-arrow-up-right"></i>
                    <span>Guest View</span>
                </a>

                <a href="${pageContext.request.contextPath}/profile"
                    class="${pageContext.request.requestURI.contains('profile') ? 'on' : ''}">
                    <i class="bi bi-person-gear"></i>
                    <span>Admin Profile</span>
                </a>
            </nav>
        </div>

        <!-- Sidebar Footer Admin Monogram -->
        <div class="side-footer">
            <div class="user-monogram">
                <span>AD</span>
            </div>
            <div class="user-info">
                <span class="user-name">${sessionScope.fullName != null ? sessionScope.fullName : 'Administrator'}</span>
                <span class="user-role-badge"><i class="bi bi-shield-check"></i> System Admin</span>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn-sidebar-logout" title="Sign out of Admin Console">
                <i class="bi bi-box-arrow-right"></i>
            </a>
        </div>
    </aside>

    <script>
        (function () {
            const sidebar = document.getElementById('sidebar');
            const backdrop = document.getElementById('backdrop');
            const toggleBtn = document.getElementById('toggleBtn');

            function toggleSidebar(open) {
                if (!sidebar || !backdrop)
                    return;
                const isOpen = (typeof open === 'boolean') ? open : !sidebar.classList.contains('open');
                sidebar.classList.toggle('open', isOpen);
                backdrop.classList.toggle('active', isOpen);
                document.body.style.overflow = isOpen ? 'hidden' : '';
            }

            if (toggleBtn) {
                toggleBtn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    toggleSidebar();
                });
            }
            if (backdrop) {
                backdrop.addEventListener('click', () => toggleSidebar(false));
            }

            // Close on escape key
            document.addEventListener('keydown', (e) => {
                if (e.key === 'Escape' && sidebar && sidebar.classList.contains('open')) {
                    toggleSidebar(false);
                }
            });
        })();
    </script>
