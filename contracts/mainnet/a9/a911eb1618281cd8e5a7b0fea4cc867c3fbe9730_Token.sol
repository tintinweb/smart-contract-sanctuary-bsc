// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Context.sol";
import "./Ownable.sol";

contract Token is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => address) public inviter;
    mapping (address => bool) private _isExcluded;
    mapping(address => bool) private _isExcludedFromFee;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private  _tTotal = 21000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    string private _name = 'BLHI Token';
    string private _symbol = 'BLHI';
    uint8 private _decimals = 9;
    
    address private _burnPool = address(0);
    address public _fundAddress = address(0);
    address public _exchangePool = address(0);
    address[] private _excluded;
    address private _inviterDefault = address(0);
    address public deadAddress = address(0x000000000000000000000000000000000000dEaD);
    
    uint256 public _taxFee = 2;
    uint256 private _previousTaxFee = _taxFee;
    uint256 public _burnFee = 1;
    uint256 private _previousBurnFee = _burnFee;
    uint256 public _fundFee = 3;
    uint256 private _previousFundFee = _fundFee;
    uint256 public _inviterFee = 4;
    uint256 private _previousInviterFee = _inviterFee;
    
    
    uint256 private _tFeeTotal;
    uint256 private _tBurnTotal;
    uint256 private _tFundTotal;
    uint256 private _tInviterTotal;
    
    uint256 public  MAX_STOP_FEE_TOTAL = 2022 * 10**uint256(_decimals);
    
    struct Tranfee {
        uint256 tAmount;
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tBurn;
        uint256 tFund;
        uint256 tInv;
    }
    struct MTranfee {
        uint256 tAmount;
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tBurn;
        uint256 tFund;
        uint256 tInv;
    }

    constructor (
        address inviterDefault
    ) public {
        
        _inviterDefault = inviterDefault;
        
        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
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
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    
    function totalBurn() public view returns (uint256) {
        return _tBurnTotal;
    }
    
    function totalFund() public view returns (uint256) {
        return _tFundTotal;
    }
    
    function totalInviter() public view returns (uint256) {
        return _tInviterTotal;
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
        restoreAllFee();
    }
    
    function setExchangePool(address exchangePool) public onlyOwner {
        _exchangePool = exchangePool;
    }
    
    function setFundAddress(address fundAddress) public onlyOwner {
        _fundAddress = fundAddress;
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
        
        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        bool shouldSetInviter = balanceOf(recipient) == 0 && inviter[recipient] == address(0) && 
                                !isContract(sender) && !isContract(recipient) && 
                                sender != owner() && recipient != owner();
        
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
         
         if(
             _isExcludedFromFee[sender] ||
             _isExcludedFromFee[recipient] ||
             (sender != _exchangePool && recipient != _exchangePool)
        )
            restoreAllFee();
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
        ) {
            _reflectFee(tranFee.rFee, tranFee.tBurn.mul(currentRate), tranFee.tFee, tranFee.tBurn);
            _rOwned[_fundAddress] = _rOwned[_fundAddress].add(tranFee.tFund.mul(currentRate));
            
            _tFundTotal = _tFundTotal.add(tranFee.tFund);
            
            _takeInviterFee(sender, recipient, tAmount);
            
            emit Transfer(sender, _burnPool, tranFee.tBurn);
            emit Transfer(sender, _fundAddress, tranFee.tFund);
        }
        emit Transfer(sender, recipient, tranFee.tTransferAmount);
    }
    
    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
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

        for (int256 i = 0; i < 3; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 20;
            } else if (i == 1) {
                rate = 15;
            } else {
                rate = 5;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = _inviterDefault;
            }
            uint256 curTAmount = tAmount.mul(rate).div(1000);
            uint256 curRAmount = curTAmount.mul(currentRate);
            
            _rOwned[cur] = _rOwned[cur].add(curRAmount);
            _tInviterTotal = _tInviterTotal.add(curTAmount);
            
            emit Transfer(sender, cur, curTAmount);
        }
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
    
    function calculateFundFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_fundFee).div(
            10 ** 2
        );
    }
    
    function calculateInvFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_inviterFee).div(
            10 ** 2
        );
    }

    function removeAllFee() private {
        if(_taxFee == 0 && _burnFee == 0 && _fundFee == 0 && _inviterFee == 0) return;
        _previousTaxFee = _taxFee;
        _previousBurnFee = _burnFee;
        _previousFundFee = _fundFee;
        _previousInviterFee = _inviterFee;
        _taxFee = 0;
        _burnFee = 0;
        _fundFee = 0;
        _inviterFee = 0;
    }
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _burnFee = _previousBurnFee;
        _fundFee = _previousFundFee;
        _inviterFee = _previousInviterFee;
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
        
        MTranfee memory mtranfee = _getTValues(tAmount);
        
        tranFee.tTransferAmount = mtranfee.tTransferAmount;
        tranFee.tFee = mtranfee.tFee;
        tranFee.tBurn = mtranfee.tBurn;
        tranFee.tFund = mtranfee.tFund;
        tranFee.tInv = mtranfee.tInv;
        
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(mtranfee);
        
        tranFee.rAmount = rAmount;
        tranFee.rTransferAmount = rTransferAmount;
        tranFee.rFee = rFee;
        
        return tranFee;
    }

    function _getTValues(uint256 tAmount) private view returns (MTranfee memory) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 tFund = calculateFundFee(tAmount);
        uint256 tInv = calculateInvFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tBurn).sub(tFund).sub(tInv);
        return MTranfee(tAmount, tTransferAmount, tFee, tBurn, tFund, tInv);
    }

    function _getRValues(MTranfee memory mtranfee) private view returns (uint256, uint256, uint256) {
        
        uint256 currentRate =  _getRate();
        
        uint256 rAmount = mtranfee.tAmount.mul(currentRate);
        uint256 rFee = mtranfee.tFee.mul(currentRate);
        uint256 rBurn = mtranfee.tBurn.mul(currentRate);
        uint256 rFund = mtranfee.tFund.mul(currentRate);
        uint256 rInv = mtranfee.tInv.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rBurn).sub(rFund).sub(rInv);
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