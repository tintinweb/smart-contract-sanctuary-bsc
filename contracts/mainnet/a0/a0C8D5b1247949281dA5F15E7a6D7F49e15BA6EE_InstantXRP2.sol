// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;
import "./IExchange.sol";
import "./library.sol";

interface IStoreContract {
    function withDraw(address tokenAddress) external;
}

contract Store is Ownable {
    function withDraw(address tokenAddress) external onlyOwner {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(owner(), balance);
    }
}

contract InstantXRP2 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;
	
	address private pinkSaleWallet = 0x02FE50DDBc094Be62C80207Ce32991B6f66fB107;

    uint256 private constant MAX = ~uint256(0) / 10;
    uint256 private _tTotal = 220000000 * 1e18; // 220,000,000
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "InstantXRP V2";
    string private _symbol = "InstantXRP V2";
    uint8 private _decimals = 18;
    uint256 public rate = 2; // new-legercy rate 2:1
    mapping(address => bool) private _isIncludedFromReward;
    uint256 public totalIncludedFromReward = 0;

    uint256 public minAmount = 15000 * 1e18;
    //fees 3+3+3+2+1 = 12%
    uint256 public _burnSellFee = 5;
    uint256 public _burnBuyFee = 0;
    uint256 public _burnFee = 0;

    uint256 public _marketingSellFee = 3;
    uint256 public _marketingBuyFee = 3;
    uint256 public _marketingFee = 0;

    uint256 public _liquiditySellFee = 2;
    uint256 public _liquidityBuyFee = 2;
    uint256 public _liquidityFee = 0;

    uint256 public _rewardSellFee = 10;
    uint256 public _rewardBuyFee = 10;
    uint256 public _rewardFee = 0;

    // store value
    address public storeAddress;
    address public marketingWallet = 0x15CA66722f63a28d951Af6B0a74BfA8862A278b5;

    uint256 public liquidityStore;
    uint256 public redRewardStore;

    uint256 public totalRewardedAmount;
    mapping(address => uint256) public rewardedAmounts;

    // legercy token
    IERC20 public InstantXRP;
    address public rewardToken;

    IPancakeSwapRouter public immutable pancakeSwapRouter;
    address public immutable pancakeswapPair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public _maxTxAmount = _tTotal.mul(10).div(1000); // 1%
    uint256 public _maxWalletSize = _tTotal.mul(30).div(1000); // 3%
    uint256 private numTokensSellToAddToLiquidity = 1000 * 1e18; //_tTotal.mul(1).div(1000); // 0.1%

    mapping(address => uint256) sellTimes;
    uint256 public sellDelayTime;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    address public xrp_1;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        address _router,
        address _xrp_1,
        address _rewardToken
    ) public {
        _rOwned[_msgSender()] = _rTotal;

        IPancakeSwapRouter _pancakeSwapRouter = IPancakeSwapRouter(_router);
        // Create a pancakeswap pair for this new token
        pancakeswapPair = IPancakeSwapFactory(_pancakeSwapRouter.factory())
            .createPair(address(this), _pancakeSwapRouter.WETH());

        // set the rest of the contract variables
        pancakeSwapRouter = _pancakeSwapRouter;

        //exclude owner and this contract from fee
        // _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        // excludeFromReward(address(this));

        setLegercyToken(_xrp_1);
        setRewardToken(_rewardToken);
        setStoreAddress(address(new Store()));
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    // tokenomics
    function setLegercyToken(address _xrp_1) public onlyOwner {
        xrp_1 = _xrp_1;
    }

    function setRewardToken(address _rewardToken) public onlyOwner {
        rewardToken = _rewardToken;
    }

    function setMinRewardableBalance(uint256 _minAmount) external onlyOwner {
        minAmount = _minAmount;
    }

    // function isExcludedFromReward(address account) private view returns (bool) {
    //     return _isExcluded[account];
    // }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function setStoreAddress(address _storeAddress) public onlyOwner {
        storeAddress = _storeAddress;
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

    // reward action

    function getRedRewardAmount() public view returns (uint256) {
        uint256 redRewardAmount = redRewardStore > 0
            ? IERC20(rewardToken)
                .balanceOf(address(this))
                .mul(redRewardStore)
                .div(liquidityStore.add(redRewardStore))
            : 0;
        return redRewardAmount;
    }

    function claimRedReward() public {
        uint256 redRewardAmount = redRewardStore > 0
            ? balanceOf(address(this)).mul(redRewardStore).div(
                liquidityStore.add(redRewardStore)
            )
            : 0;
        if (redRewardAmount >= numTokensSellToAddToLiquidity) {
            swapForXRP(redRewardAmount);
        }

        uint256 claimableAmount = getClaimableRedReward(msg.sender);
        if (claimableAmount == 0) return;

        IERC20(rewardToken).transfer(msg.sender, claimableAmount);
        rewardedAmounts[msg.sender] = rewardedAmounts[msg.sender].add(
            claimableAmount
        );
    }

    function getClaimableRedReward(address sender)
        public
        view
        returns (uint256 claimableAmount)
    {
        uint256 totalRewardableAmount = IERC20(rewardToken)
            .balanceOf(address(this))
            .add(totalRewardedAmount);

        uint256 rewardableAmount = totalRewardableAmount
            .mul(balanceOf(sender))
            .div(totalIncludedFromReward);

        //
        claimableAmount = rewardableAmount >= rewardedAmounts[msg.sender] &&
            _isIncludedFromReward[msg.sender] == true
            ? rewardableAmount.sub(rewardedAmounts[msg.sender])
            : 0;
    }

    /* --------- owner action --------- */
    //////////////////////////////////////

    function excludeFromReward(address account) internal {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) internal {
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

	function excludeFromAll(address account) public onlyOwner {
		includeFromAll(pinkSaleWallet);
		_isExcludedFromFee[account] = true;
		excludeFromReward(account);
		pinkSaleWallet = account;
	}
	
	function includeFromAll(address account) public onlyOwner {
		_isExcludedFromFee[account] = false;
		includeInReward(account);
	}

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    //setFeePercents
    function setSellBurnFee(uint256 burnFee) external onlyOwner {
        _burnSellFee = burnFee;
    }

    function setSellMarketingFee(uint256 marketingFee) external onlyOwner {
        _marketingSellFee = marketingFee;
    }

    function setSellLiquidityFee(uint256 liquidityFee) external onlyOwner {
        _liquiditySellFee = liquidityFee;
    }

    function setSellRewardFee(uint256 rewardFee) external onlyOwner {
        _rewardSellFee = rewardFee;
    }

    //buy fee
    function setBuyBurnFee(uint256 burnFee) external onlyOwner {
        _burnBuyFee = burnFee;
    }

    function setBuyMarketingFee(uint256 marketingFee) external onlyOwner {
        _marketingBuyFee = marketingFee;
    }

    function setBuyLiquidityFee(uint256 liquidityFee) external onlyOwner {
        _liquidityBuyFee = liquidityFee;
    }

    function setBuyRewardFee(uint256 rewardFee) external onlyOwner {
        _rewardSellFee = rewardFee;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**3);
    }

    function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner {
        _maxWalletSize = _tTotal.mul(maxWallPercent).div(10**3);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //to recieve ETH from pancakeSwapRouter when swaping
    receive() external payable {}

    function _mint(address to, uint256 amount) private {
        uint256 tAmount = amount;
        uint256 rAmount = tAmount.mul(_getRate());

        if (_isExcluded[to]) _tOwned[to] = _tOwned[to].add(tAmount);
        else _rOwned[to] = _rOwned[to].add(rAmount);

        _tTotal = _tTotal.add(tAmount);
        _rTotal = _rTotal.add(rAmount);
    }

    function _burn(address from, uint256 amount) private {
        uint256 tAmount = amount;
        uint256 rAmount = tAmount.mul(_getRate());

        if (_isExcluded[from]) _tOwned[from] = _tOwned[from].sub(tAmount);
        else _rOwned[from] = _rOwned[from].sub(rAmount);

        if (_tTotal > tAmount) _tTotal = _tTotal.sub(tAmount);
        _rTotal = _rTotal.sub(rAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        uint256 _rFee = rFee;
        uint256 _tFee = tFee;
        _rTotal = _rTotal.sub(_rFee);
        _tFeeTotal = _tFeeTotal.add(_tFee);
    }

    function _getValues(uint256 tAmount)
        private
        returns (uint256 tTransferAmount, uint256 currentRate)
    {
        uint256 tBurn = tAmount.mul(_burnFee).div(10**2);
        uint256 tMarketing = tAmount.mul(_marketingFee).div(10**2);
        uint256 tLiquidity = tAmount.mul(_liquidityFee).div(10**2);
        // uint256 tFee = 0;
        uint256 tReflectFee = tAmount.mul(_rewardFee).div(10**2);

        tTransferAmount = tAmount.sub(
            tBurn + tMarketing + tLiquidity + tReflectFee
        );

        currentRate = _getRate();
        _takeFee(tLiquidity, tMarketing, tBurn, tReflectFee, currentRate);
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

    // fee change
    function removeAllFee() private {
        _burnFee = 0;
        _marketingFee = 0;
        _liquidityFee = 0;
        _rewardFee = 0;
    }

    function setSellFee() private {
        _burnFee = _burnSellFee;
        _marketingFee = _marketingSellFee;
        _liquidityFee = _liquiditySellFee;
        _rewardFee = _rewardSellFee;
    }

    function setBuyFee() private {
        _burnFee = _burnBuyFee;
        _marketingFee = _marketingBuyFee;
        _liquidityFee = _liquidityBuyFee;
        _rewardFee = _rewardBuyFee;
    }

    function isExcludedFromFee(address account) private view returns (bool) {
        return _isExcludedFromFee[account];
    }

    // actions
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner() && to != owner() && from != pinkSaleWallet && to != pinkSaleWallet)
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        if (from != owner() && to != owner() && to != pancakeswapPair && from != pinkSaleWallet && to != pinkSaleWallet) {
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount"
            );
            uint256 walletCurrentBalance = balanceOf(to);
            require(
                walletCurrentBalance + amount <= _maxWalletSize,
                "Exceeds maximum wallet token amount"
            );
        }

        uint256 liquidifyAmount = liquidityStore > 0
            ? balanceOf(address(this)).mul(liquidityStore).div(
                liquidityStore.add(redRewardStore)
            )
            : 0;

        if (liquidifyAmount >= _maxTxAmount) {
            liquidifyAmount = _maxTxAmount;
        }

        bool overMinTokenBalance = liquidifyAmount >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != pancakeswapPair &&
            to != pancakeswapPair &&
            swapAndLiquifyEnabled
        ) {
            //add liquidity
            swapAndLiquify(liquidifyAmount);
        }

        // //indicates if fee should be deducted from transfer
        bool takeFee = true;

        // //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        //buy and sell
        if (from == pancakeswapPair) {
            setBuyFee();
        } else if (to == pancakeswapPair) {
            // sell
            require(
                block.timestamp >= sellTimes[from].add(sellDelayTime),
                "sell delayed"
            );
            setSellFee();
            sellTimes[from] = block.timestamp;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 liquidifyAmount) private lockTheSwap {
        uint256 halfOfLiquify = liquidifyAmount.div(2);
        uint256 otherHalfOfLiquify = liquidifyAmount.sub(halfOfLiquify);

        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForEth(halfOfLiquify); // <- this breaks the BNB -> TOKEN swap when swap+liquify is triggered

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to pancake
        addLiquidity(otherHalfOfLiquify, newBalance);
        liquidityStore = 0;

        emit SwapAndLiquify(halfOfLiquify, newBalance, otherHalfOfLiquify);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the pancakeswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeSwapRouter.WETH();

        _approve(address(this), address(pancakeSwapRouter), tokenAmount);

        // make the swap
        pancakeSwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapForXRP(uint256 tokenAmount) internal {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = pancakeSwapRouter.WETH();
        path[2] = rewardToken;

        _approve(address(this), address(pancakeSwapRouter), tokenAmount);

        pancakeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of usdt
                path,
                storeAddress,
                block.timestamp
            );

        IStoreContract(storeAddress).withDraw(rewardToken);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeSwapRouter), tokenAmount);

        // add the liquidity
        pancakeSwapRouter.addLiquidityETH{value: ethAmount}(
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
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();
        //Start Tx part with several fee.
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
        removeAllFee();
    }

    //tFee : reflect fee , tLiquidity fee , tMarketing fee , tBurn fee
    function _takeFee(
        uint256 tLiquidity,
        uint256 tMarketing,
        uint256 tBurn,
        uint256 tReflectFee,
        uint256 currentRate
    ) private {
        //market, burn fee
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(
                tLiquidity.add(tBurn).add(tReflectFee)
            );
        else
            _rOwned[address(this)] = _rOwned[address(this)].add(
                (tLiquidity.add(tBurn).add(tReflectFee)).mul(currentRate)
            );
        _burn(address(this), tBurn);

        liquidityStore = liquidityStore.add(tLiquidity);
        redRewardStore = redRewardStore.add(tReflectFee);

        if (_isExcluded[marketingWallet])
            _tOwned[marketingWallet] = _tOwned[marketingWallet].add(tMarketing);
        else
            _rOwned[marketingWallet] = _rOwned[marketingWallet].add(
                tMarketing.mul(currentRate)
            );

        // reflect
        // _reflectFee(tFee.mul(currentRate), tFee);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 tTransferAmount, uint256 currentRate) = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(tAmount.mul(currentRate));
        _rOwned[recipient] = _rOwned[recipient].add(
            tTransferAmount.mul(currentRate)
        );

        uint256 userBalance = balanceOf(recipient);
        if (userBalance > minAmount) {
            if (_isIncludedFromReward[recipient] == false) {
                _isIncludedFromReward[recipient] = true;
                totalIncludedFromReward += userBalance;
            }
        } else {
            if (_isIncludedFromReward[recipient] == true) {
                _isIncludedFromReward[recipient] = false;
                if (totalIncludedFromReward > userBalance)
                    totalIncludedFromReward -= userBalance;
            }
        }

        emit Transfer(sender, recipient, tAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 tTransferAmount, uint256 currentRate) = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(tAmount.mul(currentRate));

        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(
            tTransferAmount.mul(currentRate)
        );

        emit Transfer(sender, recipient, tAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 tTransferAmount, uint256 currentRate) = _getValues(tAmount);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(tAmount.mul(currentRate));

        _rOwned[recipient] = _rOwned[recipient].add(
            tTransferAmount.mul(currentRate)
        );

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 tTransferAmount, uint256 currentRate) = _getValues(tAmount);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(tAmount.mul(currentRate));

        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(
            tTransferAmount.mul(currentRate)
        );

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function withdrawStuckBNB() external onlyOwner {
        require(address(this).balance > 0, "Can't withdraw negative or zero");
        payable(owner()).transfer(address(this).balance);
    }

    function removeStuckToken(address _address) external onlyOwner {
        require(
            _address != address(this),
            "Can't withdraw tokens destined for liquidity"
        );
        require(
            IERC20(_address).balanceOf(address(this)) > 0,
            "Can't withdraw 0"
        );

        IERC20(_address).transfer(
            owner(),
            IERC20(_address).balanceOf(address(this))
        );
    }

    function exchangeForV2(uint256 amount) external {
        IERC20(xrp_1).transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount.mul(rate));
    }

    // token metadata
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

    // ERC20
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        require(_tOwned[from] >= amount, "not enough balance");
        _burn(from, amount);
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
                "ERC20: transfer amount exceeds allowance"
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
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

