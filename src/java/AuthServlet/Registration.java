package AuthServlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "Registration", urlPatterns = {"/api/register", "/Registration", "/register"})
public class Registration extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String password = request.getParameter("password");
        String roleParam = request.getParameter("role");

        // Restrict self-registration role to "Customer"
        String role = "Customer";
        if (roleParam != null && "admin".equalsIgnoreCase(roleParam.trim())) {
            // Keep customer role for public registration
            role = "Customer";
        }

        // 1. Validate required fields
        if (fullName == null || email == null || password == null ||
            fullName.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"error\", \"message\":\"Please complete all required fields.\"}");
            out.flush();
            return;
        }

        String checkEmailSql = "SELECT email FROM registration WHERE LOWER(email) = ?";
        String insertSql = "INSERT INTO registration (full_name, email, phone, address, password, role, status) VALUES (?, ?, ?, ?, ?, ?, 'Active')";

        try (Connection conn = DBconnection.getConnection()) {
            if (conn == null) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"status\":\"error\", \"message\":\"Cannot connect to the database. Check DBconnection credentials.\"}");
                out.flush();
                return;
            }

            // 2. Check if email already exists (case-insensitive)
            try (PreparedStatement checkStmt = conn.prepareStatement(checkEmailSql)) {
                checkStmt.setString(1, email.trim().toLowerCase());
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        response.setStatus(HttpServletResponse.SC_CONFLICT); // 409 Conflict
                        out.print("{\"status\":\"error\", \"field\":\"email\", \"message\":\"An account with this email address already exists.\"}");
                        out.flush();
                        return;
                    }
                }
            }

            // 3. Insert record into database with hashed password
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                insertStmt.setString(1, fullName.trim());
                insertStmt.setString(2, email.trim().toLowerCase());
                insertStmt.setString(3, (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null);
                insertStmt.setString(4, (address != null && !address.trim().isEmpty()) ? address.trim() : null);
                insertStmt.setString(5, PasswordUtil.hashPassword(password));
                insertStmt.setString(6, role);

                int rowsAffected = insertStmt.executeUpdate();

                if (rowsAffected > 0) {
                    response.setStatus(HttpServletResponse.SC_OK);
                    out.print("{\"status\":\"success\", \"message\":\"Guest profile successfully registered.\"}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"status\":\"error\", \"message\":\"Could not insert profile into the database.\"}");
                }
                out.flush();
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"status\":\"error\", \"message\":\"SQL Database Error: " + e.getMessage().replace("\"", "'") + "\"}");
            out.flush();
        }
    }
}
