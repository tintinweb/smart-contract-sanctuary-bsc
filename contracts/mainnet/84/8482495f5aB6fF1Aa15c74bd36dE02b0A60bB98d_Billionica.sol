/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT



library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }
}

contract Billionica  {
    
    using SafeMath for uint;

    address internal owner;
    address payable public lastPaymentAddress; 
    uint public treasury;
    uint internal reserve;
    uint public lastPaymentBlock;
    bool internal locked;

    event Payment(address, uint);
    event Withdrawal(address, uint);
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
    
    function pay() external payable {
        _pay();
    }

    function _pay() internal  {
           
        require(msg.value == 10000000 gwei, "Amount must be 0.01 BNB");
        treasury += 7000000 gwei;
        reserve +=  3000000 gwei;
        lastPaymentBlock = block.number;
        lastPaymentAddress = payable(msg.sender);
        emit Payment(msg.sender, msg.value); 
    }


    function withdrawAccountFunds() public noReentrant {

        require(msg.sender == lastPaymentAddress, "Not the last payer");
        require(block.number.sub(lastPaymentBlock) >= 100, "Wait 100 blocks to withdraw");
        require(treasury > 0, "No funds");

        /* 90% of the pool is paid out, rest is left for next round */
        uint _amount = treasury * 90 / 100;
        treasury = treasury - _amount;
        lastPaymentAddress = payable(0);
        lastPaymentBlock = 0;

        (bool sent,) = msg.sender.call{value: _amount}("");
        assert(sent);
        emit Withdrawal(msg.sender, _amount);
    }

    function getTreasuryBalance() view public returns (uint){
        return treasury;
    }
    
    function getContractBalance() view public returns (uint){
        return address(this).balance;
    }

    fallback() external payable {
        _pay();
    }

    receive() external payable {
        _pay();
    }

    function withdrawReserve() public onlyOwner noReentrant {
        
        (bool sent,) = msg.sender.call{value: reserve}("");
        reserve=0;
        assert(sent);
    }
    
    function addTreasury() public payable onlyOwner {
        treasury = uint(treasury.add(msg.value));
    }

    
}