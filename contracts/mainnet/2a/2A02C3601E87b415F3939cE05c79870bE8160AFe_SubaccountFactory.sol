/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Subaccount.sol";

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

contract SubaccountFactory {
    // ========== storage ==========

    // Subaccount template that can be cloned
    address immutable template;
    address immutable dealer;

    // Subaccount can only be added.
    mapping(address => address[]) subaccountRegistry;

    // ========== event ==========

    event NewSubaccount(
        address indexed master,
        uint256 subaccountIndex,
        address subaccountAddress
    );

    // ========== constructor ==========

    constructor(address _dealer) {
        template = address(new Subaccount());
        dealer = _dealer;
        Subaccount(template).init(address(this), dealer);
    }

    // ========== functions ==========

    /// @notice https://eips.ethereum.org/EIPS/eip-1167[EIP 1167]
    /// is a standard protocol for deploying minimal proxy contracts,
    /// also known as "clones".
    function newSubaccount() external returns (address subaccount) {
        subaccount = Clones.clone(template);

        Subaccount(subaccount).init(msg.sender, dealer);
        subaccountRegistry[msg.sender].push(subaccount);
        emit NewSubaccount(
            msg.sender,
            subaccountRegistry[msg.sender].length - 1,
            subaccount
        );
    }

    function getSubaccounts(address master)
        external
        view
        returns (address[] memory)
    {
        return subaccountRegistry[master];
    }

    function getSubaccount(address master, uint256 index)
        external
        view
        returns (address)
    {
        return subaccountRegistry[master][index];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/
import "../intf/IDealer.sol";

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @notice Subaccount can help its owner manage risk and positions.
/// You can open orders with isolated positions via Subaccount.
/// You can also let others trade for you by setting them as authorized
/// operators. Operators have no access to fund transfer.
contract Subaccount {
    // ========== storage ==========

    /*
       This is not a standard ownable contract because the ownership
       can not be transferred. This contract is designed to be
       initializable to better support clone, which is a low gas
       deployment solution.
    */
    address public owner;
    address public dealer;
    bool public initialized;

    // ========== modifier ==========

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // ========== functions ==========

    function init(address _owner, address _dealer) external {
        require(!initialized, "ALREADY INITIALIZED");
        initialized = true;
        owner = _owner;
        dealer = _dealer;
        IDealer(dealer).setOperator(owner, true);
    }

    /// @param isValid authorize operator if value is true
    /// unauthorize operator if value is false
    function setOperator(address operator, bool isValid) external onlyOwner {
        IDealer(dealer).setOperator(operator, isValid);
    }

    /*
        Subaccount can only withdraw asset to its owner account.
        No deposit related function is supported in subaccount because the owner can
        transfer fund to subaccount directly in the Dealer contract. 
    */

    /// @param primaryAmount The amount of primary asset you want to withdraw
    /// @param secondaryAmount The amount of secondary asset you want to withdraw
    function requestWithdraw(uint256 primaryAmount, uint256 secondaryAmount)
        external
        onlyOwner
    {
        IDealer(dealer).requestWithdraw(primaryAmount, secondaryAmount);
    }

    /// @notice Always withdraw to owner, no matter who fund this subaccount
    function executeWithdraw(address to, bool isInternal) external onlyOwner {
        IDealer(dealer).executeWithdraw(to, isInternal);
    }

    /// @notice retrieve asset
    function retrieve(
        address to,
        address token,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }
}

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;

import "../lib/Types.sol";

interface IDealer {
    /// @notice Deposit fund to get credit for trading
    /// @param primaryAmount is the amount of primary asset you want to deposit.
    /// @param secondaryAmount is the amount of secondary asset you want to deposit.
    /// @param to is the account you want to deposit to.
    function deposit(
        uint256 primaryAmount,
        uint256 secondaryAmount,
        address to
    ) external;

    /// @notice Submit withdrawal request, which can be executed after
    /// the timelock. The main purpose of this function is to avoid the
    /// failure of counterparty caused by withdrawal.
    /// @param primaryAmount is the amount of primary asset you want to withdraw.
    /// @param secondaryAmount is the amount of secondary asset you want to withdraw.
    function requestWithdraw(uint256 primaryAmount, uint256 secondaryAmount)
        external;

    /// @notice Execute the withdrawal request.
    /// @param to is the address receiving assets.
    /// @param isInternal Only internal credit transfers will be made,
    /// and ERC20 transfers will not happen.
    function executeWithdraw(address to, bool isInternal) external;

    /// @notice Help perpetual contract parse tradeData and return
    /// the balance changes of each trader.
    /// @dev only perpetual contract can call this function
    /// @param orderSender is the one who submit tradeData.
    /// @param tradeData contains orders, signatures and match info.
    function approveTrade(address orderSender, bytes calldata tradeData)
        external
        returns (
            address[] memory traderList,
            int256[] memory paperChangeList,
            int256[] memory creditChangeList
        );

    /// @notice Check if the trader's margin is enough (>= maintenance margin).
    /// If so, the trader is "safe".
    /// The trader's positions under all markets will be liquidated if he is
    /// not safe.
    function isSafe(address trader) external view returns (bool);

    /// @notice Check if a list of traders are safe.
    /// @dev This function is more gas effective than isSafe, by caching
    /// mark prices.
    function isAllSafe(address[] calldata traderList)
        external
        view
        returns (bool);

    /// @notice Get funding rate of a perpetual market.
    /// Funding rate is a 1e18 based decimal.
    function getFundingRate(address perp) external view returns (int256);

    /// @notice Update multiple funding rate at once.
    /// Can only be called by funding rate keeper.
    function updateFundingRate(
        address[] calldata perpList,
        int256[] calldata rateList
    ) external;

    /// @notice Calculate the paper and credit change of liquidator and
    /// liquidated trader.
    /// @dev Only perpetual contract can call this function.
    /// liqtor is short for liquidator, liqed is short for liquidated trader.
    /// @param liquidator is the one who will take over positions.
    /// @param liquidatedTrader is the one who is being liquidated.
    /// @param requestPaperAmount is the size that the liquidator wants to take.
    /// Positive if the position is long, negative if the position is short.
    function requestLiquidation(
        address liquidator,
        address liquidatedTrader,
        int256 requestPaperAmount
    )
        external
        returns (
            int256 liqtorPaperChange,
            int256 liqtorCreditChange,
            int256 liqedPaperChange,
            int256 liqedCreditChange
        );

    /// @notice Transfer all bad debt to insurance account,
    /// including primary and secondary balances.
    function handleBadDebt(address liquidatedTrader) external;

    /// @notice Register the trader's position into dealer.
    /// @dev Only perpetual contract can call this function when
    /// someone's position is opened.
    function openPosition(address trader) external;

    /// @notice Accrual realized pnl and remove the trader's position from dealer.
    /// @dev Only perpetual contract can call this function when
    /// someone's position is closed.
    function realizePnl(address trader, int256 pnl) external;

    /// @notice Register operator.
    /// The operator can sign order on your behalf.
    function setOperator(address operator, bool isValid) external;

    /// @param perp the address of perpetual contract market
    function getRiskParams(address perp)
        external
        view
        returns (Types.RiskParams memory params);

    /// @notice Return all registered perpetual contract market.
    function getAllRegisteredPerps() external view returns (address[] memory);

    /// @notice Return mark price of a perpetual market.
    /// price is a 1e18 based decimal.
    function getMarkPrice(address perp) external view returns (uint256);

    /// @notice Get all open positions of the trader.
    function getPositions(address trader)
        external
        view
        returns (address[] memory);

    /// @notice Return the credit details of the trader.
    /// You cannot use credit as net value or net margin of a trader.
    /// The net value of positions would also be included.
    function getCreditOf(address trader)
        external
        view
        returns (
            int256 primaryCredit,
            uint256 secondaryCredit,
            uint256 pendingPrimaryWithdraw,
            uint256 pendingSecondaryWithdraw,
            uint256 executionTimestamp
        );

    /// @notice Get the risk profile data of a trader.
    /// @return netValue net value of trader including credit amount
    /// @return exposure open position value of the trader across all markets
    function getTraderRisk(address trader)
        external
        view
        returns (
            int256 netValue,
            uint256 exposure,
            uint256 maintenanceMargin
        );

    /// @notice Get liquidation price of a position
    /// @dev This function is for directional use. The margin of error is typically
    /// within 10 wei.
    /// @return liquidationPrice equals 0 if there is no liquidation price.
    function getLiquidationPrice(address trader, address perp)
        external
        view
        returns (uint256 liquidationPrice);

    /// @notice a view version of requestLiquidation, liquidators can use
    /// this function to check how much you have to pay in advance.
    function getLiquidationCost(
        address perp,
        address liquidatedTrader,
        int256 requestPaperAmount
    )
        external
        view
        returns (int256 liqtorPaperChange, int256 liqtorCreditChange);

    /// @notice Get filled paper amount of an order to avoid double matching.
    /// @return filledAmount includes paper amount
    function getOrderFilledAmount(bytes32 orderHash)
        external
        view
        returns (uint256 filledAmount);

    /// @notice check if order sender is valid
    function isOrderSenderValid(address orderSender)
        external
        view
        returns (bool);

    /// @notice check if operator is valid
    function isOperatorValid(address client, address operator)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
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

/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

library Types {
    /// @notice data structure of dealer
    struct State {
        // primary asset, ERC20
        address primaryAsset;
        // secondary asset, ERC20
        address secondaryAsset;
        // credit, gained by deposit assets
        mapping(address => int256) primaryCredit;
        mapping(address => uint256) secondaryCredit;
        // withdrawal request time lock
        uint256 withdrawTimeLock;
        // pending primary asset withdrawal amount
        mapping(address => uint256) pendingPrimaryWithdraw;
        // pending secondary asset withdrawal amount
        mapping(address => uint256) pendingSecondaryWithdraw;
        // withdrawal request executable timestamp
        mapping(address => uint256) withdrawExecutionTimestamp;
        // perpetual contract risk parameters
        mapping(address => Types.RiskParams) perpRiskParams;
        // perpetual contract registry, for view
        address[] registeredPerp;
        // all open positions of a trader
        mapping(address => address[]) openPositions;
        // To quickly search if a trader has open position:
        // trader => perpetual contract address => hasPosition
        mapping(address => mapping(address => bool)) hasPosition;
        // For offchain pnl calculation, serial number +1 whenever 
        // position is fully closed.
        // trader => perpetual contract address => current serial Num
        mapping(address => mapping(address => uint256)) positionSerialNum;
        // filled amount of orders
        mapping(bytes32 => uint256) orderFilledPaperAmount;
        // valid order sender registry
        mapping(address => bool) validOrderSender;
        // operator registry
        // client => operator => isValid
        mapping(address => mapping(address => bool)) operatorRegistry;
        // insurance account
        address insurance;
        // funding rate keeper, normally an EOA account
        address fundingRateKeeper;
    }

    struct Order {
        // address of perpetual market
        address perp;
        /*
            Signer is trader, the identity of trading behavior,
            whose balance will be changed.
            Normally it should be an EOA account and the 
            order is valid only if the signer signed it.
            If the signer is a contract, it must implement
            isValidPerpetualOperator(address) returns(bool).
            The order is valid only if one of the valid operators
            is an EOA account and signed the order.
        */
        address signer;
        // positive(negative) if you want to open long(short) position
        int128 paperAmount;
        // negative(positive) if you want to open short(long) position
        int128 creditAmount;
        /*
            ╔═══════════════════╤═════════╗
            ║ info component    │ type    ║
            ╟───────────────────┼─────────╢
            ║ makerFeeRate      │ int64   ║
            ║ takerFeeRate      │ int64   ║
            ║ expiration        │ uint64  ║
            ║ nonce             │ uint64  ║
            ╚═══════════════════╧═════════╝
        */
        bytes32 info;
    }

    // EIP712 component
    bytes32 public constant ORDER_TYPEHASH =
        keccak256(
            "Order(address perp,address signer,int128 paperAmount,int128 creditAmount,bytes32 info)"
        );

    /// @notice risk params of a perpetual market
    struct RiskParams {
        /*
            Liquidation will happen when
            netValue < exposure * liquidationThreshold
            The lower liquidationThreshold, the higher leverage.
            1E18 based decimal.
        */
        uint256 liquidationThreshold;
        /*
            The discount rate for the liquidation.
            markPrice * (1 - liquidationPriceOff) when liquidate long position
            markPrice * (1 + liquidationPriceOff) when liquidate short position
            1e18 based decimal.
        */
        uint256 liquidationPriceOff;
        // The insurance fee rate charged from liquidation. 
        // 1E18 based decimal.
        uint256 insuranceFeeRate;
        // price source of mark price
        address markPriceSource;
        // perpetual market name
        string name;
        // if the market is activited
        bool isRegistered;
    }

    /// @notice Match result obtained by parsing and validating tradeData.
    /// Contains arrays of balance change.
    struct MatchResult {
        address[] traderList;
        int256[] paperChangeList;
        int256[] creditChangeList;
        int256 orderSenderFee;
    }

    uint256 constant ONE = 10**18;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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