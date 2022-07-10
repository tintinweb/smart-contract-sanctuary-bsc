// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./Context.sol";
import "./Ownable.sol";

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

interface IWBNB {
    function withdraw(uint256) external;

    function deposit() external payable;
}

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
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

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)
library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

library PancakeLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5" // init code hash
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(
            pairFor(factory, tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "PancakeLibrary: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(9975);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(10000);
        uint256 denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "PancakeLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "PancakeLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

contract Trigger2 is Ownable {
    using SafeMath for uint256;

    address public immutable factory =
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public immutable WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // bsc variables
    address constant wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant cakeFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    // eth variables
    // address constant wbnb= 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // address constant cakeRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    // address constant cakeFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    address payable private administrator;
    uint256 private wbnbIn;
    uint256 private minTknOut;
    address private tokenToBuy;
    address private tokenPaired;
    bool private snipeLock;

    mapping(address => bool) public authenticatedSeller;

    constructor() {
        administrator = payable(msg.sender);
        authenticatedSeller[msg.sender] = true;
    }

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "PancakeRouter: EXPIRED");
        _;
    }

    receive() external payable {
        IWBNB(wbnb).deposit{value: msg.value}();
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _dwich(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = PancakeLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2
                ? PancakeLibrary.pairFor(factory, output, path[i + 2])
                : _to;
            IPancakePair(PancakeLibrary.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }

    function sandwichExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) internal virtual ensure(deadline) returns (uint256[] memory amounts) {
        amounts = PancakeLibrary.getAmountsOut(factory, amountIn, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            PancakeLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _dwich(amounts, path, to);
    }

    //================== main functions ======================

    // Trigger2 is the smart contract in charge or performing liquidity sniping and sandwich attacks.
    // For liquidity sniping, its role is to hold the BNB, perform the swap once dark_forester detect the tx in the mempool and if all checks are passed; then route the tokens sniped to the owner.
    // For liquidity sniping, it require a first call to configureSnipe in order to be armed. Then, it can snipe on whatever pair no matter the paired token (BUSD / WBNB etc..).
    // This contract uses a custtom router which is a copy of PCS router but with modified selectors, so that our tx are more difficult to listen than those directly going through PCS router.

    // perform the liquidity sniping
    function snipeListing() external returns (bool success) {
        require(
            IERC20(wbnb).balanceOf(address(this)) >= wbnbIn,
            "snipe: not enough wbnb on the contract"
        );
        // IERC20(wbnb).approve(sandwichRouter, wbnbIn);
        require(snipeLock == false, "snipe: sniping is locked. See configure");
        snipeLock = true;

        address[] memory path;
        if (tokenPaired != wbnb) {
            path = new address[](3);
            path[0] = wbnb;
            path[1] = tokenPaired;
            path[2] = tokenToBuy;
        } else {
            path = new address[](2);
            path[0] = wbnb;
            path[1] = tokenToBuy;
        }

        sandwichExactTokensForTokens(
            wbnbIn,
            minTknOut,
            path,
            administrator,
            block.timestamp + 120
        );
        return true;
    }

    // manage the "in" phase of the sandwich attack
    function sandwichIn(
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    ) external returns (bool success) {
        require(
            msg.sender == administrator || msg.sender == owner(),
            "in: must be called by admin or owner"
        );
        require(
            IERC20(wbnb).balanceOf(address(this)) >= amountIn,
            "in: not enough wbnb on the contract"
        );

        address[] memory path;
        path = new address[](2);
        path[0] = wbnb;
        path[1] = tokenOut;

        sandwichExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 120
        );
        return true;
    }

    // manage the "out" phase of the sandwich. Should be accessible to all authenticated sellers
    function sandwichOut(address tokenIn, uint256 amountOutMin)
        external
        returns (bool success)
    {
        require(
            authenticatedSeller[msg.sender] == true,
            "out: must be called by authenticated seller"
        );
        uint256 amountIn = IERC20(tokenIn).balanceOf(address(this));
        require(amountIn >= 0, "out: empty balance for this token");

        address[] memory path;
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = wbnb;

        sandwichExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 120
        );

        return true;
    }

    //================== owner functions=====================

    function authenticateSeller(address _seller) external onlyOwner {
        authenticatedSeller[_seller] = true;
    }

    function getAdministrator()
        external
        view
        onlyOwner
        returns (address payable)
    {
        return administrator;
    }

    function setAdministrator(address payable _newAdmin)
        external
        onlyOwner
        returns (bool success)
    {
        administrator = _newAdmin;
        authenticatedSeller[_newAdmin] = true;
        return true;
    }

    // must be called before sniping
    function configureSnipe(
        address _tokenPaired,
        uint256 _amountIn,
        address _tknToBuy,
        uint256 _amountOutMin
    ) external onlyOwner returns (bool success) {
        tokenPaired = _tokenPaired;
        wbnbIn = _amountIn;
        tokenToBuy = _tknToBuy;
        minTknOut = _amountOutMin;
        snipeLock = false;
        return true;
    }

    function getSnipeConfiguration()
        external
        view
        onlyOwner
        returns (
            address,
            uint256,
            address,
            uint256,
            bool
        )
    {
        return (tokenPaired, wbnbIn, tokenToBuy, minTknOut, snipeLock);
    }

    // here we precise amount param as certain bep20 tokens uses strange tax system preventing to send back whole balance
    function emmergencyWithdrawTkn(address _token, uint256 _amount)
        external
        onlyOwner
        returns (bool success)
    {
        require(
            IERC20(_token).balanceOf(address(this)) >= _amount,
            "not enough tokens in contract"
        );
        IERC20(_token).transfer(administrator, _amount);
        return true;
    }

    // souldn't be of any use as receive function automaticaly wrap bnb incoming
    function emmergencyWithdrawBnb() external onlyOwner returns (bool success) {
        require(address(this).balance > 0, "contract has an empty BNB balance");
        administrator.transfer(address(this).balance);
        return true;
    }
}