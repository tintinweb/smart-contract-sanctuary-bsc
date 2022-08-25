// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

import { UniversalERC20 } from "./lib/UniversalERC20.sol";
import { SafeERC20 } from "./lib/SafeERC20.sol";
import { DecimalMath } from "./lib/DecimalMath.sol";
import { ReentrancyGuard } from "./lib/ReentrancyGuard.sol";
import { SafeMath } from "./lib/SafeMath.sol";
import { IDODOV2 } from "./interfaces/IDODOV2.sol";
import { IDPPOracleAdmin } from "./interfaces/IDPPOracleAdmin.sol";
import { IERC20 } from "./interfaces/IERC20.sol";
import { IWETH } from "./interfaces/IWETH.sol";
import { Adminable } from "./lib/Adminable.sol";
import { DuetDppLpFunding } from "./DuetDppLpFunding.sol";

contract DuetDppController is Adminable, DuetDppLpFunding {
    using SafeMath for uint256;
    using UniversalERC20 for IERC20;
    using SafeERC20 for IERC20;

    address public _WETH_;
    bool flagInit = false;

    /** 主要用于frontrun保护，当项目方发起交易，修改池子参数时，可能会造成池子的价格改变，
     * 这时候机器人可能会frontrun套利，因此这两个参数设定后，
     * 当执行时池子现存的base，quote的数量小于传入的值，reset交易会revert，防止被套利 **/
    uint256 minBaseReserve = 0;
    uint256 minQuoteReserve = 0;

    modifier judgeExpired(uint256 deadLine) {
        require(deadLine >= block.timestamp, "DODOV2Proxy02: EXPIRED");
        _;
    }

    modifier notInitialized() {
        require(flagInit == false, "have been initialized");
        flagInit = true;
        _;
    }

    fallback() external payable {}

    receive() external payable {}

    function init(
        address admin,
        address dppAddress,
        address dppAdminAddress,
        address weth
    ) external notInitialized {
        // 改init
        _WETH_ = weth;
        _DPP_ADDRESS_ = dppAddress;
        _DPP_ADMIN_ADDRESS_ = dppAdminAddress;
        _setAdmin(admin);

        // load pool info
        _BASE_TOKEN_ = IERC20(IDODOV2(_DPP_ADDRESS_)._BASE_TOKEN_());
        _QUOTE_TOKEN_ = IERC20(IDODOV2(_DPP_ADDRESS_)._QUOTE_TOKEN_());
        _updateDppInfo();

        string memory connect = "_";
        string memory suffix = "Duet";

        name = string(abi.encodePacked(suffix, connect, addressToShortString(address(this))));
        symbol = "Duet_LP";
        decimals = _BASE_TOKEN_.decimals();

        // ============================== Permit ====================================
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                // keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
        // ==========================================================================
    }

    // ========= change DPP Oracle and Parameters , onlyAdmin ==========
    function tunePrice(
        uint256 newI,
        uint256 minBaseReserve_,
        uint256 minQuoteReserve_
    ) external onlyAdmin returns (bool) {
        IDPPOracleAdmin(_DPP_ADMIN_ADDRESS_).tunePrice(newI, minBaseReserve_, minQuoteReserve_);
        _updateDppInfo();
        return true;
    }

    function tuneParameters(
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 minBaseReserve_,
        uint256 minQuoteReserve_
    ) external onlyAdmin returns (bool) {
        IDPPOracleAdmin(_DPP_ADMIN_ADDRESS_).tuneParameters(
            newLpFeeRate,
            newI,
            newK,
            minBaseReserve_,
            minQuoteReserve_
        );
        _updateDppInfo();
        return true;
    }

    function changeOracle(address newOracle) external onlyAdmin {
        IDPPOracleAdmin(_DPP_ADMIN_ADDRESS_).changeOracle(newOracle);
    }

    function enableOracle() external onlyAdmin {
        IDPPOracleAdmin(_DPP_ADMIN_ADDRESS_).enableOracle();
    }

    function disableOracle(uint256 newI) external onlyAdmin {
        IDPPOracleAdmin(_DPP_ADMIN_ADDRESS_).disableOracle(newI);
    }

    function changeMinRes(uint256 newBaseR_, uint256 newQuoteR_) external onlyAdmin {
        minBaseReserve = newBaseR_;
        minQuoteReserve = newQuoteR_;
    }

    // =========== deal with LP ===============

    function addDuetDppLiquidity(
        uint256 baseInAmount,
        uint256 quoteInAmount,
        uint256 baseMinAmount,
        uint256 quoteMinAmount,
        uint8 flag, // 0 - ERC20, 1 - baseInETH, 2 - quoteInETH
        uint256 deadLine
    )
        external
        payable
        preventReentrant
        judgeExpired(deadLine)
        returns (
            uint256 shares,
            uint256 baseAdjustedInAmount,
            uint256 quoteAdjustedInAmount
        )
    {
        (baseAdjustedInAmount, quoteAdjustedInAmount) = _adjustedAddLiquidityInAmount(baseInAmount, quoteInAmount);
        require(
            baseAdjustedInAmount >= baseMinAmount && quoteAdjustedInAmount >= quoteMinAmount,
            "Duet Dpp Controller: deposit amount is not enough"
        );

        _deposit(msg.sender, _DPP_ADDRESS_, IDODOV2(_DPP_ADDRESS_)._BASE_TOKEN_(), baseAdjustedInAmount, flag == 1);
        _deposit(msg.sender, _DPP_ADDRESS_, IDODOV2(_DPP_ADDRESS_)._QUOTE_TOKEN_(), quoteAdjustedInAmount, flag == 2);

        //mint lp tokens to users

        (shares, , ) = _buyShares(msg.sender);
        // reset dpp pool
        require(
            IDODOV2(IDODOV2(_DPP_ADDRESS_)._OWNER_()).reset(
                address(this),
                _LP_FEE_RATE_,
                _I_,
                _K_,
                0,
                0,
                minBaseReserve, // minBaseReserve
                minQuoteReserve // minQuoteReserve
            ),
            "Reset Failed"
        );

        // refund dust eth
        if (flag == 1 && msg.value > baseAdjustedInAmount) {
            payable(msg.sender).transfer(msg.value - baseAdjustedInAmount);
        }
        if (flag == 2 && msg.value > quoteAdjustedInAmount) {
            payable(msg.sender).transfer(msg.value - quoteAdjustedInAmount);
        }
    }

    function removeDuetDppLiquidity(
        uint256 shareAmount,
        uint256 baseMinAmount,
        uint256 quoteMinAmount,
        uint8 flag, // 0 - ERC20, 1 - baseInETH, 2 - quoteInETH, 3 - baseOutETH, 4 - quoteOutETH
        uint256 deadLine
    )
        external
        preventReentrant
        judgeExpired(deadLine)
        returns (
            uint256 shares,
            uint256 baseOutAmount,
            uint256 quoteOutAmount
        )
    {
        //mint lp tokens to users
        (baseOutAmount, quoteOutAmount) = _sellShares(shareAmount, msg.sender, baseMinAmount, quoteMinAmount);
        // reset dpp pool
        require(
            IDODOV2(IDODOV2(_DPP_ADDRESS_)._OWNER_()).reset(
                address(this),
                _LP_FEE_RATE_,
                _I_,
                _K_,
                baseOutAmount,
                quoteOutAmount,
                minBaseReserve, //minBaseReserve,
                minQuoteReserve //minQuoteReserve
            ),
            "Reset Failed"
        );

        _withdraw(payable(msg.sender), IDODOV2(_DPP_ADDRESS_)._BASE_TOKEN_(), baseOutAmount, flag == 3);
        _withdraw(payable(msg.sender), IDODOV2(_DPP_ADDRESS_)._QUOTE_TOKEN_(), quoteOutAmount, flag == 4);
        shares = shareAmount;
    }

    function _adjustedAddLiquidityInAmount(uint256 baseInAmount, uint256 quoteInAmount)
        internal
        view
        returns (uint256 baseAdjustedInAmount, uint256 quoteAdjustedInAmount)
    {
        (uint256 baseReserve, uint256 quoteReserve) = IDODOV2(_DPP_ADDRESS_).getVaultReserve();
        if (quoteReserve == 0 && baseReserve == 0) {
            require(msg.sender == admin, "Must initialized by admin");
            // Must initialized by admin
            baseAdjustedInAmount = baseInAmount;
            quoteAdjustedInAmount = quoteInAmount;
        }
        if (quoteReserve == 0 && baseReserve > 0) {
            baseAdjustedInAmount = baseInAmount;
            quoteAdjustedInAmount = 0;
        }
        if (quoteReserve > 0 && baseReserve > 0) {
            uint256 baseIncreaseRatio = DecimalMath.divFloor(baseInAmount, baseReserve);
            uint256 quoteIncreaseRatio = DecimalMath.divFloor(quoteInAmount, quoteReserve);
            if (baseIncreaseRatio <= quoteIncreaseRatio) {
                baseAdjustedInAmount = baseInAmount;
                quoteAdjustedInAmount = DecimalMath.mulFloor(quoteReserve, baseIncreaseRatio);
            } else {
                quoteAdjustedInAmount = quoteInAmount;
                baseAdjustedInAmount = DecimalMath.mulFloor(baseReserve, quoteIncreaseRatio);
            }
        }
    }

    // ================= internal ====================

    function _updateDppInfo() internal {
        _LP_FEE_RATE_ = IDODOV2(_DPP_ADDRESS_)._LP_FEE_RATE_();
        _K_ = IDODOV2(_DPP_ADDRESS_)._K_();
        _I_ = IDODOV2(_DPP_ADDRESS_)._I_();
    }

    function _deposit(
        address from,
        address to,
        address token,
        uint256 amount,
        bool isETH
    ) internal {
        if (isETH) {
            if (amount > 0) {
                require(msg.value >= amount, "ETH_VALUE_WRONG");
                // case:msg.value > adjustAmount
                IWETH(_WETH_).deposit{ value: amount }();
                if (to != address(this)) SafeERC20.safeTransfer(IERC20(_WETH_), to, amount);
            }
        } else {
            if (amount > 0) {
                IERC20(token).safeTransferFrom(from, to, amount);
            }
        }
    }

    function _withdraw(
        address payable to,
        address token,
        uint256 amount,
        bool isETH
    ) internal {
        if (isETH) {
            if (amount > 0) {
                IWETH(_WETH_).withdraw(amount);
                to.transfer(amount);
            }
        } else {
            if (amount > 0) {
                SafeERC20.safeTransfer(IERC20(token), to, amount);
            }
        }
    }

    // =================================================

    function addressToShortString(address _addr) public pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(8);
        for (uint256 i = 0; i < 4; i++) {
            str[i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[1 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}

pragma solidity 0.8.9;

import { SafeMath } from "./SafeMath.sol";
import { IERC20 } from "../interfaces/IERC20.sol";
import { SafeERC20 } from "./SafeERC20.sol";

library UniversalERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(
        IERC20 token,
        address payable to,
        uint256 amount
    ) internal {
        if (amount > 0) {
            if (isETH(token)) {
                to.transfer(amount);
            } else {
                token.safeTransfer(to, amount);
            }
        }
    }

    function universalApproveMax(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        uint256 allowance = token.allowance(address(this), to);
        if (allowance < amount) {
            if (allowance > 0) {
                token.safeApprove(to, 0);
            }
            token.safeApprove(to, type(uint256).max);
        }
    }

    function universalBalanceOf(IERC20 token, address who) internal view returns (uint256) {
        if (isETH(token)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }

    function tokenBalanceOf(IERC20 token, address who) internal view returns (uint256) {
        return token.balanceOf(who);
    }

    function isETH(IERC20 token) internal pure returns (bool) {
        return token == ETH_ADDRESS;
    }
}

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0
    This is a simplified version of OpenZepplin's SafeERC20 library

*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import { IERC20 } from "../interfaces/IERC20.sol";
import { SafeMath } from "./SafeMath.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

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

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import { SafeMath } from "./SafeMath.sol";

/**
 * @title DecimalMath
 * @author DODO Breeder
 *
 * @notice Functions for fixed point number with 18 decimals
 */
library DecimalMath {
    using SafeMath for uint256;

    uint256 internal constant ONE = 10**18;
    uint256 internal constant ONE2 = 10**36;

    function mulFloor(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(d) / (10**18);
    }

    function mulCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(d).divCeil(10**18);
    }

    function divFloor(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(10**18).div(d);
    }

    function divCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(10**18).divCeil(d);
    }

    function reciprocalFloor(uint256 target) internal pure returns (uint256) {
        return uint256(10**36).div(target);
    }

    function reciprocalCeil(uint256 target) internal pure returns (uint256) {
        return uint256(10**36).divCeil(target);
    }

    function powFloor(uint256 target, uint256 e) internal pure returns (uint256) {
        if (e == 0) {
            return 10**18;
        } else if (e == 1) {
            return target;
        } else {
            uint256 p = powFloor(target, e.div(2));
            p = p.mul(p) / (10**18);
            if (e % 2 == 1) {
                p = p.mul(target) / (10**18);
            }
            return p;
        }
    }
}

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

/**
 * @title ReentrancyGuard
 * @author DODO Breeder
 *
 * @notice Protect functions from Reentrancy Attack
 */
contract ReentrancyGuard {
    // https://solidity.readthedocs.io/en/latest/control-structures.html?highlight=zero-state#scoping-and-declarations
    // zero-state of _ENTERED_ is false
    bool private _ENTERED_;

    modifier preventReentrant() {
        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
}

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface IDODOV2 {
    //========== Common ==================

    function sellBase(address to) external returns (uint256 receiveQuoteAmount);

    function sellQuote(address to) external returns (uint256 receiveBaseAmount);

    function getVaultReserve() external view returns (uint256 baseReserve, uint256 quoteReserve);

    function _BASE_TOKEN_() external view returns (address);

    function _QUOTE_TOKEN_() external view returns (address);

    function getPMMStateForCall()
        external
        view
        returns (
            uint256 i,
            uint256 K,
            uint256 B,
            uint256 Q,
            uint256 B0,
            uint256 Q0,
            uint256 R
        );

    function getUserFeeRate(address user) external view returns (uint256 lpFeeRate, uint256 mtFeeRate);

    function getDODOPoolBidirection(address token0, address token1)
        external
        view
        returns (address[] memory, address[] memory);

    //========== DODOVendingMachine ========

    function createDODOVendingMachine(
        address baseToken,
        address quoteToken,
        uint256 lpFeeRate,
        uint256 i,
        uint256 k,
        bool isOpenTWAP
    ) external returns (address newVendingMachine);

    function buyShares(address to)
        external
        returns (
            uint256,
            uint256,
            uint256
        );

    //========== DODOPrivatePool ===========

    function createDODOPrivatePool() external returns (address newPrivatePool);

    function initDODOPrivatePool(
        address dppAddress,
        address creator,
        address baseToken,
        address quoteToken,
        uint256 lpFeeRate,
        uint256 k,
        uint256 i,
        bool isOpenTwap
    ) external;

    function reset(
        address operator,
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 baseOutAmount,
        uint256 quoteOutAmount,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);

    function _OWNER_() external returns (address);

    function _LP_FEE_RATE_() external returns (uint64);

    function _K_() external returns (uint64);

    function _I_() external returns (uint128);

    //========== CrowdPooling ===========

    function createCrowdPooling() external returns (address payable newCrowdPooling);

    function initCrowdPooling(
        address cpAddress,
        address creator,
        address[] memory tokens,
        uint256[] memory timeLine,
        uint256[] memory valueList,
        bool[] memory switches,
        int256 globalQuota
    ) external;

    function bid(address to) external;
}

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface IDPPOracleAdmin {
    function init(
        address owner,
        address dpp,
        address operator,
        address dodoApproveProxy
    ) external;

    //=========== admin ==========
    function ratioSync() external;

    function retrieve(
        address payable to,
        address token,
        uint256 amount
    ) external;

    function reset(
        address assetTo,
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 baseOutAmount,
        uint256 quoteOutAmount,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);

    function tuneParameters(
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);

    function tunePrice(
        uint256 newI,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) external returns (bool);

    function changeOracle(address newOracle) external;

    function enableOracle() external;

    function disableOracle(uint256 newI) external;
}

// This is a file copied from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface IWETH {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

abstract contract Adminable {
    event AdminUpdated(address indexed user, address indexed newAdmin);

    address public admin;

    modifier onlyAdmin() virtual {
        require(msg.sender == admin, "UNAUTHORIZED");

        _;
    }

    function setAdmin(address newAdmin) public virtual onlyAdmin {
        _setAdmin(newAdmin);
    }

    function _setAdmin(address newAdmin) internal {
        require(newAdmin != address(0), "Can not set admin to zero address");
        admin = newAdmin;

        emit AdminUpdated(msg.sender, newAdmin);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import { DecimalMath } from "./lib/DecimalMath.sol";
import { ReentrancyGuard } from "./lib/ReentrancyGuard.sol";
import { SafeMath } from "./lib/SafeMath.sol";
import { IDODOV2 } from "./interfaces/IDODOV2.sol";
import { DuetDppLp } from "./DuetDppLp.sol";

contract DuetDppLpFunding is DuetDppLp, ReentrancyGuard {
    using SafeMath for uint256;
    // ============ Events ============

    event BuyShares(address to, uint256 increaseShares, uint256 totalShares);

    event SellShares(address payer, address to, uint256 decreaseShares, uint256 totalShares);

    // ============ Buy & Sell Shares ============

    // buy shares [round down]
    function _buyShares(address to)
        internal
        returns (
            uint256 shares,
            uint256 baseInput,
            uint256 quoteInput
        )
    {
        uint256 baseBalance = _BASE_TOKEN_.balanceOf(_DPP_ADDRESS_);
        uint256 quoteBalance = _QUOTE_TOKEN_.balanceOf(_DPP_ADDRESS_);
        (uint256 baseReserve, uint256 quoteReserve) = IDODOV2(_DPP_ADDRESS_).getVaultReserve();

        baseInput = baseBalance.sub(baseReserve);
        quoteInput = quoteBalance.sub(quoteReserve);
        require(baseInput > 0, "NO_BASE_INPUT");

        // Round down when withdrawing. Therefore, never be a situation occuring balance is 0 but totalsupply is not 0
        // But May Happen，reserve >0 But totalSupply = 0
        if (totalSupply == 0) {
            // case 1. initial supply
            require(baseBalance >= 10**3, "INSUFFICIENT_LIQUIDITY_MINED");
            shares = baseBalance; // 以免出现balance很大但shares很小的情况
        } else if (baseReserve > 0 && quoteReserve == 0) {
            // case 2. supply when quote reserve is 0
            shares = baseInput.mul(totalSupply).div(baseReserve);
        } else if (baseReserve > 0 && quoteReserve > 0) {
            // case 3. normal case
            uint256 baseInputRatio = DecimalMath.divFloor(baseInput, baseReserve);
            uint256 quoteInputRatio = DecimalMath.divFloor(quoteInput, quoteReserve);
            uint256 mintRatio = quoteInputRatio < baseInputRatio ? quoteInputRatio : baseInputRatio;
            shares = DecimalMath.mulFloor(totalSupply, mintRatio);
        }
        _mint(to, shares);
        emit BuyShares(to, shares, _SHARES_[to]);
    }

    // sell shares [round down]
    function _sellShares(
        uint256 shareAmount,
        address to,
        uint256 baseMinAmount,
        uint256 quoteMinAmount
    ) internal returns (uint256 baseAmount, uint256 quoteAmount) {
        require(shareAmount <= _SHARES_[to], "DLP_NOT_ENOUGH");
        (uint256 baseBalance, uint256 quoteBalance) = IDODOV2(_DPP_ADDRESS_).getVaultReserve();
        uint256 totalShares = totalSupply;

        baseAmount = baseBalance.mul(shareAmount).div(totalShares);
        quoteAmount = quoteBalance.mul(shareAmount).div(totalShares);

        require(baseAmount >= baseMinAmount && quoteAmount >= quoteMinAmount, "WITHDRAW_NOT_ENOUGH");

        _burn(to, shareAmount);

        emit SellShares(to, to, shareAmount, _SHARES_[to]);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import { IERC20 } from "./interfaces/IERC20.sol";
import { SafeMath } from "./lib/SafeMath.sol";
import { DecimalMath } from "./lib/DecimalMath.sol";
import { SafeERC20 } from "./lib/SafeERC20.sol";
import { DuetDppStorage } from "./DuetDppStorage.sol";

contract DuetDppLp is DuetDppStorage {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Events ============

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Mint(address indexed user, uint256 value);

    event Burn(address indexed user, uint256 value);

    // ============ Shares (ERC20) ============

    /**
     * @dev transfer token for a specified address
     * @param to The address to transfer to.
     * @param amount The amount to be transferred.
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        require(amount <= _SHARES_[msg.sender], "BALANCE_NOT_ENOUGH");

        _SHARES_[msg.sender] = _SHARES_[msg.sender].sub(amount);
        _SHARES_[to] = _SHARES_[to].add(amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the the balance of.
     * @return balance An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) external view returns (uint256 balance) {
        return _SHARES_[owner];
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param amount uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(amount <= _SHARES_[from], "BALANCE_NOT_ENOUGH");
        require(amount <= _ALLOWED_[from][msg.sender], "ALLOWANCE_NOT_ENOUGH");

        _SHARES_[from] = _SHARES_[from].sub(amount);
        _SHARES_[to] = _SHARES_[to].add(amount);
        _ALLOWED_[from][msg.sender] = _ALLOWED_[from][msg.sender].sub(amount);
        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param spender The address which will spend the funds.
     * @param amount The amount of tokens to be spent.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        _ALLOWED_[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Function to check the amount of tokens that an owner _ALLOWED_ to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _ALLOWED_[owner][spender];
    }

    function _mint(address user, uint256 value) internal {
        require(value > 1000, "MINT_INVALID");
        _SHARES_[user] = _SHARES_[user].add(value);
        totalSupply = totalSupply.add(value);
        emit Mint(user, value);
        emit Transfer(address(0), user, value);
    }

    function _burn(address user, uint256 value) internal {
        _SHARES_[user] = _SHARES_[user].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Burn(user, value);
        emit Transfer(user, address(0), value);
    }

    // ============================ Permit ======================================

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "DODO_DVM_LP: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "DODO_DVM_LP: INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

import { IERC20 } from "./interfaces/IERC20.sol";

contract DuetDppStorage {
    // ============ pool info ===============
    address public _DPP_ADDRESS_;
    address public _DPP_ADMIN_ADDRESS_;
    IERC20 public _BASE_TOKEN_;
    IERC20 public _QUOTE_TOKEN_;
    uint64 public _LP_FEE_RATE_;
    uint128 public _I_;
    uint64 public _K_;

    // ============ Shares (ERC20) ============

    string public symbol;
    uint8 public decimals;
    string public name;

    uint256 public totalSupply;
    mapping(address => uint256) internal _SHARES_;
    mapping(address => mapping(address => uint256)) internal _ALLOWED_;

    // ================= Permit ======================

    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;
}