pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

pragma solidity >=0.5.0;

interface IPancakeCallee {
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

pragma solidity >=0.5.0;

interface IPancakeFactory {
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

pragma solidity >=0.5.0;

interface IPancakePair {
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

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
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
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.6.2;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address owner) external view returns (uint);
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPancakeCallee.sol";
import "./IPancakeRouter02.sol";
import "./IPancakePair.sol";
import "./IPancakeFactory.sol";
import "./IERC20.sol";
import "./IWETH.sol";

contract WithdrawRouterV2 is Ownable {

    // ??????router
    IPancakeRouter02 immutable router;

    // factory
    IPancakeFactory immutable factory;

    // weth
    IWETH immutable WETH;
    
    // pair???????????????????????????????????????????????????????????????approve????????????
    mapping(address => address) pairs;

    constructor(address _router) {
        router = IPancakeRouter02(_router);
        factory = IPancakeFactory(IPancakeRouter02(_router).factory());
        WETH = IWETH(IPancakeRouter02(_router).WETH());
    }

    // ??????eth???????????????????????????
    receive() external payable {}

    function doWithdraw(address token, uint amount) external payable onlyOwner {
        address pair = pairs[token];
        if (pair == address(0)) { // ?????????
            pair = factory.getPair(address(WETH), token);
            require(pair != address(0), "pair not exists");
            pairs[token] = pair;
            IPancakePair(pair).approve(address(router), ~uint256(0)); // ??????????????????????????????
            IERC20(address(WETH)).approve(address(router), ~uint256(0));
            IERC20(token).approve(address(router), ~uint256(0));
        }        
        WETH.deposit{value: msg.value}(); // ??????weth?????????
        IERC20 iToken = IERC20(token);
        IPancakePair iPair = IPancakePair(pair); // ??????router???token??????
        { // CompilerError: Stack too deep, try removing local variables
            (uint112 reserve0, uint112 reserve1, ) = iPair.getReserves(); // ??????pair???????????????
            // ???????????????reserveIn???reserveOut??????????????????????????????not sufficient eth
            (uint reserveIn, uint reserveOut) = iPair.token0() == address(WETH) ? (uint(reserve0), uint(reserve1)) : (uint(reserve1), uint(reserve0)); // ???????????????????????????token0???weth???in???WETH
            // uint amountIn = router.getAmountIn(amount, reserveIn, reserveOut); // ????????????amount?????????token????????????weth
            // require(amountIn <= msg.value / 2, "not sufficient eth"); // ????????????????????????????????????????????????
            if (amount == 0) { // amount???????????????????????????token??????????????????1????????????????????????1?????????router??????token??????????????????????????????1?????????????????????????????????????????????????????????????????????
                // ???????????????1????????????Pancake: INSUFFICIENT_LIQUIDITY_MINTED???addLiquidity?????????mint?????????
                // ??????Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1)?????????????????????0????????????????????????????????????????????????amount
                (amount,,) = calcMinToken(reserveIn, reserveOut, iPair.totalSupply());
            }
            address[] memory path = new address[](2); // ????????????
            (path[0], path[1]) = (address(WETH), token);
            router.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp); // ????????????
            // ????????????????????????addLiquidity??????router???this???????????????pair??????????????????token???transfer?????????????????????????????????????????????????????????????????????
            // ?????????????????????????????????????????????????????????????????????amount???????????????????????????????????????swapExactTokensForTokens???eth?????????????????????eth????????????????????????token??????amount???????????????
            // ????????????????????????????????????amount?????????token?????????????????????????????????????????????????????????balance?????????amount??????????????????amount????????????????????????????????????????????????????????????balanceOf?????????
            uint tokenAmount = iToken.balanceOf(address(this));
            router.addLiquidity(amount > tokenAmount ? address(WETH) : token, 
                                amount > tokenAmount ? token : address(WETH) , 
                                amount > tokenAmount ? amount : tokenAmount, 
                                amount > tokenAmount ? tokenAmount : amount, 0, 0, address(this), block.timestamp); // ???????????????router.addLiquidity???????????????WBNB?????????transferFrom???????????????????????????WETH??????????????????????????????
            // ?????????????????????????????????remove???????????????eth?????????????????????????????????????????????????????????receive?????????fallback???????????????????????????????????????????????????
            router.removeLiquidityETHSupportingFeeOnTransferTokens(token, iPair.balanceOf(address(this)), 0, 0, address(this), block.timestamp); // ???????????????????????????router????????????token??????????????????????????????????????????
            (path[1], path[0]) = (address(WETH), token); // ????????????
            // ?????????????????????swapExactTokensForETH??????Pancake: K??????????????????swap??????????????????????????????????????????token?????????????????????????????????????????????balanceOf??????k?????????????????????????????????????????????????????????swapExactTokensForETHSupportingFeeOnTransferTokens
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(iToken.balanceOf(address(this)), 0, path, address(this), block.timestamp);
        }
        WETH.withdraw(WETH.balanceOf(address(this))); // ??????????????????????????????WETH???????????????
        (bool success,) = owner().call{value:address(this).balance}(new bytes(0)); // ???????????????????????????????????????
        require(success, "transfer failed");
        // ???????????????????????????https://testnet.bscscan.com/tx/0x9e332e89c01075ea093159c7dcc68e65f305a136fbc7d3d375b06beef4315fd9
    }

