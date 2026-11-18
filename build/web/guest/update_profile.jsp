<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    /* If accessed directly without passing through servlet, forward to servlet */
    if (request.getAttribute("customer") == null) {
        response.sendRedirect(request.getContextPath() + "/profile");
        return;
    }
%>

<%-- Which tab to open (set by UpdateProfileServlet after a password change) --%>
<c:set var="initialTab" value="${empty sessionScope.activeTab ? 'personal' : sessionScope.activeTab}"/>
<c:remove var="activeTab" scope="session"/>

<%-- Flash messages set by ProfileServlet / UpdateProfileServlet --%>
<c:set var="flashSuccess" value="${sessionScope.successMessage}"/>
<c:set var="flashError" value="${sessionScope.errorMessage}"/>
<c:remove var="successMessage" scope="session"/>
<c:remove var="errorMessage" scope="session"/>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>GrandStay Privé | My Profile</title>

        <!-- Google Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&family=Playfair+Display:ital,wght@0,600;0,700;1,400&display=swap" rel="stylesheet">

        <!-- Bootstrap & Icons -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">


        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/guest/upadate_profile.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/guest/navbar.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/CSS/modal.css">

    </head>

    <body data-initial-tab="<c:out value='${initialTab}'/>">

        <!-- Header -->
        <jsp:include page="navbar.jsp" />

        <!-- Main Content -->
        <main class="container profile-container">

            <div class="page-heading">
                <span class="eyebrow">ACCOUNT SETTINGS</span>
                <h1>Guest Profile</h1>
                <p>Review your personal records and configure authentication credentials.</p>
            </div>

            <div class="profile-layout">

                <!-- Sidebar: Current Account Summary (data from database) -->
                <aside class="profile-sidebar">
                    <div class="member-card">
                        <div class="member-avatar">
                            <i class="bi bi-person"></i>
                        </div>
                        <h2>
                            <c:out value="${not empty customer.fullName ? customer.fullName : 'Valued Guest'}"/>
                        </h2>
                        <div class="member-status">
                            <i class="bi bi-gem"></i> Privé Club Member
                        </div>

                        <div class="member-divider"></div>

                        <div class="member-info">
                            <i class="bi bi-envelope"></i>
                            <span class="text-truncate"><c:out value="${customer.email}"/></span>
                        </div>
                        <div class="member-info">
                            <i class="bi bi-telephone"></i>
                            <span><c:out value="${not empty customer.phone ? customer.phone : 'No phone linked'}"/></span>
                        </div>
                        <div class="member-info">
                            <i class="bi bi-geo-alt"></i>
                            <span class="text-truncate"><c:out value="${not empty customer.address ? customer.address : 'No address saved'}"/></span>
                        </div>
                        <div class="member-info">
                            <i class="bi bi-shield-check"></i>
                            <span>Verified Account</span>
                        </div>
                    </div>

                    <div class="sidebar-note">
                        <i class="bi bi-shield-lock-fill"></i>
                        <h3>Credential Safety</h3>
                        <p>Passwords are never displayed in plain text. Provide your current credentials to authorize updates.</p>
                    </div>
                </aside>

                <!-- Profile Management Panels -->
                <div class="profile-content">

                    <!-- Tab Switcher -->
                    <div class="profile-tabs" role="tablist">
                        <button type="button" id="personalTab" class="profile-tab active" role="tab"
                                aria-selected="true" onclick="showTab('personal')">
                            <i class="bi bi-person-badge"></i>
                            <span>Personal Details</span>
                        </button>
                        <button type="button" id="securityTab" class="profile-tab" role="tab"
                                aria-selected="false" onclick="showTab('security')">
                            <i class="bi bi-key"></i>
                            <span>Security &amp; Password</span>
                        </button>
                    </div>

                    <!-- Panel 1: Personal Details -->
                    <section id="personalPanel" class="tab-panel" role="tabpanel">
                        <div class="section-heading">
                            <div>
                                <h2>Current Information</h2>
                                <p>Update your contact and personal information stored on file.</p>
                            </div>
                            <div class="section-icon">
                                <i class="bi bi-person-lines-fill"></i>
                            </div>
                        </div>

                        <form id="profileForm" action="${pageContext.request.contextPath}/update-profile"
                              method="post" autocomplete="off" novalidate>

                            <div class="form-group-luxury">
                                <label for="full_name">Full Name</label>
                                <input type="text"
                                       class="form-control-luxury"
                                       id="full_name"
                                       name="full_name"
                                       maxlength="100"
                                       value="<c:out value='${customer.fullName}'/>"
                                       required>
                                <span id="nameError" class="field-error"></span>
                            </div>

                            <div class="row">
                                <div class="col-md-6 form-group-luxury">
                                    <label for="email">Email Address</label>
                                    <input type="email"
                                           class="form-control-luxury"
                                           id="email"
                                           name="email"
                                           maxlength="100"
                                           value="<c:out value='${customer.email}'/>"
                                           required>
                                    <span id="emailError" class="field-error"></span>
                                </div>

                                <div class="col-md-6 form-group-luxury">
                                    <label for="phone">Phone Number</label>
                                    <input type="tel"
                                           class="form-control-luxury"
                                           id="phone"
                                           name="phone"
                                           maxlength="10"
                                           inputmode="numeric"
                                           placeholder="10-digit mobile number"
                                           value="<c:out value='${customer.phone}'/>">
                                    <span id="phoneError" class="field-error"></span>
                                </div>
                            </div>

                            <div class="form-group-luxury">
                                <label for="address">Mailing / Billing Address</label>
                                <textarea class="form-control-luxury"
                                          id="address"
                                          name="address"
                                          maxlength="255"
                                          rows="3"
                                          placeholder="Street Address, City, State, ZIP"><c:out value="${customer.address}"/></textarea>
                                <span id="addressError" class="field-error"></span>
                            </div>

                            <div class="form-footer">
                                <button type="submit" class="btn-gold-luxury">
                                    <i class="bi bi-check2-circle"></i> Save Profile Details
                                </button>
                            </div>
                        </form>
                    </section>

                    <!-- Panel 2: Account Security -->
                    <section id="securityPanel" class="tab-panel d-none" role="tabpanel">
                        <div class="section-heading">
                            <div>
                                <h2>Account Security</h2>
                                <p>Current passwords are never shown. Enter your existing password to verify identity before saving a new one.</p>
                            </div>
                            <div class="section-icon">
                                <i class="bi bi-shield-lock"></i>
                            </div>
                        </div>

                        <div class="security-banner">
                            <i class="bi bi-info-circle-fill security-icon"></i>
                            <div>
                                <h3>Password Requirements</h3>
                                <p>Must be at least 8 characters and include uppercase, lowercase, numbers, and symbols.</p>
                            </div>
                        </div>

                        <form id="passwordForm" action="${pageContext.request.contextPath}/change-password"
                              method="post" autocomplete="off" novalidate>

                            <div class="form-group-luxury">
                                <label for="current_password">Current Password</label>
                                <div class="password-wrapper">
                                    <input type="password"
                                           class="form-control-luxury"
                                           id="current_password"
                                           name="current_password"
                                           placeholder="Enter your current password"
                                           autocomplete="current-password"
                                           required>
                                    <button type="button"
                                            class="password-toggle"
                                            onclick="togglePassword('current_password', this)"
                                            aria-label="Show password">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                </div>
                                <span id="currentPasswordError" class="field-error"></span>
                            </div>

                            <div class="row">
                                <div class="col-md-6 form-group-luxury">
                                    <label for="new_password">New Password</label>
                                    <div class="password-wrapper">
                                        <input type="password"
                                               class="form-control-luxury"
                                               id="new_password"
                                               name="new_password"
                                               minlength="8"
                                               placeholder="Minimum 8 characters"
                                               autocomplete="new-password"
                                               required>
                                        <button type="button"
                                                class="password-toggle"
                                                onclick="togglePassword('new_password', this)"
                                                aria-label="Show password">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                    <div class="strength-meter">
                                        <div id="strengthFill"></div>
                                    </div>
                                    <div class="strength-caption">
                                        <span>Strength</span>
                                        <span id="strengthText">None</span>
                                    </div>
                                    <span id="newPasswordError" class="field-error"></span>
                                </div>

                                <div class="col-md-6 form-group-luxury">
                                    <label for="confirm_password">Confirm New Password</label>
                                    <div class="password-wrapper">
                                        <input type="password"
                                               class="form-control-luxury"
                                               id="confirm_password"
                                               name="confirm_password"
                                               minlength="8"
                                               placeholder="Re-enter new password"
                                               autocomplete="new-password"
                                               required>
                                        <button type="button"
                                                class="password-toggle"
                                                onclick="togglePassword('confirm_password', this)"
                                                aria-label="Show password">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                    </div>
                                    <span id="confirmPasswordError" class="field-error"></span>
                                </div>
                            </div>

                            <div class="form-footer">
                                <button type="submit" class="btn-gold-luxury">
                                    <i class="bi bi-shield-check"></i> Update Password
                                </button>
                            </div>
                        </form>
                    </section>

                </div>
            </div>

        </main>

        <!-- Result Pop-up (shown after profile / password update) -->
        <c:if test="${not empty flashSuccess or not empty flashError}">
            <div class="modal fade" id="resultModal" tabindex="-1"
                 aria-labelledby="resultModalTitle" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content luxury-modal">
                        <div class="modal-body text-center">

                            <c:choose>
                                <c:when test="${not empty flashError}">
                                    <div class="modal-status modal-status-danger">
                                        <i class="bi bi-exclamation-circle-fill"></i>
                                    </div>
                                    <span class="modal-eyebrow">Security Notice</span>
                                    <h4 id="resultModalTitle" class="modal-title">Update Failed</h4>
                                    <p class="modal-lead"><c:out value="${flashError}"/></p>
                                    <button type="button" class="btn-gold-luxury" data-bs-dismiss="modal">
                                        Try Again
                                    </button>
                                </c:when>

                                <c:otherwise>
                                    <div class="modal-status modal-status-success">
                                        <i class="bi bi-check-circle-fill"></i>
                                    </div>
                                    <span class="modal-eyebrow">Privé Profile</span>
                                    <h4 id="resultModalTitle" class="modal-title">Update Successful</h4>
                                    <p class="modal-lead"><c:out value="${flashSuccess}"/></p>
                                    <button type="button" class="btn-gold-luxury" data-bs-dismiss="modal">
                                        Continue
                                    </button>
                                </c:otherwise>
                            </c:choose>

                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <footer class="profile-footer">
            <p>&copy; 2026 GRANDSTAY HOTEL &amp; RESIDENCES. ALL RIGHTS RESERVED.</p>
        </footer>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <!-- Custom Script -->
        <script src="${pageContext.request.contextPath}/JS/guest/update_profile.js"></script>
    </body>
</html>