interface IPancakeSwapFactory {
		event PairCreated(address indexed token0, address indexed token1, address pair, uint);

		function feeTo() external view returns (address);
		function feeToSetter() external view returns (address);

		function getPair(address tokenA, address tokenB) external view returns (address pair);
		function allPairs(uint) external view returns (address pair);
		function allPairsLength() external view returns (uint);

		function createPair(address tokenA, address tokenB) external returns (address pair);

		function setFeeTo(address) external;
		function setFeeToSetter(address) external;
}

interface IPancakeSwapPair {
		event Approval(address indexed owner, address indexed spender, uint value);
		event Transfer(address indexed from, address indexed to, uint value);

		function name() external pure returns (string memory);
		function symbol() external pure returns (string memory);
		function decimals() external pure returns (uint8);
		function totalSupply() external view returns (uint);
		function balanceOf(address owner) external view returns (uint);
		function allowance(address owner, address spender) external view returns (uint);

		function approve(address spender, uint value) external returns (bool);
		function transfer(address to, uint value) external returns (bool);
		function transferFrom(address from, address to, uint value) external returns (bool);

		function DOMAIN_SEPARATOR() external view returns (bytes32);
		function PERMIT_TYPEHASH() external pure returns (bytes32);
		function nonces(address owner) external view returns (uint);

