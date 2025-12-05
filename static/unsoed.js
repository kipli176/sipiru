
function showPage(id, push=true){
    document.querySelectorAll(".page").forEach(p => p.classList.remove("active"));
    document.getElementById(id).classList.add("active");

    if(push){
        history.pushState({page:id}, "");
    }
}

function backTo(id) {
    showPage(id, true);
}

function toggleTheme(){
    let h=document.documentElement;
    if(h.classList.contains("dark")){
        h.classList.remove("dark");
        localStorage.setItem("theme","light");
    } else {
        h.classList.add("dark");
        localStorage.setItem("theme","dark");
    }
}
if(localStorage.getItem("theme")==="light"){
    document.documentElement.classList.remove("dark");
}

/* SHEET */
function openSheet(){ sheet.classList.add("active"); }
function closeSheet(){ sheet.classList.remove("active"); }

/* STATE */
let state = {
    fakultas_id:null,
    ruangan_id:null,
    tanggal:null,
    slot_ids:[],
    slots_raw:[],
    monthOffset:0
};


/* ==========================
   LOAD FAKULTAS
========================== */
async function loadFakultas(){
    fakultas_list.innerHTML=`
        <div class="card-premium shimmer h-20"></div>
        <div class="card-premium shimmer h-20"></div>
    `;
    let list=await (await fetch("/cgv/api/fakultas")).json();

    fakultas_list.innerHTML="";
    fakultas_peminjam_id.innerHTML = '<option value="">Pilih Fakultas</option>';
    list.forEach(f=>{
        let card=document.createElement("div");
        card.className="card-premium cursor-pointer";

        card.innerHTML=`
            <div class="flex justify-between items-center">
                <div class="flex items-center gap-3">
                    <span class="text-2xl">🎓</span>
                    <span class="font-bold">${f.nama}</span>
                </div>
                <span class="text-xl opacity-50">›</span>
            </div>
        `;

        card.onclick=()=>{
            state.fakultas_id = f.id;
            showPage("ruangan_page");
            loadRuangan();
        };

        fakultas_list.appendChild(card);
        fakultas_peminjam_id.innerHTML += `<option value="${f.id}">${f.nama}</option>`;
    });
}


/* ==========================
   LOAD RUANGAN + EMPTY STATE
========================== */
async function loadRuangan(){
    ruangan_list.innerHTML=`
        <div class="card-premium shimmer h-24"></div>
        <div class="card-premium shimmer h-24"></div>
    `;

    let list=await (await fetch(`/cgv/api/ruangan?fakultas_id=${state.fakultas_id}`)).json();

    if(list.length === 0){
        ruangan_list.innerHTML = `
            <div class="card-premium text-center opacity-70 p-6 col-span-2">
                <div class="text-xl mb-2">⚠ Tidak Ada Ruangan</div>
                <div>Belum ada ruangan yang terdaftar untuk fakultas ini.</div>
            </div>
        `;
        return;
    }

    ruangan_list.innerHTML="";
    list.forEach(r=>{
        let capColor =
            r.kapasitas < 50 ? "bg-blue-500" :
            r.kapasitas == 50 ? "bg-yellow-400" :
            "bg-green-500";

        let card=document.createElement("div");
        card.className="card-premium cursor-pointer mb-4";

        card.innerHTML=`
            <div class="flex justify-between">
                <div>
                    <div class="font-bold text-xl">${r.kode_ruang}</div>
                    <div class="opacity-60">${r.nama_ruang}</div>
                    <div class="opacity-60 text-sm">
                        ${r.gedung} • Lt ${r.lantai}
                    </div>
                </div>
                <div class="px-3 py-1 text-white rounded ${capColor}">
                    ${r.kapasitas}
                </div>
            </div>
        `;

        card.onclick=()=>{
            state.ruangan_id = r.id;
            state.monthOffset = 0;
            genCalendar();
            showPage("tanggal_page");
        };

        ruangan_list.appendChild(card);
    });
}


