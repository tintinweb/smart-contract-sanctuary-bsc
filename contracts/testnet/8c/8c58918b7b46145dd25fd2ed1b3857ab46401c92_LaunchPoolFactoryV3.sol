/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT

// File: contracts/LaunchpoolV3.sol

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/launchpool.sol

pragma solidity ^0.8.7;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function deposit() external payable;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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
            "TransferHelper::safeApprove: approve failed"
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
            "TransferHelper::safeTransfer: transfer failed"
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
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
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
                            //hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66' // init code hash
                            hex"ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074" // Change to INIT_CODE_PAIR_HASH of Pancake Factory
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
        require(amountOut > 0, "PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
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

interface IPancakeRouter {
    function WETH() external view returns (address);

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

    function factory() external view returns (address);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

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

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

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

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
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

    receive() external payable;
}

contract LaunchPool {
    using SafeMath for uint256;
    address payable public deployer;
    address payable public owner;
    uint256[] public vestDuration = [0 days];
    uint256[] public vestingClaim = [100]; // in percentage
    address wBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address ReceiverFee = 0x546ba9FfE3B229f80EE13CC27899F84472918cA0;

    enum Release {
        NOT_SET,
        FAILED,
        RELEASED
    }

    IPancakeRouter public PancakeRouter =
        IPancakeRouter(payable(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3));
    IERC20 tokenSell;
    string urlSocial;
    uint64 presaleRate;
    uint64 listingRate;
    uint64 addToLiquidityPercentage;
    uint256 public startTime;
    uint256 public endTime;
    uint256 totalTokenSell;
    uint256 softCap;
    uint256 hardCap;
    uint256 maxBuy;
    uint256 minBuy;
    bool isRefund;
    uint256 public alreadyRaised;
    Release public release;
    uint256 public releaseTime;
    uint256 public lockPeriod;
    IERC20 public activeCurrency;
    bool public isWhitelist = false;
    bool public isCheckSoftCap = true;
    bool public isVesting = false;

    struct UserInfo {
        uint256 totalToken;
        uint256 totalSpent;
    }

    struct LockLP {
        address owner;
        uint256 amount;
        uint256 unlockDate;
    }

    enum Claims {
        HALF,
        FULL,
        FAILED
    }

    mapping(address => UserInfo) public usersTokenBought; // userAddress => User Info
    mapping(address => LockLP) public LockedLP; // LP token => locked info
    mapping(address => bool) public whitelistedAddress;
    mapping(address => mapping(uint256 => bool)) public claimInPeriod; // userAddress => period => true/false

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    modifier withdrawCheck() {
        require(getSoftFilled() == true, "Can't withdraw");
        _;
    }

    event BUY(address Buyer, uint256 amount);
    event CLAIM(address Buyer, Claims claim);
    event RELEASE(Release released);
    event LockAdded(
        address indexed token,
        address owner,
        uint256 amount,
        uint256 unlockDate
    );

    constructor(
        address payable _owner,
        address[] memory _token, // 0: token for sale, 1: active currency
        uint64[] memory _rate, // 0: presale rate, 1: listing rate, 2: liquidity percentage
        uint256[] memory _cap, // 0: softcap, 1: hardcap, 2: minbuy, 3: maxbuy
        uint256[] memory _time, // 0: start time, 1: end time, 2: LP lock period
        bool[] memory _isWhitelistAndVesting, // 0: is whitelist, 1: is vesting
        uint256[] memory _vests, // vesting period. If there is first release after finalize, index 0 must be 0
        uint256[] memory _claims, // claim percentage. If there is first release after finalize, index 0 must be first release percentage
        string memory _urlSocial
    ) {
        require(_cap[0] >= _cap[1].mul(25).div(100), "Softcap must be greater than 25% of hardcap");
        require(_rate[2] >= 51, "Liquidity percentage minimum 51%");
        owner = _owner;
        tokenSell = IERC20(_token[0]);
        activeCurrency = IERC20(_token[1]);
        presaleRate = _rate[0];
        listingRate = _rate[1];
        addToLiquidityPercentage = _rate[2];
        softCap = _cap[0];
        hardCap = _cap[1];
        minBuy = _cap[2]; // in BNB
        maxBuy = _cap[3]; // in BNB
        startTime = _time[0];
        endTime = _time[1];
        lockPeriod = _time[2];
        isWhitelist = _isWhitelistAndVesting[0];
        isVesting = _isWhitelistAndVesting[1];
        setVestingPeriodAndClaim(_isWhitelistAndVesting[1], _vests, _claims);
        urlSocial = _urlSocial;
    }

    // isWhitelist
    // is

    // onlyOwner Function
    function setEventPeriod(uint256 _startTime, uint256 _endTime)
        external
        onlyOwner
    {
        require(address(tokenSell) != address(0), "Setup raised first");
        require(_startTime != 0, "Cannot set 0 value");
        require(_endTime > _startTime, "End time must be greater");
        startTime = _startTime;
        endTime = _endTime;
    }

    function setRaised(
        //address _tokenSale,
        //uint64 _presaleRate,
        //uint256 _softcap,
        //uint256 _hardcap,
        //uint256 _maxBuy,
        //uint256 _minBuy,
        //bool _isCheckSoftCap,

        uint256 _lockPeriod,
        uint64 _addToLiquidityPercentage,
        bool _isWhitelist,
        bool _isVesting,
        bool _isRefund,
        string memory _urlSocial
    ) public onlyOwner {
        // require(startTime == 0, "Raising period already start");
        //require(_hardcap > _softcap, "Hardcap must greater than softcap");
        //tokenSell = IERC20(_tokenSale);
        //uint256 _totalTokenSale = _hardcap.mul(_presaleRate);
        //uint256 allowance = tokenSell.allowance(msg.sender, address(this));
        //uint256 balance = tokenSell.balanceOf(msg.sender);
        //require(balance >= _totalTokenSale, "Not enough tokens");
        //require(allowance >= _totalTokenSale, "Check the token allowance");

        //presaleRate = _presaleRate;
        //totalTokenSell = _totalTokenSale;
        //softCap = _softcap;
        //hardCap = _hardcap;
        //maxBuy = _maxBuy; // in BNB
        //minBuy = _minBuy; // in BNB
        lockPeriod = _lockPeriod;
        addToLiquidityPercentage = _addToLiquidityPercentage;
        isWhitelist = _isWhitelist;
        isVesting = _isVesting; // only set one time
        isRefund = _isRefund;
        urlSocial = _urlSocial;

        //isCheckSoftCap = _isCheckSoftCap; // only set one time
        //tokenSell.transferFrom(msg.sender, address(this), _totalTokenSale);
    }

    function setIsWhitelist(bool _isWhitelist) external onlyOwner {
        require(isWhitelist != _isWhitelist, "cannot assign same value");
        isWhitelist = _isWhitelist;
    }

    function addWhitelised(
        address[] memory whitelistAddresses,
        bool[] memory values
    ) external onlyOwner {
        require(
            whitelistAddresses.length == values.length,
            "provide same length"
        );
        for (uint256 i = 0; i < whitelistAddresses.length; i++) {
            whitelistedAddress[whitelistAddresses[i]] = values[i];
        }
    }

    function setVestingPeriodAndClaim(
        bool _isVesting,
        uint256[] memory _vests,
        uint256[] memory _claims
    ) public onlyOwner {
        if (_isVesting) {
            require(_vests.length == _claims.length, "length must be same");
            require(block.timestamp < startTime, "Raising period already started");
            uint256 total;
            for (uint256 i = 0; i < _claims.length; i++) {
                total += _claims[i];
            }
            require(total == 100, "total claim must be 100");

            for (uint256 i = 0; i < _vests.length; i++) {
                vestDuration[i] = _vests[i].mul(1 days);
                vestingClaim[i] = _claims[i];
            }
        }
    }

    // function for lock lp
    function lock(
        address _token,
        address _owner,
        uint256 _amount,
        uint256 _unlockDate
    ) internal {
        require(
            _unlockDate > block.timestamp,
            "Unlock date should be in the future"
        );
        require(_amount > 0, "Amount should be greater than 0");

        LockLP memory lockLp = LockedLP[_token];
        lockLp.owner = _owner;
        lockLp.amount = _amount;
        lockLp.unlockDate = _unlockDate;
        LockedLP[_token] = lockLp;

        emit LockAdded(_token, _owner, _amount, _unlockDate);
    }

    // function for finalize lp
    function _finalize() internal {
        require(
            lockPeriod > block.timestamp,
            "lock periode must greater than block timestamp"
        );

        address tokenA = address(tokenSell);
        address tokenB = address(activeCurrency);

        IERC20(tokenA).approve(address(this), type(uint256).max);
        IERC20(tokenB).approve(address(this), type(uint256).max);

        uint256 balanceTokenA;
        uint256 balanceTokenB;

        if (IERC20(tokenB) == IERC20(wBNB)) {
            uint256 balance = address(this).balance;
            require(balance > 0, "does not have any balance");

            uint256 forFee = balance.mul(5).div(100);
            uint256 forLiquidity = balance.sub(forFee).mul(addToLiquidityPercentage).div(100);
            uint256 forOwner = balance.sub(forFee).sub(forLiquidity);

            payable(ReceiverFee).transfer(forFee);
            payable(owner).transfer(forOwner);
            balanceTokenA = forLiquidity.mul(listingRate);
            balanceTokenB = forLiquidity;
        } else {
            uint256 balance = IERC20(tokenB).balanceOf(address(this));
            require(balance > 0, "does not have any balance");

            uint256 forFee = balance.mul(5).div(100);
            uint256 forLiquidity = balance.sub(forFee).mul(addToLiquidityPercentage).div(100);
            uint256 forOwner = balance.sub(forFee).sub(forLiquidity);

            IERC20(tokenB).transfer(ReceiverFee, forFee);
            IERC20(tokenB).transfer(owner, forOwner);
            balanceTokenA = forLiquidity.mul(listingRate);
            balanceTokenB = forLiquidity;
        }

        (uint256 amountA, uint256 amountB) = _addLiquidity(
            tokenA,
            tokenB,
            balanceTokenA,
            balanceTokenB,
            1,
            1
        );

        if (tokenB == wBNB) IERC20(tokenB).deposit{value: amountB}();

        address factory = PancakeRouter.factory();
        address pair = PancakeLibrary.pairFor(factory, tokenA, tokenB);
        IERC20(tokenA).transfer(pair, amountA);
        IERC20(tokenB).transfer(pair, amountB);

        uint256 presaleAmount = alreadyRaised.mul(presaleRate);
        uint256 refundAmount = IERC20(tokenA).balanceOf(address(this)).sub(presaleAmount);
        IERC20(tokenA).transfer(owner, refundAmount);

        uint256 liquidity = IPancakePair(pair).mint(address(this));
        lock(pair, msg.sender, liquidity, lockPeriod);
    }

    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        // create the pair if it doesn't exist yet
        address factory = PancakeRouter.factory();
        if (IPancakeFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IPancakeFactory(factory).createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB) = PancakeLibrary.getReserves(
            factory,
            tokenA,
            tokenB
        );
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = PancakeLibrary.quote(
                amountADesired,
                reserveA,
                reserveB
            );
            if (amountBOptimal <= amountBDesired) {
                require(
                    amountBOptimal >= amountBMin,
                    "PancakeRouter: INSUFFICIENT_B_AMOUNT"
                );
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = PancakeLibrary.quote(
                    amountBDesired,
                    reserveB,
                    reserveA
                );
                assert(amountAOptimal <= amountADesired);
                require(
                    amountAOptimal >= amountAMin,
                    "PancakeRouter: INSUFFICIENT_A_AMOUNT"
                );
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function setRelease(Release _release)
        external
        onlyOwner
    {
        require(startTime != 0, "Raise no start");
        require(release != _release, "Can't setup same release");
        require(release < Release.RELEASED, "Already released");
        if (isCheckSoftCap) {
            require(getSoftFilled(), "Softcap not fullfiled");
        }
        if (getHardFilled() == false) {
            require(block.timestamp > endTime, "Raising not end");
        }
        release = _release;
        releaseTime = block.timestamp;

        if (release == Release.RELEASED) _finalize();

        emit RELEASE(_release);
    }

    function withdrawLP(address _tokenLP) external onlyOwner {
        LockLP memory data = LockedLP[_tokenLP];
        require(data.owner == msg.sender, "You are not the owner of this LP");
        require(
            data.unlockDate <= block.timestamp,
            "The LP is still in lock period"
        );
        uint256 totalSupply = IERC20(_tokenLP).totalSupply();
        uint256 balance = IERC20(_tokenLP).balanceOf(address(this));
        uint256 allowance = IERC20(_tokenLP).allowance(
            address(this),
            address(this)
        );
        if (allowance < balance)
            IERC20(_tokenLP).approve(address(this), totalSupply);
        IERC20(_tokenLP).transferFrom(address(this), msg.sender, data.amount);
    }

    // function withdrawBNB() public onlyOwner withdrawCheck {
    //     uint256 balance = address(this).balance;
    //     require(balance > 0, "does not have any balance");
    //     payable(msg.sender).transfer(balance);
    // }

    // function withdrawToken(address _tokenAddress, uint256 _amount)
    //     public
    //     onlyOwner
    // {
    //     IERC20(_tokenAddress).transfer(msg.sender, _amount);
    // }

    // Buy Function
    function getHardFilled() public view returns (bool) {
        return alreadyRaised >= hardCap;
    }

    function getSoftFilled() public view returns (bool) {
        return alreadyRaised >= softCap;
    }

    function getSellTokenAmount(uint256 _amount)
        internal
        view
        returns (uint256)
    {
        return _amount * presaleRate;
    }

    function buyWithBNB() external payable {
        require(
            activeCurrency == IERC20(wBNB),
            "Cannot buy with BNB, Please buy with Token"
        );
        require(block.timestamp != 0, "Raising period not set");
        require(block.timestamp >= startTime, "Raising period not started yet");
        require(block.timestamp < endTime, "Raising period already end");
        require(msg.value > 0, "Please input value");
        require(getHardFilled() == false, "Raise already fullfilled");

        UserInfo memory userInfo = usersTokenBought[msg.sender];

        require(
            userInfo.totalSpent.add(msg.value) >= minBuy,
            "Less than min buy"
        );
        require(
            userInfo.totalSpent.add(msg.value) <= maxBuy,
            "More than max buy"
        );
        require(
            msg.value + alreadyRaised <= hardCap,
            "amount buy more than total hardcap"
        );

        uint256 tokenSellAmount = getSellTokenAmount(msg.value);
        userInfo.totalToken = userInfo.totalToken.add(tokenSellAmount);
        userInfo.totalSpent = userInfo.totalSpent.add(msg.value);
        usersTokenBought[msg.sender] = userInfo;

        alreadyRaised = alreadyRaised.add(msg.value);

        emit BUY(msg.sender, tokenSellAmount);
    }

    function buyWithToken(uint256 amount) external {
        require(
            activeCurrency != IERC20(wBNB),
            "Cannot buy with Token, Please buy with BNB"
        );
        require(block.timestamp != 0, "Raising period not set");
        require(block.timestamp >= startTime, "Raising period not started yet");
        require(block.timestamp < endTime, "Raising period already end");
        require(amount > 0, "Please input value");
        require(getHardFilled() == false, "Raise already fullfilled");

        UserInfo memory userInfo = usersTokenBought[msg.sender];

        require(userInfo.totalSpent.add(amount) >= minBuy, "Less than min buy");
        require(userInfo.totalSpent.add(amount) <= maxBuy, "More than max buy");
        require(
            amount + alreadyRaised <= hardCap,
            "amount buy more than total hardcap"
        );

        activeCurrency.transferFrom(msg.sender, address(this), amount);

        uint256 tokenSellAmount = getSellTokenAmount(amount);
        userInfo.totalToken = userInfo.totalToken.add(tokenSellAmount);
        userInfo.totalSpent = userInfo.totalSpent.add(amount);
        usersTokenBought[msg.sender] = userInfo;

        alreadyRaised = alreadyRaised.add(amount);

        emit BUY(msg.sender, tokenSellAmount);
    }

    // Claim Function
    function claimFailed() external {
        require(block.timestamp > endTime, "Raising not end");
        if (isCheckSoftCap) {
            require(getSoftFilled() == false, "Soft cap already fullfiled");
        } else {
            require(release == Release.FAILED, "Release not failed");
        }

        uint256 userSpent = usersTokenBought[msg.sender].totalSpent;
        require(userSpent > 0, "Already claimed");

        if (activeCurrency == IERC20(wBNB)) {
            payable(msg.sender).transfer(userSpent);
        } else {
            activeCurrency.transfer(msg.sender, userSpent);
        }

        delete usersTokenBought[msg.sender];
        emit CLAIM(msg.sender, Claims.FAILED);
    }

    modifier checkPeriod(uint256 _claim) {
        require(
            vestDuration[_claim] + releaseTime <= block.timestamp,
            "Claim not avalaible yet"
        );
        _;
    }

    function claimSuccess(uint256 _claim)
        external
        checkPeriod(uint256(_claim))
    {
        require(release == Release.RELEASED, "Not Release Time");
        UserInfo storage userInfo = usersTokenBought[msg.sender];
        require(userInfo.totalToken > 0, "You can't claim any amount");

        uint256 amountClaim;
        Claims claim;

        if (isVesting == false) {
            require(
                claimInPeriod[msg.sender][0] == false,
                "already claim"
            );
            amountClaim = userInfo.totalToken;
            tokenSell.transfer(msg.sender, amountClaim);
            claimInPeriod[msg.sender][0] = true;
            claim = Claims.FULL;
        } else {
            require(_claim < vestDuration.length, "more than max claim");
            require(
                claimInPeriod[msg.sender][_claim] == false,
                "already claim"
            );
            amountClaim = userInfo.totalToken.mul(vestingClaim[_claim]).div(
                100
            );
            tokenSell.transfer(msg.sender, amountClaim);
            claimInPeriod[msg.sender][_claim] = true;
            claim = Claims.HALF;
        }

        emit CLAIM(msg.sender, claim);
    }

    function getRaised()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256[] memory,
            uint256,
            uint256,
            uint64,
            IERC20,
            IERC20,
            string memory
        )
    {
        return (
            alreadyRaised,
            startTime,
            endTime,
            softCap,
            hardCap,
            releaseTime,
            vestDuration,
            minBuy,
            maxBuy,
            presaleRate,
            activeCurrency,
            tokenSell,
            urlSocial
        );
    }
}
// File: contracts/LaunchpoolFactoryV3.sol

pragma solidity ^0.8.0;

/**
 * @dev This contract is for creating proxy to access launchPool token.
 */
contract LaunchPoolFactoryV3 is Ownable {
    using SafeMath for uint256;
    event CreatelaunchPool(address launchpoolAddress);
    uint256 public amountFee = 0.01 ether;
    address wBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address feeReceiver = 0xc8940abA96a537705E1090Aa9eCE7db072a54Bd6;

    function send(address payable _addr) public payable {
        require(msg.value >= amountFee);
        _addr.transfer(msg.value);
    }

    function createNewLaunchPool(
        address[] memory _token, // 0: token for sale, 1: active currency
        uint64[] memory _rate, // 0: presale rate, 1: listing rate, 2: liquidity percentage
        uint256[] memory _cap, // 0: softcap, 1: hardcap, 2: minbuy, 3: maxbuy
        uint256[] memory _time, // 0: start time, 1: end time, 2: LP lock period
        bool[] memory _isWhitelistAndVesting, // 0: is whitelist, 1: is vesting
        uint256[] memory _vests, // vesting period. If there is first release after finalize, index 0 must be 0
        uint256[] memory _claims, // claim percentage. If there is first release after finalize, index 0 must be first release percentage
        string memory _urlSocial
    ) external payable returns (address) {
        require(msg.value >= amountFee, "Amount for fee is not enough");

        LaunchPool _newPool = new LaunchPool(
            payable(msg.sender),
            _token,
            _rate,
            _cap,
            _time,
            _isWhitelistAndVesting,
            _vests,
            _claims,
            _urlSocial
        );

        // hardcap x pertoken buy = untuk di claim user yang ikut presale
        uint256 forPresale = _cap[1].mul(_rate[0]);
        // 95% hardcap * listing rate * % liquidity = untuk liquidity
        // uint256 forListing = _cap[1].sub(_cap[1].mul(5).div(100)).mul(_rate[1]).mul(_rate[2]).div(100);
        uint256 forListing = (_cap[1] * 95 / 100) * _rate[1] * _rate[2] / 100;
        // total token yang di transfer
        uint256 totalToken = forPresale.add(forListing);

        IERC20(_token[0]).transferFrom(
            msg.sender,
            address(_newPool),
            totalToken
        );

        emit CreatelaunchPool(address(_newPool));
        return address(_newPool);
    }

    function getAddress(bytes memory bytecode, uint256 _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );

        return address(uint160(uint256(hash)));
    }

    function getByteCode(address _owner) public pure returns (bytes memory) {
        bytes memory bytecode = type(LaunchPool).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner));
    }
}