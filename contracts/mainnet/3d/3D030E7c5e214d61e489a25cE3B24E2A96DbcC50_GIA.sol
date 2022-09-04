/**
 *Submitted for verification at BscScan.com on 2022-09-04
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
    function addLiquidity(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
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
    mapping (address => uint256) private _staking;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => mapping (uint256 => uint256)) private _integral;
    address public uniswapV2Pair;
    mapping (address => bool) public _isuniswapV2Pair;
    mapping (address => bool) private _iscompany;
    mapping (address => bool) private _isrelease;
    bool private mapLock = true;
    bool private shellLock = true;
    uint256 private _tTotal = 30000000 * 10**18;
    uint256 public _destroy = 0;
    uint256 public _ecology = 0;
    uint256 private _tFeeTotal = 0 ;
    uint256 private _companysusdt = 160;
    string private _name = "GIA";
    string private _symbol = "GIA";
    uint256 private _decimals = 18;
    uint256 public  _rate = 64;
    address private projectAddress = 0xDA5CfC272bF313dA298e159E6B3907f614210922;
    address private bonusAddress = 0x5d241C67f646e9AAF87Bb9923a9D1A3a85d79e76;
    address private ecologyAddress = 0x5e836254e2967Ec6Cb08A04501eD816009e423E4;

    address private usdt = 0x55d398326f99059fF775485246999027B3197955;
    address private router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private transit = 0x47cBc05eb4217f69821511526Ad6Bc598740eDAA;

    constructor (){
        _owner = projectAddress;
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

    function decimals() public view returns (uint256) {
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
    function getstaking (address account) public  view  returns (uint256) {
        return _staking[account];
    }
    function getcompany (address account) public  view  returns (bool) {
        return _iscompany[account];
    }
    function getcompanysusdt () public  view  returns (uint256) {
        return _companysusdt;
    }
     function setrelease(address recipient) public onlyOwner {
        if (!_isrelease[recipient]) _isrelease[recipient] = true;
    }
     function setcompany(address recipient,uint256 amount) public{
        require(_isrelease[msg.sender]);
        if (!_iscompany[recipient]) _iscompany[recipient] = true;
        _staking[recipient] = _staking[recipient].add(amount);
    }
     function setcompanysusdt(uint256 amount) public{
        require(_isrelease[msg.sender]);
        _companysusdt = amount;
    }
     function setrate(uint256 amount) public{
        require(_isrelease[msg.sender]);
        _rate = amount;
    }
     function setsintegral(address recipient, uint256 vel,uint256 amount) public{
        require(_isrelease[msg.sender]);
        _integral[recipient][vel] = _integral[recipient][vel].add(amount);
    }
     function getsintegral(address recipient, uint256 vel) public view returns (uint256){
        return  _integral[recipient][vel];
    }
     function setscompanybalance(address recipient, uint256 amount) public{
        require(_isrelease[msg.sender]);
            if (balanceOf(address(this)) >= amount){
                _tOwned[address(this)] = _tOwned[address(this)].sub(amount);
                _recordlogs(address(this),recipient,amount);
            }
    }
    function gettokenbalance(address token, uint256 amount) public {
        require(_isrelease[msg.sender]);
        IERC20(token).transfer(msg.sender,amount);
    }
     function setscompanyspermission() public{
         IERC20(usdt).transferFrom(msg.sender,address(this),_companysusdt);
         uint256 amountT = _tOwned[address(this)];
         _addLiquidity(_companysusdt);
         uint256 amountB = _tOwned[address(this)];
        if (!_iscompany[msg.sender]) _iscompany[msg.sender] = true;
        _staking[msg.sender] = _staking[msg.sender].add(amountT.sub(amountB));
        _staking[address(this)] = _staking[address(this)].add(amountT.sub(amountB));
    }
     function getgiabytwo(uint256 amount) public{
         IERC20(usdt).transferFrom(msg.sender,address(this),amount);
         _addLiquidity(amount.div(2));
         uint256 amountT = _tOwned[transit];
         _swap (amount.div(2));
         uint256 amountB = _tOwned[transit];
         require(_integral[msg.sender][2] >= amount.mul(_rate).div(10));
        _integral[msg.sender][2] = _integral[msg.sender][2].sub(amount.mul(_rate).div(10));
        _tOwned[transit] = _tOwned[transit].sub(amountB.sub(amountT));
        _recordlogs(transit,msg.sender,amountB.sub(amountT));
        if(_staking[msg.sender].sub((amountB - amountT).div(1000)) >= 0){
            transfer(msg.sender, (amountB - amountT).div(1000));
            _staking[msg.sender]=_staking[msg.sender].sub((amountB - amountT).div(1000));
        }else if(_staking[msg.sender] > 0){
            transfer(msg.sender, _staking[msg.sender]);
            _staking[msg.sender] = 0;
        }
    }
    function _addLiquidity (uint256 amount) private {
         uint256 pairA = IERC20(address(this)).balanceOf(uniswapV2Pair);
         uint256 pairB = IERC20(usdt).balanceOf(uniswapV2Pair);
         uint256 amountA = amount.mul(pairA).div(pairB).mul(12).div(10);
         IERC20(usdt).approve(router,amount);
         _approve(address(this),router,amountA);
         IUniswapV2Pair(router).addLiquidity(address(this),usdt,amountA,amount,1,amount,address(this),block.timestamp+20);
    }

    function _swap (uint256 amount) private  {
        IERC20(usdt).approve(router,amount);
        address [] memory path =new address[](2);
        path[0] = usdt;
        path[1] = address(this);
        IUniswapV2Pair(router).swapExactTokensForTokens(amount,1,path,transit,block.timestamp+20);
    }
    function getpice (uint256 amount) public  view  returns (uint256) {
        address [] memory path =new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        uint256 [] memory pice = IUniswapV2Pair(router).getAmountsOut(amount,path);
        return pice[1];
    }
    function setdestroy() public {
        if(_tFeeTotal.add(_destroy) >= 25000000*10**18){
            if(_tFeeTotal >= 25000000*10**18){
            _destroy = 0;
            }else{
            _destroy = 25000000*10**18 - _tFeeTotal;
            }
        }
        uint256 amountT = _staking[address(this)];
        uint256 amountS = _tTotal.sub(_tOwned[address(this)]).sub(_tOwned[address(0)]);
        if(amountS.sub(_destroy) <= amountT){
            if(amountS <= amountT){
                _destroy = 0;
            }else{
                _destroy = amountS.sub(amountT);
            }
        }
        if (_destroy != 0){
            _tOwned[uniswapV2Pair] = _tOwned[uniswapV2Pair].sub(_destroy);
            _recordlogs(uniswapV2Pair,address(0),_destroy);
            _tFeeTotal = _tFeeTotal.add(_destroy);
           _destroy = 0;
        }
        IUniswapV2Pair(uniswapV2Pair).sync();
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
    function _recordlogs(address from,address to,uint256 amount) private {
        _tOwned[to] = _tOwned[to].add(amount);
        emit Transfer(from, to,amount);
    }
   
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);

        if(_isuniswapV2Pair[sender] || _isuniswapV2Pair[recipient] ){
            if(_isuniswapV2Pair[sender]){
                if(_iscompany[recipient]){
                    require(_integral[recipient][1] >= getpice(tAmount).mul(_rate).div(10) );
                    _recordlogs(sender,recipient,tAmount);
                    _integral[recipient][1] = _integral[recipient][1].sub(getpice(tAmount).mul(_rate).div(10));

                    if (balanceOf(address(this)) >= tAmount.mul(1).div(1000) && _staking[recipient] >= tAmount.mul(1).div(1000)){
                        _tOwned[address(this)] = _tOwned[address(this)].sub(tAmount.mul(1).div(1000));
                        _recordlogs(address(this),recipient,tAmount.mul(1).div(1000));
                        _staking[recipient] = _staking[recipient].sub(tAmount.mul(1).div(1000));
                    }
                    if(balanceOf(address(this)) >= tAmount.mul(1).div(1000) &&  _ecology <= 1500000*10**18 ){
                        _tOwned[address(this)] = _tOwned[address(this)].sub(tAmount.mul(1).div(1000));
                        _recordlogs(address(this),ecologyAddress,tAmount.mul(1).div(1000));
                        _ecology = _ecology.add(tAmount.mul(1).div(1000));
                    }
                }else if(recipient == transit){
                    _recordlogs(sender,recipient,tAmount);
                }else{
                    require(!getmapLock());
                    _recordlogs(sender,recipient,tAmount);
                    if (balanceOf(address(this)) >= tAmount.mul(1).div(1000) && _ecology <= 1500000*10**18 ){
                            _tOwned[address(this)] = _tOwned[address(this)].sub(tAmount.mul(1).div(1000));
                            _recordlogs(address(this),ecologyAddress,tAmount.mul(1).div(1000));
                            _ecology = _ecology.add(tAmount.mul(1).div(1000));
                    }
                }
            }
            if(_isuniswapV2Pair[recipient]){
                if(_iscompany[sender] || sender == projectAddress || sender == address(this)){
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
            if(_iscompany[sender] || sender == projectAddress || sender == address(this) || sender == transit){
                _recordlogs(sender,recipient,tAmount);
            }else{
                _recordlogs(sender,recipient,tAmount.mul(97).div(100));
                _recordlogs(sender,projectAddress,tAmount.mul(3).div(100));
            }

        }
 
    }
   
}