/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

//
// ██████  ███████ ████████  ██████  ██████  ██    ██ ███████ ██████  ███████ ███████
// ██   ██ ██         ██    ██      ██    ██ ██    ██ ██      ██   ██ ██      ██
// ██████  █████      ██    ██      ██    ██ ██    ██ █████   ██████  ███████ █████
// ██   ██ ██         ██    ██      ██    ██  ██  ██  ██      ██   ██      ██ ██
// ██████  ███████    ██     ██████  ██████    ████   ███████ ██   ██ ███████ ███████

pragma solidity ^0.8.6;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier:MIT

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address payable private _owner;
    address payable private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        _owner = payable(address(0));
    }

    function transferOwnership(address payable newOwner)
        public
        virtual
        onlyOwner
    {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// Main Bep20 BetCoVerse Token

contract BetCoVerse is Context, IBEP20, Ownable {
    mapping(address => uint256) private blanaces;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isSniper;

    uint256 private _tTotal = 20 * 1e9 ether; // 20 billion total supply
    uint256 maxTxAmount = 1 * 1e8 ether; // 100 million

    string private _name = "BetCoVerse"; // token name
    string private _symbol = "BETC"; // token ticker
    uint8 private _decimals = 18; // token decimals

    IPancakeRouter02 public pancakeRouter;
    address public pancakePair;

    address payable public marketWallet =
        payable(0xe3d85EC0be9384472681Fba54CF25d08e3A96408);
    address payable public stakingWallet =
        payable(0xcC227F25FC77C7B8A56D33Ce89f45539baDB620b);
    address payable public loyaltyWallet =
        payable(0x795A4BA7572a7A8383314C2380d834d390fb0C12);
    address payable public devWallet =
        payable(0xF69fE777100ad4B8D873153F1ac4773c4b33618b);

    address public burnAddress = 0x4e8365EBd0ed71e38c2Bdf0bC88823EffA324a47;

    uint256 minTokenNumberToSell = 10000 ether; // 10000 max tx amount will trigger swap and add liquidity
    uint256 public maxFee = 250; // 25% max fees limit per transaction
    bool public swapAndLiquifyEnabled = false; // should be true to turn on to liquidate the pool
    bool inSwapAndLiquify = false;
    bool public tradingOpen;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;
    uint256 antiSnipingTime = 60 seconds;

    // buy tax fee
    uint256 public liquidityFeeOnBuying = 20; // 2% will be added to the liquidity pool
    uint256 public marketingFeeOnBuying = 20; // 2% will go to the marketingwallet address
    uint256 public stakingFeeOnBuying = 20; // 2% will go to the stakinggwallet address
    uint256 public loyaltyFeeOnBuying = 10; // 1% will go to the  loyalty wallet address
    uint256 public devFeeOnBuying = 10; // 1% will go to the  dev wallet address
    uint256 public autoburnFeeOnBuying = 0; // 0% will go to the earth autoburn wallet address

    // sell tax fee
    uint256 public liquidityFeeOnSelling = 20; // 2% will be added to the liquidity pool
    uint256 public marketingFeeOnSelling = 20; // 2% will go to the market address
    uint256 public autoburnFeeOnSelling = 40; // 4% will go to the earth autoburn wallet address
    uint256 public stakingFeeOnSelling = 20; // 2% will go to the stakinggwallet address
    uint256 public loyaltyFeeOnSelling = 10; // 1% will go to the  loyalty wallet address
    uint256 public devFeeOnSelling = 10; // 1% will go to the  dev wallet address

    // for smart contract use
    uint256 private _currentLiquidityFee;
    uint256 private _currentmarketingFee;
    uint256 private _currentautoburnFee;
    uint256 private _currentstakingFee;
    uint256 private _currentdevFee;
    uint256 private _currentloyaltyFee;

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

    constructor() {
        blanaces[owner()] = _tTotal;

        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        // Create a pancake pair for this new token
        pancakePair = IPancakeFactory(_pancakeRouter.factory()).createPair(
            address(this),
            _pancakeRouter.WETH()
        );

        // set the rest of the contract variables
        pancakeRouter = _pancakeRouter;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        isTxLimitExempt[owner()] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return blanaces[account];
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
            _allowances[sender][_msgSender()] - (amount)
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
            _allowances[_msgSender()][spender] + (addedValue)
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
            _allowances[_msgSender()][spender] - (subtractedValue)
        );
        return true;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMinTokenNumberToSell(uint256 _amount) public onlyOwner {
        minTokenNumberToSell = _amount;
    }

    function setSwapAndLiquifyEnabled(bool _state) public onlyOwner {
        swapAndLiquifyEnabled = _state;
        emit SwapAndLiquifyEnabledUpdated(_state);
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public onlyOwner {
        require(launchedAt == 0, "Already launched boi");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
        tradingOpen = true;
        inSwapAndLiquify = true;
    }

    function setTxLimit(uint256 amount) external onlyOwner {
        require(
            amount > 10000 ether,
            "transaction amiunt should be less than 10k"
        );
        maxTxAmount = amount;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isTxLimitExempt[holder] = exempt;
    }

    function addSniperInList(address _account) external onlyOwner {
        require(
            _account != address(pancakeRouter),
            "We can not blacklist router"
        );
        require(!isSniper[_account], "Sniper already exist");
        isSniper[_account] = true;
    }

    function removeSniperFromList(address _account) external onlyOwner {
        require(isSniper[_account], "Not a sniper");
        isSniper[_account] = false;
    }

    function setMarketWallet(address payable _marketWallet) external onlyOwner {
        require(
            _marketWallet != address(0),
            "Market wallet cannot be address zero"
        );
        marketWallet = _marketWallet;
    }

    function setStakingWallet(address payable _sWallet) external onlyOwner {
        require(
            stakingWallet != address(0),
            "staking wallet cannot be address zero"
        );
        stakingWallet = _sWallet;
    }

    function setLoyaltyWallet(address payable _loyaltyWallet)
        external
        onlyOwner
    {
        require(
            loyaltyWallet != address(0),
            "Market wallet cannot be address zero"
        );
        loyaltyWallet = _loyaltyWallet;
    }

    function setDevWallet(address payable _devWallet) external onlyOwner {
        require(devWallet != address(0), "dev wallet cannot be address zero");
        devWallet = _devWallet;
    }

    function setBuyBackWallet(address payable _buyBack) external onlyOwner {
        burnAddress = _buyBack;
    }

    function setRoute(IPancakeRouter02 _router, address _pair)
        external
        onlyOwner
    {
        require(
            address(_router) != address(0),
            "Router adress cannot be address zero"
        );
        require(_pair != address(0), "Pair adress cannot be address zero");
        pancakeRouter = _router;
        pancakePair = _pair;
    }

    function withdrawBNB(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Invalid Amount");
        payable(msg.sender).transfer(_amount);
    }

    function withdrawToken(IBEP20 _token, uint256 _amount) external onlyOwner {
        require(_token.balanceOf(address(this)) >= _amount, "Invalid Amount");
        _token.transfer(msg.sender, _amount);
    }

    //to receive BNB from pancakeRouter when swapping
    receive() external payable {}

    function totalFeePerTx(uint256 tAmount) internal view returns (uint256) {
        uint256 percentage = (tAmount *
            ((_currentLiquidityFee) +
                (_currentstakingFee) +
                (_currentloyaltyFee) +
                (_currentdevFee) +
                (_currentmarketingFee) +
                (_currentautoburnFee))) / (1e3);
        return percentage;
    }

    function _takeLiquidityPoolFee(uint256 tAmount) internal {
        uint256 tPoolFee = (tAmount * (_currentLiquidityFee)) / (1e3);
        blanaces[address(this)] = blanaces[address(this)] + (tPoolFee);
        emit Transfer(_msgSender(), address(this), tPoolFee);
    }

    function _takeMarketFee(uint256 tAmount) internal {
        uint256 tMarketFee = (tAmount * (_currentmarketingFee)) / (1e3);
        blanaces[marketWallet] = blanaces[marketWallet] + (tMarketFee);
        emit Transfer(_msgSender(), marketWallet, tMarketFee);
    }

    function _takeStakingFee(uint256 tAmount) internal {
        uint256 tstakingFee = (tAmount * (_currentstakingFee)) / (1e3);
        blanaces[stakingWallet] = blanaces[stakingWallet] + (tstakingFee);
        emit Transfer(_msgSender(), stakingWallet, tstakingFee);
    }

    function _takeLoyaltyFee(uint256 tAmount) internal {
        uint256 tLoyaltyFee = (tAmount * (_currentloyaltyFee)) / (1e3);
        blanaces[loyaltyWallet] = blanaces[loyaltyWallet] + (tLoyaltyFee);
        emit Transfer(_msgSender(), loyaltyWallet, tLoyaltyFee);
    }

    function _takeDevFee(uint256 tAmount) internal {
        uint256 tDevFee = (tAmount * (_currentdevFee)) / (1e3);
        blanaces[devWallet] = blanaces[devWallet] + (tDevFee);
        emit Transfer(_msgSender(), devWallet, tDevFee);
    }

    function _takeBurnFee(uint256 tAmount) internal {
        uint256 burnFee = (tAmount * (_currentautoburnFee)) / (1e3);
        blanaces[burnAddress] = blanaces[burnAddress] + (burnFee);
        emit Transfer(_msgSender(), burnAddress, burnFee);
    }

    function removeAllFee() private {
        _currentLiquidityFee = 0;
        _currentmarketingFee = 0;
        _currentautoburnFee = 0;
        _currentloyaltyFee = 0;
        _currentstakingFee = 0;
        _currentdevFee = 0;
    }

    function setBuyFee() private {
        _currentLiquidityFee = liquidityFeeOnBuying;
        _currentmarketingFee = marketingFeeOnBuying;
        _currentdevFee = devFeeOnSelling;
        _currentautoburnFee = autoburnFeeOnBuying;
        _currentloyaltyFee = loyaltyFeeOnBuying;
        _currentstakingFee = stakingFeeOnBuying;
    }

    function setSellFee() private {
        _currentLiquidityFee = liquidityFeeOnSelling;
        _currentmarketingFee = marketingFeeOnSelling;
        _currentautoburnFee = autoburnFeeOnSelling;
        _currentdevFee = devFeeOnSelling;
        _currentloyaltyFee = loyaltyFeeOnSelling;
        _currentstakingFee = stakingFeeOnSelling;
    }

    //only owner can change BuyFeePercentages any time after deployment
    function setBuyFeePercent(
        uint256 _liquidityFee,
        uint256 _marketingFee,
        uint256 _loyaltyFee,
        uint256 _stakingFee,
        uint256 _devFee,
        uint256 _burnFee
    ) external onlyOwner {
        liquidityFeeOnBuying = _liquidityFee;
        marketingFeeOnBuying = _marketingFee;
        loyaltyFeeOnBuying = _loyaltyFee;
        stakingFeeOnBuying = _stakingFee;
        devFeeOnBuying = _devFee;
        autoburnFeeOnBuying = _burnFee;
        require(
            (liquidityFeeOnBuying) +
                (marketingFeeOnBuying) +
                (loyaltyFeeOnBuying) +
                (stakingFeeOnBuying) +
                (autoburnFeeOnBuying) +
                (devFeeOnBuying) <=
                maxFee,
            "BEP20: Can not be greater than max fee"
        );
    }

    //only owner can change SellFeePercentages any time after deployment
    function setSellFeePercent(
        uint256 _liquidityFee,
        uint256 _marketingFee,
        uint256 _autoburnFee,
        uint256 _loyaltyFee,
        uint256 _stakingFee,
        uint256 _devFee
    ) external onlyOwner {
        liquidityFeeOnSelling = _liquidityFee;
        marketingFeeOnSelling = _marketingFee;
        autoburnFeeOnSelling = _autoburnFee;
        loyaltyFeeOnSelling = _loyaltyFee;
        stakingFeeOnSelling = _stakingFee;
        devFeeOnSelling = _devFee;
        require(
            (liquidityFeeOnSelling) +
                (marketingFeeOnSelling) +
                (autoburnFeeOnSelling) +
                (loyaltyFeeOnSelling) +
                (stakingFeeOnSelling) +
                (devFeeOnSelling) <=
                maxFee,
            "BEP20: Can not be greater than max fee"
        );
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
        require(amount > 0, "BEP20: Transfer amount must be greater than zero");
        require(!isSniper[to], "Sniper detected");
        require(!isSniper[from], "Sniper detected");
        if (!isTxLimitExempt[from] && !isTxLimitExempt[to]) {
            // trading disable till launch
            if (!tradingOpen) {
                require(
                    from != pancakePair && to != pancakePair,
                    "Trading is not enabled yet"
                );
            }
            // antibot
            if (
                block.timestamp < launchedAtTimestamp + antiSnipingTime &&
                from != address(pancakeRouter)
            ) {
                if (from == pancakePair) {
                    isSniper[to] = true;
                } else if (to == pancakePair) {
                    isSniper[from] = true;
                }
            }

            require(amount <= maxTxAmount, "TX Limit Exceeded");
        }
        // swap and liquify
        swapAndLiquify(from, to);

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        if (!takeFee) {
            removeAllFee();
        }
        // buying handler
        else if (from == pancakePair) {
            setBuyFee();
        }
        // selling handler
        else if (to == pancakePair) {
            setSellFee();
        }
        // normal transaction handler
        else {
            removeAllFee();
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 tTransferAmount = tAmount - (totalFeePerTx(tAmount));
        blanaces[sender] -= (tAmount);
        blanaces[recipient] += (tTransferAmount);
        _takeLiquidityPoolFee(tAmount);
        _takeMarketFee(tAmount);
        _takeBurnFee(tAmount);
        _takeLoyaltyFee(tAmount);
        _takeDevFee(tAmount);
        _takeStakingFee(tAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function swapAndLiquify(address from, address to) private {
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancake pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        bool shouldSell = contractTokenBalance >= minTokenNumberToSell;

        if (
            !inSwapAndLiquify &&
            shouldSell &&
            from != pancakePair &&
            swapAndLiquifyEnabled &&
            !(from == address(this) && to == address(pancakePair)) // swap 1 time
        ) {
            // only sell for minTokenNumberToSell, decouple from _maxTxAmount
            // split the contract balance into 4 pieces

            contractTokenBalance = minTokenNumberToSell;
            // approve contract
            _approve(
                address(this),
                address(pancakeRouter),
                contractTokenBalance
            );

            // add liquidity
            // split the contract balance into 2 pieces

            uint256 otherPiece = contractTokenBalance / (2);
            uint256 tokenAmountToBeSwapped = contractTokenBalance -
                (otherPiece);

            uint256 initialBalance = address(this).balance;

            // now is to lock into staking pool
            Utils.swapTokensForEth(
                address(pancakeRouter),
                tokenAmountToBeSwapped
            );

            // how much BNB did we just swap into?

            // capture the contract's current BNB balance.
            // this is so that we can capture exactly the amount of BNB that the
            // swap creates, and not make the liquidity event include any BNB that
            // has been manually sent to the contract

            uint256 bnbToBeAddedToLiquidity = address(this).balance -
                (initialBalance);

            // add liquidity to pancake
            Utils.addLiquidity(
                address(pancakeRouter),
                owner(),
                otherPiece,
                bnbToBeAddedToLiquidity
            );

            emit SwapAndLiquify(
                tokenAmountToBeSwapped,
                bnbToBeAddedToLiquidity,
                otherPiece
            );
        }
    }
}

library Utils {
    function swapTokensForEth(address routerAddress, uint256 tokenAmount)
        internal
    {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp + 300
        );
    }

    function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) internal {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 300
        );
    }
}