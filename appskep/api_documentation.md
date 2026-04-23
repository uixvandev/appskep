# 📱 AppSkep API Documentation for iOS Developer

**Base URL:** `https://your-server.com/api/v1`  
**Content-Type:** `application/json`  
**Auth:** Bearer Token di header `Authorization: Bearer <token>`  
**Last Updated:** 2026-04-22

---

## 📌 Response Wrapper (Semua Endpoint)

Semua response dibungkus dalam format berikut:

### ✅ Success
```json
{
  "success": true,
  "message": "...",
  "data": { ... }
}
```

### ❌ Error
```json
{
  "success": false,
  "message": "...",
  "error": "detail error message"
}
```

**HTTP Status Codes:**
| Code | Keterangan |
|------|-----------|
| 200 | OK |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Internal Server Error |

---

## 🔐 1. Auth

### POST `/auth/register`
> **Auth:** Tidak perlu

**Request Body:**
```json
{
  "name": "Budi Santoso",
  "email": "budi@student.com",
  "password": "password123",
  "role": "student",
  "phone_number": "081234567890",
  "gender": "male"
}
```
| Field | Type | Required | Keterangan |
|-------|------|----------|-----------|
| name | string | ✅ | Min 2 karakter |
| email | string | ✅ | Format email valid |
| password | string | ✅ | Min 6 karakter |
| role | string | ❌ | `student` (default) atau `admin` |
| phone_number | string | ❌ | |
| date_of_birth | string | ❌ | Format: `YYYY-MM-DD` |
| gender | string | ❌ | `male` atau `female` |
| educational_institution | string | ❌ | |
| profession | string | ❌ | |
| address | string | ❌ | |
| province | string | ❌ | |
| city | string | ❌ | |

**Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1...",
    "user": {
      "email": "budi@student.com",
      "name": "Budi Santoso",
      "role": "student",
      "phone_number": "081234567890",
      "date_of_birth": null,
      "gender": "male",
      "educational_institution": null,
      "profession": null,
      "address": null,
      "province": null,
      "city": null,
      "created_at": "2026-04-22T10:00:00+07:00",
      "updated_at": "2026-04-22T10:00:00+07:00"
    }
  }
}
```

### POST `/auth/login`
> **Auth:** Tidak perlu

**Request Body:**
```json
{
  "email": "budi@student.com",
  "password": "password123"
}
```

**Response (200):** Sama dengan register response.

---

## 👤 2. Users

### GET `/users/profile`
> **Auth:** Bearer Token

**Request Body:** Tidak ada

**Response (200):**
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "email": "budi@student.com",
    "name": "Budi Santoso",
    "role": "student",
    "phone_number": "081234567890",
    "date_of_birth": "2000-01-15",
    "gender": "male",
    "educational_institution": "Universitas Indonesia",
    "profession": "Mahasiswa",
    "address": "Jl. Merdeka No. 1",
    "province": "DKI Jakarta",
    "city": "Jakarta Pusat",
    "created_at": "2026-04-22T10:00:00+07:00",
    "updated_at": "2026-04-22T10:00:00+07:00"
  }
}
```
> ⚠️ **Catatan:** Field opsional yang belum diisi akan bernilai `null`, BUKAN dihilangkan.

### PUT `/users/profile`
> **Auth:** Bearer Token

**Request Body:** (semua field opsional)
```json
{
  "name": "Budi Santoso Updated",
  "phone_number": "081234567890",
  "date_of_birth": "2000-01-15",
  "gender": "male",
  "educational_institution": "Universitas Indonesia",
  "profession": "Mahasiswa",
  "address": "Jl. Merdeka No. 1",
  "province": "DKI Jakarta",
  "city": "Jakarta Pusat"
}
```

**Response (200):** Sama dengan GET profile response.

### PUT `/users/change-password`
> **Auth:** Bearer Token

