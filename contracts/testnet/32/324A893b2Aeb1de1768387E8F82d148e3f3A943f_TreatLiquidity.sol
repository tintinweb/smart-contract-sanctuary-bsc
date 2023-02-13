// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IPair.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/ITreatToken.sol";
import "./interfaces/ITreatLiquidity.sol";
import "./interfaces/IWETH.sol";
import "./VestingManager.sol";
import "./SafeOwnable.sol";

// @title Contract that allows you to add or remove liquidity with Treat Token without vesting fees
// Treat tokens continue vesting process while being added to liquidity
// Unlike other vesting contracts, TreatLiquidity vests token percentage, not token amount.
// If you have deposited into liquidity 100 TreatTokens, 70% of which were locked and the next moment your LP tokens
// are worth 150 TreatTokens, 70% of them will still be locked.
contract TreatLiquidity is SafeOwnable, ReentrancyGuard, ITreatLiquidity {
    using SafeERC20 for IERC20;
    struct DepositInfo {
        address tokenB;                 // TokenB address of TokenB<>Treat pair
        address lpToken;                // LP token address
        uint256 lpTokenAmount;          // Amount of LP tokens that user received with this smart contract
        uint256 treatAmount;            // Amount of Treat tokens that user could receive after removing liquidity
        uint256 locked;                 // Amount of locked tokens from `treatAmount`
        uint256 lockedPercentage;       // Percentage of TreatTokens locked, where 1e9 is 100%
        uint256 remainingVestingTime;   // Remaining vesting time until full unlock
        uint256 vestingDuration;        // Vesting duration for this pair
    }

    ITreatToken public immutable treatToken;
    address public immutable router;
    address public immutable WETH;
    IFactory public immutable factory;
    uint256 private constant BASE_PERCENTAGE = 1e9;

    uint32 public defaultVestingDuration;       // default vesting duration

    //tokenB => specialVestingDuration
    mapping(address => uint32) private specialVestingDuration;
    //account => tokenB => VestingData
    mapping(address => mapping(address => VestingManager.VestingData)) public tokenVesting;
    //user => tokenB => LP tokens deposited
    mapping(address => mapping(address => uint256)) public liquidityDeposits;
    //(linked list) user account => tokenB of added by the user liquidity Treat<>TokenB
    // first and last elements are address(0x1) sentinels
    mapping(address => mapping(address => address)) private depositedPairTokens;

    event LiquidityAdded(address account, address tokenB, uint256 liquidity);
    event LiquidityRemoved(address account, address tokenB, uint256 liquidity);
    event NewDefaultVestingDuration(uint32);
    event NewSpecialVestingDuration(address tokenB, uint32 vestingDuration);
    event ERC20Recovered(address token, uint256 amount, address account);

    /*
     * @param _treatToken TreatToken address
     * @param _router Router address
     * @param _defaultVestingDuration Default vesting duration
     */
    constructor(
        ITreatToken _treatToken,
        address _router,
        uint32 _defaultVestingDuration
    ) {
        require(address(_treatToken) != address(0) && _router != address(0));
        treatToken = _treatToken;
        router = _router;
        address _factory = IRouter(_router).factory();
        address _WETH = IRouter(_router).WETH();
        factory = IFactory(_factory);
        WETH = _WETH;

        defaultVestingDuration = _defaultVestingDuration;
    }

    // Receive ETH
    receive() external payable {}


    /*
     * @notice Adds TreatToken<>Token liquidity and sends LP tokens to msg.sender
     * @param TokenB address
     * @param Desired amount of TreatToken to add to liquidity
     * @param Desired amount of TokenB to add to liquidity
     * @param Minimum amount of TreatToken to add to liquidity
     * @param Minimum amount of TokenB to add to liquidity
     * @param Deadline
     * @return Amount of TreatToken, that was added to liquidity
     * @return Amount of TokenB, that was added to liquidity
     * @return Amount of liquidity received
     */
    function addLiquidity(
        address tokenB,
        uint256 amountTreatDesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        return addLiquidityOnBehalf(
            msg.sender,
            tokenB,
            amountTreatDesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            deadline
        );
    }


    /*
     * @notice Adds TreatToken<>Token liquidity and sends LP tokens to account
     * @param account Future owner of LP tokens
     * @param TokenB address
     * @param Desired amount of TreatToken to add to liquidity
     * @param Desired amount of TokenB to add to liquidity
     * @param Minimum amount of TreatToken to add to liquidity
     * @param Minimum amount of TokenB to add to liquidity
     * @param Deadline
     * @return Amount of TreatToken, that was added to liquidity
     * @return Amount of TokenB, that was added to liquidity
     * @return Amount of liquidity received
     */
    function addLiquidityOnBehalf(
        address account,
        address tokenB,
        uint256 amountTreatDesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
        public nonReentrant
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        (
            uint256 lockedAmount,
            uint256 remainingVestingProgress,
            uint256 initialTreatBalance,
            uint256 ownedTreatTokensInLiquidity
        ) = _transferTreatAndCheck(account, tokenB, amountTreatDesired);

        IERC20(tokenB).safeTransferFrom(
            msg.sender,
            address(this),
            amountBDesired
        );
        _approveIfRequired(tokenB, amountBDesired);

        (amountA, amountB, liquidity) = IRouter(router)
            .addLiquidity(
                address(treatToken),
                tokenB,
                amountTreatDesired,
                IERC20(tokenB).balanceOf(address(this)),
                amountAMin,
                amountBMin,
                account,
                deadline
            );

        // returning tokens
        {
            uint256 remainingTokenB = IERC20(tokenB).balanceOf(address(this));
            if (remainingTokenB > 0) {
                IERC20(tokenB).transfer(msg.sender, remainingTokenB);
            }
        }

        _registerStaking(
            account,
            tokenB,
            lockedAmount,
            remainingVestingProgress,
            initialTreatBalance,
            amountTreatDesired,
            liquidity,
            ownedTreatTokensInLiquidity
        );
    }


    /*
     * @notice Adds TreatToken<>ETH liquidity and sends LP tokens to msg.sender
     * @param amountTreatDesired Desired amount of TreatToken to add to liquidity
     * @param amountTokenMin Minimum amount of TreatToken to add to liquidity
     * @param amountETHMin Minimum amount of ETH to add to liquidity
     * @param deadline Deadline
     * @return amountToken Amount of TreatToken, that was added to liquidity
     * @return amountETH Amount of ETH, that was added to liquidity
     * @return liquidity Amount of liquidity received
     */
    function addLiquidityETH(
        uint256 amountTreatDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        return addLiquidityETHOnBehalf(
            msg.sender,
            amountTreatDesired,
            amountTokenMin,
            amountETHMin,
            deadline
        );
    }


    /*
     * @notice Adds TreatToken<>ETH liquidity and sends LP tokens to account
     * @param account Future owner of LP tokens
     * @param amountTreatDesired Desired amount of TreatToken to add to liquidity
     * @param amountTokenMin Minimum amount of TreatToken to add to liquidity
     * @param amountETHMin Minimum amount of ETH to add to liquidity
     * @param deadline Deadline
     * @return amountToken Amount of TreatToken, that was added to liquidity
     * @return amountETH Amount of ETH, that was added to liquidity
     * @return liquidity Amount of liquidity received
     */
    function addLiquidityETHOnBehalf(
        address account,
        uint256 amountTreatDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
        public
        nonReentrant
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        (
            uint256 lockedAmount,
            uint256 remainingVestingProgress,
            uint256 initialTreatBalance,
            uint256 ownedTreatTokensInLiquidity
        ) = _transferTreatAndCheck(account, WETH, amountTreatDesired);

        (amountToken, amountETH, liquidity) = IRouter(router)
            .addLiquidityETH{value: msg.value}(
                address(treatToken),
                amountTreatDesired,
                amountTokenMin,
                amountETHMin,
                account,
                deadline
            );

        _registerStaking(
            account,
            WETH,
            lockedAmount,
            remainingVestingProgress,
            initialTreatBalance,
            amountTreatDesired,
            liquidity,
            ownedTreatTokensInLiquidity
        );

        // returning BNB
        if (msg.value > amountETH) {
            (bool success,) = payable(msg.sender).call{value: msg.value - amountETH}("");
            require(success, "BNB return failed");
        }
    }


    /*
     * @notice Removes TreatToken<>Token liquidity
     * @param tokenB TokenB address
     * @param liquidity Liquidity amount
     * @param amountTreatMin Minimum amount of TreatToken to receive
     * @param amountBMin Minimum amount of TokenB to receive
     * @param deadline Deadline
     * @return amountTreat Amount of TreatToken, that was received
     * @return amountB Amount of TokenB, that was received
     * @dev Liquidity can be removed only by address which added liquidity with this smart contract
     * @dev Liquidity amount must not be greater than amount, received with this smart contract
     */
    function removeLiquidity(
        address tokenB,
        uint256 liquidity,
        uint256 amountTreatMin,
        uint256 amountBMin,
        uint256 deadline
    ) public nonReentrant returns (uint256 amountTreat, uint256 amountB) {
        (amountTreat,) = _executeWithdrawal(
            msg.sender,
            tokenB,
            liquidity,
            amountTreatMin,
            amountBMin,
            deadline
        );

        amountB = IERC20(tokenB).balanceOf(address(this));
        IERC20(tokenB).safeTransfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, tokenB, liquidity);
    }

    /*
     * @notice Removes TreatToken<>ETH liquidity
     * @param liquidity Liquidity amount
     * @param amountTreatMin Minimum amount of TreatToken to receive
     * @param amountETHMin Minimum amount of ETH to receive
     * @param deadline Deadline
     * @return amountToken Amount of TreatToken, that was received
     * @return amountETH Amount of ETH, that was received
     * @dev Liquidity can be removed only by address which added liquidity with this smart contract
     * @dev Liquidity amount must not be greater than amount, received with this smart contract
     */
    function removeLiquidityETH(
        uint256 liquidity,
        uint256 amountTreatMin,
        uint256 amountETHMin,
        uint256 deadline
    ) public nonReentrant returns (uint256 amountTreat, uint256 amountETH) {
        (amountTreat, amountETH) = _executeWithdrawal(
            msg.sender,
            WETH,
            liquidity,
            amountTreatMin,
            amountETHMin,
            deadline
        );

        IWETH(WETH).withdraw(amountETH);
        (bool success, ) = payable(msg.sender).call{value:amountETH}("");
        require(success, "ETH transfer failed");

        emit LiquidityRemoved(msg.sender, WETH, liquidity);
    }

    /*
     * @notice Removes TreatToken<>Token liquidity with permit
     * @param tokenB TokenB address
     * @param liquidity Liquidity amount
     * @param amountAMin Minimum amount of TreatToken to receive
     * @param amountBMin Minimum amount of TokenB to receive
     * @param deadline Deadline
     * @param approveMax approveMax Was max uint amount approved for transfer?
     * @param v Signature v part
     * @param r Signature r part
     * @param s Signature s part
     * @return amountA Amount of TreatToken, that was received
     * @return amountB Amount of TokenB, that was received
     * @dev Liquidity can be removed only by address which added liquidity with this smart contract
     * @dev Liquidity amount must not be greater than amount, received with this smart contract
     */
    function removeLiquidityWithPermit(
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB) {
        address pair = factory.getPair(address(treatToken), tokenB);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountA, amountB) = removeLiquidity(
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            deadline
        );
    }


    /*
     * @notice Removes TreatToken<>ETH liquidity
     * @param Liquidity amount
     * @param Minimum amount of TreatToken to receive
     * @param Minimum amount of ETH to receive
     * @param Deadline
     * @param approveMax Was max uint amount approved for transfer?
     * @param v Signature v part
     * @param r Signature r part
     * @param s Signature s part
     * @return amountToken Amount of TreatToken, that was received
     * @return amountETH Amount of ETH, that was received
     * @dev Liquidity can be removed only by address which added liquidity with this smart contract
     * @dev Liquidity amount must not be greater than amount, received with this smart contract
     */
    function removeLiquidityETHWithPermit(
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH) {
        address pair = factory.getPair(address(treatToken), WETH);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountToken, amountETH) = removeLiquidityETH(
            liquidity,
            amountTokenMin,
            amountETHMin,
            deadline
        );
    }


    /*
     * @notice Sets default vesting duration for this contract
     * @param _defaultVestingDuration New default vesting duration
     * @dev Only Owner can call this function
     */
    function setDefaultVestingDuration(uint32 _defaultVestingDuration) external onlyOwner {
        require(_defaultVestingDuration != 0, "Zero value");
        require(defaultVestingDuration != _defaultVestingDuration, "Already set");
        defaultVestingDuration = _defaultVestingDuration;

        emit NewDefaultVestingDuration(_defaultVestingDuration);
    }


    /*
     * @notice Sets special vesting duration for TreatToken<>TokenB pair
     * @param _tokenB New default vesting duration
     * @param _vestingDuration New special vesting duration
     * @notice Set to 0 to remove special vesting duration
     * @dev Only Owner can call this function
     */
    function setSpecialVestingDuration(
        address _tokenB,
        uint32 _vestingDuration
    ) external onlyOwner {
        require(specialVestingDuration[_tokenB] != _vestingDuration, "Already set");
        specialVestingDuration[_tokenB] = _vestingDuration;

        emit NewSpecialVestingDuration(_tokenB, _vestingDuration);
    }


    /*
     * @notice Recovers stuck tokens. Use in case of emergency
     * @param token ERC20 token address
     * @param amount Amount of tokens to recover
     * @param account Tokens receiver
     * @dev Only Owner can call this function
     */
    function recoverERC20(
        IERC20 token,
        uint256 amount,
        address account
    ) external onlyOwner {
        token.transfer(account, amount);

        emit ERC20Recovered(address(token), amount, account);
    }


    /*
     * @notice Calculates detailed deposit info for FrontEnd
     * @param account User account address
     * @return ownedTreatTokens Total TreatToken staked amount
     * @return deposits Array of deposit info for each liquidity pool
     */
    function getUserData(
        address account
    ) external view returns(
        uint256 ownedTreatTokens,
        DepositInfo[] memory deposits
    ) {
        ownedTreatTokens = 0;
        if (depositedPairTokens[account][address(0x1)] == address(0)) {
            return(
                ownedTreatTokens,
                deposits
            );
        }

        //calculating array length
        address token = depositedPairTokens[account][address(0x1)];
        uint256 length = 0;
        while (token != address(0x1)) {
            if (liquidityDeposits[account][token] > 0) {
                length++;
            }
            token = depositedPairTokens[account][token];
        }

        //storing data
        deposits = new DepositInfo[](length);
        token = depositedPairTokens[account][address(0x1)];
        uint256 i = 0;
        while (token != address(0x1)) {
            if (liquidityDeposits[account][token] > 0) {
                deposits[i] = getDepositData(account, token);
                ownedTreatTokens += deposits[i].treatAmount;
                i++;
            }
            token = depositedPairTokens[account][token];
        }
    }


    /*
     * @notice Calculates detailed deposit info for FrontEnd
     * @param account Account address
     * @param tokenB TokenB of TreatToken<>TokenB pair
     * @return depositInfo Collected deposit data
     * tokenB - TokenB address of TokenB<>Treat pair
     * lpToken - LP token address
     * lpTokenAmount - Amount of LP tokens that user received with this smart contract
     * treatAmount - Amount of Treat tokens that user could receive after removing liquidity
     * locked - Amount of locked tokens from `treatAmount`
     * lockedPercentage - Percentage of TreatTokens locked, where 1e9 is 100%
     * remainingVestingTime - Remaining vesting time until full unlock
     * vestingDuration - Vesting duration for this pair
     */
    function getDepositData(address account, address tokenB)
        public
        view
        returns (DepositInfo memory depositInfo)
    {
        depositInfo.tokenB = tokenB;
        depositInfo.lpTokenAmount = liquidityDeposits[account][tokenB];
        depositInfo.lpToken = factory.getPair(address(treatToken), tokenB);

        (
            depositInfo.lockedPercentage,
            depositInfo.remainingVestingTime,
            depositInfo.vestingDuration
        ) = getLockedData(account, tokenB);

        if (depositInfo.lpTokenAmount == 0) {
            return depositInfo;
        }

        uint256 _totalSupply = IERC20(depositInfo.lpToken).totalSupply();
        depositInfo.treatAmount = _totalSupply == 0
            ? 0
            : treatToken.balanceOf(depositInfo.lpToken)
                * depositInfo.lpTokenAmount / IERC20(depositInfo.lpToken).totalSupply();

        depositInfo.locked = depositInfo.lockedPercentage * depositInfo.treatAmount / BASE_PERCENTAGE;

        return depositInfo;
    }


    /*
     * @notice Calculates detailed deposit info for FrontEnd
     * @param account Account address
     * @param tokenB TokenB of TreatToken<>TokenB pair
     * @return lockedPercentage Which % of owned Treat Tokens are locked. 100% == 1e9
     * @return remainingVestingTime How much to wait until full unlock?
     * @return vestingDuration What is vesting duration for this pool?
     */
    function getLockedData(address account, address tokenB) public view
    returns (
        uint256 lockedPercentage,
        uint256 remainingVestingTime,
        uint256 vestingDuration
    ) {
        vestingDuration = getPairVestingDuration(tokenB);

        (lockedPercentage, remainingVestingTime) = VestingManager.getLockedAndRemaining(
            tokenVesting[account][tokenB],
            vestingDuration
        );
    }


    /*
     * @notice Gets vesting duration for specific pair
     * @param tokenB Token B address of TokenB<>TreatToken pair
     * @return Vesting duration in seconds. Period, by the end of which tokens become fully unlocked
     */
    function getPairVestingDuration(address tokenB) public view returns(uint32) {
        return specialVestingDuration[tokenB] > 0
            ? specialVestingDuration[tokenB]
            : defaultVestingDuration;
    }


    /*
     * @notice Gets vesting duration for multiple pairs
     * @param tokenB Array of Token B addresses of TokenB<>TreatToken pairs
     * @return Array of vesting durations in seconds. Period, by the end of which tokens become fully unlocked
     * @dev For Front End convenience
     */
    function getBatchPairVestingDuration(
        address[] calldata tokenB
    ) external view returns(
        uint32[] memory
    ) {
        uint32[] memory vestingDurations = new uint32[](tokenB.length);

        for(uint i = 0 ; i < tokenB. length; i++) {
            vestingDurations[i] = getPairVestingDuration(tokenB[i]);
        }

        return vestingDurations;
    }


    /*
     * @notice Adds token to the linked list of tokens, which were added by liquidity by the user
     * @param account User address
     * @param token Token address
     */
    function _addToken(address account, address token) private {
        if (depositedPairTokens[account][token] == address(0)) {
            if (depositedPairTokens[account][address(0x1)] == address(0)) {
                depositedPairTokens[account][address(0x1)] = token;
                depositedPairTokens[account][token] = address(0x1);
            } else {
                depositedPairTokens[account][token]
                    = depositedPairTokens[account][address(0x1)];
                depositedPairTokens[account][address(0x1)] = token;
            }
        }
    }


    /*
     * @notice Removes token from the linked list of tokens, which were added by liquidity by the user
     * @param account User address
     * @param token Token address
     */
    function _removeToken(address account, address tokenToRemove) private {
        address token = depositedPairTokens[account][address(0x1)];
        address prevToken = address(0x1);
        while (token != address(0x1)) {
            if(tokenToRemove == token) {
                address nextToken = depositedPairTokens[account][token];
                depositedPairTokens[account][prevToken] = nextToken;
                return;
            }
            prevToken = token;
            token = depositedPairTokens[account][token];
        }
    }


    /*
     * @notice Approves token to router in case of insufficient allowance
     * @param token ERC20 token address
     * @param amount ERC20 token address
     */
    function _approveIfRequired(address token, uint256 amount) private {
        uint256 allowance = IERC20(token).allowance(address(this), router);
        if (allowance < amount) {
            IERC20(token).approve(router, type(uint256).max);
        }
    }


    /*
     * @notice Removes liquidity, transfers Treat tokens to account and updates vesting data
     * @param account Account address
     * @param tokenB Token B of TokenB<>TreatToken pair, which liquidity is being removed
     * @param liquidityAmount Amount of liquidity being removed
     * @param amountTreatMin Minimum amount of TreatToken to receive
     * @param amountBMin Minimum amount of TokenB to receive
     * @param deadline Deadline
     */
    function _executeWithdrawal(
        address account,
        address tokenB,
        uint256 liquidityAmount,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    ) private returns (uint256 amountTreat, uint256 amountB) {
        uint256 depositedLiquidityAmount = liquidityDeposits[msg.sender][tokenB];
        require(
            depositedLiquidityAmount >= liquidityAmount,
            "Can only withdraw your liquidity"
        );
        liquidityDeposits[msg.sender][tokenB] = depositedLiquidityAmount - liquidityAmount;

        address pair = factory.getPair(address(treatToken), tokenB);
        IERC20(pair).safeTransferFrom(msg.sender, address(this), liquidityAmount);
        _approveIfRequired(pair, liquidityAmount);
        (amountTreat, amountB) = IRouter(router).removeLiquidity(
            address(treatToken),
            tokenB,
            liquidityAmount,
            amountAMin,
            amountBMin,
            address(this),
            deadline
        );

        uint256 vestingDuration = getPairVestingDuration(tokenB);

        (uint256 lockedPercentage, uint256 remainingVestingTime) = VestingManager.vestingUpdate(
            tokenVesting[account][tokenB],
            vestingDuration
        );

        uint256 lockedMoved = lockedPercentage * amountTreat / BASE_PERCENTAGE;
        if (liquidityAmount == depositedLiquidityAmount) {
            // delete staked vesting data
            tokenVesting[account][tokenB].lockedAmount = 0;
        }

        treatToken.executeWithdrawal(
            account,
            amountTreat,
            lockedMoved,
            remainingVestingTime * 1e9 / vestingDuration
        );

        if (liquidityAmount == depositedLiquidityAmount) {
            _removeToken(msg.sender, tokenB);
        }
    }


    /*
     * @notice Initiates depositing Treat to liquidity. Checks pair, transfers Treat Token
     * @param account Account address
     * @param tokenB Token B of TokenB<>TreatToken pair, which liquidity is being removed
     * @param amountTreatDesired Desired amount of TreatToken to add to liquidity
     * @return lockedAmount Amount of locked tokens that should be added to vesting info
     * @return remainingVestingProgress Remaining vesting progress of locked tokens, where 100% = 1e9
     * Example: Tokens are fully locked - 1e9, 50% of vesting period for locked tokens has passed - 0.5 * 1e9
     * @return initialTreatBalance Initial Treat Token balance
     */
    function _transferTreatAndCheck(
        address account,
        address tokenB,
        uint256 amountTreatDesired
    ) private returns (
        uint256 lockedAmount,
        uint256 remainingVestingProgress,
        uint256 initialTreatBalance,
        uint256 ownedTreatTokensInLiquidity
    ) {
        require(account == msg.sender || account == tx.origin, "Invalid account address");
        initialTreatBalance = treatToken.balanceOf(address(this));
        {
            address pair = factory.getPair(address(treatToken), tokenB);
            bool isApprovedExchange = treatToken.isExchangeAddress(pair);
            require(pair != address(0) && isApprovedExchange, "Not approved / 0 address pair");
            uint256 _totalSupply = IERC20(pair).totalSupply();
            ownedTreatTokensInLiquidity = _totalSupply == 0
                ? 0
                : treatToken.balanceOf(pair)
                    * liquidityDeposits[account][tokenB] / _totalSupply;
        }
        (lockedAmount, remainingVestingProgress) = treatToken.executeStaking(
            msg.sender,
            amountTreatDesired
        );
        _approveIfRequired(address(treatToken), amountTreatDesired);
    }


    /*
     * @notice Updates vesting info of specific deposit for received Treat Tokens
     * @param account Account address
     * @param tokenB Token B of TokenB<>TreatToken pair, which liquidity is being removed
     * @param newLockedAmount Amount of locked tokens that should be added to vesting info
     * @param remainingVestingProgress Remaining vesting progress of locked tokens, where 100% = 1e9
     * Example: Tokens are fully locked - 1e9, 50% of vesting period for locked tokens has passed - 0.5 * 1e9
     * @param initialTreatBalance Initial balance of Treat Token
     * @param amountTreatDesired Desired amount of TreatToken to add to liquidity
     * @param liquidity Liquidity amount, that user has received
     * @param ownedTreatTokens Amount of Treat Tokens already owned in liquidity
     */
    function _registerStaking(
        address account,
        address tokenB,
        uint256 newLockedAmount,
        uint256 remainingVestingProgress,
        uint256 initialTreatBalance,
        uint256 amountTreatDesired,
        uint256 liquidity,
        uint256 ownedTreatTokens
    ) private {
        uint256 remainingTreat = treatToken.balanceOf(address(this)) - initialTreatBalance;
        if (remainingTreat > 0) {
            // returning excessive TreatTokens
            uint256 excessiveLocked = remainingTreat * newLockedAmount / amountTreatDesired;
            newLockedAmount -= excessiveLocked;
            treatToken.executeWithdrawal(
                msg.sender,
                remainingTreat,
                excessiveLocked,
                remainingVestingProgress
            );
        }

        uint256 vestingDuration = getPairVestingDuration(tokenB);

        (uint256 oldLockedPercentage, uint256 oldRemainingVestingTime) = VestingManager.vestingUpdate(
            tokenVesting[account][tokenB],
            vestingDuration
        );

        // updating vesting info
        if(newLockedAmount > 0) {
            uint256 oldLockedAmount = 0;
            if (oldLockedPercentage > 0) {
                oldLockedAmount = oldLockedPercentage * ownedTreatTokens / BASE_PERCENTAGE;
            }
            // calculating new locked percentage
            uint256 newLockedPercentage = BASE_PERCENTAGE * (oldLockedAmount + newLockedAmount)
                / (ownedTreatTokens + amountTreatDesired - remainingTreat);

            // updating remaining vesting time based on locked amounts
            uint256 remainingAddedDuration = vestingDuration * remainingVestingProgress / 1e9;
            uint256 newRemainingVestingTime = (newLockedAmount * remainingAddedDuration + oldLockedAmount * oldRemainingVestingTime)
                / (newLockedAmount + oldLockedAmount);

            // update vesting data
            tokenVesting[account][tokenB].vestingEndTime = SafeCast.toUint40(block.timestamp + newRemainingVestingTime);
            tokenVesting[account][tokenB].lockedAmount = SafeCast.toUint176(newLockedPercentage);
        }

        _addToken(account, tokenB);

        liquidityDeposits[account][tokenB] += liquidity;
        emit LiquidityAdded(account, tokenB, liquidity);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

// @title Library for managing vesting storage data.
// Must be used by staking smart contracts with Treat Token as deposit token
library VestingManager {
    struct VestingData {
        uint40 vestingEndTime;  // end of vesting timestamp
        uint40 lastUpdateTime;  // last vesting update timestamp
        uint176 lockedAmount;   // amount of tokens being vested
    }

    /*
     * @notice Updates vesting data: end of vesting, amount of tokens has not been vested yet
     * @param vestingStorage Vesting data storage
     * @param vestingDuration Vesting duration for this vesting data
     * @return locked Amount of locked tokens
     * @return remainingVestingTime Remaining vesting duration
     */
    function vestingUpdate(
        VestingData storage vestingStorage,
        uint256 vestingDuration
    ) internal returns (uint256 locked, uint256 remainingVestingTime){
        VestingData memory vestingMemory = vestingStorage;
        (locked, remainingVestingTime) = getLockedAndRemaining(
            vestingMemory,
            vestingDuration
        );

        // update if needed
        if (vestingMemory.lastUpdateTime != uint40(block.timestamp)) {
            vestingStorage.lastUpdateTime = uint40(block.timestamp);
        }
        if (
            remainingVestingTime != 0
            && vestingMemory.vestingEndTime != SafeCast.toUint40(block.timestamp + remainingVestingTime)
        ) {
            vestingStorage.vestingEndTime = SafeCast.toUint40(block.timestamp + remainingVestingTime);
        }
        if (vestingMemory.lockedAmount != locked) {
            vestingStorage.lockedAmount = SafeCast.toUint176(locked);
        }
    }


    /*
     * @notice Adds new unvested tokens to vesting storage. Calculates remaining vesting time as weighted average.
     * @param vestingStorage Vesting data storage
     * @param vestingDuration Vesting duration for this vesting data
     * @param lockedAmount Amount of locked tokens to be added
     * @param remainingVestingProgress Remaining percentage of vesting duration for arriving tokens, where 1e9 == 100%
     * If tokens are fully unvested `remainingVestingProgress` = 1e9
     * If tokens are half vested `remainingVestingProgress` = 0.5 * 1e9
     * Should be calculated as {remainingVestingTime * 1e9 / vestingDuration}
     * @return locked Amount of locked tokens
     * @return remainingVestingTime Remaining vesting duration
     * @dev Must be used after vestingUpdate()
     */
    function addVesting(
        VestingData storage vestingStorage,
        uint256 vestingDuration,
        uint256 lockedAmount,
        uint256 remainingVestingProgress
    ) internal returns (uint256 locked, uint256 remainingVestingTime) {
        // gas savings
        VestingData memory vestingMemory = vestingStorage;
        require(vestingMemory.lastUpdateTime == uint40(block.timestamp), "vestingUpdate first");
        // calculate remaining time with weighted average
        uint256 storageRemainingTime = block.timestamp < vestingMemory.vestingEndTime
            ? vestingMemory.vestingEndTime - block.timestamp
            : 0;
        if(lockedAmount == 0) {
            return (vestingMemory.lockedAmount, storageRemainingTime);
        }
        uint256 remainingAddedDuration = vestingDuration * remainingVestingProgress / 1e9;
        remainingVestingTime = (lockedAmount * remainingAddedDuration + vestingMemory.lockedAmount * storageRemainingTime)
            / (lockedAmount + vestingMemory.lockedAmount);
        locked = vestingMemory.lockedAmount + lockedAmount;

        // update vesting data
        vestingStorage.vestingEndTime = SafeCast.toUint40(block.timestamp + remainingVestingTime);
        vestingStorage.lockedAmount = SafeCast.toUint176(locked);
    }


    /*
     * @notice Calculates vesting data: end of vesting, amount of tokens has not been vested yet
     * @param vestingData Vesting data
     * @param vestingDuration Vesting duration for this vesting data
     * @return locked Amount of locked tokens
     * @return remainingVestingTime Remaining vesting duration
     */
    function getLockedAndRemaining(
        VestingData memory vestingData,
        uint256 vestingDuration
    ) internal view returns (uint256 locked, uint256 remainingVestingTime) {
        remainingVestingTime = 0;
        locked = 0;

        if (vestingData.lockedAmount == 0) {
            return (0,0);
        } else {
            uint256 maxEndTime = vestingData.lastUpdateTime + vestingDuration;
            if (vestingData.vestingEndTime > maxEndTime) {
                vestingData.vestingEndTime = SafeCast.toUint40(maxEndTime);
            }

            // If vesting time is over
            if (vestingData.vestingEndTime <= block.timestamp) {
                return (0,0);
            }

            remainingVestingTime = vestingData.vestingEndTime - block.timestamp;
            uint256 sinceLastUpdate = block.timestamp - vestingData.lastUpdateTime;
            locked = vestingData.lockedAmount * remainingVestingTime / (sinceLastUpdate + remainingVestingTime);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {updateOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract SafeOwnable is Context {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipUpdated(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     */
    function updateOwnership() external {
        _updateOwnership();
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _newOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     * Internal function without access restriction.
     */
    function _updateOwnership() private {
        address oldOwner = _owner;
        address newOwner = _newOwner;
        require(msg.sender == newOwner, "Not a new owner");
        require(oldOwner != newOwner, "Already updated");
        _owner = newOwner;
        emit OwnershipUpdated(oldOwner, newOwner);
    }
}

//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IRouter {
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

//SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

interface IPair {
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
pragma solidity ^0.8.0;

import "./IFactory.sol";

interface ITreatLiquidity {
    function addLiquidity(
        address tokenB,
        uint256 amountTreatDesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        uint256 amountTreatDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function addLiquidityOnBehalf(
        address account,
        address tokenB,
        uint256 amountTreatDesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETHOnBehalf(
        address account,
        uint256 amountTreatDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function factory() external view returns(IFactory);
    function router() external view returns(address);
}

//SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

interface IFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITreatToken is IERC20, IERC20Metadata {
    function getPastVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256);

    function executeStaking(
        address account,
        uint256 transferAmount
    ) external returns (
        uint256 lockedAmount,
        uint256 remainingVestingProgress
    );

    function executeWithdrawal(
        address account,
        uint256 transferAmount,
        uint256 lockedAmount,
        uint256 remainingVestingProgress
    ) external;

    function viewNotVestedTokens(address recipient) external view
        returns(uint256 locked, uint256 remainingVestingTime);

    function isExchangeAddress(address pair) external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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