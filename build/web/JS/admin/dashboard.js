// GrandStay Admin Dashboard Script
document.addEventListener('DOMContentLoaded', function () {
    // 1. Recent Bookings Table Real-Time Filter
    const searchInput = document.getElementById('bookingSearch');
    const tableBody = document.getElementById('recentBookingsBody');
    if (searchInput && tableBody) {
        searchInput.addEventListener('input', function () {
            const query = this.value.toLowerCase().trim();
            const rows = tableBody.querySelectorAll('tr');
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(query) ? '' : 'none';
            });
        });
    }

    // 4. Modal inspection for Booking details
    const modal = document.getElementById('bookingModal');
    const modalClose = document.getElementById('closeBookingModal');
    if (modalClose && modal) {
        modalClose.addEventListener('click', () => modal.classList.remove('open'));
        modal.addEventListener('click', (e) => {
            if (e.target === modal) modal.classList.remove('open');
        });
    }

    window.openBookingDetails = function (btn) {
        if (!modal) return;
        const refEl = document.getElementById('mbRef');
        if (refEl) refEl.textContent = btn.dataset.ref || '—';

        const guestEl = document.getElementById('mbGuest');
        if (guestEl) guestEl.textContent = btn.dataset.guest || '—';

        const emailEl = document.getElementById('mbEmail');
        if (emailEl) emailEl.textContent = btn.dataset.email || '—';

        const phoneEl = document.getElementById('mbPhone');
        if (phoneEl) phoneEl.textContent = btn.dataset.phone || '—';

        const roomEl = document.getElementById('mbRoom');
        if (roomEl) roomEl.textContent = (btn.dataset.room || '—') + ' (' + (btn.dataset.roomtype || 'Standard') + ')';

        const datesEl = document.getElementById('mbDates');
        if (datesEl) datesEl.textContent = (btn.dataset.in || '—') + ' to ' + (btn.dataset.out || '—') + ' (' + (btn.dataset.nights || '1') + ' nights)';

        const guestsEl = document.getElementById('mbGuests');
        if (guestsEl) guestsEl.textContent = btn.dataset.count || '1';

        const totalEl = document.getElementById('mbTotal');
        if (totalEl) {
            const rawPrice = parseFloat(btn.dataset.price || '0');
            totalEl.textContent = '₹' + rawPrice.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        }

        const statusEl = document.getElementById('mbStatus');
        if (statusEl) statusEl.textContent = btn.dataset.status || 'CONFIRMED';
        
        const reasonRow = document.getElementById('mbReasonRow');
        if (reasonRow) {
            const reason = btn.dataset.reason;
            if (reason && reason !== 'null' && reason.trim() !== '') {
                const reasonEl = document.getElementById('mbReason');
                if (reasonEl) reasonEl.textContent = reason;
                reasonRow.style.display = '';
            } else {
                reasonRow.style.display = 'none';
            }
        }

        modal.classList.add('open');
    };
});

