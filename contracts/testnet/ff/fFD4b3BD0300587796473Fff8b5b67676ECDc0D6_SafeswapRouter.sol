/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// File: contracts/SafeswapRouter.sol

/**
 *Submitted for verification at BscScan.com on 2022-08-09
 */

// File: contracts/SafeswapRouter.sol

/**
 *Submitted for verification at BscScan.com on 2022-07-08
 */

// File: contracts/IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}
// File: contracts/IERC20.sol

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
// File: contracts/SafeMath.sol

pragma solidity =0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'SafeMath: division by zero');
        return a / b;
    }
}
// File: contracts/ISafeswapPair.sol

pragma solidity >=0.5.0;

interface ISafeswapPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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
// File: contracts/SafeswapLibrary.sol

pragma solidity >=0.5.0;

library SafeswapLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'SafeswapLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'SafeswapLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex'e6cd96fd3e55f2c35029835d89f51e8f5ca10bbbb7544fba53e02454fa9b26f8' // init code hash
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
        (uint256 reserve0, uint256 reserve1, ) = ISafeswapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, 'SafeswapLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'SafeswapLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, 'SafeswapLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'SafeswapLibrary: INSUFFICIENT_LIQUIDITY');
        uint256 amountInWithFee = amountIn.mul(998);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, 'SafeswapLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'SafeswapLibrary: INSUFFICIENT_LIQUIDITY');
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, 'SafeswapLibrary: INVALID_PATH');
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, 'SafeswapLibrary: INVALID_PATH');
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}
// File: contracts/ISafeswapRouter01.sol

pragma solidity >=0.6.2;

interface ISafeswapRouter01 {
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
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}
// File: contracts/ISafeswapRouter02.sol

pragma solidity >=0.6.2;

interface ISafeswapRouter02 is ISafeswapRouter01 {
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
// File: contracts/TransferHelper.sol

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}
// File: contracts/ISafeswapFactory.sol

pragma solidity >=0.5.0;

interface ISafeswapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}
// File: contracts/SafeswapRouter.sol

pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

