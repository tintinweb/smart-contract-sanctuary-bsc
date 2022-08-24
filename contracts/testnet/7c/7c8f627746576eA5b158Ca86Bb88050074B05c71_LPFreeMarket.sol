// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@interest-protocol/dex/interfaces/IPair.sol";
import "@interest-protocol/dex/interfaces/IRouter.sol";
import "@interest-protocol/tokens/interfaces/IDinero.sol";
import "@interest-protocol/earn/interfaces/ICasaDePapel.sol";
import "@interest-protocol/library/MathLib.sol";
import "@interest-protocol/library/SafeCastLib.sol";
import "@interest-protocol/library/SafeTransferErrors.sol";
import "@interest-protocol/library/SafeTransferLib.sol";

import "./interfaces/IPriceOracle.sol";
import "./interfaces/ISwap.sol";

contract LPFreeMarket is
    Initializable,
    SafeTransferErrors,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    /*///////////////////////////////////////////////////////////////
                                  LIBS
    //////////////////////////////////////////////////////////////*/

    using SafeTransferLib for address;
    using MathLib for uint256;
    using SafeCastLib for uint256;

    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed from, address indexed to, uint256 amount);

    event Withdraw(
        address indexed from,
        address indexed recipient,
        uint256 amount
    );

    event Borrow(
        address indexed borrower,
        address indexed receiver,
        uint256 amount
    );

    event Repay(address indexed payer, address indexed payee, uint256 amount);

    event Liquidate(
        address indexed liquidator,
        address indexed debtor,
        uint256 principal,
        uint256 collateralToCover,
        uint256 fee
    );

    event MaxTVLRatio(uint256);

    event LiquidationFee(uint256);

    event MaxBorrowAmount(uint256);

    event Compound(uint256 rewards, uint256 fee);

    event GetCollateralEarnings(address indexed treasury, uint256 amount);

    event NewTreasury(address indexed newTreasury);

    /*///////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////*/

    error LPFreeMarket__InvalidMaxLTVRatio();

    error LPFreeMarket__InvalidLiquidationFee();

    error LPFreeMarket__MaxBorrowAmountReached();

    error LPFreeMarket__InvalidExchangeRate();

    error LPFreeMarket__InsolventCaller();

    error LPFreeMarket__InvalidAmount();

    error LPFreeMarket__InvalidAddress();

    error LPFreeMarket__InvalidWithdrawAmount();

    error LPFreeMarket__InvalidRequest();

    error LPFreeMarket__InvalidLiquidationAmount();

    error LPFreeMarket__Reentrancy();

    /*///////////////////////////////////////////////////////////////
                                  STRUCTS
    //////////////////////////////////////////////////////////////*/

    struct LiquidationInfo {
        uint256 allCollateral;
        uint256 allPrincipal;
        uint256 allFee;
    }

    struct Account {
        uint128 collateral;
        uint128 rewards;
        uint256 rewardDebt;
        uint256 principal;
    }

    // NO MEMORY SLOT
    // Requests
    uint256 internal constant DEPOSIT_REQUEST = 0;

    uint256 internal constant WITHDRAW_REQUEST = 1;

    uint256 internal constant BORROW_REQUEST = 2;

    uint256 internal constant REPAY_REQUEST = 3;

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 0                            */

    // Interest Swap Router address
    IRouter internal ROUTER;
    //////////////////////////////////////////////////////////////

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 1                            */

    // Dinero address
    IDinero internal DNR;
    //////////////////////////////////////////////////////////////

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 2                            */

    // Dinero address
    address public COLLATERAL;
    //////////////////////////////////////////////////////////////

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 3                            */

    ICasaDePapel internal CASA_DE_PAPEL;
    //////////////////////////////////////////////////////////////

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 4                            */

    // Contract uses Chainlink to obtain the price in USD with 18 decimals
    IPriceOracle internal ORACLE;

    // A fee that will be charged as a penalty of being liquidated.
    uint96 public liquidationFee;
    //////////////////////////////////////////////////////////////

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 5                            */

    // Governance token for Interest Protocol
    address internal IPX;

    // The current master chef farm being used.
    uint96 public POOL_ID;
    //////////////////////////////////////////////////////////////

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 6                            */

    // principal + interest rate / collateral. If it is above this value, the user might get liquidated.
    uint128 public maxLTVRatio;

    // total amount of staking token in the contract
    uint128 public totalCollateral;
    //////////////////////////////////////////////////////////////

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 7                            */

    // Total amount of Dinero borrowed from this contract.
    uint128 public totalPrincipal;

    // Dinero Markets must have a max of how much DNR they can create to prevent liquidity issues during liquidations.
    uint128 public maxBorrowAmount;
    //////////////////////////////////////////////////////////////

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 8                            */

    // Total amount of rewards per token ever collected by this contract
    uint256 public totalRewardsPerToken;
    //////////////////////////////////////////////////////////////

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 9                            */

    mapping(address => Account) public accountOf;

    //////////////////////////////////////////////////////////////

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 10                            */

    uint256 public collateralEarnings;

    //////////////////////////////////////////////////////////////

    /*//////////////////////////////////////////////////////////////
                       STORAGE  SLOT 11                            */

    address public treasury;

    //////////////////////////////////////////////////////////////

    /*///////////////////////////////////////////////////////////////
                            INITIALIZER
    //////////////////////////////////////////////////////////////*/

    /**
     * Requirements:
     *
     * @param contracts addresses of contracts to intialize this market.
     * @param settings several global state uint variables to initialize this market
     *
     * - Can only be called at once and should be called during creation to prevent front running.
     */
    function initialize(bytes calldata contracts, bytes calldata settings)
        external
        initializer
    {
        __Ownable_init();

        _initializeContracts(contracts);

        _initializeSettings(settings);

        IPX.safeApprove(address(CASA_DE_PAPEL), type(uint256).max);
        COLLATERAL.safeApprove(address(CASA_DE_PAPEL), type(uint256).max);
        COLLATERAL.safeApprove(address(ROUTER), type(uint256).max);
    }

    function _initializeContracts(bytes memory data) private {
        (ROUTER, DNR, COLLATERAL, IPX, ORACLE, CASA_DE_PAPEL, treasury) = abi
            .decode(
                data,
                (
                    IRouter,
                    IDinero,
                    address,
                    address,
                    IPriceOracle,
                    ICasaDePapel,
                    address
                )
            );
    }

    function _initializeSettings(bytes memory data) private {
        (maxLTVRatio, liquidationFee, maxBorrowAmount, POOL_ID) = abi.decode(
            data,
            (uint128, uint96, uint128, uint96)
        );
    }

    /*///////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Check if a user loan is below the {maxLTVRatio}.
     * @dev We call the Chainlink oracle in this function, which can make this very costly on chains with a high gas price.
     */
    modifier isSolvent() {
        _;
        if (
            !_isSolvent(
                msg.sender,
                ORACLE.getIPXLPTokenUSDPrice(address(COLLATERAL), 1 ether)
            )
        ) revert LPFreeMarket__InsolventCaller();
    }

    /*///////////////////////////////////////////////////////////////
                        VIEW FUNCTION
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice It returns the pending rewards of a user.
     * @dev This function is not optimized because it is not meant to be called by mutative functions.
     * @param account The address of the user.
     * @return uint256 The pending rewards of the user.
     */
    function getPendingRewards(address account)
        external
        view
        returns (uint256)
    {
        uint256 totalPoolRewards = CASA_DE_PAPEL.getUserPendingRewards(
            0,
            address(this)
        );

        uint256 totalFarmRewards = CASA_DE_PAPEL.getUserPendingRewards(
            POOL_ID,
            address(this)
        );

        if (totalCollateral == 0) return 0;

        uint256 pendingRewardsPerToken = (totalPoolRewards + totalFarmRewards)
            .fdiv(totalCollateral) + totalRewardsPerToken;

        Account memory user = accountOf[account];

        return
            user.rewards +
            uint256(user.collateral).fmul(pendingRewardsPerToken) -
            user.rewardDebt;
    }

    /*///////////////////////////////////////////////////////////////
                        MUTATIVE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev This function collects the {COLLATERAL} earned from liquidations.
     */
    function getCollateralEarnings() external {
        uint256 earnings = collateralEarnings;

        if (earnings == 0) return;

        // Reset to 0
        collateralEarnings = 0;

        COLLATERAL.safeTransfer(treasury, earnings);

        emit GetCollateralEarnings(treasury, earnings);
    }

    /**
     * @dev This function compounds the {IPX} rewards in the pool id 0 and rewards the caller with 2% of the pending rewards.
     */
    function compound() external {
        // Variable to keep track of the {IPX} rewards we will get by depositing and unstaking.
        uint256 rewards;

        // Get rewards from the {COLLATERAL} pool.
        rewards = rewards.uAdd(_harvestFarm());

        // Get rewards from the {IPX} pool.
        rewards = rewards.uAdd(_harvestIPX());

        // Calculate the fee to reward the `msg.sender`.
        // The fee amounts to 2% of all the rewards harvested in this block.
        uint256 fee = rewards.fmul(0.02e18);

        rewards = rewards.uSub(fee);

        // Update the state
        totalRewardsPerToken += rewards.fdiv(totalCollateral);

        // Pay the `msg.sender` the fee.
        _safeIPXTransfer(msg.sender, fee);

        // Compound the remaining rewards in the {IPX} pool.
        // We already got the rewards up to this block. So the {IPX} pool rewards should be 0.
        // Therefore, we do not need to update the {_totalRewardsPerAmount} variable.
        CASA_DE_PAPEL.stake(0, _getIPXBalance());

        emit Compound(rewards, fee);
    }

    /**
     * @dev The tokens will be transfered from the {msg.sender}
     * @param to The address that the deposit will be assigned to.
     * @param amount The number of {COLLATERAL} tokens that will be deposited.
     */
    function deposit(address to, uint256 amount) external {
        _deposit(to, amount);
    }

    /**
     * @dev The tokens withdrawn will be from the {msg.sender} account.
     * @param to The address that will receive the tokens withdrawn.
     * @param amount The number of tokens to withdraw.
     */
    function withdraw(address to, uint256 amount) external isSolvent {
        _withdraw(msg.sender, to, amount);

        // Send the underlying token to the recipient
        COLLATERAL.safeTransfer(to, amount);

        emit Withdraw(msg.sender, to, amount);
    }

    /**
     * @dev The borrow will be credited to the {msg.sender} account.
     * @param to The address that will receive the borrowed tokens.
     * @param amount How many dinero tokens the {msg.sender} is borrowing.
     */
    function borrow(address to, uint256 amount) external isSolvent {
        _borrow(to, amount);
    }

    /**
     * @dev The repayment is done by burning dinero from the {msg.sender} account.
     * @param account The account that will be credited with the repayment.
     * @param amount The number of Dinero tokens to repay.
     */
    function repay(address account, uint256 amount) external {
        _repay(account, amount);
    }

    /**
     * @notice This function allows to chain (deposit, withdraw, borrow and repay) operations in one call.
     * @param requests An array of uint actions to run.
     * @param requestArgs The arguments to call the action operations with.
     */
    function request(uint256[] calldata requests, bytes[] calldata requestArgs)
        external
    {
        // Indicates if the user must be solvent after the actions.
        // We only want to call {_isSolvent} once to save gas.
        bool checkForSolvency;

        for (uint256 i; i < requests.length; i = i.uAdd(1)) {
            uint256 requestAction = requests[i];

            if (_checkForSolvency(requestAction) && !checkForSolvency)
                checkForSolvency = true;

            _request(requestAction, requestArgs[i]);
        }

        if (checkForSolvency)
            if (
                !_isSolvent(
                    msg.sender,
                    ORACLE.getIPXLPTokenUSDPrice(address(COLLATERAL), 1 ether)
                )
            ) revert LPFreeMarket__InsolventCaller();
    }

    /**
     * @notice This function closes underwater positions. It charges the borrower a fee and rewards the liquidator for keeping the integrity of the protocol. The liquidator can use the collateral to close the position or must have enough dinero to repay the loan.
     * @dev If the data field is not empty, the recipient is assumed to implement the interface {ISwap}.
     * @param accounts The  list of accounts to be liquidated.
     * @param principals The amount of principal the `msg.sender` wants to liquidate from each account.
     * @param recipient The address that will receive the proceeds gained by liquidating.
     * @param data arbitrary data to be passed to the recipient.
     *
     * Requirements:
     *
     * - He must hold enough Dinero to cover the sum of principals.
     */
    function liquidate(
        address[] calldata accounts,
        uint256[] calldata principals,
        address recipient,
        bytes calldata data
    ) external {
        // Liquidations must be based on the current exchange rate.
        uint256 _exchangeRate = ORACLE.getIPXLPTokenUSDPrice(
            address(COLLATERAL),
            // Interest DEX LP tokens have 18 decimals
            1 ether
        );

        // Save state to memory for gas saving

        LiquidationInfo memory liquidationInfo;

        // Loop through all positions
        for (uint256 i; i < accounts.length; i = i.uAdd(1)) {
            address account = accounts[i];

            // If the user has enough collateral to cover his debt. He cannot be liquidated. Move to the next one.
            if (_isSolvent(account, _exchangeRate)) continue;

            // How much principal the user has borrowed.
            uint256 loanPrincipal = accountOf[account].principal;

            // Liquidator cannot repay more than the what `account` borrowed.
            // Note the liquidator does not need to close the full position.
            uint256 principal = principals[i].min(loanPrincipal);

            unchecked {
                // The minimum value is it's own value. So this can never underflow.
                // Update the userLoan global state
                accountOf[account].principal -= principal;
            }

            // How much collateral is needed to cover the loan.
            // Since Dinero is always 1 USD we can calculate this way.
            // We do not care what is the current price of Dinero as we want it to force to be 1 USD.
            uint256 collateralToCover = principal.fdiv(_exchangeRate);

            // Calculate the collateralFee (for the liquidator and the protocol)
            uint256 fee = collateralToCover.fmul(liquidationFee);

            // Remove the collateral from the account. We can consider the debt paid.
            // The rewards accrued will be sent to the liquidated `account`.
            _withdraw(account, account, collateralToCover + fee);

            emit Liquidate(
                msg.sender,
                account,
                principal,
                collateralToCover,
                fee
            );

            liquidationInfo.allCollateral += collateralToCover;
            liquidationInfo.allPrincipal += principal;
            liquidationInfo.allFee += fee;
        }

        // There must have liquidations or we throw an error;
        // We throw an error instead of returning because we already changed state, sent events and withdrew tokens from collateral.
        // We need to revert all that.
        if (liquidationInfo.allPrincipal == 0)
            revert LPFreeMarket__InvalidLiquidationAmount();

        // We already substract these values from userAccount and userPrincipal mapping. So we d not need to check for underflow
        unchecked {
            // Update Global state
            totalPrincipal -= liquidationInfo.allPrincipal.toUint128();
        }

        // The protocol keeps 10% of the liquidation fee.
        uint256 protocolFee = liquidationInfo.allFee.fmul(0.1e18);

        unchecked {
            // Collect the protocol fee.
            collateralEarnings += protocolFee;
        }

        uint256 liquidatorAmount = liquidationInfo.allCollateral +
            liquidationInfo.allFee.uSub(protocolFee);

        // If any  data is passed, we assume the recipient is a swap contract.
        if (data.length != 0) {
            // Remove the liquidity to obtain token0 and token1 and send to the recipient.
            // Liquidator receives his reward in collateral.
            // Abstracted the logic to a function to avoid; Stack too deep compiler error.
            _sellCollateral(
                data,
                liquidatorAmount,
                liquidationInfo.allPrincipal,
                recipient
            );
        } else {
            // Send the collateral to the recipient without removing the liquidity.
            COLLATERAL.safeTransfer(recipient, liquidatorAmount);
        }

        // The {msg.sender} must have enough Dinero to be burned to cover all outstanding principal.
        DNR.burn(msg.sender, liquidationInfo.allPrincipal);
    }

    /*///////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Helper function to check if we should check for solvency in the request functions
     *
     * @param req The request action
     * @return pred if true the function should check for solvency
     */
    function _checkForSolvency(uint256 req) internal pure returns (bool pred) {
        if (req == WITHDRAW_REQUEST || req == BORROW_REQUEST) pred = true;
    }

    /**
     * @dev Due to math limitations, the amount to be sent might be a bit off. This makes sure the transfers do not fail.
     *
     * @param to The address that will receive the `IPX`.
     * @param amount The number of IPX to send.
     */
    function _safeIPXTransfer(address to, uint256 amount) internal {
        IPX.safeTransfer(to, _getIPXBalance().min(amount));
    }

    /**
     * @dev It deposits all {IPX} stored in the contract in the {IPX} pool in the {IPX_MASTER_CHEF} and returns the rewards obtained.
     *
     * @return uint256 The reward acrrued up to this block in {IPX}.
     */
    function _stakeIPX() internal returns (uint256) {
        CASA_DE_PAPEL.stake(0, _getIPXBalance());
        // The current {balanceOf} IPX is equivalent to all rewards because we just staked our entire {IPX} balance.
        return _getIPXBalance();
    }

    /**
     * @dev It withdraws an `amount` of {IPX} from the {IPX_MASTER_CHEF} and returns the rewards obtained.
     *
     * @return ipxHarvested The number of {IPX} that was obtained as reward.
     */
    function _harvestIPX() internal returns (uint256 ipxHarvested) {
        ipxHarvested = _getIPXBalance();

        CASA_DE_PAPEL.unstake(0, 0);
        // Need to subtract the previous balance and the withdrawn amount from the current {balanceOf} to know many {IPX} rewards  we got.
        ipxHarvested = _getIPXBalance() - ipxHarvested;
    }

    /**
     * @dev A helper function to get the current {IPX} balance in this vault.
     */
    function _getIPXBalance() internal view returns (uint256) {
        return IERC20(IPX).balanceOf(address(this));
    }

    /**
     * @notice This function harvests the rewards from the farm.
     *
     * @return ipxHarvested It returns how many {IPX} we got as reward from the depsit function.
     */
    function _harvestFarm() internal returns (uint256 ipxHarvested) {
        // Need to save the {balanceOf} {IPX} before the deposit function to calculate the rewards.
        ipxHarvested = _getIPXBalance();
        CASA_DE_PAPEL.stake(POOL_ID, 0);
        // Find how much IPX we earned after depositing as the deposit functions always {transfer} the pending {IPX} rewards.
        ipxHarvested = _getIPXBalance() - ipxHarvested;
    }

    /**
     * @dev It withdraws an `amount` of {COLLATERAL} from the farm. And it keeps track of the rewards obtained by using the {_getBalance} function.
     *
     * @param amount The number of {COLLATERAL} to be withdrawn from the {CASA_DE_PAPEL}.
     * @return ipxHarvested It returns the number of {IPX} tokens we got as reward.
     */
    function _withdrawFarm(uint256 amount)
        internal
        returns (uint256 ipxHarvested)
    {
        // Save the current {IPX} balance before calling the withdraw function because it will give us rewards.
        ipxHarvested = _getIPXBalance();
        CASA_DE_PAPEL.unstake(POOL_ID, amount);
        // The difference between the previous {IPX} balance and the current balance is the rewards obtained via the withdraw function.
        ipxHarvested = _getIPXBalance() - ipxHarvested;
    }

    function _deposit(address to, uint256 amount) internal {
        if (0 == amount) revert LPFreeMarket__InvalidAmount();
        if (address(0) == to) revert LPFreeMarket__InvalidAddress();

        // Save storage state in memory to save gas.
        Account memory user = accountOf[to];

        uint256 _totalCollateral = totalCollateral;
        uint256 _totalRewardsPerToken = totalRewardsPerToken;

        // If there are no tokens deposited, we do not have to update the current rewards.
        if (_totalCollateral != 0) {
            // Get rewards currently in the {COLLATERAL} pool.
            _totalRewardsPerToken += _harvestFarm().fdiv(_totalCollateral);
            // Reinvest all {IPX} rewards into the IPX pool.
            // The functions on this block send pending {IPX} to this contract. Therefore, we need to update the {_totalRewardsPerAccount}.
            _totalRewardsPerToken += _stakeIPX().fdiv(_totalCollateral);
        }

        unchecked {
            // We do not need to calculate rewards if the user has no open deposits in this contract.
            if (user.collateral != 0) {
                // Calculate and add how many rewards the user accrued.
                user.rewards += (_totalRewardsPerToken.fmul(user.collateral) -
                    user.rewardDebt).toUint128();
            }
        }

        // We want to get the tokens before updating the state
        COLLATERAL.safeTransferFrom(msg.sender, address(this), amount);

        // Update local State
        _totalCollateral += amount;

        unchecked {
            user.collateral += amount.toUint128();
        }

        // Deposit the new acquired tokens in the pool.
        // Since we already got the rewards up to this block. There should be no rewards right now to harvest.
        // Therefore, we do not need to update the {_totalRewardsPerAmount}.
        CASA_DE_PAPEL.stake(POOL_ID, amount);
        // Compound the rewards. Deposit any current {IPX} in the IPX pool.
        CASA_DE_PAPEL.stake(0, _getIPXBalance());

        // Update State to tell us that user has been completed paid up to this point.
        user.rewardDebt = _totalRewardsPerToken.fmul(user.collateral);

        // Update Global state
        accountOf[to] = user;
        totalCollateral = _totalCollateral.toUint128();
        totalRewardsPerToken = _totalRewardsPerToken;

        emit Deposit(msg.sender, to, amount);
    }

    /**
     * @dev This function does not transfer the collateral and does not emit an event.
     */
    function _withdraw(
        address from,
        address rewardsRecipient,
        uint256 amount
    ) internal returns (uint256 rewards) {
        if (0 == amount) revert LPFreeMarket__InvalidAmount();

        // Save storage state in memory to save gas.
        Account memory user = accountOf[from];

        if (amount > user.collateral)
            revert LPFreeMarket__InvalidWithdrawAmount();

        // Save storage state in memory to save gas.
        uint256 _totalCollateral = totalCollateral;
        uint256 _totalRewardsPerToken = totalRewardsPerToken;

        // The {Vault} contract ensures that the `amount` is greater than 0.
        // It also ensured that the {totalCollateral} is greater than 0.
        // We withdraw from the {CASA_DE_PAPEL} the desired `amount`.
        _totalRewardsPerToken += _withdrawFarm(amount).fdiv(_totalCollateral);
        // Collect the current rewards in the {IPX} pool to properly update {_totalRewardsPerAmount}.
        _totalRewardsPerToken += _harvestIPX().fdiv(_totalCollateral);

        // Calculate how many rewards the user is entitled before this deposit
        rewards = _totalRewardsPerToken.fmul(user.collateral) - user.rewardDebt;

        unchecked {
            // Update local state
            _totalCollateral -= amount;
            user.collateral -= amount.toUint128();
            // Add all accrued rewards. As this contract only sends the rewards on withdraw.
            rewards += user.rewards;
        }

        // Set rewards to 0
        delete user.rewards;

        // Get the current {IPX} balance to make sure we have enough to cover the {IPX} the rewards.
        uint256 ipxBalance = _getIPXBalance();

        if (rewards > ipxBalance) {
            // Already took the rewards up to this block. So we do not need to update the {_totalRewardsPerAmount}.
            CASA_DE_PAPEL.unstake(0, rewards - ipxBalance);
        }

        // Send the rewards to the `from`. To make the following calculations easier
        _safeIPXTransfer(rewardsRecipient, rewards);

        // re-stake any remaining IPX
        CASA_DE_PAPEL.stake(0, _getIPXBalance());

        // Reset totalRewardsPerAmount if the pool is totally empty
        totalRewardsPerToken = _totalRewardsPerToken;
        user.rewardDebt = _totalRewardsPerToken.fmul(user.collateral);
        totalCollateral = _totalCollateral.toUint128();

        accountOf[from] = user;
    }

    /**
     * @dev The core logic of borrow. Careful it does not accrue or check for solvency.
     *
     * @param to The address which will receive the borrowed `DINERO`
     * @param amount The number of `DINERO` to borrow
     */
    function _borrow(address to, uint256 amount) internal {
        totalPrincipal += amount.toUint128();

        if (totalPrincipal > maxBorrowAmount)
            revert LPFreeMarket__MaxBorrowAmountReached();

        unchecked {
            accountOf[msg.sender].principal += amount;
        }

        // Note the `msg.sender` can use his collateral to lend to someone else.
        DNR.mint(to, amount);

        emit Borrow(msg.sender, to, amount);
    }

    /**
     * @dev The core logic to repay a loan without accrueing or require checks.
     *
     * @param account The address which will have some of its principal paid back.
     * @param amount How many `DINERO` tokens (princicpal) to be paid back for the `account`
     */
    function _repay(address account, uint256 amount) internal {
        // Since all debt is in `DINERO`. We can simply burn it from the `msg.sender`
        DNR.burn(msg.sender, amount);

        accountOf[account].principal -= amount;

        unchecked {
            totalPrincipal -= amount.toUint128();
        }

        emit Repay(msg.sender, account, amount);
    }

    /**
     * @dev Checks if an `account` has enough collateral to back his loan based on the {maxLTVRatio}.
     *
     * @param account The address to check if he is solvent.
     * @param exchangeRate The rate to exchange {Collateral} to DNR.
     * @return bool True if the user can cover his loan. False if he cannot.
     */
    function _isSolvent(address account, uint256 exchangeRate)
        internal
        view
        returns (bool)
    {
        if (exchangeRate == 0) revert LPFreeMarket__InvalidExchangeRate();

        // How much the user has borrowed.
        Account memory user = accountOf[account];

        // Account has no open loans. So he is solvent.
        if (user.principal == 0) return true;

        // Account has no collateral so he can not open any loans. He is insolvent.
        if (user.collateral == 0) return false;

        // All Loans are emitted in `DINERO` which is based on USD price
        // Collateral in USD * {maxLTVRatio} has to be greater than principal + interest rate accrued in DINERO which is pegged to USD
        return
            uint256(user.collateral).fmul(exchangeRate).fmul(maxLTVRatio) >=
            user.principal;
    }

    /**
     * @dev Call a function based on requestAction
     *
     * @param requestAction The action associated to a function
     * @param data The arguments to be passed to the function
     */
    function _request(uint256 requestAction, bytes calldata data) private {
        if (requestAction == DEPOSIT_REQUEST) {
            (address to, uint256 amount) = abi.decode(data, (address, uint256));
            return _deposit(to, amount);
        }

        if (requestAction == WITHDRAW_REQUEST) {
            (address to, uint256 amount) = abi.decode(data, (address, uint256));
            _withdraw(msg.sender, to, amount);

            COLLATERAL.safeTransfer(to, amount);

            emit Withdraw(msg.sender, to, amount);
            return;
        }

        if (requestAction == BORROW_REQUEST) {
            (address to, uint256 amount) = abi.decode(data, (address, uint256));
            return _borrow(to, amount);
        }

        if (requestAction == REPAY_REQUEST) {
            (address account, uint256 principal) = abi.decode(
                data,
                (address, uint256)
            );
            return _repay(account, principal);
        }

        revert LPFreeMarket__InvalidRequest();
    }

    function _removeLiquidity(address recipient, uint256 collateralAmount)
        private
        returns (
            address token0,
            address token1,
            uint256 amount0,
            uint256 amount1
        )
    {
        bool stable;

        (token0, token1, stable, , , , , ) = IPair(address(COLLATERAL))
            .metadata();

        // Even if one of the tokens is WBNB. We dont want BNB because we want to use {swapExactTokensForTokens} for Dinero after.
        // Avoids unecessary routing through WBNB {deposit} and {withdraw}.
        (amount0, amount1) = ROUTER.removeLiquidity(
            token0,
            token1,
            stable,
            collateralAmount,
            0, // The liquidator will pay for slippage
            0, // The liquidator will pay for slippage
            recipient,
            //solhint-disable-next-line not-rely-on-time
            block.timestamp
        );
    }

    /**
     * @dev A helper function to sell collateral for dinero.
     *
     * @notice Slippage is not an issue because on {liquidate} we always burn the necessary amount of `DINERO`.
     * @notice We are only  using highly liquid pairs. So slippage should not be an issue. Front-running can be an issue, but the liquidation fee should cover it. It will be between 10%-15% (minus 10% for the protocol) of the debt liquidated.
     *
     * @param data arbitrary data to be passed to the swapContract
     * @param collateralAmount The amount of tokens to remove from the DEX.
     * @param principal The amount of DNR to be burned
     * @param swapContract The liquidator address to sell the collateral
     */
    function _sellCollateral(
        bytes calldata data,
        uint256 collateralAmount,
        uint256 principal,
        address swapContract
    ) private {
        // Even if one of the tokens is WBNB. We dont want BNB because we want to use {swapExactTokensForTokens} for Dinero after.
        // Avoids unecessary routing through WBNB {deposit} and {withdraw}.
        (
            address token0,
            address token1,
            uint256 amount0,
            uint256 amount1
        ) = _removeLiquidity(swapContract, collateralAmount);

        ISwap(swapContract).sellTwoTokens(
            data,
            token0,
            token1,
            amount0,
            amount1,
            principal
        );
    }

    /*///////////////////////////////////////////////////////////////
                         OWNER ONLY
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev updates the {maxLTVRatio} of the whole contract.
     *
     * @param amount The new {maxLTVRatio}.
     *
     * Requirements:
     *
     * - {maxLTVRatio} cannot be higher than 90% due to the high volatility of crypto assets and we are using the overcollaterization ratio.
     * - It can only be called by the owner to avoid griefing
     *
     */
    function setMaxLTVRatio(uint256 amount) external onlyOwner {
        if (amount > 0.9e18) revert LPFreeMarket__InvalidMaxLTVRatio();
        maxLTVRatio = amount.toUint128();
        emit MaxTVLRatio(amount);
    }

    /**
     * @dev Updates the {liquidationFee}.
     *
     * @param amount The new liquidation fee.
     *
     * Requirements:
     *
     * - It cannot be higher than 15%.
     * - It can only be called by the owner to avoid griefing.
     *
     */
    function setLiquidationFee(uint256 amount) external onlyOwner {
        if (amount > 0.15e18) revert LPFreeMarket__InvalidLiquidationFee();
        liquidationFee = amount.toUint96();
        emit LiquidationFee(amount);
    }

    /**
     * @dev Sets a new value to the {maxBorrowAmount}.
     *
     * @notice Allows the {owner} to set a limit on how DNR can be created by this market.
     *
     * @param amount The new maximum amount that can be borrowed.
     *
     * Requirements:
     *
     * - Function can only be called by the {owner}
     */
    function setMaxBorrowAmount(uint256 amount) external onlyOwner {
        maxBorrowAmount = amount.toUint128();
        emit MaxBorrowAmount(amount);
    }

    /**
     * @dev Updates the treasury address.
     *
     * @param _treasury The new treasury.
     *
     * Requirements:
     *
     * - Function can only be called by the {owner}
     */
    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
        emit NewTreasury(_treasury);
    }

    /**
     * @dev A hook to guard the address that can update the implementation of this contract. It must be the owner.
     */
    function _authorizeUpgrade(address)
        internal
        view
        override
        onlyOwner
    //solhint-disable-next-line no-empty-blocks
    {

    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import {Observation} from "../DataTypes.sol";

import "./IERC20.sol";

interface IPair is IERC20 {
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

    event Sync(uint256 reserve0, uint256 reserve1);

    function stable() external view returns (bool);

    function nonces(address) external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function observations(uint256)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function reserve0() external view returns (uint256);

    function reserve1() external view returns (uint256);

    function blockTimestampLast() external view returns (uint256);

    function reserve0CumulativeLast() external view returns (uint256);

    function reserve1CumulativeLast() external view returns (uint256);

    function observationLength() external view returns (uint256);

    function getFirstObservationInWindow()
        external
        view
        returns (Observation memory);

    function observationIndexOf(uint256 timestamp)
        external
        pure
        returns (uint256 index);

    function metadata()
        external
        view
        returns (
            address t0,
            address t1,
            bool st,
            uint256 fee,
            uint256 r0,
            uint256 r1,
            uint256 dec0,
            uint256 dec1
        );

    function tokens() external view returns (address, address);

    function getReserves()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getTokenPrice(address tokenIn, uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function currentCumulativeReserves()
        external
        view
        returns (
            uint256 reserve0Cumulative,
            uint256 reserve1Cumulative,
            uint256 blockTimestamp
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function getAmountOut(address, uint256) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import {Amount, Route} from "../DataTypes.sol";

import "./IWNT.sol";

interface IRouter {
    function factory() external view returns (address);

    //solhint-disable-next-line func-name-mixedcase
    function WNT() external view returns (IWNT);

    function sortTokens(address tokenA, address tokenB)
        external
        pure
        returns (address token0, address token1);

    function pairFor(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (address pair);

    function getPairs(address tokenA, address tokenB)
        external
        view
        returns (address volatilePair, address stablePair);

    function getAmountsOut(uint256 amount, Route[] memory routes)
        external
        view
        returns (Amount[] memory amounts);

    function getReserves(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (uint256 reserveA, uint256 reserveB);

    function getAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (Amount memory amount);

    function isPair(address pair) external view returns (bool);

    function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 amountADesired,
        uint256 amountBDesired
    )
        external
        view
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function quoteRemoveLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity
    ) external view returns (uint256 amountA, uint256 amountB);

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
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

    function addLiquidityNativeToken(
        address token,
        bool stable,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountNativeTokenMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountNativeToken,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityNativeToken(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountNativeTokenMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountNativeToken);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        bool stable,
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

    function removeLiquidityNativeTokenWithPermit(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountNativeTokenMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountNativeToken);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external returns (Amount[] memory amounts);

    function swapExactNativeTokenForTokens(
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external payable returns (Amount[] memory amounts);

    function swapExactTokensForNativeToken(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external returns (Amount[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IDinero is IERC20PermitUpgradeable, IERC20Upgradeable {
    function MINTER_ROLE() external view returns (bytes32);

    function DEVELOPER_ROLE() external view returns (bytes32);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface ICasaDePapel {
    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Stake(address indexed user, uint256 indexed poolId, uint256 amount);

    event Unstake(address indexed user, uint256 indexed poolId, uint256 amount);

    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed poolId,
        uint256 amount
    );

    event Liquidate(
        address indexed liquidator,
        address indexed debtor,
        uint256 amount
    );

    event UpdatePool(
        uint256 indexed poolId,
        uint256 blockNumber,
        uint256 accruedIntPerShare
    );

    event UpdatePoolAllocationPoint(
        uint256 indexed poolId,
        uint256 allocationPoints
    );

    event AddPool(
        address indexed token,
        uint256 indexed poolId,
        uint256 allocationPoints
    );

    event NewInterestTokenRatePerBlock(uint256 rate);

    event NewTreasury(address indexed treasury);

    function START_BLOCK() external view returns (uint256);

    function interestTokenPerBlock() external view returns (uint256);

    function treasury() external view returns (address);

    function treasuryBalance() external view returns (uint256);

    function pools(uint256 index)
        external
        view
        returns (
            address stakingToken,
            uint256 allocationPoints,
            uint256 lastRewardBlock,
            uint256 accruedIntPerShare,
            uint256 totalSupply
        );

    function userInfo(uint256 poolId, address account)
        external
        view
        returns (uint256 amount, uint256 rewardsPaid);

    function hasPool(address token) external view returns (bool);

    function getPoolId(address token) external view returns (uint256);

    function totalAllocationPoints() external view returns (uint256);

    function getPoolsLength() external view returns (uint256);

    function getUserPendingRewards(uint256 poolId, address _user)
        external
        view
        returns (uint256);

    function mintTreasuryRewards() external;

    function updatePool(uint256 poolId) external;

    function updateAllPools() external;

    function stake(uint256 poolId, uint256 amount) external;

    function unstake(uint256 poolId, uint256 amount) external;

    function emergencyWithdraw(uint256 poolId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Set of utility functions to perform mathematical operations.
 */
library MathLib {
    /// @notice The decimal houses of most ERC20 tokens and native tokens.
    uint256 private constant SCALAR = 1e18;

    /**
     * @notice It multiplies two fixed point numbers.
     * @dev It assumes the arguments are fixed point numbers with 18 decimal houses. It reverts if the result overflows 2**256-1. Source: https://twitter.com/transmissions11/status/1451129626432978944/photo/1
     * @param x First operand
     * @param y The second operand
     * @return z The result of multiplying x and y
     */
    function fmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// We use assembly to optimize gas consumption.
        assembly {
            if iszero(or(iszero(x), eq(div(mul(x, y), x), y))) {
                revert(0, 0)
            }

            z := div(mul(x, y), SCALAR)
        }
    }

    /**
     * @notice It divides two fixed point numbers.
     * @dev It assumes the arguments are fixed point numbers with 18 decimal houses. It reverts if the result overflows 2**256-1. It does not guard against underflows because the EVM div opcode cannot underflow. Source: https://twitter.com/transmissions11/status/1451129626432978944/photo/1
     * @param x First operand
     * @param y The second operand
     * @return z The result of multiplying x and y
     */
    function fdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// We use assembly to optimize gas consumption.
        assembly {
            if or(
                iszero(y),
                iszero(or(iszero(x), eq(div(mul(x, SCALAR), x), SCALAR)))
            ) {
                revert(0, 0)
            }
            z := div(mul(x, SCALAR), y)
        }
    }

    /**
     * @notice It returns a version of the first argument with 18 decimals.
     * @dev This function protects against shadow integer overflow.
     * @param x Number that will be manipulated to have 18 decimals.
     * @param decimals The current decimal houses of the first argument
     * @return z A version of the first argument with 18 decimals.
     */
    function adjust(uint256 x, uint8 decimals) internal pure returns (uint256) {
        /// If the number has 18 decimals, we do not need to do anything.
        /// Since {mulDiv} protects against shadow overflow, we can first add 18 decimal houses and then remove the current decimal houses.
        return decimals == 18 ? x : mulDiv(x, SCALAR, 10**decimals);
    }

    /**
     * @notice It adds two numbers.
     * @dev This function has no protection against integer overflow to optimize gas consumption. It must only be used when we are 100% certain it will not overflow. E.g., to calculate the number of blocks elapsed.
     * @param x First operand.
     * @param y The second operand.
     * @return z The result of adding x and y.
     */
    function uAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(x, y)
        }
    }

    /**
     * @notice It subtracts two numbers.
     * @dev This function has no protection against integer underflow to optimize gas consumption. It must only be used when we are 100% certain it will not underflow. E.g., to calculate the number of blocks elapsed.
     * @param x First operand.
     * @param y The second operand.
     * @return z The result of adding x and y.
     */
    function uSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := sub(x, y)
        }
    }

    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // Handle division by zero
        require(denominator > 0);

        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remiander Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Short circuit 256 by 256 division
        // This saves gas when a * b is small, at the cost of making the
        // large case a bit more expensive. Depending on your use case you
        // may want to remove this short circuit and always go through the
        // 512 bit path.
        if (prod1 == 0) {
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Handle overflow, the result must be < 2**256
        require(prod1 < denominator);

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        // Note mulmod(_, _, 0) == 0
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1 unless denominator is zero, then twos is zero.
        uint256 twos = denominator & (~denominator + 1);
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        // If denominator is zero the inverse starts with 2
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson itteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256
        // If denominator is zero, inv is now 128

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    /**
     * @notice This function finds the square root of a number.
     * @dev It was taken from https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol.
     * @param x This function will find the square root of this number.
     * @return The square root of x.
     */
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;

        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }

        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }

    /**
     * @notice It returns the smaller number between the two arguments.
     * @param x Any uint256 number.
     * @param y Any uint256 number.
     * @return It returns whichever is smaller between x and y.
     */
    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Set of functions to safely cast uint256 numbers to smaller uint bit numbers.
 * @dev We use solidity to optimize the gas consumption, and the functions will revert without any reason.
 */
library SafeCastLib {
    /**
     * @notice Casts a uint256 to uint128 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint128
     * @return y The uint128 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**128 - 1
     */
    function toUint128(uint256 x) internal pure returns (uint128 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(128, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint112 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint112
     * @return y The uint112 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**112 - 1
     */
    function toUint112(uint256 x) internal pure returns (uint112 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(112, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint96 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint96
     * @return y The uint96 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**96 - 1
     */
    function toUint96(uint256 x) internal pure returns (uint96 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(96, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint64 for memory optimization
     *
     * @param x The uint256 that will be casted to uint64
     * @return y The uint64 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**64 - 1
     */
    function toUint64(uint256 x) internal pure returns (uint64 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(64, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint32 for memory optimization
     *
     * @param x The uint256 that will be casted to uint32
     * @return y The uint64 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**32 - 1
     */
    function toUint32(uint256 x) internal pure returns (uint32 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(32, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title The errors thrown by the {SafeERC20} library.
 * @dev Contracts that use the {SafeERC20} library should inherit this contract.
 */
contract SafeTransferErrors {
    error NativeTokenTransferFailed(); // function selector - keccak-256 0x3022f2e4

    error TransferFromFailed(); // function selector - keccak-256 0x7939f424

    error TransferFailed(); // function selector - keccak-256 0x90b8ec18

    error ApproveFailed(); // function selector - keccak-256 0x3e3f8f73
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title A set of utility functions to guarantee the finality of the ERC20 {transfer}, {transferFrom} and {approve} functions.
 * @author Jose Cerqueira <[email protected]>
 * @dev These functions do not check that the recipient has any code, and they will revert with custom errors available in the {SafeERC20Errors}. We also leave dirty bits in the scratch space of the memory 0x00 to 0x3f.
 */
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                          NATIVE TOKEN OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice This function sends native tokens from the {msg.sender} to an address.
     * @param to The recipient of the `amount` of native tokens.
     * @param amount The number of native tokens to send to the `to` address.
     */
    function safeTransferNativeToken(address to, uint256 amount) internal {
        assembly {
            /// Pass no calldata only value in wei
            /// We do not save any data in memory.
            /// Returns 1, if successful
            if iszero(call(gas(), to, amount, 0x00, 0x00, 0x00, 0x00)) {
                // Save the function identifier in slot 0x00
                mstore(
                    0x00,
                    0x3022f2e400000000000000000000000000000000000000000000000000000000
                )
                /// Grab the first 4 bytes in slot 0x00 and revert with {NativeTokenTransferFailed()}
                revert(0x00, 0x04)
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice It transfers {ERC20} tokens from {msg.sender} to an address.
     * @param token The address of the {ERC20} token.
     * @param to The address of the recipient.
     * @param amount The number of tokens to send.
     */
    function safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            /// Keep the pointer in memory to restore it later.
            let freeMemoryPointer := mload(0x40)

            /// Save the arguments in memory to pass to {call} later.
            /// IMPORTANT: We will override the free memory pointer, but we will restore it later.

            /// keccak-256 transfer(address,uint256) first 4 bytes 0xa9059cbb
            mstore(
                0x00,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, to) // save address after first 4 bytes
            mstore(0x24, amount) // save amount after 36 bytes

            // First, we call the {token} with 68 bytes of data starting from slot 0x00 to slot 0x44.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, it fails.
            // If the data returned from {call} does not equal to 1 or is not empty, this transaction will revert.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
                )
            ) {
                // Save the function identifier for {TransferFailed()} on slot 0x00.
                mstore(
                    0x00,
                    0x90b8ec1800000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes on slot 0x00 and revert.
                revert(0x00, 0x04)
            }

            // Restore the free memory pointer value on slot 0x40.
            mstore(0x40, freeMemoryPointer)
        }
    }

    /**
     * @notice It transfers {ERC20} tokens from a third party address to another address.
     * @dev This function requires the {msg.sender} to have an allowance equal to or higher than the number of tokens being transferred.
     * @param token The address of the {ERC20} token.
     * @param from The address that will have its tokens transferred.
     * @param to The address of the recipient.
     * @param amount The number of tokens being transferred.
     */
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        assembly {
            /// Keep the pointer in memory to restore it later.
            let freeMemoryPointer := mload(0x40)

            /// Save the arguments in memory to pass to {call} later.
            /// IMPORTANT: We will override the zero slot and free memory pointer, BUT we will restore it after.

            /// Save the first 4 bytes 0x23b872dd of the keccak-256 transferFrom(address,address,uint256) on slot 0x00.
            mstore(
                0x00,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, from) // save address after first 4 bytes
            mstore(0x24, to) // save address after 36 bytes
            mstore(0x44, amount) // save amount after 68 bytes

            // First we call the {token} with 100 bytes of data starting from slot 0x00.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, this transaction will revert.
            // If the data returned from {call} does not equal to 1 or is not empty, this transaction will revert.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x64, 0x00, 0x20)
                )
            ) {
                // Save function identifier for {TransferFromFailed()} on slot 0x00.
                mstore(
                    0x00,
                    0x7939f42400000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes on slot 0x00 and revert.
                revert(0x00, 0x04)
            }

            // Clean up memory
            mstore(0x40, freeMemoryPointer) // restore the free memory pointer
            mstore(
                0x60,
                0x0000000000000000000000000000000000000000000000000000000000000000
            ) // restore the slot zero
        }
    }

    /**
     * @notice It allows the {msg.sender} to update the allowance of an address.
     * @dev Developers have to keep in mind that this transaction can be front-run.
     * @param token The address of the {ERC20} token.
     * @param to The address that will have its allowance updated.
     * @param amount The new allowance.
     */
    function safeApprove(
        address token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // Keep the pointer in memory to restore it later.
            let freeMemoryPointer := mload(0x40)

            // Save the arguments in memory to pass to {call} later.
            // We will override the free memory pointer, but we will restore it later.

            // Save the first 4 bytes (0x095ea7b3) of the keccak-256 approve(address,uint256) function on slot 0x00.
            mstore(
                0x00,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, to) // save the address after 4 bytes
            mstore(0x24, amount) // save the amount after 36 bytes

            // First we call the {token} with 68 bytes of data starting from slot 0x00.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, this transaction will revert.
            // If the data returned from {call} does not equal to 1 or is not empty, this transaction will revert.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
                )
            ) {
                // Save the first 4 bytes of the keccak-256 of {ApproveFailed()}
                mstore(
                    0x00,
                    0x3e3f8f7300000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes on slot 0x00 and return
                revert(0x00, 0x04)
            }

            // restore the free memory pointer
            mstore(0x40, freeMemoryPointer)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IPriceOracle {
    function getTokenUSDPrice(address token, uint256 amount)
        external
        view
        returns (uint256 price);

    function getIPXLPTokenUSDPrice(address pair, uint256 amount)
        external
        view
        returns (uint256 price);

    function getNativeTokenUSDPrice(uint256 amount)
        external
        view
        returns (uint256 price);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface ISwap {
    function sellTwoTokens(
        bytes calldata data,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 debt
    ) external;

    function sellOneToken(
        bytes calldata data,
        address token,
        uint256 amount,
        uint256 debt
    ) external;

    function sellNativeToken(
        bytes calldata data,
        uint256 amount,
        uint256 debt
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

struct Observation {
    uint256 timestamp;
    uint256 reserve0Cumulative;
    uint256 reserve1Cumulative;
}

struct Route {
    address from;
    address to;
}

struct Amount {
    uint256 amount;
    bool stable;
}

struct InitData {
    address token0;
    address token1;
    bool stable;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "./IERC20.sol";

/// @notice IWNT stands for Wrapped Native Token Interface
interface IWNT is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
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
interface IERC20PermitUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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