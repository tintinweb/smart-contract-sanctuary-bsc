pragma solidity ^0.8.1;

import "./token/Ownable.sol";
import "./token/SafeMath.sol";
import "./token/IERC20.sol";

// SPDX-License-Identifier: GPL-3.0

/**
 * @dev Simple ERC20 Token example, with mintable token creation only during the deployement of the token contract */

contract DeepRootsContract is Ownable{
  using SafeMath for uint256;

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  uint256 public _TOKEN_PRICE=0;

  uint8 public _BUY_FEE=5; // default 5% fee for deep root
  uint8 public _BUY_DEV_MAR_FEE=5;  // default 5% fee for technology & development & marketing
  uint8 public _SALE_LIQUIDITY_FEE=2; // default 2% fee for liquidity 
  uint8 public _SALE_FEE=18; // default 18% fee for sale tax 
  uint8 public _REWARD_PER=100; // default 100% reward on purchase of token  
  uint8 public _REFERRAL_REWARD_PER=20; // default 100% reward on purchase of token  

  address public _ACCOUNT; // Deep Root Account
  address public _DEV_MAR_ACCOUNT;  // Development and Marketing Account
  address public _LIQUIDITY_ACCOUNT; // Liquidity Account 
  

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;
  mapping(address => bool) public vestedlist;

  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event UnlockToken();
  event LockToken();
  event Burn();
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event addedToVestedlist(address indexed _vestedAddress);
  event removedFromVestedlist(address indexed _vestedAddress);



  bool public mintingFinished = false;
  bool public locked = true;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier canTransfer() {
    require(!locked || msg.sender == owner );
    _;
  }

  modifier onlyAuthorized() {
    require(msg.sender == owner );
    _;
  }


  constructor() {
    name = "DEEP ROOTS";
    symbol = "DEEPROOTS";
    decimals = 18;
    totalSupply = 222000000;
    balances[msg.sender] = totalSupply;
    emit Transfer(address(0), msg.sender, totalSupply);


  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) public onlyAuthorized canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(this), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyAuthorized canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public canTransfer returns (bool) {
    require(_to != address(0));
	  require (!isVestedlisted(msg.sender));
    require(_value <= balances[msg.sender]);
    require (msg.sender != address(this));



    uint sale_fee = SafeMath.div(SafeMath.mul(_value,_SALE_FEE ), 100);
    uint sale_liquidity_fee = SafeMath.div(SafeMath.mul(_value,_SALE_LIQUIDITY_FEE ), 100);

    uint aftertaxedValue = SafeMath.sub(_value, sale_fee);
    aftertaxedValue = SafeMath.sub(aftertaxedValue, sale_liquidity_fee);

         
    balances[_ACCOUNT] = balances[_ACCOUNT].add(sale_fee);
    balances[_LIQUIDITY_ACCOUNT]   = balances[_LIQUIDITY_ACCOUNT].add(sale_liquidity_fee);
    balances[msg.sender]   = balances[msg.sender].sub(aftertaxedValue);
    balances[_to] = balances[_to].add(aftertaxedValue);

    emit Transfer(msg.sender, _ACCOUNT, sale_fee);
    emit Transfer(msg.sender, _LIQUIDITY_ACCOUNT, sale_liquidity_fee);
    emit Transfer(msg.sender, _to, aftertaxedValue);

 
    return true;
  }


  function burn(address _who, uint256 _value) onlyAuthorized public returns (bool){
    require(_who != address(0));

    totalSupply = totalSupply.sub(_value);
    balances[_who] = balances[_who].sub(_value);
    emit Burn();
    emit Transfer(_who, address(0), _value);
    return true;
  }

 
  function setTokenPrice(uint256 _value) onlyAuthorized public returns (bool){
    _TOKEN_PRICE =  _value;
    return true;
  }

  function setRewardPersontage(uint8 _value) onlyAuthorized public returns (bool){
    _REWARD_PER =  _value;
    return true;
  }

  function setReferralReward(uint8 _value) onlyAuthorized public returns (bool){
    _REFERRAL_REWARD_PER =  _value;
    return true;
  }

  function setBuyFee(uint8 _value) onlyAuthorized public returns (bool){
    _BUY_FEE =  _value;
    return true;
  }

  function setBuyDevAndMarFee(uint8 _value) onlyAuthorized public returns (bool){
    _BUY_DEV_MAR_FEE =  _value;
    return true;
  }

  function setSaleLiquidityFee(uint8 _value) onlyAuthorized public returns (bool){
    _SALE_LIQUIDITY_FEE =  _value;
    return true;
  }

  function setSaleFee(uint8 _value) onlyAuthorized public returns (bool){
    _SALE_FEE =  _value;
    return true;
  }

 

  function setAccount(address _value) onlyAuthorized public returns (bool){
    _ACCOUNT =  _value;
    return true;
  }

  function setDevAndMarAccount(address _value) onlyAuthorized public returns (bool){
    _DEV_MAR_ACCOUNT =  _value;
    return true;
  }

  function setLiquidityAccount(address _value) onlyAuthorized public returns (bool){
    _LIQUIDITY_ACCOUNT =  _value;
    return true;
  }
 



  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public canTransfer returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);


    uint sale_fee = SafeMath.div(SafeMath.mul(_value,_SALE_FEE ), 100);
    uint sale_liquidity_fee = SafeMath.div(SafeMath.mul(_value,_SALE_LIQUIDITY_FEE ), 100);

    uint aftertaxedValue = SafeMath.sub(_value, sale_fee);
    aftertaxedValue = SafeMath.sub(aftertaxedValue, sale_liquidity_fee);
     
    balances[_ACCOUNT] = balances[_ACCOUNT].add(sale_fee);
    balances[_LIQUIDITY_ACCOUNT]   = balances[_LIQUIDITY_ACCOUNT].add(sale_liquidity_fee);
    balances[_from]   = balances[_from].sub(aftertaxedValue);
    balances[_to] = balances[_to].add(aftertaxedValue);

    emit Transfer(_from, _ACCOUNT, sale_fee);
    emit Transfer(_from, _LIQUIDITY_ACCOUNT, sale_liquidity_fee);
    emit Transfer(_from, _to, aftertaxedValue);

    return true;

  }

  function transferFromERC20Contract(address _to, uint256 _value) public onlyOwner returns (bool) {
    require(_to != address(0));
    require(_value <= balances[address(this)]);
    balances[address(this)] = balances[address(this)].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(address(this), _to, _value);
    return true;
  }


  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function unlockToken() public onlyAuthorized returns (bool) {
    locked = false;
    emit UnlockToken();
    return true;
  }

  function lockToken() public onlyAuthorized returns (bool) {
    locked = true;
    emit LockToken();
    return true;
  }
 

    /**
     * @dev Adds list of addresses to Vestedlist. Not overloaded due to limitations with truffle testing.
     * @param _vestedAddress Addresses to be added to the Vestedlist
     */
    function addToVestedlist(address[] memory _vestedAddress) public onlyOwner {
        for (uint256 i = 0; i < _vestedAddress.length; i++) {
            if (vestedlist[_vestedAddress[i]]) continue;
            vestedlist[_vestedAddress[i]] = true;
        }
    }


    /**
     * @dev Removes single address from Vestedlist.
     * @param _vestedAddress Address to be removed to the Vestedlist
     */
    function removeFromVestedlist(address[] memory _vestedAddress) public onlyOwner {
        for (uint256 i = 0; i < _vestedAddress.length; i++) {
            if (!vestedlist[_vestedAddress[i]]) continue;
            vestedlist[_vestedAddress[i]] = false;
        }
    }


    function isVestedlisted(address _vestedAddress) internal view returns (bool) {
      return (vestedlist[_vestedAddress]);
    }


 


