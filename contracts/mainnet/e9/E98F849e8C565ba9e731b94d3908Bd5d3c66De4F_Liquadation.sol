/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// File: contracts/interfaces/bscswap/IBSCswapFactory.sol


pragma solidity 0.8.7;

interface IBSCswapFactory {
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

// File: contracts/interfaces/bscswap/IBSCswapRouter01.sol


pragma solidity 0.8.7;


interface IBSCswapRouter01 {
    function factory() external pure returns (address);
    function WBNB() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityBNB(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountBNB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountBNB, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityBNB(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountBNB);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityBNBWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountBNB);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactBNB(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapBNBForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: contracts/interfaces/bscswap/IBSCswapRouter02.sol


pragma solidity 0.8.7;


interface IBSCswapRouter02 is IBSCswapRouter01 {
    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountBNB);
    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountBNB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    
}

// File: contracts/interfaces/bscswap/IBSCswapPair.sol


pragma solidity 0.8.7;

interface IBSCswapPair {
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

// File: contracts/interfaces/ILiquadation.sol


pragma solidity 0.8.7;

interface ILiquadation {
    struct PushParameter {
        uint256 dsRatio;
        uint256 cashOutRatio;
        uint256 liquadityRatio;
        uint256 totalCashOut;
        bool liquidityType;
        address dumperSheild;
        address priceFeed;
        address routerAddress;
        address pairedToken;
        address offeringToken;
        address reciver;
    }

    function pushFund(PushParameter memory data)
        external
        payable
        returns (
            uint256 dsEthReturn,
            uint256 lpEthReturn,
            uint256 lpAmount,
            uint256 lpcashOutUsdAmount,
            bool paused
        );
}
// File: contracts/interfaces/IDumperSheild.sol


pragma solidity 0.8.7;

interface IDumperSheild {
    function deposit(
        address token,
        uint256 amount,
        address user
    ) external returns (bool);

    function buyToken(
        address buyToken,
        uint256 buyAmount,
        address sendToken,
        uint256 sendAmount
    ) external payable returns (uint256 tokenAmount);

    function getAvailableTokens(address token)
        external
        returns (uint256 amount);

    function getOutputTokens(
        address sendToken,
        uint256 sendAmount,
        address token
    ) external returns (uint256 amount);


    function createDumperShield(
        address token,  // token contract address
        address router, // Uniswap compatible AMM router address where exist Token <> WETH pair
        uint256 unlockDate, // Epoch time (in second) when tokens will be unlocked
        address dao         // Address of token's voting contract if exist. Otherwise = address(0).
    ) external ;

    function dumperShieldTokens(address token) external returns (address dsToken);
}

// File: contracts/interfaces/IPriceFeed.sol


pragma solidity 0.8.7;

interface IPriceFeed {
    function setPriceFeed(address tokenAddress, address priceFeed)
        external
        returns (bool);

    function getTokenPrice(address tokenAddress)
        external
        view
        returns (uint256 tokenPrice);

    function getUsdAmountPool(
        address router,
        address token0,
        address token1
    )
        external
        view
        returns (
            uint256 totalAmount,
            uint256 token0Usd,
            uint256 token1Usd
        );

