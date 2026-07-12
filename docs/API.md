# FastCure API Integration & Interfaces

This document outlines the Repository interface endpoints and Gemini API configurations in FastCure.

---

## 🔑 AI Generative Chatbot API Integration

FastCure communicates directly with the **Google Gemini Pro** Beta Generative AI service using standard HTTP requests:

*   **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={API_KEY}`
*   **Method**: `POST`
*   **Request Body**:
    ```json
    {
      "contents": [
        {
          "parts": [
            {
              "text": "System context & user query"
            }
          ]
        }
      ]
    }
    ```
*   **Offline Fallback Mode**: If no internet access is available, the request automatically redirects to local symptom-checker, drug reference, and health tips dictionaries.

---

## 📦 Domain Repositories API contracts

### 1. DoctorRepository
*   `Future<List<DoctorModel>> getDoctors()`: Retrieves all active doctors.
*   `Future<void> addDoctor(DoctorModel doc)`: Creates a new doctor document.
*   `Future<void> updateDoctor(DoctorModel doc)`: Updates metadata records.
*   `Future<void> deleteDoctor(String id)`: Removes doctor entries.

### 2. PatientRepository
*   `Future<List<PatientModel>> getPatients()`: Retrieves registered patients.
*   `Future<void> addPatient(PatientModel pat)`: Creates a patient card.
*   `Future<void> updatePatient(PatientModel pat)`: Updates profiles.
*   `Future<void> deletePatient(String id)`: Deletes records.

### 3. AppointmentRepository
*   `Future<List<AppointmentModel>> getAppointments()`: Gets all scheduled appointments.
*   `Future<void> createAppointment(AppointmentModel app)`: Adds a new schedule.
*   `Future<void> approveAppointment(String id)`: Sets status to `Approved`.
*   `Future<void> rejectAppointment(String id)`: Sets status to `Rejected`.
*   `Future<void> cancelAppointment(String id)`: Sets status to `Cancelled`.

### 4. BillingRepository
*   `Future<List<BillModel>> getBills()`: Retrieves invoices.
*   `Future<void> generateBill(BillModel bill)`: Creates a bill receipt.
*   `Future<void> markAsPaid(String billId, String method)`: Sets status to `Paid` with payment type.
*   `Future<void> deleteBill(String id)`: Removes bill sheets.