function buy(address referralAddress, uint256 reflag) public payable {
       
        /*
         * sends the requested amount of tokens
         * from this contract address
         * to the buyer
         */

         uint256 amountTobuy = SafeMath.div(msg.value*_TOKEN_PRICE,10**decimals);
         uint256 dexBalance = balanceOf(owner);
         require(amountTobuy > 0, "You need to send some bnb");
         require(msg.value > 0, "You need to send some bnb");
         require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
          
         uint buy_fee = SafeMath.div(SafeMath.mul(amountTobuy, _BUY_FEE), 100);
         uint buy_dev_mar_fee = SafeMath.div(SafeMath.mul(amountTobuy, _BUY_DEV_MAR_FEE), 100);


         uint totalReward = SafeMath.div(SafeMath.mul(amountTobuy, _REWARD_PER), 100);
         uint totalReferralReward = SafeMath.div(SafeMath.mul(amountTobuy, _REFERRAL_REWARD_PER), 100);


         uint aftertaxedValue = SafeMath.sub(amountTobuy, buy_fee);
         aftertaxedValue = SafeMath.sub(aftertaxedValue, buy_dev_mar_fee);

         payable(owner).transfer(msg.value);

         balances[owner] = balances[owner].sub(amountTobuy);
         balances[_ACCOUNT] = balances[_ACCOUNT].add(buy_fee);
         balances[_DEV_MAR_ACCOUNT]   = balances[_DEV_MAR_ACCOUNT].add(buy_dev_mar_fee);
         balances[msg.sender]   = balances[msg.sender].add(aftertaxedValue);
         balances[msg.sender]   = balances[msg.sender].add(totalReward);

         emit Transfer(owner, _ACCOUNT, buy_fee);
         emit Transfer(owner, _DEV_MAR_ACCOUNT, buy_dev_mar_fee);
         emit Transfer(owner, msg.sender, aftertaxedValue);
         emit Transfer(owner, msg.sender, totalReward);
          if (reflag == 1){
            balances[referralAddress]   = balances[referralAddress].add(totalReferralReward);
            emit Transfer(owner, referralAddress, totalReferralReward);

          }

     }
 
    fallback() external  payable {
           
    }

    receive() external payable {
         
    }


 

}

pragma solidity ^0.8.1;

// SPDX-License-Identifier: GPL-3.0

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized operation");
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Address shouldn't be zero");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

pragma solidity ^0.8.1;

// SPDX-License-Identifier: GPL-3.0

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

pragma solidity ^0.8.1;

// SPDX-License-Identifier: GPL-3.0

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address _owner) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}