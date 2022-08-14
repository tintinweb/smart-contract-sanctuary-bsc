/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

//SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.0 < 0.9.0;

contract Disaster {
    //Contract Variables
    address private owner;
    string public DisasterName;


    //Enums
    enum RequestState { Initiated, Dispatched, Delivered, Cancelled }

    //Structs
    struct Request {
        string supplyType;
        string requestedBy;
        string deliveryAddress;
        uint amount;
        RequestState state;
    }
    struct CenterData {
        address centerAddress;
        string name;
    }
    struct StateData {
        address stateAddress;
        string name;
    }
    struct GroundData {
        address groundAddress;
        string name;
    }

    //Mappings
    mapping(address => string) public AuthorityName;
    mapping(address => bool) public isCenter;
    mapping(address => bool) public isState;
    mapping(address => bool) public isGround;
    mapping(address => Request[]) public authorityRequest;

    //Arrays
    CenterData[] public allCenterData;
    StateData[] public allStateData;
    GroundData[] public allGroundData;
    Request[] public allRequests;
    
    constructor(address EOA, string memory DisasterType) {
        owner = EOA;
        DisasterName = DisasterType;
        isCenter[EOA] = true;
        CenterData memory newCenter;
        newCenter.centerAddress = EOA;
        newCenter.name = "Admin";
        allCenterData.push(newCenter);
    }

    //Access Modifiers
    modifier onlyAdmin{
        require(owner == msg.sender, "Sorry You are not an Admin");
        _;
    }

    modifier onlyCenter{
        require(isCenter[msg.sender] == true, "Only Center Level Authorities Allowed");
        _;
    }

    modifier onlyState{
        require(isState[msg.sender] == true, "Only Center Level Authorities Allowed");
        _;
    }

    modifier onlyStateOrCenter {
        require(isState[msg.sender] == true || isCenter[msg.sender] == true, "Only Center or State Level Authorities Allowed");
        _;
    }

    modifier onlyInvolvedAuthorities {
        require(isState[msg.sender] == true || isCenter[msg.sender] == true || isGround[msg.sender] == true, "Only Involved Authorities Allowed");
        _;
    }

    //Gets all Center Data 
    function getCenterData() external view returns (CenterData[] memory) {
        return allCenterData;
    }

    //Gets all State Data 
    function getStateData() external view returns (StateData[] memory) {
        return allStateData;
    }

    //gets all Ground Data
    function getGroundData() external view returns (GroundData[] memory) {
        return allGroundData;
    }

    //create Center Level 
    function createCenterLevel(address toGrant, string memory centerName) external onlyCenter {

        AuthorityName[toGrant] = centerName;
        isCenter[toGrant] = true;
        CenterData memory newCenter;
        newCenter.centerAddress = toGrant;
        newCenter.name = centerName;
        allCenterData.push(newCenter);

    }

    //create State level
    function createStateLevel(address toGrant, string memory stateName) external onlyCenter {

        AuthorityName[toGrant] = stateName;
        isState[toGrant] = true;
        StateData memory newState;
        newState.stateAddress = toGrant;
        newState.name = stateName;
        allStateData.push(newState);

    }

    //create Ground Level
    function createGroundLevel(address toGrant, string memory GroundName) external onlyStateOrCenter {

        AuthorityName[toGrant] = GroundName;
        isGround[toGrant] = true;
        GroundData memory newGround;
        newGround.groundAddress = toGrant;
        newGround.name = GroundName;
        allGroundData.push(newGround);

    }

    //Create a new Supply Request
    function createRequest(string memory _supplyType, string memory _deliveryAddress, uint _amount) external onlyInvolvedAuthorities{

        Request memory newRequest;
        newRequest.supplyType = _supplyType;
        newRequest.requestedBy = AuthorityName[msg.sender];
        newRequest.deliveryAddress = _deliveryAddress;
        newRequest.amount = _amount;
        newRequest.state = RequestState.Initiated;
        allRequests.push(newRequest);
        authorityRequest[msg.sender].push(newRequest);

    }

    //Gets All Requests for this particular disastar
    function getAllRequest() external view returns(Request[] memory){
        return allRequests;
    }

    //Gets Specific User Supply Requests
    function getRequest(address supplyCreator) external view returns (Request[] memory){
        return authorityRequest[supplyCreator];
    }

    //Dispatch Supply
    function dispatchSupply(address supplyCreator, uint index) external {
        authorityRequest[supplyCreator][index].state = RequestState.Dispatched;
    }

    //Supply Delivered
    function deliveredSupply(address supplyCreator, uint index) external {
        authorityRequest[supplyCreator][index].state = RequestState.Delivered;
    }

    //Supply Cancelled
    function cancelSupply(address supplyCreator, uint index) external {
        authorityRequest[supplyCreator][index].state = RequestState.Cancelled;
    }
    
}


contract MasterContract {
    address private ownerMaster;
    Disaster[] public deployedDisaster;

    constructor () {
        ownerMaster = msg.sender;
    }

    function CreateDisaster(string memory DisasterType) public {
        Disaster new_Disaster_address = new Disaster(msg.sender, DisasterType);
        deployedDisaster.push(new_Disaster_address);
    }
}