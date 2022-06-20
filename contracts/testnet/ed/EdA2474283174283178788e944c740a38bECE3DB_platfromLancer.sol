/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

pragma solidity ^0.8.14;
//SPDX-License-Identifier: MIT

contract platfromLancer {
    uint256 NONCE;
    struct Project {
        bytes20 projectHash;    //sha1
        address payable freelancer;
        address payable client;
        uint allProjectsIndex;
        uint creationTime;
        uint[] checkpointRewards;
        mapping(uint => bool) checkpointsCompleted;
    }
    struct User {
        string  NAME;
        string  CNIC;
        string  EMAIL;
        string  PHONE;
        string  DOB;
        address payable userAddress;
        bool isRegistered;
        uint256 [] earnings;
        uint256 [] payments;
        uint256 totalEarned;
        uint256 totalPaid;
    }
    
    bytes12[] allProjects;                                  //Stores all project id's for getter function.
    mapping(bytes12 => Project) projects;                  //mapping from project id (created by backend) to Project struct. Stores all project details.
    mapping(address => User) public users;                        //mapping from user address to User struct. Stores all user details.
    mapping(uint256 => address) public usersbyIndex;
    
    
    
    
    //------------------EVENTS------------------
    event ProjectAdded(bytes12 _id, address _clientAddress);
    event ProjectAssigned(bytes12 _id, address _freelancerAddress);
    event CheckpointCompleted(bytes12 _id, uint _checkpointIndex);
    event ProjectUnassigned(bytes12 _id);
    event ProjectDeleted(bytes12 _id);
    //------------------------------------------
    
    
    //------------------MODIFIERS------------------
    modifier onlyClient(bytes12 _id) {
        require(msg.sender == projects[_id].client, "Only client can do this");
        require(users[msg.sender].isRegistered, "You are not registered");
        _;
    }
    
    modifier onlyfreelancer(bytes12 _id) {
        require(msg.sender == projects[_id].freelancer, "Only freelancer can do this");
        require(users[msg.sender].isRegistered, "You are not registered");
        _;
    }
    
    modifier onlyClientOrfreelancer(bytes12 _id) {
        require(msg.sender == projects[_id].client || msg.sender == projects[_id].freelancer, "Only client or freelancer can do this");
        require(users[msg.sender].isRegistered, "You are not registered");
        _;
    }
    
    modifier projectExists(bytes12 _id){
        require(projects[_id].projectHash != 0, "Project does not exist");
        _;
    }
    
    modifier isAssigned(bytes12 _id){
        require(projects[_id].freelancer != address(0), "Project not yet assigned");
        _;
    }
    //---------------------------------------------
    function signUp(string memory _name, string memory _cnic, string memory _email, string memory _phone, string memory _dob) public {
        User storage newUser = users[msg.sender];
        usersbyIndex[NONCE] = msg.sender;
        // require(!newUser.isRegistered , "Already isRegistered");


        require(bytes(_name).length > 3 && bytes(_name).length < 15, "Name must be between 3 to 15 characters");
        require(bytes(_cnic).length > 10 && bytes(_cnic).length < 20, "CNIC must be between 10 to 20 characters");
        require(bytes(_email).length > 5 && bytes(_email).length < 30, "Email must be between 5 to 30 characters");
        require(bytes(_phone).length >= 9 && bytes(_phone).length < 20, "Phone must be 9 to 20 characters");
        require(bytes(_dob).length >= 8 , "DOB must be greater than 8 characters");
        bool validuser = true;

        for(uint256 i = 0; i < NONCE; i++){
            if(keccak256(abi.encodePacked((users[usersbyIndex[i]].CNIC))) == keccak256(abi.encodePacked((_cnic)))){
                validuser = false;
            }
        }
        require(validuser, "You are already registered");

        newUser.NAME = _name;
        newUser.CNIC = _cnic;
        newUser.EMAIL = _email;
        newUser.PHONE = _phone;
        newUser.DOB = _dob;
        newUser.userAddress = payable(msg.sender);
        newUser.isRegistered = true;

        NONCE++;
    }
    
    //Add project. For Checkpoint only reward values as uint[] is passed. By default all checkpoints.completed == false.
    //In case client does not want to have a checkpoint based reward, a single checkpoint corresponding to 100% completion will be made (handled by stack appliaction).
    function addProject(bytes12 _id, bytes20 _projectHash, uint[] calldata _checkpointRewards) external returns(bool) {
        require(_checkpointRewards.length > 0, "Checkpoints required");
        require(projects[_id].projectHash == 0, "Project already added");
        
        projects[_id].checkpointRewards = _checkpointRewards;
        projects[_id].client = payable(msg.sender);
        projects[_id].projectHash = _projectHash;
        projects[_id].creationTime = block.timestamp;
        
        projects[_id].allProjectsIndex = allProjects.length;
        allProjects.push(_id);
        
        emit ProjectAdded(_id, msg.sender);
        return true;
    }
    
    //Assign project. Client will also have to transfer value to smart contract at this point.
    function assign(bytes12 _id, address payable freelancerAddress) projectExists(_id) onlyClient(_id) payable external returns(bool) {
        require(projects[_id].freelancer == address(0), "Project already assigned");
        require(freelancerAddress != address(0), "Zero address submitted");
        
        uint totalReward;
        for(uint i=0; i<projects[_id].checkpointRewards.length; i++){
            if(!projects[_id].checkpointsCompleted[i]){
                totalReward += projects[_id].checkpointRewards[i];
            }
        }
        
        require(msg.value == totalReward, "Wrong amount submitted");
        
        projects[_id].freelancer = freelancerAddress;
        
        emit ProjectAssigned(_id, freelancerAddress);
        return true;
    }
    
    //mark checkpoint as completed and transfer reward
    function checkpointCompleted(bytes12 _id, uint index) projectExists(_id) onlyClient(_id) isAssigned(_id) external returns(bool) {
        require(index < projects[_id].checkpointRewards.length, "Checkpoint index out of bounds");
        require(!projects[_id].checkpointsCompleted[index], "Checkpoint already completed");
        
        projects[_id].checkpointsCompleted[index] = true;
        
        emit CheckpointCompleted(_id, index);
        projects[_id].freelancer.transfer(projects[_id].checkpointRewards[index]);
        users[projects[_id].freelancer].totalEarned += projects[_id].checkpointRewards[index];
        users[projects[_id].freelancer].earnings.push(projects[_id].checkpointRewards[index]);
        users[projects[_id].client].payments.push( projects[_id].checkpointRewards[index]);
        users[projects[_id].client].totalPaid += projects[_id].checkpointRewards[index];
        
        return true;
    }
    
    //Called by client or freelancer to unassign freelancer from the project
    function unassign(bytes12 _id) projectExists(_id) isAssigned(_id) onlyClientOrfreelancer(_id) public returns(bool) {
        delete projects[_id].freelancer;
        
        emit ProjectUnassigned(_id);
        uint totalReward;
        for(uint i=0; i<projects[_id].checkpointRewards.length; i++){
            if(!projects[_id].checkpointsCompleted[i]){
                totalReward += projects[_id].checkpointRewards[i];
            }
        }
    
        projects[_id].client.transfer(totalReward);
        return true;
    }
    
    //delete project. Requires unassigning first so that remainingReward is not lost.
    function deleteProject(bytes12 _id) projectExists(_id) onlyClient(_id) external returns(bool) {
        if (projects[_id].freelancer != address(0))
            unassign(_id);
        
        delete allProjects[projects[_id].allProjectsIndex];
        delete projects[_id];
        
        emit ProjectDeleted(_id);
        return true;
    }
    
    
    //------------------GETTERS------------------
    function getAllProjects() view public returns(bytes12[] memory) {
        return allProjects;
    }
    
    function get20Projects(uint _from) view public returns(bytes12[20] memory, uint) {
        bytes12[20] memory tempProjects;
        uint count = 0;
        uint i = allProjects.length-1 - _from;
        for(i; i >= 0 && count < 20; i--){
            if(allProjects[i] != 0) {
                tempProjects[count] = allProjects[i];
                count++;
            }
        } 
        return (tempProjects, allProjects.length-1-i);
    }
    
    function getProject(bytes12 _id) view public projectExists(_id) returns(address, address, bytes20, uint[] memory, bool[] memory, uint) {
        bool[] memory _tempCheckpoints = new bool[](projects[_id].checkpointRewards.length);
        for(uint i=0; i<projects[_id].checkpointRewards.length; i++){
            _tempCheckpoints[i] = projects[_id].checkpointsCompleted[i];
        }
        return (
            projects[_id].client,
            projects[_id].freelancer,
            projects[_id].projectHash,
            projects[_id].checkpointRewards,
            _tempCheckpoints,
            projects[_id].creationTime
        );
    }
    
    function getfreelancerProjects(address _freelancerAddress) view public returns(bytes12[] memory) {
        require(_freelancerAddress != address(0), "Zero address passed");
        bytes12[] memory _tempProjects = new bytes12[](allProjects.length);
        uint counter;
        for(uint i = 0; i<allProjects.length; i++){
            if(projects[allProjects[i]].freelancer == _freelancerAddress){
                _tempProjects[counter] = allProjects[i];
                counter++;
            }
        }
        bytes12[] memory _projects = new bytes12[](counter);
        for(uint i=0; i<counter; i++){
            _projects[i] = _tempProjects[i];
        }
        return _projects;
    }
    
    function getClientProjects(address _clientAddress) view public returns(bytes12[] memory) {
        require(_clientAddress != address(0), "Zero address passed");
        bytes12[] memory _tempProjects = new bytes12[](allProjects.length);
        uint counter;
        for(uint i = 0; i<allProjects.length; i++){
            if(projects[allProjects[i]].client == _clientAddress){
                _tempProjects[counter] = allProjects[i];
                counter++;
            }
        }
        bytes12[] memory _projects = new bytes12[](counter);
        for(uint i=0; i<counter; i++){
            _projects[i] = _tempProjects[i];
        }
        return _projects;
    }
   
}