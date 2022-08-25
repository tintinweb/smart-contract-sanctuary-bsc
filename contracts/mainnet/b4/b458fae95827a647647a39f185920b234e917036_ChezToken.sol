//SPDX-License-Identifier: NONE
pragma solidity ^0.8.16;

import "Address.sol";

import "./IERC20.sol";
import "./Tokenomics.sol";

abstract contract UnStucker is Ownable {
    function withdrawStuckFunds() external onlyOwner {
        require(address(this).balance > 0);
        payable(_msgSender()).transfer(address(this).balance);
    }

    function withdrawStuckToken(address _token, uint _amount) external onlyOwner {
        address _spender = address(this);
        uint _balance = IERC20(_token).balanceOf(_spender);
        require(_balance >= _amount, "Balance >= Amount");

        IERC20(_token).approve(_spender, _balance);
        IERC20(_token).transferFrom(_spender, _msgSender(), _balance);
    }
}

abstract contract IERC20Token is IERC20, Tokenomics, Liquifier, UnStucker {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) internal _reflectedBalances;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping (address => uint256)) internal _allowances;
    
    mapping(address => bool) internal _isExcludedFromFee;
    mapping(address => bool) internal _isExcludedFromRewards;
    address[] private _excluded;

    constructor(string memory tName, string memory tSymbol, uint totalAmount) Tokenomics(tName, tSymbol, totalAmount) {
        _reflectedBalances[owner()] = _reflectedSupply;
        
        // exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        // exclude the owner and this contract from rewards
        _exclude(owner());
        _exclude(address(this));

        emit Transfer(address(0), owner(), TOTAL_SUPPLY);
     }
    
    /** Functions required by IERC20Metadat **/
        function name() external view returns (string memory) { return NAME; }
        function symbol() external view returns (string memory) { return SYMBOL; }
        function decimals() external pure returns (uint8) { return DECIMALS; }
        
    /** Functions required by IERC20Metadat - END **/
    /** Functions required by IERC20 **/
        function totalSupply() external view override returns (uint256) {
            return TOTAL_SUPPLY;
        }
        
        function balanceOf(address account) public view override returns (uint256){
            if (_isExcludedFromRewards[account]) return _balances[account];
            return tokenFromReflection(_reflectedBalances[account]);
        }
        
        function transfer(address recipient, uint256 amount) external override returns (bool){
            _transfer(_msgSender(), recipient, amount);
            return true;
        }
        
        function allowance(address owner, address spender) external view override returns (uint256){
            return _allowances[owner][spender];
        }
    
        function approve(address spender, uint256 amount) external override returns (bool) {
            _approve(_msgSender(), spender, amount);
            return true;
        }
        
        function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool){
            _transfer(sender, recipient, amount);
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
            return true;
        }
    /** Functions required by IERC20 - END **/

    function burn(uint256 amount) external {
        address sender = _msgSender();
        require(sender != address(0), "Error: burn from the zero address");
        require(sender != address(burnAddress), "Error: burn from the burn address");

        uint256 balance = balanceOf(sender);
        require(balance >= amount, "Error: burn amount exceeds balance");

        uint256 reflectedAmount = amount.mul(_getCurrentRate());

        // remove the amount from the sender's balance first
        _reflectedBalances[sender] = _reflectedBalances[sender].sub(reflectedAmount);
        if (_isExcludedFromRewards[sender])
            _balances[sender] = _balances[sender].sub(amount);

        _burnTokens( sender, amount, reflectedAmount );
    }
    
    function _burnTokens(address sender, uint256 tBurn, uint256 rBurn) internal {
        _reflectedBalances[burnAddress] = _reflectedBalances[burnAddress].add(rBurn);
        if (_isExcludedFromRewards[burnAddress])
            _balances[burnAddress] = _balances[burnAddress].add(tBurn);

        emit Transfer(sender, burnAddress, tBurn);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcludedFromRewards[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns(uint256) {
        require(tAmount <= TOTAL_SUPPLY, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount,0);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount,_getSumOfFees(_msgSender(), tAmount));
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) internal view returns(uint256) {
        require(rAmount <= _reflectedSupply, "Amount must be less than total reflections");
        uint256 currentRate = _getCurrentRate();
        return rAmount.div(currentRate);
    }
    
    function excludeFromReward(address account) external onlyOwner() {
        require(!_isExcludedFromRewards[account], "Account is not included");
        _exclude(account);
    }
    
    function _exclude(address account) internal {
        if(_reflectedBalances[account] > 0) {
            _balances[account] = tokenFromReflection(_reflectedBalances[account]);
        }
        _isExcludedFromRewards[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedFromRewards[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _balances[account] = 0;
                _isExcludedFromRewards[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function setExcludedFromFee(address account, bool value) external onlyOwner { _isExcludedFromFee[account] = value; }
    function isExcludedFromFee(address account) public view returns(bool) { return _isExcludedFromFee[account]; }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Error: approve from the zero address");
        require(spender != address(0), "Error: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _isSell(address recipient) internal view returns(bool) {
        return recipient == _pair;
    }

    function _isBuy(address sender) internal view returns(bool) {
        return sender == _pair;
    }

    function _isUnlimitedSender(address account) internal view returns(bool){
        return (account == owner());
    }

    function _isUnlimitedRecipient(address account) internal view returns(bool){
        return (account == owner() || account == burnAddress);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "Error: transfer from the zero address");
        require(recipient != address(0), "Error: transfer to the zero address");
        require(sender != address(burnAddress), "Error: transfer from the burn address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        bool takeFee = true;
        if (isInTaxFree || inSwapAndLiquify) { takeFee = false; 
        } else {
            if (amount > maxTransactionAmount && _isSell(recipient) && !_isUnlimitedSender(sender) && !_isUnlimitedRecipient(recipient)){
                revert("Sell amount exceeds the maxTxAmount.");
            }
        }

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) { takeFee = false; }

        _beforeTokenTransfer(sender, recipient, amount, takeFee);
        _transferTokens(sender, recipient, amount, takeFee);
    }

    function _transferTokens(address sender, address recipient, uint256 amount, bool takeFee) private {
        uint256 sumOfFees = _getSumOfFees(sender, amount);
        if (!takeFee) { sumOfFees = 0; }
        
        (uint256 rAmount, uint256 rTransferAmount, uint256 tAmount, uint256 tTransferAmount, uint256 currentRate) = _getValues(amount, sumOfFees);
        
        _reflectedBalances[sender] = _reflectedBalances[sender].sub(rAmount);
        _reflectedBalances[recipient] = _reflectedBalances[recipient].add(rTransferAmount);
    
        if (_isExcludedFromRewards[sender]) { _balances[sender] = _balances[sender].sub(tAmount); }
        if (_isExcludedFromRewards[recipient]) { _balances[recipient] = _balances[recipient].add(tTransferAmount); }
        
        _takeFees(amount, currentRate, sumOfFees, _isBuy(sender));
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function _takeFees(uint256 amount, uint256 currentRate, uint256 sumOfFees, bool buy) private {
        if (sumOfFees > 0 && !isInTaxFree) {
            _takeTransactionFees(amount, currentRate, buy);
        }
    }
    
    function _getValues(uint256 tAmount, uint256 feesSum) internal view returns (uint256, uint256, uint256, uint256, uint256) {
        
        uint256 tTotalFees = tAmount.mul(feesSum).div(FEES_DIVISOR);
        uint256 tTransferAmount = tAmount.sub(tTotalFees);
        uint256 currentRate = _getCurrentRate();
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTotalFees = tTotalFees.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rTotalFees);
        
        return (rAmount, rTransferAmount, tAmount, tTransferAmount, currentRate);
    }
    
    function _getCurrentRate() internal view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    
    function _getCurrentSupply() internal view returns(uint256, uint256) {
        uint256 rSupply = _reflectedSupply;
        uint256 tSupply = TOTAL_SUPPLY;  

        /**
         * The code below removes balances of addresses excluded from rewards from
         * rSupply and tSupply, which effectively increases the % of transaction fees
         * delivered to non-excluded holders
         */
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_reflectedBalances[_excluded[i]] > rSupply || _balances[_excluded[i]] > tSupply) return (_reflectedSupply, TOTAL_SUPPLY);
            rSupply = rSupply.sub(_reflectedBalances[_excluded[i]]);
            tSupply = tSupply.sub(_balances[_excluded[i]]);
        }
        if (tSupply == 0 || rSupply < _reflectedSupply.div(TOTAL_SUPPLY)) return (_reflectedSupply, TOTAL_SUPPLY);
        return (rSupply, tSupply);
    }
    
    function _beforeTokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) internal virtual;
    
    function _getSumOfFees(address sender, uint256 amount) internal view virtual returns (uint256);

    function _isV2Pair(address account) internal view virtual returns(bool);

    function _redistribute(uint256 amount, uint256 currentRate, uint256 fee, uint256 index, bool buy) internal {
        uint256 tFee = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rFee = tFee.mul(currentRate);

        _reflectedSupply = _reflectedSupply.sub(rFee);
        _addFeeCollectedAmount(index, tFee, buy);
    }

    function _takeTransactionFees(uint256 amount, uint256 currentRate, bool buy) internal virtual;
}

