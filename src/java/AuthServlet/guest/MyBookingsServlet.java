package AuthServlet.guest;

import AuthServlet.DBconnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/guest/my-bookings", "/my-bookings", "/my-bookings.jsp", "/bookings", "/bookings.jsp"})
public class MyBookingsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String sessionEmail = (session != null && session.getAttribute("userEmail") != null) 
                            ? (String) session.getAttribute("userEmail") : null;

        // If sessionEmail is missing but userId is available in session, load from registration table
        if (sessionEmail == null && session != null && session.getAttribute("userId") != null) {
            try (Connection conn = DBconnection.getConnection()) {
                if (conn != null) {
                    String userQuery = "SELECT email, full_name, phone, address FROM registration WHERE registration_id = ?";
                    try (PreparedStatement psUser = conn.prepareStatement(userQuery)) {
                        psUser.setObject(1, session.getAttribute("userId"));
                        try (ResultSet rsUser = psUser.executeQuery()) {
                            if (rsUser.next()) {
                                sessionEmail = rsUser.getString("email");
                                session.setAttribute("userEmail", sessionEmail);
                                session.setAttribute("fullName", rsUser.getString("full_name"));
                                session.setAttribute("phone", rsUser.getString("phone"));
                                session.setAttribute("address", rsUser.getString("address"));
                            }
                        }
                    }
                }
            } catch (SQLException ignored) {}
        }

        String searchEmail = request.getParameter("email");
        String searchRef = request.getParameter("bookingRef");
        String bookingSuccess = request.getParameter("bookingSuccess");

        // If newly booked, query by that reference if not explicitly overridden
        if ((searchRef == null || searchRef.trim().isEmpty()) && bookingSuccess != null && !bookingSuccess.trim().isEmpty()) {
            searchRef = bookingSuccess.trim();
        }

        String emailToQuery = (searchEmail != null && !searchEmail.trim().isEmpty()) 
                            ? searchEmail.trim() : sessionEmail;

        // If user is neither logged in nor searching for a booking, redirect to login
        if (session == null || (session.getAttribute("userId") == null && session.getAttribute("userEmail") == null)) {
            if (searchRef == null || searchRef.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }
        }

        List<Map<String, Object>> bookingList = new ArrayList<>();
        int confirmedCount = 0;
        int cancelledCount = 0;

        if (emailToQuery != null || (searchRef != null && !searchRef.trim().isEmpty())) {
            try (Connection conn = DBconnection.getConnection()) {
                if (conn != null) {
                    // Automatically ensure cancellation_reason column exists
                    ensureCancellationReasonColumn(conn);

                    String sql = "SELECT b.id, b.booking_reference, b.room_id, b.guest_name, b.guest_email, b.guest_phone, "
                               + "       b.check_in, b.check_out, b.guests_count, b.total_price, b.booking_status, "
                               + "       b.cancellation_reason, b.created_at, "
                               + "       r.room_number, r.title AS room_title, r.bed_type, "
                               + "       COALESCE(rt.name, 'Suite') AS category_name, "
                               + "       (SELECT image_url FROM room_images WHERE room_id = r.id ORDER BY is_primary DESC, id ASC LIMIT 1) AS primary_photo "
                               + "FROM bookings b "
                               + "JOIN rooms r ON b.room_id = r.id "
                               + "LEFT JOIN room_types rt ON r.room_type_id = rt.id "
                               + "WHERE (LOWER(b.guest_email) = LOWER(?) OR b.booking_reference = ?) "
                               + "ORDER BY b.created_at DESC";

                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, emailToQuery != null ? emailToQuery : "");
                        ps.setString(2, searchRef != null ? searchRef.trim() : "");
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                Map<String, Object> booking = new HashMap<>();
                                int bId = rs.getInt("id");
                                booking.put("id", bId);
                                booking.put("bookingReference", rs.getString("booking_reference"));
                                booking.put("roomId", rs.getInt("room_id"));
                                booking.put("guestName", rs.getString("guest_name"));
                                booking.put("guestEmail", rs.getString("guest_email"));
                                booking.put("guestPhone", rs.getString("guest_phone"));
                                booking.put("checkIn", rs.getDate("check_in"));
                                booking.put("checkOut", rs.getDate("check_out"));
                                booking.put("guestsCount", rs.getInt("guests_count"));
                                booking.put("totalPrice", rs.getBigDecimal("total_price"));
                                
                                String status = rs.getString("booking_status");
                                if (status == null) status = "CONFIRMED";
                                booking.put("bookingStatus", status);
                                
                                String cancelReason = rs.getString("cancellation_reason");
                                booking.put("cancellationReason", cancelReason != null ? cancelReason : "");

                                if ("CANCELLED".equalsIgnoreCase(status)) {
                                    cancelledCount++;
                                } else {
                                    confirmedCount++;
                                }

                                booking.put("createdAt", rs.getTimestamp("created_at"));
                                booking.put("roomNumber", rs.getString("room_number"));
                                booking.put("roomTitle", rs.getString("room_title"));
                                booking.put("bedType", rs.getString("bed_type"));
                                booking.put("categoryName", rs.getString("category_name"));
                                String photo = rs.getString("primary_photo");
                                booking.put("primaryPhoto", photo != null ? photo.trim().replace("\\", "/") : "");
                                bookingList.add(booking);
                            }
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Error retrieving reservations: " + e.getMessage());
            }
        }

        request.setAttribute("bookings", bookingList);
        request.setAttribute("totalCount", bookingList.size());
        request.setAttribute("confirmedCount", confirmedCount);
        request.setAttribute("cancelledCount", cancelledCount);
        request.setAttribute("queriedEmail", emailToQuery);
        request.getRequestDispatcher("/guest/my_bookings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String bookingIdParam = request.getParameter("bookingId");

        if ("cancel".equalsIgnoreCase(action) && bookingIdParam != null) {
            String cancelReason = request.getParameter("cancelReason");
            if (cancelReason == null || cancelReason.trim().isEmpty()) {
                cancelReason = "Guest initiated cancellation";
            } else {
                cancelReason = cancelReason.trim();
                if (cancelReason.length() > 255) {
                    cancelReason = cancelReason.substring(0, 255);
                }
            }

            HttpSession session = request.getSession(false);
            String userEmail = (session != null) ? (String) session.getAttribute("userEmail") : null;
            String userRole = (session != null) ? (String) session.getAttribute("userRole") : null;

            try {
                int bookingId = Integer.parseInt(bookingIdParam.trim());
                try (Connection conn = DBconnection.getConnection()) {
                    if (conn != null) {
                        ensureCancellationReasonColumn(conn);
                        
                        String cancelSql;
                        if ("admin".equalsIgnoreCase(userRole)) {
                            cancelSql = "UPDATE bookings SET booking_status = 'CANCELLED', cancellation_reason = ? WHERE id = ?";
                        } else {
                            cancelSql = "UPDATE bookings SET booking_status = 'CANCELLED', cancellation_reason = ? WHERE id = ? AND LOWER(guest_email) = LOWER(?)";
                        }

                        try (PreparedStatement ps = conn.prepareStatement(cancelSql)) {
                            ps.setString(1, cancelReason);
                            ps.setInt(2, bookingId);
                            if (!"admin".equalsIgnoreCase(userRole)) {
                                ps.setString(3, userEmail != null ? userEmail.trim().toLowerCase() : "");
                            }
                            ps.executeUpdate();
                        }
                    }
                }
                response.sendRedirect(request.getContextPath() + "/guest/my-bookings?cancelSuccess=true");
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/guest/my-bookings");
    }

    private void ensureCancellationReasonColumn(Connection conn) {
        String alterSql = "ALTER TABLE bookings ADD COLUMN cancellation_reason VARCHAR(255) NULL AFTER booking_status";
        try (java.sql.Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(alterSql);
        } catch (SQLException ignored) {
            // Column already exists or table cannot be altered, ignore
        }
    }
}