    function getPoolDetailsWithUsdAmount(
        address router,
        address token0,
        address token1
    )
        external
        view
        returns (
            address poolAddress,
            uint256 totalAmount,
            uint256 token0Usd,
            uint256 token1Usd
        );
}

// File: contracts/interfaces/IBEP20.sol


pragma solidity 0.8.7;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts/Utils/Math/SafeMath.sol


pragma solidity >=0.4.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// File: contracts/lib/TransferHelper.sol


pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

// File: contracts/Liquadation.sol


pragma solidity 0.8.7;











contract Liquadation is ILiquadation {
    using SafeMath for uint256;

    address owner;

    mapping(address => uint256) public uniVersion;
    address public weth;

    uint256 internal constant WEI_UNIT = 1e18;

    uint256 internal constant PRICE_UNIT = 1e9;

    receive() external payable {}

    fallback() external payable {}

    constructor(address _weth) {
        weth = _weth;
        owner = msg.sender;
    }

    function setUniVersion(address router, uint256 version) external {
        require(msg.sender == owner, "auth_err");
        uniVersion[router] = version;
    }

    function pushFund(ILiquadation.PushParameter memory data)
        external
        payable
        override
        returns (
            uint256 dsEthReturn,
            uint256 lpEthReturn,
            uint256 lpAmount,
            uint256 lpcashOutUsdAmount,
            bool paused
        )
    {
        uint256 dsReturnToken;
        uint256 lpReturnToken;

        if (data.dsRatio > 0)
            (dsReturnToken, dsEthReturn) = _pushToDumperSheild(
                data.dumperSheild,
                data.dsRatio,
                data.offeringToken
            );

        if (data.cashOutRatio > 0) {
            (uint256 _amountInPool, , ) = IPriceFeed(data.priceFeed)
                .getUsdAmountPool(
                    data.routerAddress,
                    data.pairedToken,
                    data.offeringToken
                );

            uint256 cashTemp = data
                .cashOutRatio
                .mul(IPriceFeed(data.priceFeed).getTokenPrice(weth))
                .div(WEI_UNIT);

            if (data.totalCashOut.add(cashTemp) > _amountInPool.mul(2)) {
                if (data.liquidityType) {
                    data.liquadityRatio = data.cashOutRatio.add(
                        data.liquadityRatio
                    );
                    data.cashOutRatio = 0;
                    paused = true;
                } else {
                    uint256 tempRatio = data.cashOutRatio.div(3);
                    data.liquadityRatio = data.cashOutRatio.sub(tempRatio).add(
                        data.liquadityRatio
                    );
                    data.cashOutRatio = tempRatio;
                }
            }

            if (data.cashOutRatio > 0) {
                TransferHelper.safeTransferETH(data.reciver, data.cashOutRatio);
                lpcashOutUsdAmount = data
                    .cashOutRatio
                    .mul(IPriceFeed(data.priceFeed).getTokenPrice(weth))
                    .div(WEI_UNIT);
            }
        }

        if (data.liquadityRatio > 0)
            (lpAmount, lpReturnToken, lpEthReturn) = _liquididatePool(
                data.liquadityRatio,
                data.routerAddress,
                data.pairedToken,
                data.offeringToken
            );

        if (dsReturnToken.add(lpReturnToken) > 0)
            TransferHelper.safeTransfer(
                data.offeringToken,
                msg.sender,
                dsReturnToken.add(lpReturnToken)
            );

        if (dsEthReturn.add(lpEthReturn) > 0)
            TransferHelper.safeTransferETH(
                msg.sender,
                dsEthReturn.add(lpEthReturn)
            );
    }

    function _pushToDumperSheild(
        address dumperSheild,
        uint256 ethAmount,
        address offeringToken
    ) internal returns (uint256 returnToken, uint256 returnEth) {
        uint256 outToken = IDumperSheild(dumperSheild).getOutputTokens(
            address(0),
            ethAmount,
            offeringToken
        );

        uint256 perTokenPrice = ethAmount
            .mul(10**IBEP20(offeringToken).decimals())
            .div(outToken);

        uint256 availableTokens = IDumperSheild(dumperSheild)
            .getAvailableTokens(offeringToken);

        uint256 avdTokenPrice = availableTokens.mul(perTokenPrice).div(
            10**IBEP20(offeringToken).decimals()
        );

        if (availableTokens == 0 || avdTokenPrice <= PRICE_UNIT) {
            returnEth = ethAmount;
            returnToken = 0;
        } else if (availableTokens >= outToken) {
            returnToken = IDumperSheild(dumperSheild).buyToken{
                value: ethAmount
            }(offeringToken, outToken, address(0), ethAmount);
            returnEth = 0;
        } else {
            uint256 tempAmount = availableTokens.mul(perTokenPrice).div(
                10**IBEP20(offeringToken).decimals()
            );
            returnEth = ethAmount.sub(tempAmount);
            outToken = IDumperSheild(dumperSheild).getOutputTokens(
                address(0),
                tempAmount,
                offeringToken
            );
            returnToken = IDumperSheild(dumperSheild).buyToken{
                value: tempAmount
            }(offeringToken, outToken, address(0), tempAmount);
        }
    }

    function getPoolAddress(
        address routerAddress,
        address tokenA,
        address tokenB
    ) internal view returns (address poolAddress) {
        address factoryAddresss = IBSCswapRouter02(routerAddress).factory();
        poolAddress = IBSCswapFactory(factoryAddresss).getPair(tokenA, tokenB);
    }

    function swapNativeToToken(
        address routerAddress,
        uint256 ethAmount,
        address[] memory path
    ) internal returns (uint256[] memory amounts) {
        uint256 version = uniVersion[routerAddress];
        if (version == 0) {
            amounts = IBSCswapRouter02(routerAddress).swapExactETHForTokens{
                value: ethAmount
            }(1, path, address(this), block.timestamp);
        } else if (version == 1) {
            amounts = IBSCswapRouter02(routerAddress).swapExactBNBForTokens{
                value: ethAmount
            }(1, path, address(this), block.timestamp);
        }
    }

    function swapTokenToNative(
        address routerAddress,
        uint256 tokenAmount,
        address[] memory path
    ) internal returns (uint256[] memory amounts) {
        uint256 version = uniVersion[routerAddress];
        if (version == 0) {
            amounts = IBSCswapRouter02(routerAddress).swapExactTokensForETH(
                tokenAmount,
                1,
                path,
                address(this),
                block.timestamp
            );
        } else if (version == 1) {
            amounts = IBSCswapRouter02(routerAddress).swapExactTokensForBNB(
                tokenAmount,
                1,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function addLiquidityWithNative(
        address routerAddress,
        uint256 ethAmount,
        address token,
        uint256 tokenAmount
    )
        internal
        returns (
            uint256 amountToken,
            uint256 amountBNB,
            uint256 lpAmount
        )
    {
        uint256 version = uniVersion[routerAddress];
        if (version == 0) {
            (amountToken, amountBNB, lpAmount) = IBSCswapRouter02(routerAddress)
                .addLiquidityETH{value: ethAmount}(
                token,
                tokenAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                msg.sender,
                block.timestamp
            );
        } else if (version == 1) {
            (amountToken, amountBNB, lpAmount) = IBSCswapRouter02(routerAddress)
                .addLiquidityBNB{value: ethAmount}(
                token,
                tokenAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                msg.sender,
                block.timestamp
            );
        }
    }

    function _liquididatePool(
        uint256 ethAmount,
        address routerAddress,
        address pairedToken,
        address offeringToken
    )
        internal
        returns (
            uint256 lpAmount,
            uint256 returnToken,
            uint256 returnEth
        )
    {
        if (pairedToken != weth) {
            address[] memory path = new address[](2);

            path[0] = weth;
            path[1] = pairedToken;

            uint256[] memory amounts = swapNativeToToken(
                routerAddress,
                ethAmount,
                path
            );

            uint256 half = amounts[amounts.length.sub(1)].div(2);
            uint256 otherHalf = amounts[amounts.length.sub(1)].sub(half);

            path[0] = pairedToken;
            path[1] = offeringToken;
            TransferHelper.safeApprove(
                pairedToken,
                routerAddress,
                amounts[amounts.length.sub(1)]
            );

            amounts = IBSCswapRouter02(routerAddress).swapExactTokensForTokens(
                otherHalf,
                1,
                path,
                address(this),
                block.timestamp
            );

            uint256 offeringTokenAmount = amounts[amounts.length.sub(1)];
            TransferHelper.safeApprove(
                offeringToken,
                routerAddress,
                offeringTokenAmount
            );
            uint256 amountA;
            uint256 amountB;
            (amountA, amountB, lpAmount) = IBSCswapRouter02(routerAddress)
                .addLiquidity(
                    pairedToken,
                    offeringToken,
                    half,
                    offeringTokenAmount,
                    0,
                    0,
                    msg.sender,
                    block.timestamp
                );

            uint256 aReturnToken = half.sub(amountA);
            if (aReturnToken > 0) {
                TransferHelper.safeApprove(
                    pairedToken,
                    routerAddress,
                    aReturnToken
                );
                path[0] = pairedToken;
                path[1] = weth;
                amounts = swapTokenToNative(routerAddress, aReturnToken, path);
                returnEth = amounts[amounts.length.sub(1)];
            }
            returnToken = offeringTokenAmount.sub(amountB);
            if (returnToken > 0)
                TransferHelper.safeTransfer(
                    offeringToken,
                    msg.sender,
                    returnToken
                );
        } else {
            uint256 half = ethAmount.div(2);
            uint256 otherHalf = ethAmount.sub(half);

            address[] memory path = new address[](2);
            path[0] = weth;
            path[1] = offeringToken;

            uint256[] memory amounts = swapNativeToToken(
                routerAddress,
                half,
                path
            );

            TransferHelper.safeApprove(
                offeringToken,
                routerAddress,
                amounts[amounts.length.sub(1)]
            );
            uint256 amountToken;
            uint256 amountBNB;

            (amountToken, amountBNB, lpAmount) = addLiquidityWithNative(
                routerAddress,
                otherHalf,
                offeringToken,
                amounts[amounts.length.sub(1)]
            );

            returnToken = amounts[amounts.length.sub(1)].sub(amountToken);
            returnEth = otherHalf.sub(amountBNB);
        }
    }
}