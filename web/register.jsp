<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession regSession = request.getSession(false);
    if (regSession != null && regSession.getAttribute("userId") != null) {
        String role = (String) regSession.getAttribute("userRole");
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
        <title>GrandStay Privé | Guest Registration</title>

        <!-- Google Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@0,300;0,400;0,500;0,600;0,700;1,300&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400;1,600&display=swap" rel="stylesheet">

        <!-- Bootstrap 5.3 CSS & Icons -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <!-- Custom Stylesheet -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/register.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/modal.css">
    </head>
    <body>

        <!-- Header Navigation -->
        <header class="register-header d-flex justify-content-between align-items-center sticky-top">
            <a href="${pageContext.request.contextPath}/index.html" class="d-flex align-items-center gap-2 text-decoration-none">
                <div class="brand-crest">
                    <span class="font-serif fw-bold text-gold" style="font-size: 1.1rem;">GS</span>
                </div>
                <div class="d-flex flex-column">
                    <span class="font-serif fw-bold text-white fs-5 tracking-wider lh-1">GRANDSTAY</span>
                    <span class="text-gold letter-spacing-2 text-uppercase" style="font-size: 0.55rem;">Hotel &amp; Residences</span>
                </div>
            </a>

            <div class="d-flex align-items-center gap-3">
                <a href="${pageContext.request.contextPath}/index.html" class="nav-action-btn d-none d-sm-inline-flex">
                    <i class="bi bi-compass text-gold"></i>
                    <span>Explore Suites</span>
                </a>
                <a href="${pageContext.request.contextPath}/login.jsp" class="nav-action-btn">
                    <i class="bi bi-box-arrow-in-right text-gold"></i>
                    <span>Sign In</span>
                </a>
            </div>
        </header>

        <!-- Main Registration Card -->
        <main class="register-container container">
            <div class="row justify-content-center">
                <div class="col-12 col-lg-10 col-xl-8">
                    <div class="luxury-card">

                        <div class="text-center mb-4 pb-2">
                            <span class="text-gold letter-spacing-2 text-uppercase fw-semibold" style="font-size: 0.72rem;">
                                Privé Membership Program
                            </span>
                            <h1 class="font-serif display-5 fw-bold text-white mt-1 mb-2">Create Your Guest Profile</h1>
                            <p class="text-secondary fw-light mx-auto col-md-10" style="font-size: 0.92rem;">
                                Join our exclusive circle to curate your stay preferences, reserve signature suites with priority access, and receive tailored concierge hospitality worldwide.
                            </p>
                        </div>

                        <!-- Registration Form -->
                        <form id="registrationForm"
                              onsubmit="handleFormSubmission(event, '${pageContext.request.contextPath}')"
                              autocomplete="off"
                              novalidate>

                            <input type="hidden" id="role" name="role" value="Customer">

                            <!-- SECTION 1: GUEST IDENTITY -->
                            <div class="form-section-divider">
                                <i class="bi bi-person-badge text-gold"></i>
                                Guest Information
                            </div>

                            <div class="row">
                                <!-- Full Name -->
                                <div class="col-12 col-md-6">
                                    <div class="form-group-luxury">
                                        <label for="full_name">Full Name</label>
                                        <input type="text"
                                               id="full_name"
                                               name="full_name"
                                               class="form-control form-control-luxury"
                                               placeholder="Enter your full name"
                                               minlength="3"
                                               maxlength="100"
                                               required>
                                        <small class="validation-error" id="fullNameError"></small>
                                    </div>
                                </div>

                                <!-- Email -->
                                <div class="col-12 col-md-6">
                                    <div class="form-group-luxury">
                                        <label for="email">Email Address</label>
                                        <input type="email"
                                               id="email"
                                               name="email"
                                               class="form-control form-control-luxury"
                                               placeholder="Enter your email address"
                                               maxlength="100"
                                               required>
                                        <small class="validation-error" id="emailError"></small>
                                    </div>
                                </div>

                                <!-- Phone -->
                                <div class="col-12">
                                    <div class="form-group-luxury">
                                        <label for="phone">Contact Number</label>
                                        <input type="tel"
                                               id="phone"
                                               name="phone"
                                               class="form-control form-control-luxury"
                                               placeholder="Enter your 10-digit mobile number"
                                               maxlength="10"
                                               required>
                                        <small class="validation-error" id="phoneError"></small>
                                    </div>
                                </div>
                            </div>

                            <!-- SECTION 2: RESIDENCE & MAILING -->
                            <div class="form-section-divider mt-4">
                                <i class="bi bi-geo-alt text-gold"></i>
                                Residence &amp; Billing Address
                            </div>

                            <div class="row">
                                <!-- Address -->
                                <div class="col-12">
                                    <div class="form-group-luxury">
                                        <label for="address">Address</label>
                                        <textarea id="address"
                                                  name="address"
                                                  class="form-control form-control-luxury"
                                                  rows="2"
                                                  maxlength="255"
                                                  placeholder="Enter your complete address"
                                                  required></textarea>
                                        <small class="validation-error" id="addressError"></small>
                                    </div>
                                </div>
                            </div>

                            <!-- SECTION 3: ACCOUNT SECURITY -->
                            <div class="form-section-divider mt-4">
                                <i class="bi bi-shield-lock text-gold"></i>
                                Account Security
                            </div>

                            <div class="row">
                                <!-- Password -->
                                <div class="col-12 col-md-6">
                                    <div class="form-group-luxury">
                                        <label for="password">Password</label>
                                        <div class="password-wrapper">
                                            <input type="password"
                                                   id="password"
                                                   name="password"
                                                   class="form-control form-control-luxury pe-5"
                                                   placeholder="Minimum 8 characters"
                                                   minlength="8"
                                                   maxlength="255"
                                                   required>
                                            <button type="button"
                                                    class="password-toggle-btn"
                                                    onclick="togglePasswordVisibility('password', this)"
                                                    aria-label="Toggle password visibility">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                        <small class="validation-error" id="passwordError"></small>

                                        <!-- Strength Meter -->
                                        <div class="strength-meter-bar">
                                            <div id="strengthMeterFill" class="strength-meter-fill"></div>
                                        </div>
                                        <div class="strength-label">
                                            <span>Security Level:</span>
                                            <span id="strengthText">None</span>
                                        </div>
                                    </div>
                                </div>

                                <!-- Confirm Password -->
                                <div class="col-12 col-md-6">
                                    <div class="form-group-luxury">
                                        <label for="confirm_password">Confirm Password</label>
                                        <div class="password-wrapper">
                                            <input type="password"
                                                   id="confirm_password"
                                                   name="confirm_password"
                                                   class="form-control form-control-luxury pe-5"
                                                   placeholder="Re-type your password"
                                                   minlength="8"
                                                   maxlength="255"
                                                   required>
                                            <button type="button"
                                                    class="password-toggle-btn"
                                                    onclick="togglePasswordVisibility('confirm_password', this)"
                                                    aria-label="Toggle confirm password visibility">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                        <small class="validation-error" id="confirmPasswordError"></small>
                                    </div>
                                </div>
                            </div>

                            <!-- Submit Button -->
                            <div class="d-flex flex-column flex-sm-row gap-3 mt-4">
                                <button type="submit"
                                        id="submitBtn"
                                        class="btn btn-gold-luxury flex-grow-1 py-3 d-flex align-items-center justify-content-center gap-2">
                                    <i class="bi bi-check-circle-fill"></i>
                                    <span id="btnText">Complete Registration</span>
                                </button>
                            </div>

                            <!-- Sign-In Link -->
                            <div class="text-center mt-4 pt-2">
                                <span class="text-secondary small">Already a GrandStay Privé member?</span>
                                <a href="${pageContext.request.contextPath}/login.jsp" class="text-gold small fw-semibold text-decoration-none ms-1">
                                    Sign in to your account
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>

        <!-- Success Modal -->
        <div class="modal fade" id="successModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content luxury-modal">
                    <div class="modal-body text-center">
                        <div class="modal-status modal-status-gold">
                            <i class="fa-solid fa-crown"></i>
                        </div>
                        <span class="modal-eyebrow">
                            Privé Privilege Conferred
                        </span>
                        <h4 class="modal-title" id="successGuestName">Welcome, Distinguished Guest</h4>
                        <p class="modal-lead">
                            Your profile and residence preferences have been registered into the GrandStay Privé registry. You may now authenticate your credentials.
                        </p>
                        <div class="modal-badge-info">
                            Redirecting to sign in within <strong id="redirectSeconds" class="text-gold">3</strong> seconds...
                        </div>
                        <div>
                            <button type="button" class="btn-gold-luxury" onclick="proceedToSignIn('${pageContext.request.contextPath}')">
                                Proceed Now <i class="bi bi-arrow-right ms-2"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Registration Error / Notice Modal -->
        <div class="modal fade" id="registerErrorModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content luxury-modal">
                    <div class="modal-body text-center">
                        <div class="modal-status modal-status-danger">
                            <i class="bi bi-exclamation-circle-fill"></i>
                        </div>
                        <span class="modal-eyebrow">Registration Notice</span>
                        <h4 class="modal-title" id="registerErrorTitle">Registration Refused</h4>
                        <p class="modal-lead" id="registerErrorMessage">Failed to save your profile.</p>
                        <button type="button" class="btn-gold-luxury" data-bs-dismiss="modal">
                            Try Again
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Toast Notification -->
        <div id="luxuryToast" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex align-items-start gap-3">
                <div class="rounded-circle d-flex align-items-center justify-content-center bg-dark p-2 border border-gold" style="width: 38px; height: 38px; min-width: 38px;">
                    <i class="bi bi-exclamation-triangle-fill text-gold"></i>
                </div>
                <div class="flex-grow-1">
                    <h6 class="text-gold-light mb-1 small fw-bold text-uppercase letter-spacing-1" id="toastHeading">Notice</h6>
                    <p class="text-light text-opacity-75 small mb-0" id="toastMessage">Information requirement.</p>
                </div>
                <button type="button" class="btn-close btn-close-white btn-sm" onclick="hideToast()" aria-label="Close"></button>
            </div>
        </div>

        <!-- Scripts -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="JS/register.js"></script>
    </body>
</html>