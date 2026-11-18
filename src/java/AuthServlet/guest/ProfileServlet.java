package AuthServlet.guest;

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

@WebServlet(urlPatterns = {"/profile", "/update-profile", "/profile.jsp", "/guest/profile", "/guest/update-profile"})
public class ProfileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/guest/update_profile.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer registrationId = getRegistrationId(session);

        if (registrationId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Never cache a page that shows personal data
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String sql = "SELECT registration_id, full_name, email, phone, address, role "
                + "FROM registration WHERE registration_id = ?";

        try (Connection con = AuthServlet.DBconnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, registrationId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Customer customer = new Customer(
                            rs.getInt("registration_id"),
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getString("phone"),
                            rs.getString("address"),
                            rs.getString("role"));
                    request.setAttribute("customer", customer);
                } else {
                    // Account no longer exists
                    session.invalidate();
                    response.sendRedirect(request.getContextPath() + "/login.jsp");
                    return;
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while loading profile.", e);
        }

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Integer registrationId = getRegistrationId(session);

        if (registrationId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String fullName = clean(request.getParameter("full_name"));
        String email = clean(request.getParameter("email"));
        String phone = clean(request.getParameter("phone"));
        String address = clean(request.getParameter("address"));

        String error = null;
        String cleanPhone = phone.replaceAll("[\\s-]", "");

        if (fullName.length() < 3 || fullName.length() > 100) {
            error = "Name must be between 3 and 100 characters.";
        } else if (email.length() > 100 || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            error = "Please provide a valid email address.";
        } else if (!cleanPhone.isEmpty() && !cleanPhone.matches("^(\\+)?[0-9]{10,15}$")) {
            error = "Enter a valid phone number (10 to 15 digits).";
        } else if (address.length() > 255) {
            error = "Address cannot exceed 255 characters.";
        }

        if (error != null) {
            fail(request, response, session, error);
            return;
        }

        String emailCheck = "SELECT 1 FROM registration WHERE LOWER(email) = ? AND registration_id <> ?";
        String update = "UPDATE registration SET full_name = ?, email = ?, phone = ?, address = ? "
                + "WHERE registration_id = ?";

        try (Connection con = AuthServlet.DBconnection.getConnection()) {

            // The email must not belong to a different account
            try (PreparedStatement ps = con.prepareStatement(emailCheck)) {
                ps.setString(1, email.toLowerCase());
                ps.setInt(2, registrationId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        fail(request, response, session, "This email is already used by another account.");
                        return;
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(update)) {
                ps.setString(1, fullName);
                ps.setString(2, email.toLowerCase());
                ps.setString(3, phone.isEmpty() ? null : phone);
                ps.setString(4, address.isEmpty() ? null : address);
                ps.setInt(5, registrationId);

                if (ps.executeUpdate() > 0) {
                    // Keep the entire session in sync
                    session.setAttribute("fullName", fullName);
                    session.setAttribute("userEmail", email.toLowerCase());
                    session.setAttribute("phone", phone);
                    session.setAttribute("userPhone", phone);
                    session.setAttribute("address", address);
                    session.setAttribute("userAddress", address);
                    session.setAttribute("successMessage", "Profile updated successfully.");
                } else {
                    session.setAttribute("errorMessage", "Failed to update profile.");
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Database error while updating profile.", e);
        }

        response.sendRedirect(request.getContextPath() + "/profile");
    }

    private Integer getRegistrationId(HttpSession session) {
        if (session == null) {
            return null;
        }
        // LoginServlet stores "userId"; "registration_id" is accepted as a fallback
        Object idObj = session.getAttribute("userId");
        if (idObj == null) {
            idObj = session.getAttribute("registration_id");
        }
        if (idObj == null) {
            return null;
        }
        try {
            return (idObj instanceof Integer)
                    ? (Integer) idObj
                    : Integer.valueOf(idObj.toString().trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private void fail(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, String message) throws IOException {
        session.setAttribute("errorMessage", message);
        response.sendRedirect(request.getContextPath() + "/profile");
    }
}
