/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

   


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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () { }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
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
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
  address private _owner;
  address private _ico;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender()|| _ico == _msgSender() , "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

    /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function setICO(address newOwner) public onlyOwner {
    _ico = newOwner;
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

/**
* @notice Stakeable is a contract who is ment to be inherited by other contract that wants Staking capabilities
*/


contract Ozark is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) internal _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 internal _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  bool private _icoEnd;

  constructor() {
    _name = "Ozark";
    _symbol = "OZK";
    _decimals = 18;
    _totalSupply = 0;
    _icoEnd = false;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }


    /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier icoEnd() {
    require(_icoEnd == true, "OZARK: wait for ICO to END");
    _;
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external override view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external override view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external override view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external icoEnd override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external  icoEnd override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }


  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
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
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) public onlyOwner {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
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
  function _burn(address account, uint256 amount) public onlyOwner {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account] - amount;
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
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
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function icoEnded() public onlyOwner {
    _icoEnd = true;
  }

}

pragma solidity >=0.5.0 <0.9.0;


/**
* @notice Stakeable is a contract who is ment to be inherited by other contract that wants Staking capabilities
*/
contract Stakeable {


     /**
    * @notice Constructor since this contract is not ment to be used without inheritance
    * push once to stakeholders for it to work proplerly
     */
    constructor() {
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders.push();
    }


    /**
     * @notice
     * A stake struct is used to represent the way we store stakes, 
     * A Stake will contain the users address, the amount staked and a timestamp, 
     * Since which is when the stake was made
     */
    struct Stake{
        address user;
        uint256 amount;
        uint256 since;
        // This reward field is used to tell how much reward the user has earned with staking
        uint256 nextReward;
    }

    /**
    * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder{
        address user;
        Stake stake;
        
    }

    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */ 
    struct StakingSummary{
        uint256 total_amount;
        Stake[] stakes;
    }


    struct ApySummary{
        uint256 totalMinted;
        uint256 totalStaked;
        uint256 stakedRatio;
        uint256 periodRate;
        uint256 nextRebase;
        uint256 cntInvest;
    }


    /**
    * @notice 
    *   This is a array where we store all Stakes that are performed on the Contract
    *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
    */
    Stakeholder[] internal stakeholders;

    ApySummary metrics;

    
    /**
     * @notice
      rewardPerHour is 1000 because it is used to represent 0.001, since we only use integer numbers
      This will give users 0.1% reward for each staked token / H
     */
    uint256 internal rewardPerHour = 1000;


    /**
    * @notice 
    * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;

    /**
    * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
     event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);

     event Unstaked(address indexed user, uint256 amount, uint256 timestamp);


     
    /**
    * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker) internal returns (uint256){

        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex; 
    }

     /**
    * @notice
    * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
    * StakeID 
    */
    function _stake(uint256 _amount) internal{
        // Simple check so that user does not stake 0 
        require(_amount > 0, "Cannot stake nothing");
        

        // Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[msg.sender];
        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;
        // See if the staker already has a staked index or if its the first time
        if((index == 0 && stakeholders[0].stake.amount == 0)||(index == 0 && stakeholders[0].user != msg.sender) ){
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeholder(msg.sender);
            stakeholders[index].stake=(Stake(msg.sender, _amount, timestamp,0));
            stakeholders[index].stake.nextReward = stakeholders[index].stake.amount * metrics.periodRate / 10000000 / 10000000;
        }
        else {
            stakeholders[index].stake.amount+= _amount;
            stakeholders[index].stake.nextReward = stakeholders[index].stake.amount * metrics.periodRate / 10000000 / 10000000;
        }
        // Emit an event that the stake has occured
        emit Staked(msg.sender, _amount, index,timestamp);
    }


      /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
    */
    function _withdrawStake(uint256 amount, address user) internal returns(uint256){
         // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[user];
        Stake memory current_stake = stakeholders[user_index].stake;
        require(current_stake.amount >= amount, "Staking: Cannot withdraw more than you have staked");

        // Calculate available Reward first before we start modifying data
        uint256 unstaked = current_stake.amount - amount;
        // Remove by subtracting the money unstaked 
        current_stake.amount = current_stake.amount - amount;
        // If stake is empty, 0, then remove it from the array of stakes
        if(current_stake.amount == 0){
            stakeholders[user_index].stake.amount = 0;
            // Reset timer of stake
            stakeholders[user_index].stake.since = 0;
            stakeholders[user_index].stake.nextReward =0;
        }else {
            // If not empty then replace the value of it
            stakeholders[user_index].stake.amount = unstaked;
            // Reset timer of stake
            stakeholders[user_index].stake.since = block.timestamp;
            stakeholders[user_index].stake.nextReward = unstaked * metrics.periodRate / 10000000 / 10000000;

        }
        emit Unstaked(msg.sender,amount,block.timestamp);
        return amount;

     }

    /**
     * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker) internal view returns(Stake memory){
        // totalStakeAmount is used to count total staked amount of the address
        uint256 user_index = stakes[_staker];

        // Keep a summary in memory since we need to calculate this
        Stake memory stake = stakeholders[user_index].stake;
        return stake;
    }
}



contract OzarkICO is Stakeable{
    using SafeMath for uint;

    address public admin;
    address payable public treasuryAddress; // treasury
    address payable public coreAddress; // coreAddress

    uint public treasuryRaised; // this value will be in wei

    //uint public maxInvestment = 5 ether;
    uint public minInvestment = 0.05 ether;

    enum State { beforeStart, running, afterEnd, halted} // ICO states 
    State public icoState;

    uint tokenPrice =  0.0001 ether;  // 1 OZK = 0.0001 BNB
    Ozark ozk;

    // api variables
    uint256 maxPeriodRate = 75000;
    uint256 diffPeriodRate = 12000;
    uint256 objInvest = 1000000;
    uint256 rebasePeriod = 8 hours;
    uint256 weightSales = 6000000;
    uint256 multi = 10000000;

    event Rebase(uint256 timestamp);
    event Invest(address investor, uint value, uint tokens);
    event InvestMGM(address investor,address inviter, uint value, uint tokens);


    constructor(address payable ozk_address,address payable _treasury,address payable _core){
      treasuryAddress = _treasury;
      coreAddress = _core;
      admin = msg.sender; 
      icoState = State.running;
      treasuryRaised = 0;
      metrics.totalMinted = 0;
      metrics.totalStaked = 0;
      metrics.nextRebase = block.timestamp;
      metrics.cntInvest = 0;
      ozk = Ozark(ozk_address);
    }

  
    modifier onlyAdmin(){
      require(msg.sender == admin);
      _;
    }
  
  
  // emergency stop
    function halt() public onlyAdmin{
        icoState = State.halted;
    }
  
  
    function resume() public onlyAdmin{
        icoState = State.running;
    }
  
  
    function changeTreasuryAddress(address payable newTreasuryAddress) public onlyAdmin{
        treasuryAddress = newTreasuryAddress;
    }
    
    function changeCoreAddress(address payable newCoreAddress) public onlyAdmin{
        coreAddress = newCoreAddress;
    }

    // returning the balance of treasury
    function getTreasury() public view returns(uint){
        return address(treasuryAddress).balance;
    }
    
    function getCurrentPrice() public view returns(uint) {
        return tokenPrice;
    }

  
    function getCurrentState() public view returns(State){
        if(icoState == State.halted){
            return State.halted;
        }else {
            return State.running;
        }
    }




    // this function is called automatically when someone sends BNB to the contract's address
    receive () payable external{
        invest();
    }  

    // function called when sending BNB to the contract with invinte ref
    function investMGM(address mgmAddress) payable public returns(bool){ 
        icoState = getCurrentState();
        require(icoState == State.running);
        require(msg.value >= minInvestment);

        uint tokens = ((msg.value * (10**18))/ tokenPrice);
        mint(msg.sender,tokens);
        metrics.cntInvest++;


        uint treasury =  (msg.value).div(2);
        treasuryRaised += treasury; 
        treasuryAddress.transfer(treasury); // transfering the value sent to the ICO to the deposit address - %50 to treasury

        uint core = (msg.value).div(4);
        coreAddress.transfer(core); // transfering the value sent to the ICO to the deposit address - %25 to core

        uint mgm = (msg.value).div(4);
        payable(mgmAddress).transfer(mgm); // transfering the value sent to the ICO to the deposit address - %25 to inviter mgm bonus

        uint tkCore = tokens.div(10);
        mint(coreAddress, tkCore);
        
        uint tkMgm = tokens.div(10);
        mint(mgmAddress, tkMgm);

        emit InvestMGM(msg.sender, mgmAddress, msg.value, tokens);
        return true;
    }

    // function called when sending eth to the contract without invite ref
    function invest() payable public returns(bool){ 
      icoState = getCurrentState();
      require(icoState == State.running);
      require(msg.value >= minInvestment);
      
      uint tokens = ((msg.value * (10**18))/ tokenPrice);
      mint(msg.sender,tokens);
      metrics.cntInvest++;

      uint treasury =  (msg.value).div(2);
      treasuryRaised += treasury; 
      treasuryAddress.transfer(treasury); // transfering the value sent to the ICO to the deposit address - %50 to treasury

      uint core = (msg.value).div(2);
      coreAddress.transfer(core); // transfering the value sent to the ICO to the deposit address - %50 to core
      
      uint tkCore = tokens.div(10);
      mint(coreAddress, tkCore);

      emit Invest(msg.sender, msg.value, tokens);
      return true;
    }
  

  

    function mint(address account, uint256 amount) internal {
        require(account != address(0), "OZK: cannot mint to zero address");
        metrics.totalMinted += amount;
        ozk._mint(account,amount);
    }

  
  /**
    * @notice _burn will destroy tokens from an address inputted and then decrease total supply
    * An Transfer event will emit with receiever set to zero address
    *
    * Requires
    * - Account cannot be zero
    * - Account balance has to be bigger or equal to amount
    */
  function burn(address account, uint256 amount) internal {
      require(
          account != address(0),
          "OZARK: cannot burn from zero address"
      );

      ozk._burn(account,amount);
    }

    /**
    * Add functionality like burn to the _stake afunction
    *
    */
  function stake(uint256 _amount) public {
      // Make sure staker actually is good for it
      require(
          _amount <= ozk.balanceOf(msg.sender),
          "OZARK: Cannot stake more than you own"
      );
      //transferFrom(msg.sender, address(this), _amount);
      metrics.totalStaked += _amount;
      _stake(_amount);
      // Burn the amount of tokens on the sender
      burn(msg.sender, _amount);
  }

  /**
    * @notice unstake is used to withdraw stakes from the account holder
    */
  function unstake(uint256 amount) public {
      uint256 amount_to_mint = _withdrawStake(amount,msg.sender);
      // Return staked tokens to user
      metrics.totalStaked -= amount;
      mint(msg.sender, amount_to_mint);
  }

  function checkStaked(address account) public view returns(uint256 staked){
      Stake memory s = hasStake(account);
      uint256 aux = s.amount;
      if(s.user != account) {
          aux = 0;
      }
      return aux;
  }

    function getNextReward(address account) public view returns(uint256 reward){
        Stake memory s = hasStake(account);
        uint256 aux = s.nextReward;
        if(s.user != account) {
            aux = 0;
        }
        return aux;
    }

    function checkMetrics() public payable{
        uint256 checkday = block.timestamp;

        require(checkday >= (metrics.nextRebase - 30 minutes));
        metrics.nextRebase = checkday + rebasePeriod;
        periodRate();

    }

    function periodRate() internal {
        uint256 totalStaked = metrics.totalStaked;
        uint256 auxMinted = metrics.totalMinted;
        uint256 objInvestRatio = (metrics.cntInvest * multi) / objInvest;
        if(auxMinted == 0 || totalStaked > auxMinted) {
            metrics.stakedRatio = multi;
        }
        else {
            metrics.stakedRatio = (multi*totalStaked)/(auxMinted);
        }

        uint256 auxStaked = metrics.stakedRatio;
        uint256 finalRes = 270000000000;

        if(objInvestRatio > 60000000) {
            finalRes = 270000000000;
        }
        else {
            finalRes = ((((maxPeriodRate)-((diffPeriodRate*objInvestRatio)/multi))) * weightSales) + (((maxPeriodRate)-((diffPeriodRate*auxStaked)/multi))) *(multi - weightSales);
        }

        metrics.periodRate = finalRes;
        payRewards();
    }

    function payRewards() internal {
        uint256 auxPeriodRate = metrics.periodRate;
        uint256 auxTotalStaked = 0;
        for(uint i = 0; i<stakeholders.length;i++){
                stakeholders[i].stake.amount += stakeholders[i].stake.nextReward;
                stakeholders[i].stake.nextReward = stakeholders[i].stake.amount * auxPeriodRate / multi / multi;
                auxTotalStaked += stakeholders[i].stake.amount;
        }
        metrics.totalStaked = auxTotalStaked; 
        emit Rebase(block.timestamp);
    }

  
    function getTotalMinted() public view returns(uint minted) {
        return metrics.totalMinted;
    }

    function getTotalStaked() public view returns(uint minted) {
        return metrics.totalStaked;
    }

    function getPeriodRate()  public view returns(uint periodrate) {
        return metrics.periodRate;
    }

    function getStakedRatio()  public view returns(uint periodrate) {
        return metrics.stakedRatio;
    }


    function getNextRebase()  public view returns(uint nextRebase) {
        return metrics.nextRebase;
    }

    function getTotalInvestments() public view returns (uint cntInvest) {
        return metrics.cntInvest;
    }

    function getBalance(address  addrs)  public view returns (uint balance) {
        return ozk.balanceOf(addrs);
    }

    function getTotalStakeHolders() public view returns (uint length) {
        return  stakeholders.length;
    }

    function getMinInvestment() public view returns (uint minInv) {
        return  minInvestment;
    }

    function getDiffPR() public view returns (uint diffPR) {
        return  diffPeriodRate;
    }

    function getMaxPR() public view returns (uint maxPR) {
        return  maxPeriodRate;
    }

    function getObjInvest() public view returns (uint objInv) {
        return  objInvest;
    }

    function getWeight() public view returns (uint weightS) {
        return  weightSales;
    }

    
    function getRebasePeriod() public view returns (uint rbPeriod) {
        return rebasePeriod;
    }

    function getStakingHelper(uint256 index)public view returns (address user, uint256 amount) {
        return (stakeholders[index].user, stakeholders[index].stake.amount);

    }


    /*
    * Setters APY vars
    */

    function setMaxPeriodRate(uint256  max)  public payable onlyAdmin{
        maxPeriodRate = max;
    }

    function setRebaseHours(uint256  rb)  public payable onlyAdmin{
        rebasePeriod = rb;
    } 

    function setDiffPR(uint256  diff)  public payable onlyAdmin{
        diffPeriodRate = diff;
    }

    function setInvestObj(uint256  obj)  public payable onlyAdmin{
        objInvest = obj;
    } 

    function setWeightSales(uint256  wg)  public payable onlyAdmin{
        weightSales = wg;
    }

    function setTokenPrice(uint256  price)  public payable onlyAdmin{
        tokenPrice = price;
    }

    function setMinInvest(uint256  minInvest)  public payable onlyAdmin{
        minInvestment = minInvest;
    }

    function migrate(address[] memory addresses_, uint256[] memory balances_) external onlyAdmin {
        for (uint256 i = 0; i < addresses_.length; i++) {
            mint(addresses_[i], balances_[i]);
        }
    }

}