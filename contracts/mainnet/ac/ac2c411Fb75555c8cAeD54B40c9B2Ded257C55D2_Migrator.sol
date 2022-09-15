// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IVault.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";

contract Migrator {
    IUniswapV2Router02 constant router =
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    IERC20 constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 constant AMES = IERC20(0xb9E05B4C168B56F73940980aE6EF366354357009);
    IERC20 constant ASHARE = IERC20(0xFa4b16b0f63F5A6D0651592620D585D308F749A4);

    IERC20 constant AMES_LP = IERC20(0x81722a6457e1825050B999548a35E30d9f11dB5c);
    IERC20 constant ASHARE_LP = IERC20(0x91da56569559b0629f076dE73C05696e34Ee05c1);

    IVault public constant vault = IVault(0xEE1c8DbfBf958484c6a4571F5FB7b99B74A54AA7);

    bytes32 constant AMES_POOL_ID =
        0x9aa867870d5775a3c155325db0cb0b116bbf4b6a000200000000000000000002;

    bytes32 constant ASHARE_POOL_ID =
        0x74154c70f113c2b603aa49899371d05eeedd1e8c000200000000000000000003;

    enum PoolType {
        AMES,
        ASHARE
    }

    constructor() {}

    function migrate(uint256 amount, PoolType _poolType) external {
        if (_poolType == PoolType.AMES) {
            _handleAmesMigration(amount);
        } else {
            _handleAshareMigration(amount);
        }
    }

    function _handleAmesMigration(uint256 amount) internal {
        require(AMES_LP.transferFrom(msg.sender, address(this), amount), "ERR TRANSFER FROM");

        // AMES is token0
        _removeLiquidity(AMES_LP, address(AMES), address(BUSD));

        // Need to be in sorted order for vault
        address[] memory tokens = new address[](2);
        tokens[0] = address(AMES);
        tokens[1] = address(BUSD);

        uint256[] memory balances = new uint256[](2);
        balances[0] = AMES.balanceOf(address(this));
        balances[1] = BUSD.balanceOf(address(this));

        _pairLiquidity(msg.sender, balances, AMES_POOL_ID, tokens);
    }

    function _handleAshareMigration(uint256 amount) internal {
        require(ASHARE_LP.transferFrom(msg.sender, address(this), amount), "ERR TRANSFER FROM");
        // Share is token1
        _removeLiquidity(ASHARE_LP, address(BUSD), address(ASHARE));

        // Need to be in sorted order for vault
        address[] memory tokens = new address[](2);
        tokens[0] = address(BUSD);
        tokens[1] = address(ASHARE);

        uint256[] memory balances = new uint256[](2);
        balances[0] = BUSD.balanceOf(address(this));
        balances[1] = ASHARE.balanceOf(address(this));

        _pairLiquidity(msg.sender, balances, ASHARE_POOL_ID, tokens);
    }

    function _removeLiquidity(
        IERC20 _lpToken,
        address _token0,
        address _token1
    ) internal {
        _lpToken.approve(address(router), _lpToken.balanceOf(address(this)));
        router.removeLiquidity(
            _token0,
            _token1,
            _lpToken.balanceOf(address(this)),
            0,
            0,
            address(this),
            block.timestamp + 100
        );
    }

    function _pairLiquidity(
        address _lpTokenRecipient,
        uint256[] memory _initialBalances,
        bytes32 _poolId,
        address[] memory _tokens
    ) internal {
        require(
            _tokens.length == _initialBalances.length,
            "tokens.length != _initialBalances.length"
        );

        for (uint256 i = 0; i < _initialBalances.length; i++) {
            // Need to approve the vault first to pull the tokens
            IERC20(_tokens[i]).approve(address(vault), type(uint256).max);
        }

        // Put together a JoinPoolRequest type
        JoinPoolRequest memory joinRequest;
        joinRequest.tokens = _tokens;
        joinRequest.maxAmountsIn = _initialBalances;
        // In this case we do not need to be concerned with internal balances
        joinRequest.fromInternalBalance = false;

        uint256 joinKind = 1; // INIT_JOIN
        // User data needs to be encoded
        // Different join types require different parameters to be encoded
        bytes memory userJoinDataEncoded = abi.encode(joinKind, _initialBalances);
        joinRequest.userData = userJoinDataEncoded;

        // Tokens are pulled from sender (Or could be an approved relayer)
        address sender = address(this);
        vault.joinPool(_poolId, sender, _lpTokenRecipient, joinRequest);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct JoinPoolRequest {
    address[] tokens;
    uint256[] maxAmountsIn;
    bytes userData;
    bool fromInternalBalance;
}

interface IVault {
    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory joinPoolRequest
    ) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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
pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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