from flask import Flask, render_template, request, redirect, url_for,session, jsonify, Response, flash, send_file
from datetime import datetime, date
from functools import wraps 
import base64 
import qrcode
from io import BytesIO
from db import query_all, query_one, execute
from flask_caching import Cache

from helper import (
    # UTILITIES
    q, to_str, get_total, get_all_timeslots, parse_import_file,

    # AUTH
    get_fakultas_aktif_nama, authenticate_admin, set_admin_session,

    # DASHBOARD
    get_dashboard_counts, get_dashboard_recent_activity,
    get_top_ruangan, get_jadwal_hari_ini,

    # RUANGAN
    get_ruangan_page, get_ruangan_by_id, get_ruangan_list,
    ruang_kode_exists, insert_ruangan, update_ruangan,
    toggle_ruangan, delete_ruangan, get_ruangan_export_rows,
    generate_ruangan_export_excel,

    # JADWAL
    get_jadwal_page, get_jadwal_detail, bentrok_jadwal,
    insert_jadwal, update_jadwal, delete_jadwal,
    batch_insert_jadwal, get_jadwal_export_rows,
    generate_jadwal_export_excel,

    # BOOKING
    get_booking_page, serialize_booking_rows
)


app = Flask(__name__)
app.secret_key = "secret-key-ubah-nanti"

cache = Cache(app, config={
    "CACHE_TYPE": "SimpleCache",
    "CACHE_DEFAULT_TIMEOUT": 60   # default cache 60 detik
})


# =====================================================
# =============== HELPERS / SERVICE ===================
# =====================================================

def q(sql, params=None, one=False, commit=False, many=False):
    if many:
        execute(sql, params, many=True)
        return None
    if one:
        return query_one(sql, params)
    if commit:
        execute(sql, params)
        return None
    return query_all(sql, params)

def view(tpl, **ctx):
    return render_template(tpl, **ctx)

def is_htmx():
    return request.headers.get("HX-Request") == "true"

HARI_MAP = {
    "senin": 1, "selasa": 2, "rabu": 3, "kamis": 4,
    "jumat": 5, "sabtu": 6, "minggu": 7
}

def get_slots():
    slots = q("SELECT id, start_time, end_time FROM time_slot ORDER BY id")
    for s in slots:
        s["label"] = f"{s['start_time']} - {s['end_time']}"
    return slots

def tanggal_indonesia_full(tanggal):
    if isinstance(tanggal, str):
        try:
            tanggal = datetime.strptime(tanggal, "%Y-%m-%d")
        except:
            try:
                tanggal = datetime.fromisoformat(tanggal)
            except:
                return tanggal

    hari = ["Senin","Selasa","Rabu","Kamis","Jumat","Sabtu","Minggu"]
    bulan = [
        "Januari","Februari","Maret","April","Mei","Juni",
        "Juli","Agustus","September","Oktober","November","Desember"
    ]
    return f"{hari[tanggal.weekday()]}, {tanggal.day} {bulan[tanggal.month-1]} {tanggal.year}"


app.jinja_env.filters["indo_full"] = tanggal_indonesia_full

@app.context_processor
def inject_globals():
    return {
        "fakultas_nama": session.get("fakultas_nama"),
        "admin_nama": session.get("admin_nama"),
        "is_superadmin": session.get("role") == "superadmin"
    }

def get_fakultas_aktif():
    return q("""
        SELECT id, kode, nama
        FROM fakultas
        WHERE aktif = TRUE
        ORDER BY nama
    """)

def get_fakultas_list_simple():
    return q("""
        SELECT id, nama
        FROM fakultas
        WHERE aktif = TRUE
        ORDER BY nama
    """)

def get_ruangan_by_fakultas(fakultas_id):
    return q("""
        SELECT id, kode_ruang, nama_ruang, gedung, lantai, kapasitas
        FROM ruangan
        WHERE fakultas_id = %s AND aktif = TRUE
        ORDER BY nama_ruang
    """, (fakultas_id,))

def get_time_slots():
    rows = q("SELECT id, start_time, end_time FROM time_slot ORDER BY id")
    return rows

