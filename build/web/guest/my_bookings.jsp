<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    /* If accessed directly without passing through servlet, forward to servlet */
    if (request.getAttribute("bookings") == null) {
        response.sendRedirect(request.getContextPath() + "/guest/my-bookings");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>GrandStay Privé | My Bookings</title>

        <!-- Google Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&family=Playfair+Display:ital,wght@0,600;0,700;1,400&display=swap" rel="stylesheet">

        <!-- Bootstrap & Icons -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

        <!-- Stylesheets -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/guest/navbar.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/guest/rooms.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/modal.css">

        <style>
            .bookings-container {
                max-width: 1200px;
                margin: 2rem auto 4rem;
                padding: 0 1.5rem;
            }
            .filter-tab-bar {
                display: flex;
                gap: 0.75rem;
                margin-bottom: 2rem;
                border-bottom: 1px solid rgba(197, 160, 89, 0.2);
                padding-bottom: 1rem;
                flex-wrap: wrap;
            }
            .tab-btn {
                background: rgba(22, 26, 36, 0.6);
                border: 1px solid rgba(197, 160, 89, 0.25);
                color: #94a3b8;
                padding: 0.55rem 1.25rem;
                border-radius: 30px;
                font-size: 0.82rem;
                font-weight: 600;
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
                cursor: pointer;
                transition: all 0.25s ease;
            }
            .tab-btn:hover {
                border-color: rgba(197, 160, 89, 0.6);
                color: #e2e8f0;
                transform: translateY(-1px);
            }
            .tab-btn.active {
                background: linear-gradient(135deg, rgba(197, 160, 89, 0.25) 0%, rgba(197, 160, 89, 0.08) 100%);
                border-color: #c5a059;
                color: #f1f5f9;
                box-shadow: 0 4px 14px rgba(197, 160, 89, 0.15);
            }
            .tab-badge {
                background: rgba(0, 0, 0, 0.35);
                border-radius: 12px;
                padding: 0.1rem 0.5rem;
                font-size: 0.72rem;
            }
            .booking-card {
                background: linear-gradient(145deg, #161a24 0%, #0e1118 100%);
                border: 1px solid rgba(197, 160, 89, 0.28);
                border-radius: 14px;
                padding: 1.5rem 1.75rem;
                margin-bottom: 1.5rem;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
                display: flex;
                flex-wrap: wrap;
                justify-content: space-between;
                align-items: center;
                gap: 1.5rem;
                transition: transform 0.2s ease, border-color 0.2s ease;
            }
            .booking-card:hover {
                transform: translateY(-2px);
                border-color: rgba(197, 160, 89, 0.5);
            }
            .booking-card.card-cancelled {
                border-color: rgba(239, 68, 68, 0.35);
                background: linear-gradient(145deg, #181316 0%, #0e0d11 100%);
                opacity: 0.92;
            }
            .booking-info-group {
                display: flex;
                align-items: center;
                gap: 1.25rem;
                flex: 1;
                min-width: 300px;
            }
            .booking-thumb {
                width: 96px;
                height: 96px;
                border-radius: 10px;
                object-fit: cover;
                border: 1px solid rgba(197, 160, 89, 0.3);
            }
            .booking-ref-badge {
                display: inline-block;
                padding: 0.25rem 0.65rem;
                border-radius: 20px;
                background: rgba(197, 160, 89, 0.15);
                color: var(--gold-light, #e6cb8b);
                font-size: 0.72rem;
                font-weight: 700;
                letter-spacing: 0.08em;
                margin-bottom: 0.35rem;
            }
            .booking-title {
                margin: 0 0 0.35rem;
                font-family: 'Playfair Display', serif;
                font-size: 1.28rem;
                color: #fff;
            }
            .booking-meta {
                display: flex;
                flex-wrap: wrap;
                gap: 1rem;
                font-size: 0.78rem;
                color: #94a3b8;
            }
            .booking-meta span {
                display: inline-flex;
                align-items: center;
                gap: 0.35rem;
            }
            .booking-meta i {
                color: #c5a059;
            }
            .cancellation-reason-tag {
                background: rgba(239, 68, 68, 0.12);
                border: 1px solid rgba(239, 68, 68, 0.3);
                border-radius: 8px;
                padding: 0.4rem 0.75rem;
                margin-top: 0.6rem;
                font-size: 0.76rem;
                color: #fca5a5;
                display: inline-flex;
                align-items: center;
                gap: 0.4rem;
            }
            .booking-side-action {
                text-align: right;
                display: flex;
                flex-direction: column;
                align-items: flex-end;
                gap: 0.75rem;
            }
            .booking-price {
                font-family: 'Playfair Display', serif;
                font-size: 1.45rem;
                font-weight: 700;
                color: #e6cb8b;
            }
            .status-pill {
                padding: 0.3rem 0.75rem;
                border-radius: 20px;
                font-size: 0.72rem;
                font-weight: 700;
                letter-spacing: 0.08em;
                text-transform: uppercase;
                display: inline-flex;
                align-items: center;
                gap: 0.35rem;
            }
            .status-confirmed {
                background: rgba(16, 185, 129, 0.15);
                border: 1px solid #10b981;
                color: #6ee7b7;
            }
            .status-cancelled {
                background: rgba(239, 68, 68, 0.15);
                border: 1px solid #ef4444;
                color: #fca5a5;
            }
            .booking-action-btn-group {
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }
            .btn-booking-view {
                background: rgba(197, 160, 89, 0.12);
                border: 1px solid rgba(197, 160, 89, 0.35);
                color: #e6cb8b;
                font-size: 0.75rem;
                font-weight: 600;
                padding: 0.4rem 0.85rem;
                border-radius: 6px;
                cursor: pointer;
                transition: all 0.2s ease;
                display: inline-flex;
                align-items: center;
                gap: 0.35rem;
            }
            .btn-booking-view:hover {
                background: rgba(197, 160, 89, 0.25);
                border-color: #c5a059;
                color: #fff;
                transform: translateY(-1px);
            }
            .btn-booking-cancel {
                background: rgba(239, 68, 68, 0.1);
                border: 1px solid rgba(239, 68, 68, 0.4);
                color: #fca5a5;
                font-size: 0.75rem;
                font-weight: 600;
                padding: 0.4rem 0.85rem;
                border-radius: 6px;
                cursor: pointer;
                transition: all 0.2s ease;
                display: inline-flex;
                align-items: center;
                gap: 0.35rem;
            }
            .btn-booking-cancel:hover {
                background: rgba(239, 68, 68, 0.22);
                border-color: #ef4444;
                color: #fff;
                transform: translateY(-1px);
            }
            .btn-booking-delete {
                background: rgba(148, 163, 184, 0.1);
                border: 1px solid rgba(148, 163, 184, 0.3);
                color: #cbd5e1;
                font-size: 0.75rem;
                font-weight: 600;
                padding: 0.4rem 0.85rem;
                border-radius: 6px;
                cursor: pointer;
                transition: all 0.2s ease;
                display: inline-flex;
                align-items: center;
                gap: 0.35rem;
            }
            .btn-booking-delete:hover {
                background: rgba(239, 68, 68, 0.2);
                border-color: #ef4444;
                color: #fca5a5;
                transform: translateY(-1px);
            }
            .lookup-box {
                background: linear-gradient(145deg, #161a24 0%, #0e1118 100%);
                border: 1px solid rgba(197, 160, 89, 0.28);
                border-radius: 12px;
                padding: 1.5rem;
                margin-bottom: 2rem;
            }
            .search-input-field {
                width: 100%;
                background: #0d1118;
                border: 1px solid rgba(197, 160, 89, 0.25);
                color: #fff;
                padding: 0.6rem 1rem;
                border-radius: 8px;
                font-size: 0.85rem;
            }
            .search-input-field:focus {
                outline: none;
                border-color: #c5a059;
            }
            /* Itinerary Detail Grid */
            .itinerary-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 1rem;
                text-align: left;
                background: rgba(13, 17, 24, 0.75);
                border: 1px solid rgba(197, 160, 89, 0.2);
                border-radius: 12px;
                padding: 1.25rem;
                margin: 1.25rem 0;
            }
            .itinerary-item {
                display: flex;
                flex-direction: column;
                gap: 0.2rem;
            }
            .itinerary-label {
                font-size: 0.72rem;
                color: #94a3b8;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }
            .itinerary-value {
                font-size: 0.92rem;
                font-weight: 600;
                color: #f1f5f9;
            }
        </style>
    </head>
    <body>
        <!-- Header / Navbar -->
        <jsp:include page="navbar.jsp" />

        <div class="rooms-hero" style="min-height: 220px; padding: 3rem 1rem;">
            <div class="hero-shade"></div>
            <div class="hero-content">
                <span class="eyebrow"><i class="bi bi-calendar-check"></i> Guest Management</span>
                <h1 style="font-size: 2.2rem; margin: 0.5rem 0;">My <em>Reservations</em></h1>
                <p>View confirmed bookings, review cancellation history, and inspect your luxury stay itineraries.</p>
            </div>
        </div>

        <main class="bookings-container">

            <!-- Search / Lookup Bar -->
            <div class="lookup-box">
                <form action="${pageContext.request.contextPath}/guest/my-bookings" method="GET" class="row g-2 align-items-center">
                    <div class="col-md-5">
                        <input type="email" name="email" class="search-input-field" 
                               value="${queriedEmail}" placeholder="Search by email address...">
                    </div>
                    <div class="col-md-5">
                        <input type="text" name="bookingRef" class="search-input-field" 
                               value="${param.bookingRef}" placeholder="Or search by booking reference (e.g. GS-XXXXXXXX)...">
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn-modal-confirm w-100 py-2">
                            <i class="bi bi-search"></i> Find
                        </button>
                    </div>
                </form>
            </div>

            <!-- Booking Filter Tabs: All, Confirmed, Cancelled -->
            <div class="filter-tab-bar">
                <button type="button" class="tab-btn active" id="tabAll" onclick="filterBookings('ALL', this)">
                    <i class="bi bi-collection"></i> All Bookings
                    <span class="tab-badge">${not empty totalCount ? totalCount : fn:length(bookings)}</span>
                </button>
                <button type="button" class="tab-btn" id="tabConfirmed" onclick="filterBookings('CONFIRMED', this)">
                    <i class="bi bi-check-circle"></i> Confirmed Stays
                    <span class="tab-badge">${not empty confirmedCount ? confirmedCount : 0}</span>
                </button>
                <button type="button" class="tab-btn" id="tabCancelled" onclick="filterBookings('CANCELLED', this)">
                    <i class="bi bi-x-circle"></i> Cancelled Stays
                    <span class="tab-badge">${not empty cancelledCount ? cancelledCount : 0}</span>
                </button>
            </div>

            <!-- Bookings List -->
            <c:choose>
                <c:when test="${not empty bookings}">
                    <div id="bookingListWrapper">
                        <c:forEach var="b" items="${bookings}">
                            <div class="booking-card ${b.bookingStatus == 'CANCELLED' ? 'card-cancelled' : ''}" data-status="${b.bookingStatus}">
                                <div class="booking-info-group">
                                    <c:choose>
                                        <c:when test="${not empty b.primaryPhoto}">
                                            <c:set var="rawBPhoto" value="${fn:replace(b.primaryPhoto, '\\\\', '/')}" />
                                            <c:choose>
                                                <c:when test="${fn:startsWith(rawBPhoto, 'http://') or fn:startsWith(rawBPhoto, 'https://')}">
                                                    <c:set var="bPhoto" value="${rawBPhoto}" />
                                                </c:when>
                                                <c:when test="${fn:startsWith(rawBPhoto, '/')}">
                                                    <c:set var="bPhoto" value="${pageContext.request.contextPath}${rawBPhoto}" />
                                                </c:when>
                                                <c:otherwise>
                                                    <c:set var="bPhoto" value="${pageContext.request.contextPath}/${rawBPhoto}" />
                                                </c:otherwise>
                                            </c:choose>
                                            <img src="${bPhoto}" alt="${b.roomTitle}" class="booking-thumb"
                                                 onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/Image/default_room.jpg';">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/Image/default_room.jpg" alt="${b.roomTitle}" class="booking-thumb">
                                        </c:otherwise>
                                    </c:choose>

                                    <div>
                                        <span class="booking-ref-badge">${b.bookingReference}</span>
                                        <h3 class="booking-title">${b.roomTitle} <small class="fs-6" style="color: #94a3b8;">(${b.categoryName})</small></h3>
                                        <div class="booking-meta">
                                            <span><i class="bi bi-door-closed"></i> Room ${b.roomNumber}</span>
                                            <span><i class="bi bi-calendar-event"></i> Check-in: <strong><fmt:formatDate value="${b.checkIn}" pattern="dd MMM yyyy"/></strong></span>
                                            <span><i class="bi bi-calendar-check"></i> Check-out: <strong><fmt:formatDate value="${b.checkOut}" pattern="dd MMM yyyy"/></strong></span>
                                            <span><i class="bi bi-people"></i> ${b.guestsCount} Guest(s)</span>
                                        </div>
                                        <div class="mt-2" style="font-size: 0.72rem; color: #94a3b8;">
                                            Reserved by: <strong class="text-light">${b.guestName}</strong> • ${b.guestEmail} • ${b.guestPhone}
                                        </div>

                                        <c:if test="${b.bookingStatus == 'CANCELLED' && not empty b.cancellationReason}">
                                            <div class="cancellation-reason-tag">
                                                <i class="bi bi-info-circle-fill"></i>
                                                <strong>Cancellation Reason:</strong>
                                                <span>${fn:escapeXml(b.cancellationReason)}</span>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>

                                <div class="booking-side-action">
                                    <span class="status-pill ${b.bookingStatus == 'CONFIRMED' ? 'status-confirmed' : 'status-cancelled'}">
                                        <i class="bi ${b.bookingStatus == 'CONFIRMED' ? 'bi-check-circle-fill' : 'bi-x-circle-fill'}"></i>
                                        ${b.bookingStatus}
                                    </span>
                                    <div class="booking-price">
                                        ₹<fmt:formatNumber value="${b.totalPrice}" pattern="#,##0.00"/>
                                    </div>

                                    <!-- Action Buttons: View Always Available; Cancel only if Confirmed -->
                                    <div class="booking-action-btn-group">
                                        <button type="button" class="btn-booking-view" onclick="openViewModal(
                                            '${b.id}',
                                            '${b.bookingReference}',
                                            '${fn:escapeXml(b.roomTitle)}',
                                            '${b.roomNumber}',
                                            '${b.categoryName}',
                                            '${b.bedType}',
                                            '<fmt:formatDate value="${b.checkIn}" pattern="dd MMM yyyy"/>',
                                            '<fmt:formatDate value="${b.checkOut}" pattern="dd MMM yyyy"/>',
                                            '${b.guestsCount}',
                                            '<fmt:formatNumber value="${b.totalPrice}" pattern="#,##0.00"/>',
                                            '${b.bookingStatus}',
                                            '${fn:escapeXml(b.cancellationReason)}',
                                            '<fmt:formatDate value="${b.createdAt}" pattern="dd MMM yyyy, hh:mm a"/>',
                                            '${fn:escapeXml(b.guestName)}',
                                            '${fn:escapeXml(b.guestEmail)}',
                                            '${fn:escapeXml(b.guestPhone)}',
                                            '${bPhoto}'
                                        )">
                                            <i class="bi bi-eye"></i> View
                                        </button>

                                        <c:if test="${b.bookingStatus == 'CONFIRMED'}">
                                            <button type="button" class="btn-booking-cancel" onclick="openCancelModal('${b.id}', '${b.bookingReference}', '${fn:escapeXml(b.roomTitle)}', '${b.roomNumber}')">
                                                <i class="bi bi-x-circle"></i> Cancel
                                            </button>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state text-center py-5">
                        <i class="bi bi-calendar-x fs-1 text-gold"></i>
                        <h3 class="mt-3">No Reservations Found</h3>
                        <p style="color: #94a3b8;">No bookings were found matching your account or search parameters.</p>
                        <a href="${pageContext.request.contextPath}/guest/room" class="btn btn-gold-luxury d-inline-flex mt-3 text-decoration-none px-4 py-2">
                            <i class="bi bi-door-open me-2"></i> Browse Available Rooms
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>

        <!-- 1. POPUP: Cancel Booking Modal with Cancellation Reason -->
        <div class="modal fade" id="cancelBookingModal" tabindex="-1" aria-labelledby="cancelModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content luxury-modal">
                    <div class="modal-body text-center">
                        <div class="modal-status modal-status-warning">
                            <i class="bi bi-calendar-x"></i>
                        </div>
                        <span class="modal-eyebrow">Reservation Cancellation</span>
                        <h4 id="cancelModalTitle" class="modal-title">Cancel Reservation</h4>
                        <p class="modal-lead" id="cancelModalPrompt">
                            Are you sure you want to cancel booking <strong id="cancelModalRef" class="text-gold"></strong>?
                        </p>

                        <form action="${pageContext.request.contextPath}/guest/my-bookings" method="POST" id="cancelForm" class="text-start">
                            <input type="hidden" name="action" value="cancel">
                            <input type="hidden" name="bookingId" id="cancelBookingId">

                            <div class="form-group-luxury mb-3">
                                <label for="reasonCategory" class="form-field-label text-light mb-1 small fw-semibold">
                                    Reason for Cancellation <span class="text-danger">*</span>
                                </label>
                                <select id="reasonCategory" class="search-input-field" required onchange="handleReasonCategoryChange()">
                                    <option value="" disabled selected>-- Select a Reason --</option>
                                    <option value="Change of travel plans">Change of travel plans</option>
                                    <option value="Personal or family emergency">Personal or family emergency</option>
                                    <option value="Flight / transport delay or cancellation">Flight / transport delay or cancellation</option>
                                    <option value="Found alternative hotel accommodation">Found alternative hotel accommodation</option>
                                    <option value="Date or schedule conflict">Date or schedule conflict</option>
                                    <option value="Booked by mistake">Booked by mistake</option>
                                    <option value="Other">Other reason</option>
                                </select>
                            </div>

                            <div class="form-group-luxury mb-3">
                                <label for="cancelReasonText" class="form-field-label text-light mb-1 small fw-semibold">
                                    Additional Feedback / Reason Details
                                </label>
                                <textarea name="cancelReason" id="cancelReasonText" class="search-input-field" rows="3" required placeholder="Please provide cancellation reason..."></textarea>
                            </div>

                            <div class="modal-actions d-flex justify-content-center gap-3 mt-4">
                                <button type="button" class="btn-outline-luxury" data-bs-dismiss="modal">
                                    Keep Booking
                                </button>
                                <button type="submit" class="btn-gold-luxury" style="background: linear-gradient(135deg, #ef4444 0%, #b91c1c 100%) !important; color: #fff !important; border: none !important;">
                                    Confirm Cancellation
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2. POPUP: View Itinerary / Reservation Details Modal -->
        <div class="modal fade" id="viewBookingModal" tabindex="-1" aria-labelledby="viewModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" style="max-width: 620px !important;">
                <div class="modal-content luxury-modal">
                    <div class="modal-body text-center" style="padding: 36px 30px !important;">
                        <div class="modal-status modal-status-gold">
                            <i class="bi bi-journal-bookmark-fill"></i>
                        </div>
                        <span class="modal-eyebrow">Reservation Itinerary</span>
                        <h4 id="viewModalTitle" class="modal-title mb-1">Booking Overview</h4>
                        <span class="booking-ref-badge" id="viewModalRef">GS-XXXXXXXX</span>

                        <!-- Booking Status Pill -->
                        <div class="mt-2 mb-3">
                            <span class="status-pill" id="viewModalStatusPill">CONFIRMED</span>
                        </div>

                        <!-- Prominent Room Photo Display in Itinerary Modal -->
                        <div class="view-booking-photo-container" style="width: 100%; height: 170px; border-radius: 12px; overflow: hidden; margin: 14px 0; border: 1px solid rgba(197, 160, 89, 0.35); background: #0c0f16; position: relative; box-shadow: 0 4px 16px rgba(0, 0, 0, 0.5);">
                            <img id="viewModalPhoto" src="${pageContext.request.contextPath}/Image/default_room.jpg" alt="Reserved Suite Photo" style="width: 100%; height: 100%; object-fit: cover; display: block;" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/Image/default_room.jpg';">
                        </div>

                        <!-- Cancellation Reason Alert in View Modal (if cancelled) -->
                        <div id="viewModalCancelReasonWrapper" class="cancellation-reason-tag w-100 text-start justify-content-start mb-3" style="display: none;">
                            <i class="bi bi-info-circle-fill text-danger fs-6"></i>
                            <div>
                                <strong>Reason for Cancellation:</strong>
                                <div id="viewModalCancelReasonText" class="mt-1"></div>
                            </div>
                        </div>

                        <!-- Itinerary Details Grid -->
                        <div class="itinerary-grid">
                            <div class="itinerary-item">
                                <span class="itinerary-label">Suite / Room</span>
                                <span class="itinerary-value" id="viewModalRoomTitle">--</span>
                            </div>
                            <div class="itinerary-item">
                                <span class="itinerary-label">Room Number</span>
                                <span class="itinerary-value" id="viewModalRoomNumber">--</span>
                            </div>
                            <div class="itinerary-item">
                                <span class="itinerary-label">Check-in Date</span>
                                <span class="itinerary-value" id="viewModalCheckIn">--</span>
                            </div>
                            <div class="itinerary-item">
                                <span class="itinerary-label">Check-out Date</span>
                                <span class="itinerary-value" id="viewModalCheckOut">--</span>
                            </div>
                            <div class="itinerary-item">
                                <span class="itinerary-label">Total Occupancy</span>
                                <span class="itinerary-value" id="viewModalGuests">--</span>
                            </div>
                            <div class="itinerary-item">
                                <span class="itinerary-label">Total Price Paid / Due</span>
                                <span class="itinerary-value text-gold" id="viewModalTotalPrice">--</span>
                            </div>
                            <div class="itinerary-item">
                                <span class="itinerary-label">Guest Full Name</span>
                                <span class="itinerary-value" id="viewModalGuestName">--</span>
                            </div>
                            <div class="itinerary-item">
                                <span class="itinerary-label">Contact Details</span>
                                <span class="itinerary-value" id="viewModalGuestContact" style="font-size: 0.8rem;">--</span>
                            </div>
                            <div class="itinerary-item" style="grid-column: span 2;">
                                <span class="itinerary-label">Booking Placed At</span>
                                <span class="itinerary-value" id="viewModalCreatedAt" style="font-size: 0.8rem;">--</span>
                            </div>
                        </div>

                        <div class="modal-actions d-flex justify-content-center">
                            <button type="button" class="btn-gold-luxury" data-bs-dismiss="modal">
                                Close Itinerary
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 4. POPUP: Luxury Status Feedback Modal (Matches Login & Registration Modal System) -->
        <c:if test="${not empty param.bookingSuccess or param.cancelSuccess == 'true' or param.deleteSuccess == 'true'}">
            <div class="modal fade" id="statusResultModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content luxury-modal">
                        <div class="modal-body text-center">

                            <c:choose>
                                <c:when test="${not empty param.bookingSuccess}">
                                    <div class="modal-status modal-status-success">
                                        <i class="bi bi-check-circle-fill"></i>
                                    </div>
                                    <span class="modal-eyebrow">Reservation Confirmed</span>
                                    <h4 class="modal-title">Booking Successful</h4>
                                    <p class="modal-lead">
                                        Your suite reservation has been confirmed and stored in the hotel database. Reference: 
                                        <strong class="text-gold">${fn:escapeXml(param.bookingSuccess)}</strong>.
                                    </p>
                                    <button type="button" class="btn-gold-luxury" data-bs-dismiss="modal">
                                        View Reservations
                                    </button>
                                </c:when>

                                <c:when test="${param.cancelSuccess == 'true'}">
                                    <div class="modal-status modal-status-warning">
                                        <i class="bi bi-calendar-x-fill"></i>
                                    </div>
                                    <span class="modal-eyebrow">Cancellation Recorded</span>
                                    <h4 class="modal-title">Reservation Cancelled</h4>
                                    <p class="modal-lead">
                                        Your booking has been cancelled successfully. Your reason has been registered in the system records.
                                    </p>
                                    <button type="button" class="btn-gold-luxury" data-bs-dismiss="modal">
                                        Understood
                                    </button>
                                </c:when>
                            </c:choose>

                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Footer -->
        <footer class="site-footer">
            <a class="footer-brand" href="#">GRANDSTAY<span>HOTEL &amp; RESIDENCES</span></a>
            <small class="d-block mt-2" style="color: #94a3b8;">&copy; <%= java.time.Year.now().getValue() %> GrandStay Hotel. All rights reserved.</small>
        </footer>

        <!-- Bootstrap JS Bundle -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // Auto-show feedback modal if present
                const statusModalEl = document.getElementById("statusResultModal");
                if (statusModalEl) {
                    new bootstrap.Modal(statusModalEl).show();
                }
            });

            // Tab filtering for All / Confirmed / Cancelled
            function filterBookings(status, btnElement) {
                document.querySelectorAll(".tab-btn").forEach(b => b.classList.remove("active"));
                btnElement.classList.add("active");

                const cards = document.querySelectorAll(".booking-card");
                cards.forEach(card => {
                    const cardStatus = card.getAttribute("data-status");
                    if (status === "ALL") {
                        card.style.display = "flex";
                    } else if (cardStatus === status) {
                        card.style.display = "flex";
                    } else {
                        card.style.display = "none";
                    }
                });
            }

            // Open Cancellation Modal
            function openCancelModal(bookingId, ref, roomTitle, roomNumber) {
                document.getElementById("cancelBookingId").value = bookingId;
                document.getElementById("cancelModalRef").innerText = ref;
                document.getElementById("cancelModalPrompt").innerHTML = 
                    'Are you sure you want to cancel booking <strong class="text-gold">' + ref + '</strong> for ' + roomTitle + ' (Room ' + roomNumber + ')?';
                document.getElementById("reasonCategory").value = "";
                document.getElementById("cancelReasonText").value = "";
                new bootstrap.Modal(document.getElementById("cancelBookingModal")).show();
            }

            // Sync category selection with reason text
            function handleReasonCategoryChange() {
                const select = document.getElementById("reasonCategory");
                const textarea = document.getElementById("cancelReasonText");
                if (select.value && select.value !== "Other") {
                    textarea.value = select.value;
                } else if (select.value === "Other") {
                    textarea.value = "";
                    textarea.focus();
                }
            }

            // Open View Itinerary Modal
            function openViewModal(id, ref, roomTitle, roomNumber, category, bedType, checkIn, checkOut, guests, price, status, cancelReason, createdAt, guestName, guestEmail, guestPhone, photo) {
                document.getElementById("viewModalRef").innerText = ref;
                document.getElementById("viewModalRoomTitle").innerText = roomTitle + " (" + category + ")";
                document.getElementById("viewModalRoomNumber").innerText = "Room " + roomNumber + " • " + bedType;
                document.getElementById("viewModalCheckIn").innerText = checkIn;
                document.getElementById("viewModalCheckOut").innerText = checkOut;
                document.getElementById("viewModalGuests").innerText = guests + " Guest(s)";
                document.getElementById("viewModalTotalPrice").innerText = "₹" + price;
                document.getElementById("viewModalGuestName").innerText = guestName;
                document.getElementById("viewModalGuestContact").innerText = guestEmail + " | " + guestPhone;
                document.getElementById("viewModalCreatedAt").innerText = createdAt;

                const statusPill = document.getElementById("viewModalStatusPill");
                const reasonWrapper = document.getElementById("viewModalCancelReasonWrapper");
                const reasonText = document.getElementById("viewModalCancelReasonText");

                statusPill.innerText = status;
                if (status === "CANCELLED") {
                    statusPill.className = "status-pill status-cancelled";
                    reasonWrapper.style.display = "flex";
                    reasonText.innerText = cancelReason || "Cancelled by guest";
                } else {
                    statusPill.className = "status-pill status-confirmed";
                    reasonWrapper.style.display = "none";
                }

                const photoEl = document.getElementById("viewModalPhoto");
                if (photoEl) {
                    photoEl.src = (photo && photo.trim().length > 0) ? photo : "${pageContext.request.contextPath}/Image/default_room.jpg";
                }

                new bootstrap.Modal(document.getElementById("viewBookingModal")).show();
            }
        </script>
    </body>
</html>
