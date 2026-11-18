
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    HttpSession currSession = request.getSession(false);
    if (currSession != null && currSession.getAttribute("userId") != null) {
        String role = (String) currSession.getAttribute("userRole");
        if ("admin".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        } else {
            response.sendRedirect(request.getContextPath() + "/guest/dashboard.jsp");
            return;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>GrandStay Privé | Member Access</title>

        <!-- Google Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

        <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&family=Playfair+Display:wght@400;500;600;700&display=swap"
              rel="stylesheet">

        <!-- Bootstrap 5.3 -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">

        <!-- Bootstrap Icons -->
        <link rel="stylesheet"
              href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

        <!-- Font Awesome -->
        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <!-- Custom CSS -->
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/CSS/login.css">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/CSS/modal.css">

    </head>

    <body>

        <!-- Header -->
        <header class="auth-header d-flex justify-content-between align-items-center">

            <a href="${pageContext.request.contextPath}/index.html"
               class="d-flex align-items-center gap-2 text-decoration-none">

                <div class="brand-crest">
                    <span class="font-serif fw-bold text-gold fs-5">GS</span>
                </div>

                <div class="d-flex flex-column">

                    <span class="font-serif fw-bold text-white fs-5 lh-1">
                        GRANDSTAY
                    </span>

                    <span class="text-gold letter-spacing-2 text-uppercase brand-subtitle">
                        Hotel &amp; Residences
                    </span>

                </div>

            </a>

            <div class="d-flex align-items-center gap-2">

                <a href="${pageContext.request.contextPath}/index.html"
                   class="nav-action-btn d-none d-sm-inline-flex">

                    <i class="bi bi-house text-gold"></i>
                    <span>Hotel Home</span>

                </a>

                <a href="${pageContext.request.contextPath}/register.jsp"
                   class="nav-action-btn">

                    <i class="bi bi-person-plus text-gold"></i>
                    <span>Register</span>

                </a>

            </div>

        </header>


        <!-- Main Login Card -->
        <main class="login-container">

            <section class="luxury-login-card" aria-labelledby="loginTitle">

                <!-- Login Heading -->
                <div class="text-center mb-4">

                    <div class="access-label d-inline-flex align-items-center gap-2 px-3 py-1 rounded-pill mb-3">

                        <i class="fa-solid fa-gem text-gold"></i>

                        <span class="text-gold-light letter-spacing-2 text-uppercase fw-semibold">
                            Privé Society Access
                        </span>

                    </div>

                    <h1 id="loginTitle" class="display-6 fw-bold mb-2">
                        Member Sign In
                    </h1>

                    <p class="auth-lead">
                        Authenticate with your registered credentials.
                    </p>

                </div>

                <!-- Login Form -->
                <form id="loginForm"
                      method="post"
                      action="${pageContext.request.contextPath}/login"
                      autocomplete="off">

                    <!-- Email Input -->
                    <div class="form-group-luxury">

                        <label for="email">

                            <span>
                                <i class="fa-solid fa-envelope text-gold me-1"></i>
                                Email ID
                                <span class="text-danger">*</span>
                            </span>

                        </label>

                        <div class="input-icon-wrapper">

                            <i class="bi bi-envelope input-leading-icon"></i>

                            <input type="email"
                                   id="email"
                                   name="email"
                                   class="form-control form-control-luxury"
                                   placeholder="Enter your email"
                                   maxlength="100"
                                   autocomplete="email"
                                   value="${requestScope.loginError != null ? param.email : ''}"
                                   required>

                        </div>

                    </div>


                    <!-- Password Input -->
                    <div class="form-group-luxury">

                        <div class="d-flex justify-content-between align-items-center mb-1">

                            <label for="password" class="mb-0">

                                <span>
                                    <i class="fa-solid fa-key text-gold me-1"></i>
                                    Password
                                    <span class="text-danger">*</span>
                                </span>

                            </label>

                            <a href="#" class="forgot-link">
                                Forgot Password?
                            </a>

                        </div>

                        <div class="input-icon-wrapper position-relative">

                            <i class="bi bi-lock input-leading-icon"></i>

                            <input type="password"
                                   id="password"
                                   name="password"
                                   class="form-control form-control-luxury pe-5"
                                   placeholder="Enter your password"
                                   maxlength="255"
                                   autocomplete="current-password"
                                   required>

                            <button type="button"
                                    class="password-toggle-btn position-absolute top-50 end-0 translate-middle-y me-2 border-0 bg-transparent text-secondary"
                                    id="passwordToggle"
                                    aria-label="Show password"
                                    aria-pressed="false">

                                <i class="bi bi-eye" id="toggleIcon"></i>

                            </button>

                        </div>

                    </div>


                    <!-- Login Button -->
                    <button type="submit"
                            class="btn btn-gold-luxury w-100 mb-4 d-flex align-items-center justify-content-center gap-2">

                        <i class="bi bi-door-open-fill fs-5"></i>

                        <span>Authenticate &amp; Enter</span>

                    </button>


                    <!-- Registration Link -->
                    <p class="signup-prompt text-center pt-3 mb-0 small">
                        Not yet a member of GrandStay Privé?
                    </p>

                    <a href="${pageContext.request.contextPath}/register.jsp"
                       class="signup-link d-block text-center fw-semibold mt-2">

                        Create an Account &rarr;

                    </a>

                </form>

            </section>

        </main>


        <!-- Login Result Popup -->
        <div class="modal fade"
             id="loginResultModal"
             tabindex="-1"
             aria-hidden="true">

            <div class="modal-dialog modal-dialog-centered">

                <div class="modal-content luxury-modal">

                    <div class="modal-body text-center">

                        <% if (request.getAttribute("loginError") != null) {%>

                        <div class="modal-status modal-status-danger">
                            <i class="bi bi-exclamation-circle-fill"></i>
                        </div>

                        <span class="modal-eyebrow">Security Notice</span>
                        <h4 class="modal-title">Authentication Failed</h4>

                        <p class="modal-lead">
                            <%= request.getAttribute("loginError")%>
                        </p>

                        <button type="button"
                                class="btn-gold-luxury"
                                data-bs-dismiss="modal">
                            Try Again
                        </button>

                        <% } else if ("true".equals(request.getParameter("registered"))) { %>

                        <div class="modal-status modal-status-success">
                            <i class="bi bi-check-circle-fill"></i>
                        </div>

                        <span class="modal-eyebrow">Registration Complete</span>
                        <h4 class="modal-title">Welcome to GrandStay</h4>

                        <p class="modal-lead">
                            Your guest profile has been successfully registered. Please sign in with your credentials.
                        </p>

                        <button type="button"
                                class="btn-gold-luxury"
                                data-bs-dismiss="modal">
                            Sign In Now
                        </button>

                        <% } else if (request.getAttribute("loginSuccess") != null) { %>

                        <div class="modal-status modal-status-success">
                            <i class="bi bi-check-circle-fill"></i>
                        </div>

                        <span class="modal-eyebrow">Access Granted</span>
                        <h4 class="modal-title">Welcome to GrandStay</h4>

                        <p class="modal-lead">
                            Login successful. Redirecting to your account...
                        </p>

                        <div class="modal-spinner-wrapper">
                            <div class="spinner-border text-gold" role="status">
                                <span class="visually-hidden">Redirecting...</span>
                            </div>
                        </div>

                        <% } %>

                    </div>

                </div>

            </div>
        </div>

        <!-- Bootstrap JavaScript -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>


        <!-- Custom JavaScript -->
        <script>
            document.addEventListener("DOMContentLoaded", function () {

                // Password visibility
                const toggleBtn = document.getElementById("passwordToggle");
                const passwordInput = document.getElementById("password");
                const toggleIcon = document.getElementById("toggleIcon");

                if (toggleBtn && passwordInput && toggleIcon) {

                    toggleBtn.addEventListener("click", function () {

                        const isPassword = passwordInput.type === "password";

                        passwordInput.type = isPassword ? "text" : "password";

                        toggleIcon.classList.toggle("bi-eye");
                        toggleIcon.classList.toggle("bi-eye-slash");

                    });
                }

                // Show login popup
            <% if (request.getAttribute("loginError") != null
                            || request.getAttribute("loginSuccess") != null
                            || "true".equals(request.getParameter("registered"))) { %>

                const modalElement = document.getElementById("loginResultModal");

                if (modalElement) {
                    new bootstrap.Modal(modalElement).show();
                }

            <% } %>

                // Redirect after successful login
            <% if (request.getAttribute("loginSuccess") != null) { %>

                setTimeout(function () {
                    window.location.href =
                            "${pageContext.request.contextPath}/dashboard.jsp";
                }, 1800);

            <% }%>

            });
        </script>

    </body>
</html>
