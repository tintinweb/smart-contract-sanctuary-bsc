// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./SafeMath.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./IFactoryV2.sol";
import "./IERC20.sol";
import "./IUniswapV2Pair.sol";

contract LIFEGAMES is IERC20 {
    using SafeMath for uint256;

    /*
        Smart Staking - Reflection: 0.5%     (standard)
        Liquidez: 1%                         (manda a wallet)
        Recompra y quema de tokens: 1%       (manda tokens a externo wallet decide si quemar o no)
        Reservas: 0.5%                       (manda tokens a externo)
    */


    //used for store the percentage of fees applied for purchase, sale, transfer and distribution to holders
    struct Fees {
        uint16 distributionToHoldersFee;
        uint16 liquidityFee;
        uint16 buyBackFee;
        uint16 busdReserveFee;
    }

    // used to designate the amount sent to the respective wallet after the fee is applied
    // NOT IN USE
    struct Ratios {
        uint16 liquidityRatio;
        uint16 buyBurnRatio;
        uint16 busdReserveRatio;
        uint16 total;
    }

    // internal accouting to manage fees
    struct FeeValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tBuyBurn;
        uint256 tReserve;
    }

    struct tFeeValues {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tBuyBurn;
        uint256 tReserve;
    }

    Ratios public _ratios;
    Fees public _taxRates;

    // REFLECTION (DISTRIBUTION TO HOLDERS / SMART STAKING)
    uint256 private _tTotal;
    uint256 private MAX;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint16 private _previousTaxFee;
    mapping(address => uint256) private _rOwned;
    address[] private _excluded;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    // --------------------------------------------------

    bool private gasLimitActive; // used for enable / disable max gas price limit
    uint256 private maxGasPriceLimit; // for store max gas price value
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily  // todo remove
    bool public transferDelayEnabled; // for enable / disable delay between transactions
    uint256 private initialBlock; // to store the block in which the trading was enabled

    bool private autoAddliquidityEnabled; // to enable / disable auto inject liquidity
    uint256 private autoLiquidityTokenPriceThreshold; // for set threshold for auto inject liquidity when price hit this threshold
    uint256 public autoAddliquidityThreshold; // for set threshold for auto inject liquidity

    // event for show burn txs
    event Burn(address indexed sender,uint256 amount);

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private _owner;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) _isFeeExcluded; // todo
    mapping(address => uint256) _tOwned;
    mapping(address => bool) private lpPairs; // used for allow owner to add liquidity in diferents tokens

    address public contractAddress;
    IUniswapV2Router02 public dexRouter;
    address public lpPair;
    address public zero;
    address public DEAD;
    address payable public busdForLiquidityAddress;
    address payable public busdBuyBurnAddress;
    address payable public busdReserveAddress;
    bool public contractSwapEnabled;
    uint256 public swapThreshold;
    bool inSwap;
    bool public tradingActive;
    address public busdAddress;
    bool public transferToPoolsOnSwaps;
    mapping(address => bool) private _liquidityRatioHolders;
    uint256 private _liqAddBlock;
    bool public hasLiqBeenAdded;
    mapping(address => bool) private _liquidityHolders;
   event TransferedToPool(address, uint256);
    // modifier for know when tx is swaping
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractSwapEnabledUpdated(bool enabled);

    // initialize upgradable contract
        constructor () {
        //__ERC20_init("LIFEGAMES", "LFG");
        //_mint(msg.sender, 1 * 1e7 * 1e18);
        _owner = msg.sender;
        _name = "LIFEGAMES";
        _symbol = "LFG";
        _decimals = 18;
        contractAddress = address(this);
        _owner = msg.sender; // set owner
        _rOwned[msg.sender] = _rTotal; // send total supply to owner

        DEAD = 0x000000000000000000000000000000000000dEaD;
        zero = 0x0000000000000000000000000000000000000000;

        // set busd, router, liquidity reserve and buy and burn reserve addresses
        address[] memory addresses = new address[](5);
        addresses[0] = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // busd
        addresses[1] = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // router
        addresses[2] = 0xd235eD438FB2D6Bd428F5AEdF67bc8AB03bcFB96; // liquidity address
        addresses[3] = 0x09f33F64aAADf6A02956C9732b25d42DD9c2d4bC; // buy burn address
        addresses[4] = 0x02FDE2D8e2E940d5D97FD8ad8F7a48dF8B6e3312; // busd reserve address

        // set fees values
        _taxRates = Fees({
            distributionToHoldersFee : 50,  // 0.5%
            liquidityFee : 100,             // 1.0%
            buyBackFee : 100,               // 1.0%
            busdReserveFee : 50             // 0.5%
        });

        // set ration values
        // NOT IN USE
        _ratios = Ratios({
            liquidityRatio : 100, // 1%
            buyBurnRatio : 100,   // 1%
            busdReserveRatio: 50, // 0.5%
            total : 250           // 2.5%
        });

        // REFLECTION (DISTRIBUTION TO HOLDERS / SMART STAKING)
        _tTotal = 1 * 1e7 * 1e18; // set total supply
        MAX = ~uint256(0); // set max allowed unsigned integer in solidity
        _rTotal = (MAX - (MAX % _tTotal)); // set max distribution to holders rewards // todo check
        _tFeeTotal;
        _previousTaxFee = 0; // used for temporaly store previous fee

        gasLimitActive = true; // used enable or disable max gas price limit
        maxGasPriceLimit = 15000000000; // used for store max gas price limit value
        transferDelayEnabled = false;   // used for enable / disable delay between transactions

        autoAddliquidityEnabled = false; // used for enable / disable inject liquidity automatically
        autoLiquidityTokenPriceThreshold = 0; // when the token reaches a set price, liquidity is automatically injected.
        autoAddliquidityThreshold = 0; // when the token reaches a set price, liquidity is automatically injected.

        swapThreshold = 100000000000000000000; // token balance on contract needed for do swap
        contractSwapEnabled = true; // enable or disable swap when contract balance hits threshodl
        tradingActive = false;
        transferToPoolsOnSwaps = false; // enable / disable transfer to wallets when contract do swap tokens for busd
        _liqAddBlock = 0;
        hasLiqBeenAdded = false;

        // constructor -------------------------------------
        _owner = msg.sender; // set owner
        _rOwned[msg.sender] = _rTotal; // send total supply to owner

        // set busd address
        busdAddress = address(addresses[0]);
        busdReserveAddress = payable(address(addresses[4]));

        // exclude from fee
        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[contractAddress] = true;

        // exclude LiquidityAddress and busdBuyBurnAddress
        _isExcludedFromFee[addresses[2]] = true;
        _isExcludedFromFee[addresses[3]] = true;

        // give permissions to the router to spend tokens and busd of the contract and owner
        _approve(msg.sender, busdAddress, type(uint256).max);
        _approve(contractAddress, busdAddress, type(uint256).max);

        _approve(msg.sender, addresses[1], type(uint256).max);
        _approve(contractAddress, addresses[1], type(uint256).max);

        // initialize router and create lp pair
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addresses[1]);
        //lpPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(contractAddress, busdAddress);
        //lpPairs[lpPair] = true;
        dexRouter = _uniswapV2Router;

        // wallets used to hold BUSD until liquidity is added/tokens are repurchased for burning.
        setLiquidityAddress(addresses[2]);
        setBusdBuyBurnAddress(addresses[3]);
        setBusdReserveAddress(addresses[4]);

        emit Transfer(zero, msg.sender, _tTotal);
        emit OwnershipTransferred(address(0), msg.sender);
    }
    // ====================================================== //
    //                      ONLY V3                           //
    // ====================================================== //
    function testMigrationFunction() external view returns (address){
        return owner();
    }

    function createPair() public onlyOwner() {
        lpPair = IFactoryV2(dexRouter.factory()).createPair(busdAddress,contractAddress );
        lpPairs[lpPair] = true;
    }

    function createPairv2(address add1) public onlyOwner() {
        lpPair = IFactoryV2(dexRouter.factory()).createPair(busdAddress, add1);
        lpPairs[lpPair] = true;
    }

    // ====================================================== //
    //                      RECIEVE                           //
    // ====================================================== //
    receive() external payable {}

    // ====================================================== //
    //                       EXTERNAL                         //
    // ====================================================== //
    
    function setTaxes(uint16 distributionToHoldersFee, uint16 liquidityFee, uint16 buyBackFee, uint16 busdReserveFee) external onlyOwner {
        // check each individual fee is not higher than 3%
        require(distributionToHoldersFee <= 300, "distributionToHoldersFee EXCEEDED 3%");
        require(liquidityFee <= 300, "liquidityFee EXCEEDED 3%");
        require(buyBackFee <= 300, "distributionToHoldersFee EXCEEDED 3%");
        require(busdReserveFee <= 300, "distributionToHoldersFee EXCEEDED 3%");

        // set values
        _taxRates.distributionToHoldersFee = distributionToHoldersFee;
        _taxRates.liquidityFee = liquidityFee;
        _taxRates.buyBackFee = buyBackFee;
        _taxRates.busdReserveFee = busdReserveFee;
    }

    function transferOwner(address newOwner) external onlyOwner {
        _isFeeExcluded[_owner] = false;
        _isFeeExcluded[newOwner] = true;
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    // set different liquidity pair
    function setLpPair(address pair, bool newValue) external onlyOwner {
        if (newValue = false) {
            lpPairs[pair] = false;
        } else {
            lpPairs[pair] = true;
        }
    }

    function updateAutoliquidityTokenPriceThreshold(bool newVal) external onlyOwner {
        transferDelayEnabled = newVal;
    }

    function updateContractAddress(address newVal) external onlyOwner {
         contractAddress = newVal;
    }

    function updateTransferDelayEnabled(bool newVal) external onlyOwner {
        transferDelayEnabled = newVal;
    }

    // todo remove later
    function updateTransferToPoolsOnSwaps(bool newValue) external onlyOwner {
        transferToPoolsOnSwaps = newValue;
    }

    function updateBUSDAddress(address newAddress) external onlyOwner {
        busdAddress = address(newAddress);
    }

    function updateAutoAddliquidityEnabled(bool newValue) external onlyOwner {
        autoAddliquidityEnabled = newValue;
    }

    function updateAutoAddliquidityThreshold(uint256 newValue) external onlyOwner {
        autoAddliquidityThreshold = newValue;
    }

    // send tokens to multiple wallets given wallets and amounts
    function multiSendTokens(address[] memory accounts, uint256[] memory amounts) external {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(_tOwned[msg.sender] >= amounts[i]);
            _transfer(msg.sender, accounts[i], amounts[i] * 10 ** _decimals);
        }
    }

    // send tokens to multiple wallets given wallets and percents
    function multiSendPercents(address[] memory accounts, uint256[] memory percents, uint256[] memory divisors) external {
        require(accounts.length == percents.length && percents.length == divisors.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(_tOwned[msg.sender] >= (_tTotal * percents[i]) / divisors[i]);
            _transfer(msg.sender, accounts[i], (_tTotal * percents[i]) / divisors[i]);
        }
    }


    function owner() public view returns (address) {return _owner;}

    // ====================================================== //
    //                        PUBLIC                          //
    // ====================================================== //


    function totalSupply() public view virtual override returns (uint256) {return _tTotal;}
    function decimals() public view virtual override returns (uint8) {return _decimals;}
    function symbol() public view virtual override returns (string memory) {return _symbol;}
    function name() public view virtual override returns (string memory) {return _name;}
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address tokenOwner, address spender) public view virtual override returns (uint256) {return _allowances[tokenOwner][spender];}
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address tokenOwner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(tokenOwner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function getOwner() external view returns (address) {
         return owner();
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    
    // check if account is excluded from fees
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    // used for exclude account from fees
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    // used for include account from fees
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    // only called on initializer
    function setLiquidityAddress(address _busdForLiquidityAddress) public onlyOwner {
        busdForLiquidityAddress = payable(_busdForLiquidityAddress);
    }

    function setBusdBuyBurnAddress(address _busdBuyBurnAddress) public onlyOwner {
        busdBuyBurnAddress = payable(_busdBuyBurnAddress);
    }

    function setBusdReserveAddress(address _busdReserveAddress) public onlyOwner {
        busdReserveAddress = payable(_busdReserveAddress);
    }

    // ====================================================== //
    //                PUBLIC EXPERIMENTAL                     //
    // ====================================================== //

    // enable trading (swap) and set initial block
    function enableTrading() public onlyOwner {
        require(!tradingActive, "Trading already enabled!");
        tradingActive = true;
        initialBlock = block.number;
    }

    // todo check excluded
    // check rfi contract and check if is same or not
    // check if account is excluded from fees
    function isFeeExcluded(address account) public view returns (bool) {
        return _isFeeExcluded[account];
    }
    // set router address and busd on this router
    function setNewRouter(address newRouter, address busd) public onlyOwner() {
        IUniswapV2Router02 _newRouter = IUniswapV2Router02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(address(busd),contractAddress );

        // check if pair exist
        // if not exists, create pair, otherwise get pair address from factory contract
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(address(busd),contractAddress );
        }
        else {
            lpPair = get_pair;
        }

        // set lp address on automatic market maker list
        lpPairs[lpPair] = true;
        dexRouter = _newRouter;
        _approve(contractAddress, address(dexRouter), type(uint256).max);
    }


    // check if limits are enabled
    function _hasLimits(address from, address to) private view returns (bool) {
        return from != _owner && from != busdForLiquidityAddress
        && to != _owner && to != busdForLiquidityAddress
        && tx.origin != _owner
        && !_liquidityRatioHolders[to]
        && !_liquidityRatioHolders[from]
        && to != DEAD
        && to != address(0)
        && from !=contractAddress ;
    }

    // ====================================================== //
    //                      INTERNAL                          //
    // ====================================================== //

    // Transfer between wallets have 0% fee
    // Buys and Sells are taxes equally
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount != 0, "Transfer amount cannot be zero");
        //console.log("----- %s sends %s %s -----", from, to, amount);

        if (inSwap) {
            _TransferNoFee(from, to, amount);
            return;
        }

        // SWAP
        uint256 contractTokenBalance = balanceOf(contractAddress);
        if (
            contractTokenBalance >= swapThreshold &&
            !inSwap &&
            from != lpPair &&
            balanceOf(lpPair) > 0 &&
            !_isExcludedFromFee[to] &&
            !_isExcludedFromFee[from] &&
            contractSwapEnabled
        ) {
            contractSwap(contractTokenBalance);
        }

        bool takeFee = true;
        bool isTransfer = isTransferBetweenWallets(from, to);

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        // Transfer between wallets have 0% fee
        // If takeFee is false there is 0% fee
        if (isTransfer || !takeFee){
            _TransferNoFee(from, to, amount);
            return;
        }

        //console.log("----- TAKE FEE IS %s -----", takeFee);
        //console.log("----- isTransferBetweenWallets %s -----", isTransfer);
        //console.log("----- _isExcludedFromFee -----", _isExcludedFromFee[from]);
        //console.log("----- _isExcludedFromFee -----", _isExcludedFromFee[to]);

        _tokenTransfer(from, to, amount, takeFee, isTransfer);
    }

    function isTransferBetweenWallets(address from, address to) internal view returns (bool) {
        // Check if transfer interacts with lp pair (BUYS or SELLS)
        /*
        if(from != lpPair && to != lpPair){
            //console.log("----- TX is TRANSFER not trade -----");
            return true;
        } else {
            return false;
        }
        */

        return from != lpPair && to != lpPair;
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, bool isTransfer) private {
        // Transfer between wallets have 0% fee
        // If takeFee is false there is 0% fee
        //if (isTransfer || !takeFee){
        //    _TransferNoFee(sender, recipient, amount);
        //    return;
        //}

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
    }

    function _TransferNoFee(address sender, address recipient, uint256 amount) private {

        //console.log("*********** NO FEE TRANSFER **********");
        uint256 currentRate = _getRate();
        uint256 rAmount = amount.mul(currentRate);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);

        if (_isExcluded[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(amount);
        }
        
        if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(amount);
        }
        emit Transfer(sender, recipient, amount);
    }



    // todo check if the amount of tokens distributed is proportional to the balance of each user
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount ) private {
        FeeValues memory _values = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(_values.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);
        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        FeeValues memory _values = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);
        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        FeeValues memory _values = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(_values.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);
        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        FeeValues memory _values = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);
        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }


    /*
    ORIGINAL 
    function _takeFees(address sender, FeeValues memory values) private {
        _takeFee(sender, values.tLiquidity, busdForLiquidityAddress );
        _takeFee(sender, values.tBuyBurn, busdBuyBurnAddress);
        _takeFee(sender, values.tReserve, busdReserveAddress);
    }
    */

    function _takeFees(address sender, FeeValues memory values) private {
       
        //  todo
        //_takeFee(sender, values.tLiquidity + values.tBuyBurn + values.tReserve, contractAddress );
        _takeFee(sender, values.tLiquidity, contractAddress );
        _takeFee(sender, values.tBuyBurn, contractAddress);
        _takeFee(sender, values.tReserve, contractAddress);
    }

    function _takeFee(address sender, uint256 tAmount, address recipient) private {
        if(recipient == address(0)) return;
        if(tAmount == 0) return;

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        if(_isExcluded[recipient])
            _tOwned[recipient] = _tOwned[recipient].add(tAmount);

        emit Transfer(sender, recipient, tAmount);
    }

    function _checkLiquidityAdd(address from, address to) private {
        require(!hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {

            _liqAddBlock = block.number;
            _liquidityHolders[from] = true;
            hasLiqBeenAdded = true;

            contractSwapEnabled = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }

    function updateContractSwapEnabled(bool newValue) public onlyOwner {
        contractSwapEnabled = newValue;
    }

    function updateMaxGasPriceLimit(uint256 newValue) public onlyOwner {
        require(newValue >= 10000000000, "max gas price cant be lower than 10 gWei");
        maxGasPriceLimit = newValue;
    }

    function updateAutoLiquidityTokenPriceThreshold(uint256 newValue) public onlyOwner {
        autoLiquidityTokenPriceThreshold = newValue;
    }

    function contractSwap(uint256 numTokensToSwap) internal swapping {
        // cancel swap if fees are zero
        if (_ratios.total == 0) {
            return;
        }

        // check allowances // todo
        if (_allowances[address(this)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }

        // calculate percentage to bsud reserver and manual buyback and burn 
        uint256 tokensToliquidityAmount = (numTokensToSwap * _ratios.liquidityRatio) / (_ratios.total);
        uint256 tokensToBuyBurnAmount = (numTokensToSwap * _ratios.buyBurnRatio) / (_ratios.total);
        //uint256 minOut = getOutEstimatedTokensForTokens(address(this), busdAddress, numTokensToSwap);

        // swap tokens for busd and send to busd liquidity address
        if (tokensToliquidityAmount > 0) {

            address[] memory tokensBusdPath = getPathForTokensToTokens(address(this), busdAddress);
            IERC20(address(this)).approve(address(dexRouter), numTokensToSwap);
            IERC20(busdAddress).approve(address(dexRouter), numTokensToSwap);

            dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokensToliquidityAmount,
                0,
                tokensBusdPath,
                busdForLiquidityAddress,
                block.timestamp + 600
            );
        }

        // swap tokens for busd and send to manual busd buyback and burn address 
        if (tokensToBuyBurnAmount > 0) {

            address[] memory tokensBusdPath = getPathForTokensToTokens(address(this), busdAddress);
            IERC20(address(this)).approve(address(dexRouter), numTokensToSwap);
            IERC20(busdAddress).approve(address(dexRouter), numTokensToSwap);

            dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokensToBuyBurnAmount,
                0,
                tokensBusdPath,
                busdBuyBurnAddress,
                block.timestamp + 600
            );
        }

        // todo test auto liquidityRatio
        if (autoAddliquidityEnabled) {

            uint256 tokenPriceInBusd = getOutEstimatedTokensForTokens(address(this), busdAddress, 1000000000000000000);

            // todo create update autoliquidity price condition 
            //if (tokenPriceInBusd > autoliquidityTokenPriceThreshold) {
            if (tokenPriceInBusd > 1) {

                // amounts
                uint256 estimatedTokensForAutoliquidity = getOutEstimatedTokensForTokens(address(this), busdAddress, 100000000000000000000);
                uint256 estimatedBusdForAutoliquidity = getOutEstimatedTokensForTokens(busdAddress, address(this), estimatedTokensForAutoliquidity);

                // if hit threshold
                // transfer tokens and busd contract
                if (estimatedTokensForAutoliquidity > autoAddliquidityThreshold) {

                    IERC20(address(busdAddress)).transferFrom(busdForLiquidityAddress, address(this), estimatedBusdForAutoliquidity);
                    IERC20(address(busdAddress)).transferFrom(busdBuyBurnAddress, address(this), estimatedTokensForAutoliquidity);

                    // swap busd for tokens?
                    addLiquidity(address(this), busdAddress, estimatedTokensForAutoliquidity, estimatedBusdForAutoliquidity, 0, 0, owner());
                }
            }
        }
    }

    function sendToPools() internal {
        
        uint256 newBalance = contractAddress.balance;

        if (newBalance > 0) {

            uint256 busdForLiquidityAmount = (newBalance * _ratios.liquidityRatio) / (_ratios.total);
            if (busdForLiquidityAmount > 0) {
                IERC20(address(busdAddress)).transferFrom(contractAddress,busdForLiquidityAddress,busdForLiquidityAmount);
                //payable(busdForLiquidityAddress).transfer(busdForLiquidityAmount);
                emit TransferedToPool(busdForLiquidityAddress, busdForLiquidityAmount);
            }

            uint256 busdBuyBurnAmount = (newBalance * _ratios.buyBurnRatio) / (_ratios.total);
            if (busdBuyBurnAmount > 0) {
                IERC20(address(busdAddress)).transferFrom(contractAddress,busdBuyBurnAddress,busdBuyBurnAmount);
                //payable(busdBuyBurnAddress).transfer(busdBuyBurnAmount);
                emit TransferedToPool(busdBuyBurnAddress, busdBuyBurnAmount);
            }

            uint256 busdReserveAmount = (newBalance * _ratios.buyBurnRatio) / (_ratios.total);
            if (busdReserveAmount > 0) {
                IERC20(address(busdAddress)).transferFrom(contractAddress,busdReserveAddress,busdReserveAmount);
                //payable(busdReserveAddress).transfer(busdReserveAmount);
                emit TransferedToPool(busdReserveAddress, busdReserveAmount);
            }
        }
    }



    // return busd and token reserves on the pool
    function getReserves() public view returns (uint[] memory) {
        IUniswapV2Pair pair = IUniswapV2Pair(lpPair);
        (uint Res0, uint Res1,) = pair.getReserves();

        uint[] memory reserves = new uint[](2);
        reserves[0] = Res0;
        reserves[1] = Res1;

        return reserves;
    }

    // return token price
    function getTokenPrice(uint amount) public view returns (uint) {
        uint[] memory reserves = getReserves();
        uint res0 = reserves[0] * (10 ** _decimals);
        return ((amount * res0) / reserves[1]);
    }

    // return amount of tokenA needed to buy 1 tokenB
    function getOutEstimatedTokensForTokens(address tokenAddressA, address tokenAddressB, uint amount) public view returns (uint256) {
        return dexRouter.getAmountsOut(amount, getPathForTokensToTokens(tokenAddressA, tokenAddressB))[1];
    }

    // return amount of tokenA needed to sell 1 tokenB
    function getInEstimatedTokensForTokens(address tokenAddressA, address tokenAddressB, uint amount) public view returns (uint256) {
        return dexRouter.getAmountsIn(amount, getPathForTokensToTokens(tokenAddressA, tokenAddressB))[1];
    }

    // return the route given the busd addresses and the token
    function getPathForTokensToTokens(address tokenAddressA, address tokenAddressB) private pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = tokenAddressA;
        path[1] = tokenAddressB;
        return path;
    }

    // todo check if burn create new tokens
    function burn(address to, uint256 amount) public {
        require(amount >= 0, "Burn amount should be greater than zero");

        // check sender allowance
        if (msg.sender != to) {
            uint256 currentAllowance = _allowances[to][msg.sender];
            if (currentAllowance != type(uint256).max) {
                require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            }
        }

        // burn amount must be equal or greather than sender balance
        require(amount <= balanceOf(to),"Burn amount should be less than account balance");

        // decrease user balance and total supply
        _tOwned[to] = _tOwned[to] - amount;
        _tTotal = _tTotal - amount;
        emit Burn(to, amount);
    }

    // reflection -------------------------------------------------------------------------------------------

    function reflectionFromToken(uint256 tAmount) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        FeeValues memory _values = _getValues(tAmount);
        return _values.rAmount;
    }

    function tokenFromReflection(uint256 rAmount) internal view returns (uint256) {
        require(rAmount <= _rTotal, "Amt must be less than tot refl");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function removeAllFee() private {
        if (_taxRates.distributionToHoldersFee == 0) return;
        _previousTaxFee = _taxRates.distributionToHoldersFee;
        _taxRates.distributionToHoldersFee = 0;
    }

    function restoreAllFee() private {
        _taxRates.distributionToHoldersFee = _previousTaxFee;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (FeeValues memory) {
        tFeeValues memory tValues = _getTValues(tAmount);
        // add all extra fees
        uint256 tTransferFee = tValues.tLiquidity.add(tValues.tBuyBurn).add(tValues.tReserve);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tValues.tFee, tTransferFee, _getRate());

        return FeeValues(rAmount, rTransferAmount, rFee, tValues.tTransferAmount, tValues.tFee, tValues.tLiquidity, tValues.tBuyBurn, tValues.tReserve);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTransferFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferFee = tTransferFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTransferFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getTValues(uint256 tAmount) private view returns (tFeeValues memory) {

        tFeeValues memory tValues = tFeeValues(
            0,
            calculateFee(tAmount, _taxRates.distributionToHoldersFee),
            calculateFee(tAmount, _taxRates.liquidityFee),
            calculateFee(tAmount, _taxRates.buyBackFee),
            calculateFee(tAmount, _taxRates.busdReserveFee)
        );

        tValues.tTransferAmount = tAmount.sub(tValues.tFee).sub(tValues.tLiquidity).sub(tValues.tBuyBurn).sub(tValues.tReserve);
        return tValues;
    }

    function calculateFee(uint256 _amount, uint256 _fee) private pure returns (uint256) {
        if(_fee == 0) return 0;
        return _amount.mul(_fee).div(
            10**4
        );
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

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) private {
        _approve(contractAddress, address(dexRouter), amountADesired);
        _approve(contractAddress, address(dexRouter), amountBDesired);
        dexRouter.addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            to,
            block.timestamp
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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
        // Gas optimization: this is TKNaper than requiring 'a' not being zero, but the
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
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
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
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
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
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
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
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IUniswapV2Factory {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);

    function getPair(address tokenA, address tokenB) external view returns (address lpPair);

    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IUniswapV2Router01 {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}