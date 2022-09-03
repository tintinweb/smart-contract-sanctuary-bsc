/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// SPDX-License-Identifier: MIT

//    ____                   _               _    _                     
//   |  _ \                 (_)             | |  | |                    
//   | |_) |_   _ _ __ _ __  _ _ __   __ _  | |__| | ___  _ __ ___  ___ 
//   |  _ <| | | | '__| '_ \| | '_ \ / _` | |  __  |/ _ \| '__/ __|/ _ \
//   | |_) | |_| | |  | | | | | | | | (_| | | |  | | (_) | |  \__ |  __/
//   |____/ \__,_|_|  |_| |_|_|_| |_|\__, | |_|  |_|\___/|_|  |___/\___|
//                                    __/ |                             
//                                   |___/                              

// Burn and shine
// Stay strong and wise
// From the Ashes We Will Rise

// File: ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
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
// File: SafeMath.sol



pragma solidity ^0.8.4;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// File: Ownable.sol


pragma solidity ^0.8.4;

/**
* @notice Contract is a inheritable smart contract that will add a 
* New modifier called onlyOwner available in the smart contract inherting it
* 
* onlyOwner makes a function only callable from the Token owner
*
*/
contract Ownable {
    // _owner is the owner of the Token
    address private _owner;

    /**
    * Event OwnershipTransferred is used to log that a ownership change of the token has occured
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * Modifier
    * We create our own function modifier called onlyOwner, it will Require the current owner to be 
    * the same as msg.sender
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: only owner can call this function");
        // This _; is not a TYPO, It is important for the compiler;
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    /**
    * @notice owner() returns the currently assigned owner of the Token
    * 
     */
    function owner() public view returns(address) {
        return _owner;

    }
    /**
    * @notice renounceOwnership will set the owner to zero address
    * This will make the contract owner less, It will make ALL functions with
    * onlyOwner no longer callable.
    * There is no way of restoring the owner
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @notice transferOwnership will assign the {newOwner} as owner
    *
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    /**
    * @notice _transferOwnership will assign the {newOwner} as owner
    *
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }



}
// File: Roles.sol



pragma solidity ^0.8.4;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}
// File: MinterRole.sol



pragma solidity ^0.8.4;



abstract contract MinterRole is Ownable {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

 constructor() {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender), "Only for Minter");
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyOwner {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function removeMinter(address minterToRemove) public onlyOwner {
    _removeMinter(minterToRemove);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}
// File: IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    function burn(address account, uint256 amount) external returns(bool);

    function lotteryTransfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: BurningHorse.sol

pragma solidity ^0.8.14;

contract BurningHorse is Ownable, MinterRole, ReentrancyGuard{
  
using SafeMath for uint256;
  uint private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  uint256 TSStartBlock; 
  uint256 TSEndBlock; 
  uint256 TSMax; 
  uint256 TSTotal; 
  uint256 TSChunk; 
  uint256 TSPrice;
  uint256 TSCounter;
  uint256 public burningPercentage;
  uint256 public minBnbPerBuy; 
  uint256 public commissionBurningRound;
  uint256 public maxSupply;
  uint256 private discountLastBlock;

  function _isContract(address _addr) internal view returns (bool) {
      uint256 size;
      assembly {
          size := extcodesize(_addr)
      }
      return size > 0;
  }
  
  modifier notContract() {
      require(!_isContract(msg.sender), "Contract not allowed");
      require(msg.sender == tx.origin, "Proxy contract not allowed");
      _;
  }


  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => uint256) public userBurned;
  mapping (address => bool) private _stakingAddresses;
  mapping(address => bool) private lotteryAddr;
  mapping (uint256 => uint256) commissionBurningAmount;

  function isStakingAddress(address _stakingAddr) external view returns(bool){
    return(_isStakingAddress(_stakingAddr));
  }

  function _isStakingAddress(address _stakingAddr) internal view returns(bool){
    return(_stakingAddresses[_stakingAddr]);
  }

  function isLotteryAddress(address _lotteryAddr) external view returns(bool){
    return(lotteryAddr[_lotteryAddr]);
  }

  function addStakingAddress(address _stakingAddr) public onlyOwner{
    _stakingAddresses[_stakingAddr] = true;
    emit StakingAddressAdded(_stakingAddr);
  }

  function removeStakingAddress(address _stakingAddr) public onlyOwner{
    _stakingAddresses[_stakingAddr] = false;
    emit StakingAddressRemoved(_stakingAddr);
  }

  function addLotteryAddr(address lottery) external onlyOwner{
    lotteryAddr[lottery] = true;
  }

  function removeLotteryAddr(address lottery) external onlyOwner{
    lotteryAddr[lottery] = false;
  }


  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event StakingAddressAdded(address staking);
  event StakingAddressRemoved(address staking);


  function decimals() public view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory){
    return _symbol;
  }

  function name() external view returns (string memory){
    return _name;
  }

  function totalSupply() external view returns (uint256){
    return _totalSupply;
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function decreaseMaxSupply(uint256 _newMaxSupply) external onlyOwner{
    require(_newMaxSupply > _totalSupply, "Cannot set max supply greater than current supply");
    require(_newMaxSupply <= 500000000 * 10**decimals(), "Max supply cannot exceed 500M");
    maxSupply = _newMaxSupply;
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BRHS: cannot mint to zero address");
    require(_totalSupply + amount <= maxSupply, "Exceeding the max supply");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);

    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BRHS: cannot burn from zero address");
    require(_balances[account] >= amount, "BRHS: Cannot burn more than the account owns");

    _balances[account] = _balances[account].sub(amount);
    _totalSupply = _totalSupply.sub(amount);

    userBurned[account] += amount;
  
    emit Transfer(account, address(0), amount);
  }

  function burn(uint256 amount) public returns(bool){
    _burn(msg.sender, amount);
    return true;
  }

  function burnFromContract(uint256 _amount) external onlyOwner{
    _burn(address(this), _amount);
  }

  function mint(address account, uint256 amount) public onlyMinter returns(bool){
    _mint(account, amount);
    return true;
  }

  function commissionBurningFromContract() public onlyOwner{
    require(commissionBurningAmount[commissionBurningRound] >= balanceOf(address(this)), "Not enough tokens");
    _burn(address(this), commissionBurningAmount[commissionBurningRound]);
    commissionBurningRound++;
  }

  function commissionBurning() public onlyOwner{
    require(commissionBurningAmount[commissionBurningRound] >= balanceOf(msg.sender), "Not enough tokens");
    _burn(msg.sender, commissionBurningAmount[commissionBurningRound]);
    commissionBurningRound++;
  }

  function viewCommissionBurning(uint _burningRound) public view returns(uint256){
    return(commissionBurningAmount[_burningRound]);
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    if(burningPercentage != 0) commissionBurningAmount[commissionBurningRound].add((amount / 10000) * burningPercentage);
    return true;
  }

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public nonReentrant {
    uint resLenght = receivers.length;
    uint i = 0;
    for (i; i < resLenght; ++i) {
      _transfer(msg.sender, receivers[i], amounts[i]);
    }
  }

  function transferFrom(address spender, address recipient, uint256 amount) external nonReentrant returns(bool){ 
    require(_allowances[spender][msg.sender] >= amount, "BRHS: You cannot spend that much on this account");

    _transfer(spender, recipient, amount);
    if(burningPercentage != 0) commissionBurningAmount[commissionBurningRound].add((amount / 10000) * burningPercentage);
    _approve(spender, msg.sender, _allowances[spender][msg.sender].sub(amount));
    return true;
  }

  function lotteryTransfer(address recipient, uint256 amount) external returns (bool) {
    // For the lottery.
    require(lotteryAddr[msg.sender], "Only available for the lottery");
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BRHS: transfer from zero address");
    require(_balances[sender] >= amount, "BRHS: cant transfer more than your account holds");

    _balances[sender] = _balances[sender].sub(amount, "Transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);

    emit Transfer(sender, recipient, amount);
  }

  function tranferFromContract(uint256 _amount) external onlyOwner{
    _transfer(address(this), owner(), _amount);
  }

  function getOwner() external view returns (address) {
    return owner();
  }

  function allowance(address owner, address spender) external view returns(uint256){
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BRHS: approve cannot be done from zero address");
    require(spender != address(0), "BRHS: approve cannot be to zero address");
    // Set the allowance of the spender address at the Owner mapping over accounts to the amount
    _allowances[owner][spender] = amount;

    emit Approval(owner,spender,amount);
  }

  function increaseAllowance(address spender, uint256 amount) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(amount));
    return true;
  }

  function decreaseAllowance(address spender, uint256 amount) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(amount));
    return true;
  }

  function viewUserBurned(address _address) public view returns(uint256){
    return(userBurned[_address]);
  }

  constructor(string memory token_name, string memory short_symbol, uint8 token_decimals, uint256 token_totalSupply){
    _name = token_name;
    _symbol = short_symbol;
    _decimals = token_decimals;
    _totalSupply = token_totalSupply;
    commissionBurningRound = 1;
    minBnbPerBuy = 4*10**16;
    TSTotal = 0;
    TSCounter = 0;
    discountLastBlock = 22020000;
    maxSupply = 500000000 * 10**decimals();
    
    burningPercentage = 5;  
    //   5 = 0.05% = amount * 0.0005 = (amount/10000) * 5
    //  10 = 0.1% = amount * 0.001 = (amount/10000) * 10
    //  50 = 0.5% = amount * 0.005 = (amount/10000) * 50
    // 100 = 1% = amount * 0.01 = (amount/10000) * 100

    _balances[msg.sender] = _totalSupply*2/100;
    _balances[address(this)] = _totalSupply*98/100;
    emit Transfer(address(0), msg.sender, _totalSupply*2/100);
    emit Transfer(address(0), address(this), _totalSupply*98/100);
    
    startSale(block.number, 22968060, 62500*10**decimals(), 226000000000*10**decimals());
  }

  function setBurningPercent(uint256 _newBurningPercentage) external onlyOwner{
    require(_newBurningPercentage <= 1000, "Burning fee cannot be more than 10%");
    burningPercentage = _newBurningPercentage;
  }

  function setMinBnbPerBuy(uint256 _newMinBnbPerBuy) external onlyOwner{
    minBnbPerBuy = _newMinBnbPerBuy;
  }

  function setDiscountLastBlock(uint256 _newDiscountLastBlock) external onlyOwner{
    discountLastBlock = _newDiscountLastBlock;
  }

  function buyTokens(address _refer) public payable nonReentrant {
    require(TSStartBlock <= block.number && block.number <= TSEndBlock, "The token sale has ended or has not started yet");
    require(TSTotal < TSMax || TSMax == 0, "Exceeding the maximum number of buyers");
    require(msg.value >= minBnbPerBuy, "Too small amount");
    require(msg.sender != address(0), "Cannot buy from zero address");
    uint256 _tokens;
    uint256 tknsForOneBNB = TSPrice;

    if(block.number <= discountLastBlock){
      tknsForOneBNB = 100000*10**decimals();
    }
    _tokens = (tknsForOneBNB * msg.value) / 1 ether;

    if(msg.value >= (1 ether / 2)) _tokens += _tokens * 100 / 2000; // 5% bonus if buy from 0.5 BNB

    if(msg.sender != _refer && _refer != address(0) && _refer != address(this)){
      _transfer(address(this), _refer, _tokens/10);
    }

    _transfer(address(this), msg.sender, _tokens);
    TSTotal+=_tokens;
    TSCounter++;
  }
    
  function startSale(uint256 _startBlock, uint256 _endBlock, uint256 _salePrice, uint256 _saleMax) public onlyOwner{
    TSStartBlock = _startBlock;
    TSEndBlock = _endBlock;
    TSPrice =_salePrice;
    TSMax = _saleMax;
  }
  
  function viewTokenSale() external view returns(uint256 StartBlock, uint256 EndBlock, uint256 SaleCap, uint256 Sold, uint256 SalePrice, uint256 MinBuyBNB, uint256 Counter){
    return(TSStartBlock, TSEndBlock, TSMax, TSTotal, TSPrice, minBnbPerBuy, TSCounter);
  }

  function viewTotalBurned() public view returns(uint256){
    return(IERC20(address(this)).balanceOf(address(0))/decimals());
  }

  function withdraw(uint256 amount) external onlyOwner {
    payable(owner()).transfer(amount);
  }

  function tokenReturn(address _token, uint256 _amount, address _sendTo) public onlyOwner{
    require(_token != address(0), "The returned token cannot be zero address");
    IERC20 tokenToReturn = IERC20(address(_token));
    tokenToReturn.transfer(payable(_sendTo), _amount);
  }

}