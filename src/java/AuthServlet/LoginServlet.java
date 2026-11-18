package AuthServlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Redirect direct GET requests back to the login page
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        // 1. Validate empty inputs
        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            req.setAttribute("loginError", "Both Email and Password are required.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        try (Connection conn = DBconnection.getConnection()) {
            if (conn == null) {
                req.setAttribute("loginError", "Database service unavailable. Please verify MySQL connection.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
                return;
            }

            ensureRegistrationColumns(conn);

            String sql = "SELECT registration_id, full_name, email, phone, address, password, role, status, block_reason FROM registration WHERE LOWER(email) = ?";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, email.trim().toLowerCase());

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        String storedPassword = rs.getString("password");

                        // Verify password against stored SHA-256 hash (or legacy plain text)
                        if (!PasswordUtil.checkPassword(password, storedPassword)) {
                            req.setAttribute("loginError", "Invalid email address or password.");
                            req.getRequestDispatcher("/login.jsp").forward(req, resp);
                            return;
                        }

                        // Transparently upgrade legacy unhashed plain-text passwords to SHA-256
                        if (!PasswordUtil.isHashed(storedPassword)) {
                            try (PreparedStatement upgradeStmt = conn.prepareStatement(
                                    "UPDATE registration SET password = ? WHERE registration_id = ?")) {
                                upgradeStmt.setString(1, PasswordUtil.hashPassword(password));
                                upgradeStmt.setInt(2, rs.getInt("registration_id"));
                                upgradeStmt.executeUpdate();
                            } catch (SQLException ignored) {
                            }
                        }

                        String userStatus = rs.getString("status");
                        String role = rs.getString("role");

                        if ("Blocked".equalsIgnoreCase(userStatus) && !"admin".equalsIgnoreCase(role)) {
                            String blockReason = rs.getString("block_reason");
                            String errorMsg = "Your account has been restricted by hotel administration.";
                            if (blockReason != null && !blockReason.trim().isEmpty()) {
                                errorMsg += " Reason: " + blockReason;
                            } else {
                                errorMsg += " Please contact hotel support.";
                            }
                            req.setAttribute("loginError", errorMsg);
                            req.getRequestDispatcher("/login.jsp").forward(req, resp);
                            return;
                        }

                        // 2. Invalidate any existing session and generate a new session ID for security
                        HttpSession oldSession = req.getSession(false);
                        if (oldSession != null) {
                            oldSession.invalidate();
                        }
                        HttpSession session = req.getSession(true);

                        // 3. Store authenticated user info in session
                        session.setAttribute("userId", rs.getInt("registration_id"));
                        session.setAttribute("registration_id", rs.getInt("registration_id"));
                        session.setAttribute("fullName", rs.getString("full_name"));
                        session.setAttribute("userEmail", rs.getString("email"));
                        session.setAttribute("phone", rs.getString("phone"));
                        session.setAttribute("userPhone", rs.getString("phone"));
                        session.setAttribute("address", rs.getString("address"));
                        session.setAttribute("userAddress", rs.getString("address"));
                        session.setAttribute("userRole", role);
                        session.setAttribute("accountStatus", userStatus != null ? userStatus : "Active");

                        // 4. Role-based redirect (Admin vs Guest)
                        if ("admin".equalsIgnoreCase(role)) {
                            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                        } else {
                            // Redirect guest to dashboard
                            resp.sendRedirect(req.getContextPath() + "/guest/dashboard.jsp");
                        }
                    } else {
                        // 5. Authentication failed (User email not found)
                        req.setAttribute("loginError", "Invalid email address or password.");
                        req.getRequestDispatcher("/login.jsp").forward(req, resp);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("loginError", "An error occurred during authentication. Details: " + e.getMessage());
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }

    private void ensureRegistrationColumns(Connection conn) {
        try (java.sql.Statement stmt = conn.createStatement()) {
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
}