**Request Body:**
```json
{
  "current_password": "password123",
  "new_password": "newpassword456"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

---

## 🏫 3. Kelas

### GET `/kelas`
> **Auth:** Tidak perlu  
> **Query Params:** `?page=1&limit=10`

**Response (200):**
```json
{
  "success": true,
  "message": "Kelas retrieved successfully",
  "data": {
    "data": [
      {
        "class_code": "KELAS-UKOM-2024",
        "name": "Kelas UKOM 2024",
        "description": "Kelas persiapan UKOM keperawatan tahun 2024",
        "price": 350000,
        "is_active": 1
      }
    ],
    "page": 1,
    "limit": 10,
    "total_items": 1,
    "total_pages": 1
  }
}
```
> ⚠️ **Catatan:** Default hanya menampilkan kelas aktif (`is_active=1`). Admin bisa pakai `?show_all=true`.

### GET `/kelas/:class_code`
> **Auth:** Tidak perlu

**Response (200):**
```json
{
  "success": true,
  "message": "Kelas retrieved successfully",
  "data": {
    "class_code": "KELAS-UKOM-2024",
    "name": "Kelas UKOM 2024",
    "description": "Kelas persiapan UKOM keperawatan tahun 2024",
    "price": 350000,
    "is_active": 1
  }
}
```

### GET `/kelas/:class_code/pakets`
> **Auth:** Tidak perlu

**Response (200):**
```json
{
  "success": true,
  "message": "Pakets retrieved successfully",
  "data": [
    {
      "package_code": "PKT-KLINIK-01",
      "name": "Paket Keperawatan Klinik",
      "description": "Soal-soal UKOM bidang keperawatan klinik",
      "duration": 90,
      "total_questions": 10,
      "is_active": 1
    }
  ]
}
```
> ⚠️ **Catatan:** Hanya paket aktif yang ditampilkan untuk iOS. `total_questions` = jumlah soal aktif di paket.

---

## 📦 4. Paket

### GET `/pakets`
> **Auth:** Bearer Token  
> **Query Params:** `?page=1&limit=10`

**Response (200):** Paginated list of Paket (format sama dengan kelas paginated).

### GET `/pakets/:package_code`
> **Auth:** Bearer Token

**Response (200):**
```json
{
  "success": true,
  "message": "Paket retrieved successfully",
  "data": {
    "package_code": "PKT-KLINIK-01",
    "name": "Paket Keperawatan Klinik",
    "description": "Soal-soal UKOM bidang keperawatan klinik",
    "duration": 90,
    "is_active": 1
  }
}
```

### GET `/pakets/:package_code/soals`
> **Auth:** Bearer Token

**Response (200):**
```json
{
  "success": true,
  "message": "Soals retrieved successfully",
  "data": [
    {
      "question_code": "Q-KLINK-001",
      "category_name": "Keperawatan Klinik",
      "question": "Seorang pasien berusia 45 tahun...",
      "explanation": "Digoxin memiliki rentang terapeutik...",
      "is_active": 1,
      "pilihan_jawaban": [
        {
          "options_id": 1,
          "question_code": "Q-KLINK-001",
          "option_text": "Tekanan darah",
          "is_correct": false
        },
        {
          "options_id": 2,
          "question_code": "Q-KLINK-001",
          "option_text": "Denyut nadi",
          "is_correct": true
        }
      ]
    }
  ]
}
```

---

## 📝 5. Kategori Soal

### GET `/kategori-soal`
> **Auth:** Tidak perlu

**Response (200):**
```json
{
  "success": true,
  "message": "Kategori retrieved successfully",
  "data": [
    {
      "category_name": "Keperawatan Klinik",
      "description": "Soal-soal terkait keperawatan klinik",
      "created_at": "2026-04-22T10:00:00+07:00",
      "updated_at": "2026-04-22T10:00:00+07:00"
    }
  ]
}
```

### GET `/kategori-soal/:category_name`
> **Auth:** Tidak perlu

**Response (200):** Single KategoriSoal object.

---

## 🛒 6. Order

### POST `/orders`
> **Auth:** Bearer Token

**Request Body:**
```json
{
  "class_code": "KELAS-UKOM-2024"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Order created successfully",
  "data": {
    "order_number": "appskep1",
    "email": "budi@student.com",
    "class_code": "KELAS-UKOM-2024",
    "status": "pending",
    "payment_reference": "ORDER-budi@student.com-1709000000",
    "gross_amount": 350000,
    "payment_type": null,
    "transaction_id": null,
    "snap_token": "abc123-snap-token",
    "snap_redirect_url": "https://app.sandbox.midtrans.com/snap/v3/redirection/abc123",
    "created_at": "2026-04-22T10:00:00+07:00",
    "updated_at": "2026-04-22T10:00:00+07:00",
    "kelas": {
      "class_code": "KELAS-UKOM-2024",
      "name": "Kelas UKOM 2024",
      "description": "...",
      "price": 350000,
      "is_active": 1
    }
  }
}
```

### GET `/orders/my-orders`
> **Auth:** Bearer Token  
> **Query Params:** `?page=1&limit=10`

**Response (200):** Paginated list of Order objects.

### GET `/orders/:order_number`
> **Auth:** Bearer Token

**Response (200):** Single Order object (format sama dengan create order response data).

### GET `/orders/find/:identifier`
> **Auth:** Bearer Token  
> Cari order berdasarkan `order_number` ATAU `payment_reference`.

**Response (200):** Single Order object.

### GET `/orders/check-access/:class_code`
> **Auth:** Bearer Token

**Response (200):**
```json
{
  "success": true,
  "message": "Access check completed",
  "data": {
    "has_access": true
  }
}
```

---

## 📋 7. Try Out

### POST `/tryouts/start`
> **Auth:** Bearer Token

**Request Body:**
```json
{
  "order_number": "appskep1",
  "class_package_id": 1
}
```
| Field | Type | Required | Keterangan |
|-------|------|----------|-----------|
| order_number | string | ✅ | Nomor order yang sudah `success` |
| class_package_id | int | ✅ | ID dari tabel `kelaspaket` |

**Response (201):**
```json
{
  "success": true,
  "message": "Try out started successfully",
  "data": {
    "tryout_code": "TO-1713765432",
    "order_number": "appskep1",
    "class_package_id": 1,
    "started_at": "2026-04-22T10:00:00+07:00",
    "status": "in_progress",
    "paket_name": "Paket Keperawatan Klinik"
  }
}
```

### GET `/tryouts/:tryout_code`
> **Auth:** Bearer Token

**Response (200):**
```json
{
  "success": true,
  "message": "Try out detail retrieved successfully",
  "data": {
    "tryout_code": "TO-1713765432",
    "order_number": "appskep1",
    "class_package_id": 1,
    "package_code": "PKT-KLINIK-01",
    "started_at": "2026-04-22T10:00:00+07:00",
    "finished_at": null,
    "score": null,
    "paket": {
      "package_code": "PKT-KLINIK-01",
      "name": "Paket Keperawatan Klinik",
      "description": "...",
      "duration": 90,
      "total_questions": 10,
      "is_active": 1
    },
    "soals": [
      {
        "question_code": "Q-KLINK-001",
        "category_name": "Keperawatan Klinik",
        "question": "...",
        "explanation": "...",
        "is_active": 1,
        "pilihan_jawaban": [
          {
            "options_id": 1,
            "question_code": "Q-KLINK-001",
            "option_text": "Tekanan darah",
            "is_correct": false
          }
        ],
        "user_answer": null
      }
    ],
    "answers": [
      {
        "tryout_code": "TO-1713765432",
        "options_id": 2,
        "pilihan_jawaban": {
          "options_id": 2,
          "question_code": "Q-KLINK-001",
          "option_text": "Denyut nadi",
          "is_correct": true
        }
      }
    ]
  }
}
```

### POST `/tryouts/submit-answer`
> **Auth:** Bearer Token

**Request Body:**
```json
{
  "tryout_code": "TO-1713765432",
  "options_id": 2
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Answer submitted successfully"
}
```

### POST `/tryouts/submit-all`
> **Auth:** Bearer Token

**Request Body:**
```json
{
  "tryout_code": "TO-1713765432",
  "answers": [
    { "options_id": 2 },
    { "options_id": 6 },
    { "options_id": 11 }
  ]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "All answers submitted successfully"
}
```

### POST `/tryouts/finish`
> **Auth:** Bearer Token

**Request Body:**
```json
{
  "tryout_code": "TO-1713765432"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Try out finished successfully",
  "data": {
    "tryout_code": "TO-1713765432",
    "email": "budi@student.com",
    "paket_name": "Paket Keperawatan Klinik",
    "total_questions": 10,
    "answered_questions": 10,
    "correct_answers": 7,
    "wrong_answers": 3,
    "unanswered": 0,
    "score": 70.0,
    "percentage": 70.0,
    "grade": "B",
    "started_at": "2026-04-22T10:00:00+07:00",
    "finished_at": "2026-04-22T11:15:00+07:00",
    "duration_minutes": 75,
    "passed": true,
    "passing_score": 60
  }
}
```

### GET `/tryouts/:tryout_code/progress`
> **Auth:** Bearer Token

**Response (200):**
```json
{
  "success": true,
  "message": "Try out progress retrieved successfully",
  "data": {
    "tryout_code": "TO-1713765432",
    "total_questions": 10,
    "answered_questions": 5,
    "progress_percentage": 50,
    "is_finished": false,
    "score": null
  }
}
```

### GET `/tryouts/history`
> **Auth:** Bearer Token  
> **Query Params:** `?page=1&limit=10`

**Response (200):** Paginated list of TryOut objects.

### GET `/tryouts/:tryout_code/results`
> **Auth:** Bearer Token

**Response (200):** Sama dengan finish try out response data (`TryOutResults`).

### GET `/tryouts/:tryout_code/pembahasan`
> **Auth:** Bearer Token

**Response (200):**
```json
{
  "success": true,
  "message": "Pembahasan retrieved successfully",
  "data": {
    "tryout_code": "TO-1713765432",
    "questions": [
      {
        "question_code": "Q-KLINK-001",
        "question": "...",
        "user_answer": {
          "options_id": 2,
          "option_text": "Denyut nadi",
          "is_correct": true
        },
        "correct_answer": {
          "options_id": 2,
          "option_text": "Denyut nadi",
          "is_correct": true
        },
        "all_options": [
          { "options_id": 1, "option_text": "Tekanan darah", "is_correct": false },
          { "options_id": 2, "option_text": "Denyut nadi", "is_correct": true },
          { "options_id": 3, "option_text": "Suhu tubuh", "is_correct": false },
          { "options_id": 4, "option_text": "Saturasi oksigen", "is_correct": false }
        ],
        "explanation": "Digoxin memiliki rentang terapeutik...",
        "is_user_correct": true,
        "category": "Keperawatan Klinik"
      }
    ],
    "summary": {
      "correct_by_category": { "Keperawatan Klinik": 5 },
      "wrong_by_category": { "Keperawatan Klinik": 2 }
    }
  }
}
```
> ⚠️ `user_answer` bisa `null` jika soal belum dijawab.

### GET `/tryouts/check-retry`
> **Auth:** Bearer Token  
> **Query Params:** `?order_number=appskep1&class_package_id=1`

**Response (200):**
```json
{
  "success": true,
  "message": "Retry eligibility checked successfully",
  "data": {
    "attempt_number": 1,
    "total_attempts": 1,
    "max_attempts": 0,
    "can_retry": true,
    "best_score": 70.0,
    "has_passed": true
  }
}
```
> `max_attempts: 0` artinya unlimited retry.

---

## 🤖 8. Chatbot

### POST `/chat/send`
> **Auth:** Bearer Token

**Request Body:**
```json
{
  "message": "Mengapa jawaban yang benar adalah denyut nadi?",
  "question_code": "Q-KLINK-001"
}
```
| Field | Type | Required | Keterangan |
|-------|------|----------|-----------|
| message | string | ✅ | Pertanyaan user |
| question_code | string | ✅ | Kode soal untuk konteks (kirim `""` untuk chat umum) |

**Response (200):**
```json
{
  "success": true,
  "message": "Message sent successfully",
  "data": {
    "id": 1,
    "message": "Mengapa jawaban yang benar adalah denyut nadi?",
    "response": "Karena digoxin memiliki efek...",
    "question_code": "Q-KLINK-001",
    "soal_context": {
      "question_code": "Q-KLINK-001",
      "question": "Seorang pasien berusia 45 tahun...",
      "explanation": "Digoxin memiliki rentang...",
      "options": [
        { "options_id": 1, "option_text": "Tekanan darah", "is_correct": false },
        { "options_id": 2, "option_text": "Denyut nadi", "is_correct": true }
      ]
    },
    "created_at": "2026-04-22T10:30:00+07:00"
  }
}
```
> `soal_context` akan `null` jika `question_code` kosong.

### GET `/chat/history`
> **Auth:** Bearer Token  
> **Query Params:** `?page=1&limit=20` atau `?question_code=Q-KLINK-001&page=1&limit=20`

**Response (200):**
```json
{
  "success": true,
  "message": "Chat history retrieved successfully",
  "data": {
    "messages": [
      {
        "id": 1,
        "message": "...",
        "response": "...",
        "question_code": "Q-KLINK-001",
        "soal_context": null,
        "created_at": "2026-04-22T10:30:00+07:00"
      }
    ],
    "page": 1,
    "limit": 20,
    "total_items": 1,
    "total_pages": 1
  }
}
```

### GET `/chat/soal/:question_code/context`
> **Auth:** Bearer Token

**Response (200):**
```json
{
  "success": true,
  "message": "Soal context retrieved successfully",
  "data": {
    "question_code": "Q-KLINK-001",
    "question": "...",
    "explanation": "...",
    "options": [
      { "options_id": 1, "option_text": "...", "is_correct": false }
    ]
  }
}
```

### DELETE `/chat/history`
> **Auth:** Bearer Token — Hapus semua chat history user.

### DELETE `/chat/history/:id`
> **Auth:** Bearer Token — Hapus satu message berdasarkan ID.

**Response (200):**
```json
{ "success": true, "message": "Chat history deleted successfully" }
```

---

## 🔔 9. Notifications

### GET `/notifications`
> **Auth:** Bearer Token  
> **Query Params:** `?page=1&limit=20`

**Response (200):**
```json
{
  "success": true,
  "message": "Notifications retrieved successfully",
  "data": {
    "notifications": [
      {
        "notification_id": 1,
        "title": "Pembayaran Berhasil",
        "description": "Pembayaran untuk Kelas UKOM 2024 telah berhasil.",
        "order_number": "appskep1",
        "is_read": false,
        "created_at": "2026-04-22T10:00:00+07:00",
        "updated_at": "2026-04-22T10:00:00+07:00",
        "order_details": {
          "order_number": "appskep1",
          "kelas_name": "Kelas UKOM 2024",
          "status": "success",
          "gross_amount": 350000
        }
      }
    ],
    "page": 1,
    "limit": 20,
    "total_items": 1,
    "total_pages": 1,
    "unread_count": 1
  }
}
```
> `order_number` dan `order_details` bisa `null` jika notifikasi tidak terkait order.

### GET `/notifications/unread-count`
> **Auth:** Bearer Token

**Response (200):**
```json
{
  "success": true,
  "message": "Unread count retrieved successfully",
  "data": {
    "unread_count": 3
  }
}
```

### PUT `/notifications/:id/read`
> **Auth:** Bearer Token — Mark single notification as read.

**Response (200):**
```json
{ "success": true, "message": "Notification marked as read" }
```

### DELETE `/notifications/:id`
> **Auth:** Bearer Token

**Response (200):**
```json
{ "success": true, "message": "Notification deleted successfully" }
```

---

## 💳 10. Payment

### POST `/payment/simulate` *(Development Only)*
> **Auth:** Tidak perlu

**Request Body:**
```json
{
  "order_number": "appskep1",
  "action": "success"
}
```
| action | Keterangan |
|--------|-----------|
| `success` | Simulasi pembayaran berhasil |
| `pending` | Simulasi pembayaran pending |
| `failed` | Simulasi pembayaran gagal |

**Response (200):**
```json
{
  "success": true,
  "message": "Payment simulated successfully",
  "data": {
    "order_number": "appskep1",
    "new_status": "success"
  }
}
```

---

## ⚠️ Perubahan Penting (Database Changes)

### 1. Field `is_active` (INTEGER, bukan BOOLEAN)
Entitas berikut menggunakan `is_active` sebagai **integer** (`1` = aktif, `0` = nonaktif):
- **Kelas** — `is_active: 1 | 0`
- **Paket** — `is_active: 1 | 0`
- **Soal** — `is_active: 1 | 0`

### 2. Soft Delete → Deactivation
- `DELETE` pada Kelas, Paket, dan Soal **TIDAK menghapus data**, hanya mengubah `is_active` ke `0`.
- Endpoint reactivation tersedia di:
  - `PUT /kelas/:class_code/activate` (Admin)
  - `PUT /pakets/:package_code/activate` (Admin)
  - `PUT /soals/:question_code/activate` (Admin)

### 3. iOS Filtering
- **GET list endpoints** secara default hanya mengembalikan data **aktif** (`is_active=1`).
- Paket dalam kelas (`/kelas/:code/pakets`) secara otomatis filter yang aktif saja.

### 4. Try Out Historical Data
- Try out history tetap dapat diakses meskipun paket/soal sudah dinonaktifkan.
- Data snapshot disimpan saat try out selesai untuk menjaga integritas data historis.
