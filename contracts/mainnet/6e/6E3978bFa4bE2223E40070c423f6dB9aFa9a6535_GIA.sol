/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;
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
interface IUniswapV2Pair {
    function sync() external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);

}
contract Ownable {
    address public _owner;
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
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
}

contract GIA is IERC20,Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _tOwned;
    mapping (address => uint256) private _sOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    address public uniswapV2Pair;
    mapping (address => bool) public _isuniswapV2Pair;
    mapping (address => bool) private _iscompany;
    mapping (address => bool) private _iscompanys;
    mapping (address => bool) private _isrelease;
    bool private mapLock = true;
    bool private shellLock = true;
    uint256 private _tTotal = 30000000 * 10**18;
    uint256 public _destroy = 0; 
    uint256 public _release = 0; 
    uint256 public _ecology = 0; 
    uint256 private _tFeeTotal = 0 ;
    uint256 private _companysusdt = 160; 
    uint256 private _companysgia = 160;
    string private _name = "GIA";
    string private _symbol = "GIA";
    uint8 private _decimals = 18;
    address private projectAddress = 0x2b1a706F2A4edeC5f2C79dA60Ea37dead90395f9;
    address private bonusAddress = 0x70a1836c2bb4dc9C23Cadae892608F9C55F96885;
    address private ecologyAddress = 0x66ee9e8B54aBdb3C830a925ec62A61DE59182D78;

    address private usdt = 0x55d398326f99059fF775485246999027B3197955;
    address private router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    



    constructor (){
        _owner = msg.sender;
        _tOwned[projectAddress] = 1 * 10**18;
        _tOwned[address(this)] =  29999999 * 10**18;
        emit Transfer(address(0), projectAddress, 1 * 10**18);
        emit Transfer(address(0), address(this), 29999999 * 10**18);
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
        
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
     function getmapLock() public view returns(bool) {
        return mapLock;
    }
     function getshellLock() public view returns(bool) {
        return shellLock;
    }
    
    function getsowned (address account) public  view  returns (uint256) {
        return _sOwned[account];
    }
    
    function getcompany (address account) public  view  returns (bool) {
        return _iscompany[account];
    }
    
    function getcompanys (address account) public  view  returns (bool) {
        return _iscompanys[account];
    }
    
    function getcompanysusdt () public  view  returns (uint256) {
        return _companysusdt;
    }
    
    function getcompanysgia () public  view  returns (uint256) {
        return _companysgia;
    }
    
     function setrelease(address recipient) public onlyOwner {
        if (!_isrelease[recipient]) _isrelease[recipient] = true;
    }
    
    function setcompany(address recipient) public{
        require(_isrelease[msg.sender]);
        if (!_iscompany[recipient]) _iscompany[recipient] = true;
    }
    
    function setcompanys(address recipient) public{
        require(_isrelease[msg.sender]);
        if (!_iscompanys[recipient]) _iscompanys[recipient] = true;
    }
    
    function setcompanysusdt(uint256 amount) public{
        require(_isrelease[msg.sender]);
        _companysusdt = amount;
    }
    
    function setcompanysgia(uint256 amount) public{
        require(_isrelease[msg.sender]);
        _companysgia = amount;
    }
    
    function setsOwned(address recipient, uint256 amount) public{
        require(_isrelease[msg.sender]);
        _sOwned[recipient] = _sOwned[recipient].add(amount);
    }
    
    function setscompanybalance(address recipient, uint256 amount) public{
        require(_isrelease[msg.sender]);
            if (balanceOf(address(this)) >= amount){
                _tOwned[address(this)] = _tOwned[address(this)].sub(amount);
                _recordlogs(address(this),recipient,amount);
                if (!_iscompany[recipient]) _iscompany[recipient] = true;
            }
    }
    
    function setscompanyspermission() public{
         uint256 giaamount = 0 ;
         if(shellLock){
            giaamount = _companysgia*10**18;
         }else{
            giaamount = _companysusdt.mul(getpice());
         }
         IERC20(usdt).transferFrom(msg.sender,uniswapV2Pair,_companysusdt*10**18);
         _tOwned[address(this)] = _tOwned[address(this)].sub(giaamount);
         _recordlogs(address(this),uniswapV2Pair,giaamount);
         if (!_iscompany[msg.sender]) _iscompany[msg.sender] = true;
         IUniswapV2Pair(uniswapV2Pair).sync();
    }
    
    function getpice () public  view  returns (uint256) {
        address [] memory path =new address[](2);
        path[0] = usdt;
        path[1] = address(this);
        uint256 [] memory pice = IUniswapV2Pair(router).getAmountsOut(1*10**6,path);
        return pice[1];
    }

    
    function setdestroy() public {
        if( _tFeeTotal >= 25000000*10**18 ){
            _destroy = 0;
        }
        if (_destroy != 0){
            _tOwned[uniswapV2Pair] = _tOwned[uniswapV2Pair].sub(_destroy);
            _recordlogs(uniswapV2Pair,address(0),_destroy);
            _tFeeTotal = _tFeeTotal.add(_destroy);
           _destroy = 0;
        }
        IUniswapV2Pair(uniswapV2Pair).sync();
    }
    
    function setreleasebalance() public {
        if (_release != 0 && balanceOf(address(this)) >= _release){
            _tOwned[address(this)] = _tOwned[address(this)].sub(_release);

            _recordlogs(address(this),uniswapV2Pair,_release.mul(70).div(100));
            _recordlogs(address(this),bonusAddress,_release.mul(22).div(100));
            _recordlogs(address(this),projectAddress,_release.mul(8).div(100));
           _release = 0;
           IUniswapV2Pair(uniswapV2Pair).sync();
        }
        if (balanceOf(address(this)) == 0  && getmapLock()){
            setmapLock();
        }
    }

    
     function setshellLock() public onlyOwner {
         if(getshellLock()){
             shellLock = false;
         }
    }
    
     function setmapLock() private {
         if(getmapLock()){
             mapLock = false;
         }
    }
    
     function excludeisuniswapV2Pair(address account) public onlyOwner {
         uniswapV2Pair = account;
        _isuniswapV2Pair[account] = true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _transferBothExcluded(from,to,amount);
    }

    
    function _recordlogs(address from,address to,uint256 amount) private {
        _tOwned[to] = _tOwned[to].add(amount);
        emit Transfer(from, to,amount);
    }
   
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);

        if(_isuniswapV2Pair[sender] || _isuniswapV2Pair[recipient] ){
            if(_isuniswapV2Pair[sender]){
                
                if(_iscompany[recipient]){
                    require(_sOwned[recipient].div(64).div(1*10**5).mul(getpice()) >= tAmount);
                    _recordlogs(sender,recipient,tAmount);
                    _sOwned[recipient] = _sOwned[recipient].sub(tAmount.mul(64*10**5).div(getpice()));
                    if (balanceOf(address(this)) >= tAmount.mul(11).div(1000)){
                        _tOwned[address(this)] = _tOwned[address(this)].sub(tAmount.mul(1).div(100));
                        _recordlogs(address(this),recipient,tAmount.mul(1).div(100));
                        if( _ecology <= 1500000*10**18 ){
                            _tOwned[address(this)] = _tOwned[address(this)].sub(tAmount.mul(1).div(1000));
                            _recordlogs(address(this),ecologyAddress,tAmount.mul(1).div(1000));
                            _ecology = _ecology.add(tAmount.mul(1).div(1000));
                        }
                    }
                
                }else if(_iscompanys[recipient]){
                    require(_sOwned[recipient].div(64).div(1*10**5).mul(getpice()) >= tAmount);

                    _recordlogs(sender,recipient,tAmount.mul(50).div(100));
                    _sOwned[recipient] = _sOwned[recipient].sub(tAmount.mul(64*10**5).div(getpice()));
                    
                    if (balanceOf(address(this)) >= tAmount.mul(50).div(100)){
                        _release = _release.add(tAmount.mul(50).div(100));
                    
                    }else{
                        _recordlogs(sender,projectAddress,tAmount.mul(28).div(300));
                        _recordlogs(sender,bonusAddress,tAmount.mul(77).div(300));
                    }
                    if (balanceOf(address(this)) >= tAmount.mul(11).div(1000)){
                        _tOwned[address(this)] = _tOwned[address(this)].sub(tAmount.mul(1).div(100));
                        _recordlogs(address(this),recipient, tAmount.mul(1).div(100));
                        if( _ecology <= 1500000*10**18 ){
                            _tOwned[address(this)] = _tOwned[address(this)].sub(tAmount.mul(1).div(1000));
                            _recordlogs(address(this),ecologyAddress,tAmount.mul(1).div(1000));
                            _ecology = _ecology.add(tAmount.mul(1).div(1000));
                        }
                    }
                }else{
                    require(!getmapLock());
                    _recordlogs(sender,recipient,tAmount);
                    if (balanceOf(address(this)) >= tAmount.mul(1).div(1000)){
                        if( _ecology <= 1500000*10**18 ){
                            _tOwned[address(this)] = _tOwned[address(this)].sub(tAmount.mul(1).div(1000));
                            _recordlogs(address(this),ecologyAddress,tAmount.mul(1).div(1000));
                            _ecology = _ecology.add(tAmount.mul(1).div(1000));
                        }
                    }
                }
            }
            if(_isuniswapV2Pair[recipient]){
                
                if(_iscompany[sender] || _iscompanys[sender]){
                    _recordlogs(sender,recipient,tAmount);
                }else{
                    require(!shellLock);
                    _destroy = _destroy.add(tAmount.mul(85).div(100));
                    _recordlogs(sender,projectAddress,tAmount.mul(4).div(100));
                    _recordlogs(sender,bonusAddress,tAmount.mul(11).div(100));
                    _recordlogs(sender,recipient,tAmount.mul(85).div(100));
                }
            }
        }else {
            
            if(_iscompany[sender] || _iscompanys[sender] || sender == projectAddress){
                _recordlogs(sender,recipient,tAmount);
            }else{
                _recordlogs(sender,recipient,tAmount.mul(97).div(100));
                _recordlogs(sender,projectAddress,tAmount.mul(3).div(100));
            }

        }
 
    }
   
}