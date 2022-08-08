/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

/**
⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠛⢉⢉⠉⠉⠻⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⠟⠠⡰⣕⣗⣷⣧⣀⣅⠘⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⠃⣠⣳⣟⣿⣿⣷⣿⡿⣜⠄⣿⣿⣿⣿⣿
⣿⣿⣿⣿⡿⠁⠄⣳⢷⣿⣿⣿⣿⡿⣝⠖⠄⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠃⠄⢢⡹⣿⢷⣯⢿⢷⡫⣗⠍⢰⣿⣿⣿⣿⣿
⣿⣿⣿⡏⢀⢄⠤⣁⠋⠿⣗⣟⡯⡏⢎⠁⢸⣿⣿⣿⣿⣿
⣿⣿⣿⠄⢔⢕⣯⣿⣿⡲⡤⡄⡤⠄⡀⢠⣿⣿⣿⣿⣿⣿
⣿⣿⠇⠠⡳⣯⣿⣿⣾⢵⣫⢎⢎⠆⢀⣿⣿⣿⣿⣿⣿⣿
⣿⣿⠄⢨⣫⣿⣿⡿⣿⣻⢎⡗⡕⡅⢸⣿⣿⣿⣿⣿⣿⣿
⣿⣿⠄⢜⢾⣾⣿⣿⣟⣗⢯⡪⡳⡀⢸⣿⣿⣿⣿⣿⣿⣿
⣿⣿⠄⢸⢽⣿⣷⣿⣻⡮⡧⡳⡱⡁⢸⣿⣿⣿⣿⣿⣿⣿
⣿⣿⡄⢨⣻⣽⣿⣟⣿⣞⣗⡽⡸⡐⢸⣿⣿⣿⣿⣿⣿⣿
⣿⣿⡇⢀⢗⣿⣿⣿⣿⡿⣞⡵⡣⣊⢸⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⡀⡣⣗⣿⣿⣿⣿⣯⡯⡺⣼⠎⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣧⠐⡵⣻⣟⣯⣿⣷⣟⣝⢞⡿⢹⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⡆⢘⡺⣽⢿⣻⣿⣗⡷⣹⢩⢃⢿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣷⠄⠪⣯⣟⣿⢯⣿⣻⣜⢎⢆⠜⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⡆⠄⢣⣻⣽⣿⣿⣟⣾⡮⡺⡸⠸⣿⣿⣿⣿
⣿⣿⡿⠛⠉⠁⠄⢕⡳⣽⡾⣿⢽⣯⡿⣮⢚⣅⠹⣿⣿⣿
⡿⠋⠄⠄⠄⠄⢀⠒⠝⣞⢿⡿⣿⣽⢿⡽⣧⣳⡅⠌⠻⣿
⠁⠄⠄⠄⠄⠄⠐⡐⠱⡱⣻⡻⣝⣮⣟⣿⣻⣟⣻⡺⣊

Telegram: https://t.me/clicknBSC
*/
pragma solidity 0.8.15;

//SPDX-License-Identifier: UNLICENSED

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
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}



//RELEVANT CONTRACT CODE STARTS HERE

