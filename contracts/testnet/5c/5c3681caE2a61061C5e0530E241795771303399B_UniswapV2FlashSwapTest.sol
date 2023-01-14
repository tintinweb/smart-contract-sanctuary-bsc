/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

interface IUniswapV2Pair {
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

contract UniswapV2FlashSwap  {
    address private constant UNISWAP_V2_FACTORY =
        0x6725F303b657a9451d8BA641348b6761A6CC7a17;

    address private constant BUSD = 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;
    address private constant WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    IUniswapV2Factory private constant factory =
        IUniswapV2Factory(UNISWAP_V2_FACTORY);

    IERC20 private constant weth = IERC20(WETH);

    IUniswapV2Pair private immutable pair;

    address public busds;

    // For this example, store the amount to repay
    uint256 public amountToRepay;

    constructor() {
        pair = IUniswapV2Pair(factory.getPair(BUSD, WETH));
    }

    function flashSwap(uint256 wethAmount) external {
        // Need to pass some data to trigger uniswapV2Call
        bytes memory data = abi.encode(WETH, msg.sender, BUSD);

        // amount0Out is DAI, amount1Out is WETH
        pair.swap(0, wethAmount, address(this), data);
    }

    // This function is called by the DAI/WETH pair contract
    function pancakeCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        require(msg.sender == address(pair), "not pair");
        require(sender == address(this), "not sender");

        (address tokenBorrow, address caller, address _BUSDs) = abi.decode(
            data,
            (address, address, address)
        );

        busds = _BUSDs;

        // (address[] memory adrs) = abi.decode(data, (address[]));

        // Your custom code would go here. For example, code to arbitrage.
        require(tokenBorrow == WETH, "token borrow != WETH");

        // about 0.3% fee, +1 to round up
        uint256 fee = (amount1 * 3) / 997 + 1;
        amountToRepay = amount1 + fee;

        // Transfer flash swap fee from caller
        weth.transferFrom(caller, address(this), fee);

        // Repay
        weth.transfer(address(pair), amountToRepay);
    }
}

address constant WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
address constant BUSD = 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;

contract UniswapV2FlashSwapTest {
    IWETH private weth = IWETH(WETH);

    UniswapV2FlashSwap private uni = new UniswapV2FlashSwap();

    function setUp() public {}

    function testFlashSwap(uint256 borrowAmount) public {
        uint256 depositAmount = (borrowAmount * 3) / 997 + 1; 
        weth.deposit{value: depositAmount}();
        // Approve flash swap fee
        weth.approve(address(uni), depositAmount);

        uni.flashSwap(borrowAmount);
    }

    function getResult() public view returns (uint256) {
        return (uni.amountToRepay());
    }

    receive() external payable {}
}