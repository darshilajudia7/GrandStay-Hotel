document.addEventListener("DOMContentLoaded", () => {
    // 1. Initialize modal dates (Check-in = +14 days, Check-out = +17 days)
    const now = new Date();
    const inDate = new Date();
    inDate.setDate(now.getDate() + 14);
    const outDate = new Date();
    outDate.setDate(now.getDate() + 17);

    const formatDate = (d) => d.toISOString().split("T")[0];

    const modalIn = document.getElementById("modalCheckIn");
    const modalOut = document.getElementById("modalCheckOut");

    if (modalIn && modalOut) {
        modalIn.value = formatDate(inDate);
        modalOut.value = formatDate(outDate);
    }

    updateBookingCost();

    // 2. Active Section ScrollSpy
    const navLinks = document.querySelectorAll("#navbarGrandStayMenu .nav-link");
    const sectionIds = ["hero", "about", "experiences", "guestReviews", "contact"];
    const sections = sectionIds
            .map((id) => document.getElementById(id))
            .filter(Boolean);

    function highlightActiveSection() {
        const scrollPosition = window.scrollY + 180;
        let activeSection = "hero";

        sections.forEach((section) => {
            const sectionTop = section.getBoundingClientRect().top + window.scrollY;
            if (sectionTop <= scrollPosition) {
                activeSection = section.id;
            }
        });

        if (window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 5) {
            activeSection = "contact";
        }

        navLinks.forEach((link) => {
            link.classList.toggle(
                    "active",
                    link.getAttribute("href") === "#" + activeSection
                    );
        });
    }

    window.addEventListener("scroll", highlightActiveSection, {passive: true});
    window.addEventListener("resize", highlightActiveSection);
    highlightActiveSection();
});

// Dynamic Reservation Cost Calculation
function updateBookingCost() {
    const expSelect = document.getElementById("modalSuiteSelect");
    const checkInInput = document.getElementById("modalCheckIn");
    const checkOutInput = document.getElementById("modalCheckOut");
    const nightsLabel = document.getElementById("stayNightsCount");
    const priceLabel = document.getElementById("modalCalculatedPrice");

    if (!expSelect || !checkInInput || !checkOutInput || !nightsLabel || !priceLabel) {
        return;
    }

    const selectedOption = expSelect.options[expSelect.selectedIndex];
    const rate = parseInt(selectedOption.getAttribute("data-price") || "350", 10);

    const d1 = new Date(checkInInput.value);
    const d2 = new Date(checkOutInput.value);

    const diffTime = d2.getTime() - d1.getTime();
    let diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    if (isNaN(diffDays) || diffDays <= 0) {
        diffDays = 1;
    }

    nightsLabel.innerText = `${diffDays} Day${diffDays > 1 ? "s" : ""}`;
    const total = rate * diffDays;
    priceLabel.innerText = `$${total.toLocaleString()}`;
}

// Modal Form Submission
function handleBookingSubmission(event) {
    event.preventDefault();
    const modalElement = document.getElementById("reservationModal");
    const bsModal = bootstrap.Modal.getInstance(modalElement);
    if (bsModal) {
        bsModal.hide();
    }

    showToast(
            "Reservation Confirmed",
            "Your inquiry has been logged. Our Chief Concierge will reach out within 15 minutes."
            );
}

// Newsletter Subscription
function handleNewsletterSubmit(event) {
    event.preventDefault();
    const email = document.getElementById("newsletterEmail");
    showToast(
            "Welcome to GrandStay Privé",
            `Discreet invitation dispatched to ${email.value}.`
            );
    email.value = "";
}

// Toast Notifications
let toastTimeout;
function showToast(heading, message) {
    const toastEl = document.getElementById("customToast");
    const headingEl = document.getElementById("toastHeading");
    const msgEl = document.getElementById("toastMessage");

    headingEl.innerText = heading;
    msgEl.innerText = message;
    toastEl.style.display = "block";

    if (toastTimeout)
        clearTimeout(toastTimeout);
    toastTimeout = setTimeout(hideToast, 5000);
}

function hideToast() {
    const toastEl = document.getElementById("customToast");
    if (toastEl)
        toastEl.style.display = "none";
}