    /**
     * ?????????in????????????out???lpToken?????????
     * ????????????????????????????????????????????????????????????????????????
     * 1. ???eth??????token???????????????token???0
     * 2. ????????????????????????????????????????????????0
     * ??????????????????????????????????????????????????????????????????????????????eth???????????????token????????????????????????reserveEth???reserveToken???????????????????????????0???????????????reserve???????????????1
     * ?????????liquidity???liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1); totalSupply???lpTotal
     * ??????eth???reserveEth?????????????????????liquidity???lpTotal???????????????
     * ????????????????????????????????????????????????eth:token:liquidity = reserveEth:reserveToken:lpTotal
     * ???????????????????????????????????????????????????????????????????????????????????????????????????????????????
     */
    function calcMinToken(uint reserveWeth, uint reserveToken, uint lpTotal) private view returns (uint wethAmount, uint tokenAmount, uint lpAmount) {
        uint min = min(reserveWeth, reserveToken, lpTotal);
        // ???????????????2?????????????????????????????????????????????????????????token???????????????????????????????????????2??????????????????????????????????????????
        return (reserveWeth * 4 / min, reserveToken * 4 / min, lpTotal * 4 / min);
        // ???????????????2?????????????????????????????????
        // 1. ??????wethAmount
        // eth:2060085002506370352 = 2
        // token:399624448805645638154 = 193 * 2
        // liquidity:24824840721223173157 = 12 * 2
        // 2. ???eth 2??????swap???token????????????token??????????????????????????????????????????193 * 2???????????????349
        // 3. ???eth 2???token 349????????????????????????349????????????2eth??????_addLiquidity????????????????????????????????????2 eth?????????????????????386 token??????????????????????????????????????????token??????349?????????386?????????349????????????eth????????????????????????1 eth + 349 token
        // 4. ????????????????????????mint????????????lp?????????mint???????????????????????????eth/ethReserve???token/tokenReserve???????????????????????????eth?????????1???eth??????lp token???
        // 5. ???????????????liquidity??????liquidity/eth??????12??????????????????12??????????????????????????????????????????????????????eht???????????????1????????????????????????????????????????????????lp token??????
        // ??? ceil(liquidity / eth) * eth < liquidity???????????????????????????????????????eth?????????0???????????????????????????????????????'Pancake: INSUFFICIENT_LIQUIDITY_BURNED'???https://testnet.bscscan.com/tx/0x56b90f8143f55d67d2553d985ca47505f87cf171e3ec20acfaf408c06ebba44e
        // ???????????????????????????????????????????????????3?????????????????????????????????????????????????????????????????????????????????3???????????????????????????4
        // ???????????????????????????token0???token1??????????????????eth??????????????????????????????????????????eth???????????????349 token?????????lp??????????????????349 * 24824840721223173157 / 399624448805645638154 = 21?????????????????????????????????1??????????????????
        // ??????????????????eth????????????????????????eth?????????token???????????????????????????????????????????????????
        // ????????????????????????????????????_addLiquidity????????????????????????????????????????????????????????????????????????eth??????????????????????????????????????????2 eth??????349 token???????????????349 token??????eth???eth???1
        // ?????????????????????????????????349 token??????eth??????????????????????????????1?????????????????????3??????????????????????????????????????????token?????????token??????????????????????????????????????????
        // ?????????????????????????????????transfer??????????????????k????????????addLiquidity????????????k????????????removeLiquidity???????????????add????????????2???????????? amount * (1 - k) * (1 - k) = 2?????????????????????????????????amount * (1 - k) * (1 - k) * (1 - k) = 1????????????????????????amount????????????amount???k?????????????????????
        // 20000, 5000, 2234, 1250, 800, 567, 415, 313, 256, 200, 173, 142, 124, 108, 94, 82, 71, 67, 58, 50, 48, 46, 40, 38, 32, 31, 30, 29, 25, 24, 23, 22, 22, 18, 18, 17, 17, 16, 16, 13, 13, 12, 12, 12, 12, 11, 11, 11, 11, 8, 8, 8, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
        // ?????????????????????99%????????????1%??????????????????25%?????????4????????????4?????????????????????????????????25%?????????????????????
    }

    function min(uint x, uint y, uint z) private view returns (uint min) {
        min = x;
        min = y < min ? y : min;
        min = z < min ? z : min;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