contract ChezToken is IERC20Token {
    using SafeMath for uint256;

    constructor(address _RouterV2, string memory tName, string memory tSymbol, uint totalAmount) IERC20Token(tName, tSymbol, totalAmount) {
        initializeLiquiditySwapper(_RouterV2, numberOfTokensToSwapToLiquidity);

        _exclude(_pair);
        _exclude(burnAddress);
    }

    function _cleanPendFees() private {
        // 1 - Buy, 2 - Sell
        delete pendFees[1][developAddress]; delete pendFees[2][developAddress];
        delete pendFees[1][marketingAddress]; delete pendFees[2][marketingAddress];
        delete totPendFees;
    }

    function resetPend() external onlyOwner {
        _cleanPendFees();
    }
    
    function _isV2Pair(address account) internal view override returns(bool){
        return (account == _pair);
    }

    function _getSumOfFees(address sender, uint256) internal view override returns (uint256){ 
        return _isBuy(sender) ? sumOfFeesBuy : sumOfFeesSell;
    }
    
    function _beforeTokenTransfer(address sender, address, uint256, bool) internal override {
        if (!isInTaxFree) {
            (, uint256 contractTokenBalance) = balanceOf(address(this)).trySub(totPendFees);
            if (!liquify(contractTokenBalance, sender) && !_isBuy(sender) && feeInBNB && !inSwapAndLiquify) {
                _takeFeeToBNB();
            }
        }
    }

    function _takeTransactionFees(uint256 amount, uint256 currentRate, bool buy) internal override {
        if (isInTaxFree) return;
        
        uint256 feesCount = _getFeesCount(buy);
        for (uint256 index = 0; index < feesCount; index++) {
            (FeeType name, uint256 fee, address recipient,) = _getFee(index, buy);
            // no need to check fee < 0 as the fee is uint (i.e. from 0 to 2^256-1)
            if (fee == 0) continue;

            if (name == FeeType.Rfi) {
                _redistribute(amount, currentRate, fee, index, buy);
            } else if (feeInBNB && name == FeeType.External) {
                _addPendFees(amount, currentRate, fee, recipient, index, buy);
            } else {
                _takeFee(amount, currentRate, fee, recipient, index);
            }
        }
    }

    function _burn(uint256 amount, uint256 currentRate, uint256 fee, uint256 index) private {
        uint256 tBurn = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rBurn = tBurn.mul(currentRate);

        _burnTokens(address(this), tBurn, rBurn);
        _addFeeCollectedAmount(index, tBurn, _isBuy(_msgSender()));
    }

    function _takeFee(uint256 amount, uint256 currentRate, uint256 fee, address recipient, uint256 index) private {
        uint256 tAmount = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rAmount = tAmount.mul(currentRate);

        _reflectedBalances[recipient] = _reflectedBalances[recipient].add(rAmount);
        if (_isExcludedFromRewards[recipient]) {
            _balances[recipient] = _balances[recipient].add(tAmount);
            emit Transfer(_msgSender(), recipient, tAmount);
        } else { emit Transfer(_msgSender(), recipient, rAmount); }
        _addFeeCollectedAmount(index, tAmount, _isBuy(_msgSender()));
    }

    function _addPendFees(uint256 amount, uint256 currentRate, uint256 fee, address recipient, uint256 index, bool buy) private {
        uint256 tAmount = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rAmount = tAmount.mul(currentRate);
        _reflectedBalances[address(this)] = _reflectedBalances[address(this)].add(rAmount);
        _balances[address(this)] = _balances[address(this)].add(tAmount);

        totPendFees = totPendFees.add(tAmount);
        if (buy) { pendFees[1][recipient] = fee;
        } else { pendFees[2][recipient] = fee; }
        _addFeeCollectedAmount(index, tAmount, false);
    }

    function _sendFeeBNB(uint _newBalance, uint fee, address recipient, uint _totalShares) private {
        uint256 feeAmount = (_newBalance * fee) / _totalShares;
        Address.sendValue(payable(recipient), feeAmount);
    }

    function _takeFeeToBNB() private lockTheSwap {
        if (totPendFees == 0 || balanceOf(address(this)) < totPendFees) return;

        uint _feeCaBuySell = pendFees[1][developAddress] + pendFees[2][developAddress];
        uint _feeMaBuySell = pendFees[1][marketingAddress] + pendFees[2][marketingAddress];
        uint _totalShares = _feeCaBuySell + _feeMaBuySell;

        uint initialBalance = address(this).balance;
        _swapTokensForEth(totPendFees);
        uint newBalance = address(this).balance.sub(initialBalance);

        if (_feeCaBuySell > 0) _sendFeeBNB(newBalance, _feeCaBuySell, developAddress, _totalShares);
        if (_feeMaBuySell > 0) _sendFeeBNB(newBalance, _feeMaBuySell, marketingAddress, _totalShares);

        _cleanPendFees();
    }
    
    function _approveDelegate(address owner, address spender, uint256 amount) internal override {
        _approve(owner, spender, amount);
    }
}