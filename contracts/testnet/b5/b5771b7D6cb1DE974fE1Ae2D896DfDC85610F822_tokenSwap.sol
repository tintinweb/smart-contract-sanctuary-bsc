/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

pragma solidity ^0.8.7;

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

interface IUniswapV2Router {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);
}

interface IUniswapV2Pair {
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

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface IUniswapV2Factory {
    function getPair(address token0, address token1) external returns (address);
}

contract tokenSwap {
    address private constant PANCAKE_TEST_ROUTER =
        0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address private constant WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address private constant PANCAKE_TEST_FACTORY =
        0x6725F303b657a9451d8BA641348b6761A6CC7a17;

    address private _owner;
    IUniswapV2Pair private pair;
    mapping(address => mapping(address => uint256)) private wallet;
    uint8 private index;
    uint256 private amountOut;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function deposit(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) external {
        // trasfer token from wallet to contract
        wallet[msg.sender][_tokenIn] += _amountIn;
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

        // build pair
        address pairAddr = IUniswapV2Factory(PANCAKE_TEST_FACTORY).getPair(
            _tokenIn,
            _tokenOut
        );
        pair = IUniswapV2Pair(pairAddr);

        (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves();
        require(_reserve0 > 0 && _reserve1 > 0, "eq 0");

        // trasfer token from contract to pair
        IERC20(_tokenIn).approve(pairAddr, _amountIn);
        IERC20(_tokenIn).transfer(pairAddr, _amountIn);

        address t0 = pair.token0();
        index = 0;
        if (t0 != _tokenIn) {
            index = 1;
        }

        amountOut = IUniswapV2Router(PANCAKE_TEST_ROUTER).getAmountOut(
            _amountIn,
            _reserve0,
            _reserve1
        );
    }

    function swap() external {
        // swap
        bytes memory zeroData;
        if (index == 0) {
            pair.swap(0, amountOut, msg.sender, zeroData);
        } else {
            pair.swap(amountOut, 0, msg.sender, zeroData);
        }
    }

    function withdraw(address _tokenIn) external {
        require(
            wallet[msg.sender][_tokenIn] > 0,
            "withdraw : not enough token"
        );

        uint256 amount;
        amount = wallet[msg.sender][_tokenIn];
        wallet[msg.sender][_tokenIn] = 0;
        IERC20(_tokenIn).approve(msg.sender, amount);
        IERC20(_tokenIn).transfer(msg.sender, amount);
    }
}