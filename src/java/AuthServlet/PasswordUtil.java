package AuthServlet;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Utility class for cryptographic password hashing and verification.
 * Uses standard SHA-256 (64-character hexadecimal digest), fully
 * compatible with MySQL's SHA2(password, 256) function.
 */
public class PasswordUtil {

    private PasswordUtil() {
        // Prevent instantiation
    }

    /**
     * Hashes a plain-text password using SHA-256.
     *
     * @param password Plain-text password to hash
     * @return 64-character lowercase hexadecimal hash string, or null if input is null
     */
    public static String hashPassword(String password) {
        if (password == null) {
            return null;
        }

        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(password.getBytes(StandardCharsets.UTF_8));

            StringBuilder hexString = new StringBuilder(64);
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available in current environment", e);
        }
    }

    /**
     * Verifies a plain-text password against a stored password string.
     * Supports both SHA-256 hashed passwords (constant-time comparison)
     * and transparent backward-compatibility with legacy unhashed plain-text records.
     *
     * @param plainPassword The plain-text password entered by the user
     * @param storedPassword The password/hash stored in the database
     * @return true if credentials match, false otherwise
     */
    public static boolean checkPassword(String plainPassword, String storedPassword) {
        if (plainPassword == null || storedPassword == null) {
            return false;
        }

        String hashedInput = hashPassword(plainPassword);
        if (hashedInput == null) {
            return false;
        }

        // 1. Primary check: Constant-time comparison against SHA-256 hash
        boolean hashMatches = MessageDigest.isEqual(
                hashedInput.getBytes(StandardCharsets.UTF_8),
                storedPassword.toLowerCase().getBytes(StandardCharsets.UTF_8)
        );

        if (hashMatches) {
            return true;
        }

        // 2. Backward-compatibility check: Support legacy unhashed plain-text passwords
        return plainPassword.equals(storedPassword);
    }

    /**
     * Checks if a stored password string appears to be a valid SHA-256 hex digest.
     *
     * @param storedPassword The password string to inspect
     * @return true if it is a 64-character hexadecimal string
     */
    public static boolean isHashed(String storedPassword) {
        if (storedPassword == null || storedPassword.length() != 64) {
            return false;
        }
        return storedPassword.matches("^[0-9a-fA-F]{64}$");
    }
}

