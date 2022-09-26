// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "./SafeMath.sol";
import "./IPancakePair.sol";

/**
 * @title BRC20 interface
 */
interface IBRC20 {
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

contract PancakeLiquidity is Ownable {
    using SafeMath for uint256;
    address public robot;

    constructor() {
        robot = owner();
    }

    function setRobot(address adr) public onlyOwner returns (bool) {
        robot = adr;
        return true;
    }

    modifier isRobot() {
        require(robot == msg.sender, "Is not robot");
        _;
    }

    function _swapAndTransfer(
        address pair,
        address token,
        uint256 amountIn
    ) internal {
        address token0 = IPancakePair(pair).token0();
        address token1 = IPancakePair(pair).token1();
        require(
            token0 == token || token1 == token,
            "PancakeLiquidity: TOKEN ERROR"
        );

        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(pair)
            .getReserves();
        (uint256 reserveA, uint256 reserveB) = token0 == token
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        uint256 amountInWithFee = amountIn.mul(9975);
        uint256 numerator = amountInWithFee.mul(reserveB);
        uint256 denominator = reserveA.mul(10000).add(amountInWithFee);
        uint256 amountOut = numerator / denominator;

        IBRC20(token).transferFrom(msg.sender, pair, amountIn);
        {
            (uint256 amount0Out, uint256 amount1Out) = token0 == token
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            IPancakePair(pair).swap(
                amount0Out,
                amount1Out,
                address(this),
                new bytes(0)
            );
        }

        address tokenOut = token0 == token ? token1 : token0;
        IBRC20(tokenOut).transfer(pair, amountOut);
    }

    function addLiquidityAndMint(
        address pair,
        address token,
        uint256 amount
    ) external virtual returns (uint256 liquidity) {
        require(pair != address(0), "PancakeLiquidity: PAIR ERROR");
        uint256 amountIn = amount / 2;
        require(amountIn > 0, "PancakeLiquidity: AMOUNT ERROR");

        _swapAndTransfer(pair, token, amountIn);
        IBRC20(token).transferFrom(msg.sender, pair, amountIn);
        liquidity = IPancakePair(pair).mint(address(this));
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