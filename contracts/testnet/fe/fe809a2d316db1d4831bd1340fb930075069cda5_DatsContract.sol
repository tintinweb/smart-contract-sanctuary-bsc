/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

contract DatsContract{
    
    struct DDos {
        uint256 id;
        address user;
        bool isApprove;
        uint8 trafficScale;
    }

    struct SuperComputer {
        uint256 id;
        address user;
        bool isApprove;
        uint8 cpuValue;
    }

    struct CyberSecurity {
        uint256 id;
        address user;
        bool isApprove;
        bool webSecurity;
        bool serverSecurity;
        bool ransomwareResearch;
        bool malwareResearch;
    }

    struct Vulnerability {
        uint256 id;
        address user;
        bool isApprove;
        bool webPenetration;
        bool serverPenetration;
        bool scadaPenetration;
        bool blockchainPenetration;
        bool contractPenetration;
    }

    struct Blockchain {
        uint256 id;
        address user;
        bool approveAttackPrevention;
    }

    address public owner;

    mapping(address => DDos) public ddoses;
    address[] public ddosLength;

    mapping(address => SuperComputer) public supers;
    address[] public superLength;

    mapping(address => CyberSecurity) public cybers;
    address[] public cyberLength;

    mapping(address => Vulnerability) public vulnerabilities;
    address[] public vulnerabilityLength;

    mapping(address => Blockchain) public blockchains;
    address[] public blockchainLength;

    event DDosSaved(uint256 _id, address indexed _consumer, DDos _data);
    event SuperComputerSaved(uint256 _id, address indexed _consumer, SuperComputer _data);
    event CyberSecuritySaved(uint256 _id, address indexed _consumer, CyberSecurity _data);
    event VulnerabilitySaved(uint256 _id, address indexed _consumer, Vulnerability _data);
    event BlockchainSaved(uint256 _id, address indexed _consumer, Blockchain _data);

    constructor(){
        owner = msg.sender;
    }

    function getAllUserDDosSettings() public view returns(DDos[] memory){
        require(owner == msg.sender, "You are not authorized.");
        DDos[] memory allDDoses = new DDos[](ddosLength.length);

        for(uint i = 0; i < ddosLength.length; i++){
            allDDoses[i] = ddoses[ddosLength[i]];
        }

        return allDDoses;
    }

    function saveDDos(bool _isApprove, uint8 _trafficScale) external {

        uint256 newId = ddosLength.length + 1;

        DDos memory ddos = DDos(newId, msg.sender, _isApprove, _trafficScale);

        if(ddoses[msg.sender].id == 0)
            ddosLength.push(msg.sender);

        ddoses[msg.sender] = ddos;  

        emit DDosSaved(newId, msg.sender, ddos);
        
    }

    function getDDos() external view returns (DDos memory) {
        return ddoses[msg.sender];
    }

    function getDDosByUser(address _user) external view returns (DDos memory){
        return ddoses[_user];
    }

    function getDDosCount() external view returns(uint256) {
        return ddosLength.length;
    }

    function getAllUserSuperComputerSettings() public view returns(SuperComputer[] memory){
        require(owner == msg.sender, "You are not authorized.");
        SuperComputer[] memory allSupers = new SuperComputer[](superLength.length);

        for(uint i = 0; i < superLength.length; i++){
            allSupers[i] = supers[superLength[i]];
        }

        return allSupers;
    }

    function saveSuperComputer(bool _isApprove, uint8 _cpuValue) external {
        
        uint256 newId = superLength.length + 1;
        
        SuperComputer memory superComputer = SuperComputer(newId, msg.sender, _isApprove, _cpuValue);

        if(supers[msg.sender].id == 0)
            superLength.push(msg.sender);

        supers[msg.sender] = superComputer;

        emit SuperComputerSaved(newId, msg.sender, superComputer);
        
    }

    function getSuperComputer() external view returns (SuperComputer memory) {
        return supers[msg.sender];
    }

    function getSuperComputerByUser(address _user) external view returns (SuperComputer memory){
        return supers[_user];
    }

    function getSuperComputerCount() external view returns(uint256) {
        return superLength.length;
    }



    function getAllUserCyberSecuritySettings() public view returns(CyberSecurity[] memory){
        require(owner == msg.sender, "You are not authorized.");
        CyberSecurity[] memory allCybers = new CyberSecurity[](cyberLength.length);

        for(uint i = 0; i < cyberLength.length; i++){
            allCybers[i] = cybers[cyberLength[i]];
        }

        return allCybers;
    }
    
    function saveCyberSecurity(bool _isApprove, bool _webSecurity, bool _serverSecurity, bool _ransomwareResearch, bool _malwareResearch) external{

        uint256 newId = cyberLength.length + 1;

        CyberSecurity memory cyberSecurity = CyberSecurity(newId, msg.sender, _isApprove, _webSecurity, _serverSecurity, _ransomwareResearch, _malwareResearch);

        if(cybers[msg.sender].id == 0)
            cyberLength.push(msg.sender);
        
        cybers[msg.sender] = cyberSecurity;

        emit CyberSecuritySaved(newId, msg.sender, cyberSecurity);
        
    }

    function getCyberSecurity() external view returns(CyberSecurity memory){
        return cybers[msg.sender];
    }

    function getCyberSecurityCount() external view returns(uint256){
        return cyberLength.length;
    }


    function getAllUserVulnerabilitySettings() public view returns(Vulnerability[] memory){
        require(owner == msg.sender, "You are not authorized.");
        Vulnerability[] memory allVulnerability = new Vulnerability[](vulnerabilityLength.length);

        for(uint i = 0; i < vulnerabilityLength.length; i++){
            allVulnerability[i] = vulnerabilities[vulnerabilityLength[i]];
        }

        return allVulnerability;
    }

    function saveVulnerability(bool _isApprove, bool _webPenetration, bool _serverPenetration, bool _scadaPenetration, bool _blockchainPenetration, bool _contractPenetration) external{
        
        uint256 newId = vulnerabilityLength.length + 1;
        
        Vulnerability memory vulnerability = Vulnerability(newId, msg.sender, _isApprove, _webPenetration, _serverPenetration, _scadaPenetration, _blockchainPenetration, _contractPenetration);

        if(vulnerabilities[msg.sender].id == 0)
            vulnerabilityLength.push(msg.sender);
        
        vulnerabilities[msg.sender] = vulnerability;

        emit VulnerabilitySaved(newId, msg.sender, vulnerability);
        
    }

    function getVulnerability() external view returns(Vulnerability memory) {
        return vulnerabilities[msg.sender];
    }

    function getVulnerabilityCount() external view returns(uint256){
        return vulnerabilityLength.length;
    }




    function getAllUserBlockchainSettings() public view returns(Blockchain[] memory){
        require(owner == msg.sender, "You are not authorized.");
        Blockchain[] memory allBlockchains = new Blockchain[](blockchainLength.length);

        for(uint i = 0; i < blockchainLength.length; i++){
            allBlockchains[i] = blockchains[blockchainLength[i]];
        }

        return allBlockchains;
    }

    function saveBlockchain(bool _approveAttackPrevention) external{
        
        uint256 newId = blockchainLength.length + 1;

        Blockchain memory blockchain = Blockchain(newId, msg.sender, _approveAttackPrevention);

        if(blockchains[msg.sender].id == 0)
            blockchainLength.push(msg.sender); 

        blockchains[msg.sender] = blockchain;

        emit BlockchainSaved(newId, msg.sender, blockchain);
        
    }

    function getBlockchain() external view returns(Blockchain memory){
        return blockchains[msg.sender];
    }

    function getBlockchainCount() external view returns(uint256){
        return blockchainLength.length;
    }

}