/* ==========================
   CALENDAR FIX
========================== */
function genCalendar(){
    const header=document.getElementById("calendar_header");
    const grid=document.getElementById("calendar_grid");
    grid.innerHTML="";

    let today=new Date();

    let base=new Date();
    base.setMonth(base.getMonth()+state.monthOffset);

    let year=base.getFullYear();
    let month=base.getMonth();

    header.innerText = base.toLocaleDateString("id-ID",{month:"long", year:"numeric"});

    let first=new Date(year,month,1);
    let last=new Date(year,month+1,0);
    let total=last.getDate();

    let firstDayIdx = (first.getDay()+6) % 7;

    for(let i=0;i<firstDayIdx;i++){
        let blank=document.createElement("div");
        blank.className="opacity-0 select-none";
        grid.appendChild(blank);
    }

    for(let d=1; d<=total; d++){
        let dateObj=new Date(year,month,d);
        let value=`${year}-${String(month+1).padStart(2,'0')}-${String(d).padStart(2,'0')}`;

        let cell=document.createElement("div");
        cell.className="calendar-cell";
        cell.innerText=d;

        let isToday =
            d===today.getDate() &&
            month===today.getMonth() &&
            year===today.getFullYear();

        if(isToday) cell.classList.add("calendar-today");

        // ================================
        // 🚫 DISABLE TANGGAL SEBELUM HARI INI
        // ================================
        let todayMid = new Date(today.getFullYear(), today.getMonth(), today.getDate());
        let dateMid = new Date(year, month, d);

        if (dateMid < todayMid) {
            cell.classList.add("opacity-30", "cursor-not-allowed");
            cell.style.pointerEvents = "none";
        } else {
            // Jika valid → klik untuk memilih tanggal
            cell.onclick = () => {
                state.tanggal = value;

                [...grid.children].forEach(c => c.classList.remove("calendar-selected"));
                cell.classList.add("calendar-selected");

                loadSlots();
                showPage("slot_page");
            };
        }

        grid.appendChild(cell);
    }
}

function prevMonth(){ state.monthOffset--; if(state.monthOffset < -2) state.monthOffset = -2; if(state.monthOffset > 3) state.monthOffset = 3; genCalendar(); }
function nextMonth(){ state.monthOffset++; if(state.monthOffset < -2) state.monthOffset = -2; if(state.monthOffset > 3) state.monthOffset = 3; genCalendar(); }


/* ==========================
   SLOT (BACKEND COLOR)
========================== */
async function loadSlots(){
    slot_list.innerHTML=`
        <div class="card-premium shimmer h-20"></div>
        <div class="card-premium shimmer h-20"></div>
    `;

    let list=await (await fetch(
        `/cgv/api/slots?ruangan_id=${state.ruangan_id}&tanggal=${state.tanggal}`
    )).json();

    state.slots_raw=list;
    state.slot_ids=[];
    slot_list.innerHTML="";

    list.forEach(s=>{
        let dotColor,borderColor;

        if(s.color==="green"){
            dotColor="bg-green-500"; borderColor="#8FEF9A";
        }
        else if(s.color==="blue"){
            dotColor="bg-blue-500"; borderColor="#7BB7FF";
        }
        else {
            dotColor="bg-red-500"; borderColor="#FF8C8C";
        }

        let card=document.createElement("div");
        card.className="slot-card";
        card.style.borderColor=borderColor;

        card.innerHTML=`
            <div class="slot-dot ${dotColor}"></div>
            <div>
                <div class="text-xl font-bold">${s.label}</div>
                <div class="text-sm opacity-70 mt-1">${s.keterangan}</div>
            </div>
        `;

        if(s.color !== "green"){
            card.style.opacity=".45";
            card.dataset.slotId = s.id;
            slot_list.appendChild(card);
            return;
        }

        card.onclick=()=>toggleSlot(s.id);
        card.dataset.slotId = s.id;
        slot_list.appendChild(card);
    });
}


