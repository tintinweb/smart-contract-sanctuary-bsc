/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;
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

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract DWALK is Context, IERC20, Ownable {
    struct TaxFee { 
        uint256 buyback;
        uint256 marketing;
        uint256 staking;
        uint256 holder;
    }

    struct TaxAddress { 
        address buyback;
        address marketing;
        address staking;
    }

    using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isBlacklisted;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isExchanger;
    mapping (address => bool) private _isTaxFree;
    address[] private _excluded;
   
    string private _name = "Doge Walk";
    string private _symbol = "DWALK";
    uint8 private _decimals = 18;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 100000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    TaxFee public taxFees = TaxFee(2, 2, 3, 1);
    TaxAddress public taxAddresses;

    bool private _freeTax = true;
    TaxFee private _zeroTax = TaxFee(0,0,0,0);

    bool public enableTaxForAll = false;
    
    constructor () public {
        _rOwned[owner()] = _rTotal;

        IPancakeRouter _pancakeRouter = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH());
        _isExchanger[pancakePair] = true;
        _excludeAccount(pancakePair);

        _isTaxFree[owner()] = true;
        _excludeAccount(owner());

        _isTaxFree[address(this)] = true;
        _excludeAccount(address(this));
        
        taxAddresses = TaxAddress(owner(), owner(), owner());
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function setTaxFees(uint256 buyback, uint256 marketing, uint256 staking, uint256 holder) external onlyOwner() {
        taxFees.buyback = buyback;
        taxFees.marketing = marketing;
        taxFees.staking = staking;
        taxFees.holder = holder;
    }

    function setTaxAddresses(address buyback, address marketing, address staking) external onlyOwner() {
        taxAddresses.buyback = buyback;
        taxAddresses.marketing = marketing;
        taxAddresses.staking = staking;
    }

    modifier preventBlacklisted(address _account) {
        require(!_isBlacklisted[_account], "blacklisted!");
        _;
    }
    
    function setBlacklist(address account, bool val) public onlyOwner() {
        _isBlacklisted[account] = val;
    }

    function setExchanger(address account, bool val) public onlyOwner() {
        _isExchanger[account] = val;
    }

    function setTaxFree(address account, bool val) public onlyOwner() {
        _isTaxFree[account] = val;
    }

    function setTaxForAll(bool val) public onlyOwner() {
        enableTaxForAll = val;
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
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    
    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function _excludeAccount(address account) private {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    
    function excludeAccount(address account) external onlyOwner() {
        _excludeAccount(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function _approve(address owner, address spender, uint256 amount) private 
    preventBlacklisted(owner)
    preventBlacklisted(spender) {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private 
    preventBlacklisted(sender)
    preventBlacklisted(recipient)
    preventBlacklisted(_msgSender()) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _freeTax = true;
        if (((_isExchanger[sender] || _isExchanger[recipient]) && !_isTaxFree[sender] && !_isTaxFree[recipient]) || enableTaxForAll){
            _freeTax = false;
        }
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, TaxFee memory rFee, uint256 tTransferAmount, TaxFee memory tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFees(sender, tFee);
        _reflectFee(rFee.holder, tFee.holder);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, TaxFee memory rFee, uint256 tTransferAmount, TaxFee memory tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFees(sender, tFee);
        _reflectFee(rFee.holder, tFee.holder);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, TaxFee memory rFee, uint256 tTransferAmount, TaxFee memory tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFees(sender, tFee);
        _reflectFee(rFee.holder, tFee.holder);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, TaxFee memory rFee, uint256 tTransferAmount, TaxFee memory tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFees(sender, tFee);
        _reflectFee(rFee.holder, tFee.holder);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, TaxFee memory, uint256, TaxFee memory) {
        (uint256 tTransferAmount, TaxFee memory tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, TaxFee memory rFee) = _getRValues(tAmount, tFee, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, TaxFee memory) {
        TaxFee memory tFee = calculateTaxFees(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee.buyback).sub(tFee.marketing).sub(tFee.staking).sub(tFee.holder);
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, TaxFee memory tFee, uint256 currentRate) private pure returns (uint256, uint256, TaxFee memory) {
        uint256 rAmount = tAmount.mul(currentRate);
        TaxFee memory rFee = TaxFee(
            tFee.buyback.mul(currentRate),
            tFee.marketing.mul(currentRate),
            tFee.staking.mul(currentRate),
            tFee.holder.mul(currentRate)
        );
        uint256 rTransferAmount = rAmount.sub(rFee.buyback).sub(rFee.marketing).sub(rFee.staking).sub(rFee.holder);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function calculateTaxFees(uint256 tAmount) private view returns (TaxFee memory) {
        if (_freeTax){
            return  _zeroTax;
        }
        return TaxFee(
            tAmount.mul(taxFees.buyback).div(100),
            tAmount.mul(taxFees.marketing).div(100),
            tAmount.mul(taxFees.staking).div(100),
            tAmount.mul(taxFees.holder).div(100)
        );
    }

    function _takeFees(address sender, TaxFee memory values) private {
        _takeFee(sender, values.buyback, taxAddresses.buyback);
        _takeFee(sender, values.marketing, taxAddresses.marketing);
        _takeFee(sender, values.staking, taxAddresses.staking);
    }

    function _takeFee(address sender, uint256 tAmount, address recipient) private {
        if(recipient == address(0)) return;
        if(tAmount == 0) return;

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        if(_isExcluded[recipient])
            _tOwned[recipient] = _tOwned[recipient].add(tAmount);

        emit Transfer(sender, recipient, tAmount);
    }

    function transferToken(address token, address payable recipient, uint256 amount) public onlyOwner {
        if (token == address(0)){
            recipient.transfer(amount);
        }else{
            IERC20 erc = IERC20(token);
            erc.transfer(recipient, amount);
        }
    }

    receive() external payable {}
}