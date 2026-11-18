<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, java.math.BigDecimal, AuthServlet.DBconnection" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    /* Ensure authenticated user session */
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null && session.getAttribute("registration_id") != null) {
        try {
            userId = Integer.valueOf(session.getAttribute("registration_id").toString());
        } catch (Exception ignored) {}
    }
    String userEmail = (String) session.getAttribute("userEmail");
    if (userId == null && (userEmail == null || userEmail.trim().isEmpty())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String userName = (String) session.getAttribute("fullName");
    String userPhone = (String) session.getAttribute("phone");
    String userAddress = (String) session.getAttribute("address");

    int totalBookingsCount = 0;
    int confirmedBookingsCount = 0;
    int cancelledBookingsCount = 0;
    BigDecimal totalSpent = BigDecimal.ZERO;
    List<Map<String, Object>> recentBookings = new ArrayList<>();

    /* Query live user data & personal booking metrics from database */
    if (userId != null || (userEmail != null && !userEmail.trim().isEmpty())) {
        try (Connection conn = DBconnection.getConnection()) {
            if (conn != null) {
                /* 1. Fetch fresh user profile if needed */
                String userSql = (userId != null)
                    ? "SELECT full_name, email, phone, address FROM registration WHERE registration_id = ?"
                    : "SELECT full_name, email, phone, address FROM registration WHERE LOWER(email) = ?";
                try (PreparedStatement psUser = conn.prepareStatement(userSql)) {
                    if (userId != null) {
                        psUser.setInt(1, userId);
                    } else {
                        psUser.setString(1, userEmail.trim().toLowerCase());
                    }
                    try (ResultSet rsUser = psUser.executeQuery()) {
                        if (rsUser.next()) {
                            userName = rsUser.getString("full_name");
                            userEmail = rsUser.getString("email");
                            userPhone = rsUser.getString("phone");
                            userAddress = rsUser.getString("address");
                            session.setAttribute("fullName", userName);
                            session.setAttribute("userEmail", userEmail);
                            session.setAttribute("phone", userPhone);
                            session.setAttribute("address", userAddress);
                        }
                    }
                }

                /* 2. Fetch user's bookings and statistics */
                String bookSql = "SELECT b.id, b.booking_reference, b.check_in, b.check_out, b.guests_count, "
                    + "b.total_price, b.booking_status, b.created_at, "
                    + "r.room_number, r.title AS room_title, "
                    + "COALESCE(rt.name, 'Suite') AS category_name "
                    + "FROM bookings b "
                    + "JOIN rooms r ON b.room_id = r.id "
                    + "LEFT JOIN room_types rt ON r.room_type_id = rt.id "
                    + "WHERE LOWER(b.guest_email) = LOWER(?) "
                    + "ORDER BY b.created_at DESC";

                try (PreparedStatement psBook = conn.prepareStatement(bookSql)) {
                    psBook.setString(1, userEmail != null ? userEmail.trim() : "");
                    try (ResultSet rsBook = psBook.executeQuery()) {
                        while (rsBook.next()) {
                            totalBookingsCount++;
                            String status = rsBook.getString("booking_status");
                            BigDecimal price = rsBook.getBigDecimal("total_price");
                            if (price == null) {
                                price = BigDecimal.ZERO;
                            }

                            if ("CANCELLED".equalsIgnoreCase(status)) {
                                cancelledBookingsCount++;
                            } else {
                                confirmedBookingsCount++;
                                totalSpent = totalSpent.add(price);
                            }

                            if (recentBookings.size() < 5) {
                                Map<String, Object> bm = new HashMap<>();
                                bm.put("id", rsBook.getInt("id"));
                                bm.put("bookingReference", rsBook.getString("booking_reference"));
                                bm.put("roomTitle", rsBook.getString("room_title"));
                                bm.put("roomNumber", rsBook.getString("room_number"));
                                bm.put("categoryName", rsBook.getString("category_name"));
                                bm.put("checkIn", rsBook.getDate("check_in"));
                                bm.put("checkOut", rsBook.getDate("check_out"));
                                bm.put("guestsCount", rsBook.getInt("guests_count"));
                                bm.put("totalPrice", price);
                                bm.put("status", status != null ? status : "CONFIRMED");
                                bm.put("createdAt", rsBook.getTimestamp("created_at"));
                                recentBookings.add(bm);
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            /* Ignore database query errors gracefully for dashboard display */
        }
    }

    request.setAttribute("recentBookings", recentBookings);
    request.setAttribute("totalBookingsCount", totalBookingsCount);
    request.setAttribute("confirmedBookingsCount", confirmedBookingsCount);
    request.setAttribute("cancelledBookingsCount", cancelledBookingsCount);
    request.setAttribute("totalSpent", totalSpent);
    request.setAttribute("userFullName", userName);
    request.setAttribute("userEmail", userEmail);
    request.setAttribute("userPhone", userPhone);
    request.setAttribute("userAddress", userAddress);
    request.setAttribute("userId", userId);
%>

                                    <!DOCTYPE html>
                                    <html lang="en">

                                    <head>
                                        <meta charset="UTF-8">
                                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                        <title>GrandStay Privé | Member Dashboard</title>

                                        <!-- Google Fonts -->
                                        <link rel="preconnect" href="https://fonts.googleapis.com">
                                        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                                        <link
                                            href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&family=Playfair+Display:ital,wght@0,600;0,700;1,400&display=swap"
                                            rel="stylesheet">

                                        <!-- Bootstrap & Icons -->
                                        <link
                                            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                                            rel="stylesheet">
                                        <link
                                            href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
                                            rel="stylesheet">

                                        <!-- Stylesheets -->
                                        <link rel="stylesheet"
                                            href="${pageContext.request.contextPath}/CSS/guest/navbar.css">
                                        <link rel="stylesheet"
                                            href="${pageContext.request.contextPath}/CSS/guest/rooms.css">
                                        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/modal.css">

                                        <style>
                                            :root {
                                                --gold-primary: #c5a059;
                                                --gold-light: #e6cb8b;
                                                --gold-dark: #9b7a37;
                                            }

                                            body {
                                                background-color: #0b0e14;
                                                color: #e2e8f0;
                                                font-family: 'Montserrat', sans-serif;
                                                min-height: 100vh;
                                            }

                                            .dashboard-hero {
                                                padding: 3rem 1.5rem 2.25rem;
                                                text-align: center;
                                                background: radial-gradient(circle at 50% 20%, rgba(197, 160, 89, 0.12) 0%, transparent 70%);
                                                border-bottom: 1px solid rgba(197, 160, 89, 0.2);
                                            }

                                            .dashboard-hero h1 {
                                                font-family: 'Playfair Display', serif;
                                                font-size: clamp(2rem, 3.8vw, 2.85rem);
                                                color: #ffffff;
                                                margin-top: 0.5rem;
                                                margin-bottom: 0.5rem;
                                            }

                                            .dashboard-hero p {
                                                color: #94a3b8;
                                                font-size: 0.95rem;
                                                max-width: 620px;
                                                margin: 0 auto;
                                                line-height: 1.6;
                                            }

                                            .dashboard-container {
                                                max-width: 1250px;
                                                margin: 2.25rem auto 5rem;
                                                padding: 0 1.5rem;
                                            }

                                            /* Stats Bar */
                                            .stats-grid {
                                                display: grid;
                                                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                                                gap: 1.25rem;
                                                margin-bottom: 2.5rem;
                                            }

                                            .stat-card {
                                                background: linear-gradient(145deg, #161a24 0%, #0e1118 100%);
                                                border: 1px solid rgba(197, 160, 89, 0.25);
                                                border-radius: 14px;
                                                padding: 1.4rem;
                                                display: flex;
                                                align-items: center;
                                                gap: 1.15rem;
                                                box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
                                                transition: transform 0.25s ease, border-color 0.25s ease;
                                            }

                                            .stat-card:hover {
                                                transform: translateY(-3px);
                                                border-color: rgba(197, 160, 89, 0.5);
                                            }

                                            .stat-icon {
                                                width: 52px;
                                                height: 52px;
                                                border-radius: 12px;
                                                background: rgba(197, 160, 89, 0.12);
                                                border: 1px solid rgba(197, 160, 89, 0.3);
                                                display: flex;
                                                align-items: center;
                                                justify-content: center;
                                                font-size: 1.5rem;
                                                color: var(--gold-light);
                                            }

                                            .stat-info .stat-label {
                                                font-size: 0.72rem;
                                                color: #94a3b8;
                                                text-transform: uppercase;
                                                letter-spacing: 0.05em;
                                                margin-bottom: 0.2rem;
                                            }

                                            .stat-info .stat-val {
                                                font-size: 1.2rem;
                                                font-weight: 700;
                                                color: #ffffff;
                                            }

                                            /* User Profile & Actions Two-Column Grid */
                                            .user-overview-grid {
                                                display: grid;
                                                grid-template-columns: 1fr 1.6fr;
                                                gap: 1.75rem;
                                                margin-bottom: 2.75rem;
                                            }

                                            @media (max-width: 991.98px) {
                                                .user-overview-grid {
                                                    grid-template-columns: 1fr;
                                                }
                                            }

                                            .user-profile-card {
                                                background: linear-gradient(145deg, #181d28 0%, #10141d 100%);
                                                border: 1px solid rgba(197, 160, 89, 0.28);
                                                border-radius: 16px;
                                                padding: 1.75rem;
                                                position: relative;
                                                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
                                            }

                                            .user-profile-card::before {
                                                content: "";
                                                position: absolute;
                                                top: 0;
                                                left: 0;
                                                right: 0;
                                                height: 3px;
                                                background: linear-gradient(90deg, transparent, var(--gold-primary), transparent);
                                            }

                                            .user-badge-header {
                                                display: flex;
                                                align-items: center;
                                                gap: 1rem;
                                                margin-bottom: 1.5rem;
                                                padding-bottom: 1.25rem;
                                                border-bottom: 1px solid rgba(255, 255, 255, 0.08);
                                            }

                                            .user-avatar-circle {
                                                width: 60px;
                                                height: 60px;
                                                border-radius: 50%;
                                                background: linear-gradient(135deg, #2a1f0a 0%, #171b26 100%);
                                                border: 2px solid var(--gold-primary);
                                                display: flex;
                                                align-items: center;
                                                justify-content: center;
                                                font-size: 1.75rem;
                                                color: var(--gold-light);
                                            }

                                            .user-record-list {
                                                display: flex;
                                                flex-direction: column;
                                                gap: 1rem;
                                            }

                                            .user-record-item {
                                                display: flex;
                                                align-items: flex-start;
                                                gap: 0.85rem;
                                                font-size: 0.88rem;
                                            }

                                            .user-record-item i {
                                                color: var(--gold-primary);
                                                font-size: 1.1rem;
                                                margin-top: 2px;
                                            }

                                            .user-record-label {
                                                font-size: 0.72rem;
                                                color: #94a3b8;
                                                text-transform: uppercase;
                                                letter-spacing: 0.05em;
                                                display: block;
                                            }

                                            .user-record-value {
                                                color: #f1f5f9;
                                                font-weight: 500;
                                                word-break: break-word;
                                            }

                                            /* Quick Actions Card */
                                            .quick-actions-card {
                                                background: linear-gradient(145deg, #181d28 0%, #10141d 100%);
                                                border: 1px solid rgba(197, 160, 89, 0.28);
                                                border-radius: 16px;
                                                padding: 1.75rem;
                                                display: flex;
                                                flex-direction: column;
                                                justify-content: space-between;
                                                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
                                            }

                                            .quick-action-item {
                                                display: flex;
                                                align-items: center;
                                                justify-content: space-between;
                                                padding: 1.1rem 1.25rem;
                                                background: rgba(255, 255, 255, 0.03);
                                                border: 1px solid rgba(197, 160, 89, 0.18);
                                                border-radius: 12px;
                                                color: #f1f5f9;
                                                text-decoration: none;
                                                margin-bottom: 0.9rem;
                                                transition: all 0.25s ease;
                                            }

                                            .quick-action-item:hover {
                                                background: rgba(197, 160, 89, 0.12);
                                                border-color: rgba(197, 160, 89, 0.5);
                                                color: #ffffff;
                                                transform: translateX(4px);
                                            }

                                            .quick-action-content {
                                                display: flex;
                                                align-items: center;
                                                gap: 1rem;
                                            }

                                            .quick-action-icon {
                                                width: 44px;
                                                height: 44px;
                                                border-radius: 10px;
                                                background: rgba(197, 160, 89, 0.15);
                                                display: flex;
                                                align-items: center;
                                                justify-content: center;
                                                font-size: 1.25rem;
                                                color: var(--gold-light);
                                            }

                                            /* Recent Bookings Table Section */
                                            .user-bookings-section {
                                                background: linear-gradient(145deg, #181d28 0%, #10141d 100%);
                                                border: 1px solid rgba(197, 160, 89, 0.28);
                                                border-radius: 16px;
                                                padding: 1.75rem;
                                                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
                                            }

                                            .table-luxury {
                                                width: 100%;
                                                border-collapse: separate;
                                                border-spacing: 0 0.5rem;
                                            }

                                            .table-luxury thead th {
                                                color: #94a3b8;
                                                font-size: 0.75rem;
                                                text-transform: uppercase;
                                                letter-spacing: 0.06em;
                                                font-weight: 600;
                                                padding: 0.75rem 1rem;
                                                border: none;
                                            }

                                            .table-luxury tbody tr {
                                                background: rgba(255, 255, 255, 0.02);
                                                transition: background 0.2s ease;
                                            }

                                            .table-luxury tbody tr:hover {
                                                background: rgba(197, 160, 89, 0.07);
                                            }

                                            .table-luxury tbody td {
                                                padding: 1rem;
                                                border-top: 1px solid rgba(197, 160, 89, 0.18);
                                                border-bottom: 1px solid rgba(197, 160, 89, 0.18);
                                                vertical-align: middle;
                                                font-size: 0.88rem;
                                            }

                                            .table-luxury tr td:first-child {
                                                border-left: 1px solid rgba(197, 160, 89, 0.18);
                                                border-top-left-radius: 10px;
                                                border-bottom-left-radius: 10px;
                                            }

                                            .table-luxury tr td:last-child {
                                                border-right: 1px solid rgba(197, 160, 89, 0.18);
                                                border-top-right-radius: 10px;
                                                border-bottom-right-radius: 10px;
                                            }

                                            .status-pill-mini {
                                                display: inline-block;
                                                padding: 0.25rem 0.65rem;
                                                border-radius: 12px;
                                                font-size: 0.7rem;
                                                font-weight: 700;
                                                letter-spacing: 0.05em;
                                                text-transform: uppercase;
                                            }

                                            .status-pill-confirmed {
                                                background: rgba(16, 185, 129, 0.15);
                                                border: 1px solid #10b981;
                                                color: #6ee7b7;
                                            }

                                            .status-pill-cancelled {
                                                background: rgba(239, 68, 68, 0.15);
                                                border: 1px solid #ef4444;
                                                color: #fca5a5;
                                            }
                                        </style>
                                    </head>

                                    <body>
                                        <!-- Header / Navbar -->
                                        <jsp:include page="navbar.jsp" />

                                        <!-- Dashboard Hero -->
                                        <header class="dashboard-hero">
                                            <span class="modal-eyebrow"><i class="bi bi-gem"></i> MEMBER ACCESS PORTAL</span>
                                            <h1>
                                                Welcome back,
                                                <span style="color: var(--gold-light);">
                                                    <c:out value="${not empty userFullName ? userFullName : 'Valued Member'}" />
                                                </span>
                                            </h1>
                                            <p>Review your personal membership profile, track your reservation history,
                                                and manage your accommodation itineraries seamlessly.</p>
                                        </header>

                                        <main class="dashboard-container">

                                            <!-- Personal User Metrics / Stats Bar -->
                                            <div class="stats-grid">
                                                <div class="stat-card">
                                                    <div class="stat-icon"><i class="bi bi-calendar-check"></i></div>
                                                    <div class="stat-info">
                                                        <div class="stat-label">Confirmed Stays</div>
                                                        <div class="stat-val">
                                                            <c:out value="${confirmedBookingsCount}" /> Stay(s)
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="stat-card">
                                                    <div class="stat-icon"><i class="bi bi-calendar-x"></i></div>
                                                    <div class="stat-info">
                                                        <div class="stat-label">Cancelled Stays</div>
                                                        <div class="stat-val">
                                                            <c:out value="${cancelledBookingsCount}" /> Stay(s)
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="stat-card">
                                                    <div class="stat-icon"><i class="bi bi-journal-bookmark"></i></div>
                                                    <div class="stat-info">
                                                        <div class="stat-label">Total Bookings</div>
                                                        <div class="stat-val">
                                                            <c:out value="${totalBookingsCount}" /> Reservation(s)
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="stat-card">
                                                    <div class="stat-icon"><i class="bi bi-cash-stack"></i></div>
                                                    <div class="stat-info">
                                                        <div class="stat-label">Total Spend (Active)</div>
                                                        <div class="stat-val">₹<fmt:formatNumber value="${totalSpent}" pattern="#,##0.00" />
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Two-Column Section: Personal Profile Details & Quick Actions -->
                                            <div class="user-overview-grid">
                                                <!-- User Profile Card -->
                                                <div class="user-profile-card">
                                                    <div class="user-badge-header">
                                                        <div class="user-avatar-circle">
                                                            <i class="bi bi-person-fill"></i>
                                                        </div>
                                                        <div>
                                                            <span class="modal-eyebrow m-0">VERIFIED PROFILE</span>
                                                            <h4 class="text-white m-0"
                                                                style="font-family: 'Playfair Display', serif; font-size: 1.35rem;">
                                                                <c:out value="${not empty userFullName ? userFullName : 'Guest Member'}" />
                                                            </h4>
                                                            <span class="badge bg-gold-badge text-gold mt-1"
                                                                style="font-size: 0.72rem; letter-spacing: 0.05em;">
                                                                <i class="bi bi-shield-check"></i> Privé Club Member
                                                            </span>
                                                        </div>
                                                    </div>

                                                    <div class="user-record-list">
                                                        <div class="user-record-item">
                                                            <i class="bi bi-envelope"></i>
                                                            <div>
                                                                <span class="user-record-label">Registered Email</span>
                                                                <span class="user-record-value">
                                                                    <c:out value="${not empty userEmail ? userEmail : 'Not available'}" />
                                                                </span>
                                                            </div>
                                                        </div>

                                                        <div class="user-record-item">
                                                            <i class="bi bi-telephone"></i>
                                                            <div>
                                                                <span class="user-record-label">Contact Mobile</span>
                                                                <span class="user-record-value">
                                                                    <c:out value="${not empty userPhone ? userPhone : 'No phone number added'}" />
                                                                </span>
                                                            </div>
                                                        </div>

                                                        <div class="user-record-item">
                                                            <i class="bi bi-geo-alt"></i>
                                                            <div>
                                                                <span class="user-record-label">Mailing / Billing Address</span>
                                                                <span class="user-record-value">
                                                                    <c:out value="${not empty userAddress ? userAddress : 'No address specified on profile'}" />
                                                                </span>
                                                            </div>
                                                        </div>

                                                        <div class="user-record-item">
                                                            <i class="bi bi-person-badge"></i>
                                                            <div>
                                                                <span class="user-record-label">Member ID</span>
                                                                <span class="user-record-value text-gold">GS-MEM-<c:out value="${not empty userId ? userId : 'GUEST'}" /></span>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="mt-4 pt-2">
                                                        <a href="${pageContext.request.contextPath}/profile"
                                                            class="btn btn-outline-luxury w-100 py-2 d-flex align-items-center justify-content-center gap-2">
                                                            <i class="bi bi-pencil-square"></i> Edit Profile Information
                                                        </a>
                                                    </div>
                                                </div>

                                                <!-- User Action Hub -->
                                                <div class="quick-actions-card">
                                                    <div>
                                                        <span class="modal-eyebrow">SERVICES &amp; NAVIGATION</span>
                                                        <h3 class="text-white mb-3"
                                                            style="font-family: 'Playfair Display', serif; font-size: 1.45rem;">
                                                            Your Accommodation Hub
                                                        </h3>

                                                        <a href="${pageContext.request.contextPath}/guest/room"
                                                            class="quick-action-item">
                                                            <div class="quick-action-content">
                                                                <div class="quick-action-icon"><i
                                                                        class="bi bi-door-open"></i></div>
                                                                <div>
                                                                    <div class="fw-bold text-white">Reserve
                                                                        Accommodations</div>
                                                                    <div style="font-size: 0.78rem; color: #94a3b8;">
                                                                        Browse live available rooms and book with your
                                                                        verified profile.</div>
                                                                </div>
                                                            </div>
                                                            <i class="bi bi-arrow-right text-gold fs-5"></i>
                                                        </a>

                                                        <a href="${pageContext.request.contextPath}/guest/my-bookings"
                                                            class="quick-action-item">
                                                            <div class="quick-action-content">
                                                                <div class="quick-action-icon"><i
                                                                        class="bi bi-calendar2-check"></i></div>
                                                                <div>
                                                                    <div class="fw-bold text-white">Manage My Bookings
                                                                    </div>
                                                                    <div style="font-size: 0.78rem; color: #94a3b8;">
                                                                        Review your active stays, cancellation reasons,
                                                                        and detailed itineraries.</div>
                                                                </div>
                                                            </div>
                                                            <i class="bi bi-arrow-right text-gold fs-5"></i>
                                                        </a>

                                                        <a href="${pageContext.request.contextPath}/profile"
                                                            class="quick-action-item">
                                                            <div class="quick-action-content">
                                                                <div class="quick-action-icon"><i
                                                                        class="bi bi-shield-lock"></i></div>
                                                                <div>
                                                                    <div class="fw-bold text-white">Account Security
                                                                        &amp; Credentials</div>
                                                                    <div style="font-size: 0.78rem; color: #94a3b8;">
                                                                        Update your account password and security
                                                                        configuration.</div>
                                                                </div>
                                                            </div>
                                                            <i class="bi bi-arrow-right text-gold fs-5"></i>
                                                        </a>
                                                    </div>

                                                    <div class="p-3 rounded mt-3"
                                                        style="background: rgba(197, 160, 89, 0.08); border: 1px dashed rgba(197, 160, 89, 0.3);">
                                                        <div class="d-flex align-items-center gap-2">
                                                            <i class="bi bi-info-circle-fill text-gold fs-5"></i>
                                                            <span class="small" style="color: #cbd5e1;">All reservations
                                                                made under this account automatically link to your email
                                                                and are viewable in the <strong>My Bookings</strong>
                                                                section.</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Recent Personal Bookings Table -->
                                            <div class="user-bookings-section">
                                                <div
                                                    class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                                                    <div>
                                                        <span class="modal-eyebrow m-0">RESERVATION OVERVIEW</span>
                                                        <h3 class="text-white m-0"
                                                            style="font-family: 'Playfair Display', serif; font-size: 1.45rem;">
                                                            Your Recent Bookings
                                                        </h3>
                                                    </div>
                                                    <a href="${pageContext.request.contextPath}/guest/my-bookings"
                                                        class="btn btn-outline-luxury btn-sm px-3 py-1">
                                                        View All Bookings <i class="bi bi-arrow-right ms-1"></i>
                                                    </a>
                                                </div>

                                                <c:choose>
                                                    <c:when test="${empty recentBookings}">
                                                        <div class="text-center py-5">
                                                            <i class="bi bi-calendar-x fs-1 text-gold"></i>
                                                            <h4 class="mt-3 text-white">No Stays Reserved Yet</h4>
                                                            <p style="color: #94a3b8; font-size: 0.9rem;">You have not
                                                                placed any room reservations under this account yet.</p>
                                                            <a href="${pageContext.request.contextPath}/guest/room"
                                                                class="btn btn-gold-luxury mt-2">
                                                                <i class="bi bi-door-open me-2"></i> Book Your First Suite
                                                            </a>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="table-responsive">
                                                            <table class="table-luxury">
                                                                <thead>
                                                                    <tr>
                                                                        <th>Booking Ref</th>
                                                                        <th>Accommodations</th>
                                                                        <th>Check-In</th>
                                                                        <th>Check-Out</th>
                                                                        <th>Guests</th>
                                                                        <th>Total Cost</th>
                                                                        <th>Status</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                    <c:forEach var="b" items="${recentBookings}">
                                                                        <tr>
                                                                            <td>
                                                                                <span class="booking-ref-badge">
                                                                                    <c:out value="${b.bookingReference}" />
                                                                                </span>
                                                                            </td>
                                                                            <td>
                                                                                <div class="fw-bold text-white">
                                                                                    <c:out value="${b.roomTitle}" />
                                                                                </div>
                                                                                <div style="font-size: 0.75rem; color: #94a3b8;">
                                                                                    Room <c:out value="${b.roomNumber}" /> • <c:out value="${b.categoryName}" />
                                                                                </div>
                                                                            </td>
                                                                            <td>
                                                                                <fmt:formatDate value="${b.checkIn}" pattern="dd MMM yyyy" />
                                                                            </td>
                                                                            <td>
                                                                                <fmt:formatDate value="${b.checkOut}" pattern="dd MMM yyyy" />
                                                                            </td>
                                                                            <td>
                                                                                <c:out value="${b.guestsCount}" /> Guest(s)
                                                                            </td>
                                                                            <td class="text-gold fw-bold">
                                                                                ₹<fmt:formatNumber value="${b.totalPrice}" pattern="#,##0.00" />
                                                                            </td>
                                                                            <td>
                                                                                <span class="status-pill-mini ${b.status eq 'CANCELLED' ? 'status-pill-cancelled' : 'status-pill-confirmed'}">
                                                                                    <c:out value="${b.status}" />
                                                                                </span>
                                                                            </td>
                                                                        </tr>
                                                                    </c:forEach>
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                        </main>

                                        <!-- Footer -->
                                        <footer class="site-footer">
                                            <a class="footer-brand" href="#">GRANDSTAY<span>HOTEL &amp;
                                                    RESIDENCES</span></a>
                                            <small class="d-block mt-2" style="color: #94a3b8;">&copy; <%=
                                                    java.time.Year.now().getValue() %> GrandStay Hotel. All rights
                                                    reserved.</small>
                                        </footer>

                                        <!-- Bootstrap JS Bundle -->
                                        <script
                                            src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                                    </body>

                                    </html>