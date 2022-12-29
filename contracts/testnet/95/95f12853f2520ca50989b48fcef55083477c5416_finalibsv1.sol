/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.17; 

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

pragma solidity ^0.8.17;

interface Dailytest {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external payable returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external payable returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Contractable {
    address public _contract;
    constructor() {
        _contract = msg.sender;
    }

    function contracto() public view returns (address) {
       return _contract;
    }

    modifier onlyContract() {
        require(_contract == msg.sender, "contract: caller is not the contract");
        _;
    } 
}

contract finalibsv1 is Contractable {
    using SafeMath for uint256; 
    Dailytest public Busd;
    address private owner;
    uint256 public startTime;
    address public _usdtAddr;
    
    struct User {
        uint user_id;
        address user_address;
        bool is_exist;
    }

    mapping(address => User) public users;
    mapping(address => uint) balance;
    event RegUserEvent(address indexed UserAddress, uint UserId);
    event InvestedEvent(address indexed UserAddress, uint256 InvestAmount);
    event LevelEarnEvent(address [] Caller, uint256 [] Earned);
    event BoostEarnEvent(address [] Caller, uint256 [] Earned);
    event ClubEarnEvent(address [] Caller, uint256 [] Earned);
    event SelfLeaderEarnEvent(address Caller, uint256 Earned);
    event LeaderEarnedEvent(address [] Caller, uint256 [] Earned);
    event WithdrawEvent(address Caller, uint256 Earned);
    
    constructor() {
        _usdtAddr = address(0xbc57617305F6957752F86359AD6974c1CF03cce2);
        Busd = Dailytest(_usdtAddr);
        startTime = block.timestamp;
    }

    function addUsers(uint _user_id) external {
        require(users[msg.sender].is_exist == false,  "User Exist");
        users[msg.sender] = User({
            user_id: _user_id,
            user_address: msg.sender,
            is_exist: true
        });
        //totalUser = totalUser.add(1);
        emit RegUserEvent(msg.sender, _user_id);
    }

    function simpinvest(uint256 _amount, address[] memory _incleveladd, uint256[] memory _inclevelcomm, address[] memory _incleadadd, uint256[] memory _incleadbonus, uint256 _selfleadbonus) external payable {
        require(users[msg.sender].is_exist == true,  "User not Exist");
        Busd.transferFrom(msg.sender, address(this), _amount);
        emit InvestedEvent(msg.sender,_amount);
         /* level bonus to array users */
        if(_incleveladd.length>0){
            sendmul(_incleveladd,_inclevelcomm);
            emit LevelEarnEvent(_incleveladd,_inclevelcomm);
        }
        /* Leader bonus to array users */
        if(_incleadadd.length>0){
            sendmul(_incleadadd,_incleadbonus);
            emit LeaderEarnedEvent(_incleadadd,_incleadbonus);
        }
        /* Leader bonus to self */
        if(_selfleadbonus>0){
            Busd.transfer(msg.sender, _selfleadbonus);
            //payable(msg.sender).transfer(_selfleadbonus);
            emit SelfLeaderEarnEvent(msg.sender,_selfleadbonus);
        }
    }

    function reinvest(uint256 _reamount, uint256 _actInvestment, address[] memory _incleveladdress, uint256[] memory _inclevelcommission, address[] memory _incleadaddress, uint256[] memory _incleadbonuses, uint256 _selfleadbonuses) external payable {
        require(users[msg.sender].is_exist == true,  "User not Exist");
        Busd.transferFrom(msg.sender, address(this), _reamount);
        emit InvestedEvent(msg.sender,_reamount);
        /* 15% to withdraw to investment */
        uint256 per = _actInvestment.mul(15).div(100);
        uint256 withdrawamt = _actInvestment.add(per);
        if(withdrawamt>0){
            Busd.transfer(msg.sender, withdrawamt);
            //payable(msg.sender).transfer(withdrawamt);
            emit WithdrawEvent(msg.sender,withdrawamt);
        }

        /* level bonus to array users */
        if(_incleveladdress.length>0){
            sendmul(_incleveladdress,_inclevelcommission);
            emit LevelEarnEvent(_incleveladdress,_inclevelcommission);
        }
        /* Leader bonus to array users */
        if(_incleadaddress.length>0){
            sendmul(_incleadaddress,_incleadbonuses);
            emit LeaderEarnedEvent(_incleadaddress,_incleadbonuses);
        }
        /* Leader bonus to self */
        if(_selfleadbonuses>0){
            Busd.transfer(msg.sender, _selfleadbonuses);
            //payable(msg.sender).transfer(_selfleadbonuses*(10**18));
            emit SelfLeaderEarnEvent(msg.sender,_selfleadbonuses);
        }
    }

    function clubIncome(address[] memory _clubAdd, uint256[] memory _clubComm) external payable {
        require(users[msg.sender].is_exist == true,  "User not Exist");
        if(_clubAdd.length>0){
            sendmul(_clubAdd,_clubComm);
            emit ClubEarnEvent(_clubAdd,_clubComm);
        }
    }

    function boostIncome(address[] memory _boostadd, uint256[] memory _boostcomm) external payable {
        require(users[msg.sender].is_exist == true,  "User not Exist");
        if(_boostadd.length>0){
            sendmul(_boostadd,_boostcomm);
            emit BoostEarnEvent(_boostadd,_boostcomm);
        }
    }

    function sendmul(address[] memory _leveladd, uint256[] memory _levelcomm) internal {
        for(uint256 i = 0; i < _leveladd.length; i++){
            Busd.transfer(_leveladd[i], _levelcomm[i]);
            //payable(_leveladd[i]).transfer(_levelcomm[i]);
        }
    }

}