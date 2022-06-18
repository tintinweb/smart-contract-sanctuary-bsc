/**
 *Submitted for verification at BscScan.com on 2022-06-17
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
interface XetaVesting {
  function emission() external view returns (uint256);
  function distributionList(string memory name, uint256 step) external view returns (uint256);
}
contract SeedVesting{
  using SafeMath for uint256;
  address public xeta;
  address public vesting;
  address public owner;
  address[] public userAddress;
  bool public pause;
  uint256 public decimals;
  string public name;
  struct user {
    bool valid;
    uint256 claimed;
    uint256 percentage;
    uint256 emission;
  }
  mapping (address => user) public users;
  constructor() {
    owner = msg.sender;
    decimals = 20;
    name = "seed";
  }
  modifier onlyOwner() {
    require(msg.sender == owner, "x");
    _;
  }
  modifier whenNotPaused(){
    require(pause == false, "xx");
    _;
  }
  function setToken(address _token) external onlyOwner{
    xeta = _token;
  }
  function setOwner(address _owner) external onlyOwner{
    owner = _owner;
  }
  function setName(string memory _name) external onlyOwner{
    name = _name;
  }
  function setVesting(address _vesting) external onlyOwner{
    vesting = _vesting;
  }
  function setDecimals(uint256 _decimals) external onlyOwner{
    decimals = _decimals;
  }
  function setUsers(address[] calldata  _userAddress, uint256[] memory _percentage, bool update) external onlyOwner{
    require(_userAddress.length == _percentage.length , "Invalid params");
    for(uint i = 0; i < _userAddress.length; i++){
      if(update) claim(_userAddress[i]);
      users[_userAddress[i]].percentage = _percentage[i];
      if(users[_userAddress[i]].valid == false) {
      users[_userAddress[i]].valid = true;
      userAddress.push(_userAddress[i]);
      }
    }
  }
  function deleteUser(address _user) external onlyOwner{
    require(users[_user].valid == true , "Invalid user");
    delete users[_user];
    for (uint256 i = 0; i < userAddress.length; i++){
      if(userAddress[i] == _user){
        userAddress[i] = userAddress[userAddress.length-1];
        userAddress.pop();
        break;
      }
    }
  }
  function claim(address _beneficiary) public whenNotPaused{
    address beneficiary;
    if(msg.sender == owner) beneficiary = _beneficiary;
    else beneficiary = msg.sender;
    require(users[beneficiary].valid, "Invalid user");
    require(users[beneficiary].percentage > 0, "Invalid %");
    uint256 balance =  IERC20(xeta).balanceOf(address(this));
    require(balance > 0, "Insufficient Balance");
    uint256 totalEmissions = XetaVesting(vesting).emission();
    require(totalEmissions > 0, "Emission is at 0");
    require(users[beneficiary].emission < totalEmissions, "Already claimed");
    uint256 distribution;
    uint256 amount;
    for (uint256 i = users[beneficiary].emission; i < totalEmissions; i++){
      distribution = XetaVesting(vesting).distributionList(name,i);
      if(distribution > 0) amount = SafeMath.add(amount,SafeMath.div(SafeMath.mul(distribution,users[beneficiary].percentage),10 ** decimals));
    }
    users[beneficiary].emission = totalEmissions;
    users[beneficiary].claimed = SafeMath.add(users[beneficiary].claimed,amount);
    require(IERC20(xeta).transfer(beneficiary, amount));
  }
  function emergencyWithdraw(address _address) external onlyOwner{
    uint256 balance =  IERC20(xeta).balanceOf(address(this));
    require(IERC20(xeta).transfer(_address, balance));
  }
  function setPause(bool status) external onlyOwner{
    pause = status;
  }
}