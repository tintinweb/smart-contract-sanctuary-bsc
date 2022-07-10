/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

contract SecondExam
{
    address private _owner;

    struct Student {
        uint studentNum;
        address studentAddress;
        bool isApprovedStudent;
        bool isPaidTuitionFee;
    }

    struct Payment {
        uint amount;
        uint timestamp;
    }

    struct Balance {
        uint total;
        uint numPayment;
        mapping (uint => Payment) payments;
    }

    address[] registerStudents;
    Student[] approvalStudents;
    Student[] paidStudents;

    uint private numStudents = 0;
    uint private numPayment = 1;
    uint public maxStudents = 10;
    uint public tuitionFee = 1 ether;
    uint public totalPaidTuitionFee = 0;

    mapping(address => bool) _isRegistered;
    mapping(address => bool) _isApproval;
    mapping(address => bool) _isPaid;
    mapping(address => Balance) private balances;

    constructor()
    {
        _owner = msg.sender; 
    }
    
    //check owner
    modifier onlyOwner() 
    {
        require(isOwner(),
        "Only owner can use this function!");
        _;
    }

    modifier notOwner() 
    {
        require(!isOwner(),
        "Only student can use this function!");
        _;
    }
    
    function isOwner() public view returns(bool) 
    {
        return msg.sender == _owner;
    }

    //set max student for the class
    function setMaxStudent(uint _max) onlyOwner public {
        maxStudents = _max;
    }

    //register and approval
    function register() notOwner public {
        require(!_isRegistered[msg.sender], "You are is already registered!");
        registerStudents.push(msg.sender);
        _isRegistered[msg.sender]=true;
    }

    function getListRegisterStudent() public view returns(address[] memory) { 
        return registerStudents;
    }

    function getListApprovalStudent() public view returns(Student[] memory) { 
        return approvalStudents;
    }

    function approval(address studentAddress) onlyOwner public {
        require(!_isApproval[studentAddress], "This student is already approval!");
        require(isRegisterStudent(studentAddress), "This student is not yet register!");
        
        Student memory newStudent = Student(0, studentAddress, true, false);
        approvalStudents.push(newStudent);
        _isApproval[studentAddress] = true;
    }

    function isApprovalStudent (address _addr) public view returns (bool){
        bool isExist = false;
        for (uint i; i < approvalStudents.length; i++){
            if (approvalStudents[i].studentAddress == _addr)
            isExist = true;
        }
        return isExist;
    }

    function isRegisterStudent (address _addr) public view returns (bool){
        bool isExist = false;
        for (uint i; i < registerStudents.length; i++){
            if (registerStudents[i] == _addr)
            isExist = true;
        }
        return isExist;
    }

    function isPaidStudent (address _addr) public view returns (bool){
        bool isExist = false;
        for (uint i; i < paidStudents.length; i++){
            if (paidStudents[i].studentAddress == _addr)
            isExist = true;
        }
        return isExist;
    }

    //paid tuition fee
    function getMyBalances() public view returns (uint) {
        return balances[msg.sender].total;
    }

    
    function deposit() notOwner payable public {
        setBalance(msg.sender, msg.value);
    }

    function withdraw(uint value) onlyOwner payable public {
        require(balances[_owner].total >= value,"The amount in your wallet is not enough");
        balances[_owner].total -= value;
        payable(_owner).transfer(value);
    }

    function paidTuitionFee() notOwner payable public {
        require(!_isPaid[msg.sender], "This student is already paid tuition fee!");
        require(isApprovalStudent(msg.sender), "This student is not approval or not exist!");
        require(numStudents < maxStudents, "This class is full!");
        require(balances[msg.sender].total >= tuitionFee, "Your wallet is not enough to pay the tuition fee - 01 ether. Please deposit ether to your wallet!");
        
        setBalance(_owner, tuitionFee);
        totalPaidTuitionFee += tuitionFee;
        balances[msg.sender].total -= tuitionFee;
        addPaidStudentToClass(msg.sender);
    }

    function setBalance(address _address, uint _value) private { 
        balances[_address].total += _value;
        Payment memory newPayment = Payment(_value, block.timestamp);
        balances[_address].numPayment = numPayment;
        balances[_address].payments[balances[_address].numPayment] = newPayment;
        numPayment++;
    }

    function addPaidStudentToClass(address studentAddress) private { 
        numStudents++;
        Student memory newStudent = Student(0, studentAddress, true, true);
        paidStudents.push(newStudent);
        _isPaid[studentAddress] = true;
    }

    function getListPaidStudent() public view returns(Student[] memory) { 
        return paidStudents;
    }

    function getNumberStudentsOfClass() public view returns(uint) { 
        return numStudents;
    }

}