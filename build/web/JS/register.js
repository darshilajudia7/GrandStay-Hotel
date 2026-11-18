let redirectCountdownInterval = null;
let toastTimer = null;

// Toggle Password Visibility
function togglePasswordVisibility(fieldId, btn) {
    const field = document.getElementById(fieldId);
    const icon = btn ? btn.querySelector("i") : null;
    if (!field || !icon)
        return;

    if (field.type === "password") {
        field.type = "text";
        icon.classList.replace("bi-eye", "bi-eye-slash");
    } else {
        field.type = "password";
        icon.classList.replace("bi-eye-slash", "bi-eye");
    }
}

// Password Strength Evaluator
function evaluatePasswordStrength(password) {
    const fill = document.getElementById("strengthMeterFill");
    const label = document.getElementById("strengthText");
    if (!fill || !label)
        return;

    let score = 0;
    if (password.length >= 8)
        score++;
    if (/[A-Z]/.test(password))
        score++;
    if (/[a-z]/.test(password))
        score++;
    if (/[0-9]/.test(password))
        score++;
    if (/[^A-Za-z0-9]/.test(password))
        score++;

    if (password.length === 0) {
        fill.style.width = "0%";
        fill.style.backgroundColor = "#232836";
        label.innerText = "None";
        label.style.color = "var(--text-dim)";
    } else if (score <= 2) {
        fill.style.width = "25%";
        fill.style.backgroundColor = "#e63946";
        label.innerText = "Weak";
        label.style.color = "#e63946";
    } else if (score === 3) {
        fill.style.width = "50%";
        fill.style.backgroundColor = "#f4a261";
        label.innerText = "Moderate";
        label.style.color = "#f4a261";
    } else if (score === 4) {
        fill.style.width = "75%";
        fill.style.backgroundColor = "#e0be77";
        label.innerText = "Strong";
        label.style.color = "#e0be77";
    } else {
        fill.style.width = "100%";
        fill.style.backgroundColor = "#2a9d8f";
        label.innerText = "Excellent";
        label.style.color = "#2a9d8f";
    }
}

// Error Modal Display (Identical Luxury Pop-up Design)
function showErrorModal(title, desc) {
    const errorModalEl = document.getElementById("registerErrorModal");
    const head = document.getElementById("registerErrorTitle");
    const body = document.getElementById("registerErrorMessage");
    if (errorModalEl && window.bootstrap) {
        if (head) head.innerText = title || "Registration Refused";
        if (body) body.innerText = desc || "Failed to save your profile.";
        const bsModal = bootstrap.Modal.getOrCreateInstance(errorModalEl);
        bsModal.show();
    } else {
        showToast(title, desc);
    }
}

// Toast Display
function showToast(title, desc) {
    const toast = document.getElementById("luxuryToast");
    const head = document.getElementById("toastHeading");
    const body = document.getElementById("toastMessage");
    if (!toast || !head || !body)
        return;

    head.innerText = title;
    body.innerText = desc;
    toast.style.display = "block";

    if (toastTimer)
        clearTimeout(toastTimer);
    toastTimer = setTimeout(hideToast, 5000);
}

// Hide Toast
function hideToast() {
    const toast = document.getElementById("luxuryToast");
    if (toast)
        toast.style.display = "none";
}

// Redirect to Login Page
function proceedToSignIn(contextPath) {
    if (redirectCountdownInterval)
        clearInterval(redirectCountdownInterval);
    const base = (contextPath && contextPath !== "undefined") ? contextPath : "";
    window.location.href = `${base}/login.jsp?registered=true`;
}

// Set or Clear Field Errors
function setFieldError(fieldId, errorId, message) {
    const field = document.getElementById(fieldId);
    const error = document.getElementById(errorId);
    if (!field || !error)
        return false;

    field.classList.remove("is-valid", "is-invalid");
    error.innerText = message;

    if (message) {
        field.classList.add("is-invalid");
        return false;
    }
    field.classList.add("is-valid");
    return true;
}

