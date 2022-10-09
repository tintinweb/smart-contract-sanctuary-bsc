/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = 0;
        if (b > 0 && a > 0) {
            c = a / b;
        }
        return c;
    }
}

interface IPancakePair {
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
 * @title BRC20 interface
 */
interface IBRC20 {
    function symbol() external pure returns (string memory);

    function transfer(address to, uint256 value) external;

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract lifeBottomPool is Ownable {
    using SafeMath for uint256;
    address public robot; 

    constructor() {
        robot = owner();
    }

    modifier isRobot() {
        require(robot == msg.sender, "Is not robot");
        _;
    }

    function setRobot(address adr) public isRobot returns (bool) {
        robot = adr;
        return true;
    }

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "PancakeRouter: EXPIRED");
        _;
    }

    function _swapOfPair(
        address pair,
        uint256 amountOut,
        bool isToken0
    ) internal {
        (uint256 amount0Out, uint256 amount1Out) = isToken0
            ? (uint256(0), amountOut)
            : (amountOut, uint256(0));
        IPancakePair(pair).swap(
            amount0Out,
            amount1Out,
            address(this),
            new bytes(0)
        );
    }

    function _swap(
        address pair,
        address tokenIn,
        uint256 amountIn
    )
        internal
        view
        returns (
            address tokenOut,
            uint256 amountOut,
            bool isToken0
        )
    {
        address token0 = IPancakePair(pair).token0();
        address token1 = IPancakePair(pair).token1();
        isToken0 = token0 == tokenIn;
        require(isToken0 || token1 == tokenIn, "PancakeLiquidity: TOKEN ERROR");

        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(pair)
            .getReserves();
        (uint256 reserveA, uint256 reserveB) = isToken0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        uint256 amountInWithFee = amountIn.mul(9975);
        uint256 numerator = amountInWithFee.mul(reserveB);
        uint256 denominator = reserveA.mul(10000).add(amountInWithFee);
        tokenOut = isToken0 ? token1 : token0;
        amountOut = numerator / denominator;
    }

    function _addLiquidity(
        address pair,
        address tokenIn,
        uint256 amountIn
    )
        internal
        view
        returns (
            address tokenOut,
            uint256 amountOut,
            bool isToken0
        )
    {
        address token0 = IPancakePair(pair).token0();
        address token1 = IPancakePair(pair).token1();
        isToken0 = token0 == tokenIn;
        require(isToken0 || token1 == tokenIn, "PancakeLiquidity: TOKEN ERROR");

        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(pair)
            .getReserves();
        (uint256 reserveA, uint256 reserveB) = isToken0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        tokenOut = isToken0 ? token1 : token0;
        amountOut = amountIn.mul(reserveB) / reserveA;
    }

    function addLiquidityAndMintOfToken(
        address pair,
        address token,
        uint256 amount,
        address to,
        uint256 deadline
    ) external virtual ensure(deadline) returns (uint256 liquidity) {
        require(pair != address(0), "PancakeLiquidity: PAIR ERROR");
        uint256 amountIn = amount / 2;
        require(amountIn > 0, "PancakeLiquidity: AMOUNT ERROR");

        (address tokenOut, uint256 amountOut, bool isToken0) = _swap(
            pair,
            token,
            amountIn
        );
        IBRC20(token).transferFrom(msg.sender, pair, amountIn);
        _swapOfPair(pair, amountOut, isToken0);

        IBRC20(tokenOut).transfer(pair, amountOut);
        IBRC20(token).transferFrom(msg.sender, pair, amountIn);
        liquidity = IPancakePair(pair).mint(to);
    }

    function addLiquidityAndMintOfTokens(
        address pair,
        address tokenA,
        uint256 amountA,
        uint256 amountBMax,
        address to,
        uint256 deadline,
        bool isFeeToTokenA
    ) external virtual ensure(deadline) returns (uint256 liquidity) {
        require(pair != address(0), "PancakeLiquidity: PAIR ERROR");
        require(amountA > 0, "PancakeLiquidity: AMOUNTA ERROR");

        (address tokenOut, uint256 amountOut, ) = _addLiquidity(
            pair,
            tokenA,
            amountA
        );

        require(amountOut <= amountBMax, "PancakeLiquidity: AMOUNTB ERROR");

        if (isFeeToTokenA) {
            IBRC20(tokenA).transferFrom(msg.sender, address(this), amountA);
            IBRC20(tokenA).transfer(pair, amountA);
            IBRC20(tokenOut).transferFrom(msg.sender, pair, amountOut);
        } else {
            IBRC20(tokenA).transferFrom(msg.sender, pair, amountA);
            IBRC20(tokenOut).transferFrom(msg.sender, address(this), amountOut);
            IBRC20(tokenOut).transfer(pair, amountOut);
        }
        liquidity = IPancakePair(pair).mint(to);
    }

