<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="AuthServlet.DBconnection"%>
<%@page import="AuthServlet.Admin.room.RoomTypeBean"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<%
    /* If accessed directly without passing through servlet, forward to AdminRoomServlet */
    if (request.getAttribute("rooms") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/rooms");
        return;
    }

    List<RoomTypeBean> typeList = (List<RoomTypeBean>) request.getAttribute("roomTypes");
    if (typeList == null || typeList.isEmpty()) {
        typeList = new ArrayList<RoomTypeBean>();
        try (Connection con = DBconnection.getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement("SELECT id, name FROM room_types ORDER BY id ASC");
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        typeList.add(new RoomTypeBean(rs.getInt("id"), rs.getString("name")));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        pageContext.setAttribute("dbCategories", typeList);
    } else {
        pageContext.setAttribute("dbCategories", typeList);
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Room Inventory | GrandStay Admin</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/admin/slider.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/admin/room.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/modal.css">
        <style>
            .room-thumb-cell {
                display: flex;
                align-items: center;
                gap: 12px;
            }
            .room-thumb {
                width: 48px;
                height: 48px;
                border-radius: var(--radius-sm);
                object-fit: cover;
                border: 1px solid var(--border-subtle);
                background: var(--bg-dark);
                flex-shrink: 0;
            }
            .file-dropzone {
                border: 2px dashed var(--border-color);
                border-radius: var(--radius-md);
                padding: 20px;
                text-align: center;
                background: var(--bg-dark);
                cursor: pointer;
                transition: var(--transition-smooth);
                position: relative;
            }
            .file-dropzone:hover {
                border-color: var(--gold-light);
                background: rgba(197, 160, 89, 0.05);
            }
            .file-dropzone input[type="file"] {
                position: absolute;
                inset: 0;
                opacity: 0;
                cursor: pointer;
                width: 100%;
                height: 100%;
            }
            .preview-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(70px, 1fr));
                gap: 8px;
                margin-top: 10px;
            }
            .preview-thumb {
                width: 100%;
                height: 70px;
                border-radius: var(--radius-sm);
                object-fit: cover;
                border: 1px solid var(--border-subtle);
            }
            .view-gallery {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
                gap: 10px;
                margin-top: 10px;
            }
            .view-gallery img {
                width: 100%;
                height: 85px;
                object-fit: cover;
                border-radius: var(--radius-sm);
                border: 2px solid transparent;
                cursor: pointer;
                transition: all 0.2s ease;
            }
            .view-gallery img:hover, .view-gallery img.active {
                border-color: var(--gold-primary);
                transform: translateY(-2px);
            }
        </style>
    </head>
    <body>

        <!-- Sidebar Component -->
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
                        <span>Update Profile</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/logout" class="nav-btn logout" title="Sign out of account">
                        <i class="bi bi-box-arrow-right"></i>
                        <span>Logout</span>
                    </a>
                </div>
            </header>

            <main>
                <div class="top">
                    <div>
                        <h1>Room Inventory</h1>
                        <p>Inspect specifications, configure amenities, and manage room allocations.</p>
                    </div>
                    <div style="display: flex; gap: 10px; align-items: center;">
                        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn">
                            <i class="bi bi-speedometer2"></i> Dashboard
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/customers" class="btn">
                            <i class="bi bi-people"></i> Guests Directory
                        </a>
                        <button class="btn primary" id="addBtn" type="button">
                            <i class="bi bi-plus-lg"></i>Add Room
                        </button>
                    </div>
                </div>

                <!-- Server-Side Metric Summaries -->
                <div class="summary" id="summary">
                    <button class="sum on" data-s="" type="button">
                        <i class="dot"></i>
                        <div><b id="countTotal">${totalRooms != null ? totalRooms : 0}</b><span>Total Rooms</span></div>
                    </button>
                    <button class="sum" data-s="Available" type="button">
                        <i class="dot Available"></i>
                        <div><b id="countAvail">${availableCount != null ? availableCount : 0}</b><span>Available</span></div>
                    </button>
                    <button class="sum" data-s="Booked" type="button">
                        <i class="dot Booked"></i>
                        <div><b id="countBooked">${bookedCount != null ? bookedCount : 0}</b><span>Booked</span></div>
                    </button>
                    <button class="sum" data-s="Maintenance" type="button">
                        <i class="dot Maintenance"></i>
                        <div><b id="countMaint">${maintenanceCount != null ? maintenanceCount : 0}</b><span>Under Maintenance</span></div>
                    </button>
                </div>

                <!-- Control Bar & Search -->
                <section class="panel">
                    <div class="bar">
                        <div class="field">
                            <i class="bi bi-search"></i>
                            <input id="q" type="search" placeholder="Search room no., title, or bed..." aria-label="Search rooms">
                        </div>
                        <select id="fType" aria-label="Filter by category">
                            <option value="">All Categories</option>
                            <c:forEach var="t" items="${dbCategories}">
                                <option value="${t.id}">${t.name}</option>
                            </c:forEach>
                        </select>
                        <select id="fStatus" aria-label="Filter by availability">
                            <option value="">All Availability</option>
                            <option value="Available">Available</option>
                            <option value="Booked">Booked</option>
                            <option value="Maintenance">Maintenance</option>
                        </select>
                        <button class="btn ghost sm" id="reset" type="button"><i class="bi bi-x-circle"></i>Clear</button>
                        <span class="count" id="count" aria-live="polite">${totalRooms != null ? totalRooms : 0} of ${totalRooms != null ? totalRooms : 0} rooms</span>
                    </div>

                    <!-- Room Data Table -->
                    <div class="wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Room</th>
                                    <th>Suite &amp; Description</th>
                                    <th>Category</th>
                                    <th>Nightly Rate</th>
                                    <th>Dimensions &amp; Bed</th>
                                    <th>Status</th>
                                    <th style="text-align:right">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="rows">
                                <c:choose>
                                    <c:when test="${not empty rooms}">
                                        <c:forEach var="r" items="${rooms}">
                                            <tr data-id="${r.id}"
                                                data-number="${r.roomNumber}"
                                                data-title="${r.title}"
                                                data-desc="${r.shortDescription}"
                                                data-type-id="${r.roomTypeId}"
                                                data-type-name="${r.typeName}"
                                                data-price="${r.pricePerNight}"
                                                data-capacity="${r.capacity}"
                                                data-area="${r.areaSqft}"
                                                data-bed="${r.bedType}"
                                                data-status="${r.status}"
                                                data-amenities="${r.amenitiesRaw}"
                                                data-images="${r.imagesRaw}">
                                                <td>
                                                    <div class="room-thumb-cell">
                                                        <c:choose>
                                                            <c:when test="${not empty r.primaryImage}">
                                                                <c:set var="admImg" value="${fn:replace(r.primaryImage, '\\\\', '/')}" />
                                                                <c:choose>
                                                                    <c:when test="${fn:startsWith(admImg, 'http://') or fn:startsWith(admImg, 'https://')}">
                                                                        <c:set var="admImgSrc" value="${admImg}" />
                                                                    </c:when>
                                                                    <c:when test="${fn:startsWith(admImg, '/')}">
                                                                        <c:set var="admImgSrc" value="${pageContext.request.contextPath}${admImg}" />
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <c:set var="admImgSrc" value="${pageContext.request.contextPath}/${admImg}" />
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <img class="room-thumb" src="${admImgSrc}" alt="Room ${r.roomNumber}"
                                                                     onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/Image/default_room.jpg';">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <img class="room-thumb" src="${pageContext.request.contextPath}/Image/default_room.jpg" alt="Room ${r.roomNumber}">
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <span class="num">${r.roomNumber}</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="title">${r.title}</div>
                                                    <div class="sub">${r.shortDescription}</div>
                                                </td>
                                                <td class="type">${r.typeName}</td>
                                                <td class="price">
                                                    ₹<fmt:formatNumber value="${r.pricePerNight}" type="number" maxFractionDigits="0"/>
                                                    <small>per night</small>
                                                </td>
                                                <td class="meta">
                                                    <b>${r.capacity}</b> guests · <b>${r.areaSqft}</b> sq.ft.<br>${r.bedType}
                                                </td>
                                                <td><span class="badge ${r.status}">${r.status}</span></td>
                                                <td>
                                                    <div class="acts">
                                                        <button class="ic action-view" type="button" title="View Specifications"><i class="bi bi-eye"></i></button>
                                                        <button class="ic action-edit" type="button" title="Edit Room"><i class="bi bi-pencil"></i></button>

                                                        <form action="${pageContext.request.contextPath}/admin/rooms" method="POST" style="margin:0; display:inline;">
                                                            <input type="hidden" name="action" value="toggle">
                                                            <input type="hidden" name="room_id" value="${r.id}">
                                                            <input type="hidden" name="current_status" value="${r.status}">
                                                            <button class="ic" type="submit" title="${r.status == 'Maintenance' ? 'Mark Available' : 'Switch to Maintenance'}">
                                                                <i class="bi ${r.status == 'Maintenance' ? 'bi-check2-circle' : 'bi-tools'}"></i>
                                                            </button>
                                                        </form>

                                                        <button class="ic del action-del" type="button" title="Delete Room"><i class="bi bi-trash"></i></button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" style="text-align:center; padding: 48px; color: var(--text-muted)">
                                                No rooms configured yet. Click "Add Room" to create one.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                        <div class="empty" id="empty" hidden>
                            <b>No rooms match criteria</b>Adjust search keywords or reset filter.
                        </div>
                    </div>
                </section>
            </main>
        </div>

        <!-- Add / Edit Modal -->
        <dialog id="editDlg" aria-labelledby="dlgTitle">
            <form id="form" action="${pageContext.request.contextPath}/admin/rooms" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="room_id" id="editRoomId" value="">

                <div class="mh">
                    <div class="mh-title">
                        <div class="mh-icon"><i class="bi bi-door-open"></i></div>
                        <div>
                            <h2 id="dlgTitle">Add Room</h2>
                            <p id="dlgSub">Provide suite specifications, amenities, and photos.</p>
                        </div>
                    </div>
                    <button class="x" type="button" data-close aria-label="Close dialog"><i class="bi bi-x-lg"></i></button>
                </div>

                <div class="mb">
                    <div class="fields-col">
                        <div class="group"><i class="bi bi-info-circle"></i>Identification</div>

                        <label>Room Number
                            <div class="input-wrap">
                                <i class="bi bi-hash"></i>
                                <input name="room_number" id="inRoomNumber" required placeholder="e.g. D-101, E-201, PH-01">
                            </div>
                        </label>

                        <label>Category
                            <div class="input-wrap">
                                <i class="bi bi-tag"></i>
                                <select name="room_type_id" id="fTypeForm" required>
                                    <option value="" disabled selected>-- Select Category --</option>
                                    <c:forEach var="t" items="${dbCategories}">
                                        <option value="${t.id}">${t.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </label>

                        <label class="full">Room Title
                            <div class="input-wrap">
                                <i class="bi bi-fonts"></i>
                                <input name="title" id="inTitle" required placeholder="e.g. Deluxe City View, Royal Presidential Suite">
                            </div>
                        </label>

                        <label class="full">Summary
                            <div class="input-wrap">
                                <i class="bi bi-card-text"></i>
                                <input name="short_description" id="inDesc" maxlength="255" required placeholder="e.g. Panoramic sea view, marble bath, and private terrace lounge">
                            </div>
                        </label>

                        <div class="group"><i class="bi bi-sliders"></i>Specifications &amp; Rates</div>

                        <label>Price per Night (₹)
                            <div class="input-wrap">
                                <i class="bi bi-currency-rupee"></i>
                                <input name="price_per_night" id="inPrice" type="number" min="0" step="1" required placeholder="e.g. 4500">
                            </div>
                        </label>

                        <label>Guest Capacity
                            <div class="input-wrap">
                                <i class="bi bi-people"></i>
                                <input name="capacity" id="inCapacity" type="number" min="1" max="10" required placeholder="e.g. 2">
                            </div>
                        </label>

                        <label>Floor Area (sq.ft.)
                            <div class="input-wrap">
                                <i class="bi bi-aspect-ratio"></i>
                                <input name="area_sqft" id="inArea" type="number" min="1" required placeholder="e.g. 350">
                            </div>
                        </label>

                        <label>Bed Configuration
                            <div class="input-wrap">
                                <i class="bi bi-moon-stars"></i>
                                <input name="bed_type" id="inBed" required placeholder="e.g. 1 King Bed, 2 Twin Beds">
                            </div>
                        </label>

                        <label class="full">Initial Availability Status
                            <div class="input-wrap">
                                <i class="bi bi-shield-check"></i>
                                <select name="status" id="inStatus" required>
                                    <option value="Available">Available</option>
                                    <option value="Maintenance">Maintenance</option>
                                </select>
                            </div>
                        </label>

                        <!-- Multi-Photo Upload Section -->
                        <div class="group"><i class="bi bi-images"></i>Room Gallery &amp; Photos</div>
                        <div class="full">
                            <div class="file-dropzone" id="dropzone">
                                <i class="bi bi-cloud-arrow-up" style="font-size: 28px; color: var(--gold-light);"></i>
                                <div style="font-weight:600; margin-top:6px; color:#fff;">Click or Drag Photos Here</div>
                                <div style="font-size:12px; color:var(--text-muted);">Upload multiple PNG, JPG, or WEBP photos (Max 10MB each)</div>
                                <input type="file" name="room_photos" id="roomPhotos" multiple accept="image/*">
                            </div>
                            <div class="preview-grid" id="newImagePreviews"></div>
                            <div id="existingImageSection" style="margin-top: 10px;" hidden>
                                <div style="font-size:11px; text-transform:uppercase; color:var(--text-dim); margin-bottom:4px;">Existing Uploaded Photos</div>
                                <div class="preview-grid" id="existingImagePreviews"></div>
                            </div>
                        </div>

                        <div class="group">Included Amenities</div>
                        <div class="spec-grid" id="amenityOptions"></div>
                        <div class="add-amenity-bar" style="margin-top: 12px; display: flex; gap: 8px; align-items: center;">
                            <input type="text" id="customAmenityInput" placeholder="Add custom amenity (e.g. Jacuzzi, Ocean View, Hair Dryer)..." style="flex: 1; padding: 9px 12px; background: var(--bg-surface-elevated); border: 1px solid var(--border-subtle); border-radius: var(--radius-sm); color: #fff; font-size: 13px;">
                            <button type="button" class="btn" id="addCustomAmenityBtn" style="padding: 9px 16px; font-size: 13px; white-space: nowrap;">
                                Add Amenity
                            </button>
                        </div>
                    </div>
                </div>

                <div class="mf">
                    <button class="btn ghost" type="button" data-close>Cancel</button>
                    <button class="btn primary" type="submit" id="saveBtn">Save Room</button>
                </div>
            </form>
        </dialog>

        <!-- View Specifications Modal -->
        <dialog id="viewDlg" aria-labelledby="viewTitle">
            <div class="mh">
                <div class="mh-title">
                    <div class="mh-icon"><i class="bi bi-eye"></i></div>
                    <div>
                        <h2 id="viewTitle">Room Specifications</h2>
                        <p>Complete amenity highlights, photos, and suite parameters.</p>
                    </div>
                </div>
                <button class="x" type="button" data-close aria-label="Close dialog"><i class="bi bi-x-lg"></i></button>
            </div>
            <div class="view-body">
                <!-- Prominent Room Photo Display -->
                <div class="view-photo-container" style="margin-bottom: 16px;">
                    <div style="width: 100%; height: 260px; border-radius: var(--radius-sm); overflow: hidden; border: 1px solid var(--border-subtle); background: #0c0f16; position: relative;">
                        <img id="vHeroPhoto" src="${pageContext.request.contextPath}/Image/default_room.jpg" alt="Featured Suite Photo" style="width: 100%; height: 100%; object-fit: cover; display: block;" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/Image/default_room.jpg';">
                    </div>
                </div>

                <div class="view-header">
                    <div class="view-title-wrap">
                        <h3 id="vTitle"></h3>
                        <p id="vDesc"></p>
                    </div>
                    <span class="badge" id="vBadge"></span>
                </div>

                <!-- View Gallery Strip -->
                <div>
                    <div class="view-amenities-title"><i class="bi bi-images" style="margin-right:6px"></i>Suite Gallery Photos</div>
                    <div class="view-gallery" id="vGallery"></div>
                </div>

                <div class="specs-cards">
                    <div class="spec-card">
                        <i class="bi bi-currency-rupee"></i>
                        <small>Nightly Rate</small>
                        <span id="vPrice"></span>
                    </div>
                    <div class="spec-card">
                        <i class="bi bi-people"></i>
                        <small>Max Guests</small>
                        <span id="vCapacity"></span>
                    </div>
                    <div class="spec-card">
                        <i class="bi bi-aspect-ratio"></i>
                        <small>Floor Space</small>
                        <span id="vArea"></span>
                    </div>
                    <div class="spec-card">
                        <i class="bi bi-moon-stars"></i>
                        <small>Bed Setup</small>
                        <span id="vBed"></span>
                    </div>
                    <div class="spec-card">
                        <i class="bi bi-tag"></i>
                        <small>Category</small>
                        <span id="vCategory"></span>
                    </div>
                    <div class="spec-card">
                        <i class="bi bi-hash"></i>
                        <small>Room Unit</small>
                        <span id="vNumber"></span>
                    </div>
                </div>
                <div>
                    <div class="view-amenities-title">Included Amenities &amp; Features</div>
                    <div class="view-amenities-tags" id="vAmenities"></div>
                </div>
            </div>
            <div class="mf">
                <button class="btn ghost" type="button" data-close>Close</button>
                <button class="btn primary" type="button" id="vEditBtn"><i class="bi bi-pencil"></i>Edit Specifications</button>
            </div>
        </dialog>

        <!-- Delete Modal -->
        <dialog id="delDlg" aria-labelledby="delTitle">
            <form action="${pageContext.request.contextPath}/admin/rooms" method="POST">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="room_id" id="delRoomId">
                <div class="mh">
                    <div class="mh-title">
                        <div class="mh-icon" style="color:#f19aa8; border-color:#f19aa8"><i class="bi bi-trash3"></i></div>
                        <div>
                            <h2 id="delTitle">Delete Room</h2>
                            <p>This action cannot be undone.</p>
                        </div>
                    </div>
                    <button class="x" type="button" data-close aria-label="Close dialog"><i class="bi bi-x-lg"></i></button>
                </div>
                <div class="confirm">
                    <div class="warn"><i class="bi bi-exclamation-triangle"></i></div>
                    <p id="delText"></p>
                </div>
                <div class="mf">
                    <button class="btn ghost" type="button" data-close>Cancel</button>
                    <button class="btn danger" type="submit" id="delOk"><i class="bi bi-trash"></i>Confirm Delete</button>
                </div>
            </form>
        </dialog>

        <!-- Toast Notifications -->
        <div class="toast" id="toast" role="status"></div>

        <script>
            window.CONTEXT_PATH = "${pageContext.request.contextPath}";
        </script>
        <c:if test="${not empty sessionScope.toastMsg}">
            <script>
                window.SERVER_MESSAGE = "${sessionScope.toastMsg}";
            </script>
            <c:remove var="toastMsg" scope="session"/>
        </c:if>

        <script src="${pageContext.request.contextPath}/JS/admin/room.js"></script>
    </body>
</html>