// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IUniswapV2Callee {
    function pancakeCall(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

contract UniswapV2FlashSwap is IUniswapV2Callee {
    address private constant UNISWAP_V2_FACTORY =
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    IUniswapV2Factory private constant factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);

    IERC20 private constant wbnb = IERC20(WBNB);

    IUniswapV2Pair private immutable pair;

    // For this example, store the amount to repay
    uint public amountToRepay;

    constructor() {
        pair = IUniswapV2Pair(factory.getPair(BUSD, WBNB));
    }

    function flashSwap(uint wbnbAmount) external {
        // Need to pass some data to trigger pancakeCall
        bytes memory data = abi.encode(WBNB, msg.sender);

        // amount0Out is BUSD, amount1Out is WBNB
        pair.swap(wbnbAmount, 0, address(this), data);
    }

    // This function is called by the BUSD/WBNB pair contract
    function pancakeCall(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) override external {
        require(msg.sender == address(pair), "not pair");
        require(sender == address(this), "not sender");

        (address tokenBorrow, address caller) = abi.decode(data, (address, address));

        // Your custom code would go here. For example, code to arbitrage.
        require(tokenBorrow == WBNB, "token borrow != WBNB");

        // about 0.3% fee, +1 to round up
        uint fee = (amount0 * 3) / 997 + 1;
        amountToRepay = amount0 + fee;

        // Transfer flash swap fee from caller
        wbnb.transferFrom(caller, address(this), fee);

        // Repay
        wbnb.transfer(address(pair), amountToRepay);
    }
}

contract FlashLoan {
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IWBNB private wbnb = IWBNB(WBNB);

    UniswapV2FlashSwap public uni = new UniswapV2FlashSwap();

    function flashLoan(uint amountToBorrow) public payable {
        uint fee = msg.value;
        wbnb.deposit{value: fee}();
        // Approve flash swap fee
        wbnb.approve(address(uni), fee);

        uni.flashSwap(amountToBorrow);

        wbnb.withdraw(wbnb.balanceOf(address(this)));
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}

interface IUniswapV2Pair {
    function swap(
        uint amount0Out,
        uint amount1Out,
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
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IWBNB is IERC20 {
    function deposit() external payable;

    function withdraw(uint amount) external;
}