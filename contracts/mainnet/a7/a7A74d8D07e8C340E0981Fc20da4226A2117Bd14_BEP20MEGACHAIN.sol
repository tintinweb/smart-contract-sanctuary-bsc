/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

pragma solidity 0.8.13;

interface IBEP20 {
  // IBEP20 Interface
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
  event Approval(address indexed owner, address indexed spender, uint256 value);
  

  //Authen View
  function stakingPools() external view returns (uint256);
  function yourLastRewardCode(address _user) external view returns (uint256);
  function yourReward(address _user) external view returns (uint256);
  function supplInvestment() external view returns (uint256);
  function hardcapInvestment() external view returns (uint256);
  function CheckBalanceOf(string memory _symbolCheck, address _userAdd) external view returns(uint256);
  
  //Authen Function
  function authDeposit(uint256 _amount, string memory _symbToken) external payable returns (bool);
  function BisStaking(uint _amount, string memory _symbToken) external;
  function GoStaking(uint256 _amount) external payable;
  function withdrawReward(uint256 _amount, string memory _symbToken) external;
  function withdrawToken(uint _amount, string memory _symbToken) external;
}


contract Context {
  constructor() { }
  function _msgSender() internal  view returns (address) {
    return msg.sender;
  }
  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
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

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }


  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}




