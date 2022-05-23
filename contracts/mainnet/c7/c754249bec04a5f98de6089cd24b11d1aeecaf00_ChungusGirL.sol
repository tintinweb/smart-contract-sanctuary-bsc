/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

/*
ChungusGirL - Buy Jackpot every 15 minutes - FairLaunch
Website DAPP: https://www.chungusgirl.com
Twitter: https://twitter.com/TheSafuDev
Telegram: https://t.me/chungusgirlbsc
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address payable private _marketingWallet;
    address payable private _buybackWallet;

    mapping(address => bool) internal authorizations;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event AuthorizationGranted(address indexed wallet);
    event AuthorizationRevoked(address indexed wallet);

    event MarketingWalletChanged(address indexed from, address indexed to);
    event BuybackWalletChanged(address indexed from, address indexed to);

    constructor(address initialOwner) {
        _owner = initialOwner;
        authorizations[_owner] = true;

        emit OwnershipTransferred(address(0), initialOwner);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    function marketingWallet() public view returns (address payable) {
        return _marketingWallet;
    }

    function buybackWallet() public view returns (address payable) {
        return _buybackWallet;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the marketing wallet owner.
     */
    modifier onlyMarketing() {
        require(
            _marketingWallet == _msgSender(),
            "Ownable: caller is not the marketing wallet owner"
        );
        _;
    }

    /**
     * @dev Throws if called by any account other than the buyback wallet owner.
     */
    modifier onlyBuyback() {
        require(
            _buybackWallet == _msgSender(),
            "Ownable: caller is not the buyback wallet owner"
        );
        _;
    }

    function setBuybackWallet(address payable buybackWalletAddress)
        public
        virtual
        onlyOwner
    {
        require(
            buybackWalletAddress != address(0),
            "You must supply a non-zero address"
        );
        emit BuybackWalletChanged(_buybackWallet, buybackWalletAddress);
        _buybackWallet = buybackWalletAddress;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _owner = newOwner;
        authorizations[newOwner] = true;
        emit OwnershipTransferred(_owner, newOwner);
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        require(!authorizations[adr], "Address is already authorized");
        authorizations[adr] = true;

        emit AuthorizationGranted(adr);
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        require(authorizations[adr], "Address is already NOT authorized");
        authorizations[adr] = false;

        emit AuthorizationRevoked(adr);
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
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

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity ^0.8.0;


library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
             uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, value);
    }


    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {
        return _values(set._inner);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity ^0.8.1;

library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract ChungusGirL is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    EnumerableSet.AddressSet private _isExcludedFromFee;
    EnumerableSet.AddressSet private _isExcludedFromSwapAndLiquify;

    // 100%
    uint256 private constant MAX_PCT = 10000;
    uint256 private constant BNB_DECIMALS = 18;
    uint256 private constant USDT_DECIMALS = 18;
    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // At any given time, buy and sell fees can NOT exceed 10% each
    uint256 private constant TOTAL_FEES_LIMIT = 1000;
    // We don't add to liquidity unless we have at least 1 Chungus GirL token
    uint256 private constant LIQ_SWAP_THRESH = 10**_decimals;

    // PCS takes 0.25% fee on all txs
    uint256 private constant ROUTER_FEE = 25;

    // Jackpot hard limits
    uint256 private constant JACKPOT_TIMESPAN_LIMIT_MIN = 30;
    uint256 private constant JACKPOT_TIMESPAN_LIMIT_MAX = 1200000;

    uint256 private constant JACKPOT_BIGBANG_MIN = 30 * 10**USDT_DECIMALS;
    uint256 private constant JACKPOT_BIGBANG_MAX = 250000 * 10**USDT_DECIMALS;

    uint256 private constant JACKPOT_BUYER_SHARE_MIN = 500;
    uint256 private constant JACKPOT_BUYER_SHARE_MAX = 10000;

    uint256 private constant JACKPOT_MINBUY_MIN = 5 * 10**(BNB_DECIMALS - 2);
    uint256 private constant JACKPOT_MINBUY_MAX = 5 * 10**(BNB_DECIMALS - 1);

    uint256 private constant JACKPOT_CASHOUT_MIN = 400;
    uint256 private constant JACKPOT_CASHOUT_MAX = 7000;

    uint256 private constant JACKPOT_BIGBANG_BUYBACK_MIN = 300;
    uint256 private constant JACKPOT_BIGBANG_BUYBACK_MAX = 7000;

    string private constant _name = "Chungus GirL";
    string private constant _symbol = "CGirL";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 10000000 * 10**_decimals;

    // Max wallet size initially set to 100%
    uint256 public maxWalletSize = _tTotal;

    // Buy fees
    // marketing
    uint256 public bMarketingFee = 600;
    // jackpot
    uint256 public bJackpotFee = 400;

    // Sell fees
    // marketing
    uint256 public sMarketingFee = 600;
    // jackpot
    uint256 public sJackpotFee = 400;

    // Fee variables for cross-method usage
    uint256 private _marketingFee = 0;
    uint256 private _jackpotFee = 0;

    // Token distribution held by the contract
    uint256 private _marketingTokens = 0;
    uint256 private _jackpotTokens = 0;

    // Jackpot related variables
    // 55.55% jackpot cashout to last buyer
    uint256 public jackpotCashout = 5555;
    // 90% of jackpot cashout to last buyer
    uint256 public jackpotBuyerShare = 9000;
    // Buys > 0.1 BNB will be eligible for the jackpot
    uint256 public jackpotMinBuy = 100000000000000000;
    // Jackpot time span is initially set to 15 mins
    uint256 public jackpotTimespan = 900;
    // Jackpot hard limit, BNB value
    uint256 public jackpotHardLimit = 4000000000000000000;
    // Jackpot hard limit buyback share
    uint256 public jackpotHardBuyback = 5000;

    address payable private _lastBuyer = payable(address(this));
    uint256 private _lastBuyTimestamp = 0;

    address private _lastAwarded = address(0);
    uint256 private _lastAwardedCash = 0;
    uint256 private _lastAwardedTokens = 0;
    uint256 private _lastAwardedTimestamp = 0;

    uint256 private _lastBigBangCash = 0;
    uint256 private _lastBigBangTokens = 0;
    uint256 private _lastBigBangTimestamp = 0;

    // The minimum transaction limit that can be set is 0.1% of the total supply
    uint256 private constant MIN_TX_LIMIT = 10;
    // Initially, max TX amount is set to the total supply
    uint256 public maxTxAmount = _tTotal;

    uint256 public numTokensSellToAddToLiquidity = 55000000000000;

    // Pending balances (BNB) ready to be collected
    uint256 private _pendingMarketingBalance = 0;
    uint256 private _pendingJackpotBalance = 0;

    // Total BNB/LAS collected by various mechanisms (marketing, jackpot)
    uint256 private _totalMarketingFeesCollected = 0;
    uint256 private _totalJackpotCashedOut = 0;
    uint256 private _totalJackpotTokensOut = 0;
    uint256 private _totalJackpotBuyer = 0;
    uint256 private _totalJackpotBuyback = 0;
    uint256 private _totalJackpotBuyerTokens = 0;
    uint256 private _totalJackpotBuybackTokens = 0;

    bool public tradingOpen = false;
    bool public swapAndLiquifyEnabled = true;
    bool private _inSwapAndLiquify;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiquidity
    );
    event MarketingFeesCollected(uint256 bnbCollected);
    event JackpotAwarded(
        uint256 cashedOut,
        uint256 tokensOut,
        uint256 buyerShare,
        uint256 tokensToBuyer,
        uint256 toBuyback,
        uint256 tokensToBuyback
    );
    event BigBang(uint256 cashedOut, uint256 tokensOut);

    event BuyFeesChanged(
        uint256 marketingFee,
        uint256 jackpotFee
    );

    event SellFeesChanged(
        uint256 marketingFee,
        uint256 jackpotFee
    );

    event JackpotFeaturesChanged(
        uint256 jackpotCashout,
        uint256 jackpotBuyerShare,
        uint256 jackpotMinBuy
    );

    event JackpotTimespanChanged(uint256 jackpotTimespan);

    event MaxTransferAmountChanged(uint256 maxTxAmount);

    event MaxWalletSizeChanged(uint256 maxWalletSize);

    event TokenToSellOnSwapChanged(uint256 numTokens);

    event BigBangFeaturesChanged(
        uint256 jackpotHardBuyback,
        uint256 jackpotHardLimit
    );

    event JackpotFund(uint256 bnbSent, uint256 tokenAmount);

    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    constructor(address cOwner) Ownable(cOwner) {
        _tOwned[cOwner] = _tTotal;

        uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );

        // Exclude system addresses from fee
        _isExcludedFromFee.add(owner());
        _isExcludedFromFee.add(address(this));

        _isExcludedFromSwapAndLiquify.add(uniswapV2Pair);

        emit Transfer(address(0), cOwner, _tTotal);
    }

    receive() external payable {}

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        approve(_msgSender(), spender, amount);
        return true;
    }

    function approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        transfer(sender, recipient, amount);
        approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalMarketingFeesCollected()
        external
        view
        onlyMarketing
        returns (uint256)
    {
        return _totalMarketingFeesCollected;
    }


    function totalJackpotOut() external view returns (uint256, uint256) {
        return (_totalJackpotCashedOut, _totalJackpotTokensOut);
    }

    function totalJackpotBuyer() external view returns (uint256, uint256) {
        return (_totalJackpotBuyer, _totalJackpotBuyerTokens);
    }

    function totalJackpotBuyback() external view returns (uint256, uint256) {
        return (_totalJackpotBuyback, _totalJackpotBuybackTokens);
    }

    function excludeFromFee(address account) public onlyAuthorized {
        _isExcludedFromFee.add(account);
    }

    function includeInFee(address account) public onlyAuthorized {
        _isExcludedFromFee.remove(account);
    }

    function setBuyFees(
        uint256 marketingFee,
        uint256 jackpotFee
    ) external onlyAuthorized {
        require(
            marketingFee.add(jackpotFee) <=
                TOTAL_FEES_LIMIT,
            "Total fees can not exceed the declared limit"
        );
        bMarketingFee = marketingFee;
        bJackpotFee = jackpotFee;
        emit BuyFeesChanged(bMarketingFee, bJackpotFee);
    }

    function getBuyTax() public view returns (uint256) {
        return bMarketingFee.add(bJackpotFee);
    }

    function setSellFees(
        uint256 marketingFee,
        uint256 jackpotFee
    ) external onlyAuthorized {
        require(
            marketingFee.add(jackpotFee) <=
                TOTAL_FEES_LIMIT,
            "Total fees can not exceed the declared limit"
        );
        sMarketingFee = marketingFee;
        sJackpotFee = jackpotFee;

        emit SellFeesChanged(
            sMarketingFee,
            sJackpotFee
        );
    }

    function getSellTax() public view returns (uint256) {
        return sMarketingFee.add(sJackpotFee);
    }

    function setJackpotFeatures(
        uint256 _jackpotCashout,
        uint256 _jackpotBuyerShare,
        uint256 _jackpotMinBuy
    ) external onlyAuthorized {
        require(
            _jackpotCashout >= JACKPOT_CASHOUT_MIN &&
                _jackpotCashout <= JACKPOT_CASHOUT_MAX,
            "Jackpot cashout percentage needs to be between 40% and 70%"
        );
        require(
            _jackpotBuyerShare >= JACKPOT_BUYER_SHARE_MIN &&
                _jackpotBuyerShare <= JACKPOT_BUYER_SHARE_MAX,
            "Jackpot buyer share percentage needs to be between 50% and 100%"
        );
        require(
            _jackpotMinBuy >= JACKPOT_MINBUY_MIN &&
                _jackpotMinBuy <= JACKPOT_MINBUY_MAX,
            "Jackpot min buy needs to be between 0.05 and 0.5 BNB"
        );
        jackpotCashout = _jackpotCashout;
        jackpotBuyerShare = _jackpotBuyerShare;
        jackpotMinBuy = _jackpotMinBuy;

        emit JackpotFeaturesChanged(
            jackpotCashout,
            jackpotBuyerShare,
            jackpotMinBuy
        );
    }

    function setJackpotHardFeatures(
        uint256 _jackpotHardBuyback,
        uint256 _jackpotHardLimit
    ) external onlyAuthorized {
        require(
            _jackpotHardBuyback >= JACKPOT_BIGBANG_BUYBACK_MIN &&
                _jackpotHardBuyback <= JACKPOT_BIGBANG_BUYBACK_MAX,
            "Jackpot hard buyback percentage needs to be between 30% and 70%"
        );
        jackpotHardBuyback = _jackpotHardBuyback;

        uint256 hardLimitUsd = usdEquivalent(_jackpotHardLimit);
        require(
            hardLimitUsd >= JACKPOT_BIGBANG_MIN &&
                hardLimitUsd <= JACKPOT_BIGBANG_MAX,
            "Jackpot hard value limit for the big bang needs to be between 30K and 250K USD"
        );
        jackpotHardLimit = _jackpotHardLimit;

        emit BigBangFeaturesChanged(jackpotHardBuyback, jackpotHardLimit);
    }

    function setJackpotTimespanInSeconds(uint256 _jackpotTimespan)
        external
        onlyAuthorized
    {
        require(
            _jackpotTimespan >= JACKPOT_TIMESPAN_LIMIT_MIN &&
                _jackpotTimespan <= JACKPOT_TIMESPAN_LIMIT_MAX,
            "Jackpot timespan needs to be between 30 and 1200 seconds (20 minutes)"
        );
        jackpotTimespan = _jackpotTimespan;

        emit JackpotTimespanChanged(jackpotTimespan);
    }

    function setMaxTxAmount(uint256 txAmount) external onlyAuthorized {
        require(
            txAmount >= _tTotal.mul(MIN_TX_LIMIT).div(MAX_PCT),
            "Maximum transaction limit can't be less than 0.1% of the total supply"
        );
        maxTxAmount = txAmount;

        emit MaxTransferAmountChanged(maxTxAmount);
    }

    function setMaxWallet(uint256 amount) external onlyAuthorized {
        require(
            amount >= _tTotal.div(1000),
            "Max wallet size must be at least 0.1% of the total supply"
        );
        maxWalletSize = amount;

        emit MaxWalletSizeChanged(maxWalletSize);
    }

    function setNumTokensSellToAddToLiquidity(uint256 numTokens)
        external
        onlyAuthorized
    {
        numTokensSellToAddToLiquidity = numTokens;

        emit TokenToSellOnSwapChanged(numTokensSellToAddToLiquidity);
    }

    function fundJackpot(uint256 tokenAmount) external payable onlyAuthorized {
        require(
            balanceOf(msg.sender) >= tokenAmount,
            "You don't have enough tokens to fund the jackpot"
        );
        uint256 bnbSent = msg.value;
        _pendingJackpotBalance = _pendingJackpotBalance.add(bnbSent);
        if (tokenAmount > 0) {
            transferBasic(msg.sender, address(this), tokenAmount);
            _jackpotTokens = _jackpotTokens.add(tokenAmount);
        }
        emit JackpotFund(bnbSent, tokenAmount);
    }

    function isJackpotEligible(uint256 tokenAmount) public view returns (bool) {
        if (jackpotMinBuy == 0) {
            return true;
        }
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uint256 tokensOut = uniswapV2Router
        .getAmountsOut(jackpotMinBuy, path)[1].mul(MAX_PCT.sub(ROUTER_FEE)).div(
                // We don't subtract the buy fee since the tokenAmount is pre-tax
                MAX_PCT
            );
        return tokenAmount >= tokensOut;
    }

    function usdEquivalent(uint256 bnbAmount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = USDT;

        return uniswapV2Router.getAmountsOut(bnbAmount, path)[1];
    }

    function getUsedTokens(
        uint256 accSum,
        uint256 tokenAmount,
        uint256 tokens
    ) private pure returns (uint256, uint256) {
        if (accSum >= tokenAmount) {
            return (0, accSum);
        }
        uint256 available = tokenAmount - accSum;
        if (tokens <= available) {
            return (tokens, accSum.add(tokens));
        }
        return (available, accSum.add(available));
    }

    function getTokenShares(uint256 tokenAmount)
        private
        returns (
            uint256,
            uint256
        )
    {
        uint256 accSum = 0;
        uint256 marketingTokens = 0;
        uint256 jackpotTokens = 0;

        (marketingTokens, accSum) = getUsedTokens(
            accSum,
            tokenAmount,
            _marketingTokens
        );
        _marketingTokens = _marketingTokens.sub(marketingTokens);

        (jackpotTokens, accSum) = getUsedTokens(
            accSum,
            tokenAmount,
            _jackpotTokens
        );
        _jackpotTokens = _jackpotTokens.sub(jackpotTokens);

        return (marketingTokens, jackpotTokens);
    }

    function setSwapAndLiquifyEnabled(bool enabled) public onlyOwner {
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee.contains(account);
    }

    function isExcludedFromSwapAndLiquify(address account)
        public
        view
        returns (bool)
    {
        return _isExcludedFromSwapAndLiquify.contains(account);
    }

    function includeFromSwapAndLiquify(address account) external onlyOwner {
        _isExcludedFromSwapAndLiquify.remove(account);
    }

    function excludeFromSwapAndLiquify(address account) external onlyOwner {
        _isExcludedFromSwapAndLiquify.add(account);
    }

    function setUniswapRouter(address otherRouterAddress) external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(otherRouterAddress);
    }

    function setUniswapPair(address otherPairAddress) external onlyOwner {
        require(
            otherPairAddress != address(0),
            "You must supply a non-zero address"
        );
        uniswapV2Pair = otherPairAddress;
    }

    function transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != owner() && to != owner()) {
            require(
                amount <= maxTxAmount,
                "Transfer amount exceeds the maxTxAmount"
            );
        }

        if (!authorizations[from] && !authorizations[to]) {
            require(tradingOpen, "Trading is currently not open");
        }

        // Jackpot mechanism locks the swap if triggered. We should handle it as
        // soon as possible so that we could award the jackpot on a sell and on a buy
        if (!_inSwapAndLiquify && _pendingJackpotBalance >= jackpotHardLimit) {
            processBigBang();
        } else if (
            // We can't award the jackpot in swap and liquify
            // Pending balances need to be untouched (externally) for swaps
            !_inSwapAndLiquify &&
            _lastBuyer != address(0) &&
            _lastBuyer != address(this) &&
            block.timestamp.sub(_lastBuyTimestamp) >= jackpotTimespan
        ) {
            awardJackpot();
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= maxTxAmount) {
            contractTokenBalance = maxTxAmount;
        }

        bool isOverMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            isOverMinTokenBalance &&
            !_inSwapAndLiquify &&
            !_isExcludedFromSwapAndLiquify.contains(from) &&
            swapAndLiquifyEnabled
        ) {
            swapAndLiquify(numTokensSellToAddToLiquidity);
        }

        bool takeFee = true;
        if (
            _isExcludedFromFee.contains(from) ||
            _isExcludedFromFee.contains(to) ||
            (uniswapV2Pair != from && uniswapV2Pair != to)
        ) {
            takeFee = false;
        }

        tokenTransfer(from, to, amount, takeFee);
    }

    function enableTrading(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    function collectMarketingFees() public onlyMarketing {
        _totalMarketingFeesCollected = _totalMarketingFeesCollected.add(
            _pendingMarketingBalance
        );
        marketingWallet().transfer(_pendingMarketingBalance);
        emit MarketingFeesCollected(_pendingMarketingBalance);
        _pendingMarketingBalance = 0;
    }


    function getJackpot() public view returns (uint256, uint256) {
        return (_pendingJackpotBalance, _jackpotTokens);
    }

    function jackpotBuyerShareAmount() public view returns (uint256, uint256) {
        uint256 bnb = _pendingJackpotBalance
            .mul(jackpotCashout)
            .div(MAX_PCT)
            .mul(jackpotBuyerShare)
            .div(MAX_PCT);
        uint256 tokens = _jackpotTokens
            .mul(jackpotCashout)
            .div(MAX_PCT)
            .mul(jackpotBuyerShare)
            .div(MAX_PCT);
        return (bnb, tokens);
    }

    function jackpotBuybackAmount() public view returns (uint256, uint256) {
        uint256 bnb = _pendingJackpotBalance
            .mul(jackpotCashout)
            .div(MAX_PCT)
            .mul(MAX_PCT.sub(jackpotBuyerShare))
            .div(MAX_PCT);
        uint256 tokens = _jackpotTokens
            .mul(jackpotCashout)
            .div(MAX_PCT)
            .mul(MAX_PCT.sub(jackpotBuyerShare))
            .div(MAX_PCT);

        return (bnb, tokens);
    }

    function getLastBuy() public view returns (address, uint256) {
        return (_lastBuyer, _lastBuyTimestamp);
    }

    function getLastAwarded()
        public
        view
        returns (
            address,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _lastAwarded,
            _lastAwardedCash,
            _lastAwardedTokens,
            _lastAwardedTimestamp
        );
    }

    function getLastBigBang()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (_lastBigBangCash, _lastBigBangTokens, _lastBigBangTimestamp);
    }

    function getPendingBalances()
        public
        view
        onlyAuthorized
        returns (
            uint256,
            uint256
        )
    {
        return (
            _pendingMarketingBalance,
            _pendingJackpotBalance
        );
    }

    function getPendingTokens()
        public
        view
        onlyAuthorized
        returns (
            uint256,
            uint256
        )
    {
        return (_marketingTokens, _jackpotTokens);
    }

    function processBigBang() private lockTheSwap {
        uint256 cashedOut = _pendingJackpotBalance.mul(jackpotHardBuyback).div(
            MAX_PCT
        );
        uint256 tokensOut = _jackpotTokens.mul(jackpotHardBuyback).div(MAX_PCT);

        buybackWallet().transfer(cashedOut);
        transferBasic(address(this), buybackWallet(), tokensOut);
        emit BigBang(cashedOut, tokensOut);

        _lastBigBangCash = cashedOut;
        _lastBigBangTokens = tokensOut;
        _lastBigBangTimestamp = block.timestamp;

        _pendingJackpotBalance = _pendingJackpotBalance.sub(cashedOut);
        _jackpotTokens = _jackpotTokens.sub(tokensOut);

        _totalJackpotCashedOut = _totalJackpotCashedOut.add(cashedOut);
        _totalJackpotBuyback = _totalJackpotBuyback.add(cashedOut);
        _totalJackpotTokensOut = _totalJackpotTokensOut.add(tokensOut);
        _totalJackpotBuybackTokens = _totalJackpotBuybackTokens.add(tokensOut);
    }

    function awardJackpot() private lockTheSwap {
        require(
            _lastBuyer != address(0) && _lastBuyer != address(this),
            "No last buyer detected"
        );
        uint256 cashedOut = _pendingJackpotBalance.mul(jackpotCashout).div(
            MAX_PCT
        );
        uint256 tokensOut = _jackpotTokens.mul(jackpotCashout).div(MAX_PCT);
        uint256 buyerShare = cashedOut.mul(jackpotBuyerShare).div(MAX_PCT);
        uint256 tokensToBuyer = tokensOut.mul(jackpotBuyerShare).div(MAX_PCT);
        uint256 toBuyback = cashedOut - buyerShare;
        uint256 tokensToBuyback = tokensOut - tokensToBuyer;
        _lastBuyer.transfer(buyerShare);
        transferBasic(address(this), _lastBuyer, tokensToBuyer);
        buybackWallet().transfer(toBuyback);
        transferBasic(address(this), buybackWallet(), tokensToBuyback);

        _pendingJackpotBalance = _pendingJackpotBalance.sub(cashedOut);
        _jackpotTokens = _jackpotTokens.sub(tokensOut);

        emit JackpotAwarded(
            cashedOut,
            tokensOut,
            buyerShare,
            tokensToBuyer,
            toBuyback,
            tokensToBuyback
        );

        _lastAwarded = _lastBuyer;
        _lastAwardedTimestamp = block.timestamp;
        _lastAwardedCash = buyerShare;
        _lastAwardedTokens = tokensToBuyer;

        _lastBuyer = payable(address(this));
        _lastBuyTimestamp = 0;

        _totalJackpotCashedOut = _totalJackpotCashedOut.add(cashedOut);
        _totalJackpotTokensOut = _totalJackpotTokensOut.add(tokensOut);
        _totalJackpotBuyer = _totalJackpotBuyer.add(buyerShare);
        _totalJackpotBuyerTokens = _totalJackpotBuyerTokens.add(tokensToBuyer);
        _totalJackpotBuyback = _totalJackpotBuyback.add(toBuyback);
        _totalJackpotBuybackTokens = _totalJackpotBuybackTokens.add(
            tokensToBuyback
        );
    }

    function swapAndLiquify(uint256 tokenAmount) private lockTheSwap {
        (
            uint256 marketingTokens,
            uint256 jackpotTokens
        ) = getTokenShares(tokenAmount);
        uint256 tokensForBnbExchange = marketingTokens.add(jackpotTokens);
 
        uint256 initialBalance = address(this).balance;
        swapTokensForBnb(tokensForBnbExchange);

        // How many BNBs did we gain after this conversion?
        uint256 gainedBnb = address(this).balance.sub(initialBalance);

        // Calculate the amount of BNB that's assigned to the marketing wallet
        uint256 balanceToMarketing = gainedBnb.mul(marketingTokens).div(
            tokensForBnbExchange
        );
        _pendingMarketingBalance += balanceToMarketing;

        // Same for Jackpot
        uint256 balanceToJackpot = gainedBnb.mul(jackpotTokens).div(
            tokensForBnbExchange
        );
        _pendingJackpotBalance += balanceToJackpot;

    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) {
            // If we're here, it means either the sender or recipient is excluded from taxes
            // Also, it could be that this is just a transfer of tokens between wallets
            _marketingFee = 0;
            _jackpotFee = 0;
        } else if (recipient == uniswapV2Pair) {
            // This is a sell
            _marketingFee = sMarketingFee;
            _jackpotFee = sJackpotFee;
        } else {
            // If we're here, it must mean that the sender is the uniswap pair
            // This is a buy
            if (isJackpotEligible(amount)) {
                _lastBuyTimestamp = block.timestamp;
                _lastBuyer = payable(recipient);
            }

            _marketingFee = bMarketingFee;
            _jackpotFee = bJackpotFee;
        }

        transferStandard(sender, recipient, amount);
    }

    function transferBasic(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(amount);
        _tOwned[recipient] = _tOwned[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 tTransferAmount,
            uint256 tMarketing,
            uint256 tJackpot
        ) = processAmount(tAmount);
        uint256 tFees = tMarketing.add(tJackpot);
        if (recipient != uniswapV2Pair && recipient != DEAD) {
            require(
                isExcludedFromFee(recipient) ||
                    balanceOf(recipient).add(tTransferAmount) <= maxWalletSize,
                "Transfer amount will push this wallet beyond the maximum allowed size"
            );
        }

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);

        takeTransactionFee(address(this), tFees);
        _marketingTokens += tMarketing;
        _jackpotTokens += tJackpot;

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function processAmount(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tMarketing = tAmount.mul(_marketingFee).div(MAX_PCT);
        uint256 tJackpot = tAmount.mul(_jackpotFee).div(MAX_PCT);
        uint256 tTransferAmount = tAmount.sub(tMarketing.add(tJackpot));
        return (tTransferAmount, tMarketing, tJackpot);
    }

    function takeTransactionFee(address to, uint256 tAmount) private {
        if (tAmount <= 0) {
            return;
        }
        _tOwned[to] = _tOwned[to].add(tAmount);
    }
}