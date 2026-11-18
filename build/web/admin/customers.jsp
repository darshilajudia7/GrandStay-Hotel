<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%
    /* If accessed directly without passing through servlet, forward to AdminCustomerServlet */
    if (request.getAttribute("customers") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/customers");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Customer Directory | GrandStay Admin</title>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/admin/slider.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/admin/room.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/admin/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/admin/customers.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/modal.css">
</head>
<body data-context="${pageContext.request.contextPath}">

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
                    <h1>Registered Guest Directory</h1>
                    <p>Manage customer profiles, verify reservation records, and configure account access status.</p>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn">
                        <i class="bi bi-speedometer2"></i> Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/rooms" class="btn primary">
                        <i class="bi bi-door-open"></i> Manage Inventory
                    </a>
                </div>
            </div>

            <!-- Toast Flash Message -->
            <c:if test="${not empty sessionScope.toastMsg}">
                <div style="background: rgba(197, 160, 89, 0.15); border: 1px solid var(--gold-primary); color: var(--gold-light); padding: 12px 18px; border-radius: var(--radius-sm); margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between;">
                    <div><i class="bi bi-info-circle-fill" style="margin-right: 8px;"></i> ${sessionScope.toastMsg}</div>
                    <button type="button" onclick="this.parentElement.remove()" style="background:none; border:none; color:inherit; cursor:pointer;">&times;</button>
                </div>
                <c:remove var="toastMsg" scope="session" />
            </c:if>

            <!-- Metrics Summary Row -->
            <div class="customer-stats-grid">
                <div class="cstat-card">
                    <div class="cstat-icon"><i class="bi bi-people-fill"></i></div>
                    <div class="cstat-info">
                        <b>${totalCustomers != null ? totalCustomers : 0}</b>
                        <span>Total Registered</span>
                    </div>
                </div>

                <div class="cstat-card">
                    <div class="cstat-icon active"><i class="bi bi-person-check-fill"></i></div>
                    <div class="cstat-info">
                        <b>${activeCustomers != null ? activeCustomers : 0}</b>
                        <span>Active Accounts</span>
                    </div>
                </div>

                <div class="cstat-card">
                    <div class="cstat-icon blocked"><i class="bi bi-person-x-fill"></i></div>
                    <div class="cstat-info">
                        <b>${blockedCustomers != null ? blockedCustomers : 0}</b>
                        <span>Blocked Accounts</span>
                    </div>
                </div>

                <div class="cstat-card">
                    <div class="cstat-icon"><i class="bi bi-calendar2-heart-fill"></i></div>
                    <div class="cstat-info">
                        <b>${withBookingsCount != null ? withBookingsCount : 0}</b>
                        <span>With Bookings</span>
                    </div>
                </div>
            </div>

            <!-- Directory Toolbar: Search & Filter Tabs -->
            <div class="directory-toolbar">
                <div class="search-box" style="min-width: 300px; flex: 1; max-width: 440px;">
                    <i class="bi bi-search"></i>
                    <input type="text" id="customerSearch" placeholder="Search by name, email, or phone..." autocomplete="off">
                </div>

                <div class="filter-pills">
                    <button type="button" class="filter-btn active" data-filter="all">
                        All <span class="filter-badge">${totalCustomers != null ? totalCustomers : 0}</span>
                    </button>
                    <button type="button" class="filter-btn" data-filter="active">
                        <i class="bi bi-check-circle" style="color:#10b981;"></i> Active <span class="filter-badge">${activeCustomers != null ? activeCustomers : 0}</span>
                    </button>
                    <button type="button" class="filter-btn" data-filter="blocked">
                        <i class="bi bi-slash-circle" style="color:#ef4444;"></i> Blocked <span class="filter-badge">${blockedCustomers != null ? blockedCustomers : 0}</span>
                    </button>
                    <button type="button" class="filter-btn" data-filter="with-bookings">
                        <i class="bi bi-bookmark-check" style="color:var(--gold-light);"></i> With Bookings <span class="filter-badge">${withBookingsCount != null ? withBookingsCount : 0}</span>
                    </button>
                </div>
            </div>

            <!-- Customer Directory Table -->
            <div class="customer-table-container">
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Guest Info</th>
                                <th>Contact Information</th>
                                <th>Address / City</th>
                                <th>Bookings</th>
                                <th>Status</th>
                                <th style="text-align: right;">Access Control</th>
                            </tr>
                        </thead>
                        <tbody id="customerTableBody">
                            <c:choose>
                                <c:when test="${not empty customers}">
                                    <c:forEach var="c" items="${customers}">
                                        <tr data-id="${c.id}"
                                            data-name="${fn:escapeXml(c.fullName)}"
                                            data-email="${fn:escapeXml(c.email)}"
                                            data-phone="${fn:escapeXml(c.phone)}"
                                            data-address="${fn:escapeXml(c.address)}"
                                            data-role="${fn:escapeXml(c.role)}"
                                            data-status="${c.status}"
                                            data-block-reason="${fn:escapeXml(c.blockReason)}"
                                            data-bookings="${c.bookingCount}"
                                            data-total-spent="${c.totalSpent}"
                                            data-joined="<fmt:formatDate value='${c.createdAt}' pattern='MMM dd, yyyy' />">
                                            <td>
                                                <div class="guest-info-block">
                                                    <div class="guest-avatar-monogram">
                                                        ${fn:toUpperCase(fn:substring(c.fullName, 0, 1))}
                                                    </div>
                                                    <div>
                                                        <div class="guest-meta-name">${c.fullName}</div>
                                                        <div class="guest-meta-email">User #${c.id}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <div style="color: #ffffff;"><i class="bi bi-envelope" style="color: var(--text-muted); margin-right: 6px;"></i>${c.email}</div>
                                                <div style="font-size: 12px; margin-top: 3px; color: var(--gold-light);"><i class="bi bi-telephone" style="color: var(--text-muted); margin-right: 6px;"></i>${not empty c.phone ? c.phone : '—'}</div>
                                            </td>
                                            <td>
                                                <div style="font-size: 13px; color: var(--text-main); max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                    ${not empty c.address ? c.address : '<span style="color:var(--text-dim);">Not Provided</span>'}
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${c.bookingCount > 0}">
                                                        <button type="button" class="booking-count-badge"
                                                                data-id="${c.id}"
                                                                data-name="${fn:escapeXml(c.fullName)}"
                                                                data-email="${fn:escapeXml(c.email)}"
                                                                data-phone="${fn:escapeXml(c.phone)}"
                                                                data-address="${fn:escapeXml(c.address)}"
                                                                data-role="${fn:escapeXml(c.role)}"
                                                                data-status="${c.status}"
                                                                data-block-reason="${fn:escapeXml(c.blockReason)}"
                                                                data-bookings="${c.bookingCount}"
                                                                data-total-spent="${c.totalSpent}"
                                                                data-joined="<fmt:formatDate value='${c.createdAt}' pattern='MMM dd, yyyy' />"
                                                                onclick="openCustomerProfile(this)">
                                                            <i class="bi bi-journal-bookmark-fill"></i> ${c.bookingCount} Booking(s)
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="booking-count-badge zero">0 Bookings</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${c.status == 'Blocked'}">
                                                        <span class="status-pill blocked">
                                                            <span class="dot"></span> Blocked
                                                        </span>
                                                        <c:if test="${not empty c.blockReason}">
                                                            <div style="font-size: 11px; color: #f87171; margin-top: 4px; max-width: 170px; line-height: 1.3;" title="Block Reason: ${fn:escapeXml(c.blockReason)}">
                                                                <i class="bi bi-info-circle"></i> Reason: ${fn:escapeXml(c.blockReason)}
                                                            </div>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-pill active">
                                                            <span class="dot"></span> Active
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="table-actions">
                                                    <!-- Profile & Booking History button -->
                                                    <button type="button" class="btn-action-icon" title="View Guest Profile &amp; Bookings"
                                                            data-id="${c.id}"
                                                            data-name="${fn:escapeXml(c.fullName)}"
                                                            data-email="${fn:escapeXml(c.email)}"
                                                            data-phone="${fn:escapeXml(c.phone)}"
                                                            data-address="${fn:escapeXml(c.address)}"
                                                            data-role="${fn:escapeXml(c.role)}"
                                                            data-status="${c.status}"
                                                            data-block-reason="${fn:escapeXml(c.blockReason)}"
                                                            data-bookings="${c.bookingCount}"
                                                            data-total-spent="${c.totalSpent}"
                                                            data-joined="<fmt:formatDate value='${c.createdAt}' pattern='MMM dd, yyyy' />"
                                                            onclick="openCustomerProfile(this)">
                                                        <i class="bi bi-eye"></i>
                                                    </button>

                                                    <!-- Status Toggle Action Buttons -->
                                                    <c:choose>
                                                        <c:when test="${c.status == 'Blocked'}">
                                                            <button type="button" class="btn-action-icon activate" title="Activate Account"
                                                                    onclick="confirmActivateUser('${c.id}', '${fn:escapeXml(c.fullName)}')">
                                                                <i class="bi bi-check-circle"></i>
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button type="button" class="btn-action-icon block" title="Block Account"
                                                                    onclick="openBlockModal('${c.id}', '${fn:escapeXml(c.fullName)}')">
                                                                <i class="bi bi-slash-circle"></i>
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" style="text-align: center; padding: 40px; color: var(--text-muted);">
                                            <i class="bi bi-people" style="font-size: 32px; display: block; margin-bottom: 10px; color: var(--gold-muted);"></i>
                                            No registered customers found. Customer sign-ups will appear here automatically.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                            <tr id="noMatchRow" style="display:none;">
                                <td colspan="6" style="text-align:center; padding:30px; color:var(--text-muted);">
                                    <i class="bi bi-search" style="font-size: 22px; display:block; margin-bottom:6px; color:var(--gold-muted);"></i>
                                    No guests matching the current search filters.
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <!-- Customer Profile & Bookings Modal -->
    <div class="modal-overlay" id="customerProfileModal">
        <div class="modal-box cust-modal-box">
            <div class="modal-header">
                <div>
                    <h3 style="font-size: 18px; margin: 0;">Guest Profile &amp; Reservation History</h3>
                    <p style="font-size: 12px; color: var(--text-muted); margin: 3px 0 0 0;">Comprehensive guest account overview and parameters</p>
                </div>
                <button type="button" class="modal-close-btn" id="closeCustModal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="cust-profile-head">
                    <div class="cust-profile-avatar" id="cpAvatar">G</div>
                    <div style="flex:1;">
                        <h4 id="cpName" style="font-size: 18px; color: #ffffff; margin: 0;">Guest Name</h4>
                        <div style="font-size: 12.5px; color: var(--text-muted); margin-top: 4px;">
                            Member since <span id="cpJoined" style="color: var(--gold-light);">—</span>
                        </div>
                    </div>
                    <div>
                        <span id="cpStatus" class="status-pill active">Active</span>
                    </div>
                </div>

                <!-- Block Reason Alert (visible when account is restricted) -->
                <div id="cpBlockReasonRow" style="display:none; background: rgba(239, 68, 68, 0.12); border: 1px solid rgba(239, 68, 68, 0.35); border-radius: var(--radius-sm); padding: 12px 14px; margin-bottom: 16px;">
                    <div style="font-size: 11px; text-transform: uppercase; color: #fca5a5; font-weight: 700; letter-spacing: 0.5px; margin-bottom: 4px;">
                        <i class="bi bi-shield-x"></i> Reason for Account Restriction
                    </div>
                    <div id="cpBlockReason" style="font-size: 13.5px; color: #ffffff;">—</div>
                </div>

                <!-- Structured User Data Form Details -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 18px; background: var(--bg-surface-elevated); padding: 16px; border-radius: var(--radius-sm); border: 1px solid var(--border-subtle);">
                    <div>
                        <label style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block; margin-bottom: 4px; font-weight: 600;">Account ID</label>
                        <span id="cpId" style="font-size: 13.5px; color: var(--gold-light); font-weight: 600;">—</span>
                    </div>
                    <div>
                        <label style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block; margin-bottom: 4px; font-weight: 600;">Account Role</label>
                        <span id="cpRole" style="font-size: 13.5px; color: var(--text-main);">Customer</span>
                    </div>
                    <div>
                        <label style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block; margin-bottom: 4px; font-weight: 600;">Email Address</label>
                        <span id="cpEmail" style="font-size: 13.5px; color: #ffffff; font-weight: 500;">—</span>
                    </div>
                    <div>
                        <label style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block; margin-bottom: 4px; font-weight: 600;">Phone Number</label>
                        <span id="cpPhone" style="font-size: 13.5px; color: #ffffff; font-weight: 500;">—</span>
                    </div>
                    <div style="grid-column: span 2;">
                        <label style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block; margin-bottom: 4px; font-weight: 600;">Residential Address</label>
                        <span id="cpAddress" style="font-size: 13.5px; color: var(--text-main);">—</span>
                    </div>
                    <div>
                        <label style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block; margin-bottom: 4px; font-weight: 600;">Total Reservations</label>
                        <span id="cpBookingsStat" style="font-size: 13.5px; color: #ffffff; font-weight: 600;">0 Bookings</span>
                    </div>
                    <div>
                        <label style="font-size: 11px; text-transform: uppercase; color: var(--text-muted); display: block; margin-bottom: 4px; font-weight: 600;">Total Spent (Confirmed)</label>
                        <span id="cpTotalSpent" style="font-size: 14px; color: var(--gold-light); font-weight: 700;">₹0.00</span>
                    </div>
                </div>

                <div class="history-subhead">
                    <i class="bi bi-clock-history" style="color: var(--gold-primary);"></i>
                    <span>Reservation History (<span id="cpBookingsCount">0 Bookings</span>)</span>
                </div>

                <div class="table-responsive" style="max-height: 240px; overflow-y: auto; border: 1px solid var(--border-subtle); border-radius: var(--radius-sm);">
                    <table class="custom-table" style="font-size: 12.5px;">
                        <thead>
                            <tr>
                                <th>Ref #</th>
                                <th>Room</th>
                                <th>Dates</th>
                                <th>Amount</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="cpBookingsHistory">
                            <tr>
                                <td colspan="5" style="text-align: center; padding: 20px; color: var(--text-muted);">
                                    Select a guest to inspect reservations.
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
                    <button type="button" class="btn primary" onclick="document.getElementById('customerProfileModal').classList.remove('open')">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Block Reason Confirmation Modal -->
    <div class="modal-overlay" id="blockConfirmModal">
        <div class="modal-box" style="max-width: 480px;">
            <div class="modal-header">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <div style="width: 36px; height: 36px; border-radius: 50%; background: rgba(239, 68, 68, 0.15); color: #ef4444; display: flex; align-items: center; justify-content: center; font-size: 18px;">
                        <i class="bi bi-slash-circle"></i>
                    </div>
                    <div>
                        <h3 style="font-size: 17px; margin: 0; color: #ffffff;">Block Customer Account</h3>
                        <p style="font-size: 12px; color: var(--text-muted); margin: 2px 0 0 0;" id="blockGuestName">Guest Name</p>
                    </div>
                </div>
                <button type="button" class="modal-close-btn" onclick="document.getElementById('blockConfirmModal').classList.remove('open')">&times;</button>
            </div>
            <form id="blockActionForm" action="${pageContext.request.contextPath}/admin/customers" method="POST">
                <input type="hidden" name="action" value="toggle_status">
                <input type="hidden" name="customerId" id="blockCustomerId" value="">
                <input type="hidden" name="newStatus" value="Blocked">
                <div class="modal-body" style="padding-top: 14px;">
                    <p style="font-size: 13px; color: var(--text-main); margin-bottom: 14px;">
                        Blocking this account will immediately revoke access to the guest portal. Please specify the reason for blocking this customer:
                    </p>
                    <label style="display: block; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; color: var(--gold-light); font-weight: 600; margin-bottom: 6px;">
                        Reason for Blocking <span style="color: #ef4444;">*</span>
                    </label>
                    <textarea name="blockReason" id="blockReasonInput" rows="3" required placeholder="e.g. Unpaid room charges, Repeated noise disturbance, Suspicious activity..." style="width: 100%; padding: 10px 12px; background: var(--bg-surface-elevated); border: 1px solid var(--border-subtle); border-radius: var(--radius-sm); color: #ffffff; font-size: 13px; resize: vertical; box-sizing: border-box;"></textarea>

                    <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
                        <button type="button" class="btn ghost" onclick="document.getElementById('blockConfirmModal').classList.remove('open')">Cancel</button>
                        <button type="submit" class="btn" style="background: #ef4444; border-color: #ef4444; color: #ffffff;">
                            <i class="bi bi-slash-circle"></i> Confirm &amp; Block Account
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!-- Hidden Form for Activate Account -->
    <form id="activateActionForm" action="${pageContext.request.contextPath}/admin/customers" method="POST" style="display:none;">
        <input type="hidden" name="action" value="toggle_status">
        <input type="hidden" name="customerId" id="activateCustomerId" value="">
        <input type="hidden" name="newStatus" value="Active">
    </form>

    <!-- Scripts -->
    <script src="${pageContext.request.contextPath}/JS/admin/customers.js"></script>

</body>
</html>

