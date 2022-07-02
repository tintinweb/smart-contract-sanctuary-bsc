/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// YieldTopia Finance
// https://yieldtopia.finance

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface InterfaceLP {
    function sync() external;
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals
    ) {
        _name = _tokenName;
        _symbol = _tokenSymbol;
        _decimals = _tokenDecimals;
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
}

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

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
     require(newOwner != address(0), "Ownable: new owner is the zero address");
     emit OwnershipTransferred(_owner, newOwner);
     _owner = newOwner;
    }
}

contract WhitelistedRole is Ownable {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyOwner {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyOwner {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

contract YieldTopia is ERC20Detailed, Ownable, WhitelistedRole {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    // Yield Protocol Settings
    uint256 private constant MAX_REBASE_FREQUENCY = 1800;
    uint256 public rewardYield = 3830800; // APY: 42,069% && DPY: 1.6%
    uint256 public rewardYieldDenominator = 10000000000;
    uint256 public maxSellTransactionAmount = 2500000 * 10 ** 18; 
    uint256 public rebaseFrequency = 1800;
    uint256 public nextRebase = 1657870200; 
    uint256 public nexthalving = 1657870200 + 2629743; // one month after the approximate launch date & first rebate
    bool public autoRebase = true;

    // $YIELD Token Settings
    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 10 * 10**9 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = ~uint128(0);
    bool public liquifyAll = false;

    // Default Buy Tax Fees = 9%
    uint256 public buyliquidityFee = 2; // $YIELD Liquidity Pool Growth
    uint256 public buyreserveFee = 3; // Insurance: Reserve fee aka insurance fund to make buy-backs with as needed
    uint256 public buytreasuryFee = 3; // Treasury: Marketing & Development [community involvment via GOV]
    uint256 public buyfirepitfee = 1; // Firepit: Used to burn $YIELD tokens out of the supply
    uint256 public totalBuyFee = buyliquidityFee.add(buyreserveFee).add(buytreasuryFee).add(buyfirepitfee);

    // Default Sell Tax Fees = 13%
    uint256 public sellliquidityFee = 3; // $YIELD Liquidity Pool Growth
    uint256 public sellreserveFee = 5; // Insurance: Reserve fee aka insurance fund to make buy-backs with as needed
    uint256 public selltreasuryFee = 4; // Treasury: Marketing & Development [community involvment via GOV]
    uint256 public sellfirepitfee = 1; // Firepit: Used to burn $YIELD tokens out of the supply
    uint256 public totalSellFee = sellliquidityFee.add(sellreserveFee).add(selltreasuryFee).add(sellfirepitfee);

    // Default Referral Settings
    uint256 public referee = 1; // $YIELD Liquidity Pool Growth
    uint256 public referrer = 1; // Insurance: Reserve fee aka insurance fund to make buy-backs with as needed
    uint256 public totalReferralFee = referee.add(referrer);

    // Transaction Tax Fees Settings
    bool public feesOnNormalTransfers = true;
    mapping(address => bool) _isFeeExempt;
    uint256 public constant MAX_FEE_RATE = 20;
    uint256 public feeDenominator = 100;
    uint256 public transferTax = 100; // No transfers in between wallets

    // Default Fee Receivers Settings
    address public yieldtopiatreasuryReceiver = 0xdd7d29eb51Dd00eAc9e445F7D6f52b654fC235F0;
    address public yieldrewardreservesReceiver = 0xF0B821A558246aFCa77140B8746354Efac65368C;
    address public yieldliquidityReceiver = 0x5f045F69C73322cDC49b50d6Aa5BB5d783302E8e;
    address public yieldfirepit = 0x8421d1560140ad03449df4A66338a7b26Aa380C5;
    address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address DEADWalletAddress = 0x000000000000000000000000000000000000dEaD;
    address ZEROWalletAddress = 0x0000000000000000000000000000000000000000;

    // Referral System
    mapping(address => address) public downlineLookupUpline;
	mapping(address => address[]) public Downlines;
    mapping(address => uint256) public referralTotalFeeReceived;
    mapping(address => uint256) public referralCount;
    mapping(uint256 => address) public uplineList;
    uint256 public iTotalUplines = 0;
    
    function getTotalUpline() public view returns (uint256) {
        return iTotalUplines;
    }

    function getUplineAddressByIndex(uint256 iIndex) public view returns (address){
        return uplineList[iIndex];
    } 

    function addMember(address uplineAddress, address downlineAddress) external onlyOwner{
        downlineLookupUpline[downlineAddress] = uplineAddress;
    }

    function approveReferral(address uplineAddress) external {
        require(downlineLookupUpline[msg.sender] == address(0), "You have already been referred");
        require(msg.sender != uplineAddress, "You cannot refer yourself");
        downlineLookupUpline[msg.sender] = uplineAddress;
		Downlines[uplineAddress].push(msg.sender);
        
        if(referralCount[uplineAddress] == 0)
        {
            uplineList[iTotalUplines] = uplineAddress;
            iTotalUplines += 1;
        }

        referralCount[uplineAddress] += 1;
    }
    
    function getUpline(address sender) public view returns (address){
        return downlineLookupUpline[sender];
    }

    function getDownlines(address sender) public view returns (address  [] memory){
        return Downlines[sender];
    }
	
    function addReferralFee(address receiver, uint256 amount) public {
        referralTotalFeeReceived[receiver] += amount;
    }

    function getReferralTotalFee(address receiver) public view returns (uint256){
        return referralTotalFeeReceived[receiver];
    }



    // $YIELD LP Settings
    bool public isLiquidityInBnb = true;
    address[] public _markerPairs;
    mapping (address => bool) public automatedMarketMakerPairs;
    uint256 targetLiquidity = 50;
    uint256 targetLiquidityDenominator = 100;
    IDEXRouter public router;
    address public pair;
    bool inSwap;
    uint256 public txfee = 1;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    struct user {
        uint256 firstBuy;
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }

    uint256 public TwentyFourhours = 86400;

    mapping(address => user) public tradeData;
    
    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 private gonSwapThreshold = TOTAL_GONS / 10000;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    constructor() ERC20Detailed("YieldTopia", "YIELD", uint8(DECIMALS)) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());
        address pairBusd = IDEXFactory(router.factory()).createPair(address(this), busdToken);

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        _allowedFragments[address(this)][pair] = uint256(-1);
        _allowedFragments[address(this)][address(this)] = uint256(-1);
        _allowedFragments[address(this)][pairBusd] = uint256(-1);

        setAutomatedMarketMakerPair(pair, true);
        setAutomatedMarketMakerPair(pairBusd, true);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _isFeeExempt[yieldtopiatreasuryReceiver] = true;
        _isFeeExempt[yieldrewardreservesReceiver] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[msg.sender] = true;

        IERC20(busdToken).approve(address(router), uint256(-1));
        IERC20(busdToken).approve(address(pairBusd), uint256(-1));
        IERC20(busdToken).approve(address(this), uint256(-1));

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyWhitelisted {
        require(isContract(_botAddress), "Only contract address, not allowed externally owned account");
        blacklist[_botAddress] = _flag;    
    }
    
    function noDecimaltotalSupply() external view returns (uint256) {
        return _totalSupply.div(10**DECIMALS);
    }

    function nodecimalCirculatingSUpply() external view returns (uint256) {
        return getCirculatingSupply().div(10**DECIMALS);
    }

    function allowance(address owner_, address spender) external view override returns (uint256){
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function checkSwapThreshold() external view returns (uint256) {
        return gonSwapThreshold.div(_gonsPerFragment);
    }

    function shouldRebase() internal view returns (bool) {
        return nextRebase <= block.timestamp;
    }

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
        totalBuyFee.add(totalSellFee) > 0 &&
        _gonBalances[address(this)] >= gonSwapThreshold;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_GONS.sub(_gonBalances[DEADWalletAddress]).sub(_gonBalances[ZEROWalletAddress])).div(_gonsPerFragment);
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256){
        uint256 liquidityBalance = 0;
        for(uint i = 0; i < _markerPairs.length; i++){
            liquidityBalance.add(balanceOf(_markerPairs[i]).div(10 ** 9));
        }
        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply().div(10 ** 9));
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool){
        return getLiquidityBacking(accuracy) > target;
    }

    function manualSync() public {
        for(uint i = 0; i < _markerPairs.length; i++){
            InterfaceLP(_markerPairs[i]).sync();
        }
    }

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool){
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);

        emit Transfer(from, to, amount);

        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");
        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];
        if (
            automatedMarketMakerPairs[recipient] &&
            !excludedAccount
        ) {
            require(amount <= maxSellTransactionAmount, "Error amount");

            uint blkTime = block.timestamp;
          
            uint256 onePercent = balanceOf(sender).mul(txfee).div(100); 
            require(amount <= onePercent, "ERR: Can't sell more than set 1%-20%");

            if( blkTime >= tradeData[sender].lastTradeTime + TwentyFourhours) {
                tradeData[sender].lastTradeTime = blkTime;
                tradeData[sender].tradeAmount = amount;
            }
            else if( (blkTime <= tradeData[sender].lastTradeTime + TwentyFourhours) && (( blkTime >= tradeData[sender].lastTradeTime)) ){
                require(tradeData[sender].tradeAmount + amount <= onePercent, "ERR: Can't sell more than set 1%-20% in One day");
                tradeData[sender].tradeAmount = tradeData[sender].tradeAmount + amount;
            }
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);

        if (shouldSwapBack()) {
            swapBack();
        }

        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, gonAmount) : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );

        if(shouldRebase() && autoRebase) {
            _rebase();

            if(!automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient]){
                manualSync();
            }
        }

        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
            msg.sender
            ].sub(value, "Insufficient Allowance");
        }

        _transferFrom(from, to, value);
        return true;
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        if(isLiquidityInBnb){
            uint256 initialBalance = address(this).balance;

            _swapTokensForBNB(half, address(this));

            uint256 newBalance = address(this).balance.sub(initialBalance);

            _addLiquidity(otherHalf, newBalance);

            emit SwapAndLiquify(half, newBalance, otherHalf);
        }else{
            uint256 initialBalance = IERC20(busdToken).balanceOf(address(this));

            _swapTokensForBusd(half, address(this));

            uint256 newBalance = IERC20(busdToken).balanceOf(address(this)).sub(initialBalance);

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
            yieldliquidityReceiver,
            block.timestamp
        );
    }

    function _addLiquidityBusd(uint256 tokenAmount, uint256 busdAmount) private {
        router.addLiquidity(
            address(this),
            busdToken,
            tokenAmount,
            busdAmount,
            0,
            0,
            yieldliquidityReceiver,
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
        path[2] = busdToken;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function swapBack() internal swapping {
        uint256 realTotalFee = totalBuyFee.add(totalSellFee);

        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : buyliquidityFee;
        uint256 contractTokenBalance = _gonBalances[address(this)].div(_gonsPerFragment);

        if(!liquifyAll && contractTokenBalance > gonSwapThreshold.div(_gonsPerFragment)){
        	contractTokenBalance = gonSwapThreshold.div(_gonsPerFragment);
        }

        uint256 amountToLiquify = contractTokenBalance.mul(dynamicLiquidityFee.mul(2)).div(realTotalFee);
        uint256 amountToReserve = contractTokenBalance.mul(buyreserveFee.add(sellreserveFee)).div(realTotalFee);
        uint256 amountToFirepit = contractTokenBalance.mul(buyfirepitfee.add(sellfirepitfee)).div(realTotalFee);
        uint256 amountToTreasury = contractTokenBalance.sub(amountToLiquify).sub(amountToReserve).sub(amountToFirepit);

    
        if(amountToLiquify > 0){
            _swapAndLiquify(amountToLiquify);
        }

        if(amountToReserve > 0){
            _swapTokensForBusd(amountToReserve, yieldrewardreservesReceiver);
        }

        if(amountToTreasury > 0){
            _swapTokensForBNB(amountToTreasury, yieldtopiatreasuryReceiver);
        }

         if(amountToFirepit > 0){
            _swapTokensForBNB(amountToFirepit, yieldfirepit);
        }

        emit SwapBack(contractTokenBalance, amountToLiquify, amountToReserve, amountToTreasury, amountToFirepit);
    }
 
    function takeFee(address sender, address recipient, uint256 gonAmount) internal returns (uint256){
        uint256 _realFee = totalBuyFee;
        uint256 _buytreasuryFee = buytreasuryFee;
        uint256 _selltreasuryFee = selltreasuryFee;

        if(automatedMarketMakerPairs[recipient]) _realFee = totalSellFee;

        uint256 feeAmount = gonAmount.mul(_realFee).div(feeDenominator);

        if(!automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient]) {
			require(transferTax <= 99, "Wallet to wallet transfer disabled");
			feeAmount = gonAmount.mul(transferTax).div(100);			
        }

        // referrals
        if (automatedMarketMakerPairs[sender]) {
            address UplineAddressBuyer = getUpline(recipient);
            if (UplineAddressBuyer != address(0))
            {      
                _buytreasuryFee -= totalReferralFee;
                uint256 _uplineBuyerReward = gonAmount.div(feeDenominator).mul(referrer);
                feeAmount = gonAmount.div(feeDenominator).mul(_realFee - referee);
                _gonBalances[UplineAddressBuyer] = _gonBalances[UplineAddressBuyer].add(
                _uplineBuyerReward
                );
                addReferralFee(UplineAddressBuyer, _uplineBuyerReward.div(_gonsPerFragment) );  
            }      
        }
        else if (automatedMarketMakerPairs[recipient]) {
            address UplineAddress = getUpline(sender);

            if (UplineAddress != address(0))
            {
                _selltreasuryFee -= totalReferralFee;
                uint256 _uplineReward = gonAmount.div(feeDenominator).mul(referrer);
                feeAmount = gonAmount.div(feeDenominator).mul(_realFee - referee);
                _gonBalances[UplineAddress] = _gonBalances[UplineAddress].add(
                    _uplineReward
                );
                addReferralFee(UplineAddress, _uplineReward.div(_gonsPerFragment) );
            }    
        }

        _gonBalances[address(this)] = _gonBalances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));

        return gonAmount.sub(feeAmount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool){
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
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

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool){
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
        spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool){
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function _rebase() private {
        if(!inSwap) {
            uint256 circulatingSupply = getCirculatingSupply();
            int256 supplyDelta = int256(circulatingSupply.mul(rewardYield).div(rewardYieldDenominator));

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
            _totalSupply = _totalSupply.sub(uint256(-supplyDelta));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }
        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        if (block.timestamp >= nexthalving) {
            rewardYield = rewardYield.div(10).mul(9);
            nexthalving = block.timestamp + 2629743;
        }
        
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        nextRebase = epoch + rebaseFrequency;
        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function manualRebase() external onlyWhitelisted{
        require(!inSwap, "Try again");
        require(nextRebase <= block.timestamp, "Not in time");

        uint256 circulatingSupply = getCirculatingSupply();
        int256 supplyDelta = int256(circulatingSupply.mul(rewardYield).div(rewardYieldDenominator));

        coreRebase(supplyDelta);
        manualSync();
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
        require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

        automatedMarketMakerPairs[_pair] = _value;

        if(_value){
            _markerPairs.push(_pair);
        }else{
            require(_markerPairs.length > 1, "Required 1 pair");
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
 
    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        require(_isFeeExempt[_addr] != _value, "Not changed");
        _isFeeExempt[_addr] = _value;
    }

    function setTxFee(uint _addr) external onlyOwner {
        txfee = _addr;
    }

    function setTransferTax(uint256 _transferTAX) external onlyOwner {
        transferTax = _transferTAX;
    }

    function setTwentyFourhours(uint256 _time) external onlyOwner {
        TwentyFourhours = _time;
    }

    function setTargetLiquidity(uint256 target, uint256 accuracy) external onlyOwner {
        targetLiquidity = target;
        targetLiquidityDenominator = accuracy;
    }
 

    function setSwapBackSettings_liquifyAll(bool _enabled) external onlyOwner {
        liquifyAll = _enabled;
    }

    // Set Wallet & Contract Addresses To Receieve Transaction Tax Fees
    function setFeeReceivers(address _yieldliquidityReceiver, address _yieldtopiatreasuryReceiver, address _yieldrewardreservesReceiver, address _yieldfirepit) external onlyOwner {
        yieldliquidityReceiver = _yieldliquidityReceiver;
        yieldtopiatreasuryReceiver = _yieldtopiatreasuryReceiver;
        yieldrewardreservesReceiver = _yieldrewardreservesReceiver;
        yieldfirepit = _yieldfirepit;
    }


    // Set Stablecoin (default: BUSD, optional to switch to USDY or other stablecoin in the future)
    function setStableCoin(address _stablecoin) external onlyOwner {
        busdToken = _stablecoin;
    }


    // Set Referral Fee Settings (The portion that's deducted from treasury in case of a referral)
    function setReferralSettings(uint256 _referee, uint256 _referrer, uint256 _feeDenominator) external onlyOwner {
        require(
            _referee.add(_referrer) <= buytreasuryFee, // checking that the referral fee is not higher than the treasury fee
            "wrong"
        );
        referee = _referee;
        referrer = _referrer;
        totalReferralFee = referee.add(referrer);
        feeDenominator = _feeDenominator;
        require(totalReferralFee < feeDenominator / 4);
    }

    // Set Buy Transactions Tax Fees
    function setBuyFees(uint256 _buyliquidityFee, uint256 _buyreserveFee, uint256 _buytreasuryFee, uint256 _buyfirepitfee, uint256 _feeDenominator) external onlyOwner {
        require(
            _buyliquidityFee <= MAX_FEE_RATE && // $YIELD Liquidity Pool Growth
            _buyfirepitfee <= MAX_FEE_RATE && // $YIELD Liquidity Pool Growth
            _buyreserveFee <= MAX_FEE_RATE && // Yield Protocol Reward Reserves
            _buytreasuryFee <= MAX_FEE_RATE, // Funding Marketing & Development
            "wrong"
        );
        buyliquidityFee = _buyliquidityFee;
        buyreserveFee = _buyreserveFee;
        buytreasuryFee = _buytreasuryFee;
        buyfirepitfee = _buyfirepitfee;
        totalBuyFee = buyliquidityFee.add(buytreasuryFee).add(buyreserveFee).add(buyfirepitfee);
        feeDenominator = _feeDenominator;
        require(totalBuyFee < feeDenominator / 4);
    }

    // Set Sell Transactions Tax Fees
     function setSellFees(uint256 _sellliquidityFee, uint256 _sellreserveFee, uint256 _selltreasuryFee, uint256 _sellfirepitfee, uint256 _feeDenominator) external onlyOwner {
        require(
            _sellliquidityFee <= MAX_FEE_RATE && // $YIELD Liquidity Pool Growth
            _sellfirepitfee <= MAX_FEE_RATE && // $YIELD Liquidity Pool Growth
            _sellreserveFee <= MAX_FEE_RATE && // Yield Protocol Reward Reserves
            _selltreasuryFee <= MAX_FEE_RATE, // Funding Marketing & Development
            "wrong"
        );
        sellfirepitfee = _sellfirepitfee;
        sellliquidityFee = _sellliquidityFee;
        sellreserveFee = _sellreserveFee;
        selltreasuryFee = _selltreasuryFee;
        totalSellFee = sellliquidityFee.add(sellreserveFee).add(selltreasuryFee).add(sellfirepitfee);
        feeDenominator = _feeDenominator;
        require(totalSellFee < feeDenominator / 4);
    }
    // Rescue Tokens Stuck In Contract
    function clearStuckBalance(address _receiver) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    // Rescue Token Stuck In Contract
    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success){
		if(tokens == 0){
            tokens = ERC20Detailed(tokenAddress).balanceOf(address(this));
        }
        return ERC20Detailed(tokenAddress).transfer(msg.sender, tokens);
    }
    
    function setAutoRebase(bool _autoRebase) external onlyOwner {
        require(autoRebase != _autoRebase, "Not changed");
        autoRebase = _autoRebase;
    }

    function setRebaseFrequency(uint256 _rebaseFrequency) external onlyOwner {
        require(_rebaseFrequency <= MAX_REBASE_FREQUENCY, "Too high");
        rebaseFrequency = _rebaseFrequency;
    }

    function setRewardYield(uint256 _rewardYield, uint256 _rewardYieldDenominator) external onlyOwner {
        rewardYield = _rewardYield;
        rewardYieldDenominator = _rewardYieldDenominator;
    }

    function setFeesOnNormalTransfers(bool _enabled) external onlyOwner {
        require(feesOnNormalTransfers != _enabled, "Not changed");
        feesOnNormalTransfers = _enabled;
    }

    function setIsLiquidityInBnb(bool _value) external onlyOwner {
        require(isLiquidityInBnb != _value, "Not changed");
        isLiquidityInBnb = _value;
    }

    function setNextRebase(uint256 _nextRebase) external onlyOwner {
        nextRebase = _nextRebase;
    }

    // Set the max sell transaction - must be above the minimum amount
    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        require(_maxTxn >= (2500000 * (10 ** 18)), "The max sell amount should be above the minimum amount");
        maxSellTransactionAmount = _maxTxn;
    }

    event SwapBack(uint256 contractTokenBalance,uint256 amountToLiquify,uint256 amountToReserve,uint256 amountToTreasury,uint256 amountToFirepit);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SwapAndLiquifyBusd(uint256 tokensSwapped, uint256 busdReceived, uint256 tokensIntoLiqudity);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
}