def build_slot_status(ruangan_id, tanggal):

    tanggal = str(tanggal).strip()

    slots = get_time_slots()

    rows = q("""
        SELECT source, time_slot_id, mata_kuliah, kelas, dosen,
               nama_peminjam, kegiatan
        FROM v_jadwal_ruang_harian
        WHERE ruangan_id = %s
          AND tanggal = %s
          AND (source = 'kuliah' OR (source = 'booking'))
    """, (ruangan_id, tanggal))

    # pisahkan menjadi map
    kuliah_map  = {}
    booking_map = {}

    for r in rows:
        tid = int(r["time_slot_id"])
        if r["source"] == "kuliah":
            kuliah_map[tid] = r
        else:  # booking
            booking_map[tid] = r

    results = []

    for s in slots:
        sid = int(s["id"])
        label = f"{s['start_time'].strftime('%H:%M')} - {s['end_time'].strftime('%H:%M')}"

        kul = kuliah_map.get(sid)
        book = booking_map.get(sid)

        if kul:
            results.append({
                "id": sid,
                "label": label,
                "color": "red",
                "keterangan": f"Kuliah {kul['mata_kuliah']} ({kul['kelas']}) — {kul['dosen']}"
            })
        elif book:
            results.append({
                "id": sid,
                "label": label,
                "color": "blue",
                "keterangan": f"Booked: {book['nama_peminjam']} — {book['kegiatan']}"
            })
        else:
            results.append({
                "id": sid,
                "label": label,
                "color": "green",
                "keterangan": "Tersedia"
            })

    return results

@cache.memoize(60)
def build_slot_status_cached(ruangan_id, tanggal):
    return build_slot_status(ruangan_id, tanggal)


def generate_qr_base64(text):
    qr = qrcode.QRCode(box_size=3, border=2)
    qr.add_data(text)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    buf = BytesIO()
    img.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()

def update_booking_status(group_id, admin_id, status, is_active):
    q("""
        UPDATE booking_ruangan
        SET 
            status=%s,
            is_active=%s,
            approved_by_admin_id=%s,
            approved_at=NOW()
        WHERE group_id=%s
    """, (status, is_active, admin_id, group_id), commit=True)

def login_required(f):
    @wraps(f)
    def wrap(*args, **kwargs):
        if "admin_id" not in session:
            return redirect(url_for("ngadmin_login_get"))
        return f(*args, **kwargs)
    return wrap

@app.route("/")
def booking_cgv():
    return view("unsoed/index_cgv.html", fakultas=get_fakultas_aktif())

@app.get("/cgv/api/fakultas")
def cgv_fakultas():
    return jsonify(get_fakultas_list_simple())

@app.get("/cgv/api/ruangan")
def cgv_ruangan():
    fakultas_id = request.args.get("fakultas_id")
    return jsonify(get_ruangan_by_fakultas(fakultas_id))

@app.get("/cgv/api/slots")
def cgv_slots():
    ruangan_id = request.args.get("ruangan_id")
    tanggal = request.args.get("tanggal").strip()
    return jsonify(build_slot_status_cached(ruangan_id, tanggal))

