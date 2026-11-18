package AuthServlet.Admin;

import AuthServlet.DBconnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
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

@WebServlet(name = "AdminCustomerServlet", urlPatterns = {"/admin/customers", "/admin/customer-management", "/admin/guests"})
public class AdminCustomerServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"admin".equalsIgnoreCase((String) session.getAttribute("userRole"))) {
            String acceptHeader = req.getHeader("Accept");
            if ("json".equalsIgnoreCase(req.getParameter("format")) || (acceptHeader != null && acceptHeader.contains("application/json"))) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().print("{\"error\":\"Unauthorized\"}");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String searchQuery = req.getParameter("q");
        String statusFilter = req.getParameter("status");
        String customerIdParam = req.getParameter("customerId");

        try (Connection con = DBconnection.getConnection()) {
            if (con != null) {
                ensureRegistrationColumns(con);

                // If asking for a single customer's bookings (for profile modal AJAX)
                if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                    handleCustomerDetailAjax(req, resp, con, Integer.parseInt(customerIdParam.trim()));
                    return;
                }
            }

            List<Map<String, Object>> customerList = fetchCustomers(con, searchQuery, statusFilter);

            int totalCount = customerList.size();
            long activeCount = customerList.stream()
                    .filter(c -> "Active".equalsIgnoreCase(String.valueOf(c.get("status"))))
                    .count();
            long blockedCount = customerList.stream()
                    .filter(c -> "Blocked".equalsIgnoreCase(String.valueOf(c.get("status"))))
                    .count();
            long withBookingsCount = customerList.stream()
                    .filter(c -> {
                        Object bCount = c.get("bookingCount");
                        return bCount instanceof Number && ((Number) bCount).intValue() > 0;
                    })
                    .count();

            // Support JSON response
            String format = req.getParameter("format");
            String acceptHeader = req.getHeader("Accept");
            if ("json".equalsIgnoreCase(format) || (acceptHeader != null && acceptHeader.contains("application/json") && !"text/html".contains(acceptHeader))) {
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.print(buildCustomerJson(customerList, totalCount, (int) activeCount, (int) blockedCount, (int) withBookingsCount));
                out.flush();
                return;
            }

            req.setAttribute("customers", customerList);
            req.setAttribute("totalCustomers", totalCount);
            req.setAttribute("activeCustomers", activeCount);
            req.setAttribute("blockedCustomers", blockedCount);
            req.setAttribute("withBookingsCount", withBookingsCount);
            req.setAttribute("searchQuery", searchQuery != null ? searchQuery : "");
            req.setAttribute("statusFilter", statusFilter != null ? statusFilter : "");

