/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MI
contract Nation{
    address public unionDeptAddress;
    address public weaponDeptAddress;
    address public crimeDeptAddress;
    address public educationDeptAddress;
    address payable trafficDeptAddress;
    address public marriageDeptAddress;
    address public owner;

    modifier unionDeptValidation(){
        require(unionDeptAddress == msg.sender, "You are not belong to Union Council Department");
        _;
    }
    modifier weaponDeptValidation(){
        require(weaponDeptAddress == msg.sender, "You are not belong to Weapon License Department");
        _;
    }
    modifier crimeDeptValidation(){
        require(crimeDeptAddress == msg.sender, "You are not belong to Crime Report Department");
        _;
    }
    modifier educationDeptValidation(){
        require(educationDeptAddress == msg.sender, "You are not belong to Education Department");
        _;
    }
    modifier trafficDeptValidation(){
        require(trafficDeptAddress == msg.sender, "You are not belong to Traffic Department");
        _;
    }
    modifier marriageDeptValidation(){
        require(marriageDeptAddress == msg.sender, "You are not belong to Marriage Department");
        _;
    }
    modifier onlyOwner(){
        require(owner == msg.sender, "You are not an owner.");
        _;
    }

    //DATA STRUCTURES:
    string[] public cnics;
    
    //UNION COUNCIL 
    struct UnionConcil{
        string name;
        string cnic;
        string f_name;
        string m_name;
        string f_cnic;
        string m_cnic;
        string gender;
        uint dob; 
        string city;
        bool isDied; 
    } 
    mapping(string => UnionConcil) public UnionConcilData;
    
    
    //WEAPON LICENSE
    struct  WeaponLisence{
        string cnic;
        string weapon_type;
        string lisence_no; 
        bool weapon_issued;
        bool isBanned; 
        uint date;
    }
    mapping(string => WeaponLisence) public WeaponLisenceData;

    //CRIMINAL RECORD
    struct CriminalRecord{
        string cnic;
        bool record_found;
        string remarks;
        uint date;
    }
    mapping(string => CriminalRecord[]) public CriminalRecordData;

    //EDUCATION
    struct Education{
        string cnic;
        string subject;
        uint256 marks;
        uint256 percentage;
        string grade;
        uint date;
        bool passedSSC;
        bool passedHSC;
    }
    mapping(string => Education[]) public EducationData;

    //TRAFFIC CHALLAN
    struct TrafficChallan{
        string cnic;
        string vehicle_no;
        string challan_type;
        uint256 amount;
        uint date;
        bool isPaid;
    }
    mapping(string => TrafficChallan[]) public TrafficChallanData;

    //MARRIAGE
    // struct Marriage{
    //     string boy_cnic;
    //     string girl_cnic;
    //     string date;
    // }
    mapping(string => mapping (string => uint256)) public marriage;

    

    constructor() {
        owner = msg.sender;
        UnionConcil memory user;
          user = UnionConcil({
            name: "Ali",
            cnic: "42301-5432567-8",
            f_name: "Abbas",
            m_name: "Ayesha",
            f_cnic: "42301-5432425-8",
            m_cnic: "42301-5432333-8",
            gender: "Male",
            dob: 890006400,
            city: "Karachi",
            isDied: false
          });
        UnionConcilData["42301-5432567-8"] = user;

        UnionConcil memory user1;
          user1 = UnionConcil({
            name: "Sobia",
            cnic: "42301-5434557-8",
            f_name: "Aamir",
            m_name: "Hira",
            f_cnic: "42301-5431087-8",
            m_cnic: "42301-5432214-8",
            gender: "Female",
            dob: 921801600,
            city: "Hyderabad",
            isDied: false
          });
        UnionConcilData["42301-5434557-8"] = user1;

        cnics.push("42301-5432567-8");
        cnics.push("42301-5434557-8");
    }

    function addUnionDeptAddress(address _address) public onlyOwner{
        unionDeptAddress = _address;
    }
    function addWeaponDeptAddress(address _address) public onlyOwner{
        weaponDeptAddress = _address;
    }
    function addCrimeDeptAddress(address _address) public onlyOwner{
        crimeDeptAddress = _address;
    }
    function addEducationDeptAddress(address _address) public onlyOwner{
        educationDeptAddress = _address;
    }
    function addTrafficDeptAddress(address _address) public onlyOwner{
        trafficDeptAddress = payable(_address);
    }
    function addMarriageDeptAddress(address _address) public onlyOwner{
        marriageDeptAddress = _address;
    }

    function Union_Concil(string memory name,string memory cnic,string memory f_name,string memory m_name,string memory f_cnic,string memory m_cnic,string memory gender,uint dob,string memory city) public unionDeptValidation{
        require(marriage[f_cnic][m_cnic] != 0, "Parents Name does not exist");
        require((dob - marriage[f_cnic][m_cnic]) > 0, "Children Date of birth should be greater than after a year of marriage");
        require(((dob - marriage[f_cnic][m_cnic])/ 60 / 60 / 24) >= 360, "Children Date of birth should be greater than after a year of marriage");
        require(UnionConcilData[f_cnic].isDied == false && UnionConcilData[m_cnic].isDied == false, "Parents was died");
        require(keccak256(abi.encodePacked(UnionConcilData[f_cnic].cnic)) == keccak256(abi.encodePacked(f_cnic)),"You have passed wrong cnic of your father");
        require(keccak256(abi.encodePacked(UnionConcilData[m_cnic].cnic)) == keccak256(abi.encodePacked(m_cnic)),"You have passed wrong cnic of your mother");
        
        UnionConcil memory user;
        user = UnionConcil({
            name: name,
            cnic: cnic,
            f_name: f_name,
            m_name: m_name,
            f_cnic: f_cnic,
            m_cnic: m_cnic,
            gender: gender,
            dob: dob,
            city: city,
            isDied: false
        });
        UnionConcilData[cnic] = user;
        cnics.push(cnic);
    } 

    function death(string memory cnic) public unionDeptValidation{
        require(keccak256(abi.encodePacked(cnic)) == keccak256(abi.encodePacked(UnionConcilData[cnic].cnic)), "Wrong CNIC" );
        UnionConcilData[cnic].isDied = true;
    }

    function Weapon_Lisence(string memory cnic, string memory weapon_type,string memory lisence_no, uint date)  public weaponDeptValidation{
        require(keccak256(abi.encodePacked(cnic)) == keccak256(abi.encodePacked(UnionConcilData[cnic].cnic)), "Wrong CNIC" );
        require(UnionConcilData[cnic].isDied == false, "The person is died");
        //require(CriminalRecordData[cnic].record_found == false, "Your Criminal Record is Found");
        require(WeaponLisenceData[cnic].weapon_issued == false, "you have already weapon available");
        require(((date - UnionConcilData[cnic].dob)/ 60 / 60 / 24) >= 6574, "Your age is less than 18");
        
        CriminalRecord[] memory crm =  CriminalRecordData[cnic];

        bool isCrimeFound;
        for(uint i = 0; i < crm.length; i++){
            if(crm[i].record_found == true){
                isCrimeFound = true;   
            }else{
                isCrimeFound = false;
            }
        }

        if(isCrimeFound == false){
            WeaponLisence memory weapon; 
            weapon = WeaponLisence({
                cnic: cnic,
                weapon_type: weapon_type,
                lisence_no: lisence_no,
                weapon_issued: true,
                date: date,
                isBanned: false
            });
            WeaponLisenceData[cnic] = weapon;
        }else{
            require(isCrimeFound == false,"Your Criminal Record is found.");
        }
        
    } 
     
    function Criminal_Record(string memory cnic,string memory remarks,bool record_found, uint date) public crimeDeptValidation {
        require(keccak256(abi.encodePacked(cnic)) == keccak256(abi.encodePacked(UnionConcilData[cnic].cnic)), "Wrong CNIC" );      
        require(UnionConcilData[cnic].isDied == false, "The person is died");
        CriminalRecord memory crime;
        crime = CriminalRecord({
            cnic: cnic,
            record_found: record_found,
            remarks: remarks,
            date: date
        });
        CriminalRecordData[cnic].push(crime);
        WeaponLisenceData[cnic].isBanned = true;
    }  

    function Marriage(string memory boy_name,string memory boy_cnic, string memory girl_name,string memory girl_cnic, uint date) public marriageDeptValidation{
        require(keccak256(abi.encodePacked(UnionConcilData[boy_cnic].cnic)) == keccak256(abi.encodePacked(boy_cnic)),"CNIC of boy is wrong");
        require(keccak256(abi.encodePacked(UnionConcilData[girl_cnic].cnic)) == keccak256(abi.encodePacked(girl_cnic)),"CNIC of girl is wrong");
        require(UnionConcilData[boy_cnic].isDied == false, "The boy is died");
        require(UnionConcilData[girl_cnic].isDied == false, "The girl is died");
        require(keccak256(abi.encodePacked(UnionConcilData[boy_cnic].name)) == keccak256(abi.encodePacked(boy_name)),"name of boy is wrong");
        require(keccak256(abi.encodePacked(UnionConcilData[girl_cnic].name)) == keccak256(abi.encodePacked(girl_name)),"name of girl is wrong");
        require(keccak256(abi.encodePacked(UnionConcilData[boy_cnic].gender)) == keccak256(abi.encodePacked("Male")),"You have passed wrong girl gender");
        require(keccak256(abi.encodePacked(UnionConcilData[girl_cnic].gender)) == keccak256(abi.encodePacked("Female")),"You have passed wrong boy gender");
        require(((date - UnionConcilData[girl_cnic].dob)/ 60 / 60 / 24) >= 6574, "girl age is less than 18");
        require(((date - UnionConcilData[boy_cnic].dob)/ 60 / 60 / 24) >= 6574, "boy age is less than 18");
        marriage[boy_cnic][girl_cnic] = block.timestamp;
    }  

    function Educations(string memory cnic, string memory subject,uint256 marks, uint256 percentage, string memory grade, uint date) public educationDeptValidation {
        require(keccak256(abi.encodePacked(cnic)) == keccak256(abi.encodePacked(UnionConcilData[cnic].cnic)), "Wrong CNIC" );    
        require(UnionConcilData[cnic].isDied == false, "The person is died");
        Education memory education;
        Education[] memory edu=  EducationData[cnic];

        if(keccak256(abi.encodePacked(subject)) == keccak256(abi.encodePacked("SSC")) ){
            require(((date - UnionConcilData[cnic].dob)/ 60 / 60 / 24) >= 5844, "Your age is less than 16");
            uint256 isPassedSSC = 0;
            bool isPassed = false;

            if(edu.length == 0){
                isPassedSSC = 1;
            }else{
                for(uint i = 0; i < edu.length; i++){
                    if(edu[i].passedSSC == true){
                        isPassedSSC = 0;   
                    }else{
                        isPassedSSC = 1;
                    }
                }
            }
            if(isPassedSSC == 1){
                if(keccak256(abi.encodePacked(grade)) != keccak256(abi.encodePacked("F"))){
                    isPassed = true;
                }
                education = Education({
                    cnic: cnic,
                    subject: subject,
                    marks: marks,
                    percentage: percentage,
                    grade: grade,
                    date: date,
                    passedSSC: isPassed,
                    passedHSC: false
                });
                EducationData[cnic].push(education);
            }else{
                require(isPassedSSC == 1, "There is some error.");
            }
        }
        
        else if( keccak256(abi.encodePacked(subject)) ==  keccak256(abi.encodePacked("HSC")) ){
            require(((date - UnionConcilData[cnic].dob)/ 60 / 60 / 24) >= 6574, "Your age is less than 18");
            
            uint256 isPassedHSC = 0;
            bool isPassed = false;

            if(edu.length == 0){
                isPassedHSC = 0;
            }else{
                for(uint i = 0; i < edu.length; i++){
                    if(edu[i].passedSSC == false){
                        isPassedHSC = 0;   
                    }else if(edu[i].passedSSC == true && edu[i].passedHSC == false){
                        isPassedHSC = 1;
                    }
                }
            }
            if(isPassedHSC == 1){
                if(keccak256(abi.encodePacked(grade)) != keccak256(abi.encodePacked("F"))){
                    isPassed = true;
                }
                education = Education({
                    cnic: cnic,
                    subject: subject,
                    marks: marks,
                    percentage: percentage,
                    grade: grade,
                    date: date,
                    passedSSC: true,
                    passedHSC: isPassed
                });
                EducationData[cnic].push(education);
            }else{
                require(isPassedHSC == 1, "There is some error.");
            }
        }
    }

    function Traffic_Challan(string memory cnic, string memory vehicle_no,string memory challan_type,uint256 amount, uint date) public trafficDeptValidation{
        require(keccak256(abi.encodePacked(cnic)) == keccak256(abi.encodePacked(UnionConcilData[cnic].cnic)), "Wrong CNIC" );    
        require(UnionConcilData[cnic].isDied == false, "The person is died");
        require(((date - UnionConcilData[cnic].dob)/ 60 / 60 / 24) >= 6574, "Your age is less than 18");
        
        TrafficChallan memory challan;
        challan = TrafficChallan({
            cnic: cnic,
            vehicle_no: vehicle_no,
            challan_type: challan_type, 
            amount: amount,
            date: date,
            isPaid: false
        });
        TrafficChallanData[cnic].push(challan);
        
    } 

    function PayChallan(string memory cnic, string memory vehicle_no, string memory challan_type, uint date) payable public trafficDeptValidation{
        require(keccak256(abi.encodePacked(cnic)) == keccak256(abi.encodePacked(UnionConcilData[cnic].cnic)), "Wrong CNIC" );    
        require(UnionConcilData[cnic].isDied == false, "The person is died");
        uint8 count= 0;
        uint8 index = 0;
        uint amount = msg.value;
        
        TrafficChallan[] memory challans = TrafficChallanData[cnic];

        for(uint8 i=0; i < challans.length; i++){
            if( keccak256(abi.encodePacked(cnic)) == keccak256(abi.encodePacked(challans[i].cnic)) &&      
                keccak256(abi.encodePacked(vehicle_no)) == keccak256(abi.encodePacked(challans[i].vehicle_no)) && 
                amount ==  challans[i].amount &&
                keccak256(abi.encodePacked(challan_type)) == keccak256(abi.encodePacked(challans[i].challan_type))
            ){
                trafficDeptAddress.transfer(amount);
                count = 1;
                index = i;
                break;
            }   
            else{
               continue;
            }
        }
        if(count==1){
            for(uint8 j=index; j < challans.length-1; j++){
               challans[j] =  challans[j+1];
            }
            TrafficChallanData[cnic].pop();
            
            TrafficChallan memory challan;
            challan = TrafficChallan({
                cnic: cnic,
                vehicle_no: vehicle_no,
                challan_type: challan_type, 
                amount: amount,
                date: date,
                isPaid: true
            });
            TrafficChallanData[cnic].push(challan);
        }
        require(count == 1, "You are passing wrong value.");
    
         
    }
      
    function getCnics() public view returns(string[] memory){
        return cnics;
    }

}