/**
 *Submitted for verification at BscScan.com on 2022-03-04
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



struct Account {
    uint80 amount;
    uint8 withdrawn;
}

contract Billionica  {
    
    using SafeMath for uint;

    address public owner;
    uint public treasury;
    uint public reserve;
    uint public lastPaymentBlock;
    address payable public lastPaymentAddress; 
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
        
        
        /* checks */        
        require(30000000 gwei == msg.value, "Amount must be 0.003 BNB");
        

        /* credit treasury (pool) */        
        treasury += 20000000 gwei;
        reserve += 10000000 gwei;

        lastPaymentBlock = block.number;
        lastPaymentAddress = payable(msg.sender);
       
        
        emit Payment(msg.sender, msg.value);
        
    }


    function withdrawAccountFunds() public noReentrant {

        require(msg.sender == lastPaymentAddress, "Not a last payer");
        require(block.number.sub(lastPaymentBlock) > 30, "Too early to witdraw, wait 30 blocks");
        require(treasury > 0, "No funds to withdraw");
        uint _amount = treasury / 100 * 90;
        treasury = treasury - _amount;
        lastPaymentAddress = payable(0);
        lastPaymentBlock = 0;

        (bool sent,) = msg.sender.call{value: _amount}("");
        require(sent, "Withdrawal failed");

        emit Withdrawal(msg.sender, _amount);
    }

    

    function getTreasuryBalance() view public returns (uint){
        return treasury;
    }

    
    function getContractBalance() view public returns (uint){
        return address(this).balance;
    }

    fallback() external {}

    receive() external payable {
        _pay();
    }



    /* admin methods */
    function withdrawReserve() public onlyOwner noReentrant {
        
        (bool sent,) = msg.sender.call{value: reserve}("");
        reserve=0;
        require(sent, "Withdrawal failed");        
    }
    
    function addTreasury() public payable onlyOwner {
        treasury = uint80(treasury.add(msg.value));
    }

    
}