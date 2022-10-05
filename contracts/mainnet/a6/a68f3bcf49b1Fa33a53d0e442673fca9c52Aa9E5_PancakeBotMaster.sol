// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interface/IPancakeRouter.sol";
import "./interface/IPancakeFactory.sol";
import "./interface/IPancakePair.sol";
import "./interface/IPancakeZapV1.sol";
import "./interface/IPancakeswapFarm.sol";

contract PancakeBotMaster is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct Exchange {
        address quoteToken;
        address baseToken;
        bool wbnbCross;
    }

    struct StaticPoolInfo {
        string poolName;
        uint256 pancakePID;
        address lpToken; // Address of the want token.
        Exchange busdExchange;
        Exchange cakeExchange;
    }

    struct PoolBalance {
        uint256 sharesTotal;
        uint256 lpLockedTotal;
        uint256 cake;
    }

    struct AutoCompound {
        bool enabled;
        uint256 lastEarnBlock;
    }

    struct PoolInfo {
        string poolName;
        uint256 pancakePID;
        address lpToken; // Address of the want token.
        Exchange busdExchange;
        Exchange cakeExchange;
        AutoCompound autoCompound;
        PoolBalance balance;
    }

    struct UserInfo {
        uint256 shares;
        uint256 lpBalance;
    }

    IPancakeFactory public constant factory =
        IPancakeFactory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    IPancakeZapV1 public constant zap =
        IPancakeZapV1(0xD4c4a7C55c9f7B3c48bafb6E8643Ba79F42418dF);
    IPancakeswapFarm public constant pancakeMasterChefV2 =
        IPancakeswapFarm(0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652); // pancake MasterChefV2
    address private constant routerAddress =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant wbnbAddress =
        0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant busdAddress =
        0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant cakeAddress =
        0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82; //CAKE
    address public constant ethAddress =
        0x2170Ed0880ac9A755fd29B2688956BD959F933F8; //ETH

    // Maximum integer (used for managing allowance)
    uint256 public constant MAX_INT = 2**256 - 1;
    // Minimum amount for a swap (derived from PancakeSwap)
    uint256 public constant MINIMUM_CAKE_AMOUNT = 1e12;
    uint256 public constant MAX_BP = 1000;
    uint256 public swapSlippageFactorBP = 900; // 90%
    uint256 public feesBP = 30; //3%
    uint256 public constant MAX_FEE_BP = 100; // 10%
    uint256 public busdFee = 3 ether;

    mapping(address => bool) public admins;

    PoolInfo[] public poolInfo; // Info of each pool.
    //       user              pid       shares/lpBalance
    mapping(address => mapping(uint256 => UserInfo)) public userInfo;
    mapping(address => uint256) public balance;
    mapping(uint256 => bool) public pancakePidAlreadyAdded;

    event AddPool(
        uint256 indexed pid,
        uint256 indexed pancakePID,
        bool isAutoCompound
    );
    event PoolAutoCompound(uint256 indexed pid, bool isAutoCompound);
    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);
    event CreateLP(
        address indexed user,
        uint256 indexed pid,
        uint256 busdAmount,
        uint256 lpCreated
    );
    event RemoveLP(
        address indexed user,
        uint256 indexed pid,
        uint256 busdAmount,
        uint256 lpRemoved
    );
    event Stake(address indexed user, uint256 indexed pid, uint256 amount);
    event UnStake(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyUnStake(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    modifier isEOA() {
        uint256 size;
        address sender = msg.sender;
        assembly {
            size := extcodesize(sender)
        }
        require(size == 0 && msg.sender == tx.origin, "human only");
        _;
    }

    modifier onlyBotsOrUser(address sender) {
        require(
            sender == msg.sender || admins[msg.sender],
            "not allowed"
        );
        _;
    }

    modifier correctPID(uint256 pid) {
        require(pid < poolInfo.length, "bad pid");
        _;
    }


    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function setSwapSlippageFactorBP(uint256 _swapSlippageFactorBP)
        external
        onlyOwner
    {
        require(_swapSlippageFactorBP < MAX_BP, "should be < MAX_BP");
        swapSlippageFactorBP = _swapSlippageFactorBP;
    }

    function setFeesBP(uint256 _feesBP) external onlyOwner {
        require(_feesBP < MAX_FEE_BP, "should be < MAX_FEE_BP");
        feesBP = _feesBP;
    }

    function setBUSDfee(uint256 _busdFee) external onlyOwner {
        require(_busdFee < 10 ether, "should be < 10 BUSD");
        busdFee = _busdFee;
    }

    function addAdmin(address admin,bool allowed) external onlyOwner {
        admins[admin]=allowed;
    }

    function setPoolAutoCompound(uint256 pid, bool isAutoCompound)
        external
        correctPID(pid)
        onlyOwner
    {
        poolInfo[pid].autoCompound.enabled = isAutoCompound;
        emit PoolAutoCompound(pid, isAutoCompound);
    }

    /// @notice Add a new pool. Can only be called by the owner.
    /// DO NOT add the same pancake PID more than once.
    /// @param _pancakePID pancake PID.
    /// @param _isAutoCompound enable autoCompound logic.
    /// @param _ignoreErrors without revert
    function addPool(
        uint256 _pancakePID,
        bool _isAutoCompound,
        bool _ignoreErrors
    ) external onlyOwner {
        StaticPoolInfo memory pool = getStaticPancakePoolProperties(
            _pancakePID
        );

        if (
            pool.busdExchange.quoteToken != address(0) &&
            pool.cakeExchange.quoteToken != address(0)
        ) {
            pancakePidAlreadyAdded[_pancakePID] = true;
            PoolInfo memory extPool;
            assembly {
                extPool := pool
            }
            extPool.autoCompound.enabled = _isAutoCompound;
            extPool.autoCompound.lastEarnBlock = block.number;
            extPool.balance = PoolBalance(0, 0, 0);
            poolInfo.push(extPool);
            emit AddPool(poolInfo.length - 1, _pancakePID, _isAutoCompound);
        } else if (!_ignoreErrors) {
            require(
                pancakePidAlreadyAdded[_pancakePID] == false,
                "already added"
            );

            require(
                pool.pancakePID < pancakeMasterChefV2.poolLength(),
                "pool not exist"
            );
            require(
                pancakeMasterChefV2.lpToken(_pancakePID) != address(0),
                "lpToken is zero"
            );
            PancakePoolInfo memory ppinfo = pancakeMasterChefV2.poolInfo(
                pool.pancakePID
            );
            require(
                ppinfo.isRegular,
                "special pool!"
            );

            require(
                pool.busdExchange.quoteToken != address(0),
                "busd-qToken not found"
            );
            revert("cake-qToken not found");
        }
    }

    function _swap(uint256 _amountIn, address[] memory _path)
        internal
        returns (uint256[] memory swapedAmounts)
    {
        IERC20(_path[0]).safeIncreaseAllowance(routerAddress, _amountIn);

        uint256[] memory amounts = IPancakeRouter02(routerAddress)
            .getAmountsOut(_amountIn, _path);
        uint256 amountOut = (amounts[amounts.length - 1] *
            swapSlippageFactorBP) / MAX_BP;

        swapedAmounts = IPancakeRouter02(routerAddress)
            .swapExactTokensForTokens(
                _amountIn,
                amountOut,
                _path,
                address(this),
                block.timestamp
            );
    }

    function _exchange(
        uint256 amountIn,
        address fromToken,
        address toToken,
        bool wbnbCross
    ) internal returns (uint256 swapedAmtFrom, uint256 swapedAmtTo) {
        address[] memory path = new address[](wbnbCross ? 3 : 2);
        if (wbnbCross) {
            path[0] = fromToken;
            path[1] = wbnbAddress;
            path[2] = toToken;
        } else {
            path[0] = fromToken;
            path[1] = toToken;
        }
        uint256[] memory swapedAmounts = _swap(amountIn, path);
        swapedAmtFrom = swapedAmounts[0];
        swapedAmtTo = swapedAmounts[swapedAmounts.length - 1];
    }

    /// @param pid PID PID on this contract
    /// @param busdAmount used BUSD from the user's balance on the contract
    /// @param userAddress user's address
    function createLP(
        uint256 pid,
        uint256 busdAmount,
        address userAddress
    )
        external
        nonReentrant
        onlyBotsOrUser(userAddress)
        correctPID(pid)
        returns (uint256 busdSwaped, uint256 lpCreated)
    {
        require(
            balance[userAddress] >= busdAmount,
            "exceeds balance"
        );

        require(
            busdAmount>busdFee,
            "amount too small"
        );

        unchecked{busdAmount-=busdFee;}
        if(busdFee>0){IERC20(busdAddress).safeTransfer(owner(), busdFee);}

        UserInfo storage user = userInfo[userAddress][pid];
        PoolInfo memory pool = poolInfo[pid];
        uint256 quoteTokenAmt = 0;
        if (pool.busdExchange.quoteToken != busdAddress) {
            (busdSwaped, quoteTokenAmt) = _exchange(
                busdAmount,
                busdAddress,
                pool.busdExchange.quoteToken,
                pool.busdExchange.wbnbCross
            );
        } else {
            busdSwaped = busdAmount;
            quoteTokenAmt = busdAmount;
        }
        uint256 busdSwapedWithFee=busdSwaped+busdFee;
        balance[userAddress] -= busdSwapedWithFee;
        uint256 balanceBefore = IERC20(pool.lpToken).balanceOf(address(this));
        IERC20(pool.busdExchange.quoteToken).safeIncreaseAllowance(
            address(zap),
            quoteTokenAmt
        );
        zap.zapInToken(
            pool.busdExchange.quoteToken,
            quoteTokenAmt,
            pool.lpToken,
            0
        );
        lpCreated =
            IERC20(pool.lpToken).balanceOf(address(this)) -
            balanceBefore;
        user.lpBalance += lpCreated;

        emit CreateLP(userAddress, pid, busdSwapedWithFee, lpCreated);
    }

    function removeLP(uint256 pid, address userAddress)
        external
        nonReentrant
        onlyBotsOrUser(userAddress)
        correctPID(pid)
        returns (uint256 busdSwaped, uint256 lpRemoved)
    {
        UserInfo storage user = userInfo[userAddress][pid];
        require(user.lpBalance > 0, "lpBalance is 0");
        lpRemoved = user.lpBalance;

        PoolInfo memory pool = poolInfo[pid];

        uint256 balanceBefore = IERC20(pool.busdExchange.quoteToken).balanceOf(
            address(this)
        );

        IERC20(pool.lpToken).safeIncreaseAllowance(address(zap), lpRemoved);

        zap.zapOutToken(
            pool.lpToken,
            pool.busdExchange.quoteToken,
            lpRemoved,
            0,
            0
        );

        uint256 quoteTokenOut = IERC20(pool.busdExchange.quoteToken).balanceOf(
            address(this)
        ) - balanceBefore;
        if (pool.busdExchange.quoteToken != busdAddress) {
            (,busdSwaped) = _exchange(
                quoteTokenOut,
                pool.busdExchange.quoteToken,
                busdAddress,
                pool.busdExchange.wbnbCross
            );
        } else {
            busdSwaped = quoteTokenOut;
        }

        balance[userAddress] += busdSwaped;
        user.lpBalance = 0;
        emit RemoveLP(userAddress, pid, busdSwaped, lpRemoved);
    }

    function getStaticPancakePoolProperties(uint256 _pancakePID)
        public
        view
        returns (StaticPoolInfo memory pool)
    {
        if (
            pancakePidAlreadyAdded[_pancakePID] == false &&
            _pancakePID < pancakeMasterChefV2.poolLength()
        ) {
            pool.lpToken = pancakeMasterChefV2.lpToken(_pancakePID);
            PancakePoolInfo memory ppinfo = pancakeMasterChefV2.poolInfo(
                _pancakePID
            );
            if (pool.lpToken != address(0) && ppinfo.isRegular) {
                pool.pancakePID = _pancakePID;
                address token0 = IPancakePair(pool.lpToken).token0();
                address token1 = IPancakePair(pool.lpToken).token1();

                address[] memory _quoteTokensBUSD = new address[](7);
                _quoteTokensBUSD[
                    0
                ] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BUSD
                _quoteTokensBUSD[
                    1
                ] = 0x55d398326f99059fF775485246999027B3197955; //USDT
                _quoteTokensBUSD[
                    2
                ] = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d; //USDC
                _quoteTokensBUSD[
                    3
                ] = 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3; //DAI
                _quoteTokensBUSD[
                    4
                ] = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c; //BTCB
                _quoteTokensBUSD[
                    5
                ] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //WBNB
                _quoteTokensBUSD[
                    6
                ] = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82; //CAKE

                pool.busdExchange = _getQuoteBaseTokens(
                    token0,
                    token1,
                    _quoteTokensBUSD
                );

                if (pool.busdExchange.quoteToken != address(0)) {
                    pool.poolName = string.concat(
                        IERC20Metadata(pool.busdExchange.quoteToken).symbol(),
                        "-",
                        IERC20Metadata(pool.busdExchange.baseToken).symbol()
                    );

                    address[] memory _quoteTokensCAKE = new address[](4);
                    _quoteTokensCAKE[
                        0
                    ] = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82; //CAKE
                    _quoteTokensCAKE[
                        1
                    ] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BUSD
                    _quoteTokensCAKE[
                        2
                    ] = 0x55d398326f99059fF775485246999027B3197955; //USDT
                    _quoteTokensCAKE[
                        3
                    ] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //WBNB

                    pool.cakeExchange = _getQuoteBaseTokens(
                        token0,
                        token1,
                        _quoteTokensCAKE
                    );
                }
            }
        }
    }

    function _getQuoteBaseTokens(
        address token0,
        address token1,
        address[] memory _qTokens
    ) internal view returns (Exchange memory ex) {
        for (uint256 i = 0; i < _qTokens.length; i++) {
            if (_qTokens[i] == token0) {
                ex.quoteToken = token0;
                ex.baseToken = token1;
                break;
            }
            if (_qTokens[i] == token1) {
                ex.quoteToken = token1;
                ex.baseToken = token0;
                break;
            }
        }
        if (ex.quoteToken == address(0)) {
            ex.wbnbCross = true;
            if (token0 == ethAddress) {
                ex.quoteToken = token0;
                ex.baseToken = token1;
            } else if (token1 == ethAddress) {
                ex.quoteToken = token1;
                ex.baseToken = token0;
            } else {
                address lp0 = factory.getPair(wbnbAddress, token0);
                address lp1 = factory.getPair(wbnbAddress, token1);
                if (lp0 != address(0) && lp1 != address(0)) {
                    (uint112 reserves0_0, uint112 reserves1_0, ) = IPancakePair(
                        lp0
                    ).getReserves();
                    (uint112 reserves0_1, uint112 reserves1_1, ) = IPancakePair(
                        lp1
                    ).getReserves();
                    uint256 wbnbReserves0 = IPancakePair(lp0).token0() ==
                        wbnbAddress
                        ? reserves0_0
                        : reserves1_0;
                    uint256 wbnbReserves1 = IPancakePair(lp1).token0() ==
                        wbnbAddress
                        ? reserves0_1
                        : reserves1_1;
                    if (wbnbReserves0 > wbnbReserves1) {
                        ex.quoteToken = token0;
                        ex.baseToken = token1;
                    } else {
                        ex.quoteToken = token1;
                        ex.baseToken = token0;
                    }
                } else if (lp0 != address(0)) {
                    ex.quoteToken = token0;
                    ex.baseToken = token1;
                } else if (lp1 != address(0)) {
                    ex.quoteToken = token1;
                    ex.baseToken = token0;
                }
            }
        }
    }

    // deposit BUSD
    function deposit(uint256 amount) external isEOA {
        IERC20(busdAddress).safeTransferFrom(msg.sender, address(this), amount);
        balance[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    // withdraw BUSD
    function withdraw(uint256 amount,bool all) external {
        if(all){amount=balance[msg.sender];}
        require(
            balance[msg.sender] >= amount,
            "exceeds balance"
        );
        balance[msg.sender] -= amount;
        IERC20(busdAddress).safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    /// @notice deposit to pancake pool.
    /// @param pid PID on this contract.
    /// @param lpAmount will be taken from the user's balance on this contract
    /// @param userAddress user's address
    function stake(
        uint256 pid,
        uint256 lpAmount,
        address userAddress
    ) external correctPID(pid) onlyBotsOrUser(userAddress) nonReentrant {
        UserInfo storage user = userInfo[userAddress][pid];
        require(user.lpBalance >= lpAmount, "exceeds balance");
        user.lpBalance -= lpAmount;

        PoolInfo storage pool = poolInfo[pid];
        PoolBalance storage pBalance = pool.balance;

        if (lpAmount > 0) {
            IERC20(pool.lpToken).safeIncreaseAllowance(
                address(pancakeMasterChefV2),
                lpAmount
            );
        }
        pBalance.cake += _farm(pool.pancakePID, lpAmount);

        if (pBalance.cake > MINIMUM_CAKE_AMOUNT) {
            _earn(pid, 0);
        } else if (pool.autoCompound.enabled) {
            uint256 _pid = getPoolThatNeedsEarnings();
            _helpToEarn(_pid);
        }

        uint256 sharesAdded = 0;
        if (pBalance.lpLockedTotal > 0 && pBalance.sharesTotal > 0) {
            sharesAdded =
                (lpAmount * pBalance.sharesTotal) /
                pBalance.lpLockedTotal;
        } else {
            sharesAdded = lpAmount;
        }

        pBalance.lpLockedTotal += lpAmount;
        pBalance.sharesTotal += sharesAdded;
        user.shares += sharesAdded;
        emit Stake(userAddress, pid, lpAmount);
    }

    /// @notice withdraw from pancake pool.
    /// @param pid PID on this contract.
    /// @param lpAmount withdraw amount
    /// @param userAddress user's address
    function unstake(
        uint256 pid,
        uint256 lpAmount,
        address userAddress,
        bool isEmergency
    ) external correctPID(pid) onlyBotsOrUser(userAddress) nonReentrant {
        UserInfo storage user = userInfo[userAddress][pid];
        require(user.shares > 0, "user.shares is 0");
        PoolInfo storage pool = poolInfo[pid];
        PoolBalance storage pBalance = pool.balance;

        uint256 maxLpAmount = (user.shares * pBalance.lpLockedTotal) /
            pBalance.sharesTotal;
        if (lpAmount > maxLpAmount) {
            lpAmount = maxLpAmount;
        }

        pBalance.cake += _unfarm(pool.pancakePID, lpAmount);

        uint256 sharesRemoved = (lpAmount * pBalance.sharesTotal) /
            pBalance.lpLockedTotal;
        if (sharesRemoved > user.shares) {
            sharesRemoved = user.shares;
        }
        uint256 bonusLp = 0;
        if (!isEmergency) {
            if (pBalance.cake > MINIMUM_CAKE_AMOUNT) {
                bonusLp = _earn(pid, sharesRemoved);
            } else if (pool.autoCompound.enabled) {
                uint256 _pid = getPoolThatNeedsEarnings();
                _helpToEarn(_pid);
            }
        }

        pBalance.sharesTotal -= sharesRemoved;
        pBalance.lpLockedTotal -= lpAmount;
        user.shares -= sharesRemoved;
        user.lpBalance += lpAmount + bonusLp;
        if (isEmergency) {
            emit EmergencyUnStake(userAddress, pid, lpAmount);
        } else {
            emit UnStake(userAddress, pid, lpAmount + bonusLp);
        }
    }

    function _farm(uint256 pancakePID, uint256 lpAmt)
        internal
        returns (uint256 receivedCake)
    {
        uint256 cakeBalanceBefore = IERC20(cakeAddress).balanceOf(
            address(this)
        );
        pancakeMasterChefV2.deposit(pancakePID, lpAmt);
        receivedCake = (IERC20(cakeAddress).balanceOf(address(this)) -
            cakeBalanceBefore);
    }

    function _unfarm(uint256 pancakePID, uint256 lpAmt)
        internal
        returns (uint256 receivedCake)
    {
        uint256 cakeBalanceBefore = IERC20(cakeAddress).balanceOf(
            address(this)
        );
        pancakeMasterChefV2.withdraw(pancakePID, lpAmt);
        receivedCake = (IERC20(cakeAddress).balanceOf(address(this)) -
            cakeBalanceBefore);
    }

    /// @notice getting the number of the pool with the oldest earn() time
    function getPoolThatNeedsEarnings() public view returns (uint256 _i) {
        for (uint256 i = _i + 1; i < poolInfo.length; i++) {
            if (
                poolInfo[i].autoCompound.enabled &&
                poolInfo[i].autoCompound.lastEarnBlock <
                poolInfo[_i].autoCompound.lastEarnBlock
            ) {
                _i = i;
            }
        }
    }

    function helpToEarn(uint256 _pid) external nonReentrant {
        _helpToEarn(_pid);
    }

    function _helpToEarn(uint256 _pid) internal {
        if (
            pancakeMasterChefV2.pendingCake(
                poolInfo[_pid].pancakePID,
                address(this)
            ) > MINIMUM_CAKE_AMOUNT
        ) {
            // harvest
            poolInfo[_pid].balance.cake += _farm(poolInfo[_pid].pancakePID, 0);
            _earn(_pid, 0);
        } else {
            poolInfo[_pid].autoCompound.lastEarnBlock = block.number; // next time
        }
    }

    function _earn(uint256 pid, uint256 userShare)
        internal
        returns (uint256 userLp)
    {
        PoolInfo storage pool = poolInfo[pid];
        pool.autoCompound.lastEarnBlock = block.number;
        if (pool.balance.cake < MINIMUM_CAKE_AMOUNT) {
            return 0;
        }
        uint256 cakeAmt = pool.balance.cake;

        cakeAmt = distributeFees(cakeAmt);
        uint256 quoteSwapedAmt = cakeAmt;
        uint256 cakeSwapedAmt = cakeAmt;

        if (pool.cakeExchange.quoteToken != cakeAddress) {
            // Converts farm CAKE into quoteToken tokens
            (cakeSwapedAmt, quoteSwapedAmt) = _exchange(
                cakeAmt,
                cakeAddress,
                pool.cakeExchange.quoteToken,
                pool.cakeExchange.wbnbCross
            );
        }

        uint256 balanceBefore = IERC20(pool.lpToken).balanceOf(address(this));
        IERC20(pool.cakeExchange.quoteToken).safeIncreaseAllowance(
            address(zap),
            quoteSwapedAmt
        );
        zap.zapInToken(
            pool.cakeExchange.quoteToken,
            quoteSwapedAmt,
            pool.lpToken,
            0
        );
        uint256 lpCreated = IERC20(pool.lpToken).balanceOf(address(this)) -
            balanceBefore;
        userLp = userShare>0 ? (lpCreated * userShare) / pool.balance.sharesTotal:0;
        lpCreated -= userLp;
        if (lpCreated > 0) {
            IERC20(pool.lpToken).safeIncreaseAllowance(
                address(pancakeMasterChefV2),
                lpCreated
            );
        }
        pool.balance.cake =
            _farm(pool.pancakePID, lpCreated) +
            (cakeAmt - cakeSwapedAmt);
        pool.balance.lpLockedTotal += lpCreated;
    }

    function distributeFees(uint256 _earnedAmt) internal returns (uint256) {
        if (_earnedAmt > 0) {
            uint256 fee = (_earnedAmt * feesBP) / MAX_BP;
            IERC20(cakeAddress).safeTransfer(owner(), fee);
            _earnedAmt -= fee;
        }

        return _earnedAmt;
    }

    function convertLpToBUSD(uint256 pid, uint256 lpAmount)
        public
        view
        returns (uint256 busdAmount)
    {
        PoolInfo memory pool = poolInfo[pid];

        address token0 = IPancakePair(pool.lpToken).token0();
        address token1 = IPancakePair(pool.lpToken).token1();
        (uint256 reserveA, uint256 reserveB, ) = IPancakePair(pool.lpToken)
            .getReserves();
        uint256 amount0 = (lpAmount * reserveA) /
            IPancakePair(pool.lpToken).totalSupply();
        uint256 amount1 = (lpAmount * reserveB) /
            IPancakePair(pool.lpToken).totalSupply();
        if (amount0 < 1000 || amount1 < 1000) {
            return 0;
        }
        uint256 quoteTokenAmt = 0;
        address[] memory expath = new address[](2);
        expath[1] = pool.busdExchange.quoteToken;

        if (token1 == pool.busdExchange.quoteToken) {
            // sell token0
            expath[0] = token0;
            quoteTokenAmt = amount1 + _calcSwapOut(amount0, expath);
        } else {
            // sell token1
            expath[0] = token1;
            quoteTokenAmt = amount0 + _calcSwapOut(amount1, expath);
        }

        if (pool.busdExchange.quoteToken != busdAddress) {
            address[] memory path = new address[](
                pool.busdExchange.wbnbCross ? 3 : 2
            );
            if (pool.busdExchange.wbnbCross) {
                path[0] = pool.busdExchange.quoteToken;
                path[1] = wbnbAddress;
                path[2] = busdAddress;
            } else {
                path[0] = pool.busdExchange.quoteToken;
                path[1] = busdAddress;
            }
            busdAmount = _calcSwapOut(quoteTokenAmt, path);
        } else {
            busdAmount = quoteTokenAmt;
        }
    }

    function _calcSwapOut(uint256 amountIn, address[] memory path)
        internal
        view
        returns (uint256 amountOut)
    {
        uint256[] memory amounts = IPancakeRouter02(routerAddress)
            .getAmountsOut(amountIn, path);
        amountOut = amounts[amounts.length - 1];
    }

    function getTVL(uint256 pid) public view returns (uint256) {
        return convertLpToBUSD(pid, poolInfo[pid].balance.lpLockedTotal);
    }

    function getStakedInBUSD(uint256 pid, address userAddress)
        public
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[userAddress][pid];
        uint256 maxLpAmount = (user.shares *
            poolInfo[pid].balance.lpLockedTotal) /
            poolInfo[pid].balance.sharesTotal;
        return convertLpToBUSD(pid, maxLpAmount);
    }

    function getTotalUserBalanceInBUSD(address userAddress)
        public
        view
        returns (uint256 totalBalance)
    {
        mapping(uint256 => UserInfo) storage user = userInfo[userAddress];
        for (uint256 i = 0; i < poolInfo.length; i++) {
            totalBalance += balance[userAddress];
            if (user[i].lpBalance > 0) {
                totalBalance += convertLpToBUSD(i, user[i].lpBalance);
            }
            if (user[i].shares > 0) {
                totalBalance += getStakedInBUSD(i, userAddress);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

struct PancakePoolInfo {
        uint256 accCakePerShare;
        uint256 lastRewardBlock;
        uint256 allocPoint;
        uint256 totalBoostedShare;
        bool isRegular;
}

interface IPancakeswapFarm {
    
    function lpToken(uint256 _pid) external view returns (address);
    function poolInfo(uint256 _pid) external view returns (PancakePoolInfo memory);
    function poolLength() external view returns (uint256);
    function pendingCake(uint256 _pid, address _user) external view returns (uint256);

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function userInfo(uint256 _pid, address _user)
        external
        view
        returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IPancakeZapV1 {
    /*
     * @notice Zap BNB in a WBNB pool (e.g. WBNB/token)
     * @param _lpToken: LP token address (e.g. CAKE/BNB)
     * @param _tokenAmountOutMin: minimum token amount (e.g. CAKE) to receive in the intermediary swap (e.g. BNB --> CAKE)
     */
    function zapInBNB(address _lpToken, uint256 _tokenAmountOutMin) external payable;
    /*
     * @notice Zap a token in (e.g. token/other token)
     * @param _tokenToZap: token to zap
     * @param _tokenAmountIn: amount of token to swap
     * @param _lpToken: LP token address (e.g. CAKE/BUSD)
     * @param _tokenAmountOutMin: minimum token to receive (e.g. CAKE) in the intermediary swap (e.g. BUSD --> CAKE)
     */
    function zapInToken(
        address _tokenToZap,
        uint256 _tokenAmountIn,
        address _lpToken,
        uint256 _tokenAmountOutMin
    ) external;

    /*
     * @notice Zap two tokens in, rebalance them to 50-50, before adding them to LP
     * @param _token0ToZap: address of token0 to zap
     * @param _token1ToZap: address of token1 to zap
     * @param _token0AmountIn: amount of token0 to zap
     * @param _token1AmountIn: amount of token1 to zap
     * @param _lpToken: LP token address (token0/token1)
     * @param _tokenAmountInMax: maximum token amount to sell (in token to sell in the intermediary swap)
     * @param _tokenAmountOutMin: minimum token to receive in the intermediary swap
     * @param _isToken0Sold: whether token0 is expected to be sold (if false, sell token1)
     */
    function zapInTokenRebalancing(
        address _token0ToZap,
        address _token1ToZap,
        uint256 _token0AmountIn,
        uint256 _token1AmountIn,
        address _lpToken,
        uint256 _tokenAmountInMax,
        uint256 _tokenAmountOutMin,
        bool _isToken0Sold
    ) external;

    /*
     * @notice Zap 1 token and BNB, rebalance them to 50-50, before adding them to LP
     * @param _token1ToZap: address of token1 to zap
     * @param _token1AmountIn: amount of token1 to zap
     * @param _lpToken: LP token address
     * @param _tokenAmountInMax: maximum token amount to sell (in token to sell in the intermediary swap)
     * @param _tokenAmountOutMin: minimum token to receive in the intermediary swap
     * @param _isToken0Sold: whether token0 is expected to be sold (if false, sell token1)
     */
    function zapInBNBRebalancing(
        address _token1ToZap,
        uint256 _token1AmountIn,
        address _lpToken,
        uint256 _tokenAmountInMax,
        uint256 _tokenAmountOutMin,
        bool _isToken0Sold
    ) external payable;

    /*
     * @notice Zap a LP token out to receive BNB
     * @param _lpToken: LP token address (e.g. CAKE/WBNB)
     * @param _lpTokenAmount: amount of LP tokens to zap out
     * @param _tokenAmountOutMin: minimum amount to receive (in BNB/WBNB) in the intermediary swap (e.g. CAKE --> BNB)
     */
    function zapOutBNB(
        address _lpToken,
        uint256 _lpTokenAmount,
        uint256 _tokenAmountOutMin
    ) external;

    /*
     * @notice Zap a LP token out (to receive a token)
     * @param _lpToken: LP token address (e.g. CAKE/BUSD)
     * @param _tokenToReceive: one of the 2 tokens from the LP (e.g. CAKE or BUSD)
     * @param _lpTokenAmount: amount of LP tokens to zap out
     * @param _tokenAmountOutMin: minimum token to receive (e.g. CAKE) in the intermediary swap (e.g. BUSD --> CAKE)
     */
    function zapOutToken(
        address _lpToken,
        address _tokenToReceive,
        uint256 _lpTokenAmount,
        uint256 _tokenAmountOutMin,
        uint256 _totalTokenAmountOutMin
    ) external;

    /*
     * @notice View the details for single zap
     * @dev Use WBNB for _tokenToZap (if BNB is the input)
     * @param _tokenToZap: address of the token to zap
     * @param _tokenAmountIn: amount of token to zap inputed
     * @param _lpToken: address of the LP token
     * @return swapAmountIn: amount that is expected to get swapped in intermediary swap
     * @return swapAmountOut: amount that is expected to get received in intermediary swap
     * @return swapTokenOut: token address of the token that is used in the intermediary swap
     */
    function estimateZapInSwap(
        address _tokenToZap,
        uint256 _tokenAmountIn,
        address _lpToken
    )
        external
        view
        returns (
            uint256 swapAmountIn,
            uint256 swapAmountOut,
            address swapTokenOut
        );
    /*
     * @notice View the details for a rebalancing zap
     * @dev Use WBNB for _token0ToZap (if BNB is the input)
     * @param _token0ToZap: address of the token0 to zap
     * @param _token1ToZap: address of the token0 to zap
     * @param _token0AmountIn: amount for token0 to zap
     * @param _token1AmountIn: amount for token1 to zap
     * @param _lpToken: address of the LP token
     * @return swapAmountIn: amount that is expected to get swapped in intermediary swap
     * @return swapAmountOut: amount that is expected to get received in intermediary swap
     * @return isToken0Sold: whether the token0 is sold (false --> token1 is sold in the intermediary swap)
     */
    function estimateZapInRebalancingSwap(
        address _token0ToZap,
        address _token1ToZap,
        uint256 _token0AmountIn,
        uint256 _token1AmountIn,
        address _lpToken
    )
        external
        view
        returns (
            uint256 swapAmountIn,
            uint256 swapAmountOut,
            bool sellToken0
        );
    /*
     * @notice View the details for single zap
     * @dev Use WBNB for _tokenToReceive (if BNB is the asset to be received)
     * @param _lpToken: address of the LP token to zap out
     * @param _lpTokenAmount: amount of LP token to zap out
     * @param _tokenToReceive: token address to receive
     * @return swapAmountIn: amount that is expected to get swapped for intermediary swap
     * @return swapAmountOut: amount that is expected to get received for intermediary swap
     * @return swapTokenOut: address of the token that is sold in the intermediary swap
     */
    function estimateZapOutSwap(
        address _lpToken,
        uint256 _lpTokenAmount,
        address _tokenToReceive
    )
        external
        view
        returns (
            uint256 swapAmountIn,
            uint256 swapAmountOut,
            address swapTokenOut
        );
    
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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

interface IPancakeRouter02 is IPancakeRouter01 {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

interface IPancakePair {
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}