# MikroTik Executive Monitoring Dashboard

Dashboard monitoring komprehensif untuk MikroTik Hotspot, dirancang untuk pelaporan eksekutif (non-teknis) dengan fokus pada penggunaan bandwidth real-time, status antrian (queue), dan kesehatan sistem.

## 🚀 Fitur Utama

- **Executive Summary**: Ringkasan bandwidth total, status link, dan jumlah klien aktif.
- **Real-time Traffic**: Grafik trafik upload/download dengan interval **5 detik** untuk akurasi tinggi.
- **System Health**: Monitor CPU Load, Temperature, Voltage, Uptime, dan RAM.
- **Zoom Safety Monitor**: Khusus memantau trafik aplikasi Zoom (via Queue Tree) beserta latency dan packet loss.
- **Organizational Usage**: Statistik penggunaan bandwidth per unit kerja (Bidang) berdasarkan Queue Tree.
- **Top Users**: 5 pengguna (queue) dengan konsumsi bandwidth tertinggi.
- **Interface Monitoring**: Grafik trafik untuk interface non-WAN (berdasarkan komentar interface).

## 🛠️ Arsitektur

Stack monitoring menggunakan Docker container:
1.  **MikroTik (SNMP Enabled)**: Sumber data.
2.  **Telegraf**: Kolektor data yang melakukan polling SNMP setiap **5 detik**.
3.  **InfluxDB (v1.8)**: Time-series database untuk menyimpan metrik.
4.  **Grafana**: Visualisasi data.

## 📂 Struktur Data InfluxDB

Telegraf dikonfigurasi untuk memecah data SNMP menjadi 3 measurement terpisah agar lebih terorganisir:

1.  `snmp_system`:
    *   Metrics: `cpu_load`, `ram_used`, `ram_total`, `temperature`, `voltage`, `uptime`, `active_dhcp_leases`.
2.  `snmp_interface`:
    *   Metrics: `ifHCInOctets`, `ifHCOutOctets`, `ifInErrors`, `ifOutErrors`, `ifOperStatus`.
    *   Tags: `ifName` (e.g., ether1), `ifAlias` (komentar interface).
3.  `mikrotik_queue_tree`:
    *   Metrics: `inner_bytes`, `inner_packets`.
    *   Tags: `name` (nama queue).

## ⚙️ Setup & Konfigurasi

### 1. Prasyarat MikroTik
Pastikan SNMP aktif di MikroTik RouterOS:
```bash
/ip snmp set enabled=yes community=monitoring
```

### 2. Konfigurasi Telegraf
File konfigurasi: `monitoring/telegraf/telegraf.conf`
*   **Agent IP**: `10.6.86.1` (Sesuaikan jika berbeda)
*   **Community**: `monitoring`
*   **Interval**: `5s` (Penting untuk grafik real-time yang halus)

### 3. Menjalankan Stack
Masuk ke direktori `monitoring` dan jalankan:
```bash
cd monitoring
docker-compose up -d
```
Restart service tertentu jika diperlukan (misal setelah ubah config):
```bash
docker-compose restart telegraf
```

### 4. Akses Dashboard
*   **Grafana**: http://localhost:3111
    *   Login default: `admin` / `admin123`
    *   Dashboard: **MikroTik Executive Dashboard** (file: `mikrotik_executive.json`)

## 📊 Bagian Dashboard

### SECTION A — SYSTEM HEALTH
*   CPU Load (Core 1)
*   Temperature & Voltage (Otomatis dikonversi ke °C dan Volt)
*   Uptime & Memory Usage

### SECTION B — EXECUTIVE SUMMARY
*   **Link Utilization**: Persentase penggunaan bandwidth terhadap kapasitas WAN.
*   **Real-time Traffic (ISP)**: Grafik Download/Upload di interface WAN (`ether1`).
*   **Active Clients**: Jumlah DHCP Leases aktif.
*   **Link Status**: Indikator UP/DOWN interface WAN.

### SECTION C — ZOOM SAFETY MONITOR
*   Memantau traffic khusus Zoom yang ditandai via Mangle & Queue Tree.
*   **Connection Quality**: Latency (ping ke gateway) dan Packet Loss.

### SECTION D & E — ORGANIZATIONAL & TOP USERS
*   **Bandwidth Usage per Bidang**: Grafik batang penggunaan bandwidth per grup (MEDIA, SEKRETARIAT, INFRA, dll).
*   **Top 5 Queues**: Tabel 5 antrian dengan penggunaan bandwidth tertinggi saat ini.

### SECTION G — INTERFACE TRAFFIC (NON-WAN)
*   Grafik trafik real-time untuk interface lain (selain WAN).
*   Label grafik menggunakan **Interface Comment** (`ifAlias`) agar mudah dibaca (misal: "To Internet", "Lokal", dll).

## 🔧 Troubleshooting Umum

### 1. Dashboard "No Data" atau Kosong
*   **Cek Koneksi Telegraf**:
    ```bash
    docker-compose logs --tail=50 telegraf
    ```
    Pastikan tidak ada error timeout atau koneksi ke 10.6.86.1.
*   **Cek Data di InfluxDB**:
    ```bash
    docker exec -it influxdb influx -database mikrotik
    > SHOW MEASUREMENTS
    ```
    Harus muncul: `snmp_system`, `snmp_interface`, `mikrotik_queue_tree`.

### 2. Grafik Putus-putus
*   Pastikan `interval` di `telegraf.conf` adalah `5s`.
*   Jika interval Telegraf lebih lambat dari refresh dashboard, grafik akan memiliki celah kosong (null).

### 3. Variabel WAN Interface Error
*   Jika panel trafik WAN error, buka Settings Dashboard -> Variables -> `wan_interface`.
*   Pastikan query `SHOW TAG VALUES FROM "snmp_interface" WITH KEY = "ifName"` mengembalikan list interface.
*   Pilih ulang interface `ether1` di dropdown dashboard.

### 4. System Health Kosong
*   Pastikan OID di `telegraf.conf` sesuai dengan tipe perangkat MikroTik Anda.
*   Cek dengan `snmpwalk` apakah perangkat mendukung OID System Health standard MikroTik.
