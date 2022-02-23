// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.3;

import "./IERC20.sol";
import "./Ownable.sol";
import "./EnumerableSet.sol";

contract CovidInsurance is Ownable {

  using EnumerableSet for EnumerableSet.AddressSet;

  uint8 public purchaseLimit = 4;
  uint8 public price = 60;
  uint16 public unitToPay;
  uint64 public unitAccumulate;
  uint128 public lock;
  uint256 public fee = 0.04 ether;
  uint256 private _unitPayable;
  uint256 private charityRatio;
  bool public claimStatus;
  bool public purchaseStatus;
  address usdtAddress;
  IERC20 usdt;
  EnumerableSet.AddressSet private holder;

  mapping(address => uint256) public purchaseCount;
  mapping(address => uint256[4]) public unitArray;
  mapping(address => mapping(uint256 => bool)) private claimable;
  mapping(address => bool) public claimed;

  constructor(uint128 _lock, uint256 _ratio, address _usdtAddress) {
    charityRatio = _ratio; // 248 * 1e3 / 1e6
    usdtAddress = _usdtAddress;
    usdt = IERC20(usdtAddress);
    lock = _lock;
  }

  function openToPurchase() external onlyOwner {
    purchaseStatus = true;
  }

  function purchase(uint256 unit) external payable {
    // gas efficiency
    uint256 priceUnit = price * unit * 1e18;
    // open to purchase check
    require(purchaseStatus == true, "Cannot purchase");
    // check fee sufficient
    require(msg.value == fee, "Fee insufficient");
    // check purchase count less than 4
    require(purchaseCount[msg.sender] < 4, "Exceed purchase limit");
    // check allowance bt contract
    require(usdt.allowance(msg.sender, address(this)) >= priceUnit, "Usdt allowance insufficient");
    // check amount user bought
    require(unit <= 5, "Amount Invalid");

    if (!holder.contains(msg.sender)) {
      holder.add(msg.sender);
    }
    // transfer price * uint to contract
    usdt.transferFrom(msg.sender, address(this), priceUnit);
    // transfer management fee and charity fee to owner
    usdt.transfer(owner(), priceUnit * charityRatio / 1e6);
    // transfer all bnb to owner
    payable(owner()).transfer(address(this).balance);
    // assign uint to number
    unitArray[msg.sender][purchaseCount[msg.sender]] = unit;
    unitAccumulate += uint64(unit);
    purchaseCount[msg.sender] += 1;
  }

  function endPurchase() external onlyOwner {
    purchaseStatus = false;
  }

  function _setClaimable(address account ,uint256 index) internal {
    require(index < 4, "Index invalid");
    require(unitArray[account][index] != 0, "Account never bought this");
    uint256 addToPay;
    if (claimable[account][index] == false) {
      addToPay += unitArray[account][index];
    }
    unitToPay += uint16(addToPay);
    claimable[account][index] = true;
  }

  function batchSetClaimable(address[] memory accounts, uint256[] memory indexs) external onlyOwner {
    address[] memory list = accounts;
    uint256[] memory idx = indexs;
    require(list.length == idx.length, "Length isn't the same");
    for(uint256 i = 0; i < list.length; i++) {
      _setClaimable(list[i], idx[i]);
    }
  }

  function openToClaim() external onlyOwner {
    require(purchaseStatus == false, "End purchase before claim");
    claimStatus = true;
    _unitPayable = usdt.balanceOf(address(this)) * 1e3 / unitToPay;
  }

  function setLockTime(uint128 newLockTime) external onlyOwner {
    lock = newLockTime;
  }

  function getClaimable(address account, uint256 index) public view returns (bool) {
    return claimable[account][index];
  }

  function getHolderAmount() public view returns (uint256) {
    return holder.length();  
  }

  function getUnitPayable() public view returns (uint256) {
    return _unitPayable / 1e3;
  }

  function userClaimable(address account) public view returns(uint256) {
    uint256 claimAmount = 0;
    for(uint256 i = 0; i < 5; i++) {
      if (claimable[account][i]) {
        claimAmount += unitArray[account][i];
      }
    }
    return claimAmount;
  }

  function userClaim() external {
    require(claimStatus == true, "Unable to claim");
    require(claimed[msg.sender] == false, "Duplicate claim");
    uint256 transferAmount = userClaimable(msg.sender) * _unitPayable / 1e3;
    require(transferAmount > 0, "Transfer nothing");
    require(usdt.balanceOf(address(this)) >= transferAmount , "Balance shortage");
    usdt.transfer(msg.sender, transferAmount);
    claimed[msg.sender] = true;
  }

  function exit() external onlyOwner {
    require(lock <= block.timestamp, "Lock on");
    usdt.transfer(owner(), usdt.balanceOf(address(this)));
  }
}