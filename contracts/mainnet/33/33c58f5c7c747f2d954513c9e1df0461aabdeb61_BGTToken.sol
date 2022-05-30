// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Context.sol";
import "./Ownable.sol";

contract BGTToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private  _tTotal = 100000000000 * 10**6;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    
    uint256 private _tBurnTotal;

    string private _name = 'BGT';
    string private _symbol = 'BGT';
    uint8 private _decimals = 6;
    
    address private _burnPool = address(0);
    address public _exchangePool = address(0);
    address public _burnAddress = address(0x000000000000000000000000000000000000dEaD);
    
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => address) public inviter;
    
    
    uint256 public _taxFee = 0;
    //uint256 private _previousTaxFee = _taxFee;
    uint256 public _burnFee = 0;
    //uint256 private _previousBurnFee = _burnFee;
    uint256 public _liquidityFee = 0;
    //uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 public _inviterFee = 0;
    //uint256 private _previousInviterFee = _inviterFee;
    uint256 public  MAX_STOP_FEE_TOTAL = 88 * 10**uint256(_decimals);
    
    uint256 public _buyTaxFee;
    uint256 public _sellTaxFee;
    //uint256 public buyMarketingFee;
    //uint256 public sellMarketingFee;
    uint256 public _buyBurnFee;
    uint256 public _sellBurnFee;
    uint256 public _buyLiquidityFee;
    uint256 public _sellLiquidityFee;
    uint256 public _buyInviterFee;
    uint256 public _sellInviterFee;
    
    struct Tranfee {
        uint256 tAmount;
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tBurn;
        uint256 tLiquidity;
        uint256 tInviter;
    }
    
    constructor (
        uint256[4] memory buyFeeSetting_, // _taxFee,_burnFee,_liquidityFee,_inviterFee
        uint256[4] memory sellFeeSetting_ // _taxFee,_burnFee,_liquidityFee,_inviterFee
    ) public {
        _rOwned[_msgSender()] = _rTotal;
        
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        _buyTaxFee = buyFeeSetting_[0];
        _buyBurnFee = buyFeeSetting_[1];
        _buyLiquidityFee = buyFeeSetting_[2];
        _buyInviterFee = buyFeeSetting_[3];
        _sellTaxFee = sellFeeSetting_[0];
        _sellBurnFee = sellFeeSetting_[1];
        _sellLiquidityFee = sellFeeSetting_[2];
        _sellInviterFee = sellFeeSetting_[3];
        
        emit Transfer(address(0), _msgSender(), _tTotal);
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
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    
    function totalBurn() public view returns (uint256) {
        return _tBurnTotal;
    }

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        Tranfee memory tranFee = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(tranFee.rAmount);
        _rTotal = _rTotal.sub(tranFee.rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        Tranfee memory tranFee;
        if (!deductTransferFee) {
            tranFee = _getValues(tAmount);
            return tranFee.rAmount;
        } else {
            tranFee = _getValues(tAmount);
            return tranFee.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
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

    function setMaxStopFeeTotal(uint256 total) public onlyOwner {
        MAX_STOP_FEE_TOTAL = total;
    }
    
    function setExchangePool(address exchangePool) public onlyOwner {
        _exchangePool = exchangePool;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        // set invite
        bool shouldSetInviter = balanceOf(recipient) == 0 && inviter[recipient] == address(0) 
            && !isContract(sender) && !isContract(recipient) && amount >= 1 * 10**uint256(_decimals-1) &&
            sender != owner() && recipient != owner();
        
        if(sender == _exchangePool){
            _taxFee = _buyTaxFee;
            _burnFee = _buyBurnFee;
            _liquidityFee = _buyLiquidityFee;
            _inviterFee = _buyInviterFee;
            
        }
        if(recipient == _exchangePool){
            _taxFee = _sellTaxFee;
            _burnFee = _sellBurnFee;
            _liquidityFee = _sellLiquidityFee;
            _inviterFee = _sellInviterFee;
        }
        
         if(_tTotal <= MAX_STOP_FEE_TOTAL) {
            removeAllFee();
            _transferStandard(sender, recipient, amount);
        } else {
        if(
            _isExcludedFromFee[sender] ||
            _isExcludedFromFee[recipient] ||
            (sender != _exchangePool && recipient != _exchangePool)
        )
            removeAllFee();
        
         _transferStandard(sender, recipient, amount);
        } 
        
        if (shouldSetInviter) {
            inviter[recipient] = sender;
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        
        uint256 currentRate =  _getRate();
        Tranfee memory tranFee = _getValues(tAmount);
        
        _rOwned[sender] = _rOwned[sender].sub(tranFee.rAmount);
        
        _rOwned[recipient] = _rOwned[recipient].add(tranFee.rTransferAmount);  
        
        if(
            !_isExcludedFromFee[sender] &&
            !_isExcludedFromFee[recipient] &&
            (sender == _exchangePool || recipient == _exchangePool)
        ){
            _rOwned[_exchangePool] = _rOwned[_exchangePool].add(tranFee.tLiquidity.mul(currentRate));
            _reflectFee(tranFee.rFee, tranFee.tBurn.mul(currentRate), tranFee.tFee, tranFee.tBurn);
            takeInviterFee(sender,recipient,tranFee.tInviter);
            emit Transfer(sender, _burnPool, tranFee.tBurn);
            emit Transfer(sender, _exchangePool, tranFee.tLiquidity);
        }
        emit Transfer(sender, recipient, tranFee.tTransferAmount);
    }
    
    function takeInviterFee(
        address sender,
        address recipient,
        uint256 tInviter
    ) private {
        if (_inviterFee == 0) return;
        uint256 currentRate =  _getRate();

        address cur = sender;
        if (sender == _exchangePool) {
            cur = recipient;
        } else if (recipient == _exchangePool) {
            cur = sender;
        }
        if (cur == address(0)) {
            return;
        }
        
        cur = inviter[cur];
        if (cur == address(0)) {
            cur = _burnAddress;
        }
        uint256 curRAmount = tInviter.mul(currentRate);
        _rOwned[cur] = _rOwned[cur].add(curRAmount);
        emit Transfer(sender, cur, tInviter);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10 ** 2
        );
    }

   function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**2
        );
    }
    
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10 ** 2
        );
    }
    
    function calculateInviterFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_inviterFee).div(
            10 ** 2
        );
    }
    
    

    function removeAllFee() private {
        if(_taxFee == 0 && _burnFee == 0 && _liquidityFee == 0 && _inviterFee == 0) return;
        _taxFee = 0;
        _burnFee = 0;
        _liquidityFee = 0;
        _inviterFee = 0;
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    

    function _reflectFee(uint256 rFee, uint256 rBurn, uint256 tFee, uint256 tBurn) private {
        _rTotal = _rTotal.sub(rFee).sub(rBurn);
        _tFeeTotal = _tFeeTotal.add(tFee);
        _tBurnTotal = _tBurnTotal.add(tBurn);
        
        _tTotal = _tTotal.sub(tBurn);
    }
    
    

    function _getValues(uint256 tAmount) private view returns (Tranfee memory) {
        Tranfee memory tranFee;
        tranFee.tAmount = tAmount;
        (uint256 tTransferAmount, uint256 tFee, uint256 tBurn, uint256 tLiquidity, uint256 tInviter) = _getTValues(tAmount);
        tranFee.tTransferAmount = tTransferAmount;
        tranFee.tFee = tFee;
        tranFee.tBurn = tBurn;
        tranFee.tLiquidity = tLiquidity;
        tranFee.tInviter = tInviter;
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tranFee);
        tranFee.rAmount= rAmount;
        tranFee.rTransferAmount= rTransferAmount;
        tranFee.rFee= rFee;
        return tranFee;
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256,uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tInviter = calculateInviterFee(tAmount);
        
        uint256 tTransferAmount = tAmount.sub(tFee);
        tTransferAmount = tTransferAmount.sub(tBurn).sub(tLiquidity).sub(tInviter);
        return (tTransferAmount, tFee, tBurn, tLiquidity, tInviter);
    }

    function _getRValues(Tranfee memory tranFee) private view returns (uint256, uint256, uint256) {
        
        uint256 currentRate =  _getRate();
        
        uint256 rAmount = tranFee.tAmount.mul(currentRate);
        uint256 rFee = tranFee.tFee.mul(currentRate);
        uint256 rBurn = tranFee.tBurn.mul(currentRate);
        uint256 rLiquidity = tranFee.tLiquidity.mul(currentRate);
        uint256 rInviter = tranFee.tInviter.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rBurn).sub(rLiquidity);
        rTransferAmount = rTransferAmount.sub(rInviter);
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
    
}