@app.post("/cgv/api/booking")
def cgv_booking():
    data = request.get_json()

    nama = (data.get("nama") or "").strip()
    hp = (data.get("hp") or "").strip()
    kegiatan = (data.get("kegiatan") or "").strip()
    ruangan_id = data.get("ruangan_id")
    tanggal = data.get("tanggal")
    slot_ids = data.get("slot_ids", [])

    if len(nama) < 3:
        return jsonify({"success": False, "message": "Nama minimal 3 huruf."})
    if len(kegiatan) < 5:
        return jsonify({"success": False, "message": "Kegiatan terlalu pendek."})
    if not hp.isdigit() or len(hp) < 8:
        return jsonify({"success": False, "message": "Nomor HP tidak valid."})
    if not ruangan_id or not tanggal or not slot_ids:
        return jsonify({"success": False, "message": "Data tidak lengkap."})

    sorted_ids = sorted(slot_ids)
    if sorted_ids != list(range(sorted_ids[0], sorted_ids[-1] + 1)):
        return jsonify({"success": False, "message": "Slot harus berurutan."})

    asal_select = data.get("asal_select")
    fakultas_peminjam_id = None
    asal_unit = None
    asal_eksternal = None

    if asal_select == "fakultas":
        fakultas_peminjam_id = data.get("fakultas_peminjam_id")
        fk = q("SELECT id FROM fakultas WHERE id=%s AND aktif=TRUE",
               (fakultas_peminjam_id,), one=True)
        if not fk:
            return jsonify({"success": False, "message": "Fakultas peminjam tidak valid."})

    elif asal_select == "unit":
        asal_unit = data.get("asal_unit")
        if not asal_unit:
            return jsonify({"success": False, "message": "Nama unit belum diisi."})

    elif asal_select == "eksternal":
        asal_eksternal = data.get("asal_eksternal")
        if not asal_eksternal:
            return jsonify({"success": False, "message": "Instansi eksternal belum diisi."})
    else:
        return jsonify({"success": False, "message": "Asal peminjam belum dipilih."})

    conflicts = q("""
        SELECT 1
        FROM v_jadwal_ruang_harian
        WHERE ruangan_id = %s
          AND tanggal = %s
          AND time_slot_id = ANY(%s)
          AND (
                source='kuliah' OR
                (source='booking' AND booking_status IN ('pending','approved'))
              )
    """, (ruangan_id, tanggal, slot_ids))

    if conflicts:
        return jsonify({"success": False, "message": "Slot bentrok dengan jadwal lain."})

    group_id = q("SELECT gen_random_uuid() AS id", one=True)["id"]

    ts_map = {r["id"]: r for r in get_time_slots()}

    for sid in slot_ids:
        ts = ts_map[sid]
        q("""
            INSERT INTO booking_ruangan (
                group_id, tanggal, ruangan_id, time_slot_id,
                jam_mulai, jam_selesai,
                nama_peminjam, kegiatan, hp,
                fakultas_peminjam_id, asal_unit, asal_eksternal,
                status, is_active
            )
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,'pending',TRUE)
        """, (
            group_id, tanggal, ruangan_id, sid,
            ts["start_time"], ts["end_time"],
            nama, kegiatan, hp,
            fakultas_peminjam_id, asal_unit, asal_eksternal
        ), commit=True)

    qr_code = generate_qr_base64(f"{request.host_url}cgv/ticket/{group_id}")

    q("""
        UPDATE booking_ruangan
        SET qr_code=%s
        WHERE id = (
            SELECT id FROM booking_ruangan
            WHERE group_id=%s
            ORDER BY id ASC
            LIMIT 1
        )
    """, (qr_code, group_id), commit=True)

    return jsonify({"success": True, "group_id": group_id})

@app.route("/cgv/ticket/<group_id>")
def ticket_cgv(group_id):
    data = q("SELECT * FROM v_booking_group WHERE group_id=%s", (group_id,), one=True)
    if not data:
        return "Data tidak ditemukan", 404

    ruangan = q("""
        SELECT id, kode_ruang, nama_ruang, gedung, lantai, kapasitas
        FROM ruangan
        WHERE id=%s
    """, (data["ruangan_id"],), one=True)

    slot_rows = get_time_slots()
    slot_map = {r["id"]: r for r in slot_rows}

    user_slots = [slot_map[sid] for sid in data["slot_ids"] if sid in slot_map]

    return view("unsoed/ticket_cgv.html",
                booking=data,
                ruangan=ruangan,
                slots=user_slots,
                is_admin=("admin_id" in session))

@app.route("/qr/<group_id>.png")
def qr_image(group_id):
    row = q("SELECT qr_code FROM v_booking_group WHERE group_id=%s", (group_id,), one=True)
    if not row:
        return "Not found", 404

    qr_bytes = base64.b64decode(row["qr_code"].split(",")[-1])
    return Response(qr_bytes, mimetype="image/png")

@app.route("/cgv/admin/bookings/<group_id>/approve", methods=["POST"])
@login_required
def cgv_admin_approve(group_id):
    update_booking_status(group_id, session["admin_id"], "approved", True)
    return redirect(f"/cgv/ticket/{group_id}")

@app.route("/cgv/admin/bookings/<group_id>/reject", methods=["POST"])
@login_required
def cgv_admin_reject(group_id):
    update_booking_status(group_id, session["admin_id"], "rejected", False)
    return redirect(f"/cgv/ticket/{group_id}")


# == ROUTES NGADMIN AUTH ==

@app.route("/ngadmin/login", methods=["GET"])
def ngadmin_login_get():
    return view("unsoed/login.html", fakultas=get_fakultas_aktif_nama())