function toggleSlot(id){
    let sel=state.slot_ids;

    if(sel.includes(id)){
        state.slot_ids = sel.slice(0, sel.indexOf(id));
        refreshSlot();
        return;
    }

    if(sel.length===0){
        closeSheet();
        state.slot_ids=[id];
        refreshSlot();
        openSheet();
        return;
    }

    let last=sel[sel.length-1];
    if(id !== last+1){
        alert("Slot harus berurutan");
        return;
    }
 
    state.slot_ids.push(id);
    refreshSlot();
    openSheet();
}

function refreshSlot(){
    document.querySelectorAll("#slot_list .slot-card").forEach(card => {
        let slotId = Number(card.dataset.slotId);

        if (state.slot_ids.includes(slotId)) {
            card.classList.add("slot-selected");
        } else {
            card.classList.remove("slot-selected");
        }
    });
}



/* ==========================
   FORM
========================== */
asal_select.onchange=()=>{
    asal_fakultas_box.classList.add("hidden");
    asal_unit.classList.add("hidden");
    asal_eksternal.classList.add("hidden");

    if(asal_select.value==="fakultas") asal_fakultas_box.classList.remove("hidden");
    if(asal_select.value==="unit") asal_unit.classList.remove("hidden");
    if(asal_select.value==="eksternal") asal_eksternal.classList.remove("hidden");
};


/* ==========================
   SUBMIT BOOKING
========================== */
let bookingBusy=false;

async function submitBooking(){
    if(bookingBusy) return;

    bookingBusy=true;
    btnBooking.innerText="Mengirim…";

    let payload={
        ruangan_id:state.ruangan_id,
        tanggal:state.tanggal,
        slot_ids:state.slot_ids,
        nama:nama.value,
        hp:hp.value,
        kegiatan:kegiatan.value,
        asal_select:asal_select.value,
        fakultas_peminjam_id:fakultas_peminjam_id.value,
        asal_unit:asal_unit.value,
        asal_eksternal:asal_eksternal.value
    };

    let res=await fetch("/cgv/api/booking",{
        method:"POST",
        headers:{"Content-Type":"application/json"},
        body:JSON.stringify(payload)
    });

    let out=await res.json();

    if(!out.success){
        alert(out.message);
        bookingBusy=false;
        btnBooking.innerText="Buat Booking";
        return;
    }

    window.location.href=`/cgv/ticket/${out.group_id}`;
}
/* ==========================
   HANDLE BACK BUTTON
========================== */
window.onpopstate = function(event){
    if(event.state && event.state.page){
        showPage(event.state.page, false);
    }
};

history.replaceState({page: "hero_page"}, "");


/* INIT */
loadFakultas();


if ("serviceWorker" in navigator) {
    window.addEventListener("load", () => {
        navigator.serviceWorker.register("/static/service-worker.js")
        .then(reg => console.log("Service Worker registered:", reg))
        .catch(err => console.log("Service Worker error:", err));
    });
}


let deferredPrompt;

const installBanner = document.getElementById("installBanner");
const btnInstallPWA = document.getElementById("btnInstallPWA");

// Default: sembunyikan banner
installBanner.classList.add("hidden");

// Browser memicu event saat boleh diinstall
window.addEventListener("beforeinstallprompt", (e) => {
    e.preventDefault();
    deferredPrompt = e;

    // Tampilkan banner install
    installBanner.classList.remove("hidden");
});

// Saat tombol install ditekan
btnInstallPWA.addEventListener("click", async () => {
    if (!deferredPrompt) return;

    deferredPrompt.prompt();

    const result = await deferredPrompt.userChoice;

    if (result.outcome === "accepted") {
        console.log("User menerima install");
    } else {
        console.log("User membatalkan install");
    }

    installBanner.classList.add("hidden");
    deferredPrompt = null;
});

// Jika aplikasi sudah terinstal → sembunyikan notifikasi
window.addEventListener("appinstalled", () => {
    console.log("PWA installed");
    installBanner.classList.add("hidden");
});