// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Sohail {
    // Patient data structure
    struct Patient {
        address patientAddress;
        string origin;
        string emergencyContact;
        string name;
        string medicalHistory;
        uint age;
    }

    // Mapping from doctor address to boolean value indicating whether they have access
    mapping(address => bool) public doctorAccess;

    // Patient data
    Patient public patient;

    // Constructor function to set patient address
    constructor() {
        patient.patientAddress = msg.sender;
    }

    // Modifier to check if the caller is the patient
    modifier onlyPatient() {
        require(msg.sender == patient.patientAddress, "Only the patient can perform this action");
        _;
    }

    // Modifier to check if the caller is a doctor with access
    modifier onlyDoctorWithAccess() {
        require(doctorAccess[msg.sender], "Doctor does not have access to patient data");
        _;
    }

    // Function for patient to enter their record
    function enterRecord(string memory _origin, string memory _emergencyContact, string memory _name, string memory _medicalHistory, uint _age) public onlyPatient {
        // Update patient data
        patient.origin = _origin;
        patient.emergencyContact = _emergencyContact;
        patient.name = _name;
        patient.medicalHistory = _medicalHistory;
        patient.age = _age;
    }

    // Function to allow patient to grant access to a doctor
    function grantAccess(address _doctor) public onlyPatient {
        doctorAccess[_doctor] = true;
    }

    // Function to allow patient to revoke access from a doctor
    function revokeAccess(address _doctor) public onlyPatient {
        doctorAccess[_doctor] = false;
    }

    // Function for doctors to access patient data
    function getPatientData() public view onlyDoctorWithAccess returns (string memory, string memory, uint) {
        // Return patient data
        return (patient.name, patient.medicalHistory, patient.age);
    }
}