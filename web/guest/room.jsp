<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map, java.math.BigDecimal" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    /* If accessed directly without passing through servlet, forward to servlet */
    if (request.getAttribute("rooms") == null) {
        response.sendRedirect(request.getContextPath() + "/guest/room");
        return;
    }
    String sessionUser = (String) session.getAttribute("fullName");
    String sessionEmail = (String) session.getAttribute("userEmail");
    String sessionPhone = (String) session.getAttribute("phone");
    String sessionAddress = (String) session.getAttribute("address");
    if (sessionUser == null) { sessionUser = ""; }
    if (sessionEmail == null) { sessionEmail = ""; }
    if (sessionPhone == null) { sessionPhone = ""; }
    if (sessionAddress == null) { sessionAddress = ""; }
%>

                        <!DOCTYPE html>
                        <html lang="en">

                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <title>GrandStay Privé | Rooms &amp; Suites</title>

                            <!-- Google Fonts -->
                            <link rel="preconnect" href="https://fonts.googleapis.com">
                            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                            <link
                                href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&family=Playfair+Display:ital,wght@0,600;0,700;1,400&display=swap"
                                rel="stylesheet">

                            <!-- Bootstrap & Icons -->
                            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                                rel="stylesheet">
                            <link
                                href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
                                rel="stylesheet">

                            <!-- Stylesheets -->
                            <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/guest/navbar.css">
                            <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/guest/rooms.css">
                            <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/modal.css">

                            <style>
                                .luxury-alert-banner {
                                    max-width: 1500px;
                                    margin: 1.5rem auto 0;
                                    padding: 0 clamp(1rem, 4vw, 3.5rem);
                                }

                                .luxury-alert {
                                    display: flex;
                                    align-items: center;
                                    gap: 1rem;
                                    padding: 1rem 1.25rem;
                                    border-radius: 10px;
                                    font-size: 0.88rem;
                                    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
                                }

                                .luxury-alert-success {
                                    background: linear-gradient(135deg, rgba(6, 78, 59, 0.9), rgba(4, 120, 87, 0.85));
                                    border: 1px solid #10b981;
                                    color: #ecfdf5;
                                }

                                .luxury-alert-error {
                                    background: linear-gradient(135deg, rgba(127, 29, 29, 0.9), rgba(153, 27, 27, 0.85));
                                    border: 1px solid #ef4444;
                                    color: #fef2f2;
                                }

                                .luxury-alert i {
                                    font-size: 1.35rem;
                                }

                                .luxury-alert-btn-close {
                                    background: transparent;
                                    border: none;
                                    color: inherit;
                                    font-size: 1.2rem;
                                    margin-left: auto;
                                    cursor: pointer;
                                    opacity: 0.8;
                                }

                                .luxury-alert-btn-close:hover {
                                    opacity: 1;
                                }

                                .no-photo-box {
                                    width: 100%;
                                    height: 100%;
                                    background: #171c26;
                                    display: flex;
                                    flex-direction: column;
                                    align-items: center;
                                    justify-content: center;
                                    gap: 0.5rem;
                                    color: #64748b;
                                    font-size: 0.78rem;
                                }

                                .no-photo-box i {
                                    font-size: 2.2rem;
                                    color: #475569;
                                }

                                .input-error-msg {
                                    font-size: 0.72rem;
                                    color: #f87171;
                                    display: none;
                                    margin-top: 0.25rem;
                                }

                                .has-validation-error .input-error-msg {
                                    display: block;
                                }

                                .has-validation-error input,
                                .has-validation-error select {
                                    border-color: #ef4444 !important;
                                    background: rgba(239, 68, 68, 0.08) !important;
                                }

                                /* Readonly fields styling for verified guest profiles */
                                .readonly-field {
                                    background-color: rgba(22, 26, 36, 0.85) !important;
                                    border: 1px solid rgba(197, 160, 89, 0.35) !important;
                                    color: #f1f5f9 !important;
                                    cursor: not-allowed !important;
                                    font-weight: 500 !important;
                                }

                                .readonly-field:focus {
                                    border-color: rgba(197, 160, 89, 0.6) !important;
                                    box-shadow: none !important;
                                    outline: none !important;
                                }

                                .readonly-badge {
                                    font-size: 0.68rem;
                                    font-weight: 600;
                                    color: #e6cb8b;
                                    background: rgba(197, 160, 89, 0.12);
                                    padding: 0.18rem 0.5rem;
                                    border-radius: 4px;
                                    border: 1px solid rgba(197, 160, 89, 0.28);
                                    display: inline-flex;
                                    align-items: center;
                                    gap: 0.25rem;
                                    letter-spacing: 0.03em;
                                }

                                .readonly-lock-icon {
                                    position: absolute;
                                    right: 12px;
                                    top: 50%;
                                    transform: translateY(-50%);
                                    color: #c5a059;
                                    font-size: 0.82rem;
                                    pointer-events: none;
                                    opacity: 0.85;
                                }

                                .readonly-textarea-icon {
                                    top: 18px !important;
                                    transform: none !important;
                                }
                            </style>
                        </head>

                        <body>
                            <!-- Header / Navbar -->
                            <jsp:include page="navbar.jsp" />

                            <!-- Hero Section -->
                            <header class="rooms-hero">
                                <div class="hero-shade"></div>
                                <div class="hero-content">
                                    <span class="eyebrow"><i class="bi bi-door-open"></i> Curated Accommodations</span>
                                    <h1>Rooms &amp; <em>Suites</em></h1>
                                    <p>Browse live room inventory directly from the hotel system and reserve your stay
                                        seamlessly.</p>
                                    <div class="hero-rule"><span></span><i class="bi bi-gem"></i><span></span></div>
                                </div>
                            </header>

                            <!-- System Alerts -->
                            <c:if test="${not empty param.bookingSuccess}">
                                <div class="luxury-alert-banner">
                                    <div class="luxury-alert luxury-alert-success">
                                        <i class="bi bi-check-circle-fill"></i>
                                        <div>
                                            <strong>Reservation Confirmed!</strong> Your booking is recorded in the
                                            system. Reference:
                                            <span
                                                class="badge bg-light text-dark ms-1 px-2 py-1 fs-6">${param.bookingSuccess}</span>
                                        </div>
                                        <button type="button" class="luxury-alert-btn-close"
                                            onclick="this.parentElement.remove()">&times;</button>
                                    </div>
                                </div>
                            </c:if>

                            <c:if test="${not empty param.error}">
                                <div class="luxury-alert-banner">
                                    <div class="luxury-alert luxury-alert-error">
                                        <i class="bi bi-exclamation-triangle-fill"></i>
                                        <div>
                                            <strong>Booking Notice:</strong> ${param.error}
                                        </div>
                                        <button type="button" class="luxury-alert-btn-close"
                                            onclick="this.parentElement.remove()">&times;</button>
                                    </div>
                                </div>
                            </c:if>

                            <c:if test="${not empty errorMessage}">
                                <div class="luxury-alert-banner">
                                    <div class="luxury-alert luxury-alert-error">
                                        <i class="bi bi-info-circle-fill"></i>
                                        <div>${errorMessage}</div>
                                        <button type="button" class="luxury-alert-btn-close"
                                            onclick="this.parentElement.remove()">&times;</button>
                                    </div>
                                </div>
                            </c:if>

                            <!-- Main Accommodations Section with TOP Filter Dropdowns -->
                            <main class="rooms-section">
                                <div class="section-heading mb-3">
                                    <div>
                                        <span class="section-kicker">Live Hotel Inventory</span>
                                        <h2>Available <em>Accommodations</em></h2>
                                    </div>
                                    <div class="results-meta m-0">
                                        <span>Showing <strong id="resultCount">${totalRooms != null ? totalRooms :
                                                0}</strong> rooms from database</span>
                                    </div>
                                </div>

                                <!-- PROPER TOP FILTER TOOLBAR USING DROPDOWN LISTS -->
                                <section class="top-filter-panel" aria-label="Room Filter Controls">
                                    <div class="top-filter-dropdowns-grid">
                                        <!-- Search Input -->
                                        <div class="search-box-luxury">
                                            <i class="bi bi-search"></i>
                                            <input type="search" id="roomSearchInput" class="search-input-field"
                                                placeholder="Search room no., title...">
                                        </div>

                                        <!-- Category Dropdown List (from Database) -->
                                        <select id="roomTypeSelect" class="form-select filter-dropdown-luxury"
                                            aria-label="Filter by Category">
                                            <option value="all">All Categories</option>
                                            <c:forEach var="type" items="${roomTypes}">
                                                <option value="${type.name}">${type.name}</option>
                                            </c:forEach>
                                        </select>

                                        <!-- Bed Configuration Dropdown List -->
                                        <select id="bedCount" class="form-select filter-dropdown-luxury"
                                            aria-label="Filter by Bed Count">
                                            <option value="any">All Bed Counts</option>
                                            <option value="1">1 Bed</option>
                                            <option value="2">2 Beds</option>
                                            <option value="3">3+ Beds</option>
                                        </select>

                                        <!-- Amenities Dropdown List (from Database) -->
                                        <select id="amenitySelect" class="form-select filter-dropdown-luxury"
                                            aria-label="Filter by Amenity">
                                            <option value="all">All Amenities</option>
                                            <c:forEach var="am" items="${availableAmenities}">
                                                <option value="${am}">${am}</option>
                                            </c:forEach>
                                        </select>

                                        <!-- Sort By Dropdown List -->
                                        <select id="sortRooms" class="form-select filter-dropdown-luxury"
                                            aria-label="Sort Rooms">
                                            <option value="recommended">Sort: Default Order</option>
                                            <option value="low-high">Sort: Price (Low to High)</option>
                                            <option value="high-low">Sort: Price (High to Low)</option>
                                        </select>

                                        <!-- Reset Button -->
                                        <button type="button" class="btn-clear-luxury" id="resetFilters"
                                            title="Reset all filters">
                                            <i class="bi bi-arrow-counterclockwise"></i> Reset
                                        </button>
                                    </div>
                                </section>

                                <!-- Full Width Room Grid -->
                                <div class="rooms-full-grid" id="roomGrid">
                                    <c:choose>
                                        <c:when test="${not empty rooms}">
                                            <c:forEach var="r" items="${rooms}">
                                                <div class="room-card" data-type="${r.categoryName}"
                                                    data-amenities="${r.amenitiesStr}" data-beds="${r.bedsCount}"
                                                    data-price="${r.pricePerNight}" data-popularity="${r.id}"
                                                    data-roomno="${r.roomNumber}" data-images="${r.imagesStr}">

                                                    <div class="room-image-wrap">
                                                        <span class="room-tag">${r.categoryName}</span>

                                                        <c:choose>
                                                            <c:when test="${not empty r.primaryPhoto}">
                                                                <c:set var="rawPhoto" value="${fn:replace(r.primaryPhoto, '\\\\', '/')}" />
                                                                <c:choose>
                                                                    <c:when test="${fn:startsWith(rawPhoto, 'http://') or fn:startsWith(rawPhoto, 'https://')}">
                                                                        <c:set var="photoSrc" value="${rawPhoto}" />
                                                                    </c:when>
                                                                    <c:when test="${fn:startsWith(rawPhoto, '/')}">
                                                                        <c:set var="photoSrc" value="${pageContext.request.contextPath}${rawPhoto}" />
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <c:set var="photoSrc" value="${pageContext.request.contextPath}/${rawPhoto}" />
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <img class="room-main-image" src="${photoSrc}" alt="${r.title}"
                                                                     onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/Image/default_room.jpg';">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:set var="photoSrc" value="${pageContext.request.contextPath}/Image/default_room.jpg" />
                                                                <img class="room-main-image" src="${photoSrc}" alt="${r.title}">
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <c:if test="${fn:length(r.images) > 1}">
                                                            <button type="button" class="gallery-next"
                                                                title="Next Photo" aria-label="Next Photo">
                                                                <i class="bi bi-chevron-right"></i>
                                                            </button>
                                                            <div class="image-dots">
                                                                <c:forEach var="img" items="${r.images}"
                                                                    varStatus="status">
                                                                    <span
                                                                        class="${status.first ? 'active' : ''}"></span>
                                                                </c:forEach>
                                                            </div>
                                                        </c:if>
                                                    </div>

                                                    <div class="room-card-body">
                                                        <div class="room-title-row">
                                                            <div>
                                                                <span class="room-category">${r.categoryName}</span>
                                                                <h3>${r.title}</h3>
                                                            </div>
                                                        </div>

                                                        <c:if test="${not empty r.description}">
                                                            <p class="room-description">${r.description}</p>
                                                        </c:if>

                                                        <div class="room-facts">
                                                            <span><i class="bi bi-door-closed"></i> Room
                                                                ${r.roomNumber}</span>
                                                            <c:if test="${r.capacity > 0}">
                                                                <span><i class="bi bi-people"></i> Up to ${r.capacity}
                                                                    Guests</span>
                                                            </c:if>
                                                            <c:if test="${not empty r.bedType}">
                                                                <span><i class="bi bi-lamp"></i> ${r.bedType}</span>
                                                            </c:if>
                                                            <c:if test="${r.areaSqft > 0}">
                                                                <span><i class="bi bi-arrows-fullscreen"></i>
                                                                    ${r.areaSqft} sq.ft</span>
                                                            </c:if>
                                                        </div>

                                                        <c:if test="${not empty r.amenities}">
                                                            <div class="amenity-pills">
                                                                <c:forEach var="amenity" items="${r.amenities}">
                                                                    <span>${amenity}</span>
                                                                </c:forEach>
                                                            </div>
                                                        </c:if>

                                                        <div class="room-card-footer">
                                                            <div class="price-block">
                                                                <small>Rate</small>
                                                                <strong>₹
                                                                    <fmt:formatNumber value="${r.pricePerNight}"
                                                                        pattern="#,##0" /> <small>/ night</small>
                                                                </strong>
                                                            </div>
                                                            <button type="button" class="view-room-btn btn-open-reservation"
                                                                data-id="${r.id}"
                                                                data-title="${fn:escapeXml(r.title)}"
                                                                data-room-number="${fn:escapeXml(r.roomNumber)}"
                                                                data-price="${r.pricePerNight}"
                                                                data-capacity="${r.capacity}"
                                                                data-category="${fn:escapeXml(r.categoryName)}"
                                                                data-photo="${photoSrc}"
                                                                data-images="${fn:escapeXml(r.imagesStr)}"
                                                                onclick="openReservationFromBtn(this)">
                                                                <i class="bi bi-calendar-check"></i> Book Now
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="empty-state" style="grid-column: 1 / -1;">
                                                <i class="bi bi-inbox"></i>
                                                <h3>No Rooms in Database</h3>
                                                <p>There are no rooms currently recorded in the database inventory.</p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Empty State for Filters -->
                                <div class="empty-state mt-4" id="emptyState" hidden>
                                    <i class="bi bi-funnel"></i>
                                    <h3>No Rooms Match Current Filters</h3>
                                    <p>Try searching different keywords or resetting active dropdown filters.</p>
                                    <button type="button" class="btn-clear-luxury mt-3" id="emptyReset">
                                        <i class="bi bi-arrow-counterclockwise"></i> Reset Filters
                                    </button>
                                </div>
                            </main>

                            <!-- PROPER LUXURY RESERVATION FORM MODAL (PROPER WIDTH & HEIGHT) -->
                            <div class="reservation-modal-overlay" id="reservationModal">
                                <div class="reservation-form-modal">
                                    <!-- Modal Header Strip with Selected Room Info -->
                                    <div class="modal-header-strip">
                                        <div class="modal-header-info">
                                            <div class="modal-room-icon">
                                                <i class="bi bi-door-closed"></i>
                                            </div>
                                            <div>
                                                <h3 class="modal-header-title" id="modalRoomTitle">Reserve Suite</h3>
                                                <p class="modal-header-subtitle" id="modalRoomSubtitle">Room No. -- • ₹0
                                                    / night</p>
                                            </div>
                                        </div>
                                        <button type="button" class="modal-close-btn" onclick="closeReservationModal()"
                                            title="Close Form">&times;</button>
                                    </div>

                                    <!-- Form Content in 2 Balanced Columns with Full Validation -->
                                    <form action="${pageContext.request.contextPath}/guest/room" method="POST"
                                        id="bookingForm" class="modal-body-form"
                                        onsubmit="return validateBookingForm(event)">
                                        <input type="hidden" name="roomId" id="modalRoomId" required>
                                        <input type="hidden" id="modalRoomPrice" value="0">

                                        <!-- Inline Feedback Alert -->
                                        <div id="modalValidationAlert" class="alert alert-danger py-2 px-3 mb-3"
                                            style="display: none; font-size: 0.8rem; border-radius: 8px;"></div>

                                        <div class="form-two-columns">
                                            <!-- Left Column: Input Fields with Proper Placeholders & Validation -->
                                            <div class="form-column-left">
                                                <!-- Section 1: Guest Details (Read-Only when Logged In) -->
                                                <div
                                                    class="form-section-header d-flex justify-content-between align-items-center">
                                                    <span><i class="bi bi-person-badge"></i> Guest Profile
                                                        Details</span>
                                                    <c:if test="${isLoggedIn || not empty sessionScope.userId}">
                                                        <span class="readonly-badge"><i class="bi bi-shield-check"></i>
                                                            Verified Member</span>
                                                    </c:if>
                                                </div>

                                                <c:choose>
                                                    <c:when test="${isLoggedIn || not empty sessionScope.userId}">
                                                        <!-- Logged-in Guest: full_name, email, phone, address (READ ONLY) -->
                                                        <div class="form-field-group" id="groupGuestName">
                                                            <div
                                                                class="d-flex justify-content-between align-items-center mb-1">
                                                                <label class="form-field-label m-0" for="guestName">Full
                                                                    Name</label>
                                                                <span class="readonly-badge"><i
                                                                        class="bi bi-lock-fill"></i> Read Only</span>
                                                            </div>
                                                            <div class="input-with-icon position-relative">
                                                                <i class="bi bi-person"></i>
                                                                <input type="text" id="guestName" name="guestName"
                                                                    value="${not empty guestFullName ? guestFullName : sessionScope.fullName}"
                                                                    readonly class="readonly-field" required
                                                                    minlength="2" maxlength="100"
                                                                    placeholder="Full Name">
                                                                <i class="bi bi-lock-fill readonly-lock-icon"></i>
                                                            </div>
                                                            <span class="input-error-msg">Full name is required.</span>
                                                        </div>

                                                        <div class="row g-2">
                                                            <div class="col-md-6 form-field-group" id="groupGuestEmail">
                                                                <div
                                                                    class="d-flex justify-content-between align-items-center mb-1">
                                                                    <label class="form-field-label m-0"
                                                                        for="guestEmail">Email Address</label>
                                                                    <span class="readonly-badge"><i
                                                                            class="bi bi-lock-fill"></i> Read
                                                                        Only</span>
                                                                </div>
                                                                <div class="input-with-icon position-relative">
                                                                    <i class="bi bi-envelope"></i>
                                                                    <input type="email" id="guestEmail"
                                                                        name="guestEmail"
                                                                        value="${not empty guestEmail ? guestEmail : sessionScope.userEmail}"
                                                                        readonly class="readonly-field" required
                                                                        placeholder="Email Address">
                                                                    <i class="bi bi-lock-fill readonly-lock-icon"></i>
                                                                </div>
                                                                <span class="input-error-msg">Email address is
                                                                    required.</span>
                                                            </div>
                                                            <div class="col-md-6 form-field-group" id="groupGuestPhone">
                                                                <div
                                                                    class="d-flex justify-content-between align-items-center mb-1">
                                                                    <label class="form-field-label m-0"
                                                                        for="guestPhone">Contact Phone</label>
                                                                    <span class="readonly-badge"><i
                                                                            class="bi bi-lock-fill"></i> Read
                                                                        Only</span>
                                                                </div>
                                                                <div class="input-with-icon position-relative">
                                                                    <i class="bi bi-telephone"></i>
                                                                    <input type="tel" id="guestPhone" name="guestPhone"
                                                                        value="${not empty guestPhone ? guestPhone : (not empty sessionScope.phone ? sessionScope.phone : sessionScope.userPhone)}"
                                                                        readonly class="readonly-field" required
                                                                        maxlength="20" placeholder="Phone Number">
                                                                    <i class="bi bi-lock-fill readonly-lock-icon"></i>
                                                                </div>
                                                                <span class="input-error-msg">Phone number is
                                                                    required.</span>
                                                            </div>
                                                        </div>

                                                        <div class="form-field-group" id="groupGuestAddress">
                                                            <div
                                                                class="d-flex justify-content-between align-items-center mb-1">
                                                                <label class="form-field-label m-0"
                                                                    for="guestAddress">Registered Address</label>
                                                                <span class="readonly-badge"><i
                                                                        class="bi bi-lock-fill"></i> Read Only</span>
                                                            </div>
                                                            <div class="input-with-icon position-relative">
                                                                <i class="bi bi-geo-alt"></i>
                                                                <textarea id="guestAddress" name="guestAddress" rows="2"
                                                                    readonly class="readonly-field"
                                                                    placeholder="No registered address on profile">${not empty guestAddress ? guestAddress : (not empty sessionScope.address ? sessionScope.address : sessionScope.userAddress)}</textarea>
                                                                <i
                                                                    class="bi bi-lock-fill readonly-lock-icon readonly-textarea-icon"></i>
                                                            </div>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <!-- Not logged in: Prompt to sign in -->
                                                        <div class="p-3 rounded mb-3 text-center"
                                                            style="background: rgba(197, 160, 89, 0.08); border: 1px dashed rgba(197, 160, 89, 0.35);">
                                                            <i class="bi bi-person-lock fs-2 d-block mb-1"
                                                                style="color: #c5a059;"></i>
                                                            <h6 class="text-white mb-1">Authentication Required</h6>
                                                            <p class="small mb-2" style="color: #cbd5e1;">Please sign in
                                                                to your
                                                                GrandStay account to book. Your verified details (Full
                                                                Name, Email, Phone, Address) will automatically load
                                                                here as read-only.</p>
                                                            <a href="${pageContext.request.contextPath}/login.jsp"
                                                                class="btn btn-gold-luxury btn-sm px-3 py-1 text-decoration-none d-inline-flex align-items-center gap-1">
                                                                <i class="bi bi-box-arrow-in-right"></i> Sign In to
                                                                Reserve
                                                            </a>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>

                                                <!-- Section 2: Dates & Occupancy -->
                                                <div class="form-section-header">
                                                    <i class="bi bi-calendar3"></i> Stay Dates &amp; Occupancy
                                                </div>

                                                <div class="row g-2">
                                                    <div class="col-md-6 form-field-group" id="groupCheckIn">
                                                        <label class="form-field-label" for="checkIn">Check-In Date
                                                            *</label>
                                                        <div class="input-with-icon">
                                                            <i class="bi bi-calendar-check"></i>
                                                            <input type="date" id="checkIn" name="checkIn" required>
                                                        </div>
                                                        <span class="input-error-msg">Check-in date cannot be in the
                                                            past.</span>
                                                    </div>
                                                    <div class="col-md-6 form-field-group" id="groupCheckOut">
                                                        <label class="form-field-label" for="checkOut">Check-Out Date
                                                            *</label>
                                                        <div class="input-with-icon">
                                                            <i class="bi bi-calendar-x"></i>
                                                            <input type="date" id="checkOut" name="checkOut" required>
                                                        </div>
                                                        <span class="input-error-msg">Check-out must be after check-in
                                                            date.</span>
                                                    </div>
                                                </div>

                                                <div class="form-field-group" id="groupGuestsCount">
                                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                                        <label class="form-field-label m-0" for="guestsCount">Number of
                                                            Guests *</label>
                                                        <small class="text-gold" id="modalCapacityNotice"
                                                            style="font-size: 0.72rem;">Max Capacity: 1 Guest</small>
                                                    </div>
                                                    <div class="input-with-icon">
                                                        <i class="bi bi-people"></i>
                                                        <input type="number" id="guestsCount" name="guestsCount" min="1"
                                                            value="1" required placeholder="1">
                                                    </div>
                                                    <span class="input-error-msg">Guest count exceeds room maximum
                                                        capacity.</span>
                                                </div>

                                                <!-- Section 3: Special Requests -->
                                                <div class="form-section-header">
                                                    <i class="bi bi-chat-left-text"></i> Additional Preferences
                                                </div>

                                                <div class="form-field-group">
                                                    <label class="form-field-label" for="specialRequests">Special
                                                        Requests (Optional)</label>
                                                    <div class="input-with-icon">
                                                        <i class="bi bi-card-text"></i>
                                                        <textarea id="specialRequests" name="specialRequests" rows="2"
                                                            maxlength="500"
                                                            placeholder="e.g. Quiet floor preferred, early check-in (approx 2 PM), high floor..."></textarea>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Right Column: Room Details, Cost Breakdown & Confirm -->
                                            <div class="form-column-right">
                                                <!-- Selected Room Details Card with All Room Photos -->
                                                <div class="selected-room-mini-card">
                                                    <div style="width: 100%; height: 165px; border-radius: 10px; overflow: hidden; margin-bottom: 10px; border: 1px solid rgba(197, 160, 89, 0.35); background: #06080d; position: relative; box-shadow: 0 4px 16px rgba(0,0,0,0.6);">
                                                        <img id="modalMiniRoomImage" src="${pageContext.request.contextPath}/Image/default_room.jpg" alt="Selected Suite" style="width: 100%; height: 100%; object-fit: cover; display: block;" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/Image/default_room.jpg';">
                                                        <span class="mini-card-tag" id="modalRoomCategory" style="position: absolute; top: 10px; left: 10px; margin: 0; background: rgba(10, 13, 20, 0.9); backdrop-filter: blur(4px); border: 1px solid rgba(197, 160, 89, 0.35);">SUITE</span>
                                                        <span id="modalImageCounter" style="position: absolute; bottom: 8px; right: 10px; font-size: 11px; font-weight: 600; background: rgba(0,0,0,0.8); color: var(--gold-light); padding: 3px 9px; border-radius: 12px; border: 1px solid rgba(197, 160, 89, 0.3); display: none;">1 / 1</span>
                                                    </div>

                                                    <!-- Gallery Thumbnail Strip for ALL Images of this selected room -->
                                                    <div id="modalGalleryStrip" style="display: none; margin-bottom: 12px;">
                                                        <div style="font-size: 11px; text-transform: uppercase; color: var(--gold-light); letter-spacing: 0.5px; margin-bottom: 6px; font-weight: 600;">
                                                            <i class="bi bi-images me-1"></i> Suite Photo Gallery (<span id="modalPhotoCount">0</span>)
                                                        </div>
                                                        <div id="modalGalleryThumbnails" style="display: flex; gap: 8px; overflow-x: auto; padding-bottom: 6px; scrollbar-width: thin;"></div>
                                                    </div>

                                                    <h4 class="mini-card-title" id="modalMiniRoomTitle" style="font-size: 1.15rem; margin-bottom: 6px; color: #fff;">Selected Suite</h4>
                                                    <div class="mini-card-facts">
                                                        <span id="modalMiniRoomNumber"><i class="bi bi-door-closed"></i> Room --</span>
                                                        <span id="modalMiniCapacity"><i class="bi bi-people"></i> Max 1 Guest</span>
                                                    </div>
                                                </div>

                                                <!-- Live Stay Summary Card -->
                                                <div class="stay-summary-card">
                                                    <div class="summary-line">
                                                        <span>Nightly Rate:</span>
                                                        <strong id="summaryRate">₹0.00</strong>
                                                    </div>
                                                    <div class="summary-line">
                                                        <span>Stay Duration:</span>
                                                        <strong id="summaryNights">0 Night(s)</strong>
                                                    </div>
                                                    <div class="summary-line">
                                                        <span>Taxes &amp; Service Charges:</span>
                                                        <strong class="text-success">Included</strong>
                                                    </div>
                                                    <div class="summary-grand-total">
                                                        <span class="grand-total-label">Total Estimated Cost:</span>
                                                        <span class="grand-total-price" id="summaryTotal">₹0.00</span>
                                                    </div>
                                                </div>

                                                <!-- Modal Actions -->
                                                <div class="modal-actions-col">
                                                    <c:choose>
                                                        <c:when test="${isLoggedIn || not empty sessionScope.userId}">
                                                            <button type="submit" class="btn-modal-confirm"
                                                                id="btnSubmitBooking">
                                                                <i class="bi bi-shield-check"></i> Complete Reservation
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="${pageContext.request.contextPath}/login.jsp"
                                                                class="btn-modal-confirm text-center text-decoration-none py-2 d-inline-flex align-items-center justify-content-center gap-2">
                                                                <i class="bi bi-box-arrow-in-right"></i> Sign In to
                                                                Reserve
                                                            </a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <button type="button" class="btn-modal-cancel"
                                                        onclick="closeReservationModal()">
                                                        Cancel
                                                    </button>
                                                </div>

                                                <div class="secure-guarantee-note">
                                                    <i class="bi bi-lock-fill"></i> Instant Confirmation • No Hidden
                                                    Fees
                                                </div>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- Footer -->
                            <footer class="site-footer">
                                <a class="footer-brand" href="#">GRANDSTAY<span>HOTEL &amp; RESIDENCES</span></a>
                                <small class="d-block mt-2" style="color: #94a3b8;">&copy;
                                    <%=java.time.Year.now().getValue()%>
                                        GrandStay Hotel. All rights reserved.
                                </small>
                            </footer>

                            <!-- Bootstrap JS Bundle -->
                            <script
                                src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

                            <!-- Custom Guest Room Filtering & Interactions Script -->
                            <script>
                                window.CONTEXT_PATH = "${pageContext.request.contextPath}";
                            </script>
                            <script src="${pageContext.request.contextPath}/JS/guest/room.js"></script>

                            <!-- Booking Modal & Form Validation Script -->
                            <script>
                                const resModal = document.getElementById("reservationModal");
                                const modalRoomId = document.getElementById("modalRoomId");
                                const modalRoomPrice = document.getElementById("modalRoomPrice");
                                const modalRoomTitle = document.getElementById("modalRoomTitle");
                                const modalRoomSubtitle = document.getElementById("modalRoomSubtitle");
                                const modalMiniRoomTitle = document.getElementById("modalMiniRoomTitle");
                                const modalMiniRoomNumber = document.getElementById("modalMiniRoomNumber");
                                const modalMiniCapacity = document.getElementById("modalMiniCapacity");
                                const modalRoomCategory = document.getElementById("modalRoomCategory");
                                const modalCapacityNotice = document.getElementById("modalCapacityNotice");
                                const guestsCountInput = document.getElementById("guestsCount");
                                const checkInInput = document.getElementById("checkIn");
                                const checkOutInput = document.getElementById("checkOut");
                                const summaryRate = document.getElementById("summaryRate");
                                const summaryNights = document.getElementById("summaryNights");
                                const summaryTotal = document.getElementById("summaryTotal");
                                const modalAlert = document.getElementById("modalValidationAlert");
                                const btnSubmit = document.getElementById("btnSubmitBooking");

                                let currentRoomMaxCapacity = 1;
                                const isUserLoggedIn = <%= (session != null && (session.getAttribute("userId") != null || session.getAttribute("userEmail") != null)) ? "true" : "false" %>;

                                const todayStr = new Date().toISOString().split("T")[0];
                                checkInInput.min = todayStr;

                                function openReservationFromBtn(btn) {
                                    if (!btn) return;
                                    const d = btn.dataset;
                                    openReservationModal(d.id, d.title, d.roomNumber, d.price, d.capacity, d.category, d.photo, d.images);
                                }

                                function selectModalPhoto(el, url, current, total) {
                                    const miniImg = document.getElementById("modalMiniRoomImage");
                                    if (miniImg) miniImg.src = url;
                                    document.querySelectorAll(".modal-thumb-item").forEach(item => {
                                        item.style.borderColor = "rgba(197, 160, 89, 0.25)";
                                        item.classList.remove("active");
                                    });
                                    if (el) {
                                        el.style.borderColor = "var(--gold-primary)";
                                        el.classList.add("active");
                                    }
                                    const counterEl = document.getElementById("modalImageCounter");
                                    if (counterEl) counterEl.innerText = current + " / " + total;
                                }

                                function openReservationModal(roomId, title, roomNumber, pricePerNight, capacity, category, photo, imagesStr) {
                                    if (!isUserLoggedIn) {
                                        window.location.href = "${pageContext.request.contextPath}/login.jsp";
                                        return;
                                    }

                                    modalRoomId.value = roomId;
                                    modalRoomPrice.value = pricePerNight;
                                    modalRoomTitle.innerText = "Book " + title;
                                    modalRoomSubtitle.innerText = "Room No. " + roomNumber + " • ₹" + Number(pricePerNight).toLocaleString('en-IN') + " / night";

                                    const miniImg = document.getElementById("modalMiniRoomImage");
                                    const galleryStrip = document.getElementById("modalGalleryStrip");
                                    const thumbsContainer = document.getElementById("modalGalleryThumbnails");
                                    const counterEl = document.getElementById("modalImageCounter");
                                    const countEl = document.getElementById("modalPhotoCount");

                                    const ctx = "${pageContext.request.contextPath}";
                                    function resolveImg(src) {
                                        if (!src) return ctx + "/Image/default_room.jpg";
                                        src = String(src).trim().replace(/\\/g, '/');
                                        if (src.startsWith('http://') || src.startsWith('https://')) return src;
                                        if (src.startsWith(ctx)) return src;
                                        if (src.startsWith('/')) return ctx + src;
                                        return ctx + '/' + src;
                                    }

                                    let imagesList = [];
                                    if (imagesStr && imagesStr.trim().length > 0) {
                                        imagesList = imagesStr.split(',').map(s => s.trim().replace(/\\/g, '/')).filter(Boolean);
                                    }
                                    if (!imagesList.length && photo && photo.trim().length > 0) {
                                        imagesList = [photo];
                                    }
                                    // Deduplicate and resolve
                                    imagesList = [...new Set(imagesList)].map(resolveImg);

                                    if (miniImg) {
                                        miniImg.src = imagesList.length > 0 ? imagesList[0] : (ctx + "/Image/default_room.jpg");
                                    }

                                    if (imagesList.length > 1 && thumbsContainer && galleryStrip) {
                                        galleryStrip.style.display = "block";
                                        if (counterEl) {
                                            counterEl.style.display = "inline-block";
                                            counterEl.innerText = "1 / " + imagesList.length;
                                        }
                                        if (countEl) {
                                            countEl.innerText = imagesList.length;
                                        }

                                        thumbsContainer.innerHTML = imagesList.map((imgUrl, idx) => `
                                            <div style="width: 58px; height: 44px; border-radius: 6px; overflow: hidden; border: 2px solid ` + (idx === 0 ? 'var(--gold-primary)' : 'rgba(197, 160, 89, 0.25)') + `; cursor: pointer; flex-shrink: 0; background: #06080d; transition: all 0.2s ease;"
                                                 class="modal-thumb-item ` + (idx === 0 ? 'active' : '') + `"
                                                 onclick="selectModalPhoto(this, '` + imgUrl + `', ` + (idx + 1) + `, ` + imagesList.length + `)">
                                                <img src="` + imgUrl + `" style="width: 100%; height: 100%; object-fit: cover; display: block;" onerror="this.onerror=null; this.src='` + ctx + `/Image/default_room.jpg';">
                                            </div>
                                        `).join('');
                                    } else {
                                        if (galleryStrip) galleryStrip.style.display = "none";
                                        if (counterEl) counterEl.style.display = "none";
                                    }

                                    if (modalMiniRoomTitle)
                                        modalMiniRoomTitle.innerText = title;
                                    if (modalMiniRoomNumber)
                                        modalMiniRoomNumber.innerHTML = '<i class="bi bi-door-closed"></i> Room ' + roomNumber;
                                    if (modalRoomCategory)
                                        modalRoomCategory.innerText = category || 'ACCOMMODATION';

                                    currentRoomMaxCapacity = parseInt(capacity) || 1;
                                    guestsCountInput.max = currentRoomMaxCapacity;
                                    guestsCountInput.value = 1;
                                    if (modalMiniCapacity)
                                        modalMiniCapacity.innerHTML = '<i class="bi bi-people"></i> Max ' + currentRoomMaxCapacity + ' Guest(s)';
                                    modalCapacityNotice.innerText = "Maximum Capacity: " + currentRoomMaxCapacity + " Guest(s)";

                                    checkInInput.value = "";
                                    checkOutInput.value = "";
                                    checkOutInput.min = todayStr;

                                    summaryRate.innerText = "₹" + Number(pricePerNight).toLocaleString('en-IN');
                                    summaryNights.innerText = "0 Night(s)";
                                    summaryTotal.innerText = "₹0.00";

                                    hideValidationAlert();
                                    document.querySelectorAll('.has-validation-error').forEach(el => el.classList.remove('has-validation-error'));

                                    resModal.style.display = "grid";
                                }

                                function closeReservationModal() {
                                    resModal.style.display = "none";
                                    hideValidationAlert();
                                }

                                window.addEventListener("click", function (event) {
                                    if (event.target === resModal) {
                                        closeReservationModal();
                                    }
                                });

                                function calculateStayCost() {
                                    const rate = parseFloat(modalRoomPrice.value) || 0;
                                    const inVal = checkInInput.value;
                                    const outVal = checkOutInput.value;

                                    if (inVal) {
                                        const nextDay = new Date(inVal);
                                        nextDay.setDate(nextDay.getDate() + 1);
                                        checkOutInput.min = nextDay.toISOString().split("T")[0];
                                    }

                                    if (inVal && outVal) {
                                        const inDate = new Date(inVal);
                                        const outDate = new Date(outVal);

                                        if (outDate > inDate) {
                                            const diffTime = Math.abs(outDate - inDate);
                                            const nights = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                                            const total = nights * rate;

                                            summaryNights.innerText = nights + (nights === 1 ? " Night" : " Nights");
                                            summaryTotal.innerText = "₹" + total.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                                            return;
                                        }
                                    }

                                    summaryNights.innerText = "0 Night(s)";
                                    summaryTotal.innerText = "₹0.00";
                                }

                                checkInInput.addEventListener("change", calculateStayCost);
                                checkOutInput.addEventListener("change", calculateStayCost);

                                function showValidationAlert(msg) {
                                    if (modalAlert) {
                                        modalAlert.innerHTML = '<i class="bi bi-exclamation-octagon-fill me-1"></i> ' + msg;
                                        modalAlert.style.display = "block";
                                    }
                                }

                                function hideValidationAlert() {
                                    if (modalAlert) {
                                        modalAlert.style.display = "none";
                                    }
                                }

                                // Real-Time Form Validation Engine
                                function validateBookingForm(e) {
                                    hideValidationAlert();
                                    document.querySelectorAll('.has-validation-error').forEach(el => el.classList.remove('has-validation-error'));

                                    const nameInput = document.getElementById("guestName");
                                    const emailInput = document.getElementById("guestEmail");
                                    const phoneInput = document.getElementById("guestPhone");
                                    const inVal = checkInInput.value;
                                    const outVal = checkOutInput.value;
                                    const guests = parseInt(guestsCountInput.value) || 0;

                                    // 1. Validate Name
                                    if (!nameInput || !nameInput.value.trim()) {
                                        e.preventDefault();
                                        if (document.getElementById("groupGuestName"))
                                            document.getElementById("groupGuestName").classList.add("has-validation-error");
                                        showValidationAlert("Full name is required from your profile.");
                                        return false;
                                    }

                                    // 2. Validate Email
                                    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
                                    if (!emailInput || !emailInput.value.trim() || !emailRegex.test(emailInput.value.trim())) {
                                        e.preventDefault();
                                        if (document.getElementById("groupGuestEmail"))
                                            document.getElementById("groupGuestEmail").classList.add("has-validation-error");
                                        showValidationAlert("A valid email address is required from your profile.");
                                        return false;
                                    }

                                    // 3. Validate Phone
                                    if (!phoneInput || !phoneInput.value.trim()) {
                                        e.preventDefault();
                                        if (document.getElementById("groupGuestPhone"))
                                            document.getElementById("groupGuestPhone").classList.add("has-validation-error");
                                        showValidationAlert("A contact phone number is required from your profile.");
                                        return false;
                                    }

                                    // 4. Validate Check-in Date
                                    if (!inVal) {
                                        e.preventDefault();
                                        document.getElementById("groupCheckIn").classList.add("has-validation-error");
                                        showValidationAlert("Please select your check-in date.");
                                        checkInInput.focus();
                                        return false;
                                    }
                                    if (inVal < todayStr) {
                                        e.preventDefault();
                                        document.getElementById("groupCheckIn").classList.add("has-validation-error");
                                        showValidationAlert("Check-in date cannot be in the past.");
                                        checkInInput.focus();
                                        return false;
                                    }

                                    // 5. Validate Check-out Date
                                    if (!outVal) {
                                        e.preventDefault();
                                        document.getElementById("groupCheckOut").classList.add("has-validation-error");
                                        showValidationAlert("Please select your check-out date.");
                                        checkOutInput.focus();
                                        return false;
                                    }
                                    if (outVal <= inVal) {
                                        e.preventDefault();
                                        document.getElementById("groupCheckOut").classList.add("has-validation-error");
                                        showValidationAlert("Check-out date must be strictly after the check-in date (minimum 1 night).");
                                        checkOutInput.focus();
                                        return false;
                                    }

                                    // 6. Validate Guest Capacity
                                    if (guests < 1) {
                                        e.preventDefault();
                                        document.getElementById("groupGuestsCount").classList.add("has-validation-error");
                                        showValidationAlert("Number of guests must be at least 1.");
                                        guestsCountInput.focus();
                                        return false;
                                    }
                                    if (guests > currentRoomMaxCapacity) {
                                        e.preventDefault();
                                        document.getElementById("groupGuestsCount").classList.add("has-validation-error");
                                        showValidationAlert("Guest count exceeds the room's maximum capacity of " + currentRoomMaxCapacity + " guest(s).");
                                        guestsCountInput.focus();
                                        return false;
                                    }

                                    // Show submitting state
                                    if (btnSubmit) {
                                        btnSubmit.disabled = true;
                                        btnSubmit.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Confirming Reservation...';
                                    }
                                    return true;
                                }
                            </script>
                        </body>

                        </html>