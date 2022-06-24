/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
interface XetaVesting {
  function emission() external view returns (uint256);
  function distributionList(string memory name, uint256 step) external view returns (uint256);
}
contract SeedVesting{
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
  function setName(string calldata _name) external onlyOwner{
    name = _name;
  }
  function setVesting(address _vesting) external onlyOwner{
    vesting = _vesting;
  }
  function setDecimals(uint256 _decimals) external onlyOwner{
    decimals = _decimals;
  }
  function setUsers(address[] calldata  _userAddress, uint256[] calldata _percentage) external onlyOwner{
    require(_userAddress.length == _percentage.length , "Invalid params");
    uint256 percentage;
    for(uint i = 0; i < _userAddress.length; i++){
      if(users[_userAddress[i]].valid) claim(_userAddress[i]);
      users[_userAddress[i]].percentage = _percentage[i];
      if(users[_userAddress[i]].valid == false) {
      users[_userAddress[i]].valid = true;
      userAddress.push(_userAddress[i]);
      }
      percentage += _percentage[i];
    }
    require(percentage == 100000000000000000000, "~100%");
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
    uint256 balance =  address(this).balance;
    require(balance > 0, "Insufficient Balance");
    uint256 totalEmissions = XetaVesting(vesting).emission();
    require(totalEmissions > 0, "Emission is at 0");
    require(users[beneficiary].emission < totalEmissions, "Already claimed");
    uint256 distribution;
    uint256 amount;
    for (uint256 i = users[beneficiary].emission; i < totalEmissions; i++){
      distribution = XetaVesting(vesting).distributionList(name,i);
      if(distribution > 0) amount += distribution;
    }
    amount = (amount * users[beneficiary].percentage) / 10 ** decimals;
    users[beneficiary].emission = totalEmissions;
    users[beneficiary].claimed += amount;
    (bool success, ) = beneficiary.call{value: amount}("");
    require(success, "Error");
  }

  function emergencyWithdraw(address _address) external onlyOwner{
    (bool success, ) = _address.call{value: address(this).balance}("");
    require(success, "Error");
  }
  function setPause(bool status) external onlyOwner{
    pause = status;
  }
}