@app.route("/ngadmin/login", methods=["POST"])
def ngadmin_login_post():
    fakultas_id = request.form.get("fakultas_id")
    password = request.form.get("password")

    if not fakultas_id or not password:
        return view("unsoed/login.html",
                    fakultas=get_fakultas_aktif_nama(),
                    error="Fakultas dan password wajib diisi")

    admin = authenticate_admin(fakultas_id, password)
    if not admin:
        return view("unsoed/login.html",
                    fakultas=get_fakultas_aktif_nama(),
                    error="Fakultas atau password salah")

    set_admin_session(admin)
    return redirect(url_for("ngadmin_dashboard"))

@app.route("/ngadmin/logout")
def ngadmin_logout():
    session.clear()
    return redirect(url_for("ngadmin_login_get"))

@app.route("/ngadmin")
@login_required
def ngadmin_dashboard():
    total_booking, total_ruangan, total_jadwal = get_dashboard_counts()
    aktivitas_terbaru = get_dashboard_recent_activity()
    top_ruangan = get_top_ruangan()
    today = date.today()
    jadwal_hari_ini = get_jadwal_hari_ini(today)

    return view("unsoed/dashboard.html",
        total_booking=total_booking,
        total_ruangan=total_ruangan,
        total_jadwal=total_jadwal,
        aktivitas_terbaru=aktivitas_terbaru,
        top_ruangan=top_ruangan,
        jadwal_hari_ini=jadwal_hari_ini,
        today=today
    )

@app.route("/ngadmin/ruangan")
@login_required
def ngadmin_ruangan():
    page = int(request.args.get("page", 1))
    per_page = 50
    offset = (page - 1) * per_page
    fak = session["fakultas_id"]

    total = get_total("ruangan", "fakultas_id=%s", [fak])
    data = get_ruangan_page(fak, per_page, offset)

    return view(
        "unsoed/ruangan.html",
        data=data,
        page=page,
        per_page=per_page,
        start=(offset + 1 if total else 0),
        end=min(offset + per_page, total),
        total=total
    )

@app.route("/ngadmin/ruangan/get/<int:id>")
@login_required
def ngadmin_ruangan_get(id):
    fak = session["fakultas_id"]
    return jsonify(get_ruangan_by_id(id, fak))

@app.route("/ngadmin/ruangan/add", methods=["POST"])
@login_required
def ngadmin_ruangan_add():
    fak = session["fakultas_id"]

    kode = request.form["kode_ruang"].strip()
    nama = request.form["nama_ruang"].strip()
    gedung = request.form.get("gedung")
    lantai = request.form.get("lantai")
    kapasitas = request.form.get("kapasitas")
    fasilitas = request.form.get("fasilitas")
    catatan = request.form.get("catatan")

    if ruang_kode_exists(fak, kode):
        flash(f"Kode ruangan '{kode}' sudah digunakan.", "error")
        return redirect(url_for("ngadmin_ruangan", show_add=1))

    insert_ruangan(fak, kode, nama, gedung, lantai, kapasitas, fasilitas, catatan)

    flash("Ruangan berhasil ditambahkan.", "success")
    return redirect(url_for("ngadmin_ruangan"))

@app.route("/ngadmin/ruangan/update/<int:id>", methods=["POST"])
@login_required
def ngadmin_ruangan_update(id):
    fak = session["fakultas_id"]

    kode = request.form["kode_ruang"]
    nama = request.form["nama_ruang"]
    gedung = request.form.get("gedung")
    lantai = request.form.get("lantai")
    kapasitas = request.form.get("kapasitas")
    fasilitas = request.form.get("fasilitas")
    aktif = request.form.get("aktif") == "1"
    catatan = request.form.get("catatan")

    if ruang_kode_exists(fak, kode, exclude_id=id):
        return "Kode ruangan sudah digunakan", 400

    update_ruangan(id, fak, kode, nama, gedung, lantai,
                   kapasitas, fasilitas, aktif, catatan)

    return redirect(url_for("ngadmin_ruangan"))

@app.route("/ngadmin/ruangan/toggle/<int:id>", methods=["POST"])
@login_required
def ngadmin_ruangan_toggle(id):
    fak = session["fakultas_id"]
    toggle_ruangan(id, fak)
    return jsonify({"success": True})

@app.route("/ngadmin/ruangan/delete/<int:id>")
@login_required
def ngadmin_ruangan_delete(id):
    fak = session["fakultas_id"]
    delete_ruangan(id, fak)
    return redirect(url_for("ngadmin_ruangan"))

