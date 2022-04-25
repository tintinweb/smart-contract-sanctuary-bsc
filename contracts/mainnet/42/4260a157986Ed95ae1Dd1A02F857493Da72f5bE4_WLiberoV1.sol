/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Auth is Context{
    address owner;
    mapping (address => bool) private authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender)); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender)); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
        emit Authorized(adr);
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
        emit Unauthorized(adr);
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
    event Authorized(address adr);
    event Unauthorized(address adr);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ILibero is IERC20 {
    function getCirculatingSupply() external view returns (uint256);
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "zero address");
        require(recipient != address(0), "zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "zero address");
        require(spender != address(0), "zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

interface IDexPair {
    function sync() external;
}

interface IReserveTreasury {
    function claimTokens(address token, uint256 amount, address receiver) external returns(bool);
}

interface ITaxTreasury {
    function updateRewards() external;
}

contract WLiberoV1 is ERC20, Auth, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public constant MAX_SUPPLY = 50 * 10**6 * 10**18;
    uint256 private constant MAX_TAX = 5000;
    uint256 private constant MAX_WRAP_FEE = 9000;

    bool private swapping;
    
    IDEXRouter public dexRouter;
    address dexPair;

    address public constant LIBERO = 0x0DFCb45EAE071B3b846E220560Bbcdd958414d78;
    address private constant burnAddress = 0x0000000000000000000000000000000000000000;
    address private constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public marketingWallet = 0x770BdD792f6471EB28cBccD4F193BB26e8B5B07E;

    IReserveTreasury public reserveTreasury;
    ITaxTreasury public taxTreasury;
    ITaxTreasury public nftTreasury;

    bool public isNotMigrating = true;
    bool public isLiquidityInBnb = true;

    bool public isFeesOnNormalTransfers = true;
    uint256 public normalTransferFee = 1400;
    uint256 public totalSellFees = 1600;
    uint256 public liquidityFee = 400;
    uint256 public toBurnTokenFee = 100;
    uint256 public nftDividendFee = 400;
    uint256 public marketingFee = 100;
    uint256 public treasuryFee = 400;
    uint256 public rewardBuyerFee = 100;
    uint256 public totalBuyFees = liquidityFee.add(toBurnTokenFee).add(nftDividendFee).add(marketingFee).add(treasuryFee).add(rewardBuyerFee);

    bool public isWrapEnable = true;
    uint256 public wrapFee = 3000;
    uint256 public unWrapFee = 0;

    uint256 public maxSellTransactionAmount = 50000 * 10**18;
    uint256 public swapTokensAtAmount = 2000 * 10 ** 18;

    mapping (address => bool) public isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) public blacklist;
    mapping (address => uint256) public nextSellTax;
    address[] private _markerPairs;
    mapping (address => uint256) public lpNukeBuildup;

    /** Luke Config **/
    bool public lpNukeEnabled = false;
    uint256 public nukePercentPerSell = 2500;

    /** Reward Biggest Buyer **/
    bool public isRewardBiggestBuyer = true;
    uint256 public immutable launchTime;
    uint256 public biggestBuyerPeriod = 1800;
    mapping(uint256 => address) public biggestBuyer;
    mapping(uint256 => uint256) public biggestBuyerAmount;
    mapping(uint256 => uint256) public biggestBuyerPaid;

    /** Breaker Config **/
    bool public isBreakerEnable = true;
    uint256 public breakerPeriod = 3600;
    uint256 public breakerPercent = 100;
    uint256 public breakerBuyFee = 1000;
    uint256 public breakerSellFee = 2500;
    uint public _curcuitBreakerFlag;
    uint public _curcuitBreakerTime;

    uint private _timeAccuTaxCheckGlobal;
    uint private _taxAccuTaxCheckGlobal;

    receive() external payable {}

    constructor(
        address _reserveTreasury,
        address _taxTreasury,
        address _nftTreasury
    ) ERC20("WTest3", "WTest3") Auth(msg.sender) {
        IDEXRouter _dexRouter = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _dexPair = IDEXFactory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());

        setDexRouter(address(_dexRouter), _dexPair);

        excludeFromFees(marketingWallet, true);
        excludeFromFees(address(this), true);
        excludeFromFees(owner, true);

        setReserveTreasury(_reserveTreasury);
        setTaxTreasury(_taxTreasury);
        setNftTreasury(_nftTreasury);

        uint256 startSupply = LiberoToWLibero(ILibero(LIBERO).getCirculatingSupply());

        _mint(msg.sender, startSupply);
        _mint(deadAddress, MAX_SUPPLY.sub(startSupply));

        launchTime = block.timestamp;
    }

    /***** Wrap Feature *****/
    function getIndex() public view returns (uint256) {
        return IERC20(LIBERO).totalSupply().mul(100 * 10**18).div(5 * 10**9 * 10**18);
    }

    function WLiberoToLibero(uint256 _amount) public view returns (uint256) {
        return _amount.mul(getIndex()).div(10**18);
    }

    function LiberoToWLibero(uint256 _amount) public view returns (uint256) {
        return _amount.mul(10**18).div(getIndex());
    }

    function wrap(uint256 _amount) external nonReentrant returns (uint256) {
        require(isWrapEnable == true, "wLIBERO: wrapping disabled");
        require(_amount > 0,"Invalid amount");

        IERC20(LIBERO).transferFrom(msg.sender, address(this), _amount);

        uint256 value = LiberoToWLibero(_amount);

        if(wrapFee > 0){
            uint256 feeAmount = value.mul(wrapFee).div(10000);

            if(feeAmount > 0){
                value = value.sub(feeAmount);
                reserveTreasury.claimTokens(address(this), feeAmount, address(taxTreasury));
                taxTreasury.updateRewards();
            }
        }

        require(value > 0, "Too small");

        reserveTreasury.claimTokens(address(this), value, msg.sender);

        emit Wrap(msg.sender, _amount, value);

        return value;
    }

    function unwrap(uint256 _amount) external nonReentrant returns (uint256) {
        require(isWrapEnable == true, "wLIBERO: unwrapping disabled");
        require(_amount > 0,"Invalid amount");

        if(unWrapFee > 0){
            uint256 feeAmount = _amount.mul(unWrapFee).div(10000);

            if(feeAmount > 0){
                _amount = _amount.sub(feeAmount);
                _transfer(msg.sender, address(taxTreasury), feeAmount);
                taxTreasury.updateRewards();
            }
        }

        _transfer(msg.sender, address(reserveTreasury), _amount);

        uint256 value = WLiberoToLibero(_amount);

        IERC20(LIBERO).transfer(msg.sender, value);

        emit UnWrap(msg.sender, _amount, value);

        return value;
    }

    function setWrapFees(uint256 _wrapFee, uint256 _unWrapFee) external onlyOwner {
        require(_wrapFee.add(_unWrapFee) <= MAX_WRAP_FEE, "Too high");

        wrapFee = _wrapFee;
        unWrapFee = _unWrapFee;
    }

    function setWrapStatus(bool _status) public onlyOwner {
        require(isWrapEnable != _status, "Not changed");
        isWrapEnable = _status;
    }

    /***** Token Feature *****/
    function circulatingSupply() public view returns (uint256) {
        return totalSupply().sub(balanceOf(address(deadAddress))).sub(balanceOf(address(reserveTreasury)));
    }

    function getPeriod() public view returns (uint256) {
        uint256 secondsSinceLaunch = block.timestamp - launchTime;
        return 1 + (secondsSinceLaunch / biggestBuyerPeriod);
    }

    function nukeLpTokenFromBuildup() external authorized {
        if(lpNukeEnabled){
            for(uint i = 0; i < _markerPairs.length; i++){

                uint256 nukeAmount = lpNukeBuildup[_markerPairs[i]];

                if(nukeAmount > 0){
                    uint256 maxBuildUp = balanceOf(_markerPairs[i]).mul(2000).div(10000);

                    if(nukeAmount > maxBuildUp){
                        nukeAmount = maxBuildUp;
                    }

                    super._transfer(_markerPairs[i], deadAddress, nukeAmount);

                    lpNukeBuildup[_markerPairs[i]] = 0;

                    IDexPair pair = IDexPair(_markerPairs[i]);

                    try pair.sync() {

                    }catch Error (string memory reason) {
                        emit SyncLpErrorEvent(_markerPairs[i], reason);
                    }
                }
            }
        }
    }

    function payBiggestBuyer(uint256 _hour) external authorized {
        _checkAndPayBiggestBuyer(_hour);
    }

    function setNextSellTax(address account, uint256 sellTax) public authorized {
        require(sellTax < MAX_TAX, "Tax too high");
        nextSellTax[account] = sellTax;
    }

    function excludeFromFees(address account, bool _status) public onlyOwner {
        require(account != address(dexRouter), 'Cannot blacklist router');
        require(account != dexPair, 'Cannot blacklist pair');
        require(isExcludedFromFees[account] != _status, "Already excluded");

        isExcludedFromFees[account] = _status;

        emit ExcludeFromFees(account, _status);
    }

    function setBotBlacklist(address account, bool _status) public onlyOwner {
        require(_isContract(account), "Only contract");
        require(account != address(dexRouter), "Not allow block dexRouter");
        require(account != dexPair, "Not allow block dexPair");

        blacklist[account] = _status;

        emit BotBlacklist(account, _status);
    }

    function setDexRouter(address _dexRouter, address _dexPair) public onlyOwner {
        dexRouter = IDEXRouter(_dexRouter);
        dexPair = _dexPair;

        setAutomatedMarketMakerPair(dexPair, true);

        _approve(address(this), address(dexRouter), MAX_SUPPLY);
        approve(address(dexRouter), MAX_SUPPLY);
        approve(address(dexPair), MAX_SUPPLY);

        IERC20(busdToken).approve(address(dexRouter), 2**256 - 1);
    }

    function setAutomatedMarketMakerPair(address _dexPair, bool _status) public onlyOwner {
        automatedMarketMakerPairs[_dexPair] = _status;

        if(_status){
            _markerPairs.push(_dexPair);
        }else{
            require(_markerPairs.length >= 1, "Required 1 pair");
            for (uint256 i = 0; i < _markerPairs.length; i++) {
                if (_markerPairs[i] == _dexPair) {
                    _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                    _markerPairs.pop();
                    break;
                }
            }
        }

        emit SetAutomatedMarketMakerPair(_dexPair, _status);
    }

    function setMaxInTx(uint256 _amount) external onlyOwner {
        require(_amount >= 10**18,"Too small");
        maxSellTransactionAmount = _amount;
    }

    function setMarketingWallet(address _newAddress) external onlyOwner {
        excludeFromFees(_newAddress, true);
        marketingWallet = _newAddress;
    }

    function setTaxTreasury(address _newAddress) public onlyOwner {
        excludeFromFees(_newAddress, true);
        taxTreasury = ITaxTreasury(_newAddress);
    }

    function setNftTreasury(address _newAddress) public onlyOwner {
        excludeFromFees(_newAddress, true);
        nftTreasury = ITaxTreasury(_newAddress);
    }

    function setReserveTreasury(address _newAddress) public onlyOwner {
        excludeFromFees(_newAddress, true);
        reserveTreasury = IReserveTreasury(_newAddress);
    }

    function setSwapTokensAtAmount(uint256 _amount) external onlyOwner {
        swapTokensAtAmount = _amount;
    }

    function setIsNotMigrating(bool _status) external onlyOwner {
        require(isNotMigrating != _status, "Not changed");
        isNotMigrating = _status;
    }

    function setIsLiquidityInBnb(bool _status) external onlyOwner {
        require(isLiquidityInBnb != _status, "Not changed");
        isLiquidityInBnb = _status;
    }

    function setBusdToken(address _newAddress) external onlyOwner {
        busdToken = _newAddress;
        IERC20(busdToken).approve(address(dexRouter), 2**256 - 1);
    }

    function setTokenFees(
        uint256 _liquidityFee,
        uint256 _toBurnTokenFee,
        uint256 _nftDividendFee,
        uint256 _marketingFee,
        uint256 _treasuryFee,
        uint256 _rewardBuyerFee,
        uint256 _totalSellFees
    ) external onlyOwner {
        uint256 _totalBuyFees = _liquidityFee + _toBurnTokenFee + _nftDividendFee + _marketingFee + _treasuryFee + _rewardBuyerFee;

        require(_totalBuyFees <= MAX_TAX, "Buy fee too high");
        require(_totalSellFees <= MAX_TAX, "Sell fee too high");

        liquidityFee = _liquidityFee;
        toBurnTokenFee = _toBurnTokenFee;
        nftDividendFee = _nftDividendFee;
        marketingFee = _marketingFee;
        treasuryFee = _treasuryFee;
        totalBuyFees = _totalBuyFees;
        rewardBuyerFee = _rewardBuyerFee;

        totalSellFees = _totalSellFees;
    }

    function setFeesOnNormalTransfers(bool _status, uint256 _normalTransferFee) external onlyOwner {
        isFeesOnNormalTransfers = _status;
        normalTransferFee = _normalTransferFee;
    }

    function setFeesOnBreaker(bool _status, uint256 _breakerPeriod, uint256 _breakerPercent, uint256 _breakerBuyFee, uint256 _breakerSellFee) external onlyOwner {
        require(_breakerBuyFee <= MAX_TAX, "Buy fee too high");
        require(_breakerSellFee <= MAX_TAX, "Sell fee too high");

        isBreakerEnable = _status;
        breakerPeriod = _breakerPeriod;
        breakerPercent = _breakerPercent;

        breakerBuyFee = _breakerBuyFee;
        breakerSellFee = _breakerSellFee;
    }

    function setLpNukeEnabled(bool _status, uint256 _percent) external onlyOwner {
        require(lpNukeEnabled != _status, "Not changed");
        require(_percent <= 10000, 'cannot be more than 100%');

        lpNukeEnabled = _status;
        nukePercentPerSell = _percent;

        if(!lpNukeEnabled){
            for(uint i = 0; i < _markerPairs.length; i++){
                lpNukeBuildup[_markerPairs[i]] = 0;
            }
        }
    }

    function setIsRewardBiggestBuyer(bool _status, uint256 _biggestBuyerPeriod) external onlyOwner {
        require(_biggestBuyerPeriod >= 300, "Period too small");
        isRewardBiggestBuyer = _status;
        biggestBuyerPeriod = _biggestBuyerPeriod;
    }

    function retrieveTokens(address _token) external onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));

        require(IERC20(_token).transfer(msg.sender, amount), "Transfer failed");
    }

    function retrieveBNB() external onlyOwner {
        uint256 amount = address(this).balance;

        (bool success,) = payable(msg.sender).call{ value: amount }("");
        require(success, "Failed to retrieve BNB");
    }

    /***** Internal Functions *****/
    function _isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "zero address");
        require(to != address(0), "zero address");
        require(!blacklist[from] && !blacklist[to], "in blacklist");

        bool excludedAccount = isExcludedFromFees[from] || isExcludedFromFees[to];

        require(isNotMigrating || excludedAccount, "Trading not started");

        if (
            automatedMarketMakerPairs[to] &&
            !excludedAccount
        ) {
            require(amount <= maxSellTransactionAmount, "Sell amount too big");

            uint256 contractTokenBalance = balanceOf(address(this));

            if (!swapping && contractTokenBalance >= swapTokensAtAmount) {
                swapping = true;

                uint256 totalBnbFee = marketingFee.add(treasuryFee).add(rewardBuyerFee);

                if(totalBnbFee > 0){
                    uint256 swapTokens = contractTokenBalance.mul(totalBnbFee).div(totalBuyFees);

                    uint256 beforeAmount = address(this).balance;
                    _swapTokensForBNB(swapTokens);
                    uint256 increaseAmount = address(this).balance.sub(beforeAmount);

                    if(increaseAmount > 0){
                        uint256 marketingAmount = increaseAmount.mul(marketingFee).div(totalBnbFee);
                        uint256 treasuryAmount = increaseAmount.mul(treasuryFee).div(totalBnbFee);

                        if(marketingAmount > 0){
                            _transferBNBToWallet(payable(marketingWallet), marketingAmount);
                        }

                        if(treasuryAmount > 0){
                            _transferBNBToWallet(payable(address(taxTreasury)), treasuryAmount);
                            taxTreasury.updateRewards();
                        }
                    }
                }

                if(liquidityFee > 0){
                    _swapAndLiquify(contractTokenBalance.mul(liquidityFee).div(totalBuyFees));
                }

                if(nftDividendFee > 0){
                    uint256 feeAmount = contractTokenBalance.mul(nftDividendFee).div(totalBuyFees);

                    super._transfer(address(this), address(nftTreasury), feeAmount);

                    nftTreasury.updateRewards();
                }

                if(toBurnTokenFee > 0){
                    uint256 tokensToBurn = contractTokenBalance.mul(toBurnTokenFee).div(totalBuyFees);
                    _burn(address(this), tokensToBurn);
                    emit Transfer(address(this), burnAddress, tokensToBurn);
                }

                swapping = false;
            }

            if(isBreakerEnable){
                _accuTaxSystem(amount);
            }
        }

        if(!swapping && !excludedAccount) {
            uint256 fees = amount.mul(totalBuyFees).div(10000);

            if(automatedMarketMakerPairs[to]) {
                if(nextSellTax[from] > 0){
                    fees = amount.mul(nextSellTax[from]).div(10000);
                    nextSellTax[from] = 0;
                }else if(isBreakerEnable && _curcuitBreakerFlag == 2){
                    fees = amount.mul(breakerSellFee).div(10000);
                }else{
                    fees = amount.mul(totalSellFees).div(10000);
                }
            }else if(automatedMarketMakerPairs[from]){
                if(isBreakerEnable && _curcuitBreakerFlag == 2){
                    fees = amount.mul(breakerBuyFee).div(10000);
                }
            }else{
                if(isFeesOnNormalTransfers){
                    fees = amount.mul(normalTransferFee).div(10000);
                }else{
                    fees = 0;
                }
            }

            if(fees > 0){
                amount = amount.sub(fees);
                super._transfer(from, address(this), fees);
            }
        }

        super._transfer(from, to, amount);

        if(isRewardBiggestBuyer){
            uint256 _periodAfterLaunch = getPeriod();

            if(automatedMarketMakerPairs[from] && !_isContract(to)){
                if (amount > biggestBuyerAmount[_periodAfterLaunch]) {
                    biggestBuyer[_periodAfterLaunch] = to;
                    biggestBuyerAmount[_periodAfterLaunch] = amount;
                }
            }

            _checkAndPayBiggestBuyer(_periodAfterLaunch);
        }

        if (lpNukeEnabled && automatedMarketMakerPairs[to] && from != address(this)) {
            lpNukeBuildup[to] += amount.mul(nukePercentPerSell).div(10000);
        }
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        if(isLiquidityInBnb){
            uint256 initialBalance = address(this).balance;

            _swapTokensForBNB(half);

            uint256 newBalance = address(this).balance.sub(initialBalance);

            _addLiquidity(otherHalf, newBalance);

            emit SwapAndLiquify(half, newBalance, otherHalf);
        }else{
            uint256 initialBalance = IERC20(busdToken).balanceOf(address(this));

            _swapTokensForBusd(half);

            uint256 newBalance = IERC20(busdToken).balanceOf(address(this)).sub(initialBalance);

            _addLiquidityBusd(otherHalf, newBalance);

            emit SwapAndLiquifyBusd(half, newBalance, otherHalf);
        }
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        dexRouter.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(taxTreasury),
            block.timestamp
        );
    }

    function _swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapTokensForBusd(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        path[2] = busdToken;

        dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidityBusd(uint256 tokenAmount, uint256 busdAmount) private {
        dexRouter.addLiquidity(
            address(this),
            busdToken,
            tokenAmount,
            busdAmount,
            0,
            0,
            address(taxTreasury),
            block.timestamp
        );
    }

    function _transferBNBToWallet(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function _checkAndPayBiggestBuyer(uint256 _currentPeriod) private {
        uint256 _prevPeriod = _currentPeriod - 1;
        if (
            _currentPeriod > 1 &&
            biggestBuyerAmount[_prevPeriod] > 0 &&
            biggestBuyerPaid[_prevPeriod] == 0
        ) {
            uint256 _rewardAmount = address(this).balance;
            if (_rewardAmount > 0) {
                _transferBNBToWallet(payable(biggestBuyer[_prevPeriod]), _rewardAmount);
                biggestBuyerPaid[_prevPeriod] = _rewardAmount;

                emit PayBiggestBuyer(biggestBuyer[_prevPeriod], _prevPeriod, _rewardAmount);
            }
        }
    }

    function _deactivateCircuitBreaker() internal returns (uint) {
        // in the solidity world,
        // to save the gas,
        // 1 is false, 2 is true
        _curcuitBreakerFlag = 1;

        _taxAccuTaxCheckGlobal = 1; // [save gas]
        _timeAccuTaxCheckGlobal = block.timestamp.sub(1); // set time (set to a little past than now)

        return 1;
    }

    function _accuTaxSystem(uint amount) internal {
        uint r1 = balanceOf(dexPair);

        uint curcuitBreakerFlag_ = _curcuitBreakerFlag;
        if (curcuitBreakerFlag_ == 2) { // circuit breaker activated
            if (_curcuitBreakerTime + breakerPeriod < block.timestamp) { // certain duration passed. everyone chilled now?
                curcuitBreakerFlag_ = _deactivateCircuitBreaker();
            }
        }

        uint taxAccuTaxCheckGlobal_ = _taxAccuTaxCheckGlobal;
        uint timeAccuTaxCheckGlobal_ = _timeAccuTaxCheckGlobal;

        {
            uint timeDiffGlobal = block.timestamp.sub(timeAccuTaxCheckGlobal_);
            uint priceChange = _getPriceChange(r1, amount); // price change based, 10000
            if (timeDiffGlobal < breakerPeriod) { // still in time window
                taxAccuTaxCheckGlobal_ = taxAccuTaxCheckGlobal_.add(priceChange); // accumulate
            } else { // time window is passed. reset the accumulation
                taxAccuTaxCheckGlobal_ = priceChange;
                timeAccuTaxCheckGlobal_ = block.timestamp; // reset time
            }
        }


        if (breakerPercent < taxAccuTaxCheckGlobal_) {
            _curcuitBreakerFlag = 2;
            _curcuitBreakerTime = block.timestamp;

            emit CircuitBreakerActivated();
        }

        /////////////////////////////////////////////// always return local variable to state variable!

        _taxAccuTaxCheckGlobal = taxAccuTaxCheckGlobal_;
        _timeAccuTaxCheckGlobal = timeAccuTaxCheckGlobal_;

        return;
    }

    function _getPriceChange(uint r1, uint x) internal pure returns (uint) {
        uint x_ = x.mul(9975); // pcs fee
        uint r1_ = r1.mul(10000);
        uint nume = r1.mul(r1_).mul(10000); // to make it based on 10000 multi
        uint deno = r1.add(x).mul(r1_.add(x_));
        uint priceChange = nume / deno;
        priceChange = (uint(10000).sub(priceChange)).div(2);

        return priceChange;
    }

    event CircuitBreakerActivated();
    event PayBiggestBuyer(address indexed account, uint256 indexed period, uint256 amount);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event BotBlacklist(address indexed account, bool isBlocked);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SwapAndLiquifyBusd(uint256 tokensSwapped, uint256 busdReceived, uint256 tokensIntoLiqudity);
    event Wrap(address indexed account, uint256 inAmount, uint256 outAmount);
    event UnWrap(address indexed account, uint256 inAmount, uint256 outAmount);
    event SyncLpErrorEvent(address lpPair, string reason);
}