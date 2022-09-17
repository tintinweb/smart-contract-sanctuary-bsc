// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";

interface IDEXRouter {
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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface InterfaceLP {
    function sync() external;
}

error AddressZero();
error NotWhitellisted(address caller);
error NotRebaseAdmin(address caller);
error TradingHasntStarted();
error SandRNotAllowedToTrade(address sender, address recipient);
error Amount_Greater_Then_MaxSell(uint256 amount);
error Amount_Greater_Then_Setpercent(uint256 amount);
error inSwap_or_NextRebase_NeedTime(uint256 nextRebase);
error ValueAlreadySet();
error Value_Greaterthen_Max();
error TotalBuyFee_Greaterthen_FeeDenomiatorbyFour();
error RequiredOnePair();
error Cant_SellMoreThen_OnePercent_ADay(uint256 totalAmount);

contract Waypay is ERC20{

    //Events 
    event SwapBack(uint256 contractTokenBalance,uint256 amountToLiquify,uint256 amountToRFV,uint256 amountToTreasury);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SwapAndLiquifyBusd(uint256 tokensSwapped, uint256 busdReceived, uint256 tokensIntoLiqudity);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    bool private initialDistributionFinished = false;
    bool private swapEnabled = true;
    bool private autoRebase = false;
    bool private feesOnNormalTransfers = false;
    bool private isLiquidityInBnb = true;

    // can be in struct
    uint256 private rewardYield = 1458334;
    uint256 private rewardYieldDenominator = 10000000000;
    uint256 public maxSellTransactionAmount = 1000000 * 10 ** 18;

    // This can be used directly
    // 604800 ---> 7days
    uint256 public rebaseFrequency = 1800;
    uint256 public nextRebase = block.timestamp + 1800;

    mapping(address => bool) private _isFeeExempt;
    mapping(address => bool) private _isWhiteListedUser;
    mapping(address => bool) private _isRebaseAdmin;
    address[] public _markerPairs;
    mapping (address => bool) public automatedMarketMakerPairs;

    uint256 public constant MAX_FEE_RATE = 20;
    uint256 private constant MAX_REBASE_FREQUENCY = 86400;
    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 10 * 10**9 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = ~uint128(0);

    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    address public liquidityReceiver        = 0x7b0c59bBcAC97DD3A72c5416D23605dA8d7E3DfD;
    address public treasuryReceiver         = 0xF5eB2e4CCDD8B03860624CCb4e6ae0Da04b2acC6;
    address public WaypayInsuranceFund      = 0x13c46b104000fab7D17554d996C1ce9630fcd84E;
   // address public busdToken                = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant busdTokenTest            = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public burnPot                  = 0x2131C154D21efd19DdC30C30F2D70F8c7095A187;
    address public constant NFT                      = 0x7a8CC69A2C0277663258Dd00D093D119dbe5B890;
    address public constant mainWallet               = 0xF5D0058C6ad1fDEA21f72e5dAF3449a6297BDa85;

    IDEXRouter private router;
    address private pair;

    uint256 public  liquidityFee = 4; // 0.5% will go into NFT 0.5% to case 0.5% to burnPot and 0.5% to liquidity
    uint256 public treasuryFee = 4;
    uint256 public buyFeeRFV = 4;
    uint256 public sellFeeTreasuryAdded = 1;
    uint256 public sellFeeRFVAdded = 1;
    uint256 private totalBuyFee = liquidityFee + treasuryFee + buyFeeRFV;
    uint256 private totalSellFee = totalBuyFee + sellFeeTreasuryAdded + sellFeeRFVAdded;
    uint256 public totalP2PFee = 80;
    uint256 public feeDenominator = 100;

    uint256 private targetLiquidity = 50;
    uint256 private targetLiquidityDenominator = 100;

    bool private inSwap;
    uint256 public SellLimit = 1;

    uint256 private constant MAX_INT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    struct user {
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }

    mapping(address => user) public tradeData;
    
    modifier validRecipient(address to) {
        if (to == address(0x0)){
            revert AddressZero();
        }
        _;
    }

    modifier onlyWhitelisted() {
        if(!_isWhiteListedUser[msg.sender]){
            revert NotWhitellisted(msg.sender);
        }
        _;
    }

    modifier onlyRebaseAdmin() {
        if(!_isRebaseAdmin[msg.sender]){
            revert NotRebaseAdmin(msg.sender);
        }
        _;
    }
    uint256 private _totalSupply;

    uint256 private gonSwapThreshold = TOTAL_GONS  / 10000;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    constructor() ERC20("Waypay", "Waypay"){

        // router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());
        // address pairBusd = IDEXFactory(router.factory()).createPair(address(this), busdTokenTest);

        // _allowedFragments[address(this)][address(router)] = uint256(MAX_INT);
        // _allowedFragments[address(this)][pair] = uint256(MAX_INT);
        // _allowedFragments[address(this)][address(this)] = uint256(MAX_INT);
        // _allowedFragments[address(this)][pairBusd] = uint256(MAX_INT);

        // automatedMarketMakerPairs[pair] = true;
        // automatedMarketMakerPairs[pairBusd] =  true;

        // _isWhiteListedUser[pair] = true;
        // _isWhiteListedUser[pairBusd] = true;

        //  _transferOwnership(_msgSender());

        // Roles
        _isWhiteListedUser[msg.sender] = true;
        _isRebaseAdmin[msg.sender] = true;

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;

        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[WaypayInsuranceFund] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[msg.sender] = true;


        // IERC20(busdTokenTest).approve(address(router), uint256(MAX_INT));
        // IERC20(busdTokenTest).approve(address(pairBusd), uint256(MAX_INT));
        // IERC20(busdTokenTest).approve(address(this), uint256(MAX_INT));

        emit Transfer(address(0x0), msg.sender, _totalSupply);

    }

    receive() external payable {}

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _gonBalances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowedFragments[owner][spender];
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function checkWhiteListedUser(address _addr) external view returns (bool) {
        return _isWhiteListedUser[_addr];
    }
    function cheackRebaseAdmin(address _addr) external view returns (bool) {
        return _isRebaseAdmin[_addr];
    }

    function checkSwapThreshold() external view returns (uint256) {
        // return (gonSwapThreshold /_gonsPerFragment);
        return (gonSwapThreshold);
    }

    function shouldRebase() internal view returns (bool) {
        return nextRebase <= block.timestamp;
    }

    // function isWhitelisted(address account) public virtual  view returns (bool) {
    //     return hasRole(White_Listed_User, account);
    // }
    // function isRebaseAdmin(address account) public virtual  view returns (bool) {
    //     return hasRole(Rebase_Admin, account);
    // }

    // function _addWhitelisted(address account) public virtual onlyWhitelisted {
    //     grantRole(White_Listed_User, account);
    // }

    // function _removeWhitelisted(address account) public virtual onlyWhitelisted {
    //     revokeRole(White_Listed_User, account);
    // }

    // function addRebaseAdmin(address account) public  virtual onlyRebaseAdmin {
    //     grantRole(Rebase_Admin, account);
    // }

    // function removeRebaseAdmin(address account) public virtual onlyRebaseAdmin {
    //     revokeRole(Rebase_Admin, account);
    // }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        if(_isFeeExempt[from] || _isFeeExempt[to]){
            return false;
        }else if (feesOnNormalTransfers){
            return true;
        }else{
            return (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]);
        }
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        !automatedMarketMakerPairs[msg.sender] &&
        !inSwap &&
        swapEnabled &&
        (totalBuyFee + totalSellFee) > 0 &&
        _gonBalances[address(this)] >= gonSwapThreshold;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return ((TOTAL_GONS -_gonBalances[DEAD]) - _gonBalances[address(0)]);
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256){
        uint256 liquidityBalance = 0;
        for(uint i = 0; i < _markerPairs.length; i++){
            liquidityBalance + (balanceOf(_markerPairs[i]) / (10 ** 9));
        }
        return accuracy * (liquidityBalance * (2)) / (getCirculatingSupply() / (10 ** 9));
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool){
        return getLiquidityBacking(accuracy) > target;
    }

    function manualSync() public {
        for(uint i = 0; i < _markerPairs.length; i++){
            InterfaceLP(_markerPairs[i]).sync();
        }
    }

    function transfer(address to, uint256 value) public virtual override validRecipient(to) returns (bool){
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        // uint256 gonAmount = amount * _gonsPerFragment;
        _gonBalances[from] = _gonBalances[from]-(amount);
        _gonBalances[to] = _gonBalances[to] + (amount);

        emit Transfer(from, to, amount);

        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];
        if(!(initialDistributionFinished || excludedAccount)){
            revert TradingHasntStarted();
        }
        if(!(_isWhiteListedUser[sender] || _isWhiteListedUser[recipient])){
            revert SandRNotAllowedToTrade(sender, recipient);
        }
        // if(_isWhiteListedUser[sender] && !automatedMarketMakerPairs[recipient]){
        //     revert("can't do P2p");
        // }
        
        if (
            automatedMarketMakerPairs[recipient] &&
            !excludedAccount
        ) {
            if(amount > maxSellTransactionAmount){
                revert Amount_Greater_Then_MaxSell(amount);
            }

            uint blkTime = block.timestamp;
          
            uint256 onePercent = balanceOf(sender) * (SellLimit) / (100); //Should use variable
            if(amount > onePercent){
                revert Amount_Greater_Then_Setpercent(amount);
            }
            
            if( blkTime > tradeData[sender].lastTradeTime + 86400) {
                tradeData[sender].lastTradeTime = blkTime;
                tradeData[sender].tradeAmount = amount;
            }
            else if( (blkTime < tradeData[sender].lastTradeTime + 86400) && (( blkTime > tradeData[sender].lastTradeTime)) ){
                if(tradeData[sender].tradeAmount + amount > onePercent){
                    revert Cant_SellMoreThen_OnePercent_ADay(tradeData[sender].tradeAmount + amount );
                }
                tradeData[sender].tradeAmount = tradeData[sender].tradeAmount + amount;
            }
        } 

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        // uint256 gonAmount = amount * (_gonsPerFragment);

        if (shouldSwapBack()) {
            swapBack();
        }

        _gonBalances[sender] = _gonBalances[sender] - (amount);

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _gonBalances[recipient] = _gonBalances[recipient] + (gonAmountReceived);

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived 
        );

        if(shouldRebase() && autoRebase) {
            _rebase();

            if(!automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient]){
                manualSync();
            }
        }

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(MAX_INT)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender] - (value);
        }

        _transferFrom(from, to, value);
        return true;
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance / (2);
        uint256 otherHalf = contractTokenBalance - (half);

        if(isLiquidityInBnb){
            uint256 initialBalance = address(this).balance;

            _swapTokensForBNB(half, address(this));

            uint256 newBalance = address(this).balance - (initialBalance);

            _addLiquidity(otherHalf, newBalance);

            emit SwapAndLiquify(half, newBalance, otherHalf);
        }else{
            uint256 initialBalance = IERC20(busdTokenTest).balanceOf(address(this));

            _swapTokensForBusd(half, address(this));

            uint256 newBalance = IERC20(busdTokenTest).balanceOf(address(this)) - (initialBalance);

            _addLiquidityBusd(otherHalf, newBalance);

            emit SwapAndLiquifyBusd(half, newBalance, otherHalf);
        }
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityReceiver,
            block.timestamp
        );
    }

    function _addLiquidityBusd(uint256 tokenAmount, uint256 busdAmount) private {
        router.addLiquidity(
            address(this),
            busdTokenTest,
            tokenAmount,
            busdAmount,
            0,
            0,
            liquidityReceiver,
            block.timestamp
        );
    }

    function _swapTokensForBNB(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function _swapTokensForBusd(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = busdTokenTest;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function swapBack() internal swapping {
        uint256 realTotalFee = totalBuyFee + (totalSellFee); //29

        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee; //2
        uint256 contractTokenBalance = _gonBalances[address(this)] ; //1000

        uint256 amountToLiquify = contractTokenBalance * (dynamicLiquidityFee * (2)) / (realTotalFee); //(2/29)*1000 69
        uint256 amountToRFV = contractTokenBalance * (buyFeeRFV * (2) + (sellFeeRFVAdded)) / (realTotalFee); //500
        uint256 amountToTreasury = contractTokenBalance - (amountToLiquify) - (amountToRFV); // 347

        if(amountToLiquify > 0){
            uint256 quarter = amountToLiquify / (4);
            _swapTokensForBNB(quarter, burnPot);
            _swapTokensForBNB(quarter, NFT);
            _swapTokensForBNB(quarter, mainWallet);

            _swapAndLiquify(amountToLiquify - (quarter * (3)));
        }

        if(amountToRFV > 0){
            _swapTokensForBusd(amountToRFV, WaypayInsuranceFund);
        }

        if(amountToTreasury > 0){
            _swapTokensForBNB(amountToTreasury, treasuryReceiver);
        }

        emit SwapBack(contractTokenBalance, amountToLiquify, amountToRFV, amountToTreasury);
    }

    function takeFee(address sender, address recipient, uint256 gonAmount) internal returns (uint256){
        uint256 _realFee = totalBuyFee;
        if(automatedMarketMakerPairs[recipient]) {_realFee = totalSellFee;}
        if(!automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient])
        {
            _realFee = totalP2PFee;
        }

        uint256 feeAmount = gonAmount * (_realFee) / (feeDenominator);

        _gonBalances[address(this)] = _gonBalances[address(this)] + (feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return gonAmount - (feeAmount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual override returns (bool){
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue -(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool){
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
        spender
        ] + (addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value) public virtual override returns (bool){
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function _rebase() private {
        if(!inSwap) {
            uint256 circulatingSupply = getCirculatingSupply();
            int256 supplyDelta = int256(circulatingSupply * (rewardYield) / (rewardYieldDenominator));

            coreRebase(supplyDelta);
        }
    }

     function coreRebase(int256 supplyDelta) private returns (uint256) {
        uint256 epoch = block.timestamp;

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply - (uint256(-supplyDelta));
        } else {
            _totalSupply = _totalSupply + (uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        // _gonsPerFragment = TOTAL_GONS / (_totalSupply);

        nextRebase = epoch + rebaseFrequency;

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function manualRebase() external onlyRebaseAdmin{

        if(inSwap || (nextRebase > block.timestamp)){
            revert inSwap_or_NextRebase_NeedTime(nextRebase);
        }

        uint256 circulatingSupply = getCirculatingSupply();
        int256 supplyDelta = int256(circulatingSupply * (rewardYield) / (rewardYieldDenominator));

        coreRebase(supplyDelta);
        manualSync();
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyWhitelisted {
        if(automatedMarketMakerPairs[_pair] == _value){
            revert ValueAlreadySet();
        }

        automatedMarketMakerPairs[_pair] = _value;
        

        if(_value){
            _markerPairs.push(_pair);
        }else{
            if(_markerPairs.length <= 1){
                revert RequiredOnePair();
            }
            for (uint256 i = 0; i < _markerPairs.length; i++) {
                if (_markerPairs[i] == _pair) {
                    _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                    _markerPairs.pop();
                    break;
                }
            }
        }

        emit SetAutomatedMarketMakerPair(_pair, _value);
    }

    function setInitialDistributionFinished(bool _value) external onlyWhitelisted {
        initialDistributionFinished = _value;
    }

    function setFeeExempt(address _addr, bool _value) external onlyWhitelisted {
        _isFeeExempt[_addr] = _value;
    }

    function setWhiteListedUser(address _addr, bool _value) public onlyWhitelisted {
        _isWhiteListedUser[_addr] = _value;
    }

     function setRebaseAdmin(address _addr, bool _value) public onlyWhitelisted {
        _isRebaseAdmin[_addr] = _value;
    }


    function setSellLimit(uint _addr) external onlyWhitelisted {
        SellLimit = _addr;
    }

    function setTargetLiquidity(uint256 target, uint256 accuracy) external onlyWhitelisted {
        targetLiquidity = target;
        targetLiquidityDenominator = accuracy;
    }

    function setSwapBackSettings(bool _enabled, uint256 _num, uint256 _denom) external onlyWhitelisted {
        swapEnabled = _enabled;
        gonSwapThreshold = TOTAL_GONS / (_denom) * (_num);
    }

    function setFeeReceivers(address _liquidityReceiver, address _treasuryReceiver, address _waypayInsuranceFund, address _burnPot) external onlyWhitelisted {
        liquidityReceiver = _liquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        WaypayInsuranceFund = _waypayInsuranceFund;
        burnPot = _burnPot;
    }

    function setFees(uint256 _liquidityFee, uint256 _riskFreeValue, uint256 _treasuryFee, uint256 _sellFeeTreasuryAdded, uint256 _sellFeeRFVAdded, uint256 _feeDenominator) external onlyWhitelisted {

        if(_liquidityFee > MAX_FEE_RATE && _riskFreeValue > MAX_FEE_RATE && _treasuryFee > MAX_FEE_RATE && _sellFeeTreasuryAdded > MAX_FEE_RATE && _sellFeeRFVAdded > MAX_FEE_RATE){
            revert Value_Greaterthen_Max(); 
        }

        liquidityFee = _liquidityFee;
        buyFeeRFV = _riskFreeValue;
        treasuryFee = _treasuryFee;
        sellFeeTreasuryAdded = _sellFeeTreasuryAdded;
        sellFeeRFVAdded = _sellFeeRFVAdded;
        totalBuyFee = liquidityFee + (treasuryFee) + (buyFeeRFV);
        totalSellFee = totalBuyFee + (sellFeeTreasuryAdded) + (sellFeeRFVAdded);
        feeDenominator = _feeDenominator;
        if(totalBuyFee >= feeDenominator / 4){
            revert TotalBuyFee_Greaterthen_FeeDenomiatorbyFour();
        }
    }

    function clearStuckBalance(address _receiver) external onlyWhitelisted {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address tokenAddress, uint256 tokens) external onlyWhitelisted returns (bool success){
        return ERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function setAutoRebase(bool _autoRebase) external onlyWhitelisted {
        autoRebase = _autoRebase;
    }

    function setRebaseFrequency(uint256 _rebaseFrequency) external onlyWhitelisted {
        if(_rebaseFrequency > MAX_REBASE_FREQUENCY){
            revert Value_Greaterthen_Max();
        }
        rebaseFrequency = _rebaseFrequency;
    }

    function setRewardYield(uint256 _rewardYield, uint256 _rewardYieldDenominator) external onlyWhitelisted {
        rewardYield = _rewardYield;
        rewardYieldDenominator = _rewardYieldDenominator;
    }

    function setFeesOnNormalTransfers(bool _enabled) external onlyWhitelisted {
        feesOnNormalTransfers = _enabled;
    }

    function setIsLiquidityInBnb(bool _value) external onlyWhitelisted {
        isLiquidityInBnb = _value;
    }

    function setNextRebase(uint256 _nextRebase) external onlyWhitelisted {
        nextRebase = _nextRebase;
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyWhitelisted {
        maxSellTransactionAmount = _maxTxn;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}