@app.route("/ngadmin/ruangan/import", methods=["POST"])
@login_required
def ngadmin_ruangan_import():
    file = request.files.get("file")
    if not file:
        return "File tidak ditemukan", 400
    fak = session["fakultas_id"]

    # Hapus data lama
    q("DELETE FROM jadwal_kuliah WHERE fakultas_id=%s", [fak], commit=True)
    q("DELETE FROM ruangan WHERE fakultas_id=%s", [fak], commit=True)

    rows, error = parse_import_file(file, min_cols=2)

    if error:
        return error, 400

    inserted = 0
    for r in rows:
        if not r or len(r) < 2:
            continue

        kode_ruang = r[0].strip()
        nama_ruang = r[1].strip()
        if not kode_ruang:
            continue

        gedung = r[2].strip() if len(r) > 2 else None
        lantai = r[3].strip() if len(r) > 3 else None
        kapasitas = r[4].strip() if len(r) > 4 else None
        fasilitas = r[5].strip() if len(r) > 5 else None
        catatan = r[6].strip() if len(r) > 6 else None

        insert_ruangan(fak, kode_ruang, nama_ruang,
                       gedung, lantai, kapasitas, fasilitas, catatan)

        inserted += 1

    flash(f"{inserted} ruangan berhasil diimport.", "success")
    return redirect(url_for("ngadmin_ruangan", _import=1))

