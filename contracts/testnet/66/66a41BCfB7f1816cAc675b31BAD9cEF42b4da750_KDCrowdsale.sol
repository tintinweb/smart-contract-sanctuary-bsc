/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

// File: [email protected]/contracts/ownership/Ownable.sol

pragma solidity ^0.4.23;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: [email protected]/contracts/math/SafeMath.sol

pragma solidity ^0.4.23;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: [email protected]/contracts/crowdsale/distribution/utils/RefundVault.sol

pragma solidity ^0.4.23;




/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  /**
   * @param _wallet Vault address
   */
  constructor(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

  /**
   * @param investor Investor address
   */
  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    emit Closed();
    wallet.transfer(address(this).balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    emit RefundsEnabled();
  }

  /**
   * @param investor Investor address
   */
  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    emit Refunded(investor, depositedValue);
  }
}

// File: [email protected]/contracts/token/ERC20/ERC20Basic.sol

pragma solidity ^0.4.23;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: [email protected]/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.23;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: [email protected]/contracts/crowdsale/Crowdsale.sol

pragma solidity ^0.4.23;




/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.transfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

// File: [email protected]/contracts/crowdsale/validation/WhitelistedCrowdsale.sol

pragma solidity ^0.4.23;




/**
 * @title WhitelistedCrowdsale
 * @dev Crowdsale in which only whitelisted users can contribute.
 */
contract WhitelistedCrowdsale is Crowdsale, Ownable {

  mapping(address => bool) public whitelist;

  /**
   * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
   */
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary]);
    _;
  }

  /**
   * @dev Adds single address to whitelist.
   * @param _beneficiary Address to be added to the whitelist
   */
  function addToWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = true;
  }

  /**
   * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
   * @param _beneficiaries Addresses to be added to the whitelist
   */
  function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
    }
  }

  /**
   * @dev Removes single address from whitelist.
   * @param _beneficiary Address to be removed to the whitelist
   */
  function removeFromWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = false;
  }

  /**
   * @dev Extend parent behavior requiring beneficiary to be in whitelist.
   * @param _beneficiary Token beneficiary
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    isWhitelisted(_beneficiary)
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

// File: [email protected]/contracts/crowdsale/validation/TimedCrowdsale.sol

pragma solidity ^0.4.23;




/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  constructor(uint256 _openingTime, uint256 _closingTime) public {
    // solium-disable-next-line security/no-block-members
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

// File: [email protected]/contracts/crowdsale/distribution/FinalizableCrowdsale.sol

pragma solidity ^0.4.23;





/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is TimedCrowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasClosed());

    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }

}

// File: [email protected]/contracts/crowdsale/distribution/RefundableCrowdsale.sol

pragma solidity ^0.4.23;





/**
 * @title RefundableCrowdsale
 * @dev Extension of Crowdsale contract that adds a funding goal, and
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale's vault.
 */
contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

  // minimum amount of funds to be raised in weis
  uint256 public goal;

  // refund vault used to hold funds while crowdsale is running
  RefundVault public vault;

  /**
   * @dev Constructor, creates RefundVault.
   * @param _goal Funding goal
   */
  constructor(uint256 _goal) public {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
  }

  /**
   * @dev Investors can claim refunds here if crowdsale is unsuccessful
   */
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  /**
   * @dev Checks whether funding goal was reached.
   * @return Whether funding goal was reached
   */
  function goalReached() public view returns (bool) {
    return weiRaised >= goal;
  }

  /**
   * @dev vault finalization task, called when owner calls finalize()
   */
  function finalization() internal {
    if (goalReached()) {
      vault.close();
    } else {
      vault.enableRefunds();
    }

    super.finalization();
  }

  /**
   * @dev Overrides Crowdsale fund forwarding, sending funds to vault.
   */
  function _forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

}

// File: [email protected]/contracts/crowdsale/validation/CappedCrowdsale.sol

pragma solidity ^0.4.23;




/**
 * @title CappedCrowdsale
 * @dev Crowdsale with a limit for total contributions.
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  /**
   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.
   * @param _cap Max amount of wei to be contributed
   */
  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  /**
   * @dev Checks whether the cap has been reached.
   * @return Whether the cap was reached
   */
  function capReached() public view returns (bool) {
    return weiRaised >= cap;
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect the funding cap.
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    require(weiRaised.add(_weiAmount) <= cap);
  }

}

// File: contracts/KDCrowdsale.sol


pragma solidity ^0.4.23;






contract KDCrowdsale is Crowdsale, CappedCrowdsale, TimedCrowdsale, WhitelistedCrowdsale, RefundableCrowdsale {

  // Track investor contributions
  uint256 public investorMinCap = 2000000000000000; // 0.002 ether
  uint256 public investorHardCap = 50000000000000000000; // 50 ether
  mapping(address => uint256) public contributions;

  constructor(
    uint256 _rate,
    address _wallet,
    ERC20 _token,
    uint256 _cap,
    uint256 _openingTime,
    uint256 _closingTime,
    uint256 _goal
  )
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(_openingTime, _closingTime)
    RefundableCrowdsale(_goal)
    public
  {
    require(_goal <= _cap);
  }

  /**
  * @dev Returns the amount contributed so far by a sepecific user.
  * @param _beneficiary Address of contributor
  * @return User contribution so far
  */
  function getUserContribution(address _beneficiary)
    public view returns (uint256)
  {
    return contributions[_beneficiary];
  }

  /**
   * @dev forwards funds to the wallet during the PreICO stage, then the refund vault during ICO stage
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }


  /**
  * @dev Extend parent behavior requiring purchase to respect investor min/max funding cap.
  * @param _beneficiary Token purchaser
  * @param _weiAmount Amount of wei contributed
  */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    uint256 _existingContribution = contributions[_beneficiary];
    uint256 _newContribution = _existingContribution.add(_weiAmount);
    require(_newContribution >= investorMinCap && _newContribution <= investorHardCap);
    contributions[_beneficiary] = _newContribution;
  }


  /**
   * @dev enables token transfers, called when owner calls finalize()
  */
  function finalization() internal {

    super.finalization();
  }

}