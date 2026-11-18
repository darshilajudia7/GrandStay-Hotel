package AuthServlet.guest;

import AuthServlet.PasswordUtil;
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

/**
 * Controller: Handles POST /change-password Verifies the current password
 * against the database, validates the new password and confirms the match
 * before saving.
 *
 * After every result the user is sent back to /profile with the "Security &
 * Password" tab open.
 */
@WebServlet("/change-password")
public class UpdateProfileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // At least 8 chars, with lowercase, uppercase, digit and symbol
    private static final String STRONG_PASSWORD
            = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9]).{8,100}$";

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

        String currentPassword = request.getParameter("current_password");
        String newPassword = request.getParameter("new_password");
        String confirmPassword = request.getParameter("confirm_password");

        //  Validation 
        if (currentPassword == null || currentPassword.isEmpty()) {
            fail(request, response, session, "Please enter your current password.");
            return;
        }

        if (newPassword == null || newPassword.length() < 8) {
            fail(request, response, session, "New password must be at least 8 characters.");
            return;
        }

        if (!newPassword.matches(STRONG_PASSWORD)) {
            fail(request, response, session,
                    "New password must include uppercase, lowercase, a number and a symbol.");
            return;
        }

        if (confirmPassword == null || !newPassword.equals(confirmPassword)) {
            fail(request, response, session, "New passwords do not match.");
            return;
        }

        if (currentPassword.equals(newPassword)) {
            fail(request, response, session, "New password cannot be identical to current password.");
            return;
        }

        String fetchQuery = "SELECT password FROM registration WHERE registration_id = ?";
        String updateQuery = "UPDATE registration SET password = ? WHERE registration_id = ?";

        try (Connection con = AuthServlet.DBconnection.getConnection()) {

            // Step 1: verify the current password
            try (PreparedStatement checkPs = con.prepareStatement(fetchQuery)) {
                checkPs.setInt(1, registrationId);

                try (ResultSet rs = checkPs.executeQuery()) {
                    if (!rs.next()) {
                        fail(request, response, session, "Account not found.");
                        return;
                    }

                    String storedPassword = rs.getString("password");
                    if (storedPassword == null || !PasswordUtil.checkPassword(currentPassword, storedPassword)) {
                        fail(request, response, session, "Current password does not match our records.");
                        return;
                    }

                    if (PasswordUtil.checkPassword(newPassword, storedPassword)) {
                        fail(request, response, session, "New password cannot be identical to current password.");
                        return;
                    }
                }
            }

            // Step 2: save the new password (hashed using SHA-256)
            try (PreparedStatement updatePs = con.prepareStatement(updateQuery)) {
                updatePs.setString(1, PasswordUtil.hashPassword(newPassword));
                updatePs.setInt(2, registrationId);

                if (updatePs.executeUpdate() > 0) {
                    session.setAttribute("successMessage", "Password updated successfully.");
                } else {
                    session.setAttribute("errorMessage", "Failed to update password.");
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Database error during password modification.", e);
        }

        session.setAttribute("activeTab", "security");
        response.sendRedirect(request.getContextPath() + "/profile");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/profile");
    }

    
 /*  Helpers                                                             */
 
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

    private void fail(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, String message) throws IOException {
        session.setAttribute("errorMessage", message);
        session.setAttribute("activeTab", "security");
        response.sendRedirect(request.getContextPath() + "/profile");
    }
}