            req.getRequestDispatcher("/admin/customers.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("customers", new ArrayList<Map<String, Object>>());
            req.setAttribute("totalCustomers", 0);
            req.setAttribute("activeCustomers", 0);
            req.setAttribute("blockedCustomers", 0);
            req.setAttribute("withBookingsCount", 0);
            req.getRequestDispatcher("/admin/customers.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"admin".equalsIgnoreCase((String) session.getAttribute("userRole"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        String customerIdParam = req.getParameter("customerId");

        if ("toggle_status".equalsIgnoreCase(action) && customerIdParam != null) {
            try {
                int customerId = Integer.parseInt(customerIdParam.trim());
                String newStatus = req.getParameter("newStatus");

                try (Connection con = DBconnection.getConnection()) {
                    if (con != null) {
                        ensureRegistrationColumns(con);

                        // Check target account role first to prevent blocking admins
                        String currentSql = "SELECT status, role FROM registration WHERE registration_id = ?";
                        String currentStatus = "Active";
                        String currentRole = "";
                        try (PreparedStatement ps = con.prepareStatement(currentSql)) {
                            ps.setInt(1, customerId);
                            try (ResultSet rs = ps.executeQuery()) {
                                if (rs.next()) {
                                    currentStatus = rs.getString("status");
                                    currentRole = rs.getString("role");
                                }
                            }
                        }

                        if ("admin".equalsIgnoreCase(currentRole)) {
                            session.setAttribute("toastMsg", "Cannot modify status of an Administrator account.");
                            resp.sendRedirect(req.getContextPath() + "/admin/customers");
                            return;
                        }

                        if (newStatus == null || (!"Active".equalsIgnoreCase(newStatus) && !"Blocked".equalsIgnoreCase(newStatus))) {
                            newStatus = "Blocked".equalsIgnoreCase(currentStatus) ? "Active" : "Blocked";
                        }

                        if ("Blocked".equalsIgnoreCase(newStatus)) {
                            String blockReason = req.getParameter("blockReason");
                            String reasonVal = (blockReason != null && !blockReason.trim().isEmpty())
                                    ? blockReason.trim()
                                    : "Administrative restriction";
                            String updateSql = "UPDATE registration SET status = 'Blocked', block_reason = ? WHERE registration_id = ?";
                            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                                ps.setString(1, reasonVal);
                                ps.setInt(2, customerId);
                                ps.executeUpdate();
                            }
                            session.setAttribute("toastMsg", "Guest account has been blocked.");
                        } else {
                            String updateSql = "UPDATE registration SET status = 'Active', block_reason = NULL WHERE registration_id = ?";
                            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                                ps.setInt(1, customerId);
                                ps.executeUpdate();
                            }
                            session.setAttribute("toastMsg", "Guest account has been activated.");
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("toastMsg", "Error updating status: " + e.getMessage());
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/customers");
    }

    private List<Map<String, Object>> fetchCustomers(Connection con, String searchQuery, String statusFilter) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (con == null) return list;

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.registration_id, r.full_name, r.email, r.phone, r.address, r.role, r.block_reason, ");
        sql.append("COALESCE(r.status, 'Active') AS status, ");
        sql.append("COALESCE(r.created_at, CURRENT_TIMESTAMP) AS created_at, ");
        sql.append("(SELECT COUNT(*) FROM bookings b WHERE LOWER(b.guest_email) = LOWER(r.email)) AS booking_count, ");
        sql.append("(SELECT COALESCE(SUM(b.total_price), 0) FROM bookings b WHERE LOWER(b.guest_email) = LOWER(r.email) AND b.booking_status = 'CONFIRMED') AS total_spent ");
        sql.append("FROM registration r ");
        sql.append("WHERE LOWER(COALESCE(r.role, '')) != 'admin' ");

        List<Object> params = new ArrayList<>();
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND (LOWER(r.full_name) LIKE ? OR LOWER(r.email) LIKE ? OR LOWER(r.phone) LIKE ?) ");
            String term = "%" + searchQuery.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            sql.append("AND LOWER(COALESCE(r.status, 'Active')) = ? ");
            params.add(statusFilter.trim().toLowerCase());
        }

        sql.append("ORDER BY r.registration_id DESC");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("registration_id"));
                    map.put("fullName", rs.getString("full_name"));
                    map.put("email", rs.getString("email"));
                    map.put("phone", rs.getString("phone"));
                    map.put("address", rs.getString("address"));
                    map.put("role", rs.getString("role"));
                    map.put("status", rs.getString("status"));
                    map.put("blockReason", rs.getString("block_reason"));
                    map.put("createdAt", rs.getTimestamp("created_at"));
                    map.put("bookingCount", rs.getInt("booking_count"));
                    map.put("totalSpent", rs.getBigDecimal("total_spent"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    private void handleCustomerDetailAjax(HttpServletRequest req, HttpServletResponse resp, Connection con, int customerId) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String guestEmail = null;
        Map<String, Object> guest = new HashMap<>();

        String userSql = "SELECT registration_id, full_name, email, phone, address, role, COALESCE(status, 'Active') AS status, block_reason, created_at FROM registration WHERE registration_id = ?";
        try (PreparedStatement ps = con.prepareStatement(userSql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    guestEmail = rs.getString("email");
                    guest.put("id", rs.getInt("registration_id"));
                    guest.put("fullName", rs.getString("full_name"));
                    guest.put("email", guestEmail);
                    guest.put("phone", rs.getString("phone"));
                    guest.put("address", rs.getString("address"));
                    guest.put("role", rs.getString("role"));
                    guest.put("status", rs.getString("status"));
                    guest.put("blockReason", rs.getString("block_reason"));
                    guest.put("createdAt", rs.getTimestamp("created_at"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (guestEmail == null) {
            out.print("{\"error\":\"Customer not found\"}");
            out.flush();
            return;
        }

        List<Map<String, Object>> bookings = new ArrayList<>();
        String bookSql = "SELECT b.id, b.booking_reference, b.check_in, b.check_out, b.guests_count, b.total_price, b.booking_status, "
                + "r.room_number, r.title AS room_title "
                + "FROM bookings b "
                + "LEFT JOIN rooms r ON b.room_id = r.id "
                + "WHERE LOWER(b.guest_email) = ? "
                + "ORDER BY b.id DESC";
        try (PreparedStatement ps = con.prepareStatement(bookSql)) {
            ps.setString(1, guestEmail.toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> b = new HashMap<>();
                    b.put("id", rs.getInt("id"));
                    b.put("bookingReference", rs.getString("booking_reference"));
                    b.put("checkIn", rs.getDate("check_in"));
                    b.put("checkOut", rs.getDate("check_out"));
                    b.put("guestsCount", rs.getInt("guests_count"));
                    b.put("totalPrice", rs.getBigDecimal("total_price"));
                    b.put("bookingStatus", rs.getString("booking_status"));
                    b.put("roomNumber", rs.getString("room_number"));
                    b.put("roomTitle", rs.getString("room_title"));
                    bookings.add(b);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"id\":").append(guest.get("id")).append(",");
        sb.append("\"fullName\":\"").append(escapeJson(String.valueOf(guest.get("fullName")))).append("\",");
        sb.append("\"email\":\"").append(escapeJson(String.valueOf(guest.get("email")))).append("\",");
        sb.append("\"phone\":\"").append(escapeJson(String.valueOf(guest.get("phone")))).append("\",");
        sb.append("\"address\":\"").append(escapeJson(String.valueOf(guest.get("address")))).append("\",");
        sb.append("\"role\":\"").append(escapeJson(String.valueOf(guest.get("role")))).append("\",");
        sb.append("\"status\":\"").append(escapeJson(String.valueOf(guest.get("status")))).append("\",");
        sb.append("\"blockReason\":\"").append(escapeJson(String.valueOf(guest.get("blockReason")))).append("\",");
        sb.append("\"createdAt\":\"").append(guest.get("createdAt") != null ? guest.get("createdAt") : "").append("\",");
        sb.append("\"bookings\":[");
        for (int i = 0; i < bookings.size(); i++) {
            Map<String, Object> b = bookings.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"bookingReference\":\"").append(escapeJson(String.valueOf(b.get("bookingReference")))).append("\",");
            sb.append("\"roomNumber\":\"").append(escapeJson(String.valueOf(b.get("roomNumber")))).append("\",");
            sb.append("\"roomTitle\":\"").append(escapeJson(String.valueOf(b.get("roomTitle")))).append("\",");
            sb.append("\"checkIn\":\"").append(b.get("checkIn") != null ? b.get("checkIn") : "").append("\",");
            sb.append("\"checkOut\":\"").append(b.get("checkOut") != null ? b.get("checkOut") : "").append("\",");
            sb.append("\"totalPrice\":").append(b.get("totalPrice") != null ? b.get("totalPrice") : 0).append(",");
            sb.append("\"bookingStatus\":\"").append(escapeJson(String.valueOf(b.get("bookingStatus")))).append("\"");
            sb.append("}");
        }
        sb.append("]");
        sb.append("}");
        out.print(sb.toString());
        out.flush();
    }

    private String buildCustomerJson(List<Map<String, Object>> customers, int total, int active, int blocked, int withBookings) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"total\":").append(total).append(",");
        sb.append("\"active\":").append(active).append(",");
        sb.append("\"blocked\":").append(blocked).append(",");
        sb.append("\"withBookings\":").append(withBookings).append(",");
        sb.append("\"customers\":[");
        for (int i = 0; i < customers.size(); i++) {
            Map<String, Object> c = customers.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"id\":").append(c.get("id")).append(",");
            sb.append("\"fullName\":\"").append(escapeJson(String.valueOf(c.get("fullName")))).append("\",");
            sb.append("\"email\":\"").append(escapeJson(String.valueOf(c.get("email")))).append("\",");
            sb.append("\"phone\":\"").append(escapeJson(String.valueOf(c.get("phone")))).append("\",");
            sb.append("\"address\":\"").append(escapeJson(String.valueOf(c.get("address")))).append("\",");
            sb.append("\"role\":\"").append(escapeJson(String.valueOf(c.get("role")))).append("\",");
            sb.append("\"status\":\"").append(escapeJson(String.valueOf(c.get("status")))).append("\",");
            sb.append("\"blockReason\":\"").append(escapeJson(String.valueOf(c.get("blockReason")))).append("\",");
            sb.append("\"bookingCount\":").append(c.get("bookingCount")).append(",");
            sb.append("\"totalSpent\":").append(c.get("totalSpent") != null ? c.get("totalSpent") : 0).append(",");
            sb.append("\"createdAt\":\"").append(c.get("createdAt") != null ? c.get("createdAt") : "").append("\"");
            sb.append("}");
        }
        sb.append("]");
        sb.append("}");
        return sb.toString();
    }

    private void ensureRegistrationColumns(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            try {
                stmt.executeUpdate("ALTER TABLE registration ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'Active'");
            } catch (SQLException ignored) {}
            try {
                stmt.executeUpdate("ALTER TABLE registration ADD COLUMN block_reason VARCHAR(255) DEFAULT NULL");
            } catch (SQLException ignored) {}
            try {
                stmt.executeUpdate("ALTER TABLE registration ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
            } catch (SQLException ignored) {}
        } catch (Exception ignored) {}
    }

    private String escapeJson(String s) {
        if (s == null || "null".equals(s)) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
}
