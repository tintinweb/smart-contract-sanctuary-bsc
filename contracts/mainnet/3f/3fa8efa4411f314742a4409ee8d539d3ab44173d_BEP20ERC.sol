/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

pragma solidity ^0.5.16;

interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Burn(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }


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
 
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}
 
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
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

contract BEP20ERC is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (uint => uint256) private _stakeRewardLimit;     /** Ödül Limiti */
  mapping (uint => uint8) private _stakeRewardRates;    /** Ödül Oranları */
  mapping (uint => uint8) private _stakePenaltyRates;   /** Ceza Oranları */
  mapping (address => Order) public orders;
  mapping (address => bool) public seeds;
  mapping (address => mapping(uint => uint256)) public preOrderMapping;
  uint256 private _totalSupply;
  uint256 _phaseBalance = 7000000000;
  uint256 _paymentTotal;
  uint256 _seedFee = 1000000000;
  uint256 _seedAmount = 1000000000;
  uint256 _fee;
	uint256	_burnAmount;
  uint256 public _unLockPhaseNumber; 
  uint private _luckNumber;
  uint8 public _decimals;
  uint8 public _phaseNumber = 1;
  uint8 public _completePhaseNumber;
  uint8 public _seedBuyCount = 0;
  uint8 public _seedBuyLimit = 50;
  string public _symbol;
  string public _name;
  bool flag;
  bool public _StakeFlag = false;
  bool public _seedCompleteFlag = false;
  bool public _seedSaleFlag = false;
  bool public _preOrderCompleteFlag = false;
  address _paymentToken;
  address _stakeWallet;
  address _feeCollector;

  struct Stake {
    uint256 balance;
    uint256 lastTimeStamp;
    address stakeOwner;
    uint    stakeNum;
  }
  
  struct Order {
    uint256    balance;
    uint8[]  orderPhasenum; 
  }
  
  Stake[] public stakes;

  event stakeBuying(uint256 _stakeId, address indexed _customer);
  event stakeSold(uint256 _stakeId, address indexed _customer);
  event newPreSale(uint256 _phaseNumber, address indexed _customer);
  event newSeedSaleNotice(address indexed _customer);
  constructor() public {
    _name = "BICOT";
    _symbol = "BICOT";
    _decimals = 6;
    _totalSupply = 500000000 * 10 ** uint256(_decimals);
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function setLuckNumber (uint number) public onlyOwner returns(bool success){
    _luckNumber = number;
    return true;
  }

  /** STAKE FUNCTİON */
  
  function stakeStart(bool Flag, bool values ) public onlyOwner returns (bool _flags){
    _StakeFlag = Flag;
    if(values == true){
        _stakePenaltyRates[0] = 13; _stakePenaltyRates[1] = 15; _stakePenaltyRates[2] = 16; _stakePenaltyRates[3] = 18; _stakePenaltyRates[4] = 20;
        _stakeRewardRates[0]  = 4;  _stakeRewardRates[1] = 9;   _stakeRewardRates[2] = 20;  _stakeRewardRates[3] = 44;  _stakeRewardRates[4] = 96;
        _stakeRewardLimit[0]  = 13000000000000; _stakeRewardLimit[1] = 11000000000000; _stakeRewardLimit[2] = 9000000000000;  _stakeRewardLimit[3] = 7000000000000;
        _stakeRewardLimit[4]  = 5000000000000;
    }
    return Flag;
  }

  function stakeFlagSet(bool Flag) public onlyOwner returns(bool _flags){
    _StakeFlag = Flag;
    return Flag;
  }


  function stakeBuy(uint stakeNum, uint unlockNumber ,uint256 amount) public{
    require(_StakeFlag == true, "BICOT: Stake sale has not started");
    require(stakeNum <= 4,"BICOT:There is no such staking program.");
    require(_balances[_msgSender()] >= amount, "BICOT: Insufficient balance.");
    require(unlockNumber == _luckNumber, "BICOT: not unlocked");

    (,uint256 reward) = stakeCalculation(stakeNum,amount,block.timestamp);

    require(reward <= _stakeRewardLimit[stakeNum], "BICOT: Stake Limit Insufficient" );
   
    Stake memory stake;
    stake.balance               = amount;
    stake.stakeNum              = stakeNum;
    stake.lastTimeStamp         = stakeEndDateCalculation(stakeNum); 
    stake.stakeOwner            = _msgSender();
    stakes.push(stake);
    
    //Stake Limits Update
    _stakeRewardLimit[stakeNum] = _stakeRewardLimit[stakeNum].sub(reward);
    _balances[_msgSender()]     = _balances[_msgSender()].sub(amount);
    _balances[_stakeWallet]     = _balances[_stakeWallet].add(amount);

    emit stakeBuying(stakes.length -1, _msgSender());
  }

  function stakeSell(uint stakeId) public returns(bool _success){
    require(_StakeFlag == true, "BICOT: Stake sale has not started");
    require(stakeId<stakes.length,"BICOT: Not a valid stake id.");
    Stake storage stake = stakes[stakeId];
    require(stake.stakeOwner == _msgSender(), "BICOT: Unauthorized transaction");
    (uint256 penalty, uint256 reward) = stakeCalculation(stake.stakeNum,stake.balance,stake.lastTimeStamp);

    emit stakeSold(stakes.length -1, _msgSender());

    if (stake.lastTimeStamp >= block.timestamp)
    {
      /** penalty */      
      uint256 totelAmount                 =   stake.balance.sub(penalty);
      _balances[stake.stakeOwner]         =  _balances[stake.stakeOwner].add(totelAmount);
      _balances[_stakeWallet]             =  _balances[_stakeWallet].sub(totelAmount);
      _stakeRewardLimit[stake.stakeNum]   =  _stakeRewardLimit[stake.stakeNum].add(reward);
      delete stakes[stakeId];
      return true;
    }
    else
    {
      /** reward */ 
      uint256 totelAmount             = stake.balance.add(reward);
      _balances[stake.stakeOwner]     = _balances[stake.stakeOwner].add(totelAmount);
      _balances[_stakeWallet]         = _balances[_stakeWallet].sub(totelAmount);
      delete stakes[stakeId];
      return true;
    }
    
  }

  function stakeLimitsUpdate( uint _stakeid, uint256 _newLimits, uint8 _newReward, uint8 _newPenalty) public onlyOwner returns(bool _success){
    _stakeRewardLimit[_stakeid] = _newLimits;
    _stakeRewardRates[_stakeid] = _newReward;
    _stakePenaltyRates[_stakeid] = _newPenalty;
    return true;
  }
    
  function stakeLimitsCheck( uint _stakeid) public view returns(uint256 _limits, uint8 _reward, uint8 _penalty){
    /** TODO : Yönetici misiniz kontrolü yüklenecek */
    return (_stakeRewardLimit[_stakeid], _stakeRewardRates[_stakeid],_stakePenaltyRates[_stakeid]);
  }

// Stake Calculation
  function stakeCalculation(uint stakeNum, uint256 balances, uint256 lastTimeStamp) private view returns( uint256 punishmentRate, uint256 RewardRates){
    if(stakeNum == 0){
        // 30 Days
        punishmentRate  = balances * (_stakePenaltyRates[stakeNum]*calculateDaysRemaining(lastTimeStamp,30))/10000;
        RewardRates     = (_stakeRewardRates[stakeNum]*balances)/100;
    }else if(stakeNum == 1){
        // 60 Days
          punishmentRate = balances * (_stakePenaltyRates[stakeNum]*calculateDaysRemaining(lastTimeStamp,60))/10000;
          RewardRates     = (_stakeRewardRates[stakeNum]*balances)/100;
    }else if(stakeNum == 2){
        // 120 Days 
        punishmentRate = balances * (_stakePenaltyRates[stakeNum]*calculateDaysRemaining(lastTimeStamp,120))/10000;
        RewardRates     = (_stakeRewardRates[stakeNum]*balances)/100;
    }else if(stakeNum == 3){
        // 240 Days
          punishmentRate = balances * (_stakePenaltyRates[stakeNum]*calculateDaysRemaining(lastTimeStamp,240))/10000;
          RewardRates     = (_stakeRewardRates[stakeNum]*balances)/100;
    }else if(stakeNum == 4){
        // 480 Days
          punishmentRate = balances * (_stakePenaltyRates[stakeNum]*calculateDaysRemaining(lastTimeStamp,480))/10000;
          RewardRates     = (_stakeRewardRates[stakeNum]*balances)/100;
    }else{
        //30 Days
          punishmentRate = balances * (_stakePenaltyRates[stakeNum]*calculateDaysRemaining(lastTimeStamp,30))/10000;
          RewardRates     = (_stakeRewardRates[stakeNum]*balances)/100;
    }
    require(punishmentRate <= balances,"BICOT: Insufficient penalty amount");
    return  (punishmentRate,RewardRates);
  }

  function stakeEndDateCalculation(uint stakeNum) private view returns(uint){
    uint stakeFinisDate;
    if(stakeNum == 0){
        //30 Days
        stakeFinisDate = block.timestamp + (86400*30);
    }else if(stakeNum == 1){
        // 60 Days
        stakeFinisDate = block.timestamp + (86400*60);
    }else if(stakeNum == 2){
        // 120 Days
        stakeFinisDate = block.timestamp + (86400*120);
    }else if(stakeNum == 3){
        // 240 Days
        stakeFinisDate = block.timestamp + (86400*240);
    }else if(stakeNum == 4){
        // 480 Days
        stakeFinisDate = block.timestamp + (86400*480);
    }else{
        //30 Days
        stakeFinisDate = block.timestamp + (86400*30);
    }
    if(stakeFinisDate >= block.timestamp){
        return stakeFinisDate;
    }else{
        revert("BICOT: date could not be calculated");
    }
  }

  function calculateDaysRemaining(uint getLastTime, uint totalDay) public view returns(uint _day){
    if(getLastTime < block.timestamp){
        return  0;
    }else{
        uint diff = (getLastTime - block.timestamp) / 60 / 60 / 24;
        return totalDay.sub(diff);
    }
  }

  function createStakeWallet(address wallet, uint256 amount) public onlyOwner returns(bool success){
    _stakeWallet              = wallet;
    _balances[wallet]         = _balances[wallet].add(amount);
    _balances[_msgSender()]   = _balances[_msgSender()].sub(amount);
    return true;
  }

  /** STAKE FUNCTİON END */ 

  /** PRE SALE FUNCTİON START */ 
  function setPhaseNumber(uint8 newPhaseNumber, uint newPhaseBalance) public onlyOwner returns (bool _success){
    _phaseNumber = newPhaseNumber;
    _phaseBalance = newPhaseBalance;
    return true;
  }

  function setPaymentToken(address tokenAdres, uint256 amount)  public onlyOwner {
    _paymentToken = tokenAdres;
    _paymentTotal = amount;
  }

  function newPreOrder(uint unlockNumber) public returns(bool _success){
    require(preOrderPhasenumCheck(_msgSender()) == true , "BICOT: A pre-order has already been created.");
    require(_phaseNumber !=0,"BICOT: Stage number should not be 0.");
    require(unlockNumber == _luckNumber, "BICOT: not unlocked");
    Callee c = Callee(_paymentToken);
    bool transfer;
    transfer = c.transferFrom(_msgSender(), owner(), _paymentTotal);
    if (transfer == true){
      if(preOrderMapping[_msgSender()][_phaseNumber] <= 0){
        preOrderMapping[_msgSender()][_phaseNumber] = _phaseBalance;
      }
      emit newPreSale(_phaseNumber, _msgSender());
      return true;
    }else{
      return false;
    }
  }

  
  function preOrderPhasenumCheck(address _buyer) public view returns(bool _success){
    if(preOrderMapping[_buyer][_phaseNumber] > 0 ){
      return false; //Alım yapamaz
    }else{
      return true;  //Alım yapabilir
    }
  }

  function preOrderBalanceCheck(address _buyer) public view returns(uint256 _balance){
    return preOrderMapping[_buyer][_phaseNumber];
  }

  function setCompletePreOrderFlag(bool Flag) public onlyOwner returns(bool _flags){
    _preOrderCompleteFlag = Flag;
    return Flag;
  }

  function setUnlockPreOrderNumber(uint _Number) public returns(bool _success){
      _unLockPhaseNumber = _Number;
      return true;
  }

  function completeOrder () public returns(bool _success) {
    require(preOrderPhasenumCheck(_msgSender()) == false, "BICOT: You do not have an order.");
    require(_preOrderCompleteFlag == true, "BICOT: The flag has not been raised. No completion allowed.");
    require(_unLockPhaseNumber !=0,"BICOT: Stage number should not be 0.");
    if(preOrderMapping[_msgSender()][_unLockPhaseNumber] > 0 ){
      _balances[owner()]      = _balances[owner()].sub(preOrderMapping[_msgSender()][_unLockPhaseNumber]);
      _balances[_msgSender()] = _balances[_msgSender()].add(preOrderMapping[_msgSender()][_unLockPhaseNumber]);
      preOrderMapping[_msgSender()][_phaseNumber] = 0;
      emit Transfer(address(0), _msgSender(), preOrderMapping[_msgSender()][_unLockPhaseNumber]);
    }else{
      return false;
    }
    


  }

  /** PRE SALE FUNCTİON END */ 

  /** SEED SALE FUNCTİON START */ 
  function setSeedSaleLimits(uint256 seedFee, uint256 seedAmount, uint8 seedBuyLimit) public onlyOwner returns (bool _success){
    _seedFee      = seedFee;
    _seedAmount   = seedAmount;
    _seedBuyLimit = seedBuyLimit;
    return true;
  }


  function setCompleteStakeFlag(bool Flag) public onlyOwner returns(bool _flags){
    _seedCompleteFlag = Flag;
    return Flag;
  }

  function seedSalesFlag(bool Flag) public onlyOwner returns(bool _flags){
    _seedSaleFlag = Flag;
    return Flag;
  }

  function buySeedBicot(uint unlockNumber) public returns(bool _success){
    require(!seeds[_msgSender()], "BICOT: you have already participated in the seed sale.");
    require(_seedSaleFlag == true, "BICOT: The flag has not been raised. No completion allowed.");
    require(_seedBuyCount <= _seedBuyLimit, "BICOT: Seed sales limit has expired.");
    require(unlockNumber == _luckNumber, "BICOT: not unlocked");
    Callee c = Callee(_paymentToken);
    bool transfer;
    transfer = c.transferFrom(_msgSender(), owner(), _seedFee);
    if (transfer == true){
      _seedBuyCount = _seedBuyCount + 1;
      seeds[_msgSender()] = true;
      emit newSeedSaleNotice(_msgSender());
      return true;
    }else{
      return false;
    }
  }

  function isSeedSale() public view returns(bool){
    return seeds[_msgSender()];
  }

  function completeSeedSale () public returns(bool _success) {
    require(_seedCompleteFlag == true, "BICOT: The flag has not been raised. No completion allowed.");
    require(isSeedSale(), "BICOT: You do not have an seed order.");
    _balances[owner()] = _balances[owner()].sub(_seedAmount);
    _balances[_msgSender()] = _balances[_msgSender()].add(_seedAmount);
    emit Transfer(address(0), msg.sender, orders[_msgSender()].balance);
    delete(seeds[_msgSender()]);
    return true;
  }
  

  /** SEED SALE FUNCTİON END */ 

  /** BICOT FUNCTION END */

  function getOwner() external view returns (address) {
    return owner();
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }
 
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }


  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

 
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function mint(uint256 amount) public onlyOwner checkPermissionFlag returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  
  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  function permissionFlag(bool permission) public onlyOwner returns(bool){
    flag = permission;
    return true;
  }


  /*********** FONKSİYONLAR ******************/


  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");
    _totalSupply        = _totalSupply.add(amount);
    _balances[account]  = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }


  function _burn(address account, uint256 amount) internal returns(bool success){
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Burn(account, address(0), amount);
    return true;
  }


  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /*** Modifier ***/ 

  modifier checkPermissionFlag(){
    require(flag == true,"BICOT: No permission flag. ");
    _;
  }

}

contract Callee{
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function transfer(address _to, uint256 _value) public returns (bool success);
}