/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

pragma solidity ^0.8.5;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint256);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Context {
    constructor () { }

    function _msgSender() internal view returns (address) {
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
contract token is Context {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;
    uint256 internal _decimals;
    string internal _symbol;
    string internal _name;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(){}

    function decimals() external view returns (uint256) {
      return _decimals;
    }

    function symbol() external view returns (string memory) {
      return _symbol;
    }

    function name() external view returns (string memory) {
      return _name;
    }

    /**
    * @dev See {BEP20-totalSupply}.
    */
    function totalSupply() public view returns (uint256) {
      return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
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

    function _transfer(address sender, address recipient, uint256 amount) virtual internal {
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");

      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
      require(owner != address(0), "BEP20: approve from the zero address");
      require(spender != address(0), "BEP20: approve to the zero address");

      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
    }
  }

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

contract xphp is token,Ownable{
    using SafeMath for uint256;

    uint256 month = 60 * 60 * 24 * 30;
    
    bool public AllCantransfer = false;

    IBEP20 php = IBEP20(0x49849B283348af4423D6750EfF475a759A7338EC);
    address stakeAdr;

    mapping (address => bool) canTransfer;

    mapping (address => uint256) public dphp0;
    mapping (address => uint256) public dphp1;
    mapping (address => uint256) public dphp2;
    mapping (address => uint256) public dphp3;
    mapping (address => uint256) public withdrawTime0;
    mapping (address => uint256) public withdrawTime1;
    mapping (address => uint256) public withdrawTime2;
    mapping (address => uint256) public withdrawTime3;

    constructor(){
        _decimals = php.decimals();
        _name = "xphp";
        _symbol = "xphp";
        _totalSupply = 0; 
    }
    function setStakeAdr(address adr) public onlyOwner{
        stakeAdr = adr;
    }

    function setTransferAdr(address adr,bool bl) public onlyOwner{
        canTransfer[adr] = bl;
    }
    function changeAllCanstransfer(bool bl) public onlyOwner{
        AllCantransfer = bl;
    }

    function getXphp(uint256 amount,uint256 timeType) public {
        require(timeType < 4,"");
        php.transferFrom(msg.sender,address(this),amount);

        if(timeType == 0){
            dphp0[msg.sender] = dphp0[msg.sender] + amount;

            withdrawTime0[msg.sender] = block.timestamp + month;
            _balances[msg.sender] = _balances[msg.sender] + amount;
            _totalSupply = _totalSupply + amount;

            emit Transfer(address(0), msg.sender, amount);
        }

        if(timeType == 1){
            dphp1[msg.sender] = dphp1[msg.sender] + amount;

            amount = amount * 3;
            withdrawTime1[msg.sender] = block.timestamp + (3 * month);
            _balances[msg.sender] = _balances[msg.sender] + amount;
            _totalSupply = _totalSupply + amount;
            emit Transfer(address(0), msg.sender, amount);
        }

        if(timeType == 2){
            dphp2[msg.sender] = dphp2[msg.sender] + amount;

            amount = amount * 6;
            withdrawTime2[msg.sender] = block.timestamp  + (6 * month);
            _balances[msg.sender] = _balances[msg.sender] + amount;
            _totalSupply = _totalSupply + amount;
            emit Transfer(address(0), msg.sender, amount);
        }

        if(timeType == 3){
            dphp3[msg.sender] = dphp3[msg.sender] + amount;

            amount = amount * 12;
            withdrawTime3[msg.sender] = block.timestamp + (12 * month);
            _balances[msg.sender] = _balances[msg.sender] + amount;
            _totalSupply = _totalSupply + amount;
            emit Transfer(address(0), msg.sender, amount);
        }
    }

    function canWithDraw(address adr,uint256 timeType)public view returns(bool) {
        if(timeType == 0){if(withdrawTime0[adr] <= block.timestamp){return true;}}
        if(timeType == 1){if(withdrawTime1[adr] <= block.timestamp){return true;}}
        if(timeType == 2){if(withdrawTime2[adr] <= block.timestamp){return true;}}
        if(timeType == 3){if(withdrawTime3[adr] <= block.timestamp){return true;}}

        return false;
    }

    function timestamp()public view returns(uint256){
        return block.timestamp;
    }

    function withDraw(uint256 amount,uint256 timeType) public {
        require(timeType < 4,"");

        php.transfer(msg.sender,amount);

        if(timeType == 0){
            require(withdrawTime0[msg.sender] <= block.timestamp,"");
            _balances[msg.sender] = _balances[msg.sender].sub(amount);
            dphp0[msg.sender] = dphp0[msg.sender].sub(amount);
            _totalSupply = _totalSupply.sub(amount);
            emit Transfer(msg.sender, address(0), amount);
        }
        if(timeType == 1){
            dphp1[msg.sender] = dphp1[msg.sender].sub(amount);
            amount = amount * 3;
            require(withdrawTime1[msg.sender] <= block.timestamp,"");
            _balances[msg.sender] = _balances[msg.sender].sub(amount);
            _totalSupply = _totalSupply.sub(amount);
            emit Transfer(msg.sender, address(0), amount);
        }
        if(timeType == 2){
            dphp2[msg.sender] = dphp2[msg.sender].sub(amount);
            amount = amount * 6;
            require(withdrawTime2[msg.sender] <= block.timestamp,"");
            _balances[msg.sender] = _balances[msg.sender].sub(amount);
            _totalSupply = _totalSupply.sub(amount);
            emit Transfer(msg.sender, address(0), amount);
        }
        if(timeType == 3){
            dphp3[msg.sender] = dphp3[msg.sender].sub(amount);
            amount = amount * 12;
            require(withdrawTime3[msg.sender] <= block.timestamp,"");
            _balances[msg.sender] = _balances[msg.sender].sub(amount);
            _totalSupply = _totalSupply.sub(amount);
            emit Transfer(msg.sender, address(0), amount);
        }

    }

    function isCantransfer(address sender, address recipient) view internal returns(bool){
        return canTransfer[sender] || canTransfer[recipient] || AllCantransfer;
    }

    function _transfer(address sender, address recipient, uint256 amount) virtual internal override{
      require(isCantransfer( sender,  recipient), "");
      super._transfer(sender, recipient, amount);
  
    }

    function stake(address sender,uint256 amount) public {
        require(msg.sender == stakeAdr,'');
        super._transfer(sender,stakeAdr,amount);
    }

    function UnStake(address sender,uint256 amount) public {
        require(msg.sender == stakeAdr,'');
        super._transfer(stakeAdr,sender,amount);
    }

    function getToken(address _token,uint256 amount)public onlyOwner{
        IBEP20(_token).transfer(msg.sender,amount);
    }
    function getETH(uint256 amount)public onlyOwner{
        payable(msg.sender).transfer(amount);
    }
}