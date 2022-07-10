/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

pragma solidity ^0.8.14;
// SPDX-License-Identifier: MIT

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * mul 
     * @dev Safe math multiply function
     */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  /**
   * add
   * @dev Safe math addition function
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev Ownable has an owner address to simplify "user permissions".
 */
contract Ownable {
  address public owner;

  /**
   * Ownable
   * @dev Ownable constructor sets the `owner` of the contract to sender
   */
  constructor ()  {
    owner = msg.sender;
  }

  /**
   * ownerOnly
   * @dev Throws an error if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * transferOwnership
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}

interface Token {
  function transfer(address _to, uint256 _value) external  returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
}

contract RBT_ICO20 is Ownable {
  using SafeMath for uint256;
  Token token;

  uint256 public  RATE = 3241917428;
  uint256 public  CAP = 4760; // Cap in BNB
  uint256 public  START = 1657391399; //Wednesday June 01 2022
  uint256 public  DAYS = 31; // 31 Days 
  // The minimum amount of Wei you must pay to participate in the RBT_ICO
  uint256 public  MinPurchase = 42 * 1e15; /** 0.042 BNB  **/

  
  uint256 public constant initialTokens = 50000000000000 * 10**16; // Initial number of tokens available
  bool public initialized = false;
  uint256 public raisedAmount = 0;
  
  /**
   * BoughtTokens
   * @dev Log tokens bought onto the blockchain
   */
  event BoughtTokens(address indexed to, uint256 value);

  /**
   * whenSaleIsActive
   * @dev ensures that the contract is still active
   **/
  modifier whenSaleIsActive() {
    // Check if sale is active
    assert(isActive());
    _;
  }
  
  constructor(address _tokenAddr)  {
      require(_tokenAddr != address(0));
      token = Token(_tokenAddr);
  }
  
  /**
   * initialize
   * @dev Initialize the contract
   **/
  function initialize() public onlyOwner {
      require(initialized == false); // Can only be initialized once
      require(tokensAvailable() == initialTokens); // Must have enough tokens allocated
      initialized = true;
  }

  /**
   * isActive
   * @dev Determins if the contract is still active
   **/
  function isActive() public view returns (bool) {
    return (
        initialized == true &&
        block.timestamp >= START && // Must be after the START date
        block.timestamp <= START.add(DAYS * 1 days) && // Must be before the end date
        goalReached() == false // Goal must not already be reached
    );
  }

  /**
   * goalReached
   * @dev Function to determin is goal has been reached
   **/
  function goalReached() public view returns (bool) {
    return (raisedAmount >= CAP * 1 ether);
  }

  /**
   * @dev Fallback function if bnb is sent to address insted of buyTokens function
   **/
  receive () external payable {
    buyTokens();
  }

  /**
   * buyTokens
   * @dev function that sells available tokens
   **/
  function buyTokens() public payable whenSaleIsActive {
    
    uint256 weiAmount = msg.value; // Calculate tokens to sell
    uint256 tokens = weiAmount.mul(RATE);

    require(msg.value > 0, "Enter a Non-Zero amount.");
    require(msg.value >= MinPurchase, "Please Enter the amount more than the minimum allowed investment." );
    
    emit BoughtTokens(msg.sender, tokens); // log event onto the blockchain
    raisedAmount = raisedAmount.add(msg.value); // Increment raised amount
    token.transfer(msg.sender, tokens); // Send tokens to buyer
    
    payable(owner).transfer(msg.value);// Send money to owner
  }

  function SetTokenRate (uint256 _rate) external onlyOwner {
    RATE = _rate;
  }

  function SetCap (uint256 _cap) external onlyOwner {
    CAP = _cap;
  }

  function SetDays (uint256 _days) external onlyOwner {
    DAYS = _days;
  }

  function SetStartTime (uint256 _startTime) external onlyOwner {
    START = _startTime;
  }

  function SetMinPurchase (uint256 _minimumInvestment) external onlyOwner {

    MinPurchase = _minimumInvestment;
  }




  /**
   * tokensAvailable
   * @dev returns the number of tokens allocated to this contract
   **/
  function tokensAvailable() public view returns (uint256) {
    return token.balanceOf(address(this));
  }

  /**
   * destroy
   * @notice Terminate contract and refund to owner
   **/
  function destroy() onlyOwner public {
    // Transfer tokens back to owner
    uint256 balance = token.balanceOf(address(this));
    assert(balance > 0);
    token.transfer(owner, balance);
    // There should be no bnb in the contract but just in case
    selfdestruct(payable(owner));
  }
}