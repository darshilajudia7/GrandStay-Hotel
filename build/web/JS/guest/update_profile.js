"use strict";


/*  Tabs                                                                */

function showTab(tabName) {
    const personalPanel = document.getElementById("personalPanel");
    const securityPanel = document.getElementById("securityPanel");
    const personalTab = document.getElementById("personalTab");
    const securityTab = document.getElementById("securityTab");

    if (!personalPanel || !securityPanel || !personalTab || !securityTab) {
        return;
    }

    const isPersonal = tabName !== "security";

    personalPanel.classList.toggle("d-none", !isPersonal);
    securityPanel.classList.toggle("d-none", isPersonal);

    personalTab.classList.toggle("active", isPersonal);
    securityTab.classList.toggle("active", !isPersonal);

    personalTab.setAttribute("aria-selected", String(isPersonal));
    securityTab.setAttribute("aria-selected", String(!isPersonal));

    clearErrors();
}


/*  Password visibility                                                 */

function togglePassword(inputId, button) {
    const input = document.getElementById(inputId);
    const icon = button.querySelector("i");
    if (!input || !icon) {
        return;
    }

    const isPassword = input.type === "password";
    input.type = isPassword ? "text" : "password";

    icon.classList.toggle("bi-eye", !isPassword);
    icon.classList.toggle("bi-eye-slash", isPassword);

    button.setAttribute("aria-label", isPassword ? "Hide password" : "Show password");
}


/*  Password strength                                                   */

function getPasswordScore(password) {
    let score = 0;
    if (password.length >= 8)
        score++;
    if (/[a-z]/.test(password) && /[A-Z]/.test(password))
        score++;
    if (/[0-9]/.test(password))
        score++;
    if (/[^A-Za-z0-9]/.test(password))
        score++;
    return score;
}

function isStrongPassword(password) {
    return password.length >= 8
        && /[a-z]/.test(password)
        && /[A-Z]/.test(password)
        && /[0-9]/.test(password)
        && /[^A-Za-z0-9]/.test(password);
}

function updatePasswordStrength() {
    const password = document.getElementById("new_password").value;
    const fill = document.getElementById("strengthFill");
    const text = document.getElementById("strengthText");

    const levels = [
        { width: "0%", label: "None", color: "transparent" },
        { width: "25%", label: "Weak", color: "#e57373" },
        { width: "50%", label: "Fair", color: "#ef9a65" },
        { width: "75%", label: "Good", color: "#f0c36d" },
        { width: "100%", label: "Strong", color: "#80cbc4" }
    ];

    const level = password.length === 0 ? levels[0] : levels[getPasswordScore(password)];
    fill.style.width = level.width;
    fill.style.backgroundColor = level.color;
    text.textContent = level.label;
}


/*  Validation helpers                                                  */

function setError(elementId, message) {
    const el = document.getElementById(elementId);
    if (el) {
        el.textContent = message;
    }
}

function clearErrors() {
    document.querySelectorAll(".field-error").forEach(function (element) {
        element.textContent = "";
    });
}

function lockSubmitButton(form) {
    const button = form.querySelector("button[type='submit']");
    if (button) {
        button.disabled = true;
        button.style.opacity = "0.7";
        button.style.cursor = "not-allowed";
    }
}


/*  Page setup                                                          */

document.addEventListener("DOMContentLoaded", function () {

    // 0. Open the tab requested by the server (e.g. after a password change)
    const initialTab = document.body.getAttribute("data-initial-tab");
    showTab(initialTab === "security" ? "security" : "personal");

    // 1. Show the result pop-up (success / error) if the server sent one
    const resultModalEl = document.getElementById("resultModal");
    if (resultModalEl && window.bootstrap) {
        new bootstrap.Modal(resultModalEl).show();
    }

    // 2. Phone field: allow digits only
    const phoneInput = document.getElementById("phone");
    if (phoneInput) {
        phoneInput.addEventListener("input", function () {
            phoneInput.value = phoneInput.value.replace(/[^0-9]/g, "");
        });
    }

    // 3. Profile form validation
    const profileForm = document.getElementById("profileForm");
    if (profileForm) {
        profileForm.addEventListener("submit", function (event) {
            clearErrors();
            let valid = true;

            const name = document.getElementById("full_name").value.trim();
            const email = document.getElementById("email").value.trim();
            const phone = document.getElementById("phone").value.trim();
            const address = document.getElementById("address").value.trim();

            if (name.length < 3 || name.length > 100) {
                setError("nameError", "Name must be between 3 and 100 characters.");
                valid = false;
            }

            if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                setError("emailError", "Please provide a valid email address.");
                valid = false;
            }

            if (phone.length > 0 && !/^[0-9]{10,15}$/.test(phone)) {
                setError("phoneError", "Enter a valid phone number (10 to 15 digits).");
                valid = false;
            }

            if (address.length > 255) {
                setError("addressError", "Address cannot exceed 255 characters.");
                valid = false;
            }

            if (!valid) {
                event.preventDefault();
                return;
            }

            lockSubmitButton(profileForm);
        });
    }

    // 4. Live password strength meter
    const newPasswordInput = document.getElementById("new_password");
    if (newPasswordInput) {
        newPasswordInput.addEventListener("input", updatePasswordStrength);
    }

    // 5. Password form validation
    const passwordForm = document.getElementById("passwordForm");
    if (passwordForm) {
        passwordForm.addEventListener("submit", function (event) {
            clearErrors();
            let valid = true;

            const currentPassword = document.getElementById("current_password").value;
            const newPassword = document.getElementById("new_password").value;
            const confirmPassword = document.getElementById("confirm_password").value;

            if (!currentPassword) {
                setError("currentPasswordError", "Please enter your current password.");
                valid = false;
            }

            if (newPassword.length < 8) {
                setError("newPasswordError", "New password must be at least 8 characters.");
                valid = false;
            } else if (!isStrongPassword(newPassword)) {
                setError("newPasswordError", "Use uppercase, lowercase, a number and a symbol.");
                valid = false;
            } else if (currentPassword && newPassword === currentPassword) {
                setError("newPasswordError", "New password must differ from current password.");
                valid = false;
            }

            if (newPassword !== confirmPassword) {
                setError("confirmPasswordError", "Passwords do not match.");
                valid = false;
            }

            if (!valid) {
                event.preventDefault();
                return;
            }

            lockSubmitButton(passwordForm);
        });
    }
});