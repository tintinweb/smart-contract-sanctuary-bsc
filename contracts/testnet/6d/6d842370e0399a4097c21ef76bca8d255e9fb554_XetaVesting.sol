/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}
interface IERC20 {
  function transfer(address to, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}
contract XetaVesting {
  using SafeMath for uint256;
  address public xeta;
  address public owner;
  uint256 public time;
  uint256 public emission;
  uint256 public decimals;
  uint256 public deployTime;
  uint256 public nextWithdrawtime;
  string[] public userName;
  uint256[] public limit;
  struct user {
    uint256[] reward;
    uint256 maxSupply;
    address contractAddress;
    uint256 distributed;
    uint256 lastWidthdrawAmount;
    uint256 lastWidthdrawTime;
    uint256 remainingSupply;
    bool valid;
  }
  mapping (string => user) public users;
  constructor() {
    owner = msg.sender;
    deployTime = block.timestamp;
    time = 604800;
    decimals = 15;
    nextWithdrawtime = SafeMath.add(deployTime,time);
  }
  modifier onlyOwner() {
    require(msg.sender == owner, "x");
    _;
  }
  function setToken(address _token) external onlyOwner {
    xeta = _token;
  }
  function setOwner(address _owner) external onlyOwner {
    owner = _owner;
  }
  function setUser(string memory _name, uint256 _maxSupply, address _contract, uint256[] memory _rewardsArr) external onlyOwner {
    users[_name].maxSupply = _maxSupply;
    users[_name].reward = _rewardsArr;
    users[_name].contractAddress = _contract;
    users[_name].valid = true;
    bool exsistUser = true;
    for (uint256 i = 0; i < userName.length; i++){
      if(keccak256(abi.encodePacked(userName[i])) == keccak256(abi.encodePacked(_name))){
        exsistUser = false;
        break;
      }
    }
    if(exsistUser) userName.push(_name);
  }
  function setRewardList(string memory _name, uint256[] memory _rewardsArr) external onlyOwner {
    users[_name].reward = _rewardsArr;
  }
  function setLimit(uint256[] memory _limit) external onlyOwner {
    limit = _limit;
  }
  function setEmission(uint256 _emission) external onlyOwner {
    emission = _emission;
  }
  function setDecimals(uint256 _decimals) external onlyOwner {
    decimals = _decimals;
  }
  function setDeployTime(uint256 _time) external onlyOwner {
    deployTime = _time;
  }
  function setTime(uint256 _time) external onlyOwner {
    time = _time;
  }
  function setWithdrawTime(uint256 _time) external onlyOwner {
    nextWithdrawtime = _time;
  }
  function rewardList(string memory _name) public view returns(uint256[] memory){
    return users[_name].reward;
  }
 function deleteUser(string memory _name) external onlyOwner {
    require(users[_name].valid == true , "Invalid user");
    delete users[_name];
    for (uint256 i = 0; i < userName.length; i++){
      if(keccak256(abi.encodePacked(userName[i])) == keccak256(abi.encodePacked(_name))){
        userName[i] = userName[userName.length-1];
        userName.pop();
        break;
      }
    }
  }
  function releaseFunds() external onlyOwner {
    // require(block.timestamp >= nextWithdrawtime , "Time is remaining");
    for (uint256 i = 0; i < userName.length; i++) {
        if(users[userName[i]].reward[emission] > 0){
            uint256 calculated = SafeMath.mul(SafeMath.mul(users[userName[i]].reward[emission], 10 ** decimals),users[userName[i]].maxSupply);
            require(IERC20(xeta).transfer(users[userName[i]].contractAddress, calculated));
            users[userName[i]].lastWidthdrawTime = block.timestamp;
            users[userName[i]].lastWidthdrawAmount = calculated;
            uint distributedFundsCal = SafeMath.add(users[userName[i]].distributed,calculated);
            users[userName[i]].distributed = distributedFundsCal;
            users[userName[i]].remainingSupply = SafeMath.sub(users[userName[i]].maxSupply, users[userName[i]].distributed);
        }
    }
    emission++;
    nextWithdrawtime = SafeMath.add(SafeMath.mul(limit[emission],time), deployTime);
  }
  function emergencyWithdraw(address _address) external onlyOwner {
    uint256 balance =  IERC20(xeta).balanceOf(address(this));
    require(IERC20(xeta).transfer(_address, balance));
  }
}