contract SafeswapRouter is ISafeswapRouter02 {
    using SafeMath for uint256;

    address public override factory;
    address public override WETH;
    bool private killSwitch;
    address public admin;
    uint256 tokensCount;

    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) public _approvePartner;
    mapping(address => bool) private _lpTokenLockStatus;
    mapping(address => uint256) private _locktime;
    mapping(address => tokenInfo) nameToInfo;
    // mapping(uint256 => address) public idToAddress;
    address[] private _stpTokensList;
    event isSwiched(bool newSwitch);

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, 'SafeswapRouter: EXPIRED');
        _;
    }

    struct tokenInfo {
        bool enabled;
        string tokenName;
        address tokenAddress;
        address feesAddress;
        uint256 expectedBuy;
        uint256 expectedSell;
        uint256 actualBuy;
        uint256 actualSell;
    }

    constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
        admin = msg.sender;
        tokensCount = 0;
        killSwitch = false;
    }

    modifier onlyOwner() {
        require(admin == msg.sender, 'Ownable: caller is not the owner');
        _;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function getTokenDeduction(address token, uint256 amount) external view returns (uint256, address) {
        if (nameToInfo[token].enabled == false || killSwitch == true) return (0, address(0));
        //amountOut.mul(nameToInfo[path[1]].expectedBuy.sub(nameToInfo[path[1]].actualBuy)).div(100);
        uint256 subt = nameToInfo[token].expectedBuy.sub(nameToInfo[token].actualBuy);
        uint256 deduction = amount.mul(subt).div(100 - subt);
        return (deduction, nameToInfo[token].feesAddress);
    }

    function registerToken(
        string calldata tokenName,
        address tokenAddress,
        address feesAddress,
        uint256 expectedBuy,
        uint256 expectedSell,
        uint256 actualBuy,
        uint256 actualSell,
        bool isUpdate
    ) external onlyOwner {
        if (!isUpdate) {
            require(nameToInfo[tokenAddress].tokenAddress == address(0), 'token already exists');
            // idToAddress[tokensCount] = tokenAddress;
            _stpTokensList.push(tokenAddress);
            tokensCount++;
        } else {
            require(nameToInfo[tokenAddress].tokenAddress != address(0), 'token does not exist');
        }

        nameToInfo[tokenAddress] = tokenInfo(
            true,
            tokenName,
            tokenAddress,
            feesAddress,
            expectedBuy,
            expectedSell,
            actualBuy,
            actualSell
        );
    }

    // function to disable token stp
    function switchSTPToken(address _tokenAddress) external onlyOwner {
        nameToInfo[_tokenAddress].enabled = !nameToInfo[_tokenAddress].enabled;
    }

    function getKillSwitch() external view returns (bool) {
        return killSwitch;
    }

    function switchSTP() external onlyOwner returns (bool) {
        killSwitch = !killSwitch;
        emit isSwiched(killSwitch);
        return killSwitch;
    }

    function getSTPTokensList() external view returns (address[] memory) {
        return _stpTokensList;
    }

    // function getAllStpTokens() external view returns (tokenInfo[] memory) {
    //     tokenInfo[] memory ret = new tokenInfo[](tokensCount);
    //     for (uint256 i = 0; i < tokensCount; i++) {
    //         ret[i] = nameToInfo[idToAddress[i]];
    //     }
    //     return ret;
    // }

    function getTokenSTP(address _tokenAddress) external view returns (tokenInfo memory) {
        return nameToInfo[_tokenAddress];
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        // create the pair if it doesn't exist yet
        if (ISafeswapFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            ISafeswapFactory(factory).createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB) = SafeswapLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = SafeswapLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'SafeswapRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = SafeswapLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'SafeswapRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        require(!_isBlacklisted[to], 'Address is blacklisted');
        require(_approvePartner[to], 'Waiting for partner approval');
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = SafeswapLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = ISafeswapPair(pair).mint(to);
    }

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
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        require(_approvePartner[to], 'Waiting for partner approval');
        address pair = SafeswapLibrary.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = ISafeswapPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountA, uint256 amountB) {
        require(!_isBlacklisted[to], 'Address is blacklisted');
        address pair = SafeswapLibrary.pairFor(factory, tokenA, tokenB);
        ISafeswapPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = ISafeswapPair(pair).burn(to);
        (address token0, ) = SafeswapLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'SafeswapRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'SafeswapRouter: INSUFFICIENT_B_AMOUNT');
    }

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountToken, uint256 amountETH) {
        require(!_isBlacklisted[to], 'Address is blacklisted');
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

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
    ) external virtual override returns (uint256 amountA, uint256 amountB) {
        require(!_isBlacklisted[to], 'Address is blacklisted');
        address pair = SafeswapLibrary.pairFor(factory, tokenA, tokenB);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        ISafeswapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

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
    ) external virtual override returns (uint256 amountToken, uint256 amountETH) {
        require(!_isBlacklisted[to], 'Address is blacklisted');
        address pair = SafeswapLibrary.pairFor(factory, token, WETH);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        ISafeswapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountETH) {
        require(!_isBlacklisted[to], 'Address is blacklisted');
        (, amountETH) = removeLiquidity(token, WETH, liquidity, amountTokenMin, amountETHMin, address(this), deadline);
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

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
    ) external virtual override returns (uint256 amountETH) {
        require(!_isBlacklisted[to], 'Address is blacklisted');
        address pair = SafeswapLibrary.pairFor(factory, token, WETH);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        ISafeswapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = SafeswapLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2 ? SafeswapLibrary.pairFor(factory, output, path[i + 2]) : _to;
            ISafeswapPair(SafeswapLibrary.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
        amounts = SafeswapLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'SafeswapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        // snippet for 'sell' fees !
        if (
            nameToInfo[path[0]].enabled == true &&
            killSwitch == false &&
            (nameToInfo[path[0]].actualSell != nameToInfo[path[0]].expectedSell)
        ) {
            uint256 deduction = amountIn.mul(nameToInfo[path[0]].expectedSell.sub(nameToInfo[path[0]].actualSell)).div(
                100
            );
            amountIn = amountIn.sub(deduction);
            TransferHelper.safeTransferFrom(path[0], msg.sender, nameToInfo[path[0]].feesAddress, deduction);
        }
        amounts = SafeswapLibrary.getAmountsOut(factory, amountIn, path);
        // same code snippet for 'buy' fees
        if (
            nameToInfo[path[1]].enabled == true &&
            killSwitch == false &&
            (nameToInfo[path[1]].actualBuy != nameToInfo[path[1]].expectedBuy)
        ) {
            uint256 amountOut = amounts[amounts.length - 1];
            uint256 deduction = amountOut.mul(nameToInfo[path[1]].expectedBuy.sub(nameToInfo[path[1]].actualBuy)).div(
                100
            );
            amountOut = amountOut.sub(deduction);
            amounts[amounts.length - 1] = amountOut;
        }
        //require(amounts[amounts.length - 1] >= amountOutMin, 'SafeswapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SafeswapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
        amounts = SafeswapLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'SafeswapRouter: EXCESSIVE_INPUT_AMOUNT');
        if (
            nameToInfo[path[1]].enabled == true &&
            killSwitch == false &&
            (nameToInfo[path[1]].actualBuy != nameToInfo[path[1]].expectedBuy)
        ) {
            uint256 deduction = amountOut.mul(nameToInfo[path[1]].expectedBuy.sub(nameToInfo[path[1]].actualBuy)).div(
                100
            );
            amountOut = amountOut.sub(deduction);
        }
        amounts = SafeswapLibrary.getAmountsIn(factory, amountOut, path);
        if (
            nameToInfo[path[0]].enabled == true &&
            killSwitch == false &&
            (nameToInfo[path[0]].actualSell != nameToInfo[path[0]].expectedSell)
        ) {
            uint256 amountIn = amounts[0];
            uint256 deduction = amountIn.mul(nameToInfo[path[0]].expectedSell.sub(nameToInfo[path[0]].actualSell)).div(
                100
            );
            amounts[0] = amountIn.sub(deduction);
            TransferHelper.safeTransferFrom(path[0], msg.sender, nameToInfo[path[0]].feesAddress, deduction);
        }
        amounts = SafeswapLibrary.getAmountsOut(factory, amounts[0], path);

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SafeswapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) returns (uint256[] memory amounts) {
        require(path[0] == WETH, 'SafeswapRouter: INVALID_PATH');
        amounts = SafeswapLibrary.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'SafeswapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        if (
            nameToInfo[path[1]].enabled == true &&
            killSwitch == false &&
            (nameToInfo[path[1]].actualBuy != nameToInfo[path[1]].expectedBuy)
        ) {
            uint256 amountOut = amounts[amounts.length - 1];
            uint256 deduction = amountOut.mul(nameToInfo[path[1]].expectedBuy.sub(nameToInfo[path[1]].actualBuy)).div(
                100
            );
            amounts[amounts.length - 1] = amountOut.sub(deduction);
        }
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(SafeswapLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
        require(path[path.length - 1] == WETH, 'SafeswapRouter: INVALID_PATH');
        amounts = SafeswapLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'SafeswapRouter: EXCESSIVE_INPUT_AMOUNT');
        if (
            nameToInfo[path[0]].enabled == true &&
            killSwitch == false &&
            (nameToInfo[path[0]].actualSell != nameToInfo[path[0]].expectedSell)
        ) {
            uint256 amountIn = amounts[0];
            uint256 deduction = amountIn.mul(nameToInfo[path[0]].expectedSell.sub(nameToInfo[path[0]].actualSell)).div(
                100
            );
            amounts[0] = amountIn.sub(deduction);
            TransferHelper.safeTransferFrom(path[0], msg.sender, nameToInfo[path[0]].feesAddress, deduction);
        }
        amounts = SafeswapLibrary.getAmountsOut(factory, amounts[0], path);
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SafeswapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
        require(path[path.length - 1] == WETH, 'SafeswapRouter: INVALID_PATH');
        uint256[] memory oldamounts = SafeswapLibrary.getAmountsOut(factory, amountIn, path); // ,amountIn,
        require(oldamounts[oldamounts.length - 1] >= amountOutMin, 'SafeswapRouter: INSUFFICIENT_OUTPUT_AMOUNT');

        if (
            nameToInfo[path[0]].enabled == true &&
            killSwitch == false &&
            (nameToInfo[path[0]].actualSell != nameToInfo[path[0]].expectedSell)
        ) {
            uint256 deduction = amountIn.mul(nameToInfo[path[0]].expectedSell.sub(nameToInfo[path[0]].actualSell)).div(
                100
            );
            amountIn = amountIn.sub(deduction);
            TransferHelper.safeTransferFrom(path[0], msg.sender, nameToInfo[path[0]].feesAddress, deduction);
        }

        amounts = SafeswapLibrary.getAmountsOut(factory, amountIn, path); // ,amountIn,

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SafeswapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0] // amouts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        // killswitch(path) - false
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WETH, 'SafeswapRouter: INVALID_PATH');
        amounts = SafeswapLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'SafeswapRouter: EXCESSIVE_INPUT_AMOUNT');
        if (
            nameToInfo[path[1]].enabled == true &&
            killSwitch == false &&
            (nameToInfo[path[1]].actualBuy != nameToInfo[path[1]].expectedBuy)
        ) {
            uint256 deduction = amountOut.mul(nameToInfo[path[1]].expectedBuy.sub(nameToInfo[path[1]].actualBuy)).div(
                100
            );
            amountOut = amountOut.sub(deduction);
        }
        amounts = SafeswapLibrary.getAmountsIn(factory, amountOut, path);

        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(SafeswapLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = SafeswapLibrary.sortTokens(input, output);
            ISafeswapPair pair = ISafeswapPair(SafeswapLibrary.pairFor(factory, input, output));
            uint256 amountInput;
            uint256 amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
                (uint256 reserveInput, uint256 reserveOutput) = input == token0
                    ? (reserve0, reserve1)
                    : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = SafeswapLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            if (killSwitch == false) {
                uint256 deduction = amountOutput
                    .mul(nameToInfo[output].expectedBuy.sub(nameToInfo[output].actualBuy))
                    .div(100);
                amountOutput = amountOutput.sub(deduction);
            }
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
            address to = i < path.length - 2 ? SafeswapLibrary.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        if (
            nameToInfo[path[0]].enabled == true &&
            killSwitch == false &&
            (nameToInfo[path[0]].actualSell != nameToInfo[path[0]].expectedSell)
        ) {
            uint256 deduction = amountIn.mul(nameToInfo[path[0]].expectedSell.sub(nameToInfo[path[0]].actualSell)).div(
                100
            );
            amountIn = amountIn.sub(deduction);
            TransferHelper.safeTransferFrom(path[0], msg.sender, nameToInfo[path[0]].feesAddress, deduction);
        }

        //address[] memory _FFSpath;
        //_FFSpath[1] = WETH;
        //_FFSpath[0] = path[0];
        //uint256[] memory _WETHOut = SafeswapLibrary.getAmountsOut(factory, amountIn, _FFSpath); // get outputs in case of LP(A, BNB)
        //require(msg.value >= _WETHOut[_WETHOut.length - 1], 'send enough BNB tax');

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SafeswapLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'SafeswapRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) {
        require(path[0] == WETH, 'SafeswapRouter: INVALID_PATH');
        uint256 amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(SafeswapLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'SafeswapRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        require(path[path.length - 1] == WETH, 'SafeswapRouter: INVALID_PATH');

        if (
            nameToInfo[path[0]].enabled == true &&
            killSwitch == false &&
            (nameToInfo[path[0]].actualSell != nameToInfo[path[0]].expectedSell)
        ) {
            uint256 deduction = amountIn.mul(nameToInfo[path[0]].expectedSell.sub(nameToInfo[path[0]].actualSell)).div(
                100
            );
            amountIn = amountIn.sub(deduction);
            TransferHelper.safeTransferFrom(path[0], msg.sender, nameToInfo[path[0]].feesAddress, deduction);
        }

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SafeswapLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint256 amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'SafeswapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure virtual override returns (uint256 amountB) {
        return SafeswapLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountOut) {
        return SafeswapLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountIn) {
        return SafeswapLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return SafeswapLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return SafeswapLibrary.getAmountsIn(factory, amountOut, path);
    }

    function blacklistAddress(address account) public onlyOwner {
        _isBlacklisted[account] = true;
    }

    function unBlacklistAddress(address account) public onlyOwner {
        _isBlacklisted[account] = false;
    }

    function approveLiquidityPartner(address account) public onlyOwner {
        _approvePartner[account] = true;
    }

    function unApproveLiquidityPartner(address account) public onlyOwner {
        _approvePartner[account] = false;
    }

    function lockLP(address LPtoken, uint256 time) public onlyOwner {
        _lpTokenLockStatus[LPtoken] = true;
        _locktime[LPtoken] = block.timestamp + time;
    }
}