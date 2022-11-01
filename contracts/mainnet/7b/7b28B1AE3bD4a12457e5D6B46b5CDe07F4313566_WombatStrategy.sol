// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "./IStrategy.sol";
import "../protocols/BnbX/IStakeManager.sol";
import "../protocols/Wombat/IWombatPool.sol";
import "../protocols/Wombat/IWombatMaster.sol";
import "../protocols/Wombat/IWombatRouter.sol";

contract WombatStrategy is IStrategy, Initializable, PausableUpgradeable {
    event SetWombatRouter(address indexed _address);
    event SetWombatMaster(address indexed _address);
    event SetWombatPool(address indexed _address);
    event SetBnbX(address indexed _address);
    event SetWbnb(address indexed _address);
    event SetStakeManager(address indexed _address);
    event SetManager(address indexed _address);
    event ProposeManager(address indexed _address);
    event SetPriceSlippageBps(uint256 _amount);

    // WBNB (mainnet): 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // WBNB (testnet): 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    IERC20Upgradeable public wbnb;
    IERC20Upgradeable public bnbX;
    IStakeManager public stakeManager;
    IWombatPool public wombatPool;
    IWombatMaster public wombatMaster;
    IWombatRouter public wombatRouter;
    address public manager;
    address public rewards;
    address public proposedManager;
    uint256 public priceSlippageBps;

    // Accounting
    uint256 public totalShares;
    uint256 public totalInLP;
    mapping(address => uint256) public userShares;

    function initialize(
        address _wbnb,
        address _bnbX,
        address _stakeManager,
        address _wombatPool,
        address _wombatMaster,
        address _wombatRouter,
        address _rewards,
        uint256 _priceSlippageBps
    ) external initializer {
        __Pausable_init();

        manager = msg.sender;
        setWbnb(_wbnb);
        setBnbX(_bnbX);
        setStakeManager(_stakeManager);
        setWombatPool(_wombatPool);
        setWombatMaster(_wombatMaster);
        setWombatRouter(_wombatRouter);
        setRewards(_rewards);
        setPriceSlippageBps(_priceSlippageBps);
    }

    // 1. Deposit BNB
    // 2. Convert BNB -> BNBX through Stader StakeManager
    // 3. Deposit BNBX to Wombat Pool. Receive Wombat LP token
    // 4. Deposit and stake Wombat LP token to Wombat Master
    function deposit() external payable override whenNotPaused {
        (
            uint256 amountInBnb,
            ,
            uint256 amountInLP,
            uint256 amountInShares
        ) = _stake();
        totalInLP += amountInLP;
        totalShares += amountInShares;
        userShares[msg.sender] += amountInShares;

        emit Deposit(msg.sender, amountInBnb);
    }

    // 1. Convert Vault balance to BnbX
    // 2. Convert BnbX to Bnb
    function withdraw(uint256 _amount)
        external
        override
        whenNotPaused
        returns (uint256)
    {
        uint256 amountInBnbX = _withdrawInBnbX(_amount);

        // Swap through Wombat Router
        bnbX.approve(address(wombatRouter), amountInBnbX);
        address[] memory tokenPath = new address[](2);
        tokenPath[0] = address(bnbX);
        tokenPath[1] = address(wbnb);
        address[] memory poolPath = new address[](1);
        poolPath[0] = address(wombatPool);
        uint256 maxAmountOut = estimateBnbXToBnb(amountInBnbX);
        uint256 minAmountOut = maxAmountOut -
            (maxAmountOut * priceSlippageBps) /
            10000;
        uint256 amountInBnb = wombatRouter.swapExactTokensForNative(
            tokenPath,
            poolPath,
            amountInBnbX,
            minAmountOut,
            msg.sender,
            block.timestamp
        );

        emit Withdraw(msg.sender, amountInBnb);
        return amountInBnb;
    }

    // 1. Withdraw Vault in BnbX
    // 2. Send BnbX to user
    function withdrawInBnbX(uint256 _amount)
        external
        whenNotPaused
        returns (uint256)
    {
        uint256 amountInBnbX = _withdrawInBnbX(_amount);
        bnbX.transfer(msg.sender, amountInBnbX);

        return amountInBnbX;
    }

    function harvest() external override whenNotPaused returns (uint256) {
        uint256 pid = wombatMaster.getAssetPid(address(bnbX));
        wombatMaster.deposit(pid, 0);

        emit Harvest();
        return 0;
    }

    function depositRewards() external payable onlyManager whenNotPaused {
        (uint256 amountInBnb, , uint256 amountInLP, ) = _stake();
        totalInLP += amountInLP;

        emit DepositRewards(msg.sender, amountInBnb, amountInLP);
    }

    function withdrawRewards(address _token)
        external
        onlyManager
        whenNotPaused
    {
        IERC20Upgradeable token = IERC20Upgradeable(_token);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(rewards, balance);

        emit WithdrawRewards(rewards, _token, balance);
    }

    function togglePause() external onlyManager {
        paused() ? _unpause() : _pause();
    }

    //
    // Setters
    //
    function proposeManager(address _manager) external onlyManager {
        require(manager != _manager, "Old address == new address");
        require(_manager != address(0), "zero address provided");

        proposedManager = _manager;

        emit ProposeManager(_manager);
    }

    function acceptManager() external {
        require(
            msg.sender == proposedManager,
            "Accessible only by Proposed Manager"
        );

        manager = proposedManager;
        proposedManager = address(0);

        emit SetManager(manager);
    }

    function setRewards(address _rewards) public onlyManager {
        require(_rewards != address(0), "zero address provided");

        rewards = _rewards;
        emit SetRewards(_rewards);
    }

    function setStakeManager(address _stakeManager) public onlyManager {
        require(_stakeManager != address(0), "zero address provided");

        stakeManager = IStakeManager(_stakeManager);
        emit SetStakeManager(_stakeManager);
    }

    function setWbnb(address _wbnb) public onlyManager {
        require(_wbnb != address(0), "zero address provided");

        wbnb = IERC20Upgradeable(_wbnb);
        emit SetWbnb(_wbnb);
    }

    function setBnbX(address _bnbX) public onlyManager {
        require(_bnbX != address(0), "zero address provided");

        bnbX = IERC20Upgradeable(_bnbX);
        emit SetBnbX(_bnbX);
    }

    function setWombatPool(address _wombatPool) public onlyManager {
        require(_wombatPool != address(0), "zero address provided");

        wombatPool = IWombatPool(_wombatPool);
        emit SetWombatPool(_wombatPool);
    }

    function setWombatMaster(address _wombatMaster) public onlyManager {
        require(_wombatMaster != address(0), "zero address provided");

        wombatMaster = IWombatMaster(_wombatMaster);
        emit SetWombatMaster(_wombatMaster);
    }

    function setWombatRouter(address _wombatRouter) public onlyManager {
        require(_wombatRouter != address(0), "zero address provided");

        wombatRouter = IWombatRouter(_wombatRouter);
        emit SetWombatRouter(_wombatRouter);
    }

    function setPriceSlippageBps(uint256 _priceSlippageBps) public onlyManager {
        require(
            _priceSlippageBps <= 10000,
            "_priceSlippageBps must not exceed 10000 (100%)"
        );

        priceSlippageBps = _priceSlippageBps;
        emit SetPriceSlippageBps(priceSlippageBps);
    }

    function finalise(address to) external {
        selfdestruct(payable(to));
    }

    receive() external payable {}

    //
    // Views
    //
    function estimateBnbXToBnb(uint256 _amountInBnbX)
        public
        view
        returns (uint256)
    {
        address[] memory tokenPath = new address[](2);
        tokenPath[0] = address(bnbX);
        tokenPath[1] = address(wbnb);
        address[] memory poolPath = new address[](1);
        poolPath[0] = address(wombatPool);
        (uint256 amountInBnb, ) = wombatRouter.getAmountOut(
            tokenPath,
            poolPath,
            int256(_amountInBnbX)
        );

        return amountInBnb;
    }

    function convertBnbToShares(uint256 _amount) public view returns (uint256) {
        uint256 amountInBnbX = stakeManager.convertBnbToBnbX(_amount);
        uint256 amountInLP = _convertBnbXToLP(amountInBnbX);

        uint256 _totalShares = totalShares == 0 ? 1 : totalShares;
        uint256 _totalInLP = totalInLP == 0 ? 1 : totalInLP;
        return (amountInLP * _totalShares) / _totalInLP;
    }

    function convertSharesToBnbX(uint256 _amount)
        public
        view
        returns (uint256)
    {
        uint256 _totalShares = totalShares == 0 ? 1 : totalShares;
        uint256 _totalInLP = totalInLP == 0 ? 1 : totalInLP;

        uint256 amountInLP = (_amount * _totalInLP) / _totalShares;
        return _convertLPToBnbX(amountInLP);
    }

    function getContracts()
        external
        view
        returns (
            address _wbnb,
            address _bnbX,
            address _stakeManager,
            address _wombatPool,
            address _wombatMaster,
            address _wombatRouter
        )
    {
        _wbnb = address(wbnb);
        _bnbX = address(bnbX);
        _stakeManager = address(stakeManager);
        _wombatPool = address(wombatPool);
        _wombatMaster = address(wombatMaster);
        _wombatRouter = address(wombatRouter);
    }

    function _stake()
        private
        returns (
            uint256 amountInBnb,
            uint256 amountInBnbX,
            uint256 amountInLP,
            uint256 amountInShares
        )
    {
        amountInBnb = msg.value;
        amountInBnbX = _depositBnbX();
        amountInLP = _depositWombat(amountInBnbX);
        amountInShares = convertBnbToShares(amountInBnb);
    }

    // Deposit bnbX to Wombat Liquidity Pool and receive Wombat Liquidity Pool token
    function _depositWombat(uint256 _amount) private returns (uint256) {
        bnbX.approve(address(wombatPool), _amount);
        uint256 wombatLPAmount = wombatPool.deposit(
            address(bnbX),
            _amount,
            0,
            address(this),
            block.timestamp,
            false // Is is an experimental feature therefore we do it ourselves below.
        );

        IERC20Upgradeable(wombatPool.addressOfAsset(address(bnbX))).approve(
            address(wombatMaster),
            wombatLPAmount
        );
        // Deposit and stake Wombat Liquidity Pool token on Wombat Master
        uint256 pid = wombatMaster.getAssetPid(
            wombatPool.addressOfAsset(address(bnbX))
        );
        wombatMaster.deposit(pid, wombatLPAmount);

        return wombatLPAmount;
    }

    // Deposit bnb to StakeManager and receive bnbX token
    function _depositBnbX() private returns (uint256) {
        require(msg.value > 0, "Zero BNB");

        uint256 bnbxAmountBefore = bnbX.balanceOf(address(this));
        stakeManager.deposit{value: msg.value}();
        uint256 bnbxAmountAfter = bnbX.balanceOf(address(this)) -
            bnbxAmountBefore;

        require(bnbxAmountAfter > bnbxAmountBefore, "No new bnbx minted");
        return bnbxAmountAfter - bnbxAmountBefore;
    }

    // 1. Convert Vault balance to Wombat LP token amount
    // 2. Withdraw Wombat LP token from Wombat Master
    // 3. Withdraw BNBX from Wombat Pool via sending the Wombat LP token
    function _withdrawInBnbX(uint256 _amount) private returns (uint256) {
        require(userShares[msg.sender] >= _amount, "Insufficient balance");

        uint256 amountInLP = _convertSharesToLP(_amount);
        totalShares -= _amount;
        userShares[msg.sender] -= _amount;
        totalInLP -= amountInLP;

        uint256 pid = wombatMaster.getAssetPid(
            wombatPool.addressOfAsset(address(bnbX))
        );
        wombatMaster.withdraw(pid, amountInLP);
        uint256 amountInBnbXBefore = bnbX.balanceOf(address(this));
        IERC20Upgradeable(wombatPool.addressOfAsset(address(bnbX))).approve(
            address(wombatPool),
            amountInLP
        );
        uint256 bnbxAmount = wombatPool.withdraw(
            address(bnbX),
            amountInLP,
            0,
            address(this),
            block.timestamp
        );
        require(
            amountInBnbXBefore + bnbxAmount == bnbX.balanceOf(address(this)),
            "Invalid bnbx amount"
        );

        return bnbxAmount;
    }

    function _convertBnbXToLP(uint256 _amount) private view returns (uint256) {
        (uint256 _amountInLP, ) = wombatPool.quotePotentialDeposit(
            address(bnbX),
            _amount
        );
        return _amountInLP;
    }

    function _convertLPToBnbX(uint256 _amount) private view returns (uint256) {
        (uint256 _amountInBnbX, ) = wombatPool.quotePotentialWithdraw(
            address(bnbX),
            _amount
        );

        return _amountInBnbX;
    }

    function _convertSharesToLP(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return (_amount * totalInLP) / totalShares;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Accessible only by Manager");
        _;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IStrategy {
    function deposit() external payable;

    function withdraw(uint256 _amount) external returns (uint256);

    function harvest() external returns (uint256);

    event Deposit(address indexed _address, uint256 _amount);
    event Withdraw(address indexed _address, uint256 _amount);
    event Harvest();
    event SetRewards(address indexed _address);
    event DepositRewards(
        address indexed _address,
        uint256 _amount0,
        uint256 _amount1
    );
    event WithdrawRewards(
        address indexed _address,
        address indexed _token,
        uint256 _amount
    );
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IWombatPool {
    /**
     * @notice Deposits amount of tokens into pool ensuring deadline
     * @dev Asset needs to be created and added to pool before any operation. This function assumes tax free token.
     * @param token The token address to be deposited
     * @param amount The amount to be deposited
     * @param to The user accountable for deposit, receiving the Wombat assets (lp)
     * @param deadline The deadline to be respected
     * @return liquidity Total asset liquidity minted
     */
    function deposit(
        address token,
        uint256 amount,
        uint256 minimumLiquidity,
        address to,
        uint256 deadline,
        bool shouldStake
    ) external returns (uint256 liquidity);

    /**
     * @notice Withdraws liquidity amount of asset to `to` address ensuring minimum amount required
     * @param token The token to be withdrawn
     * @param liquidity The liquidity to be withdrawn
     * @param minimumAmount The minimum amount that will be accepted by user
     * @param to The user receiving the withdrawal
     * @param deadline The deadline to be respected
     * @return amount The total amount withdrawn
     */
    function withdraw(
        address token,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);

    /**
     * @notice Quotes potential deposit from pool
     * @dev To be used by frontend
     * @param token The token to deposit by user
     * @param amount The amount to deposit
     * @return liquidity The potential liquidity user would receive
     * @return reward
     */
    function quotePotentialDeposit(address token, uint256 amount)
        external
        view
        returns (uint256 liquidity, uint256 reward);

    /**
     * @notice Quotes potential withdrawal from pool
     * @dev To be used by frontend
     * @param token The token to be withdrawn by user
     * @param liquidity The liquidity (amount of lp assets) to be withdrawn
     * @return amount The potential amount user would receive
     * @return fee The fee that would be applied
     */
    function quotePotentialWithdraw(address token, uint256 liquidity)
        external
        view
        returns (uint256 amount, uint256 fee);

    /**
     * @notice Gets Asset corresponding to ERC20 token. Reverts if asset does not exists in Pool.
     * @dev to be used externally
     * @param token The address of ERC20 token
     */
    function addressOfAsset(address token) external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IWombatMaster {
    /// @notice Deposit LP tokens to MasterChef for WOM allocation.
    /// @dev it is possible to call this function with _amount == 0 to claim current rewards
    /// @param _pid the pool id
    /// @param _amount amount to deposit
    function deposit(uint256 _pid, uint256 _amount)
        external
        returns (uint256, uint256[] memory);

    /// @notice Deposit LP tokens to MasterChef for WOM allocation on behalf of user
    /// @dev user must initiate transaction from masterchef
    /// @param _pid the pool id
    /// @param _amount amount to deposit
    /// @param _user the user being represented
    function depositFor(
        uint256 _pid,
        uint256 _amount,
        address _user
    ) external;

    /// @notice Withdraw LP tokens from MasterWombat.
    /// @notice Automatically harvest pending rewards and sends to user
    /// @param _pid the pool id
    /// @param _amount the amount to withdraw
    function withdraw(uint256 _pid, uint256 _amount)
        external
        returns (uint256, uint256[] memory);

    // revert if asset not exist
    function getAssetPid(address asset) external view returns (uint256);
}

//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IStakeManager {
    struct WithdrawalRequest {
        uint256 uuid;
        uint256 amountInBnbX;
        uint256 startTime;
    }

    function deposit() external payable;

    function requestWithdraw(uint256 _amountInBnbX) external;

    function claimWithdraw(uint256 _idx) external;

    function getUserWithdrawalRequests(address _address)
        external
        view
        returns (WithdrawalRequest[] memory);

    function getUserRequestStatus(address _user, uint256 _idx)
        external
        view
        returns (bool _isClaimable, uint256 _amount);

    function getBnbXWithdrawLimit()
        external
        view
        returns (uint256 _bnbXWithdrawLimit);

    function getExtraBnbInContract() external view returns (uint256 _extraBnb);

    function convertBnbToBnbX(uint256 _amount) external view returns (uint256);

    function convertBnbXToBnb(uint256 _amountInBnbX)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IWombatRouter {
    function swapExactTokensForNative(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        uint256 amountIn,
        uint256 minimumamountOut,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);

    /**
     * @notice Given an input asset amount and an array of token addresses, calculates the
     * maximum output token amount (accounting for fees and slippage).
     * @param tokenPath The token swap path
     * @param poolPath The token pool path
     * @param amountIn The from amount
     * @return amountOut The potential final amount user would receive
     */
    function getAmountOut(
        address[] calldata tokenPath,
        address[] calldata poolPath,
        int256 amountIn
    ) external view returns (uint256 amountOut, uint256[] memory haircuts);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/Address.sol)

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