contract BEP20MEGACHAIN is Context, IBEP20, Ownable {

  string[] private tokenSymbol;
  mapping (string => address) private tokenPayment;
  
  struct Authenticator{
      uint256    _totalSpend; 
      uint256    _deposit;
      uint256    _tokenTurnCount;
      uint8      _breaker;
  }
  struct TournamentStaking{
      uint256    _IDpricePools;
      uint256    _IDspendAmount;  
      uint256    _IDearnNumber;  
      address    _IDaddressAuthenticator;
      address    _coinBase;       
      uint256    _gasLimit;
      uint256    _timeStampCall;
  }

  mapping (address => Authenticator) private _authenticatorInfs;
  TournamentStaking[] private _tournamentStaking;

  mapping (string => mapping (uint256 => uint256) ) private xMult;
  mapping (address => uint256) private result;
  mapping (address => uint) private _yourEarn;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  
  uint256 private lastEarnNumber; 
  uint256 private _stakingPayments;
  uint8 private _StakeStatus;
  uint256 private j;
  uint8[] private _x1 = [ 1,
                          11,19];
  uint8[] private _x2 = [2,
                          22,29];
  uint8[] private _x3 = [3,
                          33,39];
  uint8[] private _x4 = [ 4,
                          44,49];
  uint8[] private _x5 = [5,
                          55,59];
  uint8[] private _x6 = [6,
                          66,69];
  uint8[] private _x7 = [7,
                          77,79];
  uint8[] private _x8 = [8,
                          88,89];                                                                                                                                                    
  uint8[] private _x10 = [10,
                          99];
  
  uint256 private _totalSupply;
  uint256 private _maxSupply;  
  uint256 private _hardcapInves;
  uint256 private _supplyInves;
  string private _symbol;
  string private _name;
  uint8 private _decimals;
  uint256 private _tokenTake;
  uint256 private _rewarded;
  uint256 private _stakingPools;
  uint256 private _bisPrice;
  using SafeMath for uint256;

  constructor() {
    _name = "MEGA CHAIN";
    _symbol = "BIS";
    _decimals       = 18;
    _maxSupply      = 20000000000000000000000000;
    _supplyInves    = 10000000000000000000000000;
    _hardcapInves   = 10000000000000000000000;
    _totalSupply    = 0;
    
    uint8 i;
    //x1
    for (i=1 ; i<_x1.length ; i++){
        xMult["x10"][_x1[i]] = _x1[0];
    }
    //x2
    for (i=1 ; i<_x2.length ; i++){
        xMult["x10"][_x2[i]] = _x2[0];
    }   
    //x3
    for (i=1 ; i<_x3.length ; i++){
        xMult["x10"][_x3[i]] = _x3[0];
    }
    //x4
    for (i=1 ; i<_x4.length ; i++){
        xMult["x10"][_x4[i]] = _x4[0];
    }   
    //x5
    for (i=1 ; i<_x5.length ; i++){
        xMult["x10"][_x5[i]] = _x5[0];
    }
    //x6
    for (i=1 ; i<_x6.length ; i++){
        xMult["x10"][_x6[i]] = _x6[0];
    }   
    //x7
    for (i=1 ; i<_x7.length ; i++){
        xMult["x10"][_x7[i]] = _x7[0];
    }
    //x8
    for (i=1 ; i<_x8.length ; i++){
        xMult["x10"][_x8[i]] = _x8[0];
    }   
    //x10
    for (i=1 ; i<_x10.length ; i++){
        xMult["x10"][_x10[i]] = _x10[0];
    }
    _StakeStatus = 1;
    _tournamentStaking.push(TournamentStaking(_maxSupply,_decimals,_totalSupply,msg.sender,block.coinbase,block.gaslimit,block.timestamp));
    _bisPrice = 10**_decimals;
  }

  function BisStaking(uint256 _amount, string memory _symbToken) external{
    require(_amount > 0); 
    require(_StakeStatus != 0, 'So sorry, Projects is Updating, pls wating for a new Update!'); 
    require(_hardcapInves >= _amount);
    require(_supplyInves >= _amount);
    if (_totalSupply == 0){ 
      _bisPrice = 10**_decimals; 
    }else{
      _bisPrice = _stakingPools.mul(10**_decimals).div(_totalSupply); 
      if (_bisPrice < (10**_decimals)){
        _bisPrice = 10**_decimals; 
      }
    } 
    _tokenTake = _amount.mul(10**_decimals).div(_bisPrice)*950/1000;
    require(_supplyInves.sub(_tokenTake) >= 0 ); 
    require(_totalSupply.add(_tokenTake) <= _maxSupply); 
    require(IBEP20(tokenPayment[_symbToken]).transferFrom(msg.sender,address(this),_amount),'Deposit Fail'); 
    _supplyInves = _supplyInves.sub(_tokenTake);
    _hardcapInves = _hardcapInves.sub(_tokenTake);
    _totalSupply = _totalSupply.add(_tokenTake); 
    _balances[msg.sender] = _balances[msg.sender].add(_tokenTake); 
    _stakingPools = _stakingPools.add(_amount); 
  }

  function authDeposit(uint256 _amount, string memory _symbToken) external payable returns (bool){
    require(_amount > 0, 'Deposit Fail');
    require(IBEP20(tokenPayment[_symbToken]).transferFrom(msg.sender,address(this),_amount),'Overcharge Balance!'); 
    _authenticatorInfs[msg.sender]._deposit = _amount; 
    _stakingPayments = _stakingPayments.add(_amount);
    return true;
  }
  
  function GoStaking(uint256 _amount) external payable {
      require(_amount >= 10**_decimals); 
      require(_StakeStatus != 0, 'So sorry, Projects is Updating, pls wating for a new Update!'); 
      require(_stakingPools.div(10) >= _amount,'Sovereign Yield Spread!');
      require(_authenticatorInfs[msg.sender]._deposit >= _amount);
      _stakingPools = _stakingPools.add(_amount); 
      _stakingPayments = _stakingPayments.add(_amount);
      _authenticatorInfs[msg.sender]._deposit =  _authenticatorInfs[msg.sender]._deposit.sub(_amount);
      if (_tournamentStaking.length < 1){ 
        result[msg.sender] = uint256(keccak256(abi.encodePacked(msg.sender,_amount,gasleft(),block.number,block.coinbase,block.timestamp,msg.sig,block.difficulty,_stakingPayments)))%100;
      } else {
        j = uint256(keccak256(abi.encodePacked(msg.sender,_authenticatorInfs[msg.sender]._tokenTurnCount,gasleft(),block.number,block.coinbase,block.timestamp,msg.sig,block.difficulty,_stakingPayments)))%_tournamentStaking.length;
        result[msg.sender] = uint256(keccak256(abi.encodePacked(msg.sender,block.timestamp,block.coinbase,block.number,_amount,lastEarnNumber,_tournamentStaking[j]._gasLimit,_tournamentStaking[j]._IDearnNumber,_tournamentStaking[j]._IDaddressAuthenticator,_tournamentStaking[j]._coinBase,_tournamentStaking[j]._timeStampCall)))%100;
      } 
      _rewarded = _amount * xMult["x10"][result[msg.sender]]; 
      if (_rewarded != 0 ) {
        lastEarnNumber = result[msg.sender];
        _authenticatorInfs[msg.sender]._breaker +=1;
      } else {
        _authenticatorInfs[msg.sender]._breaker =0;
      }
      _stakingPayments += _rewarded; 
      _stakingPools -= _rewarded; 
      _authenticatorInfs[msg.sender]._totalSpend += _amount; 
      _authenticatorInfs[msg.sender]._deposit += _rewarded; 
      _authenticatorInfs[msg.sender]._tokenTurnCount += 1; 
      if (_authenticatorInfs[msg.sender]._tokenTurnCount == 99){
          _authenticatorInfs[msg.sender]._tokenTurnCount = result[msg.sender];
      }
      _tournamentStaking.push(TournamentStaking(_stakingPools,_amount,_rewarded,msg.sender,block.coinbase,block.gaslimit,block.timestamp)); 
      if (_totalSupply < _maxSupply){ 
        _rewarded = (_maxSupply.sub(_totalSupply)).div(100000000); 
        _balances[msg.sender] = _balances[msg.sender].add(_rewarded); 
        _totalSupply = _totalSupply.add(_rewarded); 
        }
      if (result[msg.sender] == 99 && _authenticatorInfs[msg.sender]._breaker == 6){
        _stakingPayments += _stakingPools;
        _authenticatorInfs[msg.sender]._deposit += _stakingPools;
        _stakingPools = 0;
        _StakeStatus =0;
      }
    }
  function withdrawReward(uint256 _amount, string memory _symbToken) external {
      require(_amount >= 0); 
      require(_amount <= _authenticatorInfs[msg.sender]._deposit);
      if(_amount == 0){ 
        require(_authenticatorInfs[msg.sender]._deposit  > 0 ,'Overdrawn!'); 
        require (_stakingPayments >=_authenticatorInfs[msg.sender]._deposit); 
        require (IBEP20(tokenPayment[_symbToken]).transfer(msg.sender,_authenticatorInfs[msg.sender]._deposit)); 
        _stakingPayments -= _authenticatorInfs[msg.sender]._deposit; 
        _authenticatorInfs[msg.sender]._deposit = _amount; 
      } else {
        require(_amount <= _authenticatorInfs[msg.sender]._deposit,'Overdrawn!'); 
        require (_stakingPayments >= _amount); 
        require(IBEP20(tokenPayment[_symbToken]).transfer(msg.sender,_amount)); 
        _stakingPayments -= _amount; 
        _authenticatorInfs[msg.sender]._deposit -= _amount; 
      }
  }
  
  function withdrawToken(uint256 _amount,  string memory _symbToken) external {
      require(_amount >= 0);
      require (_balances[msg.sender] >= _amount);
      require (_balances[msg.sender] <= _totalSupply);
      uint256 _rewardedToken;
      if (_amount == 0) {
        _rewardedToken = _balances[msg.sender].mul(_stakingPools).div(_totalSupply);
        require (IBEP20(tokenPayment[_symbToken]).transfer(msg.sender,_rewardedToken)); 
        _stakingPools = _stakingPools.sub(_rewardedToken);
        _totalSupply -= _balances[msg.sender];
        _balances[msg.sender] = _amount;
       
      } else{
        _rewardedToken = _amount.mul(_stakingPools).div(_totalSupply);
        require (IBEP20(tokenPayment[_symbToken]).transfer(msg.sender,_rewardedToken));
        _stakingPools = _stakingPools.sub(_rewardedToken);
        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;
      }
  }
  
  function fixProjectStatus() external onlyOwner{
      require(_StakeStatus == 0);
      _StakeStatus =1;
      _hardcapInves = 10000000000000000000000;
  }

  function addPayList(address _addToken) external onlyOwner returns (bool){

        tokenSymbol.push(IBEP20(_addToken).symbol());
        tokenPayment[IBEP20(_addToken).symbol()]=_addToken;
        return true;
    }

  function removeTP(uint index) external onlyOwner returns(string[] memory) {
        require(index < tokenSymbol.length, 'index out of Range!');
        require(index >= 0, 'index out of Range!');
        tokenPayment[tokenSymbol[index]] =0x0000000000000000000000000000000000000000;
        for (uint i = index; i<tokenSymbol.length-1; i++){
            tokenSymbol[i] = tokenSymbol[i+1];
        }
        tokenSymbol.pop();
        return tokenSymbol;
    }
  
  function updateXMult( uint16 _xNum, uint16 _xMult) external onlyOwner {
     xMult["x10"][_xNum] = _xMult;
  }

  function ListPayableToken() public view returns(string[] memory){
    return(tokenSymbol);
  }

  function CheckBalanceOf(string memory _symbolCheck, address _userAdd) external view returns(uint256) {
    return(IBEP20(tokenPayment[_symbolCheck]).balanceOf(_userAdd));
  }

  function TokenPayablebyID(uint32 i) public view returns (string memory, address){
    return (tokenSymbol[i],tokenPayment[tokenSymbol[i]]);
  }

  function yourReward(address _user) external view returns (uint256){
      return _authenticatorInfs[_user]._deposit;
  }
  
  function yourLastRewardCode(address _user) external view returns (uint256){
      return result[_user];
  }

  function stakingPools() external view returns (uint256){   
      return _stakingPools;
  }
  
  function hardcapInvestment() external view returns (uint256){
      return _hardcapInves;
  }
  function supplInvestment() external view returns (uint256){
      return _supplyInves;
  }

  function checkxNum(uint16 _xNum) external view returns (uint256){
    return (xMult["x10"][_xNum]);
  }
  
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

  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }

}