package AuthServlet.Admin;

import AuthServlet.DBconnection;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet(urlPatterns = {"/admin/rooms", "/admin/room-management", "/admin/room"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB buffer
        maxFileSize = 1024 * 1024 * 10, // 10MB per file
        maxRequestSize = 1024 * 1024 * 50 // 50MB total per form submit
)
public class room extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads" + File.separator + "rooms";

    // --- DATA CARRIER BEANS ---
    public static class RoomTypeBean {

        private int id;
        private String name;

        public RoomTypeBean(int id, String name) {
            this.id = id;
            this.name = name;
        }

        public int getId() {
            return id;
        }

        public String getName() {
            return name;
        }
    }

    public static class RoomBean {

        private int id;
        private String roomNumber;
        private int roomTypeId;
        private String typeName;
        private String title;
        private String shortDescription;
        private BigDecimal pricePerNight;
        private int capacity;
        private int areaSqft;
        private String bedType;
        private String status;
        private String amenitiesRaw;
        private List<String> amenities;
        private String imagesRaw;
        private List<String> images;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public String getRoomNumber() {
            return roomNumber;
        }

        public void setRoomNumber(String roomNumber) {
            this.roomNumber = roomNumber;
        }

        public int getRoomTypeId() {
            return roomTypeId;
        }

        public void setRoomTypeId(int roomTypeId) {
            this.roomTypeId = roomTypeId;
        }

        public String getTypeName() {
            return typeName;
        }

        public void setTypeName(String typeName) {
            this.typeName = typeName;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getShortDescription() {
            return shortDescription;
        }

        public void setShortDescription(String shortDescription) {
            this.shortDescription = shortDescription;
        }

        public BigDecimal getPricePerNight() {
            return pricePerNight;
        }

        public void setPricePerNight(BigDecimal pricePerNight) {
            this.pricePerNight = pricePerNight;
        }

        public int getCapacity() {
            return capacity;
        }

        public void setCapacity(int capacity) {
            this.capacity = capacity;
        }

        public int getAreaSqft() {
            return areaSqft;
        }

        public void setAreaSqft(int areaSqft) {
            this.areaSqft = areaSqft;
        }

        public String getBedType() {
            return bedType;
        }

        public void setBedType(String bedType) {
            this.bedType = bedType;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getAmenitiesRaw() {
            return amenitiesRaw;
        }

        public void setAmenitiesRaw(String amenitiesRaw) {
            this.amenitiesRaw = amenitiesRaw;
        }

        public List<String> getAmenities() {
            return amenities;
        }

        public void setAmenities(List<String> amenities) {
            this.amenities = amenities;
        }

        public String getImagesRaw() {
            return imagesRaw;
        }

        public void setImagesRaw(String imagesRaw) {
            this.imagesRaw = imagesRaw;
        }

        public List<String> getImages() {
            return images;
        }

        public void setImages(List<String> images) {
            this.images = images;
        }

        public String getPrimaryImage() {
            if (images != null && !images.isEmpty()) {
                String first = images.get(0);
                return first != null ? first.trim().replace("\\", "/") : "";
            }
            return "";
        }
    }

    // --- GET: RETRIEVE DATA & FORWARD TO JSP ---
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"admin".equalsIgnoreCase((String) session.getAttribute("userRole"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        ensureTableSchema();

        try {
            List<RoomTypeBean> roomTypes = fetchRoomTypes();
            List<RoomBean> rooms = fetchRooms();

            int totalRooms = rooms.size();
            long bookedCount = rooms.stream().filter(r -> "Booked".equalsIgnoreCase(r.getStatus())).count();
            long maintenanceCount = rooms.stream().filter(r -> "Maintenance".equalsIgnoreCase(r.getStatus())).count();
            long availableCount = totalRooms - bookedCount - maintenanceCount;
            if (availableCount < 0) availableCount = 0;

            req.setAttribute("roomTypes", roomTypes);
            req.setAttribute("rooms", rooms);
            req.setAttribute("totalRooms", totalRooms);
            req.setAttribute("availableCount", availableCount);
            req.setAttribute("bookedCount", bookedCount);
            req.setAttribute("maintenanceCount", maintenanceCount);

            req.getRequestDispatcher("/admin/room.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error loading inventory", e);
        }
    }

    // --- POST: DISPATCH CRUD ACTIONS ---
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"admin".equalsIgnoreCase((String) session.getAttribute("userRole"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            action = "";
        }

        ensureTableSchema();

        try {
            switch (action.toLowerCase()) {
                case "create":
                    insertRoom(req);
                    req.getSession().setAttribute("toastMsg", "Room created successfully!");
                    break;
                case "update":
                    updateRoom(req);
                    req.getSession().setAttribute("toastMsg", "Room updated successfully!");
                    break;
                case "toggle":
                    int toggleId = Integer.parseInt(req.getParameter("room_id"));
                    String currentStatus = req.getParameter("current_status");
                    String newStatus = "Available".equalsIgnoreCase(currentStatus) ? "Maintenance" : "Available";
                    updateRoomStatus(toggleId, newStatus);
                    req.getSession().setAttribute("toastMsg", "Room status changed to " + newStatus);
                    break;
                case "delete":
                    int delId = Integer.parseInt(req.getParameter("room_id"));
                    deleteRoom(delId, req);
                    req.getSession().setAttribute("toastMsg", "Room deleted successfully!");
                    break;
                default:
                    req.getSession().setAttribute("toastMsg", "Invalid action requested.");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("toastMsg", "Error: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/rooms");
    }

    // --- DATABASE QUERIES ---
    private List<RoomTypeBean> fetchRoomTypes() throws SQLException {
        List<RoomTypeBean> types = new ArrayList<>();
        String sql = "SELECT id, name FROM room_types ORDER BY id ASC";
        try (Connection con = DBconnection.getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        types.add(new RoomTypeBean(rs.getInt("id"), rs.getString("name")));
                    }
                }
            }
        }
        return types;
    }

    private List<RoomBean> fetchRooms() throws SQLException {
        List<RoomBean> list = new ArrayList<>();
        String sql = "SELECT r.id, r.room_number, r.room_type_id, COALESCE(rt.name, 'Standard') AS type_name, "
                + "r.title, r.short_description, r.price_per_night, r.capacity, "
                + "r.area_sqft, r.bed_type, r.status, "
                + "(SELECT GROUP_CONCAT(DISTINCT amenity_code) FROM room_amenity_mapping WHERE room_id = r.id) AS amenities_str, "
                + "(SELECT GROUP_CONCAT(image_url ORDER BY is_primary DESC, id ASC) FROM room_images WHERE room_id = r.id) AS images_str, "
                + "(SELECT COUNT(*) FROM bookings b WHERE b.room_id = r.id AND b.booking_status = 'CONFIRMED' AND b.check_out >= CURRENT_DATE) AS active_booking_count "
                + "FROM rooms r "
                + "LEFT JOIN room_types rt ON r.room_type_id = rt.id "
                + "ORDER BY r.room_number ASC";

        try (Connection con = DBconnection.getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        RoomBean r = new RoomBean();
                        r.setId(rs.getInt("id"));
                        r.setRoomNumber(rs.getString("room_number"));
                        r.setRoomTypeId(rs.getInt("room_type_id"));
                        r.setTypeName(rs.getString("type_name"));
                        r.setTitle(rs.getString("title"));
                        r.setShortDescription(rs.getString("short_description"));
                        r.setPricePerNight(rs.getBigDecimal("price_per_night"));
                        r.setCapacity(rs.getInt("capacity"));
                        r.setAreaSqft(rs.getInt("area_sqft"));
                        r.setBedType(rs.getString("bed_type"));

                        int activeBookings = 0;
                        try {
                            activeBookings = rs.getInt("active_booking_count");
                        } catch (Exception ignored) {}

                        String rawStatus = rs.getString("status");
                        if ("Maintenance".equalsIgnoreCase(rawStatus)) {
                            r.setStatus("Maintenance");
                        } else if ("Booked".equalsIgnoreCase(rawStatus) || activeBookings > 0) {
                            r.setStatus("Booked");
                        } else {
                            r.setStatus("Available");
                        }

                        String amStr = rs.getString("amenities_str");
                        r.setAmenitiesRaw(amStr != null ? amStr : "");
                        if (amStr != null && !amStr.trim().isEmpty()) {
                            r.setAmenities(Arrays.asList(amStr.split(",")));
                        } else {
                            r.setAmenities(new ArrayList<>());
                        }

                        String imgStr = rs.getString("images_str");
                        r.setImagesRaw(imgStr != null ? imgStr : "");
                        if (imgStr != null && !imgStr.trim().isEmpty()) {
                            List<String> imgList = new ArrayList<>();
                            for (String s : imgStr.split(",")) {
                                String clean = s.trim().replace("\\", "/");
                                if (!clean.isEmpty()) {
                                    imgList.add(clean);
                                }
                            }
                            r.setImages(imgList);
                        } else {
                            r.setImages(new ArrayList<>());
                        }

                        list.add(r);
                    }
                }
            }
        }
        return list;
    }

    private void insertRoom(HttpServletRequest req) throws Exception {
        String insertSql = "INSERT INTO rooms (room_number, room_type_id, title, short_description, price_per_night, capacity, area_sqft, bed_type, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String amSql = "INSERT INTO room_amenity_mapping (room_id, amenity_code) VALUES (?, ?)";

        Connection con = null;
        try {
            con = DBconnection.getConnection();
            if (con == null) {
                throw new SQLException("Unable to connect to database");
            }
            con.setAutoCommit(false);

            int newRoomId = 0;
            try (PreparedStatement ps = con.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, req.getParameter("room_number") != null ? req.getParameter("room_number").trim() : "");
                ps.setInt(2, Integer.parseInt(req.getParameter("room_type_id").trim()));
                ps.setString(3, req.getParameter("title") != null ? req.getParameter("title").trim() : "");
                ps.setString(4, req.getParameter("short_description") != null ? req.getParameter("short_description").trim() : "");
                ps.setBigDecimal(5, new BigDecimal(req.getParameter("price_per_night").trim()));
                ps.setInt(6, Integer.parseInt(req.getParameter("capacity").trim()));
                ps.setInt(7, Integer.parseInt(req.getParameter("area_sqft").trim()));
                ps.setString(8, req.getParameter("bed_type") != null ? req.getParameter("bed_type").trim() : "");
                ps.setString(9, req.getParameter("status") != null ? req.getParameter("status").trim() : "Available");
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        newRoomId = rs.getInt(1);
                    }
                }
            }

            // Save amenities
            String[] amenities = req.getParameterValues("amenities");
            if (newRoomId > 0 && amenities != null) {
                try (PreparedStatement psAm = con.prepareStatement(amSql)) {
                    for (String code : amenities) {
                        psAm.setInt(1, newRoomId);
                        psAm.setString(2, code.trim());
                        psAm.addBatch();
                    }
                    psAm.executeBatch();
                }
            }

            // Save uploaded room photos
            saveRoomImages(req, con, newRoomId, true);

            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }

    private void updateRoom(HttpServletRequest req) throws Exception {
        String updateSql = "UPDATE rooms SET room_number = ?, room_type_id = ?, title = ?, short_description = ?, "
                + "price_per_night = ?, capacity = ?, area_sqft = ?, bed_type = ?, status = ? WHERE id = ?";
        String delAmSql = "DELETE FROM room_amenity_mapping WHERE room_id = ?";
        String insertAmSql = "INSERT INTO room_amenity_mapping (room_id, amenity_code) VALUES (?, ?)";

        int roomId = Integer.parseInt(req.getParameter("room_id").trim());

        Connection con = null;
        try {
            con = DBconnection.getConnection();
            if (con == null) {
                throw new SQLException("Unable to connect to database");
            }
            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setString(1, req.getParameter("room_number") != null ? req.getParameter("room_number").trim() : "");
                ps.setInt(2, Integer.parseInt(req.getParameter("room_type_id").trim()));
                ps.setString(3, req.getParameter("title") != null ? req.getParameter("title").trim() : "");
                ps.setString(4, req.getParameter("short_description") != null ? req.getParameter("short_description").trim() : "");
                ps.setBigDecimal(5, new BigDecimal(req.getParameter("price_per_night").trim()));
                ps.setInt(6, Integer.parseInt(req.getParameter("capacity").trim()));
                ps.setInt(7, Integer.parseInt(req.getParameter("area_sqft").trim()));
                ps.setString(8, req.getParameter("bed_type") != null ? req.getParameter("bed_type").trim() : "");
                ps.setString(9, req.getParameter("status") != null ? req.getParameter("status").trim() : "Available");
                ps.setInt(10, roomId);
                ps.executeUpdate();
            }

            // Re-sync amenities
            try (PreparedStatement psDel = con.prepareStatement(delAmSql)) {
                psDel.setInt(1, roomId);
                psDel.executeUpdate();
            }

            String[] amenities = req.getParameterValues("amenities");
            if (amenities != null && amenities.length > 0) {
                try (PreparedStatement psAm = con.prepareStatement(insertAmSql)) {
                    for (String code : amenities) {
                        psAm.setInt(1, roomId);
                        psAm.setString(2, code.trim());
                        psAm.addBatch();
                    }
                    psAm.executeBatch();
                }
            }

            // If new images were provided, append them
            saveRoomImages(req, con, roomId, false);

            con.commit();
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }

    private void saveRoomImages(HttpServletRequest req, Connection con, int roomId, boolean isNewRoom) throws IOException, ServletException, SQLException {
        String realPath = req.getServletContext().getRealPath("");
        String uploadPath = realPath + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // Also locate project source "web/uploads/rooms" so uploaded images persist across NetBeans rebuilds
        File sourceWebDir = null;
        try {
            File currentDir = new File(realPath);
            File projectRoot = currentDir.getParentFile() != null ? currentDir.getParentFile().getParentFile() : null;
            if (projectRoot != null && new File(projectRoot, "web").exists()) {
                sourceWebDir = new File(projectRoot, "web" + File.separator + UPLOAD_DIR);
                if (!sourceWebDir.exists()) {
                    sourceWebDir.mkdirs();
                }
            }
        } catch (Exception ignored) {}

        Collection<Part> parts = req.getParts();
        String imgSql = "INSERT INTO room_images (room_id, image_url, is_primary) VALUES (?, ?, ?)";

        boolean isFirst = isNewRoom;
        try (PreparedStatement psImg = con.prepareStatement(imgSql)) {
            boolean hasBatch = false;
            for (Part part : parts) {
                if ("room_photos".equals(part.getName()) && part.getSize() > 0) {
                    String submittedFileName = part.getSubmittedFileName();
                    if (submittedFileName != null && !submittedFileName.trim().isEmpty()) {
                        String fileName = Paths.get(submittedFileName).getFileName().toString();
                        if (fileName != null && !fileName.trim().isEmpty()) {
                            String fileExt = "";
                            int dotIndex = fileName.lastIndexOf('.');
                            if (dotIndex > 0) {
                                fileExt = fileName.substring(dotIndex);
                            }

                            String uniqueFileName = "room_" + roomId + "_" + UUID.randomUUID().toString().substring(0, 8) + fileExt;
                            String filePath = uploadPath + File.separator + uniqueFileName;
                            part.write(filePath);

                            // Copy to source folder if available
                            if (sourceWebDir != null && sourceWebDir.exists()) {
                                try {
                                    java.nio.file.Files.copy(Paths.get(filePath), 
                                            Paths.get(sourceWebDir.getAbsolutePath(), uniqueFileName), 
                                            java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                                } catch (Exception ignored) {}
                            }

                            String relativeDbPath = "uploads/rooms/" + uniqueFileName;
                            psImg.setInt(1, roomId);
                            psImg.setString(2, relativeDbPath);
                            psImg.setBoolean(3, isFirst);
                            psImg.addBatch();
                            hasBatch = true;
                            isFirst = false;
                        }
                    }
                }
            }
            if (hasBatch) {
                psImg.executeBatch();
            }
        }
    }

    private void updateRoomStatus(int roomId, String status) throws SQLException {
        String sql = "UPDATE rooms SET status = ? WHERE id = ?";
        try (Connection con = DBconnection.getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, status);
                    ps.setInt(2, roomId);
                    ps.executeUpdate();
                }
            }
        }
    }

    private void deleteRoom(int roomId, HttpServletRequest req) throws SQLException {
        // Query image files to clean up files from storage
        String getImagesSql = "SELECT image_url FROM room_images WHERE room_id = ?";
        try (Connection con = DBconnection.getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(getImagesSql)) {
                    ps.setInt(1, roomId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            String relativePath = rs.getString("image_url");
                            if (relativePath != null && !relativePath.isEmpty()) {
                                File file = new File(req.getServletContext().getRealPath("") + File.separator + relativePath);
                                if (file.exists()) {
                                    file.delete();
                                }
                            }
                        }
                    }
                }

                // Delete associated bookings first to prevent FK constraint failures
                try (PreparedStatement psDelBookings = con.prepareStatement("DELETE FROM bookings WHERE room_id = ?")) {
                    psDelBookings.setInt(1, roomId);
                    psDelBookings.executeUpdate();
                }

                // Explicitly delete child mapping records
                try (PreparedStatement psDelAm = con.prepareStatement("DELETE FROM room_amenity_mapping WHERE room_id = ?")) {
                    psDelAm.setInt(1, roomId);
                    psDelAm.executeUpdate();
                }
                try (PreparedStatement psDelImg = con.prepareStatement("DELETE FROM room_images WHERE room_id = ?")) {
                    psDelImg.setInt(1, roomId);
                    psDelImg.executeUpdate();
                }

                // Delete the room record
                String sql = "DELETE FROM rooms WHERE id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, roomId);
                    ps.executeUpdate();
                }
            }
        }
    }

    private void ensureTableSchema() {
        try (Connection con = DBconnection.getConnection()) {
            if (con != null) {
                try (Statement st = con.createStatement()) {
                    st.executeUpdate("ALTER TABLE room_amenity_mapping MODIFY COLUMN amenity_code VARCHAR(100) NOT NULL");
                } catch (Exception ignored) {}
            }
        } catch (Exception ignored) {}
    }
}
