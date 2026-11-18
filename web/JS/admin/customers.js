// GrandStay Admin Customers Management JavaScript
document.addEventListener('DOMContentLoaded', function () {
    const searchInput = document.getElementById('customerSearch');
    const tableBody = document.getElementById('customerTableBody');
    const filterButtons = document.querySelectorAll('.filter-btn');
    const profileModal = document.getElementById('customerProfileModal');
    const modalCloseBtn = document.getElementById('closeCustModal');
    const blockModal = document.getElementById('blockConfirmModal');

    let currentFilter = 'all';

    // 1. Client-Side Real-Time Filter & Search
    function applyFiltering() {
        if (!tableBody) return;
        const query = (searchInput ? searchInput.value : '').toLowerCase().trim();
        const rows = tableBody.querySelectorAll('tr[data-id]');

        let visibleCount = 0;

        rows.forEach(row => {
            const name = (row.dataset.name || '').toLowerCase();
            const email = (row.dataset.email || '').toLowerCase();
            const phone = (row.dataset.phone || '').toLowerCase();
            const status = (row.dataset.status || '').toLowerCase();
            const bookings = parseInt(row.dataset.bookings || '0', 10);

            // Search query match
            const matchesQuery = !query || name.includes(query) || email.includes(query) || phone.includes(query);

            // Tab filter match
            let matchesFilter = true;
            if (currentFilter === 'active') {
                matchesFilter = (status === 'active');
            } else if (currentFilter === 'blocked') {
                matchesFilter = (status === 'blocked');
            } else if (currentFilter === 'with-bookings') {
                matchesFilter = (bookings > 0);
            }

            if (matchesQuery && matchesFilter) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });

        const noMatchRow = document.getElementById('noMatchRow');
        if (noMatchRow) {
            noMatchRow.style.display = (visibleCount === 0 && rows.length > 0) ? '' : 'none';
        }
    }

    if (searchInput) {
        searchInput.addEventListener('input', applyFiltering);
    }

    filterButtons.forEach(btn => {
        btn.addEventListener('click', function () {
            filterButtons.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            currentFilter = this.dataset.filter || 'all';
            applyFiltering();
        });
    });

    // 2. Profile & Booking History Modal Close Handlers
    if (modalCloseBtn && profileModal) {
        modalCloseBtn.addEventListener('click', () => profileModal.classList.remove('open'));
        profileModal.addEventListener('click', (e) => {
            if (e.target === profileModal) profileModal.classList.remove('open');
        });
    }

    if (blockModal) {
        blockModal.addEventListener('click', (e) => {
            if (e.target === blockModal) blockModal.classList.remove('open');
        });
    }

    // Close modals on Escape key
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            if (profileModal && profileModal.classList.contains('open')) {
                profileModal.classList.remove('open');
            }
            if (blockModal && blockModal.classList.contains('open')) {
                blockModal.classList.remove('open');
            }
        }
    });

    // 3. Open Customer Profile & Detailed Form Modal
    window.openCustomerProfile = function (btn) {
        if (!profileModal) return;

        const customerId = btn.dataset.id;
        const fullName = btn.dataset.name || 'Guest User';
        const email = btn.dataset.email || '—';
        const phone = btn.dataset.phone || '—';
        const address = btn.dataset.address || 'Not Provided';
        const role = btn.dataset.role || 'Customer';
        const status = btn.dataset.status || 'Active';
        const blockReason = btn.dataset.blockReason || '';
        const bookingsCount = btn.dataset.bookings || '0';
        const totalSpent = btn.dataset.totalSpent || '0';
        const registered = btn.dataset.joined || '—';

        // Populate header and monogram
        const cpAvatar = document.getElementById('cpAvatar');
        if (cpAvatar) cpAvatar.textContent = fullName.charAt(0).toUpperCase();

        const cpName = document.getElementById('cpName');
        if (cpName) cpName.textContent = fullName;

        const cpJoined = document.getElementById('cpJoined');
        if (cpJoined) cpJoined.textContent = registered;

        const cpStatus = document.getElementById('cpStatus');
        if (cpStatus) {
            cpStatus.textContent = status;
            cpStatus.className = 'status-pill ' + status.toLowerCase();
        }

        // Populate structured user data form
        const cpId = document.getElementById('cpId');
        if (cpId) cpId.textContent = 'User #' + customerId;

        const cpRole = document.getElementById('cpRole');
        if (cpRole) cpRole.textContent = role;

        const cpEmail = document.getElementById('cpEmail');
        if (cpEmail) cpEmail.textContent = email;

        const cpPhone = document.getElementById('cpPhone');
        if (cpPhone) cpPhone.textContent = phone;

        const cpAddress = document.getElementById('cpAddress');
        if (cpAddress) cpAddress.textContent = address;

        const cpBookingsStat = document.getElementById('cpBookingsStat');
        if (cpBookingsStat) cpBookingsStat.textContent = bookingsCount + ' Booking(s)';

        const cpBookingsCount = document.getElementById('cpBookingsCount');
        if (cpBookingsCount) cpBookingsCount.textContent = bookingsCount + ' Bookings';

        const cpTotalSpent = document.getElementById('cpTotalSpent');
        if (cpTotalSpent) {
            const spentNum = parseFloat(totalSpent) || 0;
            cpTotalSpent.textContent = '₹' + spentNum.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        }

        // Display Block Reason row if account is restricted
        const blockRow = document.getElementById('cpBlockReasonRow');
        const cpBlockReason = document.getElementById('cpBlockReason');
        if (blockRow && cpBlockReason) {
            if (status.toLowerCase() === 'blocked') {
                blockRow.style.display = '';
                cpBlockReason.textContent = blockReason || 'Administrative restriction.';
            } else {
                blockRow.style.display = 'none';
            }
        }

        const historyBody = document.getElementById('cpBookingsHistory');
        if (historyBody) {
            historyBody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:15px; color:#9ba3b2;"><i class="bi bi-hourglass-split"></i> Loading reservation history...</td></tr>';
        }

        profileModal.classList.add('open');

        // Fetch dynamic booking history if customerId is valid
        if (customerId) {
            const contextPath = document.body.dataset.context !== undefined ? document.body.dataset.context : '';
            const fetchUrl = contextPath + '/admin/customers?customerId=' + encodeURIComponent(customerId);

            fetch(fetchUrl)
                .then(res => res.json())
                .then(data => {
                    if (!historyBody) return;
                    if (data && data.blockReason && blockRow && cpBlockReason && status.toLowerCase() === 'blocked') {
                        cpBlockReason.textContent = data.blockReason;
                    }
                    if (data && data.bookings && data.bookings.length > 0) {
                        let html = '';
                        data.bookings.forEach(b => {
                            const isConfirmed = (b.bookingStatus === 'CONFIRMED');
                            const priceFormatted = parseFloat(b.totalPrice || 0).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
                            html += '<tr>' +
                                '<td><span class="badge-ref">' + (b.bookingReference || '—') + '</span></td>' +
                                '<td><div style="font-weight:600; color:#fff;">Room ' + (b.roomNumber || '') + '</div><small style="color:#c5a059;">' + (b.roomTitle || '') + '</small></td>' +
                                '<td>' + (b.checkIn || '—') + ' &rarr; ' + (b.checkOut || '—') + '</td>' +
                                '<td><b>₹' + priceFormatted + '</b></td>' +
                                '<td><span class="status-badge ' + (isConfirmed ? 'confirmed' : 'cancelled') + '">' + (b.bookingStatus || 'CONFIRMED') + '</span></td>' +
                                '</tr>';
                        });
                        historyBody.innerHTML = html;
                    } else {
                        historyBody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:20px; color:#9ba3b2;"><i class="bi bi-inbox" style="font-size:20px; display:block; margin-bottom:5px;"></i>No bookings found for this customer.</td></tr>';
                    }
                })
                .catch(() => {
                    if (historyBody) {
                        historyBody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:15px; color:#9ba3b2;">No recent bookings recorded.</td></tr>';
                    }
                });
        }
    };

    // 4. Modal action: Open Block Reason modal
    window.openBlockModal = function (customerId, fullName) {
        if (!blockModal) return;
        const idInput = document.getElementById('blockCustomerId');
        const nameEl = document.getElementById('blockGuestName');
        const reasonInput = document.getElementById('blockReasonInput');

        if (idInput) idInput.value = customerId;
        if (nameEl) nameEl.textContent = fullName + ' (User #' + customerId + ')';
        if (reasonInput) {
            reasonInput.value = '';
            setTimeout(() => reasonInput.focus(), 150);
        }

        blockModal.classList.add('open');
    };

    // 5. Confirm Activate / Unblock Account
    window.confirmActivateUser = function (customerId, fullName) {
        const msg = 'Are you sure you want to ACTIVATE the account for guest "' + fullName + '"?\n\nThe user will regain full access to sign in to the portal.';
        if (confirm(msg)) {
            const form = document.getElementById('activateActionForm');
            const idInput = document.getElementById('activateCustomerId');
            if (form && idInput) {
                idInput.value = customerId;
                form.submit();
            }
        }
    };
});
