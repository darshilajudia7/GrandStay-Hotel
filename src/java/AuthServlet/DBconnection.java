package AuthServlet;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBconnection {

    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/grandstay?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "";

    public static Connection getConnection() {
        Connection conn = null;
        try {
            // Explicitly load MySQL driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            String envUrl = System.getenv("DB_URL");
            String envUser = System.getenv("DB_USER");
            String envPassword = System.getenv("DB_PASSWORD");

            String url = (envUrl != null && !envUrl.trim().isEmpty()) ? envUrl.trim() : DEFAULT_URL;
            String user = (envUser != null && !envUser.trim().isEmpty()) ? envUser.trim() : DEFAULT_USER;
            String password = (envPassword != null) ? envPassword : DEFAULT_PASSWORD;

            conn = DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException e) {
            System.err.println("JDBC Driver Not Found! Put MySQL jar in WEB-INF/lib");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Database Connection Failed! Check URL, user, password, or if MySQL service is running.");
            e.printStackTrace();
        }
        return conn;
    }
}
