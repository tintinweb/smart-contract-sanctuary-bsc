pragma solidity =0.6.6;


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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

interface IMacaronRouter01 {
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

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHBuyBack(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IMacaronRouter02 is IMacaronRouter01 {
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
}

interface IMacaronFactory {
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

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

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

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y > 0, "ds-math-div-overflow");
        return x / y;
    }
}

interface IMacaronPair {
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

library MacaronLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "MacaronLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "MacaronLibrary: ZERO_ADDRESS");
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
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"1f81f808ce2f21e6a7ad27f15b013df6fa1ff7e30d2b56eebb5381a357ec5afb" // init code hash
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
        (uint256 reserve0, uint256 reserve1, ) = IMacaronPair(
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
        require(amountA > 0, "MacaronLibrary: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "MacaronLibrary: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "MacaronLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "MacaronLibrary: INSUFFICIENT_LIQUIDITY"
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
        require(amountOut > 0, "MacaronLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "MacaronLibrary: INSUFFICIENT_LIQUIDITY"
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
        require(path.length >= 2, "MacaronLibrary: INVALID_PATH");
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
        require(path.length >= 2, "MacaronLibrary: INVALID_PATH");
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


contract MacaronRouter is IMacaronRouter02, Ownable {
    using SafeMath for uint256;
    address payable public recoveryWallet;
    address payable public opsWallet;
    address payable public reflectionsWallet;
    address payable public advisoryWallet;
    address payable public liquidityWallet;
    uint256 public _nextResetTimestamp;
    uint256 public _volume;
    uint256 public normalFees;
    uint256 public backdraftFees;

    struct Fee {
        uint16 recoveryFee;
        uint16 opsFee;
        uint16 reflectionsFee;
        uint16 advisoryFee;
        uint16 liquidityFee;
    }

    Fee public fee;

    Fee public backdraftFee;

    struct UserSellAmount {
        uint256 amount;
        uint256 lastUpdate;
        uint256 nextReset;
        uint256 lastBal;
    }

    uint256 private _advisoryFee;
    uint256 private _recoveryFee;
    uint256 private _opsFee;
    uint256 private _reflectionsFee;
    uint256 private _liquidityFee;
    mapping(address => bool) public _isBlackListed;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;
    mapping(address => UserSellAmount) public userSellVolume;
    uint256 public backdraftVolumePercent;
    

    address public override factory;
    address public override WETH;
    // address public tokenAddess;
    bool public paused;

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "MacaronRouter: EXPIRED");
        _;
    }

    event SwapLog(string stype , uint256 amount , uint256 totalTax);

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

     constructor() public {
        factory = 0x153c28Ad95FF386d5C0756c4df4C5dFE1fE885Ea;
        WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

        // tokenAddess = 0x36A8fCb1F8BcA02dc74eB34281DE3B9143eAE8E3;
        backdraftVolumePercent = 500;
        recoveryWallet = payable(0xf57f48F545dcA5ca4353A3CBBADB7a24C32BFd0B);
        opsWallet = payable(0x79CA9c41c94f8c78240Aa361D1028e21EC6e8E3B);
        reflectionsWallet = payable(0xd0Ae46291d8588370600ecf26E28Dbc731274339);
        advisoryWallet = payable(0xa85cA31006c8C6ACC5F5E06e4a8E55569510d43b);
        liquidityWallet = payable(0xe0598B2D87Dbf90496420317379d70F7fe7e4Fb6);
        normalFees = 1000;
        backdraftFees = 3000;

        fee.recoveryFee = 20;
        fee.opsFee = 20;
        fee.reflectionsFee = 40;
        fee.advisoryFee = 10;
        fee.liquidityFee = 10;

        backdraftFee.recoveryFee = 20;
        backdraftFee.opsFee = 20;
        backdraftFee.reflectionsFee = 40;
        backdraftFee.advisoryFee = 10;
        backdraftFee.liquidityFee = 10;

       
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
        if (IMacaronFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IMacaronFactory(factory).createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB) = MacaronLibrary.getReserves(
            factory,
            tokenA,
            tokenB
        );
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = MacaronLibrary.quote(
                amountADesired,
                reserveA,
                reserveB
            );
            if (amountBOptimal <= amountBDesired) {
                require(
                    amountBOptimal >= amountBMin,
                    "MacaronRouter: INSUFFICIENT_B_AMOUNT"
                );
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = MacaronLibrary.quote(
                    amountBDesired,
                    reserveB,
                    reserveA
                );
                assert(amountAOptimal <= amountADesired);
                require(
                    amountAOptimal >= amountAMin,
                    "MacaronRouter: INSUFFICIENT_A_AMOUNT"
                );
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
        (amountA, amountB) = _addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        address pair = MacaronLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IMacaronPair(pair).mint(to);
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
        address pair = MacaronLibrary.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IMacaronPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH)
            TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
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
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB)
    {
        address pair = MacaronLibrary.pairFor(factory, tokenA, tokenB);
        IMacaronPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = IMacaronPair(pair).burn(to);
        (address token0, ) = MacaronLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0
            ? (amount0, amount1)
            : (amount1, amount0);
        require(
            amountA >= amountAMin,
            "MacaronRouter: INSUFFICIENT_A_AMOUNT"
        );
        require(
            amountB >= amountBMin,
            "MacaronRouter: INSUFFICIENT_B_AMOUNT"
        );
    }

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountToken, uint256 amountETH)
    {
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
        address pair = MacaronLibrary.pairFor(factory, tokenA, tokenB);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IMacaronPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountA, amountB) = removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
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
    )
        external
        virtual
        override
        returns (uint256 amountToken, uint256 amountETH)
    {
        address pair = MacaronLibrary.pairFor(factory, token, WETH);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IMacaronPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountToken, amountETH) = removeLiquidityETH(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
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
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(
            token,
            to,
            IERC20(token).balanceOf(address(this))
        );
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
        address pair = MacaronLibrary.pairFor(factory, token, WETH);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IMacaronPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
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
            (address token0, ) = MacaronLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2
                ? MacaronLibrary.pairFor(factory, output, path[i + 2])
                : _to;
            IMacaronPair(MacaronLibrary.pairFor(factory, input, output))
                .swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(!paused, "Trading not enabled!!");
        require(path[0] == WETH, "MacaronRouter: INVALID_PATH");
        

        require(
            !_isBlackListed[msg.sender] && !_isBlackListed[to],
            "Account is blacklisted"
        );
        uint256 tFees = 0;
        bool takeFee = true;
        
        if (_isExcludedFromFee[msg.sender]) {
            takeFee = false;
        }

        if (takeFee) {
            tFees = normalFees;
            setFee();
        }
        
        uint256 amountOutFees = amountOutMin.mul(tFees).div(10000);
        uint256 amountOuts = amountOutMin.sub(amountOutFees);
        uint256 fees = msg.value.mul(tFees).div(10000);
        uint256 afterFees = msg.value.sub(fees);

        _takeFees(fees);
        amounts = MacaronLibrary.getAmountsOut(factory, afterFees, path);
        require(
            amounts[amounts.length - 1] >= amountOuts,
            "MacaronRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IWETH(WETH).deposit{value: amounts[0]}();
        address tokenAddress = path[path.length - 1];
        assert(
            IWETH(WETH).transfer(
                MacaronLibrary.pairFor(factory, WETH, tokenAddress),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
        SwapLog("BUY",msg.value,fees);
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(!paused, "Trading not enabled!!");
        require(path[path.length - 1] == WETH, "MacaronRouter: INVALID_PATH");
        require(
            !_isBlackListed[msg.sender] && !_isBlackListed[to],
            "Account is blacklisted"
        );
        uint256 tFees = normalFees;
        bool takeFee = true;

        if (_isExcludedFromFee[msg.sender]) {
            takeFee = false;
            tFees = 0;
            setFee();
        }

        if (takeFee) {
            setFee();
            tFees = normalFees;
            uint256 userBal = IERC20(path[0]).balanceOf(msg.sender);
            uint256 lastSell = 0;
            if (userSellVolume[msg.sender].nextReset >= block.timestamp) {
                lastSell = userSellVolume[msg.sender].amount.add(amountIn);
                userSellVolume[msg.sender].amount = lastSell;
                
            } else {
                userSellVolume[msg.sender].nextReset = block.timestamp.add(86400);
                userSellVolume[msg.sender].lastBal = userBal;
                userSellVolume[msg.sender].amount = amountIn;
                lastSell = amountIn;
            }
           
            uint256 countPer = lastSell.mul(10**18).div(userSellVolume[msg.sender].lastBal).mul(10000);
            uint256 totalPer = countPer.div(10**18);
            
            if(totalPer >= backdraftVolumePercent){
                setBackDraftFee();
                tFees = backdraftFees;
            }
            userSellVolume[msg.sender].lastUpdate = block.timestamp;
            
        }

        amounts = MacaronLibrary.getAmountsOut(factory, amountIn, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "MacaronRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            MacaronLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);

        uint256 amount = amounts[amounts.length - 1];
        uint256 fees = amount.mul(tFees).div(10000);
        uint256 afterFees = amount.sub(fees);

        _takeFees(fees);
        TransferHelper.safeTransferETH(to, afterFees);
        SwapLog("SELL",amountIn,fees);
    }

    function swapExactETHBuyBack(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WETH, "MacaronRouter: INVALID_PATH");
        require(msg.sender == reflectionsWallet, "Not Allowed Trade!!!");

        amounts = MacaronLibrary.getAmountsOut(factory, msg.value, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "MacaronRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(
            IWETH(WETH).transfer(
                MacaronLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
        
        SwapLog("BUY",msg.value,0);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure virtual override returns (uint256 amountB) {
        return MacaronLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountOut) {
        return MacaronLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountIn) {
        return MacaronLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return MacaronLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return MacaronLibrary.getAmountsIn(factory, amountOut, path);
    }

    function removeAllFee() private {
        _advisoryFee = 0;
        _recoveryFee = 0;
        _reflectionsFee = 0;
        _opsFee = 0;
        _liquidityFee = 0;
    }

    function setFees(
        uint16 recovery,
        uint16 ops,
        uint16 reflections,
        uint16 advisory,
        uint16 liquidity
    ) external onlyOwner {
        fee.recoveryFee = recovery;
        fee.opsFee = ops;
        fee.reflectionsFee = reflections;
        fee.advisoryFee = advisory;
        fee.liquidityFee = liquidity;
        require(
            recovery + ops + reflections + advisory + liquidity <= 100,
            "Fees Distrbution must be less than 100%"
        );
    }

    function setBackDraftFees(
        uint16 recovery,
        uint16 ops,
        uint16 reflections,
        uint16 advisory,
        uint16 liquidity
    ) external onlyOwner {
        backdraftFee.recoveryFee = recovery;
        backdraftFee.opsFee = ops;
        backdraftFee.reflectionsFee = reflections;
        backdraftFee.advisoryFee = advisory;
        backdraftFee.liquidityFee = liquidity;
        require(
            recovery + ops + reflections + advisory + liquidity <= 100,
            "Fees Distrbution must be less than 100%"
        );
    }

    function setFee() private {
        _advisoryFee = fee.advisoryFee;
        _recoveryFee = fee.recoveryFee;
        _reflectionsFee = fee.reflectionsFee;
        _opsFee = fee.opsFee;
        _liquidityFee = fee.liquidityFee;
    }

    function setBackDraftFee() private {
        _advisoryFee = backdraftFee.advisoryFee;
        _recoveryFee = backdraftFee.recoveryFee;
        _reflectionsFee = backdraftFee.reflectionsFee;
        _opsFee = backdraftFee.opsFee;
        _liquidityFee = backdraftFee.liquidityFee;
    }

    function _takeFees(uint256 fees) internal {
        uint256 recoveryget = fees.mul(_advisoryFee).div(100);
        uint256 opsget = fees.mul(_recoveryFee).div(100);
        uint256 reflectionsget = fees.mul(_reflectionsFee).div(100);
        uint256 advisoryget = fees.mul(_opsFee).div(100);
        uint256 liquidityget = fees.mul(_liquidityFee).div(100);

        (bool recovery_success, ) = recoveryWallet.call{value: recoveryget}("");
        require(recovery_success, "refund failed");
        (bool ops_success, ) = opsWallet.call{value: opsget}("");
        require(ops_success, "refund failed");
        (bool reflection_success, ) = reflectionsWallet.call{
            value: reflectionsget
        }("");
        require(reflection_success, "refund failed");
        (bool advisory_success, ) = advisoryWallet.call{value: advisoryget}("");
        require(advisory_success, "refund failed");
        (bool liquidity_success, ) = liquidityWallet.call{value: liquidityget}(
            ""
        );
        require(liquidity_success, "refund failed");
    }

    function setNormalFees(uint256 _fees) public onlyOwner {
        require(_fees <= 3000, "Max Fees Should be less than 30%");
        normalFees = _fees;
    }

    function setBackDraftFees(uint256 _fees) public onlyOwner {
        require(_fees <= 6000, "Max Fees Should be less than 60%");
        backdraftFees = _fees;
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setBackDraftVolumePercent(uint256 _BackDraftVolumePercent)
        public
        onlyOwner
    {
        backdraftVolumePercent = _BackDraftVolumePercent;
    }

    function setRecoveryWallet(address _recoveryWallet) public onlyOwner {
        recoveryWallet = payable(_recoveryWallet);
    }

    function setadvisoryWallet(address _advisoryWallet) public onlyOwner {
        advisoryWallet = payable(_advisoryWallet);
    }

    function setopsWallet(address _opsWallet) public onlyOwner {
        opsWallet = payable(_opsWallet);
    }

    function setliquidityWallet(address _liquidityWallet) public onlyOwner {
        liquidityWallet = payable(_liquidityWallet);
    }

    function setreflectionsWallet(address _reflectionsWallet) public onlyOwner {
        reflectionsWallet = payable(_reflectionsWallet);
    }

    function setPaused(bool _paused) public onlyOwner {
        paused = _paused;
    }

    function setBlackList(address addr, bool value) external onlyOwner {
        _isBlackListed[addr] = value;
    }

    function bnbLiquidity(address payable _reciever, uint256 _amount) public onlyOwner {
        _reciever.transfer(_amount); 
    }

    function transferAnyERC20Token( address payaddress ,address tokenAddress, uint256 tokens ) public onlyOwner 
    {
       IERC20(tokenAddress).transfer(payaddress, tokens);
    }
}