// Full Name Validator
function validateFullName() {
    const value = document.getElementById("full_name").value.trim();
    if (!value) {
        return setFieldError("full_name", "fullNameError", "Full name is required.");
    }
    if (value.length < 3) {
        return setFieldError("full_name", "fullNameError", "Name must contain at least 3 characters.");
    }
    if (!/^[A-Za-z]+(?:[ '-][A-Za-z]+)*$/.test(value)) {
        return setFieldError("full_name", "fullNameError", "Enter a valid name using letters and spaces.");
    }
    return setFieldError("full_name", "fullNameError", "");
}

// Email Validator
function validateEmail() {
    const value = document.getElementById("email").value.trim();
    const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
    if (!value) {
        return setFieldError("email", "emailError", "Email address is required.");
    }
    if (value.length > 100 || !pattern.test(value)) {
        return setFieldError("email", "emailError", "Enter a valid email address.");
    }
    return setFieldError("email", "emailError", "");
}

// Phone Validator (Required)
function validatePhone() {
    const value = document.getElementById("phone").value.trim();
    if (!value) {
        return setFieldError("phone", "phoneError", "Contact number is required.");
    }
    const pattern = /^(?:\+91[\s-]?)?[6-9][0-9]{9}$/;
    if (!pattern.test(value)) {
        return setFieldError("phone", "phoneError", "Enter a valid 10-digit Indian mobile number.");
    }
    return setFieldError("phone", "phoneError", "");
}

// Address Validator (Required)
function validateAddress() {
    const value = document.getElementById("address").value.trim();
    if (!value) {
        return setFieldError("address", "addressError", "Address is required.");
    }
    if (value.length < 5) {
        return setFieldError("address", "addressError", "Please provide a complete address (min 5 characters).");
    }
    if (value.length > 255) {
        return setFieldError("address", "addressError", "Address cannot exceed 255 characters.");
    }
    return setFieldError("address", "addressError", "");
}

// Password Validator
function validatePassword() {
    const value = document.getElementById("password").value;
    if (!value) {
        return setFieldError("password", "passwordError", "Password is required.");
    }
    if (value.length < 8) {
        return setFieldError("password", "passwordError", "Password must contain at least 8 characters.");
    }
    if (value.length > 255) {
        return setFieldError("password", "passwordError", "Password cannot exceed 255 characters.");
    }
    if (!/[A-Z]/.test(value)) {
        return setFieldError("password", "passwordError", "Include at least one uppercase letter.");
    }
    if (!/[a-z]/.test(value)) {
        return setFieldError("password", "passwordError", "Include at least one lowercase letter.");
    }
    if (!/[0-9]/.test(value)) {
        return setFieldError("password", "passwordError", "Include at least one number.");
    }
    if (!/[^A-Za-z0-9]/.test(value)) {
        return setFieldError("password", "passwordError", "Include at least one special character.");
    }
    return setFieldError("password", "passwordError", "");
}

// Confirm Password Validator
function validateConfirmPassword() {
    const password = document.getElementById("password").value;
    const confirm = document.getElementById("confirm_password").value;
    if (!confirm) {
        return setFieldError("confirm_password", "confirmPasswordError", "Please confirm your password.");
    }
    if (password !== confirm) {
        return setFieldError("confirm_password", "confirmPasswordError", "Passwords do not match.");
    }
    return setFieldError("confirm_password", "confirmPasswordError", "");
}

// Aggregate Form Validation
function validateRegistrationForm() {
    const results = [
        validateFullName(),
        validateEmail(),
        validatePhone(),
        validateAddress(),
        validatePassword(),
        validateConfirmPassword()
    ];

    const firstInvalid = document.querySelector(".is-invalid");
    if (firstInvalid)
        firstInvalid.focus();

    return results.every(Boolean);
}

// Attach Live Validation Listeners
document.addEventListener("DOMContentLoaded", function () {
    const fields = [
        ["full_name", validateFullName],
        ["email", validateEmail],
        ["phone", validatePhone],
        ["address", validateAddress],
        ["password", validatePassword],
        ["confirm_password", validateConfirmPassword]
    ];

    fields.forEach(([id, validator]) => {
        const field = document.getElementById(id);
        if (field) {
            field.addEventListener("blur", validator);
            field.addEventListener("input", function () {
                if (this.classList.contains("is-invalid")) {
                    validator();
                }
            });
    }
    });

    const password = document.getElementById("password");
    const confirmPassword = document.getElementById("confirm_password");

    password.addEventListener("input", function () {
        evaluatePasswordStrength(this.value);
        if (this.classList.contains("is-invalid") || this.classList.contains("is-valid")) {
            validatePassword();
        }
        if (confirmPassword.value) {
            validateConfirmPassword();
        }
    });

    confirmPassword.addEventListener("input", function () {
        if (this.classList.contains("is-invalid") || this.classList.contains("is-valid")) {
            validateConfirmPassword();
        }
    });
});

// Form Submission Handler
async function handleFormSubmission(event, contextPath) {
    event.preventDefault();

    if (!validateRegistrationForm()) {
        showToast("Validation Required", "Please resolve highlighted field errors before proceeding.");
        return;
    }

    const submitBtn = document.getElementById("submitBtn");
    const btnText = document.getElementById("btnText");
    if (submitBtn.disabled)
        return;

    submitBtn.disabled = true;
    const originalBtnText = btnText.innerHTML;
    btnText.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Securing Profile...';

    const payload = new URLSearchParams();
    payload.append("full_name", document.getElementById("full_name").value.trim());
    payload.append("email", document.getElementById("email").value.trim());
    payload.append("phone", document.getElementById("phone").value.trim());
    payload.append("address", document.getElementById("address").value.trim());
    payload.append("password", document.getElementById("password").value);
    payload.append("role", "Customer");

    const base = (contextPath && contextPath !== "undefined") ? contextPath : "";

    try {
        const response = await fetch(`${base}/api/register`, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
            },
            body: payload.toString()
        });

        const data = await response.json();

        if (response.ok && data.status === "success") {
            document.getElementById("successGuestName").innerText =
                    `Welcome, ${document.getElementById("full_name").value.trim()}`;

            const modalElement = document.getElementById("successModal");
            const successModal = new bootstrap.Modal(modalElement);
            successModal.show();

            let secondsLeft = 3;
            const counterSpan = document.getElementById("redirectSeconds");
            if (counterSpan)
                counterSpan.innerText = secondsLeft;

            clearInterval(redirectCountdownInterval);
            redirectCountdownInterval = setInterval(function () {
                secondsLeft--;
                if (counterSpan)
                    counterSpan.innerText = secondsLeft;

                if (secondsLeft <= 0) {
                    clearInterval(redirectCountdownInterval);
                    proceedToSignIn(base);
                }
            }, 1000);

        } else {
            if (data.field && data.message) {
                if (data.field === "email")
                    setFieldError("email", "emailError", data.message);
                if (data.field === "phone")
                    setFieldError("phone", "phoneError", data.message);
            }
            showErrorModal("Registration Refused", data.message || "Failed to save your profile.");
            submitBtn.disabled = false;
            btnText.innerHTML = originalBtnText;
        }

    } catch (error) {
        console.error("Submission failed:", error);
        showErrorModal("Connection Interrupted", "Unable to establish contact with the registry server.");
        submitBtn.disabled = false;
        btnText.innerHTML = originalBtnText;
    }
}