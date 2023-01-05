// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

interface IUniswapV2Pair {
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

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


interface IAgent {
    function delegate(
        uint256 buyPot, uint256 sellPot, uint256 transferPot, uint256 teamPot, uint256 referrerPot, uint256 tokensUsedForReferrerPot
    ) external payable;
    function marketplaceDelegate(uint256 toBuyback, uint256 toMarketing, uint256 toTeam) external payable;
    function notifyTransferListener(address from, address to) external;
    function notifyTransferListener(address from) external;

    function tryToLock(address account, uint128 amount, uint64 lockIndex, uint32 duration) external;
    function tryToLockExtra(address account, uint256 lockIndex, uint128 amount, uint32 additionalTime) external;
    function tryToUnlock(address account, uint256 lockIndex) external returns(uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../Interfaces/IERC20.sol";
import "../Interfaces/IUniswap.sol";
import "../Interfaces/IAgent.sol";

library ListAddress
{
    struct ListStruct
    {
        address[] Array;
        mapping(address => uint32) ItemToIndex;
    }

    function add(ListStruct storage self, address account) internal
    {
        if (self.Array.length == 0)
        {
            self.Array.push(address(0));
        }

        require(self.ItemToIndex[account] == 0, "LA:A0");

        self.Array.push(account);
        self.ItemToIndex[account] = uint32(self.Array.length - 1);
    }

    function remove(ListStruct storage self, address account) internal
    {
        uint256 itemIndex = self.ItemToIndex[account];

        if (itemIndex > 0)
        {
            // @@@ audit revision: moved lastIndex variable here so this function won't revert in any case
            uint256 lastIndex = self.Array.length - 1;

            if (itemIndex < lastIndex)
            {
                self.Array[itemIndex] = self.Array[lastIndex];
            }

            self.Array.pop();
            self.ItemToIndex[account] = 0;
        }
    }
}

contract MORE is IERC20
{
    using ListAddress for ListAddress.ListStruct;

    string public constant symbol = "MORE";
    string public constant name = "Mythic Ore";

    uint256 private constant _decimals = 18;

    uint256 private constant _totalSupply = MAX_SUPPLY;

    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private constant ONE = 10 ** _decimals;

    // used to pack mulitple pots into 256 bits, thus lowering gas fees
    uint256 private constant TOKEN_POTS_DIVISOR = 10 ** (_decimals - 3);

    // max supply can be safely stored in uint96+, it will be used for gas optimizations
    uint256 public constant MAX_SUPPLY = 100000000 * ONE;

    // max possible total tax is 10% on any transfer
    uint256 public constant TAX_MAX = 1000;
    uint256 private constant DENOMINATOR = 10000;

    address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    struct ModifiersData
    {
        uint32 isSellAddress;
        uint32 isExcludedFromTax;
        uint32 isExcludedFromMaxAccountRule;
        uint32 buyTaxReduction;
        uint32 sellTaxReduction;
        uint32 reflectionsMultiplier;
        uint64 oldMultiplierBalance;
    }
    mapping(address => ModifiersData) public Modifiers;

    struct ReflectionsData
    {
        uint32 currentCompoundingIndex;
        uint32 potPartToDistribute;
        uint32 prevDelay;
        uint32 delay;
        uint32 periodEnd;
        uint32 lastUpdateTime;
        uint64 maxMultiplier;
        uint64 totalBalances;
        uint96 rate;
        uint96 pot;
        uint256 perShareStored;
    }
    ReflectionsData public reflections;

    mapping(address => uint256) private ReflectionsPerSharePaid;

    ListAddress.ListStruct private Shareholders;
    ListAddress.ListStruct private AuthorizedContracts;

    /*
    @@@ audit revesion - added locks
    the locks mechanism will allow to lock tokens for a certain period of time
    it is done in combination with proxy Agent contract to notify other contracts in the ecosystem
    */
    struct LockInstance
    {
        uint32 isActive;
        uint32 duration;
        uint64 unlockTimestamp;
        uint128 amount;
    }

    struct LockConfig
    {
        uint64 areLocksAllowed;
        uint64 nextLockIndex;
        uint128 totalLocked;
    }

    mapping(address => LockConfig) public LockConfigs;
    mapping(address => mapping(uint256 => LockInstance)) public Locks;

    mapping(uint256 => uint256) public MaxCompoundingIterations;

    uint256 public minGasForWorkOnSale;
    uint256 public minGasForWorkOnBuy;

    struct TaxData
    {
        uint32 total;
        uint32 reflections;
        uint32 liquidity;
        uint32 team;
        uint32 referrer;
    }
    mapping(uint256 => TaxData) private Taxes;

    // it is safe to make token pots in 40 bits as only 3 decimals are counted
    // (2**40 - 1) / 10 ** 3 is more than MAX_SUPPLY
    // amount that is left is going to uint128 reflections pot
    struct PotsDataToken
    {
        uint40 liquidity;
        uint40 buy;
        uint40 sell;
        uint40 transfer;
        uint40 referrer;
        uint56 team;
    }
    PotsDataToken public tokenPots;

    uint256 public tokenLiquidityReserves;
    uint256 public liquidityFromFeesUnlockTime;

    // uint80 pot can hold 1208925 BNB, it is reasonable to assume that overflow is impossible
    // even if it happens (in my dreams), overflowed amount is recoverable
    struct PotsDataBNB
    {
        uint80 liquidity;
        uint80 buy;
        uint96 sell;
        uint80 transfer;
        uint80 referrer;
        uint96 team;
    }
    PotsDataBNB public potsBNB;

    struct ReferrerSystemData
    {
        uint16 isDefaultReferrer;
        uint16 currentRefferalTaxReduction;
        uint16 referralTaxReduction;
        uint16 nextSellTaxReduction;
        uint96 lastReferrerTokensAmount;
        uint96 tokensUsedForReferrersPot;
    }
    ReferrerSystemData public referrerSystemData;

    // first 4 amounts here are stored with only 3 decimals
    struct WorkAmountsData
    {
        uint32 agentBNB; // min amount of BNB for sending to an Agent
        uint32 liquidityBNB; // min amount of BNB to add to liquidity
        uint32 tokensMin; // min tokens for liquidity or to be swapped for BNB
        uint32 tokensMax; // max tokens amount to swap for BNB in one tx
        uint32 launchedTime; // stored here to pack all in one storage slot
        uint96 maxAccount; // untaxed transactions ignore max account rule
    }
    WorkAmountsData public workAmounts;
    
    IUniswapV2Router02 private SwapRouter;

    address public SwapAgent;
    address public MainAccount;
    IAgent public Agent;

    ///////////////////////////////////////////////////////////////

    event MinGasForWorkChanged(uint256 newValueOnSale, uint256 newValueOnBuy);
    event Reflected(address indexed account, uint256 amount);
    event ToggledLocks(address indexed account, uint64 flag);
    event Locked(address indexed account, uint256 lockIndex, uint128 amount, uint32 duration);
    event Unlocked(address indexed account, uint256 lockIndex, uint256 unlockFee, uint128 amount);

    ///////////////////////////////////////////////////////////////

    modifier onlyMain()
    {
        _onlyMain();
        _;
    }

    modifier onlyAuthorized()
    {
        _onlyAuthorized();
        _;
    }

    modifier onlySwap()
    {
        _onlySwap();
        _;
    }

    modifier flagCheck(uint256 flag)
    {
        _flagCheck(flag);
        _;
    }

    function _onlyMain() view private
    {
        require(msg.sender == MainAccount, "onlyMain");
    }

    function _onlyAuthorized() private view
    {
        require(AuthorizedContracts.ItemToIndex[msg.sender] > 0, "onlyAuthorized");
    }

    function _onlySwap() view private
    {
        require(msg.sender == SwapAgent, "onlySwap");
    }

    function _flagCheck(uint256 flag) private pure
    {
        require(flag < 2, "flagCheck");
    }

    ///////////////////////////////////////////////////////////////

    // some initialization needs to be made via external calls
    // this helps to reduce contract's bytecode and compile with more optimizer runs
    constructor()
    {
        MainAccount = msg.sender;

        //@@@ audit revision: changed token distribution on deploy
        _balanceOf[MainAccount] = _totalSupply;
        emit Transfer(address(0), MainAccount, _totalSupply);

        SwapRouter = IUniswapV2Router02(ROUTER_ADDRESS);
        Modifiers[ROUTER_ADDRESS].isExcludedFromMaxAccountRule = 1;

        address swapPairAddress = IUniswapV2Factory(SwapRouter.factory()).createPair(address(this), WBNB);
        Modifiers[swapPairAddress].isSellAddress = 1;

        _allowances[address(this)][ROUTER_ADDRESS] = ~uint256(0);

        Modifiers[MainAccount].isExcludedFromTax = 1;
        Modifiers[address(this)].isExcludedFromTax = 1;
        Modifiers[BURN_ADDRESS].isExcludedFromTax = 1;

        // setting initial values to 1 and keeping them non-zero to make gas usage more stable
        // so when pots are emptied, 1 is always left, and when pot value is used, 1 is always substracted
        tokenPots.liquidity = 1;

        potsBNB.buy = 1;
        potsBNB.transfer = 1;

        workAmounts.maxAccount = uint96(750000 * ONE);

        reflections.potPartToDistribute = 200;
        reflections.delay = 86400;
    }

    ///////////////////////////////////////////////////////////////

    receive() external payable { }

    ///////////////////////////////////////////////////////////////

    function transferFrom(address from, address to, uint256 value) external override returns(bool)
    {
        require(value > 0 && _allowances[from][msg.sender] >= value, "transferFrom0");

        // unchecked is safe because _allowances[from][msg.sender] >= value
        unchecked
        {
            _allowances[from][msg.sender] -= value;
        }

        return handleTransfer(from, to, value);
    }

    function transfer(address to, uint256 value) external override returns(bool)
    {
        require(value > 0, "transfer0");

        return handleTransfer(msg.sender, to, value);
    }

    // cheaper transferFrom implementation only for authorized addresses
    // still checks allowance, but skips reflections updates for receiver
    // also no tax applied and no modifiers checked
    function lightningTransfer(address sender, uint256 amount) external onlyAuthorized()
    {
        uint32 senderReflectionsMultiplier = Modifiers[sender].reflectionsMultiplier;
        if (senderReflectionsMultiplier > 0)
        {
            updateReflections(sender);
        }

        // @@@ audit revision: added lock check
        require(_allowances[sender][msg.sender] >= amount && _balanceOf[sender] - LockConfigs[sender].totalLocked >= amount, "shock");

        /*
        unchecked block usage is justified because:
            1. _allowances[sender][msg.sender] >= amount
            2. _balanceOf[sender] >= amount
            3. if (2) is true, then _balanceOf[msg.sender] += amount cannot overflow cause token has no mint functionality
        */
        unchecked
        {
            _allowances[sender][msg.sender] -= amount;

            _balanceOf[sender] -= amount;
            _balanceOf[msg.sender] += amount;
        }

        emit Transfer(sender, msg.sender, amount);

        if (senderReflectionsMultiplier > 0)
        {
            updateMultiplierBalances(sender);
        }
    }

    function prepareReferralSwap(address initiator, uint32 isSell, uint16 isDefaultReferrer) external onlySwap() returns(uint32, uint16)
    {
        if (isSell == 1)
        {
            referrerSystemData.nextSellTaxReduction = uint16(Modifiers[initiator].sellTaxReduction);
        }

        uint16 _currentRefferalTaxReduction = referrerSystemData.currentRefferalTaxReduction;

        referrerSystemData.currentRefferalTaxReduction = referrerSystemData.referralTaxReduction;
        referrerSystemData.isDefaultReferrer = isDefaultReferrer;

        return (Modifiers[initiator].isExcludedFromTax, _currentRefferalTaxReduction);
    }

    function approve(address spender, uint256 value) external override returns(bool success)
    {
        _allowances[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    /*
    this allows user to enable and disable locking at any time
    locks are generally will be done through the dapp, so if user trusts it - they enable locks
    if user does not trust the dapp anymore - they can disable locks
    call with 0 to disable locks, and call with 1 to enable
    */
    function toggleLocks(uint64 flag) external flagCheck(flag)
    {
        LockConfigs[msg.sender].areLocksAllowed = flag;

        emit ToggledLocks(msg.sender, flag);
    }

    /*
    allows user to lock their tokens while notifying the proxy Agent contract
    this makes it easy to combine reflections with staking
    also user will be able to actually see the balance with locked tokens and reflections in any wallet
    */
    function lockTokens(uint128 amount, uint32 duration) external
    {
        _beforeLock(amount);

        require(duration < 86400 * 366 + 1, "LT0");

        LockConfig storage lockConfig = LockConfigs[msg.sender];

        Agent.tryToLock(msg.sender, amount, lockConfig.nextLockIndex, duration);

        LockInstance storage lock = Locks[msg.sender][lockConfig.nextLockIndex++];

        lock.isActive = 1;
        lock.duration = duration;
        lock.unlockTimestamp = uint64(block.timestamp + duration);
        lock.amount = amount;

        emit Locked(msg.sender, lockConfig.nextLockIndex - 1, amount, duration);
    }

    function lockExtraTokens(uint256 lockIndex, uint128 amount, uint32 additionalTime) external
    {
        _beforeLock(amount);

        LockInstance storage lock = Locks[msg.sender][lockIndex];

        require(lock.isActive == 1, "LET0");
        require(block.timestamp < lock.unlockTimestamp, "LET1");
        require(lock.unlockTimestamp + additionalTime - block.timestamp < 86400 * 366 + 1, "LET2");

        Agent.tryToLockExtra(msg.sender, lockIndex, amount, additionalTime);

        lock.amount += amount;
        lock.duration += additionalTime;
        lock.unlockTimestamp += uint64(additionalTime);

        emit Locked(msg.sender, lockIndex, amount, additionalTime);
    }

    /*
    amount that is locked is stored in lockConfig.totalLocked for every user
    there are no automatic on-chain unlocks as the number of locks is potentially not limited
    its only possible to lock once in a single tx
    but it is possible to unlock multiple lock instances using external contracts
    */
    function _beforeLock(uint128 amount) private
    {
        if (Modifiers[msg.sender].reflectionsMultiplier > 0)
        {
            updateReflections(msg.sender);
        }

        LockConfig storage lockConfig = LockConfigs[msg.sender];

        require(lockConfig.areLocksAllowed == 1, "_BL0");
        require(_balanceOf[msg.sender] - lockConfig.totalLocked >= amount, "_BL1");

        lockConfig.totalLocked += amount;
    }

    /*
    How to unlock from BscScan:
    1. call LockConfigs with your wallet address
    2. call this function with the same address and the lastLockIndex value from (1)
    3. repeat (2) with all previous indexes in case if you have multiple locks active
    */
    function unlockTokens(address account, uint256 lockIndex) external
    {
        require(block.timestamp >= Locks[account][lockIndex].unlockTimestamp, "UT0");

        _beforeUnlock(account, lockIndex);

        // in case if lock is expired user must always be able to unlock tokens succesfully
        try this.tryToUnlock(account, lockIndex) { } catch { }

        emit Unlocked(account, lockIndex, 0, Locks[account][lockIndex].amount);
    }

    // leaves an opportunity to cancel the lock in case of an emergency
    function unlockTokensEarly(uint256 lockIndex, uint256 maxUnlockFee) external
    {
        require(block.timestamp < Locks[msg.sender][lockIndex].unlockTimestamp, "UTE0");

        _beforeUnlock(msg.sender, lockIndex);

        uint256 unlockFee = Agent.tryToUnlock(msg.sender, lockIndex);
        require(unlockFee != 0, "UTE1");

        if (unlockFee < 100)
        {
            require(unlockFee <= maxUnlockFee, "UTE2");
            _transfer(msg.sender, BURN_ADDRESS, Locks[msg.sender][lockIndex].amount * unlockFee / 100, 0, 999);
        }

        emit Unlocked(msg.sender, lockIndex, unlockFee, Locks[msg.sender][lockIndex].amount);
    }

    function _beforeUnlock(address account, uint256 lockIndex) private
    {
        LockInstance storage lock = Locks[account][lockIndex];
        require(lock.isActive == 1, "_BU0");
        
        lock.isActive = 0;
        LockConfigs[account].totalLocked -= lock.amount;
    }

    function tryToUnlock(address account, uint256 lockIndex) external
    {
        if (msg.sender == address(this))
        {
            Agent.tryToUnlock(account, lockIndex);
        }
    }

    function setModifiers(
        address account1, address account2,
        uint32 reflectionsMultiplier,
        uint32 buyDiscount1, uint32 sellDiscount1,
        uint32 buyDiscount2, uint32 sellDiscount2
        ) external onlyAuthorized()
    {
        if (reflectionsMultiplier > 0)
        {
            _addMultiplier(account1, reflectionsMultiplier, 0);
            _addMultiplier(account2, reflectionsMultiplier, 1);
        }

        _setBuyTaxReduction(account1, buyDiscount1);
        _setBuyTaxReduction(account2, buyDiscount2);

        _setSellTaxReduction(account1, sellDiscount1);
        _setSellTaxReduction(account2, sellDiscount2);
    }

    function setModifiers(address account, uint32 reflectionsMultiplier, uint32 isAddition, uint32 buyDiscount, uint32 sellDiscount) external onlyAuthorized()
    {
        if (reflectionsMultiplier > 0)
        {
            _addMultiplier(account, reflectionsMultiplier, isAddition);
        }

        _setBuyTaxReduction(account, buyDiscount);

        _setSellTaxReduction(account, sellDiscount);
    }

    function addMultiplier(address account, uint32 difference, uint32 isAddition) external onlyAuthorized()
    {
        _addMultiplier(account, difference, isAddition);
    }

    function setBuyTaxReduction(address account, uint32 value) external onlyAuthorized()
    {
        _setBuyTaxReduction(account, value);
    }

    function setSellTaxReduction(address account, uint32 value) external onlyAuthorized()
    {
        _setSellTaxReduction(account, value);
    }

    function addTokensToLiquidityReservesFromContract(uint256 amount) external onlyAuthorized()
    {
        require(getFreeTokens() >= amount);

        tokenLiquidityReserves += amount;
    }

    function addBNBToLiquidityPot() external payable
    {
        potsBNB.liquidity += uint80(msg.value);
    }

    function buybackAndBurn() external payable
    {
        _transfer(address(this), BURN_ADDRESS, swapBNBForTokens(msg.value), 0, 999);
    }

    function buybackAndLockToLiquidity() external payable
    {
        potsBNB.liquidity += uint80(msg.value - msg.value / 2);
        tokenLiquidityReserves += swapBNBForTokens(msg.value / 2);

        addLiquidityFromTokenReserves();
    }

    function addAuthorized(address contractAddress) external onlyMain()
    {
        AuthorizedContracts.add(contractAddress);
    }

    function removeAuthorized(address contractAddress) external onlyMain()
    {
        AuthorizedContracts.remove(contractAddress);
    }

    function lockLiquidityFromFees(uint256 additionalTime) external onlyMain()
    {
        liquidityFromFeesUnlockTime += additionalTime;
    }

    // when liquidity gathered from tax and other fees is unlocked, it can be collected
    // might be helpful in case of liquidity migration
    // this function cannot remove initial liquidity
    function withdrawLiquidityFromFees(address liquidityPairAddress) external onlyMain()
    {
        require(block.timestamp > liquidityFromFeesUnlockTime);

        IERC20(liquidityPairAddress).approve(ROUTER_ADDRESS, MAX_SUPPLY);
        Modifiers[ROUTER_ADDRESS].isExcludedFromTax = 1;

        SwapRouter.removeLiquidityETH(
            address(this),
            IERC20(liquidityPairAddress).balanceOf(address(this)),
            0,
            0,
            msg.sender,
            block.timestamp
        );

        Modifiers[ROUTER_ADDRESS].isExcludedFromTax = 0;
    }

    function toggleSellAddress(address account, uint32 flag) external onlyMain() flagCheck(flag)
    {
        Modifiers[account].isSellAddress = flag;
    }

    // 0 - not exclueded, 1 - excluded
    // 2 - excluded when sender, 3 - excluded when receiver
    function toggleAccountTaxExclusion(address account, uint32 exclusionType) external onlyMain()
    {
        require(account != MainAccount && exclusionType < 4);
        Modifiers[account].isExcludedFromTax = exclusionType;
    }

    function toggleAccountMaxAccountRuleExclusion(address account, uint32 flag) external onlyMain() flagCheck(flag)
    {
        Modifiers[account].isExcludedFromMaxAccountRule = flag;
    }

    function setReferralTaxReduction(uint16 newReferralTaxReduction) external onlyMain()
    {
        require(newReferralTaxReduction < 101);

        referrerSystemData.referralTaxReduction = newReferralTaxReduction;
    }

    function setMaxAccountAndMaxMultiplier(uint96 newMaxAccount, uint64 newMaxMultiplier) external onlyMain()
    {
        require(newMaxAccount >= MAX_SUPPLY / 1000 && newMaxMultiplier >= 300 && newMaxMultiplier <= 999999);
        
        workAmounts.maxAccount = newMaxAccount;
        reflections.maxMultiplier = newMaxMultiplier;
    }

    function setReflectionsDelayAndDistributingPart(uint32 newDelayInSeconds, uint32 newPotPartToDistribute) external onlyMain()
    {
        require(newDelayInSeconds > 0 && newDelayInSeconds < 604801 && newPotPartToDistribute > 0 && newPotPartToDistribute < DENOMINATOR);

        reflections.delay = newDelayInSeconds;
        reflections.potPartToDistribute = newPotPartToDistribute;
    }

    function setMaxCompoundingIterations(uint256 index, uint256 newValue) external onlyMain()
    {
        require(newValue < 9);

        MaxCompoundingIterations[index] = newValue;
    }

    function setMinGasForWork(uint256 newValueOnSale, uint256 newValueOnBuy) external onlyMain()
    {
        require(newValueOnSale < 550001 && newValueOnBuy < 550001);

        minGasForWorkOnSale = newValueOnSale;
        minGasForWorkOnBuy = newValueOnBuy;

        emit MinGasForWorkChanged(newValueOnSale, newValueOnBuy);
    }

    function setTax(uint256 txType, uint32 newTotalTax, uint32 newTaxReflections, uint32 newTaxLiquidity, uint32 newTeamTax, uint32 newReferrerTax) external onlyMain()
    {
        require((newTotalTax <= TAX_MAX && newTaxReflections + newTaxLiquidity <= newTotalTax) &&
                (newTeamTax + newReferrerTax <= newTotalTax - newTaxReflections - newTaxLiquidity));

        Taxes[txType].total = newTotalTax;
        Taxes[txType].reflections = newTaxReflections;
        Taxes[txType].liquidity = newTaxLiquidity;

        // these taxes are not adding up to the total directly and are a part of an Agent tax
        Taxes[txType].team = newTeamTax;
        Taxes[txType].referrer = newReferrerTax;
    }

    // only 3 decimals are counted
    function setWorkAmounts(uint32 agentBNB, uint32 liquidityBNB, uint32 tokensMin, uint32 tokensMax) external onlyMain()
    {
        require(
            tokensMin < 100000 * 1000 && tokensMin <= tokensMax &&
            tokensMax > 100000 && tokensMax >= tokensMin
        );
        
        workAmounts.agentBNB = agentBNB;
        workAmounts.liquidityBNB = liquidityBNB;
        workAmounts.tokensMin = tokensMin;
        workAmounts.tokensMax = tokensMax;
    }

    function setMainAccount(address newAccount, uint256 safetyCode) external onlyMain()
    {
        // safety check so this function won't be called accidentely
        require(safetyCode == 9753124680864213579);

        MainAccount = newAccount;
    }

    function setAgents(address newAgent, address newSwapAgent) external onlyMain()
    {
        AuthorizedContracts.remove(address(Agent));
        AuthorizedContracts.remove(address(SwapAgent));

        AuthorizedContracts.add(address(newAgent));
        AuthorizedContracts.add(address(newSwapAgent));

        _allowances[SwapAgent][ROUTER_ADDRESS] = 0;
        _allowances[newSwapAgent][ROUTER_ADDRESS] = ~uint256(0);

        Agent = IAgent(newAgent);
        SwapAgent = newSwapAgent;
    }

    function addToReflectionsFromContract(uint256 amount) external onlyAuthorized()
    {
        require(getFreeTokens() >= amount);

        _balanceOf[address(this)] -= amount;

        calculateReflections(amount);
    }

    function withdrawFreeBNB() external onlyMain()
    {
        (bool success,) = msg.sender.call{value: getFreeBNB()}('');

        require(success);
    }

    function withdrawFreeTokens(address tokenContract) external onlyMain()
    {
        if (tokenContract != address(this))
        {
            uint256 balance = IERC20(tokenContract).balanceOf(address(this));

            require(balance > 0, "WFT0");

            IERC20(tokenContract).transfer(msg.sender, balance);
        }
        else
        {
            uint256 freeTokens = getFreeTokens();

            require(freeTokens > 0, "WFT1");

            _transfer(address(this), msg.sender, freeTokens, 0, 999);
        }
    }

    function launchToken() external onlyMain()
    {
        require(workAmounts.launchedTime == 0 && address(Agent) != address(0) && address(SwapAgent) != address(0));

        workAmounts.launchedTime = uint32(block.timestamp);
    }

    function balanceOf(address account) external view override returns(uint256)
    {
        return _balanceOf[account] + reflected(account);
    }

    // @@@ audit revision: added function to view tokens available for transfers
    function unlockedBalanceOf(address account) external view returns(uint256)
    {
        return _balanceOf[account] + reflected(account) - LockConfigs[msg.sender].totalLocked;
    }

    function rawBalanceOf(address account) external view returns(uint256)
    {
        return _balanceOf[account];
    }

    function lastReferrerTokensAmount() external view returns(uint96)
    {
        return referrerSystemData.lastReferrerTokensAmount;
    }

    function getModifiers(address account1, address account2) external view returns(uint32, uint32, uint32, uint32)
    {
        return(Modifiers[account1].buyTaxReduction, Modifiers[account1].sellTaxReduction, Modifiers[account2].buyTaxReduction, Modifiers[account2].sellTaxReduction);
    }

    function getModifiers(address account) external view returns(uint32, uint32)
    {
        return(Modifiers[account].buyTaxReduction, Modifiers[account].sellTaxReduction);
    }

    function isAuthorized(address account) external view returns(uint256)
    {
        return AuthorizedContracts.ItemToIndex[account];
    }

    function allowance(address owner, address spender) external override view returns(uint256 remaining)
    {
        return _allowances[owner][spender];
    }

    function totalSupply() external pure override returns(uint256)
    {
        return _totalSupply;
    }

    function circulatingSupply() external view returns(uint256)
    {
        return _totalSupply - _balanceOf[BURN_ADDRESS];
    }

    function viewTaxes() external view returns(TaxData memory, TaxData memory, TaxData memory)
    {
        return (Taxes[0], Taxes[1], Taxes[2]);
    }

    function viewShareholders() external view returns(address[] memory)
    {
        return Shareholders.Array;
    }

    function viewAuthorized() external view returns(address[] memory)
    {
        return AuthorizedContracts.Array;
    }

    function decimals() external pure override returns(uint8)
    {
        return uint8(_decimals);
    }

    ///////////////////////////////////////////////////////////////

    // amount of work that can be performed is restricted
    // roughly 500000 gas is enough to sell, but in practice the amount will be lower
    function doWork() public
    {
        WorkAmountsData storage _workAmounts = workAmounts;
        if (Modifiers[msg.sender].isSellAddress == 0)
        {
            uint256 agentPotToSend = getBNBPotsSumWithoutLiquidity();
            if (gasleft() > minGasForWorkOnSale)
            {
                if (agentPotToSend > _workAmounts.agentBNB * TOKEN_POTS_DIVISOR)
                {
                    // @@@ audit revision - see deliverBNBToAgent function for more
                    try this.deliverBNBToAgent(agentPotToSend) { } catch { }
                    autoCompound(MaxCompoundingIterations[0]);
                }
                else
                {
                    if (potsBNB.liquidity > _workAmounts.liquidityBNB * TOKEN_POTS_DIVISOR + 1)
                    {
                        if (tokenLiquidityReserves > _workAmounts.tokensMin * TOKEN_POTS_DIVISOR)
                        {
                            addLiquidityFromTokenReserves();
                        }
                        else
                        {
                            refillLiquidityTokenReserves();
                            autoCompound(MaxCompoundingIterations[1]);
                        }
                    }
                    else
                    {
                        uint256 totalTokens = getCompressedTokenPotsSum();
                        if (totalTokens > _workAmounts.tokensMin)
                        {
                            swapTaxTokensForBNB(totalTokens);
                        }
                        else
                        {
                            autoCompound(MaxCompoundingIterations[2]);
                        }
                    }  
                }
            }
            else
            {
                doExcessiveWork(minGasForWorkOnSale);
            }
        }
        else
        {
            if (gasleft() > minGasForWorkOnBuy)
            {
                if (referrerSystemData.currentRefferalTaxReduction > 0)
                {
                    autoCompound(MaxCompoundingIterations[3]);
                }
                else
                {
                    autoCompound(MaxCompoundingIterations[4]);
                }
            }
            else
            {
                doExcessiveWork(minGasForWorkOnBuy);
            }
        }
    }

    // used to overestimate gas needed for the transaction to complete
    // this function always uses the same amount of gas with the same input given
    // so wallet estimates the amount needed to complete this function first
    // but then in doWork() actual work is going be done cause there would be enough gas for it
    // this way its not necessary to use require() or perform a gas check in each iteration of autoCompound()
    function doExcessiveWork(uint256 gas) private pure returns(uint256)
    {
        gas += 75000;

        // unchecked is safe because we subtract 51 only if value is greater than 51
        unchecked
        {
            while (gas > 51)
            {
                gas -= 51;
            }
        }

        return gas;
    }

    function autoCompound(uint256 maxIterations) public
    {
        uint256 length = Shareholders.Array.length;
        if (length < 2)
        {
            return;
        }

        uint256 currentIndex = reflections.currentCompoundingIndex;
        uint256 iterations = 0;

        reflections.perShareStored = reflectionsPerShare();
        reflections.lastUpdateTime = lastTimeReflectionsApplicable();

        while (iterations < maxIterations)
        {
            address account = Shareholders.Array[currentIndex];

            payReflections(account, reflections.perShareStored);
            updateMultiplierBalances(account);

            /*
            unchecked is safe because:
                1. uint256 cannot overflow if its being incremented by 1 starting from 0 or any array index
                   there cannot be an array that big to cause currentIndex to have the initial value reasonably close to max(uint256)

                2. iterations are starting from 0 and maxIterations are restricted by a max of 9 (see setMaxCompoundingIterations())
            */
            unchecked
            {
                ++currentIndex;
                ++iterations;
            }

            if (currentIndex == length)
            {
                currentIndex = 1;
                break;
            }
            
        }

        reflections.currentCompoundingIndex = uint32(currentIndex);
    }

    function compoundReflections(address account) public
    {
        updateReflections(account);
        updateMultiplierBalances(account);
    }

    function reflected(address account) public view returns(uint256)
    {
        return Modifiers[account].oldMultiplierBalance * (reflectionsPerShare() - ReflectionsPerSharePaid[account]) / ONE;
    }

    function reflected(address account, uint256 perShareStored) private view returns(uint256)
    {
        return Modifiers[account].oldMultiplierBalance * (perShareStored - ReflectionsPerSharePaid[account]) / ONE;
    }

    function getFreeTokens() public view returns(uint256)
    {
        return _balanceOf[address(this)] - getCompressedTokenPotsSum() * TOKEN_POTS_DIVISOR - tokenLiquidityReserves;
    }

    function getFreeBNB() public view returns(uint256)
    {
        return address(this).balance - getBNBPotsSumWithoutLiquidity() - potsBNB.liquidity;
    }

    ///////////////////////////////////////////////////////////////

    function _transfer(address sender, address recipient, uint256 amount, uint256 taxAmount, uint256 txType) internal virtual
    {
        uint32 senderReflectionsMultiplier = txType == 0 ? 0 : Modifiers[sender].reflectionsMultiplier;
        uint32 recipientReflectionsMultiplier = txType == 1 ? 0 : Modifiers[recipient].reflectionsMultiplier;

        // most likely only one of these will be called, unless its a transfer between shareholders
        if (senderReflectionsMultiplier > 0)
        {
            updateReflections(sender);
        }
        if (recipientReflectionsMultiplier > 0)
        {
            updateReflections(recipient);
        }

        // @@@ audit revision: added lock check
        require((_balanceOf[sender] - LockConfigs[sender].totalLocked >= amount) &&
                (workAmounts.launchedTime > 0 || Modifiers[sender].isExcludedFromTax == 1) &&
                (_balanceOf[recipient] + amount - taxAmount <= workAmounts.maxAccount
                || Modifiers[recipient].isSellAddress == 1 || Modifiers[recipient].isExcludedFromMaxAccountRule == 1
                || taxAmount == 0), "_transfer0");

        // @@@ audit revision: added unchecked block
        // _balanceOf[sender] >= amount is guaranteed because of the require statement above
        unchecked
        {
            _balanceOf[sender] -= amount;
        }
        _balanceOf[recipient] += amount - taxAmount;

        emit Transfer(sender, recipient, amount - taxAmount);

        if (senderReflectionsMultiplier > 0)
        {
            updateMultiplierBalances(sender);
        }
        if (recipientReflectionsMultiplier > 0)
        {
            updateMultiplierBalances(recipient);
        }

        // here failed external call does not result in a reverted transaction
        // so even if execution of notifyTransferListener reverts, _transfer will not revert
        // that makes it impossible to sabotage trading by setting a wrong Agent
        // @@@ audit revision - wrapped the call so even if method notifyTransferListener does not exists, _transfer will not revert
        if (txType == 0)
        {
            try this.notifyAgentSingle(recipient) { } catch { }
        }
        else if (txType == 1)
        {
            try this.notifyAgentSingle(sender) { } catch { }
        }
        else
        {
            try this.notifyAgentDouble(sender, recipient) { } catch { }
        }
    }

    function notifyAgentSingle(address account) external
    {
        if (msg.sender == address(this))
        {
            Agent.notifyTransferListener(account);
        }
    }

    function notifyAgentDouble(address account1, address account2) external
    {
        if (msg.sender == address(this))
        {
            Agent.notifyTransferListener(account1, account2);
        }
    }

    ///////////////////////////////////////////////////////////////

    function handleTransfer(address from, address to, uint256 value) private returns(bool)
    {
        if (Modifiers[from].isExcludedFromTax == 1 || Modifiers[to].isExcludedFromTax == 1 || Modifiers[from].isExcludedFromTax == 2 || Modifiers[to].isExcludedFromTax == 3)
        {
            transferWithoutTax(from, to, value);
        }
        else
        {
            uint256 txType = 0;
            if (Modifiers[from].isSellAddress == 0)
            {
                if (Modifiers[to].isSellAddress == 1)
                {
                    txType = 1;
                }
                else
                {
                    txType = 2;
                }
            }

            transferWithTax(from, to, value, txType);
        }

        referrerSystemData.currentRefferalTaxReduction = 0;
        referrerSystemData.nextSellTaxReduction = 0;
        
        return true;
    }

    function transferWithTax(address sender, address recipient, uint256 amount, uint256 txType) private
    {
        uint256 taxReduction = referrerSystemData.currentRefferalTaxReduction;

        if (txType == 0)
        {
            /*
            unchecked is safe because:
                1. initially taxReduction = referrerSystemData.currentRefferalTaxReduction <= max(uint16)
                2. Modifiers[recipient].buyTaxReduction <= max(uint32)
            Summary:
                uint256(max(uint16)) + max(uint32) < max(uint256)
            */
            unchecked
            {
                taxReduction += Modifiers[recipient].buyTaxReduction;
            }
        }
        else if (Modifiers[recipient].isSellAddress == 1)
        {
            if (referrerSystemData.nextSellTaxReduction > 0)
            {
                // see previous comment, shortly: uint256(max(uint16)) + max(uint16) < max(uint256)
                unchecked
                {
                    taxReduction += referrerSystemData.nextSellTaxReduction;
                }
            }
            else
            {
                // see previous comment, shortly: uint256(max(uint16)) + max(uint32) < max(uint256)
                unchecked
                {
                    taxReduction += Modifiers[recipient].sellTaxReduction;
                }
            }
        }

        uint256 tax = 0;
        if (taxReduction < Taxes[txType].total)
        {
            // unchecked is safe because taxReduction < Taxes[txType].total
            unchecked
            {
                tax = Taxes[txType].total - taxReduction;
            }
        }

        uint256 taxTokens = amount * tax / DENOMINATOR;

        doWork();

        _transfer(sender, recipient, amount, taxTokens, txType);

        notifyTaxSystem(sender, amount, taxTokens, txType);
    }

    function transferWithoutTax(address sender, address recipient, uint256 amount) private
    {
        _transfer(sender, recipient, amount, 0, 999);
    }

    /*
    @@@ audit revision - made function external and it is now called within the try catch block
    removed try catch block inside this function because of this
    that way we can guarantee doWork execution even if Agent contract won't have delegate method
    also removed reentrancy guard as now all pots are emptied before the external call
    */
    function deliverBNBToAgent(uint256 agentPotToSend) external
    {
        uint256 buyPot = potsBNB.buy - 1;
        uint256 sellPot = potsBNB.sell;
        uint256 transferPot = potsBNB.transfer - 1;
        uint256 referrerPot = potsBNB.referrer;
        uint256 teamPot = potsBNB.team;

        uint256 tokensUsedForReferrersPot = referrerSystemData.tokensUsedForReferrersPot;

        potsBNB.buy = 1;
        potsBNB.sell = 0;
        potsBNB.transfer = 1;
        potsBNB.referrer = 0;
        potsBNB.team = 0;

        referrerSystemData.tokensUsedForReferrersPot = 0;

        Agent.delegate{value: agentPotToSend}(buyPot, sellPot, transferPot, teamPot, referrerPot, tokensUsedForReferrersPot);
    }

    function notifyTaxSystem(address sender, uint256 amount, uint256 taxAmount, uint256 txType) private
    {
        TaxData storage taxData = Taxes[txType];
        uint256 totalTax = taxData.total;
        if (totalTax == 0)
        {
            return;
        }
        
        uint256 taxAmountScaled = taxAmount / TOKEN_POTS_DIVISOR;

        uint256 reflectionsAmount = taxAmountScaled * taxData.reflections / totalTax;

        uint256 liquidityAmount = taxAmountScaled * taxData.liquidity / totalTax;
        tokenPots.liquidity += uint40(liquidityAmount);

        uint256 referrerAmount = 0;
        if (referrerSystemData.isDefaultReferrer == 0 && referrerSystemData.currentRefferalTaxReduction > 0)
        {
            referrerAmount = taxAmountScaled * taxData.referrer / totalTax;
            tokenPots.referrer += uint40(referrerAmount);

            referrerSystemData.lastReferrerTokensAmount = uint96(referrerAmount * TOKEN_POTS_DIVISOR);
        }

        uint256 teamAmount = amount * taxData.team / DENOMINATOR / TOKEN_POTS_DIVISOR;
        if (taxAmountScaled < teamAmount + referrerAmount + liquidityAmount + reflectionsAmount)
        {
            teamAmount = taxAmountScaled * taxData.team / totalTax;
        }
        tokenPots.team += uint56(teamAmount);

        uint256 taxAmountPure = taxAmountScaled - reflectionsAmount - liquidityAmount - referrerAmount - teamAmount;
        if (txType == 0)
        {
            tokenPots.buy += uint40(taxAmountPure);
        }
        else if (txType == 1)
        {
            tokenPots.sell += uint40(taxAmountPure);
        }
        else
        {
            tokenPots.transfer += uint40(taxAmountPure);
        }

        reflectionsAmount = reflectionsAmount * TOKEN_POTS_DIVISOR + taxAmount - taxAmountScaled * TOKEN_POTS_DIVISOR;

        _balanceOf[address(this)] += taxAmount - reflectionsAmount;

        emit Transfer(sender, address(this), taxAmount - reflectionsAmount);

        calculateReflections(reflectionsAmount);
    }

    function calculateReflections(uint256 reflectionsAmount) private
    {
        ReflectionsData storage _reflections = reflections;

        _reflections.pot += uint96(reflectionsAmount);
        _reflections.perShareStored = reflectionsPerShare();

        uint256 takeFromPot;
        if (block.timestamp >= _reflections.periodEnd)
        {
            takeFromPot = uint256(_reflections.pot) * _reflections.potPartToDistribute / DENOMINATOR; 

            _reflections.rate = uint96(takeFromPot / _reflections.delay);
        }
        else
        {
            uint256 timeDifference;
            // unchecked usage is safe because block.timestamp < _reflections.periodEnd
            unchecked
            {
                timeDifference = _reflections.periodEnd - block.timestamp;
            }

            takeFromPot = uint256(_reflections.pot) * _reflections.potPartToDistribute * (_reflections.prevDelay - timeDifference) / _reflections.prevDelay / DENOMINATOR;

            uint256 toDistribute = takeFromPot + uint256(_reflections.rate) * timeDifference;

            _reflections.rate = uint96(toDistribute / _reflections.delay);
        }

        _reflections.pot -= uint96(takeFromPot);
        _reflections.lastUpdateTime = uint32(block.timestamp);

        // unchecked usage is safe because _reflections.delay < 604801 (see setReflectionsDelayAndDistributingPart())
        unchecked
        {
            _reflections.periodEnd = uint32(block.timestamp + _reflections.delay);
        }

        _reflections.prevDelay = _reflections.delay;
    }

    function updateMultiplierBalances(address account) private
    {
        uint256 usingMultiplier = getReflectionsMultiplier(account);

        uint256 newBalance;
        /*
        unchecked block usage is justified because:
            1. _balanceOf[account] <= MAX_SUPPLY = 10 ** 26, _balanceOf[account] is also uint256
            2. usingMultiplier <= reflections.maxMultiplier meaning that usingMultiplier <= 999999 (see setMaxAccountAndMaxMultiplier())
            3. _balanceOf[account] * usingMultiplier <= 10 ** 26 * 999999 < 10 ** 32
            5. so newBalance theoretically may be 10 ** 32 / 10 ** 18 / 100 < 10 ** 12
            6. 10 ** 12 < max(uint40)
        Summary:
            newBalance assignment cannot overflow cause its theoretical maximum in between of calculations is
                10 ** 32 < max(uint256)
            and its maximum at the end of calculations is
                max(uint40)
        */
        unchecked
        {
            newBalance = _balanceOf[account] * usingMultiplier / ONE / 100;
        }

        reflections.totalBalances = uint64(reflections.totalBalances - Modifiers[account].oldMultiplierBalance + newBalance);
    
        Modifiers[account].oldMultiplierBalance = uint64(newBalance);  
    }

    function updateReflections(address account) private
    {
        reflections.perShareStored = reflectionsPerShare();
        reflections.lastUpdateTime = lastTimeReflectionsApplicable();

        payReflections(account, reflections.perShareStored);
    }

    function payReflections(address account, uint256 perShareStored) private
    {
        uint256 _reflected = reflected(account, perShareStored);

        _balanceOf[account] += _reflected;

        emit Reflected(account, _reflected);

        ReflectionsPerSharePaid[account] = perShareStored;
    }

    function lastTimeReflectionsApplicable() private view returns(uint32)
    {
        if (block.timestamp < reflections.periodEnd)
        {
            return uint32(block.timestamp);
        }
        
        return reflections.periodEnd;
    }

    function reflectionsPerShare() private view returns(uint256)
    {
        if (reflections.totalBalances == 0)
        {
            return reflections.perShareStored;
        }

        return reflections.perShareStored + uint256(lastTimeReflectionsApplicable() - reflections.lastUpdateTime) * reflections.rate * ONE / reflections.totalBalances;
    }

    function getReflectionsMultiplier(address account) public view returns(uint256)
    {
        if (Modifiers[account].reflectionsMultiplier > reflections.maxMultiplier)
        {
            return reflections.maxMultiplier;
        }

        return Modifiers[account].reflectionsMultiplier;
    }

    function swapTaxTokensForBNB(uint256 totalCompressedTokens) private
    {
        PotsDataToken storage _tokenPots = tokenPots;

        uint256 toSwap;
        uint256 liquidityTokens;
        uint256 buyTokens;
        uint256 sellTokens;
        uint256 transferTokens;
        uint256 referrerTokens;
        uint256 teamTokens;
        if (totalCompressedTokens > workAmounts.tokensMax)
        {
            toSwap = workAmounts.tokensMax;

            liquidityTokens = toSwap * (_tokenPots.liquidity - 1) / totalCompressedTokens;
            buyTokens = toSwap * _tokenPots.buy / totalCompressedTokens;
            sellTokens = toSwap * _tokenPots.sell / totalCompressedTokens;
            transferTokens = toSwap * _tokenPots.transfer / totalCompressedTokens;
            referrerTokens = toSwap * _tokenPots.referrer / totalCompressedTokens;
            
            teamTokens = toSwap - liquidityTokens - buyTokens - sellTokens - transferTokens - referrerTokens;
        }
        else
        {
            toSwap = totalCompressedTokens;

            liquidityTokens = _tokenPots.liquidity - 1;
            buyTokens = _tokenPots.buy;
            sellTokens = _tokenPots.sell;
            transferTokens = _tokenPots.transfer;
            referrerTokens = _tokenPots.referrer;
            teamTokens = _tokenPots.team;
        }

        _tokenPots.liquidity -= uint40(liquidityTokens);
        _tokenPots.buy -= uint40(buyTokens);
        _tokenPots.sell -= uint40(sellTokens);
        _tokenPots.transfer -= uint40(transferTokens);
        _tokenPots.referrer -= uint40(referrerTokens);
        _tokenPots.team -= uint56(teamTokens);

        uint256 receivedBNB = swapTokensForBNB(toSwap * TOKEN_POTS_DIVISOR);

        PotsDataBNB storage _potsBNB = potsBNB;

        _potsBNB.liquidity += uint80(receivedBNB * liquidityTokens / toSwap);
        _potsBNB.buy += uint80(receivedBNB * buyTokens / toSwap);
        _potsBNB.sell += uint96(receivedBNB * sellTokens / toSwap);
        _potsBNB.transfer += uint80(receivedBNB * transferTokens / toSwap);
        _potsBNB.referrer += uint80(receivedBNB * referrerTokens / toSwap);
        _potsBNB.team += uint96(receivedBNB * teamTokens / toSwap);

        referrerSystemData.tokensUsedForReferrersPot += uint96(referrerTokens * TOKEN_POTS_DIVISOR);
    }

    function swapTokensForBNB(uint256 tokensAmount) private returns(uint256)
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256[] memory amountsOut = SwapRouter.swapExactTokensForETH(
            tokensAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        return amountsOut[1];
    }

    function swapBNBForTokens(uint256 amountBNB) private returns(uint256)
    {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        // to save gas it sends tokens to BURN_ADDRESS, which is a constant
        // you cannot swap a token with this same token contract as a recipient, so this trick is used
        uint256[] memory amountsOut = SwapRouter.swapExactETHForTokens{value: amountBNB}(
            0,
            path,
            BURN_ADDRESS,
            block.timestamp
        );

        uint256 amount = amountsOut[1];

        _balanceOf[BURN_ADDRESS] -= amount;

        // unchecked is safe because if we were able to subtract amount from _balanceOf[BURN_ADDRESS]
        // then we can safely add the amount to any balance cause token has no mint functionality
        unchecked
        {
            _balanceOf[address(this)] += amount;
        }

        emit Transfer(BURN_ADDRESS, address(this), amount);

        return amount;
    }

    function addLiquidityFromTokenReserves() private
    {
        uint80 liquidityPotBefore = potsBNB.liquidity;
        potsBNB.liquidity = 0;

        (uint256 addedTokens, uint256 addedBNB,) = SwapRouter.addLiquidityETH{value: liquidityPotBefore - 1}(
            address(this),
            tokenLiquidityReserves,
            0,
            0,
            address(this),
            block.timestamp
        );

        potsBNB.liquidity = liquidityPotBefore - uint80(addedBNB);
        tokenLiquidityReserves -= addedTokens;
    }

    function refillLiquidityTokenReserves() private
    {
        uint256 amountBNBtoBeSwapped = potsBNB.liquidity / 2;

        // unchecked is safe because amountBNBtoBeSwapped is a half of potsBNB.liquidity
        unchecked
        {
            potsBNB.liquidity -= uint80(amountBNBtoBeSwapped);
        }

        uint256 swappedTokens = swapBNBForTokens(amountBNBtoBeSwapped);
        tokenLiquidityReserves += swappedTokens;
    }

    function _addMultiplier(address account, uint32 difference, uint32 isAddition) private
    {
        require(account != address(this), "_AM0");

        updateReflections(account);

        if (isAddition == 1)
        {
            Modifiers[account].reflectionsMultiplier += difference;

            if (Shareholders.ItemToIndex[account] == 0)
            {
                Shareholders.add(account);
            }
        }
        else
        {
            uint32 newMultiplier = Modifiers[account].reflectionsMultiplier - difference;
            Modifiers[account].reflectionsMultiplier = newMultiplier;

            if (newMultiplier == 0)
            {
                Shareholders.remove(account);
            }
        }

        updateMultiplierBalances(account);
    }

    function _setBuyTaxReduction(address account, uint32 value) private
    {
        Modifiers[account].buyTaxReduction = value;
    }

    function _setSellTaxReduction(address account, uint32 value) private
    {
        Modifiers[account].sellTaxReduction = value;
    }

    function getCompressedTokenPotsSum() private view returns(uint256)
    {
        return tokenPots.liquidity + tokenPots.buy + tokenPots.sell + tokenPots.transfer + tokenPots.referrer + tokenPots.team - 1;
    }

    function getBNBPotsSumWithoutLiquidity() private view returns(uint256)
    {
        return uint256(potsBNB.buy) + potsBNB.sell + potsBNB.transfer + potsBNB.referrer + potsBNB.team - 2;
    }
}