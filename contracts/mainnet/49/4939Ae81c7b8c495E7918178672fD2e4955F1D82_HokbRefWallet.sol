/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
  function decimals() external pure returns (uint8);
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    function transferOwnership(address account) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, account);
        _owner = account;
    }

}

contract HokbRefWallet is Context, Ownable {

  struct User {
    uint256 currentid;
    uint256[] rewardid;
  }

  uint256 public rewardid;
  address public tokenReward;
  mapping(address => User) public users;
  mapping(uint256 => uint256) public rewardamount;
  
  mapping(address => bool) public permission;

  modifier onlyPermission() {
    require(permission[msg.sender], "!PERMISSION");
    _;
  }

  constructor(address _token) {
    tokenReward = _token;
    permission[msg.sender] = true;
  }

  function flagePermission(address _account,bool _flag) public onlyOwner returns (bool) {
    permission[_account] = _flag;
    return true;
  }

  function updateRewardToken(address _token) public onlyOwner returns (bool) {
    tokenReward = _token;
    return true;
  }

  function newReward(uint256 amount,address[] memory participants) external onlyPermission returns (bool) {
    rewardid += 1;
    rewardamount[rewardid] = amount;
    uint256 i;
    do{
        users[participants[i]].rewardid.push(rewardid);
        i++;
    }while(i<participants.length);
    return true;
  }

  function claim(address adr) external returns (uint256) {
    uint256 reward = getunclaim(adr);
    require(reward>0,"!ERROR: NOTHING TO CLAIM");
    IERC20(tokenReward).transfer(adr,reward);
    users[adr].currentid = users[adr].rewardid.length;
    return reward;
  }

  function getunclaim(address adr) public view returns (uint256) {
    if(users[adr].rewardid.length>users[adr].currentid){
        uint256 result;
        uint256 i = users[adr].currentid;
        do{
            result += rewardamount[users[adr].rewardid[i]];
            i++;
        }while(i<users[adr].rewardid.length);
        return result;
    }else{ return 0; }
  }

}