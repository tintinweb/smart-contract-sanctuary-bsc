// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";



contract IssAToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => uint256) private _balances;
    
    mapping (address => mapping (address => uint256)) private _allowances;
    
    address public lpPoolAddress;
    string private _name = 'ISSA TOKEN';
    string private _symbol = 'ISSA';
    uint8 private _decimals = 8;
    uint256 private _totalSupply = 1000000 * 10**uint256(_decimals);
    uint256 public _liquiditySellFee = 2;

    uint256 public _liquidityBurnFee = 8;
    uint256 public _liquidityLpFee = 10;
    uint256 public _liquidityPowerFee = 20;

    address public acceptAddress;

    address public feeAddress;
    

    uint256 public _transferFee = 5;
    uint256 public _liquidityAmount = 0;
    uint256 public _lastLiquidityAmount = 0;
    mapping(address => bool) private _isFrozen;
    mapping(address => bool) private _isExcluded;
    constructor () {
        _isExcluded[owner()] = true;
        _isExcluded[address(this)] = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    receive() external payable {}
    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
 
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
  
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance.sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function setExclude(address account,bool flag) public onlyOwner {
        _isExcluded[account] = flag;
    }

    function setFrozen  (address account,bool flag) public onlyOwner {
        _isFrozen[account] = flag;
    }

    function setExchangePool(address _lpPoolAddress) public onlyOwner {
        lpPoolAddress = _lpPoolAddress;
    }

    function setAcceptAddress(address _acceptAddress) public onlyOwner {
        acceptAddress = _acceptAddress;
    }

    function setFeeAddress(address _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        require(!_isFrozen[sender], "address error  !");
        uint256 realAmount=amount;
        if(lpPoolAddress==recipient||lpPoolAddress==sender){
            if(lpPoolAddress==sender){
                if(!_isExcluded[recipient]){
                    uint256 burnFee =  amount.mul(_liquidityBurnFee).div(100);
                    uint256 lpFee =  amount.mul(_liquidityLpFee).div(100);
                    uint256 powerFee =  amount.mul(_liquidityPowerFee).div(100);
                    uint256 fee = burnFee.add(lpFee).add(powerFee);
                    realAmount=amount.sub(fee);

                    _liquidityAmount=_liquidityAmount.add(amount);

                    _balances[address(0)] = _balances[address(0)].add(burnFee);
                    emit Transfer(sender,address(0), burnFee);

                    _balances[acceptAddress] = _balances[acceptAddress].add(lpFee);
                    emit Transfer(sender,acceptAddress, lpFee);

                    _balances[acceptAddress] = _balances[acceptAddress].add(powerFee);
                    emit Transfer(sender,acceptAddress, lpFee);
                }
            }else{
                if(!_isExcluded[sender]){
                    uint256 lpFee=  amount.mul(_liquiditySellFee).div(100);
                    realAmount=amount.sub(lpFee);
                    if(lpFee>0) {
                        _balances[address(0)] = _balances[address(0)].add(lpFee);
                        emit Transfer(sender,address(0), lpFee);
                    }
                }
            }
        }else{
            if(!_isExcluded[sender]&&!_isExcluded[recipient]){
                uint256 fee=  amount.mul(_transferFee).div(100);
                realAmount=amount.sub(fee);
                if(fee>0){
                    _balances[feeAddress] = _balances[feeAddress].add(fee);
                    emit Transfer(sender, feeAddress, fee);
                }
            }
        }
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(realAmount);
        emit Transfer(sender, recipient, realAmount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function addLiquidityAmount(uint256 amount) public  {
        _liquidityAmount = _liquidityAmount.add(amount);
    }

    function setLiquidityAmount() public {
        _lastLiquidityAmount = _liquidityAmount;
        _liquidityAmount=0;
    }
}