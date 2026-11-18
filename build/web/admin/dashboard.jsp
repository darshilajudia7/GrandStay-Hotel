<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%
    /* If accessed directly without passing through servlet, forward to AdminDashboardServlet */
    if (request.getAttribute("totalRooms") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Executive Dashboard | GrandStay Admin</title>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/admin/slider.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/admin/room.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/admin/dashboard.css">
    
    <!-- Custom Styles -->
</head>
<body>

    <!-- Sidebar Slider Component -->
    <jsp:include page="slider.jsp" />

    <!-- Main Workspace -->
    <div class="app-main">
        <header class="navbar">
            <div class="nav-left">
                <button class="menu-btn" id="toggleBtn" type="button" aria-label="Open navigation sidebar">
                    <i class="bi bi-list"></i>
                </button>
            </div>

            <div class="nav-right">
                <a href="${pageContext.request.contextPath}/profile" class="nav-btn" title="Update Profile">
                    <i class="bi bi-person-gear"></i>
                    <span>Profile Settings</span>
                </a>

                <a href="${pageContext.request.contextPath}/logout" class="nav-btn logout" title="Sign out of account">
                    <i class="bi bi-box-arrow-right"></i>
                    <span>Logout</span>
                </a>
            </div>
        </header>

        <main>
            <!-- Page Title Bar -->
            <div class="top">
                <div>
                    <h1>Executive Dashboard</h1>
                    <p>Live inventory status and recent reservation records.</p>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/admin/rooms" class="btn primary">
                        <i class="bi bi-door-open"></i> Manage Inventory
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/customers" class="btn">
                        <i class="bi bi-people"></i> Guests Directory
                    </a>
                </div>
            </div>

            <!-- 1. KPI SUMMARY CARDS -->
            <div class="kpi-grid">
                <!-- Total Rooms Card -->
                <div class="kpi-card">
                    <div class="kpi-header">
                        <span class="kpi-title">Total Rooms</span>
                        <div class="kpi-icon"><i class="bi bi-building"></i></div>
                    </div>
                    <div class="kpi-value">${totalRooms != null ? totalRooms : 0}</div>
                    <div class="kpi-footer">
                        <span class="pill-sub avail"><i class="bi bi-check2-circle"></i> ${availableRooms != null ? availableRooms : 0} Avail</span>
                        <span class="pill-sub booked"><i class="bi bi-calendar-check"></i> ${bookedRooms != null ? bookedRooms : 0} Booked</span>
                        <c:if test="${maintenanceRooms > 0}">
                            <span class="pill-sub maint"><i class="bi bi-tools"></i> ${maintenanceRooms} Maint</span>
                        </c:if>
                    </div>
                </div>

                <!-- Bookings Card -->
                <div class="kpi-card success">
                    <div class="kpi-header">
                        <span class="kpi-title">Total Reservations</span>
                        <div class="kpi-icon"><i class="bi bi-calendar-range"></i></div>
                    </div>
                    <div class="kpi-value">${totalBookings != null ? totalBookings : 0}</div>
                    <div class="kpi-footer">
                        <span class="pill-sub avail"><i class="bi bi-check-lg"></i> ${confirmedBookings != null ? confirmedBookings : 0} Confirmed</span>
                        <span class="pill-sub maint"><i class="bi bi-x-lg"></i> ${cancelledBookings != null ? cancelledBookings : 0} Cancelled</span>
                    </div>
                </div>

                <!-- Total Revenue Card -->
                <div class="kpi-card info">
                    <div class="kpi-header">
                        <span class="kpi-title">Confirmed Revenue</span>
                        <div class="kpi-icon"><i class="bi bi-cash-stack"></i></div>
                    </div>
                    <div class="kpi-value">
                        ₹<fmt:formatNumber value="${totalRevenue != null ? totalRevenue : 0}" pattern="#,##0.00" />
                    </div>
                    <div class="kpi-footer">
                        <span><i class="bi bi-shield-check" style="color: var(--gs-success);"></i> Total from confirmed bookings</span>
                    </div>
                </div>

                <!-- Occupancy Rate Card -->
                <div class="kpi-card warning">
                    <div class="kpi-header">
                        <span class="kpi-title">Occupancy Rate</span>
                        <div class="kpi-icon"><i class="bi bi-pie-chart"></i></div>
                    </div>
                    <div class="kpi-value">${occupancyRate != null ? occupancyRate : 0.0}%</div>
                    <div class="kpi-footer">
                        <span>${bookedRooms != null ? bookedRooms : 0} of ${totalRooms != null ? totalRooms : 0} rooms currently occupied</span>
                    </div>
                </div>
            </div>

            <!-- 2. QUICK ACTION SHORTCUTS -->
            <div class="shortcuts-panel">
                <div class="shortcuts-heading">
                    <div class="kpi-icon" style="width: 38px; height: 38px; font-size: 18px;">
                        <i class="bi bi-lightning-charge-fill"></i>
                    </div>
                    <div>
                        <h3>Quick Action Shortcuts</h3>
                        <p>Streamline frequent operational workflows and inventory adjustments.</p>
                    </div>
                </div>
                <div class="shortcuts-btns">
                    <a href="${pageContext.request.contextPath}/admin/rooms" class="action-btn gold">
                        <i class="bi bi-plus-lg"></i> Add New Room
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/customers" class="action-btn">
                        <i class="bi bi-person-lines-fill"></i> Guest Directory
                    </a>
                    <a href="${pageContext.request.contextPath}/guest/room" target="_blank" class="action-btn">
                        <i class="bi bi-eye"></i> Guest Portal View
                    </a>
                </div>
            </div>

            <!-- 3. RECENT BOOKINGS TABLE -->
            <div class="table-panel">
                <div class="table-panel-header">
                    <div class="table-panel-title">
                        <h3>Recent Reservation Records</h3>
                        <p>Latest room bookings received across the property.</p>
                    </div>
                    <div class="table-controls">
                        <div class="search-box">
                            <i class="bi bi-search"></i>
                            <input type="text" id="bookingSearch" placeholder="Search reference, guest, room..." autocomplete="off">
                        </div>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Booking Ref</th>
                                <th>Guest Details</th>
                                <th>Room Assigned</th>
                                <th>Stay Dates</th>
                                <th>Total Amount</th>
                                <th>Status</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody id="recentBookingsBody">
                            <c:choose>
                                <c:when test="${not empty recentBookings}">
                                    <c:forEach var="b" items="${recentBookings}">
                                        <tr>
                                            <td>
                                                <span class="badge-ref">${b.bookingReference}</span>
                                            </td>
                                            <td>
                                                <div class="guest-cell">
                                                    <div class="guest-avatar">
                                                        ${fn:toUpperCase(fn:substring(b.guestName, 0, 1))}
                                                    </div>
                                                    <div>
                                                        <div style="font-weight: 600; color: #ffffff;">${b.guestName}</div>
                                                        <div style="font-size: 11.5px; color: var(--text-muted);">${b.guestEmail} &bull; ${b.guestPhone}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <div style="font-weight: 600;">Room ${b.roomNumber}</div>
                                                <div style="font-size: 11.5px; color: var(--gold-light);">${b.roomTitle} (${b.typeName})</div>
                                            </td>
                                            <td>
                                                <div><fmt:formatDate value="${b.checkIn}" pattern="MMM dd, yyyy" /> &rarr; <fmt:formatDate value="${b.checkOut}" pattern="MMM dd, yyyy" /></div>
                                                <div style="font-size: 11.5px; color: var(--text-muted);">${b.nights} night(s) &bull; ${b.guestsCount} guest(s)</div>
                                            </td>
                                            <td>
                                                <div style="font-weight: 700; color: #ffffff;">
                                                    ₹<fmt:formatNumber value="${b.totalPrice}" pattern="#,##0.00" />
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${b.bookingStatus == 'CONFIRMED'}">
                                                        <span class="status-badge confirmed">
                                                            <i class="bi bi-check-circle-fill"></i> Confirmed
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-badge cancelled">
                                                            <i class="bi bi-x-circle-fill"></i> Cancelled
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: right;">
                                                <button type="button" class="btn" style="padding: 6px 12px; font-size: 12px;"
                                                        data-ref="${b.bookingReference}"
                                                        data-guest="${b.guestName}"
                                                        data-email="${b.guestEmail}"
                                                        data-phone="${b.guestPhone}"
                                                        data-room="Room ${b.roomNumber} - ${b.roomTitle}"
                                                        data-roomtype="${b.typeName}"
                                                        data-in="${b.checkIn}"
                                                        data-out="${b.checkOut}"
                                                        data-nights="${b.nights}"
                                                        data-count="${b.guestsCount}"
                                                        data-price="${b.totalPrice}"
                                                        data-status="${b.bookingStatus}"
                                                        data-reason="${b.cancellationReason}"
                                                        onclick="openBookingDetails(this)">
                                                    <i class="bi bi-info-circle"></i> Details
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" style="text-align: center; padding: 40px; color: var(--text-muted);">
                                            <i class="bi bi-calendar-x" style="font-size: 32px; display: block; margin-bottom: 10px; color: var(--gold-muted);"></i>
                                            No reservation records found. New guest bookings will appear here automatically.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <!-- Booking Details Modal -->
    <div class="modal-overlay" id="bookingModal">
        <div class="modal-box">
            <div class="modal-header">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <h3 style="font-size: 18px; margin: 0;">Reservation Details</h3>
                        <span id="mbStatus" class="status-badge confirmed" style="font-size: 11px;">CONFIRMED</span>
                    </div>
                    <p style="font-size: 12px; color: var(--text-muted); margin: 3px 0 0 0;" id="mbRef">—</p>
                </div>
                <button type="button" class="modal-close-btn" id="closeBookingModal">&times;</button>
            </div>
            <div class="modal-body">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px;">
                    <div>
                        <span style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block;">Guest Name</span>
                        <b id="mbGuest" style="font-size: 14px; color: #ffffff;">—</b>
                    </div>
                    <div>
                        <span style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block;">Contact Email</span>
                        <span id="mbEmail" style="font-size: 13.5px; color: var(--text-main);">—</span>
                    </div>
                    <div>
                        <span style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block;">Phone Number</span>
                        <span id="mbPhone" style="font-size: 13.5px; color: var(--text-main);">—</span>
                    </div>
                    <div>
                        <span style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block;">Total Paid</span>
                        <b id="mbTotal" style="font-size: 16px; color: var(--gold-light);">—</b>
                    </div>
                </div>

                <div style="background: var(--bg-surface-elevated); border: 1px solid var(--border-subtle); border-radius: var(--radius-sm); padding: 14px; margin-bottom: 16px;">
                    <div style="margin-bottom: 8px;">
                        <span style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block;">Assigned Room</span>
                        <span id="mbRoom" style="font-weight: 600; color: #ffffff;">—</span>
                    </div>
                    <div style="margin-bottom: 8px;">
                        <span style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block;">Stay Dates</span>
                        <span id="mbDates" style="color: var(--text-main);">—</span>
                    </div>
                    <div>
                        <span style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block;">Guests Count</span>
                        <span id="mbGuests" style="color: var(--text-main);">—</span>
                    </div>
                </div>

                <div id="mbReasonRow" style="display: none; background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.3); border-radius: var(--radius-sm); padding: 12px; margin-bottom: 16px;">
                    <span style="font-size: 11px; text-transform: uppercase; color: #fca5a5; display: block; font-weight: 600;">Cancellation Reason</span>
                    <span id="mbReason" style="font-size: 13px; color: #ffffff;">—</span>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px;">
                    <button type="button" class="btn primary" onclick="document.getElementById('bookingModal').classList.remove('open')">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Dashboard JavaScript -->
    <script src="${pageContext.request.contextPath}/JS/admin/dashboard.js"></script>

</body>
</html>

