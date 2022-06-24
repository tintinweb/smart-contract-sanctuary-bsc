/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// contracts/BEP20.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;


interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  function burnFrom(uint256 amount) external;

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
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
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

    /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
   modifier initializer(){

       require(initializing || initialized, "Contract instance has already been initialized");

       bool isTopLevelCall = !initializing;

       if(isTopLevelCall){

           initialized = true;
           initializing = true;

       }

       _;

       if(isTopLevelCall){
           initializing = false;
       }
   }

   /**
    @dev returns true if and only if the function is running in constructor
    */
    function isConstructor() private view returns(bool){

        // returns the current address. Since code is not currently deployed when running a constructor
        address self = address(this); 
        uint cs;

        //Since the code is still not  deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is under construction or not.
        assembly {  cs := extcodesize(self) }

        return cs == 0 ? true : false;

    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] ______gap;

}

/**
 * @dev Implementation of the {GMR} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {GMRPresetMinterPauser}.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {GMR-approve}.
 */
 contract GMRBEP20Token is Initializable, IBEP20 {

    using SafeMath for uint256;

    // user https://eth-converter.com/
    uint256 private _totalSupply; // --> 1,000,000,000,000,000,000,000,000,000 (WEI) => 1B Tokens

    string private tokenName;
    string private tokenSymbol;
    uint8 private tokenDecimals;

    bool private enableStake;
    uint256 private minStake;

    uint256 private stakeTax;
    uint256 private rewardTax;
    bool private burnTax;

    uint256 private scale;
    uint256 private constant SECONDS_PER_DAY = 24 * 60 * 60;

    mapping(uint => uint256 ) private packages;
    mapping(uint=> string) private packageNames;
    mapping(uint => uint)  private packageDuration;

    IBEP20 private csr;
    address private csrp;

    struct StakeData {
        uint id;
        string package;
        uint256 intPerDay;
        uint256 duration;
        uint256 totalStaked;
        uint256 timestamp;
        bool redeemed;
    }

    struct Party {
      uint256 balance;
      uint256 staked;
      StakeData[] stakes;
      mapping(address => uint256) allowance;
    }

    struct Board {
      uint256 totalSupply;
      uint256 totalStaked;
      uint256 totalStakers;
      address owner;
      mapping(address => Party) parties;
    }

    Board private _board;

    event Stake(address indexed owner, uint256 tokens);
    event UnStake(address indexed owner, uint256 tokens);
    event StakeGain(address indexed owner, uint256 tokens);
    event Burn(uint256 tokens);

    modifier whenStakeIsEnabled {
        require(enableStake, "GMR: can only be called when staking is snabled.");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == _board.owner, "GMR: can only be called by the owner.");
        _;
    }

    modifier onlyStakeRewardTokenContract {
        require(msg.sender == address(csr), "GMR: only stake reward token can call this.");
        _;
    }

     /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals} .
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
     constructor(){
       
       _totalSupply = 1000000000000000000000000000; // --> 1,000,000,000,000,000,000,000,000,000 (WEI) => 1B Tokens
       tokenName = "GAMR TOKEN";
       tokenSymbol = "GMR";
       tokenDecimals = 18;

       scale = 2**64;
       minStake = 1e18;

       enableStake = true;

       stakeTax = 500000000000000000;
       rewardTax = 500000000000000000;
       burnTax = true;

      //  csr = msg.sender; // NB: call setCsr to set csr
       csrp = msg.sender;

       _board.owner = msg.sender;
       _board.totalSupply = _totalSupply;
       _board.parties[msg.sender].balance = _totalSupply;

       // do initial transfer
       emit Transfer(address(0x0), msg.sender, _totalSupply);

     }

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals} .
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    //  function initialize(string calldata _name, string calldata _symbol, uint256 staketax, uint256 rewardtax, IBEP20 _csr) external initializer{
       
    //    totalSupply = 1000000000000000000000000000; // --> 1,000,000,000,000,000,000,000,000,000 (WEI) => 1B Tokens
    //    tokenName = _name;
    //    tokenSymbol = _symbol;
    //    tokenDecimals = 18;

    //    scale = 2**64;
    //    minStake = 1e18;

    //    enableStake = true;

    //    stakeTax = staketax;
    //    rewardTax = rewardtax;
    //    burnTax = true;

    //    csr = _csr;
    //    csrp = msg.sender;

    //    _board.owner = msg.sender;
    //    _board.totalSupply = totalSupply;
    //    _board.parties[msg.sender].balance = totalSupply;

    //    // do initial transfer
    //    emit Transfer(address(0x0), msg.sender, totalSupply);

    //  }

    /**
    * @dev gets the token total supply
    */
    function totalSupply() public override view returns(uint256){
        return _totalSupply;
    }

    /**
    * @dev gets the name of the token
    */
     function getName() external view returns(string memory){
        return tokenName;
     }

     /**
    * @dev gets the name of the token
    */
     function name() external view returns(string memory){
        return tokenName;
     }

    /**
    * @dev gets the symbol of the token
    */
     function getSymbol() external view returns(string memory){
        return tokenSymbol;
     }

     /**
    * @dev gets the symbol of the token
    */
     function symbol() external view returns(string memory){
        return tokenSymbol;
     }

     /**
    * @dev gets the symbol of the token
    */
     function getOwner() external view returns(address){
        return _board.owner;
     }

     /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {GMR} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IGMR-balanceOf} and {IGMR-transfer}.
     */
     function getDecimals() external view returns (uint8){
       return tokenDecimals;
     }

     /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {GMR} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IGMR-balanceOf} and {IGMR-transfer}.
     */
     function decimals() external view returns (uint8){
       return tokenDecimals;
     }

     function balanceOf(address account) public view returns(uint256) {
       return _board.parties[account].balance;
     }

     function getBalance(address account) public view returns(uint256) {
       return _board.parties[account].balance;
     }

    /**
     * @dev Moves tokens `amount` from `sender` {_s} to `recipient` {_r}.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
     function internalTransfer(address _s, address _r, uint256 amt) internal {

       require(_s != address(0), "GMR: transfer must be done from zero address");
       require(_r != address(0), "GMR: transfer must be done from zero address");
       require(getBalance(_s) >= amt, "insufficient funds");

       _board.parties[_s].balance = _board.parties[_s].balance.sub(amt, "GMR: transfer amount exceeds balance");
       _board.parties[_r].balance = _board.parties[_r].balance.add(amt);

       emit Transfer(_s, _r, amt); // emit transfer event

     }

      /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
     function internalApprove(address _o, address _s, uint256 amt) internal virtual {

       require(_o != address(0), "GMR: approval must be done from zero address");
       require(_s != address(0), "GMR: approval must be done from zero address");

       _board.parties[_o].allowance[_s] = amt;

       emit Approval(_o, _s, amt); 

     }

     /**
     * @dev Send tokens to an address.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     * virtual means it can be overidden
     */
     function transfer(address recipient, uint256 amount) external virtual returns(bool){
        internalTransfer(msg.sender, recipient, amount);

        return true;
     }

     /**
     * @dev Transfer tokens from an address to another address.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {GMR};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
     function transferFrom(address sender, address recipient, uint256 amount) external virtual returns(bool){

       // transfer token
       internalTransfer(sender, recipient, amount);

       // approve transfer
       internalApprove(sender, msg.sender, _board.parties[sender].allowance[msg.sender].sub(amount, "GMR: transfer amount exceeds allowance"));

       return true;

     }

     /**
     * @dev Approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
     function approve(address spender, uint256 amount) external virtual returns(bool) {

       internalApprove(msg.sender, spender, amount);
       return true;

     }

     function allowance(address owner, address spender) external view virtual returns(uint256){
       return _board.parties[owner].allowance[spender];
     }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve}
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
     function increaseAllowance(address spender, uint256 value) external virtual returns(bool) {
        internalApprove(msg.sender, spender, _board.parties[msg.sender].allowance[spender].add(value));
        return true;
     }

     /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve}
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 value) external virtual returns (bool) {
        internalApprove(msg.sender, spender, _board.parties[msg.sender].allowance[spender].sub(value, "GMR: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function internalBurn(address account, uint256 amount ) internal virtual {

      require(account != address(0), "GMR: ");

      _board.parties[account].balance = _board.parties[account].balance.sub(amount, "GMR: amount exceeds balance");
      _board.totalSupply = _board.totalSupply.sub(amount);

      emit Transfer(account, address(0), amount);

    }

    /**
    @dev Destroys `amount` tokens from `msg.sender`
    *
    * Emits a {Transfer} event with `to` set to the zero address
    *
    * Requirements
    *
    * - `amount`
    */
    function deepBurn(uint256 amount) internal virtual {

      _board.totalSupply = _board.totalSupply.sub(amount);
      emit Transfer(msg.sender, address(0), amount);

    }

    function burn(uint256 amount) external virtual {

      require(amount <= _board.parties[msg.sender].balance, "insufficient funds");
      internalBurn(msg.sender, amount);

      emit Burn(amount);

    }

    function burnFrom(uint256 amount) external virtual {

      require(amount <= _board.parties[msg.sender].balance, "insufficient funds");
      internalBurn(msg.sender, amount);

      emit Burn(amount);

    }

    function changeAdmin(address _to) external virtual onlyOwner{

      internalTransfer(msg.sender, _to, _board.parties[msg.sender].balance);
      _board.owner = _to;

    }

    function getStakeOf(address account) public view returns (uint256) {
        return _board.parties[account].staked;
    }

    function getStakesOf(address account) public view returns (uint256) {
        return _board.parties[account].stakes.length;
    }

    function getTotalStaked() public view returns (uint256) {
        return _board.totalStaked;
    }

    function getTotalStakers() public view returns (uint256) {
        return _board.totalStakers;
    }

    function getMinimumStake() external view returns(uint256) {
        return minStake;
    }

    function setMinStake(uint256 amount) external virtual onlyOwner returns(uint256) {
         require(amount >= 1e18, "amount must be in ether (18 decimal)");
         minStake = amount;
         return minStake;
    }

    function isStakeEnabled() external view returns (bool) {
        return enableStake;
    }

    function getBoardOwner() external view returns (address){
        return _board.owner;
    }

    function setCsr(IBEP20 _csr) external virtual onlyOwner {
        csr = _csr;
    }

    function setCsrParty(address _csrp) external virtual onlyOwner {
        require(csrp != address(0x0),"GMR: address can not be 0x0");
        csrp = _csrp;
    }

    function addDays(uint timestamp, uint _days) internal pure returns (uint) {
        uint newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        return newTimestamp;
    }

    function remDaysFromNow(uint256 fromTimestamp,uint256 toTimestamp) internal pure returns (uint256) {
        if(fromTimestamp >= toTimestamp){
            return 0;
        }
        return uint256((toTimestamp - fromTimestamp) / SECONDS_PER_DAY);
    }

    function currentDaysCount(uint duration, uint256 fromTimestamp, uint256 toTimestamp) internal pure returns (uint256){
        uint256 remainingDays = remDaysFromNow(fromTimestamp, toTimestamp);
        return uint256(duration.sub(remainingDays));
    }

    function currentDayOfStake(uint duration,uint256 fromTimestamp,uint256 toTimestamp) public pure returns (uint256){
        return currentDaysCount(duration, fromTimestamp, toTimestamp);
    }

    function internalStake(uint256 amount, uint package) internal {

        require(getBalance(msg.sender) >= amount,"your balance must be greater or equal to the stake amount");
        require(amount >= minStake,"your stake is below minimum");
        require(packages[package] > 0,"unknown package");
        
        if(_board.parties[msg.sender].staked == 0){
            _board.totalStakers = _board.totalStakers.add(1); 
        }

        _board.totalStaked = _board.totalStaked.add(amount);
        _board.parties[msg.sender].balance = _board.parties[msg.sender].balance.sub(amount);
        _board.parties[msg.sender].staked = _board.parties[msg.sender].staked.add(amount);
        
        uint stakes = _board.parties[msg.sender].stakes.length;
        string memory packageName = packageNames[package];
        uint256 interest = packages[package].mul(amount).mul(scale).div(100).div(packageDuration[package]);

        _board.parties[msg.sender].stakes.push(StakeData(stakes, packageName, interest, packageDuration[package], amount, addDays(block.timestamp, packageDuration[package]), false));
        
        emit Stake(msg.sender, amount);
    }

    function stake(uint256 amount,uint package) external virtual whenStakeIsEnabled {
        internalStake(amount, package);
    }

    function unStake(uint id) external virtual {

        require(_board.parties[msg.sender].staked > 0 && _board.parties[msg.sender].stakes.length > id && id >= 0, "GMR: stake not found");

        StakeData memory pStake = _board.parties[msg.sender].stakes[id];

        require(pStake.redeemed == false, "GMR: you can't redeem stake twice");
        _board.parties[msg.sender].stakes[id].redeemed = true;

        uint256 currentDays = currentDaysCount(pStake.duration, block.timestamp, pStake.timestamp);

        require(currentDays > 0,"GMR: same day unstake not allowed");

        uint256 reward = currentDays.mul(pStake.intPerDay).div(scale);
        uint256 staked = pStake.totalStaked;

        _board.totalStaked = _board.totalStaked.sub(staked);
        _board.parties[msg.sender].staked = _board.parties[msg.sender].staked.sub(staked);

        if(_board.parties[msg.sender].staked == 0){
            _board.totalStakers = _board.totalStakers.sub(1);
        }

        if(currentDays < pStake.duration){

            uint256 reward_tax = reward.mul(rewardTax).div(100);
            uint256 staked_tax = staked.mul(stakeTax).div(100);

            reward = reward.sub(reward_tax);
            staked = staked.sub(staked_tax);

            if(burnTax){
                deepBurn(staked_tax);
                csr.burnFrom(reward_tax);
            }else{

                _board.parties[csrp].balance = _board.parties[csrp].balance.add(staked_tax);

                require(csr.transfer(csrp, reward_tax),"GMR: CSR Transfer failed");
            }

        }
        
        _board.parties[msg.sender].balance = _board.parties[msg.sender].balance.add(staked);

        require(csr.transfer(msg.sender, reward),"GMR: CSR Transfer failed ");

        emit StakeGain(msg.sender, reward);
        emit UnStake(msg.sender, pStake.totalStaked);

    }

    function getPartyDetails(address sender) external view returns (uint256 balance, uint256 staked, uint256 stakes){
       return ( getBalance(sender), getStakeOf(sender), getStakesOf(sender));
    }

    function getPartyStake(uint256 stakeId) external view returns (uint256 id, string memory package, uint256 returnPerDay, uint duration, uint256 staked,  uint256 timestamp,
        bool redeemed) {
        require(getStakesOf(msg.sender) > 0 && getStakesOf(msg.sender) > stakeId && stakeId >= 0, "GMR: stake not found");

        StakeData memory pStake = _board.parties[msg.sender].stakes[stakeId];

        return (pStake.id, pStake.package, pStake.intPerDay, pStake.duration, pStake.totalStaked, pStake.timestamp, pStake.redeemed);
    }

    function getPartyStakeReward(uint256 stakeId, uint256 atTimestamp) external view returns (uint256) {

        require(getStakesOf(msg.sender) > 0 && getStakesOf(msg.sender) > stakeId && stakeId >= 0, "GMR: stake not found");

        StakeData memory pStake = _board.parties[msg.sender].stakes[stakeId];

        uint256 currentDay = currentDaysCount(pStake.duration, atTimestamp, pStake.timestamp);

        if(currentDay == 0) { return 0; }

        return currentDay.mul(pStake.intPerDay).div(scale);
    }

    function setEnableStake(uint enable) external virtual onlyOwner returns (bool) {

        require(enable == 1 || enable == 0, "GMAR: 1|0 is required to set enable-stake");

        if(enable == 1){ 

          enableStake = true; 

        }else if(enable == 0){

          enableStake = false; 

        }

        return enableStake;
    }

    function setStakeTaxDetails(uint256 stake_tax,uint256 reward_tax) external virtual onlyOwner {

        require(stake_tax > 0 && reward_tax > 0, "GMR: unstake tax percent must be greater than zero");

        stakeTax = stake_tax;
        rewardTax = reward_tax;
    }

    function checkStakeTax() public view returns (uint256 stake_tax,uint256 reward_tax,uint256 burn_tax) {

        uint256 burnIt = burnTax == true ? 1 : 0;
        return (stakeTax, rewardTax, burnIt);

    }

    function updateTaxBurn() external virtual onlyOwner {
         burnTax = !burnTax;
    }

    function setPackage(uint256 id, uint256 interest, string calldata package_name, uint256 duration) external virtual onlyOwner {
        packages[id]= interest;
        packageNames[id] = package_name;
        packageDuration[id] = duration;
    }

    function getPackageDetails(uint256 id) public view returns (uint256 interest, string memory package_name, uint256 duration) {
        
        return (

        packages[id],
        packageNames[id],
        packageDuration[id]
        
        );
    }



 }