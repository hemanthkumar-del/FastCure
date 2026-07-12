# FastCure Firestore Database Schemas

This document defines the schemas and structures utilized across FastCure's Cloud Firestore collections.

---

## 📂 Database Collections Diagram

```
Firestore Root/
├── doctors/ (Collection)
│   └── {doctorId} (Document)
├── patients/ (Collection)
│   └── {patientId} (Document)
├── appointments/ (Collection)
│   └── {appointmentId} (Document)
├── medicines/ (Collection)
│   └── {medicineId} (Document)
├── prescriptions/ (Collection)
│   └── {prescriptionId} (Document)
└── bills/ (Collection)
    └── {billId} (Document)
```

---

## 🗄️ Collections Detail Specification

### 1. `doctors` collection
```json
{
  "doctorId": "doc_123",
  "fullName": "Dr. Sarah Jenkins",
  "email": "sarah@fastcure.com",
  "phoneNumber": "1234567890",
  "specialization": "Cardiologist",
  "qualification": "MD, FACC",
  "experience": 12,
  "consultationFee": 150.0,
  "hospitalName": "Metro Clinic",
  "department": "Cardiology",
  "bio": "Specialist in invasive cardiology.",
  "profileImage": "https://storage.googleapis.com/.../img.png",
  "availableDays": ["Monday", "Wednesday", "Friday"],
  "availableTimeSlots": ["09:00 AM", "10:30 AM", "02:00 PM"],
  "status": "Active",
  "createdAt": "2026-07-12T10:00:00Z",
  "updatedAt": "2026-07-12T10:00:00Z"
}
```

### 2. `patients` collection
```json
{
  "patientId": "pat_889",
  "fullName": "John Doe",
  "email": "john.doe@example.com",
  "phone": "9876543210",
  "gender": "Male",
  "dob": "1990-05-15T00:00:00Z",
  "bloodGroup": "O+",
  "address": "456 Healthcare St, NY",
  "medicalHistory": ["Hypertension", "Asthma"],
  "allergies": ["Penicillin", "Peanuts"],
  "profileImage": "https://storage.googleapis.com/.../img.png",
  "createdAt": "2026-07-12T10:00:00Z"
}
```

### 3. `appointments` collection
```json
{
  "appointmentId": "app_556",
  "doctorId": "doc_123",
  "patientId": "pat_889",
  "doctorName": "Dr. Sarah Jenkins",
  "patientName": "John Doe",
  "date": "2026-07-13T00:00:00Z",
  "time": "10:30 AM",
  "status": "Pending",
  "reason": "Routine cardiac checkup",
  "notes": "Patient requested morning slot.",
  "createdAt": "2026-07-12T10:00:00Z"
}
```

### 4. `medicines` collection
```json
{
  "medicineId": "med_112",
  "name": "Paracetamol 650mg",
  "manufacturer": "HealthLabs Ltd",
  "dosage": "1 tablet every 6 hours",
  "stock": 120,
  "price": 2.5
}
```

### 5. `prescriptions` collection
```json
{
  "prescriptionId": "pres_441",
  "doctorId": "doc_123",
  "patientId": "pat_889",
  "appointmentId": "app_556",
  "doctorName": "Dr. Sarah Jenkins",
  "patientName": "John Doe",
  "medicines": [
    {
      "medicineId": "med_112",
      "name": "Paracetamol 650mg",
      "quantity": 10,
      "instructions": "Take after meals"
    }
  ],
  "notes": "Drink plenty of water.",
  "createdAt": "2026-07-12T10:00:00Z"
}
```

### 6. `bills` collection
```json
{
  "billId": "bill_098",
  "patientId": "pat_889",
  "patientName": "John Doe",
  "appointmentId": "app_556",
  "doctorFee": 150.0,
  "medicineFee": 25.0,
  "labFee": 50.0,
  "total": 225.0,
  "paymentMethod": "UPI",
  "status": "Paid",
  "createdAt": "2026-07-12T10:00:00Z"
}
```
