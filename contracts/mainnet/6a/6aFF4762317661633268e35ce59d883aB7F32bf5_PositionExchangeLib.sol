// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./PositionInfo.sol";
import "./interfaces/IPriceOracle.sol";
import "./interfaces/IERC20Decimals.sol";

library PositionExchangeLib {
    uint public constant POSITION_PRICE_LIMITS_MULTIPLIER = 1e8;
    uint public constant SLIPPAGE_MULTIPLIER = 1e8;

    function isPriceOutsideRange(
        PositionInfo memory position,
        uint priceNumerator,
        uint priceDenominator,
        uint8 numeratorDecimals,
        uint8 denominatorDecimals
    ) public view returns (bool) {
        if (denominatorDecimals > numeratorDecimals) {
            priceNumerator *= 10**(denominatorDecimals - numeratorDecimals);
        } else if (numeratorDecimals > denominatorDecimals) {
            priceDenominator *= 10**(numeratorDecimals - denominatorDecimals);
        }

        // priceFloat = priceNumerator / priceDenominator
        // stopLossPriceFloat = position.stopLossPrice / POSITION_PRICE_LIMITS_MULTIPLIER
        // if
        // priceNumerator / priceDenominator > position.stopLossPrice / POSITION_PRICE_LIMITS_MULTIPLIER
        // then
        // priceNumerator * POSITION_PRICE_LIMITS_MULTIPLIER > position.stopLossPrice * priceDenominator

        if (
            position.stopLossPrice != 0 &&
            priceNumerator * POSITION_PRICE_LIMITS_MULTIPLIER < position.stopLossPrice * priceDenominator
        ) return true;

        if (
            position.takeProfitPrice != 0 &&
            priceNumerator * POSITION_PRICE_LIMITS_MULTIPLIER > position.takeProfitPrice * priceDenominator
        ) return true;

        return false;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

import "./ProxyCaller.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

struct PositionInfo {
    uint stakedAmount; // wei
    uint feeAmount; // FEE_MULTIPLIER
    uint stopLossPrice; // POSITION_PRICE_LIMITS_MULTIPLIER
    uint maxSlippage; // SLIPPAGE_MULTIPLIER
    address poolAddress;
    address owner;
    ProxyCaller callerAddress;
    bool closed;
    uint takeProfitPrice; // POSITION_PRICE_LIMITS_MULTIPLIER
    IERC20Upgradeable stakedToken;
    IERC20Upgradeable rewardToken;
    bytes32 gelatoLiquidateTaskId; // TODO: rename to gelatoTaskId when deploy clean version
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceOracle {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IERC20Decimals is IERC20Upgradeable {
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ProxyCaller contract is deployed frequently, and in order to reduce gas
// it has to be as small as possible
contract ProxyCaller {
    address immutable _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    function exec(
        bool delegate,
        address target,
        bytes calldata data
    ) external onlyOwner returns (bool success, bytes memory) {
        if (delegate) {
            return target.delegatecall(data);
        }
        return target.call(data);
    }

    function transfer(address target, uint256 amount) external onlyOwner returns (bool success, bytes memory) {
        return target.call{value: amount}("");
    }

    receive() external payable {}
}