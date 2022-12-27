//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './IERC20.sol';
import './Ownable.sol';
import './SafeMath.sol';
import './Address.sol';
import './IPancakeV2Router02.sol';
import './IPancakeV2Factory.sol';
import './IPancakeV2Pair.sol';

contract BWRToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isBlacklisted;

    address[] private _excluded;
    mapping(address => bool) private _isWhitelisted;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 21_000_000_000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = 'BWRabbit Coin';
    string private _symbol = 'BWR';
    uint8 private _decimals = 18;

    // Base Fees
    uint256 public _taxFee = 5;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _liquidityFee = 5;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _burnFee = 5;
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _marketingFee = 10;
    address public marketingWallet;
    uint256 private _previousMarketingFee = _marketingFee;

    // Sell Fees
    uint256 public _sellTaxFee = 4;
    uint256 public _sellLiquidityFee = 8;
    uint256 public _sellMarketingFee = 12;
    uint256 public _sellBurnFee = 8;

    // Sell limit
    uint256 public _sellLimit = 10;

    // Anti whale
    uint256 public constant MAX_HOLDING_PERCENTS_DIVISOR = 10000;
    uint256 public _maxHoldingPercents = 50;
    bool public antiWhaleEnabled = false;
    bool public whitelistEnabled = true;

    // Anti bot
    mapping(uint256 => bool) allowedBuyAmount;
    bool public antiBotEnabled = false;

    IPancakeV2Router02 public pancakeV2Router;
    address public pancakeV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    uint256 private numTokensSellToAddToLiquidity = 1000000 * 10**18;
    uint256[] _allowedBuyAmount = [
        64740,
        123869,
        269755,
        539510,
        910426,
        1365640,
        2048461,
        3072692,
        4609039,
        6913559,
        10370340,
        15555511,
        23333267,
        34999902,
        52499854
    ];

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        IPancakeV2Router02 _pancakeV2Router,
        address _marketingWallet
    ) {
        marketingWallet = _marketingWallet;
        _rOwned[_msgSender()] = _rTotal;

        // Create a pancake pair for this new token
        pancakeV2Pair = IPancakeV2Factory(_pancakeV2Router.factory()).createPair(
            address(this),
            _pancakeV2Router.WETH()
        );

        // set the rest of the contract variables
        pancakeV2Router = _pancakeV2Router;

        //exclude owner, anti manager and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        _isWhitelisted[owner()] = true;
        _isWhitelisted[address(this)] = true;
        _isWhitelisted[_marketingWallet] = true;

        // Init anti bot allowed token amounts
        for (uint256 i = 0; i < _allowedBuyAmount.length; i++) {
            allowedBuyAmount[_allowedBuyAmount[i] * 10**18] = true;
        }

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (from == address(0) || to == address(0)) return;
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

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                'BEP20: transfer amount exceeds allowance'
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                'BEP20: decreased allowance below zero'
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], 'Excluded addresses cannot call this function');
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, 'Amount must be less than supply');
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, 'Amount must be less than total reflections');
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(
            account != address(pancakeV2Router),
            'We can not exclude Pancake router.'
        );
        require(!_isExcluded[account], 'Account is already excluded');
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], 'Account is already excluded');
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

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    //to receive BNB from pancakeV2Router when swapping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(
            tAmount
        );
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            _getRate()
        );
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply)
                return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(10**2);
    }

    function activateSellFee() private {
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBurnFee = _burnFee;
        _previousMarketingFee = _marketingFee;

        _taxFee = _sellTaxFee;
        _liquidityFee = _sellLiquidityFee;
        _marketingFee = _sellMarketingFee;
        _burnFee = _sellBurnFee;
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0 && _marketingFee == 0 && _burnFee == 0)
            return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBurnFee = _burnFee;
        _previousMarketingFee = _marketingFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _marketingFee = 0;
        _burnFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _burnFee = _previousBurnFee;
        _marketingFee = _previousMarketingFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

     function isBlacklisted(address account) public view returns (bool) {
        return _isBlacklisted[account];
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _isWhitelisted[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), 'BEP20: transfer from the zero address');
        require(amount > 0, 'Transfer amount must be greater than zero');
        require(!_isBlacklisted[from], 'Transfer from blacklisted address');
        require(!_isBlacklisted[to], 'Transfer to blacklisted address');

        _beforeTokenTransfer(from, to, amount);

        if (antiBotEnabled && from == pancakeV2Pair) {
            require(allowedBuyAmount[amount], 'Only allowed buy amounts');
        }

         if (whitelistEnabled && from == pancakeV2Pair) {
            require(_isWhitelisted[to], 'Only whitelisted');
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancake pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != pancakeV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount);

        if (antiWhaleEnabled) {
            uint256 maxAllowed = (_tTotal * _maxHoldingPercents) /
                MAX_HOLDING_PERCENTS_DIVISOR;
            if (to == pancakeV2Pair) {
                require(
                    amount <= maxAllowed,
                    'Transacted amount exceed the max allowed value'
                );
            } else {
                require(
                    balanceOf(to) <= maxAllowed,
                    'Wallet balance exceeds the max limit'
                );
            }
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half);
        // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to pancake
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeV2Router.WETH();

        _approve(address(this), address(pancakeV2Router), tokenAmount);

        // make the swap
        pancakeV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeV2Router), tokenAmount);

        // add the liquidity
        pancakeV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            removeAllFee();
        } else if (recipient == pancakeV2Pair) {
            require(amount <= balanceOf(sender).mul(_sellLimit).div(100), 'Sell limit');
            activateSellFee();
        }

        //Calculate burn amount and marketing amount
        uint256 burnAmt = amount.mul(_burnFee).div(100);
        uint256 marketingAmt = amount.mul(_marketingFee).div(100);

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(
                sender,
                recipient,
                (amount.sub(burnAmt).sub(marketingAmt))
            );
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(
                sender,
                recipient,
                (amount.sub(burnAmt).sub(marketingAmt))
            );
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, (amount.sub(burnAmt).sub(marketingAmt)));
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(
                sender,
                recipient,
                (amount.sub(burnAmt).sub(marketingAmt))
            );
        } else {
            _transferStandard(sender, recipient, (amount.sub(burnAmt).sub(marketingAmt)));
        }

        //Temporarily remove fees to transfer to burn address and marketing wallet
        _taxFee = 0;
        _liquidityFee = 0;

        _transferStandard(sender, address(0), burnAmt);
        _transferStandard(sender, marketingWallet, marketingAmt);

        //Restore tax and liquidity fees
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;

        if (
            _isExcludedFromFee[sender] ||
            _isExcludedFromFee[recipient] ||
            recipient == pancakeV2Pair
        ) {
            restoreAllFee();
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

     function ban(address account) public onlyOwner {
        _isBlacklisted[account] = true;
    }

    function unban(address account) public onlyOwner {
        _isBlacklisted[account] = false;
    }

    function excludeFromWhitelist(address account) public onlyOwner {
        _isWhitelisted[account] = false;
    }

    function includeInWhitelist(address account) public onlyOwner {
        _isWhitelisted[account] = true;
    }

    function setMarketingWallet(address newWallet) external onlyOwner {
        marketingWallet = newWallet;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner {
        _marketingFee = marketingFee;
    }

    function setBurnFeePercent(uint256 burnFee) external onlyOwner {
        _burnFee = burnFee;
    }

    function setSellBurnFeePercent(uint256 sellBurnFee) external onlyOwner {
        _sellBurnFee = sellBurnFee;
    }

    function setSellLimitPercent(uint256 sellLimit) external onlyOwner {
        _sellLimit = sellLimit;
    }

    function setSellMarketingFeePercent(uint256 sellMarketingFee) external onlyOwner {
        _sellMarketingFee = sellMarketingFee;
    }

    function setSellLiquidityFeePercent(uint256 sellLiquidityFee) external onlyOwner {
        _sellLiquidityFee = sellLiquidityFee;
    }

    function setSellTaxFeePercent(uint256 sellTaxFee) external onlyOwner {
        _sellTaxFee = sellTaxFee;
    }

    function setMaxHoldingPercents(uint256 maxHoldingPercents) external onlyOwner {
        _maxHoldingPercents = maxHoldingPercents;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setAntiWhale(bool enabled) external {
        require(
            msg.sender == owner(),
            'Only admin or anti manager allowed'
        );
        antiWhaleEnabled = enabled;
    }

    function setWhitelist(bool enabled) external {
        require(
            msg.sender == owner(),
            'Only admin or anti manager allowed'
        );
        whitelistEnabled = enabled;
    }

    function setAntiBot(bool enabled) external {
        require(
            msg.sender == owner(),
            'Only admin or anti manager allowed'
        );
        antiBotEnabled = enabled;
    }
}