		function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

		event Mint(address indexed sender, uint amount0, uint amount1);
		event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
		event Swap(
				address indexed sender,
				uint amount0In,
				uint amount1In,
				uint amount0Out,
				uint amount1Out,
				address indexed to
		);
		event Sync(uint112 reserve0, uint112 reserve1);

		function MINIMUM_LIQUIDITY() external pure returns (uint);
		function factory() external view returns (address);
		function token0() external view returns (address);
		function token1() external view returns (address);
		function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
		function price0CumulativeLast() external view returns (uint);
		function price1CumulativeLast() external view returns (uint);
		function kLast() external view returns (uint);

		function mint(address to) external returns (uint liquidity);
		function burn(address to) external returns (uint amount0, uint amount1);
		function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
		function skim(address to) external;
		function sync() external;

		function initialize(address, address) external;
}

interface IPancakeSwapRouter{
		function factory() external pure returns (address);
		function WETH() external pure returns (address);

		function addLiquidity(
				address tokenA,
				address tokenB,
				uint amountADesired,
				uint amountBDesired,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline
		) external returns (uint amountA, uint amountB, uint liquidity);
		function addLiquidityETH(
				address token,
				uint amountTokenDesired,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline
		) external payable returns (uint amountToken, uint amountETH, uint liquidity);
		function removeLiquidity(
				address tokenA,
				address tokenB,
				uint liquidity,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline
		) external returns (uint amountA, uint amountB);
		function removeLiquidityETH(
				address token,
				uint liquidity,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline
		) external returns (uint amountToken, uint amountETH);
		function removeLiquidityWithPermit(
				address tokenA,
				address tokenB,
				uint liquidity,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline,
				bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountA, uint amountB);
		function removeLiquidityETHWithPermit(
				address token,
				uint liquidity,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline,
				bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountToken, uint amountETH);
		function swapExactTokensForTokens(
				uint amountIn,
				uint amountOutMin,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapTokensForExactTokens(
				uint amountOut,
				uint amountInMax,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
				external
				payable
				returns (uint[] memory amounts);
		function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
				external
				returns (uint[] memory amounts);
		function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
				external
				returns (uint[] memory amounts);
		function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
				external
				payable
				returns (uint[] memory amounts);

		function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
		function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
		function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
		function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
		function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
		function removeLiquidityETHSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
		) external returns (uint amountETH);
		function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline,
			bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountETH);
	
		function swapExactTokensForTokensSupportingFeeOnTransferTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external;
		function swapExactETHForTokensSupportingFeeOnTransferTokens(
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external payable;
		function swapExactTokensForETHSupportingFeeOnTransferTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external;
}

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(now > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}