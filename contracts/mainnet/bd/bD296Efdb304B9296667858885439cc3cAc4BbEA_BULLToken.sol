// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";
import "./Config.sol";

contract BULLToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => uint256) private _balances;
    
    mapping (address => mapping (address => uint256)) private _allowances;
    
    address public lpPoolAddress;
    
    string private _name = 'TEST BULL';
    string private _symbol = 'TESTBULL';
    uint8 private _decimals = 8;
    uint256 private _totalSupply = 10000000 * 10**uint256(_decimals);


    uint256 public _transferFee = 5;
    uint256 public _liquidityFee = 7;
    uint256 public _liquidityAmount = 0;


    Config public config;

    mapping(address => bool) private _isExcluded;

    constructor () {
        _isExcluded[owner()] = true;
        _isExcluded[address(this)] = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    
    
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

    function setExclude(address account) public onlyOwner {
        _isExcluded[account] = true;
    }
    function setExchangePool(address _lpPoolAddress) public onlyOwner {
        lpPoolAddress = _lpPoolAddress;
    }    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        if(lpPoolAddress==recipient||lpPoolAddress==sender){
            if(lpPoolAddress==recipient){
                uint256 lpFee=  amount.mul(_liquidityFee).div(10**2);
                uint256 tTransferAmount=amount.sub(lpFee);
                _balances[sender] = _balances[sender].sub(amount);
                _balances[recipient] = _balances[recipient].add(tTransferAmount);
                emit Transfer(sender, recipient, tTransferAmount);
                if(lpFee>0) {
                    _liquidityAmount=_liquidityAmount.add(lpFee);
                    _balances[config.getAwordPoolAddress()] = _balances[config.getAwordPoolAddress()].add(lpFee);
                    emit Transfer(sender,config.getAwordPoolAddress(), lpFee);
                }
            }else{
                _balances[sender] = _balances[sender].sub(amount);
                _balances[recipient] = _balances[recipient].add(amount);
                emit Transfer(sender, recipient, amount);
            }
        }else{
            if(!_isExcluded[sender]&&!_isExcluded[recipient]){
                uint256 fee=  amount.mul(_transferFee).div(100);
                uint256 realAmount=amount.sub(fee);
                _balances[config.getAwordPoolAddress()] = _balances[config.getAwordPoolAddress()].add(fee);
                emit Transfer(sender, config.getAwordPoolAddress(), fee);
                _balances[sender] = _balances[sender].sub(amount);
                _balances[recipient] = _balances[recipient].add(realAmount);
                emit Transfer(sender, recipient, realAmount);
            }else{
                _balances[sender] = _balances[sender].sub(amount);
                _balances[recipient] = _balances[recipient].add(amount);
                emit Transfer(sender, recipient, amount);
            }
        }
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function setConfig(Config _config) public onlyOwner {
        config = _config;
    }
    
    function setFee(uint256 fee) public onlyOwner {
        _liquidityFee = fee;
    }

    function setTransferFee(uint256 fee) public onlyOwner {
        _transferFee = fee;
    }
    
    function subLiquidityAmount(uint256 amount) public onlyOwner {
        _liquidityAmount = _liquidityAmount.sub(amount);
    }
    

}