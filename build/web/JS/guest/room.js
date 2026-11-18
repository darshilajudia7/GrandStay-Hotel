// Luxury Hotel Interactive Filtering with Dropdowns, Sorting, Multi-Image Carousel & Form Validation
document.addEventListener("DOMContentLoaded", () => {
    // Keep the correct navigation item active
    const currentPath = window.location.pathname;
    document.querySelectorAll('.site-navbar .nav-link').forEach(link => {
        const href = link.getAttribute('href');
        if (href && (currentPath.endsWith(href) || (href.includes('room') && currentPath.includes('room')))) {
            link.classList.add('active');
            link.setAttribute('aria-current', 'page');
        }
    });

    const roomGrid = document.getElementById('roomGrid');
    const roomCards = roomGrid ? [...roomGrid.querySelectorAll('.room-card')] : [];
    const searchInput = document.getElementById('roomSearchInput');
    const roomTypeSelect = document.getElementById('roomTypeSelect');
    const bedCountSelect = document.getElementById('bedCount');
    const amenitySelect = document.getElementById('amenitySelect');
    const sortRooms = document.getElementById('sortRooms');
    const resultCount = document.getElementById('resultCount');
    const emptyState = document.getElementById('emptyState');
    const resetFiltersBtn = document.getElementById('resetFilters');
    const emptyResetBtn = document.getElementById('emptyReset');

    // Filter Change Listeners for Dropdowns & Search
    if (searchInput) {
        searchInput.addEventListener('input', applyRoomFilters);
    }
    if (roomTypeSelect) {
        roomTypeSelect.addEventListener('change', applyRoomFilters);
    }
    if (bedCountSelect) {
        bedCountSelect.addEventListener('change', applyRoomFilters);
    }
    if (amenitySelect) {
        amenitySelect.addEventListener('change', applyRoomFilters);
    }
    if (sortRooms) {
        sortRooms.addEventListener('change', applyRoomFilters);
    }

    // Master Filter Engine with Dropdowns
    function applyRoomFilters() {
        if (!roomCards.length) return;

        const query = searchInput ? searchInput.value.trim().toLowerCase() : '';
        const selectedType = roomTypeSelect ? roomTypeSelect.value.trim().toLowerCase() : 'all';
        const selectedBeds = bedCountSelect ? bedCountSelect.value.trim().toLowerCase() : 'any';
        const selectedAmenity = amenitySelect ? amenitySelect.value.trim().toLowerCase() : 'all';

        let visibleCount = 0;
        roomCards.forEach(card => {
            // 1. Text Search Match
            const title = (card.querySelector('.room-title-row h3')?.textContent || '').toLowerCase();
            const desc = (card.querySelector('.room-description')?.textContent || '').toLowerCase();
            const roomNo = (card.dataset.roomno || card.textContent || '').toLowerCase();
            const type = (card.dataset.type || '').toLowerCase();
            const searchMatch = !query || title.includes(query) || desc.includes(query) || roomNo.includes(query) || type.includes(query);

            // 2. Category Dropdown Match
            const categoryMatch = (selectedType === 'all') || (type === selectedType);

            // 3. Bed Configuration Dropdown Match
            const cardBeds = Number(card.dataset.beds) || 1;
            let bedMatch = (selectedBeds === 'any');
            if (selectedBeds === '1') bedMatch = (cardBeds === 1);
            else if (selectedBeds === '2') bedMatch = (cardBeds === 2);
            else if (selectedBeds === '3') bedMatch = (cardBeds >= 3);

            // 4. Amenity Dropdown Match
            const cardAmenities = (card.dataset.amenities || '').toLowerCase().split(/\s+/).filter(Boolean);
            const amenityMatch = (selectedAmenity === 'all') || cardAmenities.includes(selectedAmenity);

            const isVisible = searchMatch && categoryMatch && bedMatch && amenityMatch;
            card.hidden = !isVisible;
            if (isVisible) visibleCount++;
        });

        // 5. Sorting
        if (sortRooms && roomGrid) {
            const sortVal = sortRooms.value;
            const sortedCards = roomCards.slice().sort((a, b) => {
                const priceA = Number(a.dataset.price) || 0;
                const priceB = Number(b.dataset.price) || 0;

                if (sortVal === 'low-high') return priceA - priceB;
                if (sortVal === 'high-low') return priceB - priceA;
                return roomCards.indexOf(a) - roomCards.indexOf(b);
            });
            sortedCards.forEach(card => roomGrid.appendChild(card));
        }

        if (resultCount) {
            resultCount.textContent = visibleCount;
        }
        if (emptyState) {
            emptyState.hidden = visibleCount !== 0;
        }
    }

    function resetAllFilters() {
        if (searchInput) searchInput.value = '';
        if (roomTypeSelect) roomTypeSelect.value = 'all';
        if (bedCountSelect) bedCountSelect.value = 'any';
        if (amenitySelect) amenitySelect.value = 'all';
        if (sortRooms) sortRooms.value = 'recommended';
        applyRoomFilters();
    }

    if (resetFiltersBtn) resetFiltersBtn.addEventListener('click', resetAllFilters);
    if (emptyResetBtn) emptyResetBtn.addEventListener('click', resetAllFilters);

    // Multi-Image Carousel
    const guestCtx = window.CONTEXT_PATH || (window.location.pathname.split('/')[1] ? '/' + window.location.pathname.split('/')[1] : '');
    function resolveGuestImageUrl(path) {
        if (!path) return `${guestCtx}/Image/default_room.jpg`;
        path = String(path).trim().replace(/\\/g, '/');
        if (path.startsWith('http://') || path.startsWith('https://')) return path;
        if (path.startsWith('/')) return `${guestCtx}${path}`;
        return `${guestCtx}/${path}`;
    }

    roomCards.forEach((card) => {
        let cardImages = [];
        const dataImgs = card.dataset.images;
        if (dataImgs && dataImgs.trim().length > 0) {
            cardImages = dataImgs.split(',').map(s => s.trim().replace(/\\/g, '/')).filter(Boolean);
        }

        const imgElement = card.querySelector('.room-main-image');
        const nextBtn = card.querySelector('.gallery-next');
        const dots = [...card.querySelectorAll('.image-dots span')];

        if (cardImages.length <= 1) {
            if (nextBtn) nextBtn.style.display = 'none';
            const dotsContainer = card.querySelector('.image-dots');
            if (dotsContainer) dotsContainer.style.display = 'none';
            return;
        }

        let imageIndex = 0;

        function showImage(idx) {
            if (!imgElement || !cardImages.length) return;
            imageIndex = (idx + cardImages.length) % cardImages.length;
            
            let targetSrc = cardImages[imageIndex];
            imgElement.src = resolveGuestImageUrl(targetSrc);
            imgElement.onerror = function() {
                this.onerror = null;
                this.src = `${guestCtx}/Image/default_room.jpg`;
            };
            dots.forEach((dot, dIdx) => dot.classList.toggle('active', dIdx === imageIndex));
        }

        if (nextBtn) {
            nextBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                showImage(imageIndex + 1);
            });
        }

        dots.forEach((dot, dIdx) => {
            dot.addEventListener('click', (e) => {
                e.stopPropagation();
                showImage(dIdx);
            });
        });
    });

    applyRoomFilters();
});
