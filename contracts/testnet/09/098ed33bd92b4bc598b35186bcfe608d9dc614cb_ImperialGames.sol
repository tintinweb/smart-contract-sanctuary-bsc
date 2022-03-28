// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router02.sol";

contract ImperialGames is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 10**11 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "Imperial Games";
    string private constant _symbol = "IMPG";
    uint8 private constant _decimals = 18;

    uint256 public _taxFee = 2;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _MarketingFee = 2;
    uint256 private _previousMarketingFee = _MarketingFee;

    uint256 public _DevelopmentFee = 4;
    uint256 private _previousDevelopmentFee = _DevelopmentFee;

    uint256 public _liquidityFee = 2;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _BurnFee = 2;
    uint256 private _previousBurnFee = _BurnFee;
    bool private takeFee;

    address public MarketingAdd = 0xaCc7fF6E312B4136b9354bE430a954D62B52AE0f; // Marketing Wallet
    address public DevelopmentAdd = 0xAD0AdAD0c4143c66697990000559a0D922907FD8; // Development Wallet
    address private Dead = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 public _maxTxAmount = 10**8 * 10**18; // 0.1%
    uint256 private numTokensSellToAddToLiquidity = 10**8 * 10**18;

    // for tracking exact fees amount
    uint256 private MarketingTokens; // Hold exact amount before Swap&Liquify
    uint256 private DevelopmentTokens; // Hold exact amount before Swap&Liquify

    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event feesUpdated(
        uint256 Liquidity,
        uint256 Development,
        uint256 Marketing,
        uint256 Burn,
        uint256 Tax
    );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _rOwned[owner()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        _setAutomatedMarketMakerPair(uniswapV2Pair, true);
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcluded[uniswapV2Pair] = true; // Excluded From Rewards
        _isExcluded[address(this)] = true; // Excluded From Rewards

        emit Transfer(address(0), owner(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
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
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
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
                "BEP20: decreased allowance below zero"
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

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , , ) = _getValues(tAmount);
            return rTransferAmount;
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
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMarketingAdd(address addr) external onlyOwner {
        MarketingAdd = addr;
    }

    function setDevelopmentAddress(address addr) external onlyOwner {
        DevelopmentAdd = addr;
    }

    /**
     * @dev Set All Fees
     */
    function setFees(
        uint256 liquidityFee,
        uint256 Development,
        uint256 Marketing,
        uint256 burnFee,
        uint256 taxFee
    ) external onlyOwner {
        uint256 Total = liquidityFee+Development+Marketing+burnFee+taxFee;
        require(Total <= 25 , "You're Not Allowed Go Above 25% in Fees");
        _liquidityFee = liquidityFee;
        _DevelopmentFee = Development;
        _MarketingFee = Marketing;
        _BurnFee = burnFee;
        _taxFee = taxFee;

        emit feesUpdated(liquidityFee, Development, Marketing, burnFee, taxFee);
    }

    /**
     * @dev Set The Router Address .
     * IMPORTANT: You Shouldn't Change This Router Address Unless Pancakeswap Upgraded to V3 Router or So ,
     * Do Some Research Before .
     */

    function setRouter(address router) public onlyOwner {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        _isExcluded[uniswapV2Pair] = true;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Brain: Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    /**
     * @dev You Should Set All Liquidity Pair Addresses To True , So The Fees Works on It .
     * Currently BNB/TKN Pair is Set To True ,  Where TKN = This Token Symbol .
     */

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "Brain: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(pair, value);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    /**
     * @dev Set The Amount To Start The Liquidation Process .
     * When This Amount Reached on The Contract , The Swap&Liquidity Starts
     */
    function num2Add2LP(uint256 num2Add2Liquidity) external onlyOwner {
        numTokensSellToAddToLiquidity = num2Add2Liquidity;
    }

    //to recieve ETH from uniswapV2Router when swaping

    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    struct tValues {
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tburn;
        uint256 tTransferAmount;
    }

    tValues private TV;

    struct rValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
    }

    rValues private RV;

    function _getValues(uint256 tAmount)
        private
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        _getTValues(tAmount);
        _getRValues(tAmount, _getRate());
        return (
            RV.rAmount,
            RV.rTransferAmount,
            RV.rFee,
            TV.tTransferAmount,
            TV.tFee,
            TV.tLiquidity,
            TV.tburn
        );
    }

    function _getTValues(uint256 tAmount) private {
        tValues memory m = tValues(
            calculateTaxFee(tAmount),
            calculateLiquidityFee(tAmount),
            calculateBurnFee(tAmount),
            0
        );
        m.tTransferAmount = tAmount.sub(m.tFee).sub(m.tLiquidity).sub(m.tburn);

        TV = m;
    }

    function _getRValues(uint256 tAmount, uint256 currentRate) private {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = TV.tFee.mul(currentRate);
        uint256 rLiquidity = TV.tLiquidity.mul(currentRate);
        uint256 rBurn = TV.tburn.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rBurn);
        rValues memory m = rValues(rAmount, rTransferAmount, rFee);
        RV = m;
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
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

    function _calBurn(uint256 burn) private {
        uint256 currentRate = _getRate();
        uint256 rBurn = burn.mul(currentRate);
        _rOwned[Dead] = _rOwned[Dead].add(rBurn);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_BurnFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return
            _amount
                .mul(_liquidityFee.add(_MarketingFee).add(_DevelopmentFee))
                .div(10**2);
    }

    /**
     * @dev Rescue The Locked BNB in The Contract .
     * The BNB Remains From The Liquidation Process And Stored in The Contract
     */
    function RescueBNB() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * @dev Rescue Wrong Sent Tokens .
     */

    function RescueTokens(address _tokenContract, uint256 _amount)
        public
        onlyOwner
    {
        IBEP20 tokenContract = IBEP20(_tokenContract);
        tokenContract.transfer(owner(), _amount);
    }

    function removeAllFee() private {
        if (
            _taxFee == 0 &&
            _MarketingFee == 0 &&
            _liquidityFee == 0 &&
            _DevelopmentFee == 0 &&
            _BurnFee == 0
        ) return;

        _previousTaxFee = _taxFee;
        _previousMarketingFee = _MarketingFee;
        _previousDevelopmentFee = _DevelopmentFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBurnFee = _BurnFee;

        _taxFee = 0;
        _MarketingFee = 0;
        _DevelopmentFee = 0;
        _liquidityFee = 0;
        _BurnFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _MarketingFee = _previousMarketingFee;
        _DevelopmentFee = _previousDevelopmentFee;
        _liquidityFee = _previousLiquidityFee;
        _BurnFee = _previousBurnFee;
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
        if (from != owner() && to != owner())
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            !automatedMarketMakerPairs[from] &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 Liq = contractTokenBalance.sub(MarketingTokens).sub(
            DevelopmentTokens
        );
        uint256 half = Liq.div(2);
        uint256 otherHalf = Liq.sub(half);
        if (MarketingTokens > 0) sendBNBTo(MarketingAdd, MarketingTokens);
        if (DevelopmentTokens > 0) sendBNBTo(DevelopmentAdd, DevelopmentTokens);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function sendBNBTo(address Wallet, uint256 amount) private {
        swapTokensForEth(amount);
        payable(Wallet).transfer(address(this).balance);
        if (Wallet != MarketingAdd) {
            DevelopmentTokens = 0;
        } else {
            MarketingTokens = 0;
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
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
        uint256 amount,
        bool takeFees
    ) private {
        if (!takeFees) removeAllFee();

        MarketingTokens += amount.mul(_MarketingFee).div(10**2);
        DevelopmentTokens += amount.mul(_DevelopmentFee).div(10**2);

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        if (!takeFees) restoreAllFee();
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
            uint256 tLiquidity,
            uint256 tburn
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _calBurn(tburn);
        _reflectFee(rFee, tFee);
        if (tburn > 0) emit Transfer(sender, Dead, tburn);
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
            uint256 tLiquidity,
            uint256 tburn
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _calBurn(tburn);
        _reflectFee(rFee, tFee);
        if (tburn > 0) emit Transfer(sender, Dead, tburn);
        emit Transfer(sender, recipient, tTransferAmount);
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
            uint256 tLiquidity,
            uint256 tburn
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _calBurn(tburn);
        _reflectFee(rFee, tFee);
        if (tburn > 0) emit Transfer(sender, Dead, tburn);
        emit Transfer(sender, recipient, tTransferAmount);
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
            uint256 tLiquidity,
            uint256 tburn
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _calBurn(tburn);
        _reflectFee(rFee, tFee);
        if (tburn > 0) emit Transfer(sender, Dead, tburn);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}