    function addLiquidityAndSync(
        address pair,
        address token,
        uint256 amount
    ) external virtual {
        require(pair != address(0), "PancakeLiquidity: PAIR ERROR");
        require(amount > 0, "PancakeLiquidity: AMOUNT ERROR");

        address token0 = IPancakePair(pair).token0();
        address token1 = IPancakePair(pair).token1();
        require(
            token0 == token || token1 == token,
            "PancakeLiquidity: TOKEN ERROR"
        );

        IBRC20(token).transferFrom(msg.sender, pair, amount);
        IPancakePair(pair).sync();
    }

    function removeLiquidity(
        address pair,
        uint256 liquidity,
        address to,
        uint256 deadline
    )
        public
        virtual
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB)
    {
        require(liquidity > 0, "PancakeLiquidity: LIQUIDITY ERROR");
        IPancakePair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (amountA, amountB) = IPancakePair(pair).burn(address(this));

        address tokenA = IPancakePair(pair).token0();
        address tokenB = IPancakePair(pair).token1();
        IBRC20(tokenA).transfer(to, amountA);
        IBRC20(tokenB).transfer(to, amountB);
    }

    function withdraw(
        address token,
        address to,
        uint256 amount
    ) public onlyOwner {
        require(amount > 0, "PancakeLiquidity: AMOUNT ERROR");
        uint256 balance = IBRC20(token).balanceOf(address(this));
        require(balance >= amount, "insufficient funds");
        IBRC20(token).transfer(to, amount);
    }

    function swapBalance(
        address pair,
        address token,
        uint256 amount
    )
        external
        virtual
        isRobot
        returns (
            address tokenOut,
            uint256 amountOut,
            bool isToken0
        )
    {
        require(pair != address(0), "PancakeLiquidity: PAIR ERROR");
        require(amount > 0, "PancakeLiquidity: AMOUNT ERROR");
        (tokenOut, amountOut, isToken0) = _swap(pair, token, amount);
        IBRC20(token).transfer(pair, amount);
        _swapOfPair(pair, amountOut, isToken0);
    }

    function addLiquidityAndMintOfBalance(
        address pair,
        address token,
        uint256 amount
    ) external virtual isRobot returns (uint256 liquidity) {
        require(pair != address(0), "PancakeLiquidity: PAIR ERROR");
        uint256 amountIn = amount / 2;
        require(amountIn > 0, "PancakeLiquidity: AMOUNT ERROR");

        (address tokenOut, uint256 amountOut, bool isToken0) = _swap(
            pair,
            token,
            amountIn
        );
        IBRC20(token).transfer(pair, amountIn);
        _swapOfPair(pair, amountOut, isToken0);

        IBRC20(tokenOut).transfer(pair, amountOut);
        IBRC20(token).transfer(pair, amountIn);
        liquidity = IPancakePair(pair).mint(address(this));
    }

    function addLiquidityAndMintOfBalances(
        address pair,
        address token,
        uint256 amount
    ) external virtual isRobot returns (uint256 liquidity) {
        require(pair != address(0), "PancakeLiquidity: PAIR ERROR");
        require(amount > 0, "PancakeLiquidity: AMOUNT ERROR");

        (address tokenOut, uint256 amountOut, ) = _addLiquidity(
            pair,
            token,
            amount
        );

        IBRC20(tokenOut).transfer(pair, amountOut);
        IBRC20(token).transfer(pair, amount);
        liquidity = IPancakePair(pair).mint(address(this));
    }

    function burnPairLP(address pair) external isRobot {
        uint256 balance = IPancakePair(pair).balanceOf(address(this));
        require(balance > 0, "PancakeLiquidity: NOT BANLANCE");

        IPancakePair(pair).transfer(address(0), balance);
    }

    function getPrice(address pair) public view returns (uint256) {
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(pair)
            .getReserves();
        return (reserve1 * 10**18) / reserve0;
    }

    function getLPAmount(address pair) public view returns (uint256) {
        return IPancakePair(pair).balanceOf(address(this));
    }
}