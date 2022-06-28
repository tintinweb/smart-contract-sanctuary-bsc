// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "Ownable.sol";
import "Pausable.sol";
import "SafeMath.sol";
import "ITBC10Token.sol";
import "IDividendManager.sol";
import "RecoverableFunds.sol";
import "WithCallback.sol";

contract TBC10Token is ITBC10Token, Ownable, Pausable, RecoverableFunds, WithCallback {

    using SafeMath for uint256;

    uint16 private constant PERCENT_RATE = 1000;
    uint256 private constant MAX = ~uint256(0);

    // -----------------------------------------------------------------------------------------------------------------
    // ERC20
    // -----------------------------------------------------------------------------------------------------------------

    mapping(address => mapping(address => uint256)) private _allowances;
    string private _name = "TBC10 Token";
    string private _symbol = "TBC10";

    function name() override public view returns (string memory) {
        return _name;
    }

    function symbol() override public view returns (string memory) {
        return _symbol;
    }

    function decimals() override public pure returns (uint8) {
        return 18;
    }

    function totalSupply() override external view returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) override external view returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) override external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) override external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) override public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) override external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) override external returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function burn(uint256 amount) override external {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) override external  {
        uint256 currentAllowance = _allowances[account][_msgSender()];
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address account, uint256 amount) internal whenNotPaused {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 rAmount = _getRAmount(amount, _getRate());
        require(_rOwned[account] >= rAmount, "ERC20: burn amount exceeds balance");
        _decreaseBalance(account, amount, rAmount);
        _decreaseTotalSupply(amount, rAmount);
        emit Transfer(account, address(0), amount);
        _burnCallback(account, amount, rAmount);
    }

    // -----------------------------------------------------------------------------------------------------------------
    // PAUSABLE
    // -----------------------------------------------------------------------------------------------------------------

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // -----------------------------------------------------------------------------------------------------------------
    // FEES
    // -----------------------------------------------------------------------------------------------------------------

    mapping(FeeType => Fees) private _fees;
    mapping(FeeType => FeeAddresses) private _feeAddresses;
    address private _dividendsAddress;
    address private _buybackAddress;
    address private _treasuryAddress;
    address private _liquidityAddress;
    mapping(address => bool) private _isTaxable;
    mapping(address => bool) private _isTaxExempt;

    function getFees(FeeType feeType) override external view returns (Fees memory) {
        return _fees[feeType];
    }

    function setFees(FeeType feeType, uint rfi, uint dividends, uint buyback, uint treasury, uint liquidity) override external onlyOwner {
        require(feeType != FeeType.NONE, "TBC10Token: Wrong FeeType");
        _fees[feeType] = Fees(rfi, dividends, buyback, treasury, liquidity);
    }

    function getFeeAddresses(FeeType feeType) override public view returns (FeeAddresses memory) {
        return _feeAddresses[feeType];
    }

    function setFeeAddresses(FeeType feeType, address dividends, address buyback, address treasury, address liquidity) override external onlyOwner {
        require(feeType != FeeType.NONE, "TBC10Token: Wrong FeeType");
        _feeAddresses[feeType] = FeeAddresses(dividends, buyback, treasury, liquidity);
    }

    function setTaxable(address account, bool value) override external onlyOwner {
        require(_isTaxable[account] != value, "TBC10Token: already set");
        _isTaxable[account] = value;
    }

    function setTaxExempt(address account, bool value) override external onlyOwner {
        require(_isTaxExempt[account] != value, "TBC10Token: already set");
        _isTaxExempt[account] = value;
    }

    function _getFeeAmounts(uint256 amount, FeeType feeType) internal view returns (Fees memory) {
        Fees memory fees = _fees[feeType];
        Fees memory feeAmounts;
        feeAmounts.rfi = amount.mul(fees.rfi).div(PERCENT_RATE);
        feeAmounts.dividends = amount.mul(fees.dividends).div(PERCENT_RATE);
        feeAmounts.buyback = amount.mul(fees.buyback).div(PERCENT_RATE);
        feeAmounts.treasury = amount.mul(fees.treasury).div(PERCENT_RATE);
        feeAmounts.liquidity = amount.mul(fees.liquidity).div(PERCENT_RATE);
        return feeAmounts;
    }

    function _getFeeType(address sender, address recipient) internal view returns (FeeType) {
        if (_isTaxExempt[sender] || _isTaxExempt[recipient]) return FeeType.NONE;
        if (_isTaxable[sender]) return FeeType.BUY;
        if (_isTaxable[recipient]) return FeeType.SELL;
        return FeeType.NONE;
    }

    // -----------------------------------------------------------------------------------------------------------------
    // RFI
    // -----------------------------------------------------------------------------------------------------------------

    uint256 private _tTotal = 10_000_000_000 ether;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    constructor() {
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function getROwned(address account) override external view returns (uint256) {
        return _rOwned[account];
    }

    function getRTotal() override external view returns (uint256) {
        return _rTotal;
    }

    function excludeFromRFI(address account) override external onlyOwner {
        require(!_isExcluded[account], "TBC10 Token: account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInRFI(address account) override external onlyOwner {
        require(_isExcluded[account], "TBC10 Token: account is already included");
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

    function reflect(uint256 tAmount) override external {
        address account = _msgSender();
        require(!_isExcluded[account], "TBC10 Token: excluded addresses cannot call this function");
        uint256 rAmount = _getRAmount(tAmount, _getRate());
        _decreaseBalance(account, tAmount, rAmount);
        _reflect(tAmount, rAmount);
        _reflectCallback(account, tAmount, rAmount);
    }

    function reflectionFromToken(uint256 tAmount) override external view returns (uint256) {
        require(tAmount <= _tTotal, "TBC10 Token: amount must be less than supply");
        return _getRAmount(tAmount, _getRate());
    }

    function tokenFromReflection(uint256 rAmount) override public view returns (uint256) {
        require(rAmount <= _rTotal, "TBC10 Token: amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _reflect(uint256 tAmount, uint256 rAmount) internal whenNotPaused {
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        _reflectCallback(tAmount, rAmount);
    }

    function _getCurrentSupply() internal view returns (uint256, uint256) {
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

    function _getRate() internal view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getRAmount(uint256 tAmount, uint256 currentRate) internal pure returns (uint256) {
        return tAmount.mul(currentRate);
    }

    function _getRAmounts(Amounts memory t, FeeType feeType, uint256 currentRate) internal pure returns (Amounts memory) {
        Amounts memory r;
        r.sum = _getRAmount(t.sum, currentRate);
        r.transfer = r.sum;
        if (feeType != FeeType.NONE) {
            r.rfi = _getRAmount(t.rfi, currentRate);
            r.dividends = _getRAmount(t.dividends, currentRate);
            r.buyback = _getRAmount(t.buyback, currentRate);
            r.treasury = _getRAmount(t.treasury, currentRate);
            r.liquidity = _getRAmount(t.liquidity, currentRate);
            r.transfer = r.transfer.sub(r.rfi).sub(r.dividends).sub(r.buyback).sub(r.treasury).sub(r.liquidity);
        }
        return r;
    }

    function _getTAmounts(uint256 tAmount, FeeType feeType) internal view returns (Amounts memory) {
        Amounts memory t;
        t.sum = tAmount;
        t.transfer = t.sum;
        if (feeType != FeeType.NONE) {
            Fees memory fees = _getFeeAmounts(tAmount, feeType);
            t.rfi = fees.rfi;
            t.dividends = fees.dividends;
            t.buyback = fees.buyback;
            t.treasury = fees.treasury;
            t.liquidity = fees.liquidity;
            t.transfer = t.transfer.sub(t.rfi).sub(t.dividends).sub(t.buyback).sub(t.treasury).sub(t.liquidity);
        }
        return t;
    }

    function _getAmounts(uint256 tAmount, FeeType feeType) internal view returns (Amounts memory r, Amounts memory t) {
        t = _getTAmounts(tAmount, feeType);
        r = _getRAmounts(t, feeType, _getRate());
    }

    function _increaseBalance(address account, uint256 tAmount, uint256 rAmount) internal {
        _rOwned[account] = _rOwned[account].add(rAmount);
        if (_isExcluded[account]) {
            _tOwned[account] = _tOwned[account].add(tAmount);
        }
        _increaseBalanceCallback(account, tAmount, rAmount);
    }

    function _decreaseBalance(address account, uint256 tAmount, uint256 rAmount) internal {
        _rOwned[account] = _rOwned[account].sub(rAmount);
        if (_isExcluded[account]) {
            _tOwned[account] = _tOwned[account].sub(tAmount);
        }
        _decreaseBalanceCallback(account, tAmount, rAmount);
    }

    function _decreaseTotalSupply(uint256 tAmount, uint256 rAmount) private {
        _tTotal = _tTotal.sub(tAmount);
        _rTotal = _rTotal.sub(rAmount);
        _decreaseTotalSupplyCallback(tAmount, rAmount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal whenNotPaused {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        FeeType feeType = _getFeeType(sender, recipient);
        (Amounts memory r, Amounts memory t) = _getAmounts(amount, feeType);
        require(_rOwned[sender] >= r.sum, "ERC20: transfer amount exceeds balance");
        _decreaseBalance(sender, t.sum, r.sum);
        _increaseBalance(recipient, t.transfer, r.transfer);
        emit Transfer(sender, recipient, t.transfer);
        if (t.sum != t.transfer) {
            FeeAddresses memory feeAddresses = getFeeAddresses(feeType);
            if (t.rfi > 0) {
                _reflect(t.rfi, r.rfi);
            }
            if (t.dividends > 0) {
                _increaseBalance(feeAddresses.dividends, t.dividends, r.dividends);
            }
            if (t.buyback > 0) {
                _increaseBalance(feeAddresses.buyback, t.buyback, r.buyback);
            }
            if (t.treasury > 0) {
                _increaseBalance(feeAddresses.treasury, t.treasury, r.treasury);
            }
            if (t.liquidity > 0) {
                _increaseBalance(feeAddresses.liquidity, t.liquidity, r.liquidity);
            }
            emit FeeTaken(t.rfi, t.dividends, t.buyback, t.treasury, t.liquidity);
        }
        _transferCallback(sender, recipient, t.sum, t.transfer, r.sum, r.transfer);
    }

}