contract ClickN is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  uint256 public liqTax=2;
  uint256 public poolTax=2;
  uint256 public devTax=2;

  uint256 public maxTxPercentage=1; //Cant transfer more than x % of the supply at once
  uint256 public maxWalletPercentage=1; //cand hold more than x% in one wallet.

  address public devWallet=0xaEC53Aa5ab13579470bEB3D15A2ea9eE60D90b3D;

  address public oracleWallet=0x8F7e951f04d16de1380D5F73D70B569568a64c3e;

  uint256 public pool=0;

  uint256 public claimInterval=60; //24 hours 86400

  uint256 public divisor=4;

  mapping (address=>uint256) nextClaim; //next claim ts
  mapping (address=>bool) isTaxFree; //is wallet tax free?
  mapping (address=>bool) isBlacklisted; //is wallet blacklisted from transferring from and to?

    event BigBattle(address battler,uint256 battlerBalance,uint256 defenderBalance, address defender, uint256 value,bytes32 id);

  constructor()  {
    _name = "ClickN";
    _symbol = "CLKN";
    _decimals = 18;
    _totalSupply = 1000000000000000000000000000;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

//CONTRACT SPECIFIC FUNCTIONS START




  function modifyLiquidityTax(uint256 newTax) public onlyOwner{
    require(newTax<8,"Tax has to be below 8%");    
    liqTax=newTax;
  }

  function modifyPoolTax(uint256 newTax) public onlyOwner{
    require(newTax<8,"Tax has to be below 8%");    
    poolTax=newTax;
  }

  function modifyDevTax(uint256 newTax) public onlyOwner{
    require(newTax<8,"Tax has to be below 8%");
    devTax=newTax;
  }

  function modifyDevWallet (address wallet) public onlyOwner{
    devWallet=wallet;
  }

  function excludeFromTax (address wallet) public onlyOwner {
    isTaxFree[wallet]=true;
  }

  function renounceTaxFree (address wallet) public onlyOwner{
    isTaxFree[wallet]=false;
  }

  function blacklist(address wallet) public onlyOwner {
    isBlacklisted[wallet]=true;
  }

  function renounceBlacklist(address wallet) public onlyOwner {
    isBlacklisted[wallet]=false;
  }

  function modifyClaimInterval(uint256 newSeconds) public onlyOwner{
    claimInterval=newSeconds;
  }

    function modifyMaxWalletPercentage(uint256 newPercentage) public onlyOwner{
        maxWalletPercentage=newPercentage;
    }

    function modifyMaxTxPercentage (uint256 newPercentage) public onlyOwner{
        maxTxPercentage=newPercentage;
    }


  function modifyDivisor(uint256 newDivisor) public onlyOwner{
    divisor=newDivisor;
  }

  function modifyOracle(address newOracle) public onlyOwner{
      oracleWallet=newOracle;
  }
  //helper functions
  function whenIsNextClaim(address user) public view returns(uint256){
    return nextClaim[user];
  }

  function readBattleAble() public view returns(address[] memory){
    return wantToBattle;
  }

  function calculatePoolReward(address user) public view returns(uint256){
    uint256 thisReward=SafeMath.div(SafeMath.mul(_balances[user],pool),_totalSupply);
    return thisReward;
  }
  function isItBlacklisted(address user) public view returns(bool){
    return isBlacklisted[user];
  }

  function isItTaxFee(address user) public view returns(bool){
    return isTaxFree[user];
  }

  function maxTx() public view returns(uint256){
    return SafeMath.sub(_totalSupply,SafeMath.mul(SafeMath.div(_totalSupply,100),maxTxPercentage));

  }

  function maxWallet() public view returns(uint256){
    return SafeMath.sub(_totalSupply,SafeMath.mul(SafeMath.div(_totalSupply,100),maxWalletPercentage));
  }

  function calculateAmountPostTax(uint256 amountIn) public view returns(uint256){
    uint256 thisLiqTax=SafeMath.mul(SafeMath.div(amountIn,100),liqTax);
    uint256 thisPoolTax=SafeMath.mul(SafeMath.div(amountIn,100),poolTax);
    uint256 thisDevTax=SafeMath.mul(SafeMath.div(amountIn,100),devTax);


    require(amountIn>=(thisLiqTax+thisPoolTax+thisDevTax),"Calculate amount post tax will result in overflow.");
    uint256 amountOutPostTax=amountIn-thisLiqTax-thisPoolTax-thisDevTax; 
    return amountOutPostTax;
  }


  //Calc liq tax not required since we are just ignoring that amount to preserve liquidity

  function calcPoolTax(uint256 amountIn) public view returns(uint256){
    uint256 thisPoolTax=SafeMath.mul(SafeMath.div(amountIn,100),poolTax);
    return thisPoolTax;
  }
  function calcDevTax(uint256 amountIn) public view returns(uint256){
    uint256 thisDevTax=SafeMath.mul(SafeMath.div(amountIn,100),devTax);
    return thisDevTax;
  }


  //claim functions

  mapping (address=>uint256) index;
  address[] public wantToBattle;
  mapping (address=>uint256) battleReward;
  mapping (address=>bool) inBattle;


  //identified by id
  mapping(bytes32=>uint256) battleValue;
  mapping(bytes32=>address) battleWinner;
  mapping (bytes32=>address) battleBattler;
  mapping(bytes32=>address) battleDefender;

  mapping (address=>bool) pvpClaimInitiated;

  mapping(address=>bool) myLastBattleResult;
  mapping(address=>uint256) myLastBattleTimestamp;

  function readMyLastBattleTimestamp(address user) public view returns(uint256){
    return myLastBattleTimestamp[user];
  }

  function readBattleReward(address user) public view returns(uint256){
    return battleReward[user];
  }

  function readBattleWinner(bytes32 id) public view returns(address){
    return battleWinner[id];
  }
  function readMyLastBattle(address user) public view returns(bool){
    return myLastBattleResult[user];
  }

  function confirmBattle(bytes32 id,address winner) public{
    require(msg.sender==oracleWallet,"Not oracle");
    uint256 thisBattleValue=battleValue[id];
    battleWinner[id]=winner;
    pvpClaimInitiated[battleDefender[id]]=false;

    if(winner==battleDefender[id]){
          myLastBattleResult[battleDefender[id]]=true;
          myLastBattleResult[battleBattler[id]]=false;
          myLastBattleTimestamp[battleDefender[id]]=block.timestamp;
          myLastBattleTimestamp[battleBattler[id]]=block.timestamp;
    }

    if(winner==battleBattler[id]){
          myLastBattleResult[battleDefender[id]]=false;
          myLastBattleResult[battleBattler[id]]=true;
          myLastBattleTimestamp[battleDefender[id]]=block.timestamp;
          myLastBattleTimestamp[battleBattler[id]]=block.timestamp;          
    }


    inBattle[battleBattler[id]]=false;
    inBattle[battleDefender[id]]=false;
    _transfer(address(this), winner, thisBattleValue);
  }


  function startPVP(address user) public {
    uint256 reward=calculatePoolReward(msg.sender);
    require(reward>0,"Your reward is 0");
    require(block.timestamp>nextClaim[msg.sender],"Cannot enter battle at the moment. Please wait.");
    require(pvpClaimInitiated[msg.sender]==false,"You are a challenger.");
    require(inBattle[user]==true,"Requested user not in battle");
    require(_balances[msg.sender]>(_balances[user]-(_balances[user]/divisor)),"You have too small balance to battle this user.");
    require(_balances[msg.sender]<(_balances[user]+(_balances[user]/divisor)),"You have too big balance to battle this user.");

    inBattle[msg.sender]=true;
    remove(index[user]);
    require(pool>=reward,"startpvp will result in overflow");
    pool-=reward;
    uint256 battleVal=reward+battleReward[user];
    nextClaim[msg.sender]=block.timestamp+claimInterval;
    nextClaim[user]=block.timestamp+claimInterval;
    bytes32 id =keccak256(abi.encodePacked(msg.sender,user,block.timestamp));
    battleValue[id]=battleVal;
    battleBattler[id]=msg.sender;
    battleDefender[id]=user;
    emit BigBattle(msg.sender,_balances[msg.sender],_balances[user],user,battleVal,id);
    }

  function cancelPVPClaim() public {
    require(pvpClaimInitiated[msg.sender]==true,"You have not initiated PVP claim.");
    inBattle[msg.sender]=false;
    remove(index[msg.sender]);
    delete battleReward[msg.sender];
    pvpClaimInitiated[msg.sender]=false;
    pool+=battleReward[msg.sender];
  }

  function initiatePVPClaim() public {
    uint256 reward=calculatePoolReward(msg.sender);
    require(pvpClaimInitiated[msg.sender]==false,"You have already initiated PVP claim");
    require(reward>0,"Your reward is 0");
    require(block.timestamp>nextClaim[msg.sender],"Cannot enter battle at the moment. Please wait.");

    pvpClaimInitiated[msg.sender]=true;
    inBattle[msg.sender]=true;
    wantToBattle.push(msg.sender);
    index[msg.sender]=wantToBattle.length-1;
    battleReward[msg.sender]=reward;
    require(pool>=reward,"initiatePVPClaim will result in overflow");
    pool-=reward;
  }


  function claimReward() public {
    require(inBattle[msg.sender]==false,"In battle...");
    require(block.timestamp>nextClaim[msg.sender],"Cannot claim at the moment. Please wait.");
    uint256 reward=calculatePoolReward(msg.sender);
    require(reward<pool,"Pool is too small at the moment.");
    nextClaim[msg.sender]=block.timestamp+claimInterval;
    require(pool>=reward,"claimReward will result in overflow");    
    pool-=reward;
    _transfer(address(this), msg.sender, reward);
  }

    function remove(uint256 thisIndex) internal {
        if (thisIndex >= wantToBattle.length) return;

        for (uint256 i = thisIndex; i<wantToBattle.length-1; i++){
            wantToBattle[i] = wantToBattle[i+1];
        }
        wantToBattle.pop();
    }

//CONTRACT SPECIFIC FUNCTIONS END



  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view returns (uint256) {
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
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
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
   * @dev Burn `amount` tokens and decreasing the total supply.
   */
  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
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
   Here we have a x % tax

   */




  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(isBlacklisted[sender]==false,"Sender is blacklisted.");
    require(isBlacklisted[recipient]==false,"Recipient is blacklisted.");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");

    if(isTaxFree[recipient]==true){
       _balances[recipient] = _balances[recipient]+=(amount);

    emit Transfer(sender, recipient, amount);

    if(nextClaim[recipient]==0){
      nextClaim[recipient]=block.timestamp+claimInterval;
    }
    
    } else {
     uint256 currentMaxTxAmt=maxTx();
    uint256 currentMaxWalletAmt=maxWallet();

    require(amount<=currentMaxTxAmt,"ClickN: Transfer amount higher than allowed for this transaction");
    require(_balances[recipient]<=currentMaxWalletAmt,"ClickN: Wallet cannot hold more tokens at the moment.");

    uint256 newAmount=calculateAmountPostTax(amount);

    //Transfer dev tax
    uint256 thisDevTax=calcDevTax(amount);
    _balances[devWallet]+=(thisDevTax);
    //Transfer pool tax
    uint256 thisPoolTax=calcPoolTax(amount);
    _balances[address(this)]+=(thisPoolTax);
    pool+=(thisPoolTax);


    if(nextClaim[recipient]==0){
      nextClaim[recipient]=block.timestamp+claimInterval;
    }

    _balances[recipient] = _balances[recipient].add(newAmount);
    emit Transfer(sender, recipient, newAmount);

    }


    
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
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
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

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}