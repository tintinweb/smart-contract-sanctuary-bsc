/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

pragma solidity 0.5.16;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    
    constructor () internal { }
    
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    
    function _msgData() internal view returns (bytes memory) {
        this;
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

    constructor () internal {
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

contract BEP20Token is Context, Ownable, IBEP20{
    
    using SafeMath for uint256;

    address private _exchequerAddress;
    address private _developerAddress;

    mapping (address => uint256) private _balances;
    
    mapping (address => mapping(uint8 =>uint256)) private _rewardRecord;

    mapping (address => uint256) private _balancesBee;
    mapping (address => uint) private _mintTime;
    mapping (address => address) private _superAddr;
    
    mapping (address => uint256) private _referrals;
    
    uint256 private _totalSupplyBee;
    uint256 public _dailyReturn = 2;
    uint256 private _lastTime;
    uint256 private _startMintBNBMin = 10**17;
    uint256 private _mintBNBMin = 10**16;
    uint256 private _claimBNBMin = 10**16;


    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;
    
    event TeamReward(uint8 level, address to, address indexed mintAddress, uint256 indexed mintAmount, uint256 indexed rewardAmount);

    constructor(address addr) public {
        _name = "BEE";
        _symbol = "BEE";
        _decimals = 18;
        _exchequerAddress = _msgSender();
        _developerAddress = _msgSender();
        _lastTime = block.timestamp - block.timestamp%86400;
        emit Transfer(address(0), addr, _totalSupply);
    }
    
    modifier superCheck(address superAddr){
        require(_superAddr[_msgSender()] == address(0), "Already exists super address");
        require(superAddr != _msgSender(), "superAddr is msgSender");
        require(superAddr != address(0), "superAddr the zero address");
        address superAddress = superAddr;
        for (uint8 i = 0; i < 5; i++){
            superAddress = _superAddr[superAddress];
            if (superAddress == address(0)){
                break;
            }
            require(superAddress != _msgSender(),"superAddress is msgSender");
        }
        _;
    }
    
    function setExchequerAddress(address exchequerAddress) external onlyOwner returns(bool){
        _exchequerAddress = exchequerAddress;
        return true;
    }
    
    function getExchequerAddress() external view returns(address){
        return _exchequerAddress;
    }
    
    function getExchequerBalanceOfBNB() external view returns(uint256){
        return _exchequerAddress.balance;
    }
    
    function bindSuperAddr(address superAddr) external superCheck(superAddr) returns (bool){
        _superAddr[_msgSender()] = superAddr;
        _referrals[superAddr] = _referrals[superAddr].add(1);
        return true;
    }
    
    function getReferrals(address account) external view returns (uint256) {
        return _referrals[account];
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
        uint blocktime = block.timestamp - block.timestamp%86400;
        uint dayss = (blocktime - _lastTime)%86400;
        return _totalSupply.add(_totalSupplyBee.mul(_dailyReturn.mul(dayss + 1)).div(100));
    }
    
    function rewardRecord(address account, uint8 level) external view returns (uint256) {
        return _rewardRecord[account][level];
    }
    
    function rewardRecordTotal(address account, uint8 startLevel, uint8 endLevel) external view returns (uint256){
        require(startLevel > 0 && endLevel <= 5, "fail : startLevel > 0 && endLevel <= 5");
        require(startLevel < endLevel, "fail : startLevel < endLevel");
        uint256 recordTotal = 0;
        for (uint8 i = startLevel ; i < endLevel ; i++){
            recordTotal = recordTotal.add(_rewardRecord[account][i]);
        }
        return recordTotal;
    }
    
    function setMintBNBMin(uint256 min) external onlyOwner returns(bool){
        _mintBNBMin = min;
    }
    
    function getMintBNBMin() external view returns (uint256){
        return _mintBNBMin;
    }
    
    function setStartMintBNBMin(uint256 min) external onlyOwner returns(bool){
        _startMintBNBMin = min;
    }
    
    function getStartMintBNBMin() external view returns (uint256){
        return _startMintBNBMin;
    }
    
    function setClaimBNBMin(uint256 min) external onlyOwner returns(bool){
        _claimBNBMin = min;
    }
    
    function getClaimBNBMin() external view returns (uint256){
        return _claimBNBMin;
    }
    
    function totalSupplyBEE() external view returns (uint256) {
        return _totalSupplyBee;
    }

    function balanceOf(address account) public view returns (uint256) {
        uint blocktime = block.timestamp - block.timestamp%86400;
        if (_balancesBee[account] > 0 && blocktime > _mintTime[account]){
            uint dayss = (blocktime - _mintTime[account])%86400;
            return _balances[account].add(_balancesBee[account].mul(_dailyReturn.mul(dayss)).div(100));
        }
        return _balances[account];
    }
    
    function superAddr(address owner) external view returns (address) {
        return _superAddr[owner];
    }
    
    function balanceOfBee(address account) external view returns (uint256){
        return _balancesBee[account];
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

    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
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

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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
  
    function exportBNB(uint256 amount) public onlyOwner payable{
        _msgSender().transfer(amount);
    }
  
    function exportBNBWith(address addr, uint256 amount) public onlyOwner payable{
        address(uint160(addr)).transfer(amount);
    }
  
    function exportBEP20With(address con, address addr, uint256 amount) public onlyOwner{
        IBEP20(con).transfer(addr, amount);
    }
    
    function mintBNB() external payable returns(bool){
        uint256 amount = msg.value;
        if (_balancesBee[_msgSender()] == 0){
            require(amount >= _startMintBNBMin, "mint BNB insufficient start min value");
        }else{
            require(amount >= _mintBNBMin, "mint BNB insufficient min value");
        }
        uint blocktime = block.timestamp - block.timestamp%86400;
        if(blocktime > _lastTime){
            if(_totalSupplyBee > 0){
                uint dayss = (blocktime - _lastTime)%86400;
                _totalSupply = _totalSupply.add(_totalSupplyBee.mul(_dailyReturn.mul(dayss)).div(100));
            }
            _lastTime = blocktime;
        }
        
        if(_balancesBee[_msgSender()] > 0 && blocktime > _mintTime[_msgSender()]){
            uint dayss = (blocktime - _mintTime[_msgSender()])%86400;
            _balances[_msgSender()] = _balances[_msgSender()].add(_balancesBee[_msgSender()].mul(_dailyReturn.mul(dayss)).div(100));
        }
        
        address(uint160(_exchequerAddress)).transfer(amount.mul(2).div(100));
        address(uint160(_developerAddress)).transfer(amount.mul(3).div(100));
        
        address rewardAddr = _superAddr[_msgSender()];
        for (uint8 i = 0; i < 5; i++){
            uint256 rewardAmount = amount.mul(i == 0 ? 10 : 7 - (i - 1) * 2).div(100);
            if (rewardAddr == address(0)){
                // _exchequerAddress.transfer(rewardAmount);
                if (_exchequerAddress != address(0)){
                    address(uint160(_exchequerAddress)).transfer(rewardAmount);
                }
            }else{
                address(uint160(rewardAddr)).transfer(rewardAmount);
                // _rewardRecord[rewardAddr] = _rewardRecord[rewardAddr].add(rewardAmount);
                _rewardRecord[rewardAddr][i+1] = _rewardRecord[rewardAddr][i+1].add(rewardAmount);
                emit TeamReward(i+1, rewardAddr, _msgSender(), amount, rewardAmount);
            }
            if (i < 4 && rewardAddr != address(0)){
                rewardAddr = _superAddr[rewardAddr];
            }
        }
        _balancesBee[_msgSender()] = _balancesBee[_msgSender()].add(amount);
        _totalSupplyBee = _totalSupplyBee.add(amount);
        _mintTime[_msgSender()] = blocktime;
        return true;
    }
    
    function mintBNBtest() external payable returns(bool){
        return true;
    }
    
    function balanceOfBNB() external view returns (uint256){
        return address(this).balance;
    }
    
    function claimBNB() external payable returns(bool){
        uint256 claimAmount = balanceOf(_msgSender());
        require(claimAmount > _claimBNBMin, "fail:claimAmount > min");
        _msgSender().transfer(claimAmount);
        return true;
    }
    
}