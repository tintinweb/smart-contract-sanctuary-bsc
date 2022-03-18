// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "./Ownable.sol";
import "./IERC20.sol";
import "./Address.sol";
import "./uniswap_contracts.sol";
import "./IPinkAntiBot.sol";

contract YOURTOKEN is Context, IERC20, Ownable {
    IPinkAntiBot public pinkAntiBot;
    bool antiBotEnabled = false;
    using Address for address;
    // Data to customize
    string private constant _name = "YOURTOKEN";
    string private constant _symbol = "YOURTOKEN";
    uint256 private totalToken = 10_000_000;

    // dev fee converted in BNB, can be sent to 2 wallets (example marketing & dev)
    uint256 public _devBNBFeeBuy = 2;
    uint256 public _devBNBFeeSell = _devBNBFeeBuy;
    address payable devWalletOne =
        payable(0x2445b2Fcf6c6e62dCeDe72d2b0B993d536982FaB);
    address payable devWalletTwo =
        payable(0x1028c4D48Bd1f895eFc4F32200B84ae4CA2517A1);

    // dev fee to recover token, optionnal, set to 0 (example charity wallet)
    uint256 public _optionalDevFeeBuy = 2;
    uint256 public _optionalDevFeeSell = _optionalDevFeeBuy;
    address payable devWalletOptional =
        payable(0x2f8e677A4Bd1C6b15Bf2EF7A044592B30BeD3454);

    // redistribution tax fee
    uint256 public _taxFeeBuy = 2;
    uint256 public _taxFeeSell = _taxFeeBuy;

    // automatic liquidity fee, optional, set to 0
    uint256 public _liquidityFeeBuy = 2;
    uint256 public _liquidityFeeSell = _liquidityFeeBuy;

    // END_ Data to customize
    uint256 private _tTotal = totalToken * _DECIMALFACTOR;

    // swap when you accumulate 0.01% of tokens
    // It means it swaps when trading volume reaches 0.2% of total token
    uint256 private numTokensSellToAddToLiquidity = _tTotal / 10000;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromTransfer;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint8 private constant _DECIMALS = 8;
    uint256 private constant _DECIMALFACTOR = 10**uint256(_DECIMALS);
    uint256 private constant MAX = ~uint256(0);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 private _tFeeTotal;

    uint256 private _previousTaxFeeBuy = _taxFeeBuy;
    uint256 private _previousTaxFeeSell = _taxFeeSell;

    uint256 private _previousDevFeeBuy = _optionalDevFeeBuy;
    uint256 private _previousDevFeeSell = _optionalDevFeeSell;

    uint256 private _previousLiquidityFeeBuy = _liquidityFeeBuy;
    uint256 private _previousLiquidityFeeSell = _liquidityFeeSell;

    uint256 private _previousdevBNBFeeBuy = _devBNBFeeBuy;
    uint256 private _previousdevBNBFeeSell = _devBNBFeeSell;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    event AddLiquidityETH(uint256 amountA, uint256 amountB);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _rOwned[_msgSender()] = _rTotal;
        // BSC's mainnet antibot.
        // See guide here https://github.com/pinkmoonfinance/pink-antibot-guide
        address pinkAntiBot_ = 0xbb06F5C7689eA93d9DeACCf4aF8546C4Fe0Bf1E5;
        pinkAntiBot = IPinkAntiBot(pinkAntiBot_);
        pinkAntiBot.setTokenOwner(msg.sender);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        ); // v2 mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // Create a pancakeswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _DECIMALS;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
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

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        require(
            _allowances[sender][_msgSender()] >= amount,
            "BEP20: transfer amount exceeds allowance"
        );
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
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
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        require(
            _allowances[_msgSender()][spender] >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        Values memory values = _getValues(tAmount, true);
        if (!deductTransferFee) {
            return values.rAmount;
        } else {
            return values.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        /* Changed error message to "Account not excluded"
         See "SSL-01 | Incorrect error message" from the Certik
         audit of safemoon.
      */
        require(_isExcluded[account], "Account not excluded");
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

    function excludeFromTransfer(address account) public onlyOwner {
        _isExcludedFromTransfer[account] = true;
    }

    function includeInTransfer(address account) public onlyOwner {
        _isExcludedFromTransfer[account] = false;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeeBuyPercent(uint256 taxFee) external onlyOwner {
        _taxFeeBuy = taxFee;
    }

    function setTaxFeeSellPercent(uint256 taxFee) external onlyOwner {
        _taxFeeSell = taxFee;
    }

    function setOptionalDevFeeBuyPercent(uint256 charityFee)
        external
        onlyOwner
    {
        _optionalDevFeeBuy = charityFee;
    }

    function setOptionalDevFeeSellPercent(uint256 charityFee)
        external
        onlyOwner
    {
        _optionalDevFeeSell = charityFee;
    }

    function setdevBNBFeeBuyPercent(uint256 devBNBFee) external onlyOwner {
        _devBNBFeeBuy = devBNBFee;
    }

    function setdevBNBFeeSellPercent(uint256 devBNBFee) external onlyOwner {
        _devBNBFeeSell = devBNBFee;
    }

    function setLiquidityFeeBuyPercent(uint256 liquidityFee)
        external
        onlyOwner
    {
        _liquidityFeeBuy = liquidityFee;
    }

    function setLiquidityFeeSellPercent(uint256 liquidityFee)
        external
        onlyOwner
    {
        _liquidityFeeSell = liquidityFee;
    }

    //to recieve BNB from pancakeswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    struct Values {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tDev;
        uint256 tDevBNB;
    }
    struct TValues {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tDevBNB;
        uint256 tLiquidity;
        uint256 tDev;
    }

    function _getValues(uint256 tAmount, bool isBuy)
        private
        view
        returns (Values memory)
    {
        TValues memory tValues = _getTValues(tAmount, isBuy);
        Values memory values;
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tValues.tFee,
            tValues.tLiquidity,
            tValues.tDev,
            tValues.tDevBNB,
            _getRate()
        );
        values.rAmount = rAmount;
        values.rTransferAmount = rTransferAmount;
        values.rFee = rFee;
        values.tTransferAmount = tValues.tTransferAmount;
        values.tFee = tValues.tFee;
        values.tLiquidity = tValues.tLiquidity;
        values.tDev = tValues.tDev;
        values.tDevBNB = tValues.tDevBNB;
        return values;
    }

    function _getTValues(uint256 tAmount, bool isBuy)
        private
        view
        returns (TValues memory)
    {
        TValues memory tValues;
        tValues.tFee = calculateTaxFee(tAmount, isBuy);
        tValues.tDev = calculateDevFee(tAmount, isBuy);
        tValues.tDevBNB = calculatedevBNBFee(tAmount, isBuy);
        tValues.tLiquidity = calculateLiquidityFee(tAmount, isBuy);
        tValues.tTransferAmount =
            tAmount -
            tValues.tFee -
            tValues.tLiquidity -
            tValues.tDev;
        return tValues;
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 tDev,
        uint256 tDevBNB,
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
        uint256 rAmount = tAmount * currentRate;
        uint256 rDevBNB = tDevBNB * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rDev = tDev * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rLiquidity - rDev - rDevBNB;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeDevForBNB(uint256 tDevBNB) private {
        uint256 currentRate = _getRate();
        uint256 rDevBNB = tDevBNB * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rDevBNB;
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tDevBNB;
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
    }

    function _takeDev(uint256 tDev) private {
        uint256 currentRate = _getRate();
        uint256 rDev = tDev * currentRate;
        _rOwned[devWalletOptional] = _rOwned[devWalletOptional] + rDev;
        if (_isExcluded[devWalletOptional])
            _tOwned[devWalletOptional] = _tOwned[devWalletOptional] + tDev;
    }

    function calculateTaxFee(uint256 _amount, bool isBuy)
        private
        view
        returns (uint256)
    {
        uint256 _taxFee = _taxFeeBuy;
        if (!isBuy) {
            _taxFee = _taxFeeSell;
        }
        return (_amount * _taxFee) / 10**2;
    }

    function calculateDevFee(uint256 _amount, bool isBuy)
        private
        view
        returns (uint256)
    {
        uint256 _optionalDevFee = _optionalDevFeeBuy;
        if (!isBuy) {
            _optionalDevFee = _optionalDevFeeSell;
        }
        return (_amount * _optionalDevFeeBuy) / 10**2;
    }

    function calculatedevBNBFee(uint256 _amount, bool isBuy)
        private
        view
        returns (uint256)
    {
        uint256 _devBNBFee = _devBNBFeeBuy;
        if (!isBuy) {
            _devBNBFee = _devBNBFeeSell;
        }
        return (_amount * _devBNBFeeBuy) / 10**2;
    }

    function calculateLiquidityFee(uint256 _amount, bool isBuy)
        private
        view
        returns (uint256)
    {
        uint256 _liquidityFee = _liquidityFeeBuy;
        if (!isBuy) {
            _liquidityFee = _liquidityFeeSell;
        }
        return (_amount * _liquidityFeeBuy) / 10**2;
    }

    function removeFees() external onlyOwner {
        removeAllFee();
    }

    function restoreFees() external onlyOwner {
        restoreAllFee();
    }

    function removeAllFee() private {
        if (
            _taxFeeBuy == 0 &&
            _liquidityFeeBuy == 0 &&
            _optionalDevFeeBuy == 0 &&
            _devBNBFeeBuy == 0 &&
            _taxFeeSell == 0 &&
            _liquidityFeeSell == 0 &&
            _optionalDevFeeSell == 0 &&
            _devBNBFeeSell == 0
        ) return;

        _previousTaxFeeBuy = _taxFeeBuy;
        _previousLiquidityFeeBuy = _liquidityFeeBuy;
        _previousDevFeeBuy = _optionalDevFeeBuy;
        _previousdevBNBFeeBuy = _devBNBFeeBuy;

        _previousTaxFeeSell = _taxFeeSell;
        _previousLiquidityFeeSell = _liquidityFeeSell;
        _previousDevFeeSell = _optionalDevFeeSell;
        _previousdevBNBFeeSell = _devBNBFeeSell;

        _taxFeeBuy = 0;
        _liquidityFeeBuy = 0;
        _optionalDevFeeBuy = 0;
        _devBNBFeeBuy = 0;
        _taxFeeSell = 0;
        _liquidityFeeSell = 0;
        _optionalDevFeeSell = 0;
        _devBNBFeeSell = 0;
    }

    function restoreAllFee() private {
        _taxFeeBuy = _previousTaxFeeBuy;
        _liquidityFeeBuy = _previousLiquidityFeeBuy;
        _optionalDevFeeBuy = _previousDevFeeBuy;
        _devBNBFeeBuy = _previousdevBNBFeeBuy;
        _taxFeeSell = _previousTaxFeeSell;
        _liquidityFeeSell = _previousLiquidityFeeSell;
        _optionalDevFeeSell = _previousDevFeeSell;
        _devBNBFeeSell = _previousdevBNBFeeSell;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            !_isExcludedFromTransfer[from],
            "This adress can't send Tokens"
        ); // excluded adress can't sell
        require(
            !_isExcludedFromTransfer[to],
            "This adress can't receive Tokens"
        ); // excluded adress can't buy
        if (antiBotEnabled) {
            pinkAntiBot.onPreTransferCheck(from, to, amount);
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancakeswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (overMinTokenBalance && !inSwapAndLiquify && from != uniswapV2Pair) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquifyAndSendBNBToDevs(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        // indicates if it's a sell or a buy
        bool isBuy = (from == address(uniswapV2Pair));
        bool isSell = (to == address(uniswapV2Pair));

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        // if it's neither a buy nor a sell, no fee
        if (!isBuy && !isSell) {
            takeFee = false;
        }

        //transfer amount, it will take tax, dev, liquidity fee
        _tokenTransfer(from, to, amount, takeFee, isBuy);
    }

    function swapAndLiquifyAndSendBNBToDevs(uint256 contractTokenBalance)
        private
        lockTheSwap
    {
        // split the contract balance into 3 parts, based on the fees
        // numToken * _devBNBFeeBuy / (_devBNBFeeBuy +_liquidityFeeBuy ) for dev
        // numToken * _liquidityFeeBuy / (_devBNBFeeBuy +_liquidityFeeBuy ) for liquidity
        // use a magnitude to avoid integer division problem
        uint256 magnitude = 1000;
        uint256 partForLiquidity = (contractTokenBalance *
            magnitude *
            _devBNBFeeBuy) /
            (_devBNBFeeBuy + _liquidityFeeBuy) /
            magnitude;
        uint256 partForDev = contractTokenBalance - partForLiquidity;

        // Swap tokens, and send them to devs
        uint256 originalBalance = address(this).balance;
        swapTokensForETH(partForDev);
        uint256 swappedBNB = address(this).balance - originalBalance;
        uint256 halfBnB = swappedBNB / 2;
        (bool success1, ) = devWalletOne.call{value: halfBnB}("");
        (bool success2, ) = devWalletTwo.call{value: swappedBNB - halfBnB}("");

        require(success1 && success2, "Swap and liquify failed");
        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;
        uint256 partForLiquidityToSwap = partForLiquidity / 2;
        uint256 partForLiquidityToAdd = partForLiquidity -
            partForLiquidityToSwap;
        // swap tokens for BNB
        swapTokensForETH(partForLiquidityToSwap);
        // how much BNB did we just swap into?
        uint256 BnbSwapped = address(this).balance - initialBalance;
        // add liquidity to pancakeswap
        addLiquidity(partForLiquidityToAdd, BnbSwapped);
        emit SwapAndLiquify(
            partForLiquidityToSwap,
            BnbSwapped,
            partForLiquidityToAdd
        );
    }

    function sendBnbLeftoverToDev() external onlyOwner {
        // see "SSL- 03 | Contract gains non-withdrawable BNB via the swapAndLiquifyfunction"
        // buy back with BNB leftover from SwapAndLiquify to increase price
        uint256 swappedBNB = address(this).balance;
        uint256 halfSwappedBNB = swappedBNB / 2;
        (bool success1, ) = devWalletTwo.call{value: halfSwappedBNB}("");
        (bool success2, ) = devWalletTwo.call{
            value: swappedBNB - halfSwappedBNB
        }("");
        require(success1 && success2, "Swap and liquify failed");
    }

    function buyWithLeftoverBNB(uint256 amount) external onlyOwner {
        // see "SSL- 03 | Contract gains non-withdrawable BNB via the swapAndLiquifyfunction"
        // buy back with BNB leftover from SwapAndLiquify to increase price
        // from Safemoon Certik Audit
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        _approve(address(this), address(uniswapV2Router), amount);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens(
            amount,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        // generate the pancakeswap pair path of token -> WBNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        /* "to" account changed to address(this) to mitigate major centralization
         issue in Safemoon's contract.
         See "SSL-04 | Centralized risk in addLiquidity" from the Certik
         audit of Safemoon.
      */
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
        emit AddLiquidityETH(tokenAmount, ethAmount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee,
        bool isBuy
    ) private {
        /* Removed:
         ".....else  if  (!_isExcluded[sender]  &&  !_isExcluded[recipient])  {{        
                         _transferStandard(sender, recipient, amount);  }....."
                         
        See "SSL-02 | Redundant code" from the Certik audit of Safemoon
      */
        if (!takeFee) removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, isBuy);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, isBuy);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, isBuy);
        } else {
            _transferStandard(sender, recipient, amount, isBuy);
        }

        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount,
        bool isBuy
    ) private {
        Values memory values = _getValues(tAmount, isBuy);
        _rOwned[sender] = _rOwned[sender] - values.rAmount;
        _rOwned[recipient] = _rOwned[recipient] + values.rTransferAmount;
        _takeDevForBNB(values.tDevBNB);
        _takeLiquidity(values.tLiquidity);
        _takeDev(values.tDev);
        _reflectFee(values.rFee, values.tFee);
        emit Transfer(sender, recipient, values.tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool isBuy
    ) private {
        Values memory values = _getValues(tAmount, isBuy);
        _rOwned[sender] = _rOwned[sender] - values.rAmount;
        _tOwned[recipient] = _tOwned[recipient] + values.tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + values.rTransferAmount;
        _takeDevForBNB(values.tDevBNB);
        _takeLiquidity(values.tLiquidity);
        _takeDev(values.tDev);
        _reflectFee(values.rFee, values.tFee);
        emit Transfer(sender, recipient, values.tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool isBuy
    ) private {
        Values memory values = _getValues(tAmount, isBuy);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - values.rAmount;
        _rOwned[recipient] = _rOwned[recipient] + values.rTransferAmount;
        _takeDevForBNB(values.tDevBNB);
        _takeLiquidity(values.tLiquidity);
        _takeDev(values.tDev);
        _reflectFee(values.rFee, values.tFee);
        emit Transfer(sender, recipient, values.tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        bool isBuy
    ) private {
        Values memory values = _getValues(tAmount, isBuy);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - values.rAmount;
        _tOwned[recipient] = _tOwned[recipient] + values.tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + values.rTransferAmount;
        _takeDevForBNB(values.tDevBNB);
        _takeLiquidity(values.tLiquidity);
        _takeDev(values.tDev);
        _reflectFee(values.rFee, values.tFee);
        emit Transfer(sender, recipient, values.tTransferAmount);
    }

    //New Pancakeswap router version?
    //No problem, just change it!
    function setRouterAddress(address newRouter) external onlyOwner {
        IUniswapV2Router02 _uniswapV2newRouter = IUniswapV2Router02(newRouter);
        // Create a pancakeswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2newRouter.factory())
            .createPair(address(this), _uniswapV2newRouter.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2newRouter;
    }

    function setDevOneWallet(address payable newWallet) external onlyOwner {
        devWalletOne = newWallet;
    }

    function getDevOneWalletAddress() external view returns (address) {
        return devWalletOne;
    }

    function setDevTwoWallet(address payable newWallet) external onlyOwner {
        devWalletTwo = newWallet;
    }

    function getDevTwoWalletAddress() external view returns (address) {
        return devWalletTwo;
    }

    function getOptionnalDevWalletAddress() external view returns (address) {
        return devWalletOptional;
    }

    function setOptionalDevWallet(address payable newWallet)
        external
        onlyOwner
    {
        devWalletOptional = newWallet;
    }

    function setNumTokensToTriggerDevAndLiquidity(uint256 newvalue)
        external
        onlyOwner
    {
        numTokensSellToAddToLiquidity = newvalue;
    }

    function disableAntibot() external onlyOwner {
        antiBotEnabled = false;
    }

    function enableAntibot() external onlyOwner {
        antiBotEnabled = true;
    }
}