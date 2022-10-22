// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../swap/IBonfireMetaRouter.sol";
import "../strategies/IBonfireStrategyAccumulator.sol";
import "../utils/IBonfireChecker.sol";

contract MetaAccumulate {
    address public constant meta =
        address(0xBF000001D78F7C459255f461C0685118820c1c96);
    address public immutable bonusToken;
    address public immutable checker;

    constructor(address _bonusToken, address _checker) {
        bonusToken = _bonusToken;
        checker = _checker;
    }

    function quote() external view returns (uint256 amountOut) {
        address accumulator = IBonfireMetaRouter(meta).accumulator();
        amountOut = IBonfireStrategyAccumulator(accumulator).quote(
            bonusToken,
            1
        );
        amountOut = _takeFee(amountOut);
    }

    function accumulate() external returns (uint256 amount) {
        IBonfireChecker(checker).bonfireCheck();
        address accumulator = IBonfireMetaRouter(meta).accumulator();
        IBonfireStrategyAccumulator(accumulator).execute(
            bonusToken,
            1,
            block.timestamp + 1,
            address(this)
        );
        IBonfireMetaRouter(meta).accumulate(bonusToken, 1);
        amount = IERC20(bonusToken).balanceOf(address(this));
        amount = _takeFee(amount);
        IERC20(bonusToken).transfer(msg.sender, amount);
        IERC20(bonusToken).transfer(
            meta,
            IERC20(bonusToken).balanceOf(address(this))
        );
    }

    function _takeFee(uint256 amount)
        internal
        view
        returns (uint256 remainder)
    {
        uint256 fee = 0;
        remainder = amount;
        uint256 p = IBonfireChecker(checker).validShares(msg.sender);
        uint256 q = IBonfireChecker(checker).totalShares();
        if (p > 1e9 * 1e7) {
            fee = amount / 100;
            if (p < q) {
                fee == (fee * (q - p)) / q;
            }
        } else fee = amount / 10;
        remainder = amount - fee;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireStrategyAccumulator {
    function tokenRegistered(address token)
        external
        view
        returns (bool registered);

    function quote(address token, uint256 threshold)
        external
        view
        returns (uint256 expectedGains);

    function execute(
        address token,
        uint256 threshold,
        uint256 deadline,
        address to
    ) external returns (uint256 gains);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireMetaRouter {
    function tracker() external view returns (address);

    function wrapper() external view returns (address);

    function paths() external view returns (address);

    function accumulator() external view returns (address);

    function accumulate(address token, uint256 tokenThreshold) external;

    function transferToken(
        address token,
        address to,
        uint256 amount,
        uint256 bonusThreshold
    ) external;

    function swapToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        address bonusToken,
        uint256 bonusThreshold
    ) external returns (uint256 amountB);

    function buyToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        address bonusToken,
        uint256 bonusThreshold
    ) external payable returns (uint256 amountB);

    function sellToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        address bonusToken,
        uint256 bonusThreshold
    ) external returns (uint256 amountB);

    function simpleQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to
    )
        external
        view
        returns (
            uint256 amountOut,
            address[] memory poolPath,
            address[] memory tokenPath,
            bytes32[] memory poolDescriptions,
            address bonusToken,
            uint256 bonusThreshold,
            uint256 bonusAmount,
            string memory message
        );

    function getBonusParameters(address[] calldata tokenPath)
        external
        view
        returns (
            address bonusToken,
            uint256 bonusThreshold,
            uint256 bonusAmount
        );

    function quote(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to
    ) external view returns (uint256 amountOut);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireChecker {
    function validShares(address account)
        external
        view
        returns (uint256 _validShares);

    function bonfireCheck() external;

    function totalShares() external view returns (uint256 _totalShares);
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