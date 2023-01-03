pragma solidity ^0.6.6;

import "./Roles.sol";
// import "./online clinic dapp.sol";

contract Patient {
    using Roles for Roles.Role;

    // Roles.Role private admin;
    // Roles.Role private doctor;
    // Roles.Role private patient;

    // for the store the impage in ipfs

    string public name = "sohail";
    uint256 public imageCount = 0;
    mapping(uint256 => Image) public images;

    struct Image {
        uint256 id;
        string hash;
        string description;
        uint256 tipAmount;
        address payable author;
    }

    event ImageCreated(
        uint256 id,
        string hash,
        string description,
        uint256 tipAmount,
        address payable author
    );

    event ImageTipped(
        uint256 id,
        string hash,
        string description,
        uint256 tipAmount,
        address payable author
    );

    //for the Documents upload ;

    // string public name = "Decentragram";
    uint256 public DocumentCount = 0;
    mapping(uint256 => Document) public Documents;

    struct Document {
        uint256 id;
        string hash;
        string description;
        //   uint tip Amount;
        address payable author;
    }

    struct personalInformation {
        string passportnumber;
        string prefix;
        string gender;
        string DOF;
        string nationality;
        string Occupation;
        string BloodGroup;
        string fathername;
        string Mothername;
        string NamewithMiddlename;
        string Month;
        string Countryofbirth;
        string Religion;
        string socialsecurityNumber;
        string year;
        string provinceOfBirth;
        string educationlevel;
        string HistoryofAllergy;
         
    }

    function personalInformation11(
        uint256 _passportnumber,
        string memory _prefix,
        string memory _gender,
        uint256 _DOF,
        string memory _nationality,
        string memory _Occupation,
        string memory _BloodGroup,
        string memory _firstName,
        string memory _Mothername,
        string memory _NamewithMiddlename,
        string memory _Month,
        string memory _Countryofbirth,
        string memory _Religion,
        string memory _socialsecurityNumber,
        uint256 _year,
        string memory _provinceOfBirth
          ) public {}

    struct AdressInformation {
        string AddressThailand;
        string Moo;
        string Soi;
        string Street;
        string Subdistrict;
        string District;
        string Province;
        uint256 Zipcode;
        uint256 Mobiletelephone;
        uint256 Hometelephone;
        uint256 Officetelephone;
        string Email;
    }

    function adressInformation(
        string memory _AddressThailand,
        string memory _Moo,
        string memory _Soi,
        string memory _Street,
        string memory _Subdistrict,
        string memory _District,
        string memory _Province,
        uint256 _Zipcode,
        uint256 _Mobiletelephone,
        uint256 Hometelephone,
        string memory _email
    ) public {}

    struct EmergencyContactInformation {
        string Emergencycontactperson;
        string Relation;
        string Mobiletelephone1;
        string Mobiletelephone2;
        string Hometelephone;
        string Officetelephone;
        string Email;
    }

    function EmergencyContactInformation2(
        string memory _EmergencyContactperson,
        string memory _Relation,
        string memory _Mobiletelephone1,
        string memory _Mobiletelephone2,
        string memory _Hometelephone,
        string memory _Officetelephone,
        string memory _email
    ) public {}

    function uploadDocument(string memory _imgHash, string memory _description)
        public
        uploadImageRequirements(_imgHash, _description)
    {
        imageCount++;
        images[imageCount] = Image(
            imageCount,
            _imgHash,
            _description,
            0,
            msg.sender
        );
        emit ImageCreated(imageCount, _imgHash, _description, 0, msg.sender);
    }

    modifier uploadImageRequirements(
        string memory _imgHash,
        string memory _description
    ) {
        require(bytes(_imgHash).length > 0);
        require(bytes(_description).length > 0);
        require(msg.sender != address(0x0));
        _;
    }

    function uploadImage(string memory _imgHash, string memory _description)
        public
        uploadImageRequirements(_imgHash, _description)
    {
        imageCount++;
        images[imageCount] = Image(
            imageCount,
            _imgHash,
            _description,
            0,
            msg.sender
        );
        emit ImageCreated(imageCount, _imgHash, _description, 0, msg.sender);
    }

    function tipImageOwner(uint256 _id) public payable {
        require(_id > 0 && _id <= imageCount);
        Image memory _image = images[_id];
        address payable _author = _image.author;
        _author.transfer(msg.value);
        _image.tipAmount = _image.tipAmount + msg.value;
        images[_id] = _image;
        emit ImageTipped(
            _image.id,
            _image.hash,
            _image.description,
            _image.tipAmount,
            _image.author
        );
    }

    // image upload smart contract function end

    struct Doctor {
        string drHash;
    }

    struct Patient {
        string patHash;
    }

    mapping(address => Doctor) Doctors;
    mapping(address => Patient) Patients;

    // address[] public Dr_ids;
    // address[] public Patient_ids;

    address accountId;
    address admin_id;
    address get_patient_id;
    address get_dr_id;

    address private owner;
    //   mapping (address => doctor) private doctors;

    // mapping (address => patient) private patients; //mapping patients to their addresses
    mapping(address => mapping(address => uint16)) private patientToDoctor; //patients and list of doctors allowed access to
    mapping(address => mapping(bytes32 => uint16)) private patientToFile; //files mapped to patients
    //   mapping (address => files[]) private patientFiles;
    //   mapping (address => hospital) private hospitals;
    //   mapping (address => insuranceComp) insuranceCompanies;
    // mapping (address => doctorAddedFiles[]) private doctorAddedPatientFiles;
    // mapping (address => doctorOfferedConsultation[]) private doctorOfferedConsultationList;
    mapping(address => ID) patient_adhaar_info;
    mapping(address => ID) doctor_adhaar_info;
    mapping(uint256 => string) public records;

    struct ID {
        address id;
        // uint64 adhaar_number;
        string name;
        string DOB;
        uint24 pincode;
    }

    function addHospital(
        address _id,
        string memory _name,
        string memory _location
    ) public {
        // hospital memory h = hospitals[_id];
        // require(!(h.id > address(0x0)));
        // hospitals[_id] = hospital({id:_id, name:_name, location:_location});
    }

    // ipfs network

    function addPatientIDInfo(
        address _pat,
        string memory _name,
        string memory _DOB,
        uint24 _pincode,
        uint64 _ID_number
    ) public {
        // ID memory a = patient_ID_info[_pat];
        // require(ID_number == 0);
        // patient_ID_info[_pat] = ID({
        // id: _pat,
        //     pincode: _pincode,
        //     name: _name,
        //     DOB: _DOB,
        //     ID_number: _ID_number
        // });
    }

    /////////// VARIABLES ///////////////////

    // address
    // address owner;

    //identity
    string private firstName;
    string private lastName;
    string private IID;

    //birthday
    string private bdate;

    //contract
    string private email;
    string private phone;
    string private zip;
    string private city;

    // keys
    string encryption_key;

    /////////// VARIABLES END ///////////////

    /////////// DECLARATIONS ////////////

    struct medical_record {
        bool is_uid_generated;
        uint256 record_id;
        string record_msg;
        uint256 record_status; // 0-Created, 1-Deleted, 2-Changed, 3-Queried, 4-Printed, 5-Copied
        // all images files etc will be stored here
        string record_details;
        address patient_address;
        uint256 record_time;
        // address doctor;
        // uint doctor_time;

        address audit;
        uint256 audit_time;
    }

    //  struct doctor {
    //     string name;
    //     uint age;
    //     address[] patientAccessList;
    // }

    uint256 creditPool;

    // address[] public patientList;
    // address[] public doctorList;

    // mapping (address => patient) patientInfo;
    // mapping (address => doctor) doctorInfo;
    mapping(address => address) Empty;
    // might not be necessary
    mapping(address => string) patientRecords;

    /////////// DECLARATIONS END////////

    ////////// MAPPINGS ////////////////

    mapping(address => medical_record) public record_mapping;
    mapping(address => bool) public doctors;
    mapping(address => bool) public audits;

    ////////// MAPPINGS END ////////////

    ////////// MODIFIERS ///////////////////

    // initiate  patient data
    constructor(
        string memory _firstName,
        string memory _lastName,
        string memory _IID,
        string memory _bdate,
        string memory _email,
        string memory _phone,
        string memory _zip,
        string memory _city,
        string memory _encryption_key
    ) public {
        owner = msg.sender;
        firstName = _firstName;
        lastName = _lastName;
        IID = _IID;
        bdate = _bdate;
        email = _email;
        phone = _phone;
        zip = _zip;
        city = _city;
        encryption_key = _encryption_key;
    }

    // make the patient using this contractt only owner
    modifier only_owner() {
        require(owner == msg.sender);
        _;
    }

    ////////// MODIFIERS END////////////////

    ////////////// EVENTS ////////////////////
    event event_start_visit(
        address record_unique_id,
        string record_msg,
        uint256 record_status,
        uint256 record_time
    );

    event event_add_doctor(
        string return_msg,
        address doctor_address,
        uint256 record_time
    );
    event event_remove_doctor(
        string return_msg,
        address doctor_address,
        uint256 record_time
    );
    event event_add_audit(
        string return_msg,
        address audit_address,
        uint256 record_time
    );
    event event_remove_audit(
        string return_msg,
        address audit_address,
        uint256 record_time
    );
    event event_patient_print(
        string record_msg,
        uint256 record_status,
        uint256 record_time
    );
    event event_patient_delete(
        string record_msg,
        uint256 record_status,
        uint256 record_time
    );
    event event_doctor_delete(
        string record_msg,
        uint256 record_status,
        uint256 record_time
    );
    event event_doctor_print(
        string record_msg,
        uint256 record_status,
        uint256 record_time
    );
    event event_doctor_copy(
        string record_msg,
        uint256 record_status,
        uint256 record_time
    );
    event event_doctor_query(
        string record_msg,
        uint256 record_status,
        uint256 record_time
    );
    event event_doctor_update(
        string record_msg,
        uint256 record_status,
        uint256 record_time
    );

    ////////////// EVENTS END////////////////

    ////////// PATIENT FUNCTIONS //////////////

    // create a medical record with unique id
    // patient makes appointment
    function start_visit(uint256 _time) public only_owner returns (address) {
        address unique_id = address(
            uint256(sha256(abi.encodePacked(msg.sender, now)))
        );
        record_mapping[unique_id].is_uid_generated = true;
        record_mapping[unique_id].record_id = uint256(unique_id);
        record_mapping[unique_id].record_msg = "New Medical Record is created";
        record_mapping[unique_id].record_status = 0;

        record_mapping[unique_id].record_details = "Visit initiate";

        record_mapping[unique_id].patient_address = msg.sender;
        record_mapping[unique_id].record_time = _time;
        emit event_start_visit(
            unique_id,
            record_mapping[unique_id].record_msg,
            record_mapping[unique_id].record_status,
            record_mapping[unique_id].record_time
        );
        return unique_id;
    }

    // give permissions to doctors -- authorize doctors
    function addDoctors(address _doctor_address)
        public
        only_owner
        returns (string memory)
    {
        // if doctor is not authorized yet
        if (!doctors[_doctor_address]) {
            doctors[_doctor_address] = true;
        }
        emit event_add_doctor("A doctor is added.", _doctor_address, now);
        return "A doctor is added.";
    }

    // take back permissions -- delete authorization of doctors
    function removeDoctors(address _doctor_address)
        public
        only_owner
        returns (string memory)
    {
        // if doctor is authorized
        if (doctors[_doctor_address]) {
            doctors[_doctor_address] = false;
        }
        emit event_remove_doctor("A doctor is removed.", _doctor_address, now);
        return "A doctor is removed.";
    }

    // Give permissions to audits
    // give permissions to doctors -- authorize doctors
    function addAudit(address _audit_address)
        public
        only_owner
        returns (string memory)
    {
        // if doctor is not authorized yet
        if (!audits[_audit_address]) {
            audits[_audit_address] = true;
        }
        emit event_add_audit("An audit is added.", _audit_address, now);
        return "An audit is added.";
    }

    // take back permissions -- delete authorization of doctors
    function removeAudit(address _audit_address)
        public
        only_owner
        returns (string memory)
    {
        // if doctor is authorized
        if (audits[_audit_address]) {
            audits[_audit_address] = false;
        }
        emit event_remove_audit("An audit is removed.", _audit_address, now);
        return "A doctor is removed.";
    }

    // function get_patient_list() public view returns(address[] memory ){
    //     return patientList;
    // }

    // function get_doctor_list() public view returns(address[] memory ){
    //     return doctorList;
    // }

    //   function addDrInfo(address dr_id, string memory _drInfo_hash) public {
    //     require(admin.has(msg.sender), "");

    //     Doctor storage drInfo = Doctors[msg.sender];
    //     drInfo.drHash = _drInfo_hash;
    //     Dr_ids.push(msg.sender);

    //     doctor.add(dr_id);
    // }

    function addDoctorIDInfo(
        address _doc,
        string memory _name,
        string memory _DOB,
        uint24 _pincode,
        uint64 _id
    ) public {
        // adhaar memory a = doctor_adhaar_info[_doc];
        // require(a.adhaar_number == 0);
        // doctor_adhaar_info[_doc] = adhaar({
        //     id: _doc,
        //     pincode: _pincode,
        //     name: _name,
        //     DOB: _DOB,
        //     adhaar_number: _adhaar_number
        // });
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}