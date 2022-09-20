/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

pragma solidity ^0.5.0;

contract Discussions{
    string  public name = "Discussions";
    mapping(address=>bool) public admin;
    mapping(address=>bool) public user;
    mapping(address=>string) public nickName;
    mapping(address=>bool) public blacklist;
    mapping(address=>bool) public blacklistedUsers;
    mapping(address=>bool) public requested;
    mapping(address=>bool) public requestedUsers;
    address public owner;
    bool open=false;
    uint256 public rate=0;
    uint256 public cost=0;
    uint256 public userCost=0;
    uint256 public userRate=0;
    uint256 public userCostOwner=10000000000000000;
    mapping(address=>uint256) public individualRate;
    mapping(address=>uint256) public individualRateAdmin;
    bool openForUsers=true;

    constructor() public {
        owner=0xe230C85389b60FDCc821c5FB66d924149d88Be29;
        admin[owner]=true;
    }

    event Message(
        address indexed _wallet,
        string _name,
        string _message
    );

    event NewRate(
        uint _rate
    );

    event NewCost(
        uint _cost
    );

    event NewUserCost(
        uint _cost
    );

    event UserRate(
        uint _rate
    );

    event NewUserRate(
        address indexed _user,
        uint _rate
    );

    event RequestForAdmission(
        address indexed _user,
        uint _value
    );

    //administration functions:
    function addAdmin(address _admin) public returns (bool success){
        require(msg.sender==owner);
        admin[_admin]=true;
        return true;
    }

    function removeAdmin(address _admin) public returns (bool success){
        require(msg.sender==owner);
        admin[_admin]=false;
        return true;
    }

    function addUser(address _user) public returns (bool success){
        require(admin[msg.sender]==true);
        require(blacklist[msg.sender]==false);
        user[_user]=true;
        return true;
    }

    function removeUser(address _user) public returns (bool success){
        require(admin[msg.sender]==true);
        require(blacklist[msg.sender]==false);
        user[_user]=false;
        return true;
    }

    function sendMessage(string memory _message) public returns (bool success){
        require(msg.sender==owner);
        emit Message(msg.sender,nickName[msg.sender],_message);
        return true;
    }

    function sendMessageAdmin(string memory _message) payable public returns (bool success){
        require(admin[msg.sender]==true);
        require(blacklist[msg.sender]==false);
        require(msg.value>=rate+individualRate[msg.sender]);
        emit Message(msg.sender,nickName[msg.sender],_message);
        return true;
    }

    function sendMessageUser(string memory _message) payable public returns (bool success){
        require(user[msg.sender]==true);
        require(blacklistedUsers[msg.sender]==false);
        require(msg.value>=userRate+individualRate[msg.sender]+individualRateAdmin[msg.sender]);
        emit Message(msg.sender,nickName[msg.sender],_message);
        return true;
    }

    function selectNicknameAdmin(string memory _name) public returns (bool success){
        require(admin[msg.sender]==true);
        require(blacklist[msg.sender]==false);
        nickName[msg.sender]=_name;
        return true;
    }

    function selectNicknameUser(string memory _name) public returns (bool success){
        require(user[msg.sender]==true);
        require(blacklistedUsers[msg.sender]==false);
        nickName[msg.sender]=_name;
        return true;
    }

    function requestAdminAdmission() payable public returns (bool success){
        require(open==true);
        require(blacklist[msg.sender]==false);
        require(blacklistedUsers[msg.sender]==false);
        require(requested[msg.sender]==false);
        require(msg.value>=cost);
        requested[msg.sender]=true;
        emit RequestForAdmission(msg.sender,msg.value);
        return true;
    }

    function requestUserAdmission() payable public returns (bool success){
        require(openForUsers==true);
        require(blacklistedUsers[msg.sender]==false);
        require(blacklist[msg.sender]==false);
        require(requestedUsers[msg.sender]==false);
        require(msg.value>=userCost+userCostOwner);
        requestedUsers[msg.sender]=true;
        emit RequestForAdmission(msg.sender,msg.value);
        return true;
    }

    function blacklistAdmin(address _user) public returns (bool success){
        require(msg.sender==owner);
        require(_user!=owner);
        blacklist[_user]=true;
        return true;
    }

    function blacklistUser(address _user) public returns (bool success){
        require(admin[msg.sender]==true);
        require(admin[_user]==false);
        require(blacklist[msg.sender]==false);
        require(_user!=owner);
        blacklistedUsers[_user]=true;
        return true;
    }

    function unblacklistAdmin(address _user) public returns (bool success){
        require(msg.sender==owner);
        blacklist[_user]=false;
        return true;
    }

    function unblacklistUser(address _user) public returns (bool success){
        require(admin[msg.sender]==true);
        require(blacklist[msg.sender]==false);
        blacklistedUsers[_user]=false;
        return true;
    }

    function openForAdminAdmission() public returns (bool success){
        require(msg.sender==owner);
        open=true;
        return true;
    }

    function closeForAdminAdmission() public returns (bool success){
        require(msg.sender==owner);
        open=false;
        return true;
    }

    function openForUserAdmission() public returns (bool success){
        require(admin[msg.sender]==true);
        require(blacklist[msg.sender]==false);
        openForUsers=true;
        return true;
    }

    function closeForUserAdmission() public returns (bool success){
        require(admin[msg.sender]==true);
        require(blacklist[msg.sender]==false);
        openForUsers=false;
        return true;
    }

    function setRate(uint _rate) public returns (bool success){
        require(msg.sender==owner);
        require(_rate>=0);
        rate=_rate;
        emit NewRate(rate);
        return true;
    }

    function setUserRate(uint _rate) public returns (bool success){
        require(admin[msg.sender]==true);
        require(blacklist[msg.sender]==false);
        require(_rate>=0);
        userRate=_rate;
        emit UserRate(userRate);
        return true;
    }

    function setIndividualRate(address _user,uint _rate) public returns (bool success){
        require(msg.sender==owner);
        require(_rate>=0);
        individualRate[_user]=_rate;
        emit NewUserRate(_user,rate);
        return true;
    }

    function setIndividualRateAdmin(address _user,uint _rate) public returns (bool success){
        require(admin[msg.sender]==true);
        require(admin[_user]==false);
        require(_user!=owner);
        require(_rate>=0);
        individualRateAdmin[_user]=_rate;
        emit NewUserRate(_user,rate);
        return true;
    }

    function setCost(uint _cost) public returns (bool success){
        require(msg.sender==owner);
        require(_cost>=0);
        cost=_cost;
        emit NewCost(cost);
        return true;
    }

    function setUserCost(uint _cost) public returns (bool success){
        require(msg.sender==owner);
        require(_cost>=0);
        userCostOwner=_cost;
        emit NewUserCost(userCost);
        return true;
    }

    function setUserCostAdmin(uint _cost) public returns (bool success){
        require(admin[msg.sender]==true);
        require(blacklist[msg.sender]==false);
        require(_cost>=0);
        userCost=_cost;
        emit NewUserCost(userCost);
        return true;
    }

    function withdrawFunds(address payable _recipient, uint _amount) public returns (bool success){
        require(address(this).balance>=_amount);
        require(msg.sender==owner);
        require(_amount>=0);
        _recipient.transfer(_amount);
        return true;
    }
    
    function getBalance() public view returns (uint){
        require(blacklist[msg.sender]==false);
        require(blacklistedUsers[msg.sender]==false);
        return address(this).balance;
    }

    function returnRate() public view returns (uint){
        require(blacklist[msg.sender]==false);
        require(blacklistedUsers[msg.sender]==false);
        if(admin[msg.sender]==true){
            return rate+individualRate[msg.sender];
        }
        else if(user[msg.sender]==true){
            return userRate+individualRate[msg.sender]+individualRateAdmin[msg.sender];
        }
        else{
            return 0;
        }
    }
}