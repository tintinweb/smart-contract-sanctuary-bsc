/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// Sources flattened with hardhat v2.6.4 https://hardhat.org

// File contracts/interfaces/IERC20.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


// File contracts/ERC20Detailed.sol

pragma solidity ^0.7.4;

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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


// File contracts/interfaces/IPancakeRouter01.sol

pragma solidity ^0.7.4;

interface IPancakeRouter01 {
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
}


// File contracts/interfaces/IPancakeRouter02.sol

pragma solidity ^0.7.4;

interface IPancakeRouter02 is IPancakeRouter01 {
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


// File contracts/libraries/SafeMathInt.sol

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


// File contracts/libraries/SafeMath.sol

pragma solidity ^0.7.4;

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


// File contracts/interfaces/IPancakeFactory.sol

pragma solidity ^0.7.4;

interface IPancakeFactory {
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


// File contracts/interfaces/ILiquidityPool.sol

pragma solidity ^0.7.4;

interface ILiquidityPool {
    function sync() external;
}


// File contracts/Ownable.sol

pragma solidity ^0.7.4;

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
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
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


// File contracts/PyramiDaoToken.sol

pragma solidity ^0.7.4;








contract PyramiDaoToken is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    ILiquidityPool public pairContract;
    IPancakeRouter02 public router;

    bool public initialDistributionFinished;
    uint256 public currentEpoch;
    uint256 public lastRebasedTime;
    uint256 public percentInOneRebaseRound;
    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 1 * 10**9 * 10**DECIMALS;
    uint256 public liquidityFee = 3;
    uint256 public Treasury = 2;
    uint256 public Insurance = 3;
    uint256 public sellFee = 5;
    uint256 public totalFee =
        liquidityFee.add(Treasury).add(Insurance);
    uint256 public feeDenominator = 100;
    uint256 public rebaseTime = 3 minutes;
    uint256 targetLiquidity = 50;
    uint256 targetLiquidityDenominator = 100;
    uint256 private pydSwapThreshold = (TOTAL_PYDS * 10) / 10000;
    uint256 private constant TOTAL_PYDS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = ~uint128(0);
    uint256 private _totalSupply;
    uint256 private _pydsPerFragment;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address public AutoLiquidityReceiver;
    address public EgyptTreasury;
    address public PharaohsInsurance;
    address public pair;
    address public openZeppelinRelayer;

    bool public swapEnabled = true;
    bool inSwap;

    mapping(address => uint256) private _pydBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    mapping(address => bool) allowTransfer;
    mapping(address => bool) _isFeeExempt;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyRelayer() {
        require(msg.sender == openZeppelinRelayer, "Only Relayer");
        _;
    }

