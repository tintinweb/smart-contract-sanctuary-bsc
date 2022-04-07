/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface BEP20Interface {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract Ownable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    address msgSender = msg.sender;
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract ClaimDexf is Ownable, ReentrancyGuard {

    uint256 public claimCost;

    BEP20Interface public dexf;

    bool public isClaimActivated;

    mapping (address => uint256) public whiteList;
    mapping (address => uint256) public claimedAmounts;

    event Claimed(address indexed account, uint256 amount);

    constructor() {
        dexf = BEP20Interface(0xCBBd83F2CB673fDdFd46b26663A523A877a73f6B);

        claimCost = 0.0027 ether;
        isClaimActivated = true;
    }

    // write functions
    function setClaimCost(uint256 _cost) external onlyOwner {
      claimCost = _cost;
    }

    function changeClaimState() external onlyOwner {
      isClaimActivated = !isClaimActivated;
    }

    function addWhiteList(address[] memory _users, uint256[] memory _amounts) external onlyOwner {
        uint256 length = _users.length;
        require(length > 0, "Invalid address list.");

        for (uint256 i = 0; i < length; i++) {
          if (whiteList[_users[i]] < _amounts[i] ) {
            whiteList[_users[i]] = _amounts[i];
          }
        }
    }

    function removeFromWhiteList(address[] memory _users) external onlyOwner {
      for (uint256 i = 0; i < _users.length; i++) {
        whiteList[_users[i]] = 0;
      }
    }

    function claim() external payable nonReentrant {
        require(!_isContract(msg.sender), "Sender could not be a contract");
        require(whiteList[msg.sender] > 0, "Address not white listed");
        require(msg.value >= claimCost, "Invalid fund");

        require(dexf.balanceOf(address(this)) >= whiteList[msg.sender], "DEXF is not enough to send");

        dexf.transfer(msg.sender, whiteList[msg.sender]);
        claimedAmounts[msg.sender] += whiteList[msg.sender];

        emit Claimed(msg.sender, whiteList[msg.sender]);

        whiteList[msg.sender] = 0;
    }

    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function withdrawDEXF() external onlyOwner nonReentrant {
        uint256 balance = dexf.balanceOf(address(this));
        dexf.transfer(msg.sender, balance);
    }

    // check if address is contract
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}