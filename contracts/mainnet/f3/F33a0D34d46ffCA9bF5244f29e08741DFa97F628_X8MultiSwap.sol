/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

interface IUniswapV2Pair {
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
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

contract X8MultiSwap {
    address public feeTo;
    address private owner;
    uint256 public feeN;
    uint256 public feeD;

    modifier ownerOnly() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    event FeeSet();
    event Swap(
        address indexed recipient,
        address indexed tokenIn,
        uint256 amountIn,
        address indexed tokenOut,
        uint256 amountOut
    );
    event SubSwap(
        address indexed pair,
        address indexed tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amount0Out,
        uint256 amount1Out
    );
    event FeeTaken(address token, uint256 feeAmount);

    constructor(
        address fee_to,
        uint256 fee_n,
        uint256 fee_d
    ) {
        owner = msg.sender;
        setFee(fee_n, fee_d); // fail ASAP
        feeTo = fee_to;
    }

    function setFee(uint256 fee_n, uint256 fee_d) public ownerOnly {
        require(fee_n < fee_d && fee_n > 0 && fee_d > 0, "invalid fee");
        feeN = fee_n;
        feeD = fee_d;
        emit FeeSet();
    }

    function setFeeTo(address fee_to) public ownerOnly {
        require(fee_to != address(0), "invalid owner address");
        require(fee_to != feeTo, "same as prev feeTo");
        feeTo = fee_to;
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata pairs,
        uint256[] calldata fns,
        uint256[] calldata fds
    ) public {
        require(amountIn > 0, "invalid input");
        require(amountOutMin > 0, "invalid input");
        require(tokenIn != address(0), "invalid input");
        require(
            pairs.length > 0 &&
                pairs.length == fns.length &&
                fns.length == fds.length,
            "invalid input"
        );

        require(
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn),
            "failed to transfer tokens from sender"
        );

        uint256 amountToSwap = 0;
        {
            uint256 _feeD = feeD; // gas savings
            amountToSwap = (amountIn * (_feeD - feeN)) / _feeD;
        }
        address tokenToSwap = tokenIn;
        uint256 balanceBefore = IERC20(tokenOut).balanceOf(msg.sender);

        // transfer service fee
        {
            uint256 serviceFee = amountIn - amountToSwap;
            address _feeTo = feeTo; // gas savings
            if (_feeTo != address(this)) {
                require(
                    IERC20(tokenIn).transfer(_feeTo, serviceFee),
                    "failed to transfer fee"
                );
                emit FeeTaken(tokenIn, serviceFee);
            }
        }

        // transfer amountIn after fee to first pair
        require(
            IERC20(tokenIn).transfer(pairs[0], amountToSwap),
            "failed to init swap"
        );

        for (uint256 i = 0; i < pairs.length; i++) {
            IUniswapV2Pair pair = IUniswapV2Pair(pairs[i]); // gas savings
            address swapTo = i < pairs.length - 1 ? pairs[i + 1] : msg.sender; // swap to next pool or sender if final swap
            uint256 _pairFeeN = fns[i];
            uint256 _pairFeeD = fds[i];

            (
                address nextTokenToSwap,
                uint256 amount0Out,
                uint256 amount1Out
            ) = calcSwap(tokenToSwap, amountToSwap, pair, _pairFeeN, _pairFeeD);

            pair.swap(amount0Out, amount1Out, swapTo, new bytes(0));
            emit SubSwap(
                address(pair),
                tokenToSwap,
                nextTokenToSwap,
                amountToSwap,
                amount0Out,
                amount1Out
            );
            amountToSwap = amount0Out != 0 ? amount0Out : amount1Out; // next amount to swap
            tokenToSwap = nextTokenToSwap;
        }

        {
            uint256 amountOutActual = IERC20(tokenOut).balanceOf(msg.sender) -
                balanceBefore;
            require(amountOutActual >= amountOutMin, "min amount out failed");
            emit Swap(msg.sender, tokenIn, amountIn, tokenOut, amountOutActual);
        }
    }
}

function getPairReserves(IUniswapV2Pair pair, address tokenIn)
    view
    returns (
        address,
        uint256,
        uint256,
        bool
    )
{
    address t0 = pair.token0();
    address t1 = pair.token1();
    require(t0 == tokenIn || t1 == tokenIn, "invalid path");

    (uint112 r0, uint112 r1, ) = pair.getReserves();
    if (t0 == tokenIn) {
        return (t1, r1, r0, true);
    } else {
        return (t0, r0, r1, false);
    }
}

function calcSwap(
    address tokenIn,
    uint256 amountIn,
    IUniswapV2Pair pair,
    uint256 _feeN,
    uint256 _feeD
)
    view
    returns (
        address tokenOut,
        uint256 amount0Out,
        uint256 amount1Out
    )
{
    (
        address tOut,
        uint256 reserveOut,
        uint256 reserveIn,
        bool flipped
    ) = getPairReserves(pair, tokenIn);

    tokenOut = tOut;
    uint256 amountInWithFee = amountIn * (_feeD - _feeN);
    uint256 numerator = amountInWithFee * reserveOut;
    uint256 denominator = reserveIn * _feeD + amountInWithFee;

    if (flipped) {
        amount0Out = 0;
        amount1Out = numerator / denominator;
    } else {
        amount0Out = numerator / denominator;
        amount1Out = 0;
    }
}