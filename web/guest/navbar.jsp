<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<header>
        <nav class="navbar navbar-expand-lg site-navbar" aria-label="Main navigation">
            <div class="container-fluid navbar-container px-3 px-xl-4">
                <!-- Changed gap-2 to gap-3 or gap-4 -->
                <a class="navbar-brand d-flex align-items-center gap-3 text-decoration-none me-3" href="${pageContext.request.contextPath}/guest/dashboard.jsp" aria-label="GRANDSTAY Home">
                    <div class="brand-monogram">
                        <span class="brand-monogram-text">GS</span>
                    </div>
                    <div class="d-flex flex-column">
                        <span class="brand-title">GRANDSTAY</span>
                        <span class="brand-subtitle">Hotel &amp; Residences</span>
                    </div>
                </a>

                <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                        data-bs-target="#customerNavbar" aria-controls="customerNavbar"
                        aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>

<%
    String currentReqUri = (String) request.getAttribute("javax.servlet.forward.request_uri");
    if (currentReqUri == null || currentReqUri.isEmpty()) {
        currentReqUri = (String) request.getAttribute("javax.servlet.include.request_uri");
    }
    if (currentReqUri == null || currentReqUri.isEmpty()) {
        currentReqUri = request.getRequestURI();
    }
    if (currentReqUri == null) currentReqUri = "";
    currentReqUri = currentReqUri.toLowerCase();

    boolean isDashboard = currentReqUri.contains("dashboard");
    boolean isRooms = currentReqUri.contains("room");
    boolean isBookings = currentReqUri.contains("booking");
    boolean isProfile = currentReqUri.contains("profile");
%>

                <div class="collapse navbar-collapse" id="customerNavbar">
                    <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                        <li class="nav-item">
                            <a class="nav-link <%= isDashboard ? "active" : "" %>" id="navDashboard" href="${pageContext.request.contextPath}/guest/dashboard.jsp">
                                <i class="bi bi-grid-1x2"></i> Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link <%= isRooms ? "active" : "" %>" id="navRooms" href="${pageContext.request.contextPath}/guest/room">
                                <i class="bi bi-door-open"></i> Rooms
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link <%= isBookings ? "active" : "" %>" id="navBookings" href="${pageContext.request.contextPath}/guest/my-bookings">
                                <i class="bi bi-calendar2-check"></i> My Bookings
                            </a>
                        </li>
                    </ul>

                    <div class="nav-actions">
                        <a class="profile-link <%= isProfile ? "active" : "" %>" id="navProfile" href="${pageContext.request.contextPath}/profile">
                            <span class="profile-avatar"><i class="bi bi-person-gear"></i></span>
                            <span>Update Profile</span>
                        </a>
                        <form action="${pageContext.request.contextPath}/logout" method="post" class="d-inline m-0">
                            <button class="btn logout-btn" id="logoutButton" type="button" data-bs-toggle="modal" data-bs-target="#logoutConfirmModal">
                                <i class="bi bi-box-arrow-right" aria-hidden="true"></i>
                                <span>Logout</span>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </nav>
    </header>

    <!-- Logout Confirmation Modal -->
    <div class="modal fade" id="logoutConfirmModal" tabindex="-1" aria-labelledby="logoutModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content luxury-modal">
                <div class="modal-body text-center">
                    <div class="modal-status modal-status-warning">
                        <i class="bi bi-box-arrow-right"></i>
                    </div>
                    <span class="modal-eyebrow">Session Management</span>
                    <h4 id="logoutModalLabel" class="modal-title">Confirm Logout</h4>
                    <p class="modal-lead">Are you sure you want to end your session at GrandStay Privé?</p>
                    <div class="modal-actions d-flex justify-content-center gap-3">
                        <button type="button" class="btn-outline-luxury" data-bs-dismiss="modal">
                            Stay Signed In
                        </button>
                        <form action="${pageContext.request.contextPath}/logout" method="post" class="m-0">
                            <button type="submit" class="btn-gold-luxury">
                                Logout Now
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const loc = window.location.pathname.toLowerCase();
            const navDashboard = document.getElementById("navDashboard");
            const navRooms = document.getElementById("navRooms");
            const navBookings = document.getElementById("navBookings");
            const navProfile = document.getElementById("navProfile");

            // Reset all active classes first
            [navDashboard, navRooms, navBookings, navProfile].forEach(el => {
                if (el) {
                    el.classList.remove("active");
                    el.removeAttribute("aria-current");
                }
            });

            if (loc.includes("dashboard")) {
                if (navDashboard) { navDashboard.classList.add("active"); navDashboard.setAttribute("aria-current", "page"); }
            } else if (loc.includes("room")) {
                if (navRooms) { navRooms.classList.add("active"); navRooms.setAttribute("aria-current", "page"); }
            } else if (loc.includes("booking")) {
                if (navBookings) { navBookings.classList.add("active"); navBookings.setAttribute("aria-current", "page"); }
            } else if (loc.includes("profile")) {
                if (navProfile) { navProfile.classList.add("active"); navProfile.setAttribute("aria-current", "page"); }
            } else {
                if (navDashboard) { navDashboard.classList.add("active"); navDashboard.setAttribute("aria-current", "page"); }
            }
        });
    </script>