    modifier initialDistributionLock() {
        require(
            initialDistributionFinished ||
                isOwner() ||
                allowTransfer[msg.sender]
        );
        _;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    constructor(
        address router_,
        address autoLiquidityReceiver_,
        address egyptTreasury_,
        address pharaohsInsurance_,
        address openZeppelinRelayer_
    ) ERC20Detailed("PyramiDaoToken", "PYRA", uint8(DECIMALS)) {
        router = IPancakeRouter02(router_);

        pair = IPancakeFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        AutoLiquidityReceiver = autoLiquidityReceiver_;
        EgyptTreasury = egyptTreasury_;
        PharaohsInsurance = pharaohsInsurance_;
        openZeppelinRelayer = openZeppelinRelayer_;
        _allowedFragments[address(this)][address(router)] = uint256(-1);
        pairContract = ILiquidityPool(pair);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _pydBalances[EgyptTreasury] = TOTAL_PYDS;
        _pydsPerFragment = TOTAL_PYDS.div(_totalSupply);

        initialDistributionFinished = false;
        _isFeeExempt[EgyptTreasury] = true;
        _isFeeExempt[address(this)] = true;
        percentInOneRebaseRound = 5287653679;
        _transferOwnership(EgyptTreasury);
        emit Transfer(address(0x0), EgyptTreasury, _totalSupply);
    }

    function shouldRebase() internal view returns (bool) {
        return
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair &&
            !inSwap &&
            lastRebasedTime > 0 &&
            block.timestamp >= (lastRebasedTime + rebaseTime);
    }

    function _rebase(int256 supplyDelta)
        internal
        returns (uint256)
    {
        require(!inSwap, "Try again");
        if (supplyDelta == 0) {
            uint256 supplyDeltaAutoCalculate = _totalSupply.mul(percentInOneRebaseRound).div(10**14);
            _totalSupply = _totalSupply.add(supplyDeltaAutoCalculate);
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(-supplyDelta));
        }
        if (supplyDelta > 0) {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _pydsPerFragment = TOTAL_PYDS.div(_totalSupply);
        pairContract.sync();

        emit LogRebase(currentEpoch, _totalSupply);
        currentEpoch += 1;
        lastRebasedTime = block.timestamp;
        return _totalSupply;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        initialDistributionLock
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) external view override returns (uint256) {
        return _pydBalances[who].div(_pydsPerFragment);
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 pydAmount = amount.mul(_pydsPerFragment);
        _pydBalances[from] = _pydBalances[from].sub(pydAmount);
        _pydBalances[to] = _pydBalances[to].add(pydAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], 'in_blacklist');
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 pydAmount = amount.mul(_pydsPerFragment);

        if (shouldRebase()) {
            _rebase(0);
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        _pydBalances[sender] = _pydBalances[sender].sub(pydAmount);

        uint256 pydAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, pydAmount)
            : pydAmount;
        _pydBalances[recipient] = _pydBalances[recipient].add(
            pydAmountReceived
        );

        emit Transfer(
            sender,
            recipient,
            pydAmountReceived.div(_pydsPerFragment)
        );
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }

        _transferFrom(from, to, value);
        return true;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(
            targetLiquidity,
            targetLiquidityDenominator
        )
            ? 0
            : liquidityFee;
        uint256 contractTokenBalance = _pydBalances[address(this)].div(
            _pydsPerFragment
        );
        uint256 amountToLiquify = contractTokenBalance
            .mul(dynamicLiquidityFee)
            .div(totalFee)
            .div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance.sub(balanceBefore);

        uint256 totalETHFee = totalFee.sub(dynamicLiquidityFee.div(2));

        uint256 amountETHLiquidity = amountETH
            .mul(dynamicLiquidityFee)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHInsurance = amountETH.mul(Insurance).div(totalETHFee);
        uint256 amountETHTreasury = amountETH.mul(Treasury).div(
            totalETHFee
        );

        (bool success, ) = payable(EgyptTreasury).call{
            value: amountETHTreasury,
            gas: 30000
        }("");
        (success, ) = payable(PharaohsInsurance).call{
            value: amountETHInsurance,
            gas: 30000
        }("");

