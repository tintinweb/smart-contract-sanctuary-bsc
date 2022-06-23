/**
 *Submitted for verification at BscScan.com on 2022-06-23
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


interface IAutoLiquidityTreasury {
    function autoLiquidify(address _sourceToken, address _pairWithToken, address _dexToken, address _dexRouter) external;
}

interface ITreasury {
    function updateRewards() external;
}

contract LiberaToken is ERC20, Auth, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public constant MAX_SUPPLY = 50 * 10**6 * 10**18;
    uint256 private constant MAX_TAX = 5000;

    bool private swapping;
    
    IDEXRouter public dexRouter;
    address public dexPair;

    address public constant LIBERO = 0x0DFCb45EAE071B3b846E220560Bbcdd958414d78;
    address private constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public liquidityToken;
    address public dexToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public marketingWallet;

    address public reserveTreasury;
    address public taxTreasury;
    ITreasury public nukeTreasury;
    ITreasury public busdTreasury;
    

    bool public isNotMigrating = false;     

    bool public isFeesOnNormalTransfers = true;
    uint256 public normalTransferFee = 1000;
    uint256 public totalSellFees = 1600;
    uint256 public liquidityFee = 100;
    uint256 public busdDividendFee = 175;
    uint256 public marketingFee = 50;
    uint256 public treasuryFee = 150;
    uint256 public rewardBuyerFee = 25;
    uint256 public totalBuyFees = liquidityFee + busdDividendFee + marketingFee + treasuryFee + rewardBuyerFee;

    uint256 public maxSellTransactionAmount = 50000 * 10**18;
    uint256 public swapTokensAtAmount = 2000 * 10 ** 18;

    mapping (address => bool) private isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) public blacklistFrom;
    mapping (address => bool) public blacklistTo;
    mapping (address => uint256) public nextSellTax;
    address[] private _markerPairs;
    mapping (address => uint256) public lpNukeBuildup;

    /** Nuke Config **/
    bool public lpNukeEnabled = true;
    uint256 public nukePercentPerSell = 2500;
    uint256 public nukePercentToBurn = 5000;
    uint256 public minNukeAmount = 1000 * 10**18;    
    uint256 public totalNuked;
    bool public autoNuke = true;

    /** Reward Biggest Buyer **/
    bool public isRewardBiggestBuyer = true;
    uint256 public biggestBuyerPeriod = 3600;
    uint256 public immutable launchTime = block.timestamp;
    uint256 public  totalBiggestBuyerPaid;
    mapping(uint256 => address) public biggestBuyer;
    mapping(uint256 => uint256) public biggestBuyerAmount;
    mapping(uint256 => uint256) public biggestBuyerPaid;

    /** Breaker Config **/
    bool public isBreakerEnable = true;
    bool public breakerOnSellOnly = false;
    int public taxBreakerCheck;
    uint256 public breakerPeriod = 3600; // 1 hour
    int public breakerPercent = 200; // activate at 2%
    uint256 public breakerBuyFee = 400;  // buy fee 4%
    uint256 public breakerSellFee = 2500; // sell fee 25%
    uint public circuitBreakerFlag;
    uint public circuitBreakerTime;
    uint private timeBreakerCheck;

    /** Auto Liquidity **/
    IAutoLiquidityTreasury public autoLiquidityTreasury;
    bool public autoLiquidityCall = true;

    receive() external payable {}
    constructor() ERC20("Libera.Financial", "LIBERA") Auth(msg.sender) {    
        //Biswap Router
        IDEXRouter _dexRouter = IDEXRouter(0x3a6d8cA21D1CF76F653A67577FA0D27453350dD8);
        
        address _dexPair = IDEXFactory(_dexRouter.factory()).createPair(address(this), dexToken);

        setDexRouter(address(_dexRouter), _dexPair, dexToken);

        excludeFromFees(address(this), true);
        excludeFromFees(owner, true);
        excludeFromFees(deadAddress,true);

        setMarketingWallet(0x770BdD792f6471EB28cBccD4F193BB26e8B5B07E);
        setTaxTreasury(0x4Dfa03c64ABd96359B77E7cCa8219B451C19f27E);
        
        setReserveTreasury(0xd01c6969C7Dc0B086f118bA3B4D926Da73acA2c7);        
        setNukeTreasury(0x5f791D180126871aE3174db38fcdd28800CcBd77);
        setBusdTreasury(0xa267AFb36DAb3C97082863431Aff7F88edbCaE29);
        setLiquidityParams(0xF0f14634971C43d872d1cF1785195C0Ce1000a9d,autoLiquidityCall,busdToken);

        _mint(msg.sender, MAX_SUPPLY);       
    }

   /***** Token Feature *****/
    function circulatingSupply() public view returns (uint256) {
        return totalSupply().sub(balanceOf(address(deadAddress))).sub(balanceOf(reserveTreasury));
    }

    function getPeriod() public view returns (uint256) {
        uint256 secondsSinceLaunch = block.timestamp - launchTime;
        return 1 + (secondsSinceLaunch / biggestBuyerPeriod);
    }

    function manualNukeLpTokens(address _lpAddress, uint256 _percent) external onlyOwner {
        require(automatedMarketMakerPairs[_lpAddress] == true, "Invalid lpAddress");
        require(_percent <= 1000, 'Cannot burn more than 10% dex balance');
        _nukeFromLp(_lpAddress, (balanceOf(_lpAddress) * _percent) / 10000);
    }
    function nukeLpTokenFromBuildup() external authorized {
        _nukeLpTokenFromBuildup();
    }
    function _nukeLpTokenFromBuildup() internal {
        if(lpNukeEnabled){
            for(uint i = 0; i < _markerPairs.length; i++){

                uint256 nukeAmount = lpNukeBuildup[_markerPairs[i]];

                if(nukeAmount > minNukeAmount){
                    uint256 maxBuildUp = balanceOf(_markerPairs[i]).mul(1000).div(10000);

                    if(nukeAmount > maxBuildUp){
                        nukeAmount = maxBuildUp;
                    }

                    _nukeFromLp(_markerPairs[i], nukeAmount);
                }
            }
        }
    }

    function _nukeFromLp(address lpAddress, uint256 amount) internal{

        if (amount>0) {
            lpNukeBuildup[lpAddress] = 0;
            totalNuked = totalNuked + amount;
            uint256 nukeToBurn = amount.mul(nukePercentToBurn).div(10000);
            if (nukeToBurn>0) {
                super._transfer(lpAddress, deadAddress, nukeToBurn);
            }
            if (amount > nukeToBurn) {
                super._transfer(lpAddress, address(nukeTreasury), amount - nukeToBurn);          
                nukeTreasury.updateRewards();
            }

            IDexPair pair = IDexPair(lpAddress);

            try pair.sync() {
                }
            catch Error (string memory reason) {
                    emit SyncLpErrorEvent(lpAddress, reason);
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
        //require(isExcludedFromFees[account] != _status, "Already excluded");
        isExcludedFromFees[account] = _status;
        emit ExcludeFromFees(account, _status);
    }

    function checkIsExcludedFromFees(address _account) external view returns (bool) {
        return(isExcludedFromFees[_account]);
    }   

    function setBotBlacklist(address account, bool _statusFrom, bool _statusTo) public onlyOwner {        
        //require(_isContract(account), "Only contract");
        require(account != address(dexRouter), "Not block dexRouter");
        require(account != dexPair, "Not block dexPair");      

        blacklistFrom[account] = _statusFrom;
        blacklistTo[account] = _statusTo;

        emit BotBlacklist(account, _statusFrom, _statusTo);
    }

    function setDexRouter(address _dexRouter, address _dexPair, address _dexToken) public onlyOwner {
        dexRouter = IDEXRouter(_dexRouter);
        dexPair = _dexPair;
        dexToken = _dexToken;

        setAutomatedMarketMakerPair(dexPair, true);

        _approve(address(this), address(dexRouter), 2**256 - 1);

        //approve for owner, not quite necessary
        approve(address(dexRouter), 2**256 - 1);        

        //liquidity making outside of contract, so this is not needed any more
        //IERC20(busdToken).approve(address(dexRouter), 2**256 - 1);
    }

    function setAutomatedMarketMakerPair(address _dexPair, bool _status) public authorized {
        automatedMarketMakerPairs[_dexPair] = _status;

        if(_status){
            _markerPairs.push(_dexPair);
        }else{
            require(_markerPairs.length >= 1, "Required 1 pair");
            require( _dexPair != dexPair, "Cannot remove dexPair");
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

    function setMaxSell(uint256 _amount) external onlyOwner {
        require(_amount >= 10**18,"Too small");
        maxSellTransactionAmount = _amount;
    }

    function setMarketingWallet(address _newAddress) public onlyOwner {
        excludeFromFees(_newAddress, true);
        marketingWallet = _newAddress;
    }

    function setTaxTreasury(address _newAddress) public onlyOwner {
        excludeFromFees(_newAddress, true);
        taxTreasury = _newAddress;
    }

    function setNukeTreasury(address _newAddress) public onlyOwner {
        excludeFromFees(_newAddress, true);
        nukeTreasury = ITreasury(_newAddress);
    }

    function setBusdTreasury(address _newAddress) public onlyOwner {
        excludeFromFees(_newAddress, true);
        busdTreasury = ITreasury(_newAddress);
    }

    function setReserveTreasury(address _newAddress) public onlyOwner {
        excludeFromFees(_newAddress, true);
        reserveTreasury = _newAddress;
    }

    function setSwapTokensAtAmount(uint256 _amount) external onlyOwner {
        swapTokensAtAmount = _amount;
    }

    function setIsNotMigrating(bool _status) external onlyOwner {
        require(isNotMigrating != _status, "Not changed");
        isNotMigrating = _status;
    }

    function setTokenFees(
        uint256 _liquidityFee,
        uint256 _busdDividendFee,
        uint256 _marketingFee,
        uint256 _treasuryFee,
        uint256 _rewardBuyerFee,
        uint256 _totalSellFees
    ) external onlyOwner {
        uint256 _totalBuyFees = _liquidityFee + _busdDividendFee + _marketingFee + _treasuryFee + _rewardBuyerFee;

        require(_totalBuyFees <= MAX_TAX, "Buy fee too high");
        require(_totalSellFees <= MAX_TAX, "Sell fee too high");

        liquidityFee = _liquidityFee;
        busdDividendFee = _busdDividendFee;
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

    function setLpNukeEnabled(bool _status, uint256 _percent, bool _auto, uint256 _minNukeAmount, uint256 _nukePercentToBurn) external onlyOwner {
        
        require(_percent <= 10000, '_percent Cannot be more than 100%');
        require(_nukePercentToBurn <= 10000, '_nukePercentToBurn Cannot be more than 100%');

        lpNukeEnabled = _status;
        autoNuke = _auto;
        nukePercentPerSell = _percent;
        nukePercentToBurn  = _nukePercentToBurn;
        minNukeAmount = _minNukeAmount;

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

    /***** Internal Functions *****/
    function _isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require((from != address(0)) && (to != address(0)), "zero address");

        bool excludedAccount = isExcludedFromFees[from] || isExcludedFromFees[to];

        require(isNotMigrating || excludedAccount, "Trading not started");
        require((!blacklistFrom[from] && !blacklistTo[to]) || excludedAccount , "Transfer failed");
        bool isSelling = automatedMarketMakerPairs[to];
        bool isBuying = automatedMarketMakerPairs[from];
        if (isSelling && !excludedAccount) {
            require(amount <= maxSellTransactionAmount, "Sell amount too big");
        }

        if (
            !isBuying && !excludedAccount && !swapping
        ) {
            
            uint256 contractTokenBalance = balanceOf(address(this));

            if (contractTokenBalance >= swapTokensAtAmount) {
                swapping = true;

                uint256 totalBnbFee = marketingFee.add(treasuryFee).add(rewardBuyerFee);

                if(totalBnbFee > 0){
                    uint256 swapTokens = contractTokenBalance.mul(totalBnbFee).div(totalBuyFees);

                    uint256 beforeAmount = address(this).balance;
                    _swapTokensForBNB(swapTokens, address(this));
                    uint256 increaseAmount = address(this).balance.sub(beforeAmount);

                    if(increaseAmount > 0){
                        uint256 marketingAmount = increaseAmount.mul(marketingFee).div(totalBnbFee);
                        uint256 treasuryAmount = increaseAmount.mul(treasuryFee).div(totalBnbFee);

                        if(marketingAmount > 0){
                            _transferBNBToWallet(payable(marketingWallet), marketingAmount);
                        }

                        if(treasuryAmount > 0){
                            _transferBNBToWallet(payable(taxTreasury), treasuryAmount);                            
                        }
                    }
                }

                if(liquidityFee > 0){
                    _swapAndLiquify(contractTokenBalance.mul(liquidityFee).div(totalBuyFees));
                }

                if(busdDividendFee > 0){
                    uint256 feeAmount = contractTokenBalance.mul(busdDividendFee).div(totalBuyFees);

                    _swapTokensForBusd(feeAmount, address(busdTreasury));
                    busdTreasury.updateRewards();
                }

                swapping = false;
            }

        }

        if(isBreakerEnable && (to == dexPair || from == dexPair) && !excludedAccount ){
            if (!breakerOnSellOnly) {
                _accuTaxSystem(amount,isBuying);
            } else if (to == dexPair) {
                _accuTaxSystem(amount,false);
            }
        }

        if(!swapping && !excludedAccount) {
            uint256 fees = amount.mul(totalBuyFees).div(10000);

            if(isSelling) {
                if(nextSellTax[from] > 0){
                    fees = amount.mul(nextSellTax[from]).div(10000);
                    nextSellTax[from] = 0;
                }else if(isBreakerEnable && circuitBreakerFlag == 2){
                    fees = amount.mul(breakerSellFee).div(10000);
                }else{
                    fees = amount.mul(totalSellFees).div(10000);
                }
            }else if(isBuying){
                if(isBreakerEnable && circuitBreakerFlag == 2){
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

            if(isBuying && !_isContract(to)){
                if (amount > biggestBuyerAmount[_periodAfterLaunch]) {
                    biggestBuyer[_periodAfterLaunch] = to;
                    biggestBuyerAmount[_periodAfterLaunch] = amount;
                }
            }

            _checkAndPayBiggestBuyer(_periodAfterLaunch);
        }

        if (lpNukeEnabled && isSelling && from != address(this) && !excludedAccount) {
            lpNukeBuildup[to] += amount.mul(nukePercentPerSell).div(10000);
        }
        if (autoNuke && !swapping && lpNukeEnabled && !isSelling && !isBuying){
            _nukeLpTokenFromBuildup();
        }

    }

    function _swapAndLiquify(uint256 contractTokenBalance) private {
            super._transfer(address(this),address(autoLiquidityTreasury), contractTokenBalance);
            if (autoLiquidityCall) {
                try autoLiquidityTreasury.autoLiquidify(address(this), liquidityToken, dexToken, address(dexRouter)) {
                    }
                catch Error (string memory reason) {
                        emit AutoLpErrorEvent(reason);
                }
            }
    }

    function _swapTokensForBNB(uint256 tokenAmount, address receiver) private {
        address[] memory path;
        if (dexToken != dexRouter.WETH()) {
            path = new address[](3);
            path[0] = address(this);
            path[1] = dexToken;
            path[2] = dexRouter.WETH();
        } else {
            path = new address[](2);
            path[0] = address(this);
            path[1] = dexRouter.WETH();
        }

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function _swapTokensForBusd(uint256 tokenAmount, address receiver) private {
        address[] memory path;
        
        if (dexToken == busdToken) {
            path = new address[](2);
            path[0] = address(this);
            path[1] = busdToken;
        } else {
            path = new address[](3);
            path[0] = address(this);
            path[1] = dexToken;
            path[2] = busdToken;
        }

        dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
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
                totalBiggestBuyerPaid = totalBiggestBuyerPaid + _rewardAmount; 
                biggestBuyerPaid[_prevPeriod] = _rewardAmount;

                emit PayBiggestBuyer(biggestBuyer[_prevPeriod], _prevPeriod, _rewardAmount);
            }
        }
    }

    function _deactivateCircuitBreaker() internal {
        // 1 is false, 2 is true
        circuitBreakerFlag = 1;
        taxBreakerCheck = 1;
        timeBreakerCheck = block.timestamp.sub(1);        
    }

    function _activateCircuitBreaker() internal {
        // 1 is false, 2 is true
        circuitBreakerFlag = 2;
        circuitBreakerTime = block.timestamp;
        emit CircuitBreakerActivated();
    }

    function setFeesOnBreaker(bool _isBreakerEnable, bool _breakerOnSellOnly, uint256 _breakerPeriod, int _breakerPercent, 
            uint256 _breakerBuyFee, uint256 _breakerSellFee) external onlyOwner {
        require(_breakerBuyFee <= MAX_TAX, "Buy fee too high");
        require(_breakerSellFee <= MAX_TAX, "Sell fee too high");

        isBreakerEnable = _isBreakerEnable;
        breakerOnSellOnly = _breakerOnSellOnly;
        //reset flag if isBreakerEnable disabled
        if (!isBreakerEnable) {
            _deactivateCircuitBreaker();
        }
        breakerPeriod = _breakerPeriod;
        breakerPercent = _breakerPercent;

        breakerBuyFee = _breakerBuyFee;
        breakerSellFee = _breakerSellFee;
    }

    function _accuTaxSystem(uint amount, bool isBuy) internal {
        uint r1 = balanceOf(dexPair);

        if (circuitBreakerFlag == 2) {
            if (circuitBreakerTime + breakerPeriod < block.timestamp) {
                _deactivateCircuitBreaker();
            }
        }

        int _taxBreakerCheck = taxBreakerCheck;
        uint _timeBreakerCheck = timeBreakerCheck;

        uint timeDiffGlobal = block.timestamp.sub(_timeBreakerCheck);
        int priceChange = int(_getPriceChange(r1, amount));
        if (isBuy) {
            priceChange = -priceChange;
        }
        if (timeDiffGlobal < breakerPeriod) {
                _taxBreakerCheck = _taxBreakerCheck + priceChange;          
        } else {
            _taxBreakerCheck = priceChange;
            _timeBreakerCheck = block.timestamp;
        }

        if (breakerPercent < _taxBreakerCheck) {
            _activateCircuitBreaker();
        }

        taxBreakerCheck = _taxBreakerCheck;
        timeBreakerCheck = _timeBreakerCheck;
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

    function setLiquidityParams(address _autoLiquidityTreasury, bool _autoLiquidityCall, address _liquidityToken) public onlyOwner  {
        excludeFromFees(_autoLiquidityTreasury,true);
        autoLiquidityTreasury = IAutoLiquidityTreasury(_autoLiquidityTreasury);
        autoLiquidityCall = _autoLiquidityCall;
        liquidityToken = _liquidityToken;
    }

    function retrieveTokens(address _token) external onlyOwner {
        //require(_token != address(this),"Cannot retrieve self-token");
        uint256 amount = IERC20(_token).balanceOf(address(this));

        require(IERC20(_token).transfer(msg.sender, amount), "Transfer failed");
    }

    function retrieveBNB() external onlyOwner {
        uint256 amount = address(this).balance;

        (bool success,) = payable(msg.sender).call{ value: amount }("");
        require(success, "Failed to retrieve BNB");
    }

    event CircuitBreakerActivated();
    event PayBiggestBuyer(address indexed account, uint256 indexed period, uint256 amount);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event BotBlacklist(address indexed account, bool isBlockedFrom, bool isBlockedTo);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SyncLpErrorEvent(address lpPair, string reason);
    event AutoLpErrorEvent(string reason);    

}