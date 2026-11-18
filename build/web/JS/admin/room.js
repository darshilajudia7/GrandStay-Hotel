/*  CONFIGURATION & MASTER AMENITIES  */
const AVAILABLE_AMENITIES = [
    {id: 'High-speed Wi-Fi', label: 'High-speed Wi-Fi'},
    {id: 'Climate Control', label: 'Climate Control'},
    {id: 'Mini Bar', label: 'Mini Bar'},
    {id: 'Smart TV', label: 'Smart TV'},
    {id: 'Soaking Tub', label: 'Soaking Tub'},
    {id: 'Private Balcony', label: 'Private Balcony'},
    {id: 'Breakfast Included', label: 'Breakfast Included'},
    {id: 'Executive Desk', label: 'Executive Desk'}
];

const LEGACY_AMENITY_MAP = {
    'wifi': 'High-speed Wi-Fi',
    'ac': 'Climate Control',
    'bar': 'Mini Bar',
    'tv': 'Smart TV',
    'tub': 'Soaking Tub',
    'balcony': 'Private Balcony',
    'breakfast': 'Breakfast Included',
    'workspace': 'Executive Desk'
};

const $ = s => document.querySelector(s);
const money = n => '₹' + Number(n).toLocaleString('en-IN');
const esc = s => String(s || '').replace(/[&<>"']/g, c => ({'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c]));
const ctx = window.CONTEXT_PATH || '';

function resolveImageUrl(path) {
    if (!path) return `${ctx}/Image/default_room.jpg`;
    path = String(path).trim().replace(/\\/g, '/');
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return `${ctx}${path}`;
    return `${ctx}/${path}`;
}

let toastTimer;
function toast(m) {
    const t = $('#toast');
    if (!t)
        return;
    t.textContent = m;
    t.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => t.classList.remove('show'), 3000);
}

if (window.SERVER_MESSAGE) {
    toast(window.SERVER_MESSAGE);
}

/*  RENDER AMENITIES CHECKBOXES (WITHOUT LOGOS/ICONS/SQUARES)  */
function syncAmenityPillStates() {
    if (!amenityBox) return;
    amenityBox.querySelectorAll('.spec-check').forEach(lbl => {
        const inp = lbl.querySelector('input');
        if (inp) {
            lbl.classList.toggle('selected', inp.checked);
        }
    });
}

function createAmenityCheckbox(id, label, checked = false) {
    return `
        <label class="spec-check ${checked ? 'selected' : ''}">
            <input type="checkbox" name="amenities" value="${esc(id)}" ${checked ? 'checked' : ''}>
            <span>${esc(label)}</span>
        </label>
    `;
}

const amenityBox = $('#amenityOptions');
if (amenityBox) {
    amenityBox.innerHTML = AVAILABLE_AMENITIES.map(a => createAmenityCheckbox(a.id, a.label)).join('');
    amenityBox.addEventListener('change', e => {
        if (e.target && e.target.name === 'amenities') {
            const lbl = e.target.closest('.spec-check');
            if (lbl) {
                lbl.classList.toggle('selected', e.target.checked);
            }
        }
    });
}

/*  ADD CUSTOM AMENITY WITHOUT ANY LOGO  */
const customAmenityInput = $('#customAmenityInput');
const addCustomAmenityBtn = $('#addCustomAmenityBtn');

function handleAddCustomAmenity() {
    if (!customAmenityInput || !amenityBox) return;
    const name = customAmenityInput.value.trim();
    if (!name) return;

    // Check if an option with this value or text already exists
    const existing = Array.from(amenityBox.querySelectorAll('input[name="amenities"]'))
        .find(input => input.value.toLowerCase() === name.toLowerCase());

    if (existing) {
        existing.checked = true;
        syncAmenityPillStates();
        toast(`Amenity "${name}" is already included and checked.`);
    } else {
        const temp = document.createElement('div');
        temp.innerHTML = createAmenityCheckbox(name, name, true);
        if (temp.firstElementChild) {
            amenityBox.appendChild(temp.firstElementChild);
            syncAmenityPillStates();
            toast(`Added amenity: "${name}"`);
        }
    }
    customAmenityInput.value = '';
}

if (addCustomAmenityBtn) {
    addCustomAmenityBtn.addEventListener('click', handleAddCustomAmenity);
}
if (customAmenityInput) {
    customAmenityInput.addEventListener('keydown', e => {
        if (e.key === 'Enter') {
            e.preventDefault();
            handleAddCustomAmenity();
        }
    });
}

/*  LIVE IMAGE PREVIEWS  */
const photoInput = $('#roomPhotos');
const newImagePreviews = $('#newImagePreviews');

if (photoInput && newImagePreviews) {
    photoInput.addEventListener('change', e => {
        newImagePreviews.innerHTML = '';
        const files = Array.from(e.target.files);
        files.forEach(file => {
            if (file.type.startsWith('image/')) {
                const reader = new FileReader();
                reader.onload = evt => {
                    const img = document.createElement('img');
                    img.src = evt.target.result;
                    img.className = 'preview-thumb';
                    newImagePreviews.appendChild(img);
                };
                reader.readAsDataURL(file);
            }
        });
    });
}

/*  CLIENT-SIDE TABLE FILTERING  */
function filterTable() {
    const q = ($('#q').value || '').trim().toLowerCase();
    const t = $('#fType').value;
    const s = $('#fStatus').value;
    const rows = document.querySelectorAll('#rows tr[data-id]');
    let visibleCount = 0;

    rows.forEach(tr => {
        const num = (tr.dataset.number || '').toLowerCase();
        const title = (tr.dataset.title || '').toLowerCase();
        const bed = (tr.dataset.bed || '').toLowerCase();
        const typeId = tr.dataset.typeId;
        const status = tr.dataset.status;

        const matchesQ = !q || num.includes(q) || title.includes(q) || bed.includes(q);
        const matchesT = !t || typeId === t;
        const matchesS = !s || (status && status.toLowerCase() === s.toLowerCase());

        if (matchesQ && matchesT && matchesS) {
            tr.style.display = '';
            visibleCount++;
        } else {
            tr.style.display = 'none';
        }
    });

    const emptyBox = $('#empty');
    if (emptyBox)
        emptyBox.hidden = visibleCount > 0;

    const countBox = $('#count');
    if (countBox)
        countBox.textContent = `${visibleCount} of ${rows.length} rooms`;
}

['q', 'fType', 'fStatus'].forEach(id => {
    const el = $('#' + id);
    if (el) {
        el.addEventListener('input', filterTable);
        el.addEventListener('change', filterTable);
    }
});

const fStatusEl = $('#fStatus');
if (fStatusEl) {
    fStatusEl.addEventListener('change', () => {
        const val = fStatusEl.value || '';
        document.querySelectorAll('#summary .sum').forEach(b => {
            b.classList.toggle('on', (b.dataset.s || '') === val);
        });
    });
}

const resetBtn = $('#reset');
if (resetBtn) {
    resetBtn.onclick = () => {
        $('#q').value = '';
        $('#fType').value = '';
        $('#fStatus').value = '';
        document.querySelectorAll('#summary .sum').forEach(b => b.classList.remove('on'));
        const allBtn = document.querySelector('#summary .sum[data-s=""]');
        if (allBtn)
            allBtn.classList.add('on');
        filterTable();
    };
}

const summaryBox = $('#summary');
if (summaryBox) {
    summaryBox.addEventListener('click', e => {
        const btn = e.target.closest('[data-s]');
        if (btn) {
            document.querySelectorAll('#summary .sum').forEach(b => b.classList.remove('on'));
            btn.classList.add('on');
            if (fStatusEl)
                fStatusEl.value = btn.dataset.s || '';
            filterTable();
        }
    });
}

/*  MODAL CONTROLS  */
const dlg = $('#editDlg'), form = $('#form'), delDlg = $('#delDlg'), viewDlg = $('#viewDlg');
let viewingRow = null;

document.querySelectorAll('[data-close]').forEach(b => {
    b.onclick = () => {
        const d = b.closest('dialog');
        if (d)
            d.close();
    };
});

[dlg, delDlg, viewDlg].forEach(d => {
    if (d) {
        d.addEventListener('mousedown', e => {
            if (e.target === d)
                d.close();
        });
    }
});

function openEditModal(tr = null) {
    if (!form || !dlg)
        return;
    form.reset();
    document.querySelectorAll('#amenityOptions input').forEach(c => c.checked = false);
    syncAmenityPillStates();
    if (newImagePreviews)
        newImagePreviews.innerHTML = '';

    const existingSection = $('#existingImageSection');
    const existingPreviews = $('#existingImagePreviews');

    if (tr) {
        $('#formAction').value = 'update';
        $('#editRoomId').value = tr.dataset.id;
        $('#inRoomNumber').value = tr.dataset.number;
        $('#fTypeForm').value = tr.dataset.typeId;
        $('#inTitle').value = tr.dataset.title;
        $('#inDesc').value = tr.dataset.desc;
        $('#inPrice').value = tr.dataset.price;
        $('#inCapacity').value = tr.dataset.capacity;
        $('#inArea').value = tr.dataset.area;
        $('#inBed').value = tr.dataset.bed;
        $('#inStatus').value = tr.dataset.status;

        const amenities = (tr.dataset.amenities || '').split(',').map(s => s.trim()).filter(Boolean);
        amenities.forEach(rawA => {
            const a = LEGACY_AMENITY_MAP[rawA.toLowerCase()] || rawA;
            let el = amenityBox ? Array.from(amenityBox.querySelectorAll('input[name="amenities"]')).find(input => input.value.toLowerCase() === a.toLowerCase()) : null;
            if (!el && amenityBox) {
                const temp = document.createElement('div');
                temp.innerHTML = createAmenityCheckbox(a, a, true);
                if (temp.firstElementChild) {
                    amenityBox.appendChild(temp.firstElementChild);
                }
            } else if (el) {
                el.checked = true;
            }
        });
        syncAmenityPillStates();

        // Show existing photos
        const images = (tr.dataset.images || '').split(',').map(s => s.trim()).filter(Boolean);
        if (images.length > 0 && existingSection && existingPreviews) {
            existingSection.hidden = false;
            existingPreviews.innerHTML = images.map(img => `<img src="${resolveImageUrl(img)}" class="preview-thumb" onerror="this.onerror=null;this.src='${ctx}/Image/default_room.jpg';">`).join('');
        } else if (existingSection) {
            existingSection.hidden = true;
        }

        $('#dlgTitle').textContent = `Edit Room: ${tr.dataset.number}`;
        $('#dlgSub').textContent = `Modifying ${tr.dataset.title}`;
        $('#saveBtn').textContent = 'Save Changes';
    } else {
        $('#formAction').value = 'create';
        $('#editRoomId').value = '';
        $('#inCapacity').value = '2';
        $('#inStatus').value = 'Available';
        $('#fTypeForm').selectedIndex = 0;
        if (existingSection)
            existingSection.hidden = true;
        $('#dlgTitle').textContent = 'Add Room';
        $('#dlgSub').textContent = 'Provide suite specifications, amenities, and photos.';
        $('#saveBtn').textContent = 'Save Room';
    }
    dlg.showModal();
}

function openViewModal(tr) {
    if (!viewDlg)
        return;
    viewingRow = tr;

    $('#vTitle').textContent = `${tr.dataset.number} – ${tr.dataset.title}`;
    $('#vDesc').textContent = tr.dataset.desc || '';
    $('#vPrice').textContent = money(tr.dataset.price);
    $('#vCapacity').textContent = `${tr.dataset.capacity} Guests`;
    $('#vArea').textContent = `${tr.dataset.area} sq.ft.`;
    $('#vBed').textContent = tr.dataset.bed;
    $('#vCategory').textContent = tr.dataset.typeName || 'Standard';
    $('#vNumber').textContent = tr.dataset.number;

    const vBadge = $('#vBadge');
    vBadge.className = `badge ${tr.dataset.status || 'Available'}`;
    vBadge.textContent = tr.dataset.status || 'Available';

    // Populate photo gallery and hero photo with ONLY this room's photos
    const vHero = $('#vHeroPhoto');
    const vGallery = $('#vGallery');
    const galleryContainer = vGallery ? vGallery.parentElement : null;
    const rawImages = (tr.dataset.images || '').split(',').map(s => s.trim()).filter(Boolean);
    const images = [...new Set(rawImages)]; // Strict deduplication for this room only

    if (images.length > 0) {
        if (vHero) {
            vHero.src = resolveImageUrl(images[0]);
            vHero.alt = `Room ${tr.dataset.number} Suite Photo`;
        }
        if (vGallery) {
            if (images.length > 1) {
                if (galleryContainer) galleryContainer.style.display = '';
                vGallery.innerHTML = images.map((img, idx) => `
                    <img src="${resolveImageUrl(img)}" 
                         alt="Room ${tr.dataset.number} Photo ${idx + 1}" 
                         class="${idx === 0 ? 'active' : ''}" 
                         onclick="document.getElementById('vHeroPhoto').src=this.src; document.querySelectorAll('#vGallery img').forEach(el=>el.classList.remove('active')); this.classList.add('active');" 
                         onerror="this.onerror=null;this.src='${ctx}/Image/default_room.jpg';">
                `).join('');
            } else {
                // If only 1 image belongs to this room, show only that image in hero and hide gallery strip
                vGallery.innerHTML = '';
                if (galleryContainer) galleryContainer.style.display = 'none';
            }
        }
    } else {
        if (vHero) {
            vHero.src = `${ctx}/Image/default_room.jpg`;
            vHero.alt = `Room ${tr.dataset.number} Photo`;
        }
        if (vGallery) {
            vGallery.innerHTML = '';
            if (galleryContainer) galleryContainer.style.display = 'none';
        }
    }

    const amMap = Object.fromEntries(AVAILABLE_AMENITIES.map(a => [a.id, a.label]));
    const amenities = (tr.dataset.amenities || '').split(',').map(s => s.trim()).filter(Boolean);

    $('#vAmenities').innerHTML = amenities.length
            ? amenities.map(rawA => {
                const a = LEGACY_AMENITY_MAP[rawA.toLowerCase()] || rawA;
                const label = amMap[a] || a;
                return `<span class="spec-tag">${esc(label)}</span>`;
            }).join('')
            : '<span class="text-dim">No extra amenities listed for this room.</span>';

    viewDlg.showModal();
}

const vEditBtn = $('#vEditBtn');
if (vEditBtn) {
    vEditBtn.onclick = () => {
        viewDlg.close();
        if (viewingRow)
            openEditModal(viewingRow);
    };
}

const addBtn = $('#addBtn');
if (addBtn)
    addBtn.onclick = () => openEditModal();

/*  ROW ACTION EVENT DELEGATION  */
const rowsEl = $('#rows');
if (rowsEl) {
    rowsEl.addEventListener('click', e => {
        const btn = e.target.closest('button');
        if (!btn)
            return;
        const tr = btn.closest('tr');
        if (!tr)
            return;

        if (btn.classList.contains('action-view')) {
            openViewModal(tr);
        } else if (btn.classList.contains('action-edit')) {
            openEditModal(tr);
        } else if (btn.classList.contains('action-del')) {
            $('#delRoomId').value = tr.dataset.id;
            $('#delText').textContent = `Are you sure you want to delete Room ${tr.dataset.number} (${tr.dataset.title})? This action cannot be undone.`;
            delDlg.showModal();
        }
    });
}