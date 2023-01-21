/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

/*
 * Day of Defeat (DOD)
 *
 * Radical Social Experiment token mathematically designed to give holders 10,000,000X PRICE INCREASE
 *
 * Website: https://dayofdefeat.app/
 * Twitter: https://twitter.com/dayofdefeatBSC
 * Telegram: https://t.me/DayOfDefeatBSC
 * BTok: https://titanservice.cn/dayofdefeatCN
 *
 * By Studio L, Legacy Capital Division
*/

// SPDX-License-Identifier: MIT

// File: StudioL/DOD/lib/SafeTransferLib.sol


pragma solidity ^0.8.0;

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        address token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
// File: StudioL/DOD/interface/IPancakeSwapRouter.sol


pragma solidity ^0.8.0;

interface IPancakeSwapRouter {
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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

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

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: StudioL/DOD/MarketingPool.sol


pragma solidity ^0.8.0;




contract MarketingPool {
    address public operator;

    address public dodToken;

    address public constant BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public governor; // governance contract

    address public marketingReceiver;

    address[] public swapPath = [dodToken, BNB];
    uint256 public swapToMarketingAmount = 1_200_000_000 * 10 ** 18; // 1,200,000,000 DOD / 6hours
    uint256 public swapToMarketingInterval = 6 hours;
    uint256 public lastSwapTime;
    bool public marketingStatus = true;

    mapping(address => bool) public access;

    event SetGovernor(address indexed newGovernor, address indexed oldGovernor);
    event SetMarketingReceiver(address indexed newReceiver, address indexed oldReceiver);
    event SetAccess(address indexed account, bool access);
    event SetForMarketingPath(address indexed operator, address[] path);
    event SetSwapToMarketingAmount(address indexed operator, uint256 amount);
    event SetSwapToMarketingInterval(
        address indexed operator,
        uint256 swapToFundInterval
    );
    event SetSwapOneKey(
        address indexed operator,
        address[] path,
        bool marketingStatus,
        uint256 amount,
        uint256 swapToFundInterval
    );
    event WithdrawToken(
        address indexed operator,
        address token,
        address to,
        uint256 amount
    );
    event SetMarketingStatus(address indexed operator, bool enable);
    event UpdateToken(address indexed oldToken, address indexed newToken);

    /**
     *  Note: After this contract is deployed,
     *  The operator privileges will be transferred to the multi-signature wallet address
     */
    constructor(
        address _operator,
        address _dodToken,
        address _governor,
        address _marketingReceiver
    ) {
        require(_dodToken != address(0), "error dod token");
        require(isContract(_dodToken), "DOD token: non contract address");
        require(_operator != address(0), "error operator");
        require(_marketingReceiver != address(0), "Zero address");
        require(_governor != address(0), "Zero governor");
        require(isContract(_governor), "governor: non contract address");
        operator = _operator;
        marketingReceiver = _marketingReceiver;
        governor = _governor;
        dodToken = _dodToken; // DODtoken
        swapPath[0] = dodToken;
        access[dodToken] = true;
        SafeTransferLib.safeApprove(dodToken, ROUTER, type(uint256).max);
    }

    /**
     * @dev Throws if the sender is not the operator.
     */
    modifier onlyOperator() {
        require(msg.sender == operator, "Treasury: caller is not the operator");
        _;
    }

    /**
     * @dev Throws if the sender is not the governor.
     */
    modifier onlyGovernor() {
        require(msg.sender == governor, "Governor: caller is not the governor");
        _;
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Current pool information.
     */
    function getPoolInfo()
        external
        view
        returns (
            address _governor,
            uint256 _lastSwapTime,
            uint256 _swapToMarketingAmount,
            bool _marketingStatus,
            uint256 _swapToMarketingInterval,
            address[] memory _swapPath
        )
    {
        return (
            governor,
            lastSwapTime,
            swapToMarketingAmount,
            marketingStatus,
            swapToMarketingInterval,
            swapPath
        );
    }

    /**
     * 4% sales tax
     */
    function swapForMarketingPool() external {
        if (
            swapPath[0] != address(0) &&
            access[msg.sender] &&
            marketingStatus &&
            swapToMarketingAmount != 0 &&
            block.timestamp >= lastSwapTime + swapToMarketingInterval
        ) {

            uint256 dodBalance = IERC20(dodToken).balanceOf(address(this));
            if (dodBalance >= swapToMarketingAmount) {

                uint256[] memory amountsOut = IPancakeSwapRouter(ROUTER)
                    .getAmountsOut(swapToMarketingAmount, swapPath);  // [dodAmount, bnbAmount]

                if (swapPath[swapPath.length - 1] == BNB) {
                    IPancakeSwapRouter(ROUTER)
                        .swapExactTokensForETHSupportingFeeOnTransferTokens(
                            swapToMarketingAmount,
                            amountsOut[amountsOut.length - 1] / 2, // Slippage 50%
                            swapPath,
                            marketingReceiver,
                            block.timestamp + 60
                        );
                } else {
                    IPancakeSwapRouter(ROUTER)
                        .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                            swapToMarketingAmount,
                            amountsOut[amountsOut.length - 1] / 2, // Slippage 50%
                            swapPath,
                            marketingReceiver,
                            block.timestamp + 60
                        );
                }
                lastSwapTime = block.timestamp;
            }
        }
    }

    function setFundStatus(bool _enable) external onlyOperator {
        require(marketingStatus != _enable, "same value");
        marketingStatus = _enable;
        emit SetMarketingStatus(msg.sender, _enable);
    }

    function setAccess(address account, bool _access) external onlyOperator {
        require(account != address(0), "error account");
        require(access[account] != _access, "same value");
        access[account] = _access;
        emit SetAccess(account, _access);
    }

    function setForMarketingPath(address[] calldata _path)
        external
        onlyOperator
    {
        require(_path.length >= 2, "MarketingPool: error path");
        for (uint8 i = 0; i < _path.length; i++) {
            require(
                _path[i] != address(0) && isContract(_path[i]),
                "MarketingPool: error token address"
            );
        }
        swapPath = _path;
        emit SetForMarketingPath(msg.sender, _path);
    }

    function setSwapToMarketingAmount(uint256 _swapAmount)
        external
        onlyOperator
    {
        require(swapToMarketingAmount != _swapAmount, "same value");
        swapToMarketingAmount = _swapAmount;
        emit SetSwapToMarketingAmount(msg.sender, _swapAmount);
    }

    function setSwapToMarketingInterval(uint256 _swapToMarketingInterval)
        external
        onlyOperator
    {
        require(swapToMarketingInterval != _swapToMarketingInterval, "same value");
        swapToMarketingInterval = _swapToMarketingInterval;
        emit SetSwapToMarketingInterval(msg.sender, _swapToMarketingInterval);
    }

    function setSwapOneKey(
        address[] calldata _path,
        bool _marketingStatus,
        uint256 _swapAmount,
        uint256 _swapToMarketingInterval
    ) external onlyOperator {
        require(_path.length >= 2, "MarketingPool: error path");
        for (uint8 i = 0; i < _path.length; i++) {
            require(
                _path[i] != address(0) && isContract(_path[i]),
                "MarketingPool: error token address"
            );
        }
        swapPath = _path;
        marketingStatus = _marketingStatus;
        swapToMarketingAmount = _swapAmount;
        swapToMarketingInterval = _swapToMarketingInterval;
        emit SetSwapOneKey(
            msg.sender,
            _path,
            _marketingStatus,
            _swapAmount,
            _swapToMarketingInterval
        );
    }

    /**
     * @dev Update marketing receiver
     */
    function setMarketingReceiver(address _marketingReceiver) external onlyOperator {
        require(_marketingReceiver != address(0), "error receiver");
        require(marketingReceiver != _marketingReceiver, "same receiver");
        emit SetMarketingReceiver(_marketingReceiver, marketingReceiver);
        marketingReceiver = _marketingReceiver;
    }

    /**
     * @dev Set up the governance contract
     */
    function setGovernor(address _newGovernor) external onlyGovernor {
        require(_newGovernor != address(0), "error governor");
        require(governor != _newGovernor, "same governor");
        emit SetGovernor(_newGovernor, governor);
        governor = _newGovernor;
    }

    function withdrawToken(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyGovernor {
        if (_token == address(0)) {
            SafeTransferLib.safeTransferETH(_to, _amount);
        } else {
            SafeTransferLib.safeTransfer(_token, _to, _amount);
        }
        emit WithdrawToken(msg.sender, _token, _to, _amount);
    }

    /**
     * @dev If the DOD token is attacked or needs to be migrated, update the token address
     */
    function updateToken(address _dodToken) external onlyGovernor {
        require(dodToken != _dodToken, "same address");
        require(isContract(_dodToken), "error token address");
        require(IERC20(_dodToken).totalSupply() != 0, "error token protocol");
        emit UpdateToken(dodToken, _dodToken);
        dodToken = _dodToken;
        swapPath[0] = dodToken;
        SafeTransferLib.safeApprove(dodToken, ROUTER, type(uint256).max);
    }

}