@app.route("/ngadmin/ruangan/export")
@login_required
def ngadmin_ruangan_export():
    fak = session["fakultas_id"]
    rows = get_ruangan_export_rows(fak)
    output = generate_ruangan_export_excel(rows)

    return send_file(
        output,
        download_name="ruangan.xlsx",
        as_attachment=True,
        mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

# == ROUTES NGADMIN JADWAL ==
@app.route("/ngadmin/jadwal")
@login_required
def ngadmin_jadwal():
    fak = session["fakultas_id"]
    page = int(request.args.get("page", 1))
    per_page = 10
    offset = (page - 1) * per_page

    total = get_total("jadwal_kuliah", "fakultas_id=%s", [fak])
    data = get_jadwal_page(fak, per_page, offset)
    ruang = get_ruangan_list(fak)
    time_slot = get_all_timeslots()

    return view("unsoed/jadwal.html",
        data=data,
        ruang=ruang,
        time_slot=time_slot,
        page=page,
        per_page=per_page,
        start=(offset + 1 if total else 0),
        end=min(offset + per_page, total),
        total=total
    )

@app.route("/ngadmin/jadwal/get/<int:id>")
@login_required
def ngadmin_jadwal_get(id):
    fak = session["fakultas_id"]
    d = get_jadwal_detail(id, fak)
    return jsonify({k: to_str(d[k]) for k in d})

@app.route("/ngadmin/jadwal/detail/<int:id>")
@login_required
def ngadmin_jadwal_detail(id):
    fak = session["fakultas_id"]
    d = get_jadwal_detail(id, fak)
    return jsonify({k: to_str(v) for k, v in d.items()})

@app.route("/ngadmin/jadwal/add", methods=["POST"])
@login_required
def ngadmin_jadwal_add():
    fak = session["fakultas_id"]

    semester = request.form["semester_kode"]
    hari = request.form["hari"]
    hari_dow = int(request.form["hari_dow"])
    jam_mulai = request.form["jam_mulai"]
    jam_selesai = request.form["jam_selesai"]
    ruangan_id = request.form["ruangan_id"]
    mk = request.form["mata_kuliah"]
    kode_mk = request.form.get("kode_mk")
    kelas = request.form.get("kelas")
    dosen = request.form.get("dosen")
    tgl_mulai = request.form.get("tanggal_mulai") or None
    tgl_selesai = request.form.get("tanggal_selesai") or None

    if bentrok_jadwal(ruangan_id, hari_dow, jam_mulai, jam_selesai):
        flash("Ruangan sudah terpakai pada jam tersebut.", "error")
        return redirect(url_for("ngadmin_jadwal", show_add=1))

    insert_jadwal([
        semester, tgl_mulai, tgl_selesai,
        hari_dow, hari, jam_mulai, jam_selesai,
        ruangan_id, mk, kode_mk, kelas, dosen, fak
    ])

    flash("Jadwal berhasil ditambahkan.", "success")
    return redirect(url_for("ngadmin_jadwal"))

@app.route("/ngadmin/jadwal/update/<int:id>", methods=["POST"])
@login_required
def ngadmin_jadwal_update_route(id):
    fak = session["fakultas_id"]
    update_jadwal(id, fak, request.form)
    return redirect(url_for("ngadmin_jadwal"))

@app.route("/ngadmin/jadwal/delete/<int:id>")
@login_required
def ngadmin_jadwal_delete_route(id):
    delete_jadwal(id, session["fakultas_id"])
    return redirect(url_for("ngadmin_jadwal"))

@app.route("/ngadmin/jadwal/import", methods=["POST"])
@login_required
def ngadmin_jadwal_import():
    fak = session["fakultas_id"]
    file = request.files.get("file")

    if not file:
        flash("File tidak ditemukan.", "error")
        return redirect(url_for("ngadmin_jadwal", _import=1))

    rows, err = parse_import_file(file, min_cols=11)
    if err:
        flash(err, "error")
        return redirect(url_for("ngadmin_jadwal", _import=1))

    ruangan_map = {
        r["kode_ruang"].upper(): r["id"]
        for r in q("SELECT id, kode_ruang FROM ruangan WHERE fakultas_id=%s", [fak])
    }

    q("DELETE FROM jadwal_kuliah WHERE fakultas_id=%s", [fak], commit=True)

    HARI_MAP = {
        "senin": 1, "selasa": 2, "rabu": 3, "kamis": 4,
        "jumat": 5, "sabtu": 6, "minggu": 7,
    }

    batch_values = []
    errors = []
    inserted = 0

    for idx, r in enumerate(rows, start=2):
        if len(r) < 11:
            errors.append(f"Baris {idx}: Kolom tidak lengkap.")
            continue

        hari, jam_mulai, jam_selesai, kode_ruang, mk, kelas, \
        dosen, semester, kode_mk, tgl_mulai, tgl_selesai = r

        kode_ruang_key = kode_ruang.upper().strip()
        hari_key = hari.lower().strip()

        if kode_ruang_key not in ruangan_map:
            errors.append(f"Baris {idx}: Ruangan '{kode_ruang}' tidak ditemukan.")
            continue

        if hari_key not in HARI_MAP:
            errors.append(f"Baris {idx}: Hari '{hari}' tidak valid.")
            continue

        batch_values.append((
            hari_key,
            jam_mulai,
            jam_selesai,
            ruangan_map[kode_ruang_key],
            mk,
            kelas,
            dosen or None,
            semester,
            kode_mk,
            tgl_mulai or None,
            tgl_selesai or None,
            HARI_MAP[hari_key],
            fak
        ))

        inserted += 1

    if batch_values:
        batch_insert_jadwal(batch_values)

    # Refresh MV
    try:
        q("REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kuliah_per_hari", commit=True)
    except:
        q("REFRESH MATERIALIZED VIEW mv_kuliah_per_hari", commit=True)

    if errors:
        flash(f"{inserted} berhasil, {len(errors)} gagal.", "error" if inserted == 0 else "success")
        for e in errors[:10]:
            flash(e, "error")
    else:
        flash(f"Berhasil mengimport {inserted} baris.", "success")

    return redirect(url_for("ngadmin_jadwal", _import=1))

@app.route("/ngadmin/jadwal/export")
@login_required
def ngadmin_jadwal_export():
    fak = session["fakultas_id"]
    rows = get_jadwal_export_rows(fak)
    output = generate_jadwal_export_excel(rows)

    return send_file(
        output,
        download_name="jadwal_export.xlsx",
        as_attachment=True
    )

@app.route("/ngadmin/booking")
@login_required
def ng_booking():
    fak = session.get("fakultas_id")
    page = int(request.args.get("page", 1))
    per_page = 25
    offset = (page - 1) * per_page

    total = get_total("v_booking_group", "fakultas_ruangan_id=%s", [fak])
    rows = get_booking_page(fak, per_page, offset)
    data = serialize_booking_rows(rows)

    return view("unsoed/booking.html",
        data=data,
        page=page,
        per_page=per_page,
        start=(offset + 1 if total else 0),
        end=min(offset + per_page, total),
        total=total
    )

# == RUN SERVER ==
if __name__ == "__main__":
    app.run(debug=True, port=5000, host="0.0.0.0")