        success = false;

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                AutoLiquidityReceiver,
                block.timestamp
            );
        }
    }

    function takeFee(address sender, address recipient, uint256 pydAmount)
        internal
        returns (uint256)
    {
        uint256 _totalFee = totalFee;
        if(recipient == pair) _totalFee = _totalFee.add(sellFee);

        uint256 feeAmount = pydAmount.mul(_totalFee).div(feeDenominator);

        _pydBalances[address(this)] = _pydBalances[address(this)].add(
            feeAmount
        );
        emit Transfer(sender, address(this), feeAmount.div(_pydsPerFragment));

        return pydAmount.sub(feeAmount);
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        initialDistributionLock
        returns (bool)
    {
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

    function increaseAllowance(address spender, uint256 addedValue)
        external
        initialDistributionLock
        returns (bool)
    {
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

    function approve(address spender, uint256 value)
        external
        override
        initialDistributionLock
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        return (pair == from || pair == to) && (!_isFeeExempt[from]);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _pydBalances[address(this)] >= pydSwapThreshold;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_PYDS.sub(_pydBalances[DEAD]).sub(_pydBalances[ZERO])).div(
                _pydsPerFragment
            );
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function checkSwapThreshold() external view returns (uint256) {
        return pydSwapThreshold.div(_pydsPerFragment);
    }

    function manualSync() external {
        ILiquidityPool(pair).sync();
    }

    /**********************************************
     * OWNERS FUNCTION
     */

    function setLP(address _address)
        external
        onlyOwner
    {
        pairContract = ILiquidityPool(_address);
        _isFeeExempt[_address];
    }

    function setLastRebasedTime(uint256 lastRebasedTime_)
        public
        onlyOwner
    {
        lastRebasedTime = lastRebasedTime_;
    }

    function setPercentInOneRebaseRound(uint256 percentInOneRebaseRound_)
        public
        onlyOwner
    {
        percentInOneRebaseRound = percentInOneRebaseRound_;
    }

    function rescueToken(address tokenAddress, uint256 tokens)
        public
        onlyOwner
        returns (bool success)
    {
        return ERC20Detailed(tokenAddress).transfer(msg.sender, tokens);
    }

    function clearStuckBalance(uint256 amountPercentage, address adr) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(adr).transfer(
            (amountETH * amountPercentage) / 100
        );
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _EgyptTreasury,
        address _pharaohsInsurance
    ) external onlyOwner {
        AutoLiquidityReceiver = _autoLiquidityReceiver;
        EgyptTreasury = _EgyptTreasury;
        PharaohsInsurance = _pharaohsInsurance;
    }

    function setOpenZeppelinRelayer(
        address openZeppelinRelayer_
    ) external onlyOwner {
        openZeppelinRelayer = openZeppelinRelayer_;
    }

    function setFees(
        uint256 _liquidityFee,
        uint256 _Insurance,
        uint256 _Treasury,
        uint256 _sellFee,
        uint256 _feeDenominator
    ) external onlyOwner {
        liquidityFee = _liquidityFee;
        Insurance = _Insurance;
        Treasury = _Treasury;
        sellFee = _sellFee;
        totalFee = liquidityFee.add(Treasury).add(Insurance);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator / 4);
    }

    function updateBotBlacklist(address _user, bool _flag) public onlyOwner{
        blacklist[_user] = _flag;
    }

    function rebase(int256 supplyDelta)
        external
        onlyRelayer
        returns (uint256)
    {
        if (shouldRebase()) {
            return _rebase(supplyDelta);
        }
    }

    function setTargetLiquidity(uint256 target, uint256 accuracy) external onlyOwner {
        targetLiquidity = target;
        targetLiquidityDenominator = accuracy;
    }

    function setSwapBackSettings(
        bool _enabled,
        uint256 _num,
        uint256 _denom
    ) external onlyOwner {
        swapEnabled = _enabled;
        pydSwapThreshold = TOTAL_PYDS.div(_denom).mul(_num);
    }

    function setInitialDistributionFinished() external onlyOwner {
        initialDistributionFinished = true;
    }

    function enableTransfer(address _addr) external onlyOwner {
        allowTransfer[_addr] = true;
    }

    function setFeeExempt(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }

    function setRebaseTime(uint256 _rebaseTime) external onlyOwner {
        rebaseTime = _rebaseTime;
    }

    function setAutoLiquidityReceiver(address _AutoLiquidityReceiver) external onlyOwner {
        AutoLiquidityReceiver = _AutoLiquidityReceiver;
    }

    function setEgyptTreasury(address _EgyptTreasury) external onlyOwner {
        EgyptTreasury = _EgyptTreasury;
    }

    function setPharaohsInsurance(address _PharaohsInsurance) external onlyOwner {
        PharaohsInsurance = _PharaohsInsurance;
    }

    /**********************************************
     *
     */

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        uint256 liquidityBalance = _pydBalances[pair].div(_pydsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }
    
    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    receive() external payable {}
}