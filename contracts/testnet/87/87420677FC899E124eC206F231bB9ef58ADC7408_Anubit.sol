// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./Headers.sol";

contract Anubit is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address payable;

    string private constant _name = "Buger";
    string private constant _symbol = "MOCO";

    uint8 private constant _decimals = 18;
    uint256 private _tTotal = 100_000_000 * 10**_decimals; // Were minting 100_000_000 million tokens
    uint256 private constant MAX = ~uint256(0);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    

    uint256 public _maxSupply = _tTotal; //were minting all our tokens
    uint256 public _circulatingSupply = 0; // for convienience

    // Timer Constants
    uint256 private constant DAY = 120; // How many seconds are in a day //TODO: ######################################################### CHAGE BACK TO 86400

    address[] private _excluded; // excluded from rfi
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isExcludedFromMaxWallet;
    mapping(address => bool) private _isExcludedFromAntiWhale;

    // Tax distribution addresses
    address payable private marketingAddress;
    address payable private developerAddress;
    address payable private ownersAddress;
    address payable private charityAddress;

    // where tokens go to die
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    //Auto reserve dump limiter
    uint256 private _autoReserveSwapTimer = DAY;
    bool public pauseautoSwapReserve = true;
    uint256 private _timeSinceLastSwap;
    uint256 public reserveSwapThreshold = 0;

    mapping(address => bool) private isAutomatedMarketMakerPair;

    bool public paused = true;

    // Anti-Whale Settings
    uint256 private _whaleSellThreshold = 0;
    uint256 private _whaleSellThresholdPercent = 400; // default .25%
    uint256 private _whaleSellTimer = DAY; // 24 hours
    mapping(address => uint256) private _amountSold;
    mapping(address => uint256) private _timeSinceFirstSell;
    bool public _isAntiWhaleEnabled = true;

    bool private inSwapAndLiquify; // keek track of swap state

    IUniswapV2Router02 public UniswapV2Router;
    address public uniswapPair;
    bool public swapAndLiquifyEnabled = true;

    uint256 public numTokensSellToAddToLiquidity = _tTotal / 3334;
    
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    struct 
    taxRatesStruct {
        uint8 rfi;
        uint8 marketing;
        uint8 charity;
        uint8 development;
        uint8 owners;
        uint8 lp;
        uint8 toSwap;
    }

    // setup buy rates
    taxRatesStruct public buyRates =
        taxRatesStruct({
            rfi: 1, // Reflection rate
            marketing: 1, //marketing
            charity: 2, // charity
            development: 3, // development
            owners: 2, // owners
            lp: 2, // LP
            toSwap: 9 // marketing + charity + development + owners
        });

    // setup sell rates
    taxRatesStruct public sellRates =
        taxRatesStruct({
            rfi: 2, // Reflection rate
            marketing: 2, //marketing
            charity: 4, // charity
            development: 6, // development
            owners: 4, // owners
            lp: 4, // LP
            toSwap: 18 // marketing + charity + development + owners
        });

    
    taxRatesStruct private appliedRates = buyRates;

    struct TotFeesPaidStruct {
        uint256 rfi;
        uint256 toSwap;
    }

    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rRfi;
        uint256 rToSwap;
        uint256 tTransferAmount;
        uint256 tRfi;
        uint256 tToSwap;
    }


    // Event Emitters
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 BNBReceived,
        uint256 tokensIntotoSwap
    );
    event LiquidityAdded(uint256 tokenAmount, uint256 BNBAmount);
    event TaxFeesAdded(uint256 developerFee, uint256 ownersFee, uint256 charityFee, uint256 marketingFee);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event AutoSwapReserve(uint256 swapReserveTokens, uint256 poolBalance);
    event AutoLP(string autoLp);
    event ManualLP();
    event MaxWalletAmountUpdated(uint256 amount);
    event ExcludeFromMaxWallet(address account, bool indexed isExcluded);






    //####################################### REMOvE BEFOR LAUNCH #######################################################################################
    event FailWhale(bool failWhale);
    event AutoSwapReserveTemp(
        uint256 swapReserveTokens,
        uint256 reserveSwapThreshold,
        uint256 delta,
        uint256 _timeSinceLastSwap
    );
    event DevLog(string message);
    event Log(string message, uint256 value);




    constructor() {
        IUniswapV2Router02 _UniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        uniswapPair = IUniswapV2Factory(_UniswapV2Router.factory()).createPair(
            address(this),
            _UniswapV2Router.WETH()
        );

        isAutomatedMarketMakerPair[uniswapPair] = true;

        emit SetAutomatedMarketMakerPair(uniswapPair, true);
        UniswapV2Router = _UniswapV2Router;

        _rOwned[owner()] = _rTotal;

        marketingAddress = payable(0xcA1D22Ab23d43D411f905395B9F4946965D6EDC4);
        developerAddress = payable(0xBd34475Ad72cc20f1b77894f22563c768F734995);
        ownersAddress = payable(0x8D6F3c51795a9f483F38584490Fc811Ed5c55414);
        charityAddress = payable(0xBF2341Ac5a5c8721e9B0F6b7A37e9C29513bDD58);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[ownersAddress] = true;
        _isExcludedFromFee[developerAddress] = true;
        _isExcludedFromFee[charityAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        _isExcludedFromMaxWallet[owner()] = true;
        _isExcludedFromMaxWallet[marketingAddress] = true;
        _isExcludedFromMaxWallet[developerAddress] = true;
        _isExcludedFromMaxWallet[ownersAddress] = true;
        _isExcludedFromMaxWallet[charityAddress] = true;
        _isExcludedFromMaxWallet[address(this)] = true;
        _isExcludedFromMaxWallet[uniswapPair] = true;

        _isExcludedFromAntiWhale[owner()] = true;
        _isExcludedFromAntiWhale[address(this)] = true;
        _isExcludedFromAntiWhale[address(UniswapV2Router)] = true;
        _isExcludedFromAntiWhale[uniswapPair] = true;
        _isExcludedFromAntiWhale[marketingAddress] = true;
        _isExcludedFromAntiWhale[ownersAddress] = true;
        _isExcludedFromAntiWhale[developerAddress] = true;
        _isExcludedFromAntiWhale[charityAddress] = true;

        //init auto swap timer
        _timeSinceLastSwap = block.timestamp;
 

        //we make sure owner isnt included in reflection (we play fair)
        _tOwned[owner()] = tokenFromReflection(_rOwned[owner()]);
        _isExcluded[owner()] = true;
        _excluded.push(owner());

        emit Transfer(address(0), owner(), _tTotal);
    }

    //std ERC20:
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override ERC20:
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rTransferAmount;
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


    function excludeFromReward(address account) external onlyOwner {
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

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromMaxWallet(address account)
        public
        view
        returns (bool)
    {
        return _isExcludedFromMaxWallet[account];
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    
    receive() external payable {}

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -= rRfi;
        totFeesPaid.rfi += tRfi;
    }

    function _takeToSwap(uint256 rToSwap, uint256 tToSwap) private {
        _rOwned[address(this)] += rToSwap;
        if (_isExcluded[address(this)]) _tOwned[address(this)] += tToSwap;
        totFeesPaid.toSwap += tToSwap;
    }

    function _getValues(uint256 tAmount, bool takeFee)
        private
        view
        returns (valuesFromGetValues memory to_return)
    {
        to_return = _getTValues(tAmount, takeFee);
        (
            to_return.rAmount,
            to_return.rTransferAmount,
            to_return.rRfi,
            to_return.rToSwap
        ) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee)
        private
        view
        returns (valuesFromGetValues memory s)
    {
        if (!takeFee) {
            s.tTransferAmount = tAmount;
            return s;
        }
        s.tRfi = (tAmount * appliedRates.rfi) / 1000;
        s.tToSwap = (tAmount * appliedRates.toSwap) / 1000;
        s.tTransferAmount = tAmount - s.tRfi - s.tToSwap;
        return s;
    }

    function _getRValues(
        valuesFromGetValues memory s,
        uint256 tAmount,
        bool takeFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rRfi,
            uint256 rToSwap
        )
    {
        rAmount = tAmount * currentRate;

        if (!takeFee) {
            return (rAmount, rAmount, 0, 0);
        }

        rRfi = s.tRfi * currentRate;
        rToSwap = s.tToSwap * currentRate;
        rTransferAmount = rAmount - rRfi - rToSwap;
        return (rAmount, rTransferAmount, rRfi, rToSwap);
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
            rSupply -= _rOwned[_excluded[i]];
            tSupply -= _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

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
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(from), "You have a low balance");

        //Pausing for launch
        if (paused) {
            if (
                (!inSwapAndLiquify &&
                    !isAutomatedMarketMakerPair[from] &&
                    (from != owner())) || (to != owner())
            ) {
                require(!paused, "Trading Paused");
            }
        }

        // We will assume that this is not a whale
        bool failWhale = false;

        bool takeFee = !(_isExcludedFromFee[from] || _isExcludedFromFee[to]);

        emit DevLog("TAKEF?");

        if (takeFee) {
            emit DevLog("TAKEFee");

            if (isAutomatedMarketMakerPair[from]) {
                emit DevLog("TAKEBUY");
                appliedRates = buyRates; // set buy rates
            } else {
                appliedRates = sellRates;
                emit DevLog("TAKESELL");

                /*
                 fishing for whales
                */
                if (_isAntiWhaleEnabled && !_isExcludedFromAntiWhale[to]) {
                    if (
                        from == uniswapPair || from == address(UniswapV2Router)
                    ) {
                        // Get the time difference in seconds between now and the first sell
                        uint256 delta = block.timestamp.sub(
                            _timeSinceFirstSell[from]
                        );

                        // Get the new total to see if it has spilled over the threshold
                        uint256 newTotal = _amountSold[from].add(amount);

                        uint256 poolBalance = balanceOf(owner());

                        _circulatingSupply = _tTotal.sub(poolBalance);

                        _whaleSellThreshold = _circulatingSupply.div(
                            _whaleSellThresholdPercent
                        );

                        if (
                            delta > 0 &&
                            delta < _whaleSellTimer &&
                            _timeSinceFirstSell[from] != 0
                        ) {
                            if (newTotal > _whaleSellThreshold) {
                                failWhale = true;
                            }
                            _amountSold[from] = newTotal;
                        } else if (
                            _timeSinceFirstSell[from] == 0 &&
                            newTotal > _whaleSellThreshold
                        ) {
                            failWhale = true;
                            _amountSold[from] = newTotal;
                        } else {
                            // Otherwise we reset their sold amount and timer
                            _timeSinceFirstSell[from] = block.timestamp;
                            _amountSold[from] = amount;
                        }
                    }
                }
            }

            if (
                balanceOf(address(this)) >= numTokensSellToAddToLiquidity &&
                !inSwapAndLiquify &&
                !isAutomatedMarketMakerPair[from] &&
                swapAndLiquifyEnabled
            ) {
                //add liquidity
                emit DevLog("SWALQ");
                swapAndLiquify(numTokensSellToAddToLiquidity);
            }

            if (pauseautoSwapReserve) {
                emit DevLog("ASR");
                autoSwapReserve();
            }
        }

        if (failWhale) {
            emit DevLog("WHALE HERE");
            //require(failWhale == false, "Whale Dump Time Throttle .25% Per Day");
        }

        // Transfer the token amount from sender to receipient.
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        valuesFromGetValues memory s = _getValues(tAmount, takeFee);

        if (_isExcluded[sender]) {
            _tOwned[sender] -= tAmount;
        }
        if (_isExcluded[recipient]) {
            _tOwned[recipient] += s.tTransferAmount;
        }

        _rOwned[sender] -= s.rAmount;
        _rOwned[recipient] += s.rTransferAmount;
        if (takeFee) {
            _reflectRfi(s.rRfi, s.tRfi);
            _takeToSwap(s.rToSwap, s.tToSwap);
            emit Transfer(sender, address(this), s.tToSwap);
        }

        emit Transfer(sender, recipient, s.tTransferAmount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 denominator = appliedRates.toSwap * 2;
        uint256 tokensToAddLiquidityWith = (contractTokenBalance * appliedRates.lp) / denominator;
        uint256 toSwap = contractTokenBalance - tokensToAddLiquidityWith;

        uint256 initialBalance = address(this).balance;

        swapTokensForBNB(toSwap);// swap tokens for BNB

        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 BNBToAddLiquidityWith = (deltaBalance * appliedRates.lp) / (denominator - appliedRates.lp);

        // add liquidity
        addLiquidity(tokensToAddLiquidityWith, BNBToAddLiquidityWith);

        // Distribute remaining tax to other wallets
        uint256 remainingBalance = address(this).balance;

        uint256 developerFee = (remainingBalance * appliedRates.development) / (denominator - appliedRates.development);
        uint256 ownersFee = (remainingBalance * appliedRates.owners) / (denominator - appliedRates.owners);
        uint256 marketingFee = (remainingBalance * appliedRates.marketing) / (denominator - appliedRates.marketing);
        uint256 charityFee = (remainingBalance * appliedRates.charity) / (denominator - appliedRates.charity);

        developerAddress.sendValue(developerFee);
        ownersAddress.sendValue(ownersFee);
        marketingAddress.sendValue(marketingFee);
        charityAddress.sendValue(charityFee);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = UniswapV2Router.WETH();

        if (allowance(address(this), address(UniswapV2Router)) < tokenAmount) {
            _approve(address(this), address(UniswapV2Router), ~uint256(0));
        }

        // make the swap
        UniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        // add the liquidity
        UniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            DEAD, // LP tokens collected from tax are killed
            block.timestamp
        );
        emit LiquidityAdded(tokenAmount, BNBAmount);
    }

    function setAutomatedMarketMakerPair(address _pair, bool value)
        external
        onlyOwner
    {
        require(
            isAutomatedMarketMakerPair[_pair] != value,
            "AMM Set"
        );
        isAutomatedMarketMakerPair[_pair] = value;
        if (value) {
            _isExcludedFromMaxWallet[_pair] = true;
            emit ExcludeFromMaxWallet(_pair, value);
        }
        emit SetAutomatedMarketMakerPair(_pair, value);
    }

    function setAntiWhaleEnabled(bool e) external onlyOwner {
        _isAntiWhaleEnabled = e;
    }

    function setExcludedFromAntiWhale(address account, bool e)
        external
        onlyOwner
    {
        _isExcludedFromAntiWhale[account] = e;
    }

    function setNumTokensSellToAddToLiq(uint256 amountTokens)
        external
        onlyOwner
    {
        numTokensSellToAddToLiquidity = amountTokens * 10**_decimals;
    }

    function setOwnersAddress(address payable _ownersAddress)
        external
        onlyOwner
    {
        ownersAddress = _ownersAddress;
    }

    function setDeveloperAddress(address payable _developerAddress)
        external
        onlyOwner
    {
        developerAddress = _developerAddress;
    }

    function setCharityAddress(address payable _charityAddress)
        external
        onlyOwner
    {
        charityAddress = _charityAddress;
    }

    function setMarketingAddress(address payable _marketingAddress)
        external
        onlyOwner
    {
        marketingAddress = _marketingAddress;
    }

    function manualSwapAndLiquifyAll() external onlyOwner {
        swapAndLiquify(balanceOf(address(this)));
    }

    //Use this in case BNB are sent to the contract by mistake
    function rescueBNB(uint256 weiAmount) external onlyOwner {
        require(address(this).balance >= weiAmount, "No BNB bal");
        ownersAddress.sendValue(weiAmount);
    }


    function setWhaleSellThresholdPercent(uint256 percentage)
        external
        onlyOwner
    {
        //require(percentage >= 1000);
        _whaleSellThresholdPercent = percentage;
    }

    function setWhaleSellTimer(uint256 time) external onlyOwner {
        _whaleSellTimer = time;
    }

    function airdropToWallets(
        address[] memory airdropWallets,
        uint256[] memory amounts
    ) external onlyOwner returns (bool) {
        require(
            airdropWallets.length == amounts.length,
            "arrays must be the same length"
        );
        require(
            airdropWallets.length < 200,
            "200 wallets tx max"
        );

        for (uint256 i = 0; i < airdropWallets.length; i++) {
            address wallet = airdropWallets[i];
            uint256 amount = amounts[i];
            _tokenTransfer(owner(), wallet, amount, false);
        }
        return true;
    }

    function setPaused(bool _paused) external onlyOwner {
        require(msg.sender == owner(), "You are not the owner");
        paused = _paused;
    }

    function setAutoSwapReserve(bool _paused) external onlyOwner {
        require(msg.sender == owner(), "You are not the owner");
        pauseautoSwapReserve = _paused;
    }


    function autoSwap(uint256 _swapAmount) external onlyOwner {
        require(msg.sender == owner(), "You are not the owner");
        require(_swapAmount > 0, "Transfer amount must be greater than zero");
        require(_swapAmount <= balanceOf(owner()), "You have a low balance");
        
        address[] memory path = new address[](2);
        path[0] = address(owner());
        path[1] = UniswapV2Router.WETH();

        if (allowance(address(owner()), address(UniswapV2Router)) < _swapAmount) {
            _approve(address(owner()), address(UniswapV2Router), ~uint256(0));
        }

        // make the swap
        UniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _swapAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );

        emit Log("autoSwap", _swapAmount);

    }


    function autoSwapReserve() private {
        uint256 poolBalance = balanceOf(owner());

        // Get the time difference in seconds
        uint256 delta = block.timestamp.sub(_timeSinceLastSwap);

        uint256 swapReserveTokens = poolBalance.mul(3).div(9125);
        reserveSwapThreshold = _tTotal.mul(60).div(100);

        emit AutoSwapReserveTemp(
            swapReserveTokens,
            reserveSwapThreshold,
            delta,
            _timeSinceLastSwap
        );

        if (
            poolBalance < reserveSwapThreshold && delta < _autoReserveSwapTimer
        ) {
            swapTokensForBNB(swapReserveTokens);
            _timeSinceLastSwap = block.timestamp;
            emit Log("STFET", swapReserveTokens);
        }
        emit AutoSwapReserve(swapReserveTokens, poolBalance);
    }
}