package AuthServlet.guest;

import AuthServlet.DBconnection;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/guest/room", "/rooms", "/rooms.jsp", "/guest/rooms", "/room", "/room.jsp"})
public class room extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Map<String, Object>> roomList = new ArrayList<>();
        List<Map<String, Object>> roomTypeList = new ArrayList<>();
        List<String> availableAmenities = new ArrayList<>();

        Connection conn = null;
        try {
            conn = DBconnection.getConnection();
            if (conn == null) {
                request.setAttribute("errorMessage", "Database connection is unavailable. Please verify MySQL service.");
                request.setAttribute("rooms", roomList);
                request.setAttribute("roomTypes", roomTypeList);
                request.setAttribute("availableAmenities", availableAmenities);
                request.getRequestDispatcher("/guest/room.jsp").forward(request, response);
                return;
            }

            // 1. Fetch ONLY actual room types from the database
            String typeQuery = "SELECT id, name FROM room_types ORDER BY name ASC";
            try (PreparedStatement psType = conn.prepareStatement(typeQuery);
                 ResultSet rsType = psType.executeQuery()) {
                while (rsType.next()) {
                    Map<String, Object> type = new HashMap<>();
                    type.put("id", rsType.getInt("id"));
                    type.put("name", rsType.getString("name"));
                    roomTypeList.add(type);
                }
            } catch (SQLException ex) {
                System.err.println("Notice: Could not load room_types: " + ex.getMessage());
            }

            // 2. Fetch ONLY distinct amenities actually mapped to rooms in the database
            String amenityQuery = "SELECT DISTINCT amenity_code FROM room_amenity_mapping WHERE amenity_code IS NOT NULL AND amenity_code != '' ORDER BY amenity_code ASC";
            try (PreparedStatement psAm = conn.prepareStatement(amenityQuery);
                 ResultSet rsAm = psAm.executeQuery()) {
                while (rsAm.next()) {
                    String code = rsAm.getString("amenity_code");
                    if (code != null && !code.trim().isEmpty()) {
                        availableAmenities.add(code.trim());
                    }
                }
            } catch (SQLException ex) {
                System.err.println("Notice: Could not load room amenities: " + ex.getMessage());
            }

            // 3. Fetch ONLY actual rooms from the database
            String fetchQuery = "SELECT r.id, r.room_number, r.title, r.short_description, "
                              + "       r.price_per_night, r.capacity, r.area_sqft, r.bed_type, r.status, "
                              + "       rt.name AS category_name, "
                              + "       (SELECT image_url FROM room_images WHERE room_id = r.id ORDER BY is_primary DESC, id ASC LIMIT 1) AS primary_photo, "
                              + "       (SELECT GROUP_CONCAT(image_url ORDER BY is_primary DESC, id ASC) FROM room_images WHERE room_id = r.id) AS images_str, "
                              + "       (SELECT GROUP_CONCAT(DISTINCT amenity_code) FROM room_amenity_mapping WHERE room_id = r.id) AS amenities_str "
                              + "FROM rooms r "
                              + "LEFT JOIN room_types rt ON r.room_type_id = rt.id "
                              + "WHERE r.status != 'Maintenance' "
                              + "ORDER BY r.id ASC";

            try (PreparedStatement ps = conn.prepareStatement(fetchQuery);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Map<String, Object> roomMap = new HashMap<>();
                    int id = rs.getInt("id");
                    roomMap.put("id", id);
                    roomMap.put("roomNumber", rs.getString("room_number") != null ? rs.getString("room_number") : "");
                    roomMap.put("title", rs.getString("title") != null ? rs.getString("title") : "");
                    roomMap.put("description", rs.getString("short_description") != null ? rs.getString("short_description") : "");
                    
                    BigDecimal price = rs.getBigDecimal("price_per_night");
                    if (price == null) {
                        price = BigDecimal.ZERO;
                    }
                    roomMap.put("pricePerNight", price);

                    int capacity = rs.getInt("capacity");
                    roomMap.put("capacity", capacity);
                    roomMap.put("areaSqft", rs.getInt("area_sqft"));
                    
                    String bedType = rs.getString("bed_type");
                    roomMap.put("bedType", bedType != null ? bedType : "");
                    roomMap.put("status", rs.getString("status") != null ? rs.getString("status") : "");
                    
                    String categoryName = rs.getString("category_name");
                    roomMap.put("categoryName", categoryName != null ? categoryName : "Standard");
                    
                    // ONLY use photo from database with normalized path
                    String photo = rs.getString("primary_photo");
                    if (photo != null) {
                        photo = photo.trim().replace("\\", "/");
                    } else {
                        photo = "";
                    }

                    // ONLY use images from database
                    String imagesStr = rs.getString("images_str");
                    List<String> images = new ArrayList<>();
                    if (imagesStr != null && !imagesStr.trim().isEmpty()) {
                        for (String img : imagesStr.split(",")) {
                            String trimmed = img.trim().replace("\\", "/");
                            if (!trimmed.isEmpty()) {
                                images.add(trimmed);
                            }
                        }
                    }
                    if (photo.isEmpty() && !images.isEmpty()) {
                        photo = images.get(0);
                    }
                    roomMap.put("primaryPhoto", photo);
                    roomMap.put("images", images);
                    roomMap.put("imagesStr", String.join(",", images));

                    // ONLY use amenities from database
                    String amenitiesStr = rs.getString("amenities_str");
                    List<String> amenities = new ArrayList<>();
                    if (amenitiesStr != null && !amenitiesStr.trim().isEmpty()) {
                        for (String am : amenitiesStr.split(",")) {
                            String trimmed = am.trim();
                            if (!trimmed.isEmpty()) {
                                amenities.add(trimmed);
                            }
                        }
                    }
                    roomMap.put("amenities", amenities);
                    roomMap.put("amenitiesStr", String.join(" ", amenities));

                    // Bed count calculation from bedType / capacity
                    int bedsCount = 1;
                    if (bedType != null) {
                        String bLower = bedType.toLowerCase();
                        if (bLower.contains("2") || bLower.contains("two") || bLower.contains("double") || bLower.contains("twin")) {
                            bedsCount = 2;
                        } else if (bLower.contains("3") || bLower.contains("three")) {
                            bedsCount = 3;
                        }
                    }
                    roomMap.put("bedsCount", bedsCount);

                    roomList.add(roomMap);
                }
            }

            // 4. Fetch logged-in user profile details (full_name, email, phone, address) from registration table
            HttpSession session = request.getSession(false);
            boolean isLoggedIn = false;
            String guestFullName = "";
            String guestEmail = "";
            String guestPhone = "";
            String guestAddress = "";

            if (session != null) {
                Integer regId = null;
                Object idObj = session.getAttribute("userId");
                if (idObj == null) {
                    idObj = session.getAttribute("registration_id");
                }
                if (idObj != null) {
                    try {
                        regId = (idObj instanceof Integer) ? (Integer) idObj : Integer.valueOf(idObj.toString().trim());
                    } catch (NumberFormatException ignored) {}
                }
                String uEmail = (String) session.getAttribute("userEmail");

                if (regId != null || (uEmail != null && !uEmail.trim().isEmpty())) {
                    String profileSql = (regId != null)
                            ? "SELECT registration_id, full_name, email, phone, address FROM registration WHERE registration_id = ?"
                            : "SELECT registration_id, full_name, email, phone, address FROM registration WHERE LOWER(email) = ?";
                    try (PreparedStatement psUser = conn.prepareStatement(profileSql)) {
                        if (regId != null) {
                            psUser.setInt(1, regId);
                        } else {
                            psUser.setString(1, uEmail.trim().toLowerCase());
                        }
                        try (ResultSet rsUser = psUser.executeQuery()) {
                            if (rsUser.next()) {
                                isLoggedIn = true;
                                guestFullName = rsUser.getString("full_name") != null ? rsUser.getString("full_name") : "";
                                guestEmail = rsUser.getString("email") != null ? rsUser.getString("email") : "";
                                guestPhone = rsUser.getString("phone") != null ? rsUser.getString("phone") : "";
                                guestAddress = rsUser.getString("address") != null ? rsUser.getString("address") : "";

                                // Keep session synced
                                session.setAttribute("userId", rsUser.getInt("registration_id"));
                                session.setAttribute("fullName", guestFullName);
                                session.setAttribute("userEmail", guestEmail);
                                session.setAttribute("phone", guestPhone);
                                session.setAttribute("address", guestAddress);
                            }
                        }
                    } catch (SQLException ex) {
                        System.err.println("Notice: Could not load user profile: " + ex.getMessage());
                    }
                }
            }

            request.setAttribute("isLoggedIn", isLoggedIn);
            request.setAttribute("guestFullName", guestFullName);
            request.setAttribute("guestEmail", guestEmail);
            request.setAttribute("guestPhone", guestPhone);
            request.setAttribute("guestAddress", guestAddress);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading rooms from database: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }

        request.setAttribute("rooms", roomList);
        request.setAttribute("roomTypes", roomTypeList);
        request.setAttribute("availableAmenities", availableAmenities);
        request.setAttribute("totalRooms", roomList.size());
        request.getRequestDispatcher("/guest/room.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || (session.getAttribute("userId") == null && session.getAttribute("userEmail") == null)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String roomIdParam = request.getParameter("roomId");
        String guestName = request.getParameter("guestName");
        String guestEmail = request.getParameter("guestEmail");
        String guestPhone = request.getParameter("guestPhone");
        String checkInStr = request.getParameter("checkIn");
        String checkOutStr = request.getParameter("checkOut");
        String guestsCountParam = request.getParameter("guestsCount");
        String specialRequests = request.getParameter("specialRequests");

        if (roomIdParam == null || roomIdParam.trim().isEmpty() ||
            guestName == null || guestName.trim().isEmpty() ||
            guestEmail == null || guestEmail.trim().isEmpty() ||
            guestPhone == null || guestPhone.trim().isEmpty() ||
            checkInStr == null || checkInStr.trim().isEmpty() ||
            checkOutStr == null || checkOutStr.trim().isEmpty() ||
            guestsCountParam == null || guestsCountParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/guest/room?error=All+booking+fields+are+required.");
            return;
        }

        int roomId;
        int guestsCount;
        LocalDate checkIn;
        LocalDate checkOut;

        try {
            roomId = Integer.parseInt(roomIdParam.trim());
            guestsCount = Integer.parseInt(guestsCountParam.trim());
            checkIn = LocalDate.parse(checkInStr.trim());
            checkOut = LocalDate.parse(checkOutStr.trim());
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/guest/room?error=Invalid+form+data+submitted.");
            return;
        }

        LocalDate today = LocalDate.now();
        if (checkIn.isBefore(today)) {
            response.sendRedirect(request.getContextPath() + "/guest/room?error=Check-in+date+cannot+be+in+the+past.");
            return;
        }

        long nights = ChronoUnit.DAYS.between(checkIn, checkOut);
        if (nights <= 0) {
            response.sendRedirect(request.getContextPath() + "/guest/room?error=Check-out+date+must+be+after+check-in.");
            return;
        }

        Connection conn = null;
        try {
            conn = DBconnection.getConnection();
            if (conn == null) {
                response.sendRedirect(request.getContextPath() + "/guest/room?error=Database+connection+unavailable.");
                return;
            }

            conn.setAutoCommit(false);

            // Ensure bookings table exists in the database
            ensureBookingsTableExists(conn);

            // 1. Validate room capacity and price from database
            BigDecimal pricePerNight = null;
            int maxCapacity = 0;
            String status = null;

            String roomSql = "SELECT price_per_night, capacity, status FROM rooms WHERE id = ?";
            try (PreparedStatement psRoom = conn.prepareStatement(roomSql)) {
                psRoom.setInt(1, roomId);
                try (ResultSet rs = psRoom.executeQuery()) {
                    if (rs.next()) {
                        pricePerNight = rs.getBigDecimal("price_per_night");
                        maxCapacity = rs.getInt("capacity");
                        status = rs.getString("status");
                    } else {
                        conn.rollback();
                        response.sendRedirect(request.getContextPath() + "/guest/room?error=Selected+room+not+found+in+database.");
                        return;
                    }
                }
            }

            if ("Maintenance".equalsIgnoreCase(status)) {
                conn.rollback();
                response.sendRedirect(request.getContextPath() + "/guest/room?error=Room+is+currently+under+maintenance.");
                return;
            }

            if (guestsCount > maxCapacity) {
                conn.rollback();
                response.sendRedirect(request.getContextPath() + "/guest/room?error=Guest+count+exceeds+room+capacity+of+" + maxCapacity + ".");
                return;
            }

            // 2. Collision check for confirmed overlapping bookings in database
            String overlapSql = "SELECT COUNT(*) FROM bookings "
                              + "WHERE room_id = ? "
                              + "  AND booking_status = 'CONFIRMED' "
                              + "  AND NOT (check_out <= ? OR check_in >= ?)";
            try (PreparedStatement psOverlap = conn.prepareStatement(overlapSql)) {
                psOverlap.setInt(1, roomId);
                psOverlap.setDate(2, Date.valueOf(checkIn));
                psOverlap.setDate(3, Date.valueOf(checkOut));
                try (ResultSet rs = psOverlap.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        conn.rollback();
                        response.sendRedirect(request.getContextPath() + "/guest/room?error=Room+is+already+booked+for+the+selected+dates.");
                        return;
                    }
                }
            }

            // 3. Compute total price and reference ID
            BigDecimal totalPrice = pricePerNight.multiply(BigDecimal.valueOf(nights));
            String bookingRef = "GS-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

            // 4. Insert booking record into database
            String insertSql = "INSERT INTO bookings "
                             + "(booking_reference, room_id, guest_name, guest_email, guest_phone, "
                             + " check_in, check_out, guests_count, total_price, booking_status) "
                             + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'CONFIRMED')";

            try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                String safeName = guestName.trim();
                if (safeName.length() > 100) safeName = safeName.substring(0, 100);

                String safeEmail = guestEmail.trim().toLowerCase();
                if (safeEmail.length() > 100) safeEmail = safeEmail.substring(0, 100);

                String safePhone = guestPhone.trim();
                if (safePhone.length() > 20) safePhone = safePhone.substring(0, 20);

                psInsert.setString(1, bookingRef);
                psInsert.setInt(2, roomId);
                psInsert.setString(3, safeName);
                psInsert.setString(4, safeEmail);
                psInsert.setString(5, safePhone);
                psInsert.setDate(6, Date.valueOf(checkIn));
                psInsert.setDate(7, Date.valueOf(checkOut));
                psInsert.setInt(8, guestsCount);
                psInsert.setBigDecimal(9, totalPrice);
                psInsert.executeUpdate();
            }

            conn.commit();
            response.sendRedirect(request.getContextPath() + "/guest/my-bookings?bookingSuccess=" + java.net.URLEncoder.encode(bookingRef, "UTF-8"));

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/guest/room?error=Booking+failed:+" + java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Unknown error", "UTF-8"));
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
    }

    private void ensureBookingsTableExists(Connection conn) {
        String createTableSql = "CREATE TABLE IF NOT EXISTS bookings ("
                              + "  id INT AUTO_INCREMENT PRIMARY KEY,"
                              + "  booking_reference VARCHAR(50) NOT NULL UNIQUE,"
                              + "  room_id INT NOT NULL,"
                              + "  guest_name VARCHAR(100) NOT NULL,"
                              + "  guest_email VARCHAR(100) NOT NULL,"
                              + "  guest_phone VARCHAR(20) NOT NULL,"
                              + "  check_in DATE NOT NULL,"
                              + "  check_out DATE NOT NULL,"
                              + "  guests_count INT NOT NULL DEFAULT 1,"
                              + "  total_price DECIMAL(10, 2) NOT NULL,"
                              + "  booking_status ENUM('CONFIRMED', 'CANCELLED') NOT NULL DEFAULT 'CONFIRMED',"
                              + "  cancellation_reason VARCHAR(255) NULL,"
                              + "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
                              + "  CONSTRAINT fk_booking_room "
                              + "      FOREIGN KEY (room_id) "
                              + "      REFERENCES rooms(id) "
                              + "      ON DELETE CASCADE "
                              + "      ON UPDATE CASCADE"
                              + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(createTableSql);
        } catch (SQLException e) {
            System.err.println("Notice on ensuring bookings table: " + e.getMessage());
        }
    }
}
