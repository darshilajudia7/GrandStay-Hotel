package AuthServlet.Admin;

import AuthServlet.DBconnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
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
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin", "/admin/", "/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"admin".equalsIgnoreCase((String) session.getAttribute("userRole"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int totalRooms = 0;
        int availableRooms = 0;
        int bookedRooms = 0;
        int maintenanceRooms = 0;

        int totalBookings = 0;
        int confirmedBookings = 0;
        int cancelledBookings = 0;
        BigDecimal totalRevenue = BigDecimal.ZERO;

        int totalCustomers = 0;
        int activeCustomers = 0;
        int blockedCustomers = 0;

        List<Map<String, Object>> recentBookings = new ArrayList<>();
        List<Map<String, Object>> roomTypeBreakdown = new ArrayList<>();

        try (Connection con = DBconnection.getConnection()) {
            if (con != null) {
                ensureSchemaSupport(con);

                // 1. Rooms statistics (Including live booked room reservations)
                String roomStatsSql = "SELECT "
                        + "COUNT(*) AS total_rooms, "
                        + "COUNT(CASE WHEN LOWER(r.status) = 'maintenance' THEN 1 END) AS maintenance_count, "
                        + "COUNT(CASE WHEN LOWER(r.status) = 'booked' OR EXISTS ("
                        + "    SELECT 1 FROM bookings b "
                        + "    WHERE b.room_id = r.id "
                        + "      AND b.booking_status = 'CONFIRMED' "
                        + "      AND b.check_out >= CURRENT_DATE"
                        + ") THEN 1 END) AS booked_count "
                        + "FROM rooms r";
                try (Statement stmt = con.createStatement();
                     ResultSet rs = stmt.executeQuery(roomStatsSql)) {
                    if (rs.next()) {
                        totalRooms = rs.getInt("total_rooms");
                        bookedRooms = rs.getInt("booked_count");
                        maintenanceRooms = rs.getInt("maintenance_count");
                        availableRooms = totalRooms - bookedRooms - maintenanceRooms;
                        if (availableRooms < 0) availableRooms = 0;
                    }
                } catch (SQLException ignored) {}

                // 2. Bookings statistics
                String bookingStatsSql = "SELECT "
                        + "COUNT(*) AS total_bookings, "
                        + "COUNT(CASE WHEN booking_status = 'CONFIRMED' THEN 1 END) AS confirmed_count, "
                        + "COUNT(CASE WHEN booking_status = 'CANCELLED' THEN 1 END) AS cancelled_count, "
                        + "COALESCE(SUM(CASE WHEN booking_status = 'CONFIRMED' THEN total_price ELSE 0 END), 0) AS confirmed_revenue "
                        + "FROM bookings";
                try (Statement stmt = con.createStatement();
                     ResultSet rs = stmt.executeQuery(bookingStatsSql)) {
                    if (rs.next()) {
                        totalBookings = rs.getInt("total_bookings");
                        confirmedBookings = rs.getInt("confirmed_count");
                        cancelledBookings = rs.getInt("cancelled_count");
                        totalRevenue = rs.getBigDecimal("confirmed_revenue");
                        if (totalRevenue == null) {
                            totalRevenue = BigDecimal.ZERO;
                        }
                    }
                } catch (SQLException ignored) {}

                // 3. Customer registration statistics
                String customerStatsSql = "SELECT "
                        + "COUNT(*) AS total_customers, "
                        + "COUNT(CASE WHEN status != 'Blocked' OR status IS NULL THEN 1 END) AS active_count, "
                        + "COUNT(CASE WHEN status = 'Blocked' THEN 1 END) AS blocked_count "
                        + "FROM registration WHERE LOWER(COALESCE(role, '')) != 'admin'";
                try (Statement stmt = con.createStatement();
                     ResultSet rs = stmt.executeQuery(customerStatsSql)) {
                    if (rs.next()) {
                        totalCustomers = rs.getInt("total_customers");
                        activeCustomers = rs.getInt("active_count");
                        blockedCustomers = rs.getInt("blocked_count");
                    }
                } catch (SQLException ignored) {}

                // 4. Room Types breakdown
                String typesSql = "SELECT rt.name, COUNT(r.id) AS room_count "
                        + "FROM room_types rt "
                        + "LEFT JOIN rooms r ON rt.id = r.room_type_id "
                        + "GROUP BY rt.id, rt.name "
                        + "ORDER BY room_count DESC, rt.name ASC";
                try (Statement stmt = con.createStatement();
                     ResultSet rs = stmt.executeQuery(typesSql)) {
                    while (rs.next()) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("name", rs.getString("name"));
                        map.put("count", rs.getInt("room_count"));
                        roomTypeBreakdown.add(map);
                    }
                } catch (SQLException ignored) {}

                // 5. Recent bookings (Top 10)
                String recentSql = "SELECT b.id, b.booking_reference, b.guest_name, b.guest_email, b.guest_phone, "
                        + "b.check_in, b.check_out, b.guests_count, b.total_price, b.booking_status, "
                        + "b.cancellation_reason, b.created_at, "
                        + "r.room_number, r.title AS room_title, COALESCE(rt.name, 'Standard') AS type_name "
                        + "FROM bookings b "
                        + "LEFT JOIN rooms r ON b.room_id = r.id "
                        + "LEFT JOIN room_types rt ON r.room_type_id = rt.id "
                        + "ORDER BY b.id DESC LIMIT 10";
                try (Statement stmt = con.createStatement();
                     ResultSet rs = stmt.executeQuery(recentSql)) {
                    while (rs.next()) {
                        Map<String, Object> b = new HashMap<>();
                        b.put("id", rs.getInt("id"));
                        b.put("bookingReference", rs.getString("booking_reference"));
                        b.put("guestName", rs.getString("guest_name"));
                        b.put("guestEmail", rs.getString("guest_email"));
                        b.put("guestPhone", rs.getString("guest_phone"));

                        java.sql.Date inDate = rs.getDate("check_in");
                        java.sql.Date outDate = rs.getDate("check_out");
                        b.put("checkIn", inDate);
                        b.put("checkOut", outDate);

                        long nights = 1;
                        if (inDate != null && outDate != null) {
                            try {
                                LocalDate lIn = inDate.toLocalDate();
                                LocalDate lOut = outDate.toLocalDate();
                                nights = ChronoUnit.DAYS.between(lIn, lOut);
                                if (nights <= 0) nights = 1;
                            } catch (Exception ignored) {}
                        }
                        b.put("nights", nights);

                        b.put("guestsCount", rs.getInt("guests_count"));
                        b.put("totalPrice", rs.getBigDecimal("total_price"));
                        b.put("bookingStatus", rs.getString("booking_status"));
                        b.put("cancellationReason", rs.getString("cancellation_reason"));
                        b.put("createdAt", rs.getTimestamp("created_at"));
                        b.put("roomNumber", rs.getString("room_number"));
                        b.put("roomTitle", rs.getString("room_title"));
                        b.put("typeName", rs.getString("type_name"));

                        recentBookings.add(b);
                    }
                } catch (SQLException ignored) {}
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        double occupancyRate = 0.0;
        if (totalRooms > 0) {
            occupancyRate = ((double) bookedRooms / totalRooms) * 100.0;
        }

        // Support JSON format for API or dashboard.html AJAX fetch
        String format = req.getParameter("format");
        String acceptHeader = req.getHeader("Accept");
        if ("json".equalsIgnoreCase(format) || (acceptHeader != null && acceptHeader.contains("application/json") && !"text/html".contains(acceptHeader))) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print(buildDashboardJson(totalRooms, availableRooms, bookedRooms, maintenanceRooms,
                    totalBookings, confirmedBookings, cancelledBookings, totalRevenue, occupancyRate,
                    totalCustomers, activeCustomers, blockedCustomers, recentBookings, roomTypeBreakdown));
            out.flush();
            return;
        }

        // Set request attributes for JSP view
        req.setAttribute("totalRooms", totalRooms);
        req.setAttribute("availableRooms", availableRooms);
        req.setAttribute("bookedRooms", bookedRooms);
        req.setAttribute("maintenanceRooms", maintenanceRooms);

        req.setAttribute("totalBookings", totalBookings);
        req.setAttribute("confirmedBookings", confirmedBookings);
        req.setAttribute("cancelledBookings", cancelledBookings);
        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("occupancyRate", Math.round(occupancyRate * 10.0) / 10.0);

        req.setAttribute("totalCustomers", totalCustomers);
        req.setAttribute("activeCustomers", activeCustomers);
        req.setAttribute("blockedCustomers", blockedCustomers);

        req.setAttribute("recentBookings", recentBookings);
        req.setAttribute("roomTypeBreakdown", roomTypeBreakdown);

        req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);
    }

    private void ensureSchemaSupport(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            try {
                stmt.executeUpdate("ALTER TABLE registration ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'Active'");
            } catch (SQLException ignored) {}
            try {
                stmt.executeUpdate("ALTER TABLE registration ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
            } catch (SQLException ignored) {}
            try {
                stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN cancellation_reason VARCHAR(255) NULL");
            } catch (SQLException ignored) {}
        } catch (Exception ignored) {}
    }

    private String buildDashboardJson(int totalRooms, int availableRooms, int bookedRooms, int maintenanceRooms,
                                      int totalBookings, int confirmedBookings, int cancelledBookings,
                                      BigDecimal totalRevenue, double occupancyRate,
                                      int totalCustomers, int activeCustomers, int blockedCustomers,
                                      List<Map<String, Object>> recentBookings,
                                      List<Map<String, Object>> roomTypeBreakdown) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"totalRooms\":").append(totalRooms).append(",");
        sb.append("\"availableRooms\":").append(availableRooms).append(",");
        sb.append("\"bookedRooms\":").append(bookedRooms).append(",");
        sb.append("\"maintenanceRooms\":").append(maintenanceRooms).append(",");
        sb.append("\"totalBookings\":").append(totalBookings).append(",");
        sb.append("\"confirmedBookings\":").append(confirmedBookings).append(",");
        sb.append("\"cancelledBookings\":").append(cancelledBookings).append(",");
        sb.append("\"totalRevenue\":").append(totalRevenue != null ? totalRevenue.toPlainString() : "0").append(",");
        sb.append("\"occupancyRate\":").append(Math.round(occupancyRate * 10.0) / 10.0).append(",");
        sb.append("\"totalCustomers\":").append(totalCustomers).append(",");
        sb.append("\"activeCustomers\":").append(activeCustomers).append(",");
        sb.append("\"blockedCustomers\":").append(blockedCustomers).append(",");
        sb.append("\"recentBookings\":[");
        for (int i = 0; i < recentBookings.size(); i++) {
            Map<String, Object> b = recentBookings.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"id\":").append(b.get("id")).append(",");
            sb.append("\"bookingReference\":\"").append(escapeJson(String.valueOf(b.get("bookingReference")))).append("\",");
            sb.append("\"guestName\":\"").append(escapeJson(String.valueOf(b.get("guestName")))).append("\",");
            sb.append("\"guestEmail\":\"").append(escapeJson(String.valueOf(b.get("guestEmail")))).append("\",");
            sb.append("\"guestPhone\":\"").append(escapeJson(String.valueOf(b.get("guestPhone")))).append("\",");
            sb.append("\"checkIn\":\"").append(b.get("checkIn") != null ? b.get("checkIn") : "").append("\",");
            sb.append("\"checkOut\":\"").append(b.get("checkOut") != null ? b.get("checkOut") : "").append("\",");
            sb.append("\"nights\":").append(b.get("nights")).append(",");
            sb.append("\"guestsCount\":").append(b.get("guestsCount")).append(",");
            sb.append("\"totalPrice\":").append(b.get("totalPrice") != null ? b.get("totalPrice") : 0).append(",");
            sb.append("\"bookingStatus\":\"").append(escapeJson(String.valueOf(b.get("bookingStatus")))).append("\",");
            sb.append("\"roomNumber\":\"").append(escapeJson(String.valueOf(b.get("roomNumber")))).append("\",");
            sb.append("\"roomTitle\":\"").append(escapeJson(String.valueOf(b.get("roomTitle")))).append("\",");
            sb.append("\"typeName\":\"").append(escapeJson(String.valueOf(b.get("typeName")))).append("\"");
            sb.append("}");
        }
        sb.append("],");
        sb.append("\"roomTypeBreakdown\":[");
        for (int i = 0; i < roomTypeBreakdown.size(); i++) {
            Map<String, Object> t = roomTypeBreakdown.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"name\":\"").append(escapeJson(String.valueOf(t.get("name")))).append("\",");
            sb.append("\"count\":").append(t.get("count"));
            sb.append("}");
        }
        sb.append("]");
        sb.append("}");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null || "null".equals(s)) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
}
