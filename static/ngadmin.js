/* ===========================================================
   MODAL ENGINE (FINAL VERSION)
   =========================================================== */

function openModal(id) {
    const overlay = document.getElementById("modal-overlay");
    const container = document.getElementById("modal-container");
    const modal = document.getElementById(id);

    if (!modal) {
        console.error("Modal ID not found:", id);
        return;
    }
    container.innerHTML = "";
    container.appendChild(modal);
    modal.classList.remove("hidden");
    overlay.classList.remove("hidden");
    overlay.classList.add("flex");
}

function closeModal() {
    const overlay = document.getElementById("modal-overlay");
    const container = document.getElementById("modal-container");
    overlay.classList.add("hidden");
    overlay.classList.remove("flex");
    document.querySelectorAll(".modal-block").forEach(m => {
        m.classList.add("hidden");
        document.body.appendChild(m);
    });
    container.innerHTML = "";
}


/* ===========================================================
   COLLAPSE TOGGLE (Panduan)
   =========================================================== */
function toggleCollapse(id) {
    const el = document.getElementById(id);
    if (!el) return;

    if (el.classList.contains("hidden")) {
        el.classList.remove("hidden");
    } else {
        el.classList.add("hidden");
    }
}



/* ===========================================================
   NAVBAR ACTIVE HIGHLIGHT (Fix Exact Dashboard Match)
=========================================================== */

document.addEventListener("DOMContentLoaded", () => {
    const path = window.location.pathname;
    if (path === "/ngadmin" || path === "/ngadmin/") {
        const nav = document.getElementById("nav-dashboard");
        if (nav) nav.classList.add("topnav-active");
        return;
    }
    const menuMap = [
        { key: "/ngadmin/ruangan",  id: "nav-ruangan" },
        { key: "/ngadmin/booking",  id: "nav-booking" },
        { key: "/ngadmin/jadwal",   id: "nav-jadwal" },
        { key: "/ngadmin/fakultas", id: "nav-fakultas" },
        { key: "/ngadmin/pengguna", id: "nav-pengguna" },
    ];

    menuMap.forEach(m => {
        if (path.startsWith(m.key)) {
            const nav = document.getElementById(m.id);
            if (nav) nav.classList.add("topnav-active");
        }
    });
});

