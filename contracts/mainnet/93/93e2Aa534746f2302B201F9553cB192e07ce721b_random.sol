/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

pragma solidity ^0.5.0 || ^0.6.0;
// pragma experimental ABIEncoderV2;

contract Governance {

    address public _governance;

    constructor() public {
        _governance = tx.origin;
    }

    event GovernanceTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyGovernance {
        require(msg.sender == _governance, "not governance");
        _;
    }

    function setGovernance(address governance)  public  onlyGovernance
    {
        require(governance != address(0), "new governance the zero address");
        emit GovernanceTransferred(_governance, governance);
        _governance = governance;
    }


}


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SafeERC20: TRANSFER_FAILED');
    }
    // function safeTransfer(IERC20 token, address to, uint256 value) internal {
    //     callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    // }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following 
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address account, uint amount) external;
    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
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
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

interface IUniswapV2Pair {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}


interface nfttoken {
    function mint(
        address _to,
        bool male,
        uint meta,
        string calldata  param1,
        string calldata  param2,
        string calldata  param3,
        string calldata _uri
    )   external;
}


contract random is Governance {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address  usdtToken = 0x55d398326f99059fF775485246999027B3197955; 
    address public  stakeToken = 0x55d398326f99059fF775485246999027B3197955;    //todo
    address public  withdrawAddr = 0xbe4597846836E6872eA85467992CCb8efCC756ce;    //todo
    address public _nfttoken = 0xF93c5D229796D013e39f7a75f9f437627efdb0d0;  //todo
    IERC20 public uniswapV2Pair;
    
    uint[] public typeRate =[3000,6000,9000,9500];
    string[][] public urls = [["QmUK8bgSSVDueJU98zpATuURqm7CLgsjwj4LNLMvj1HZoG","QmYVymzpdr7MeHTwvD7Zavv62VeSasxwG9xWZ7RViYFAuL"
                            ,"QmUVqHz562ycU6TB1Xg4YmdeaLTYrm6BhDfrPoMv2d3AXV","QmW39ko7qD2QiJ2TZtyM9wwCXaoHXrDQ6hkHVXuHiijRPn",
                            "QmWSjxRvL5WHsVuVRSFVRQN8xnhjc9QvRgjV3zmVVNVhfC","QmReuDvC5wgDurXTddyEnt1vvG6pZgVt4FZMFPHDcL7q1m",
                            "QmUQgkZp3yf91RaJdvK5wpPbUrjjNJwVyscPaHgsYt46qo","QmaTSWrkHQZtoPEX3sQdZW5sFLqWgDjSYffQhoSXZGKy2q"],
                            ["QmV6g93m2A9nXJX2jbUausATtvyyr8joqNUj2XXbztUy7n","QmeWuwYkpJoFCzx4LcXKgMpz23xc3RRketB4aTt1ayA43c",
                            "QmbZ4AiLz1AjSrVvo3Afdxa284A5E5R6F1E3YiLCt28kVt","QmQv9T4JAiUc7mrEB2PXWSAhiL9eBA5DZYjSLHBN7yn1mC",
                            "QmaGQfupesmKb86gHqnJQwSSQL9HWbYtRKEujVipJtF1zz","QmQ5rAVFLVnLXYLdar56qVcoPW4bNcgBG44HHsrXXRAgEm",
                            "QmQXig9ZPggjkoL1zfKPcNPjw61E1wpGzwKUmQj81kRMFT","QmQxjJc4QCM3aeBwSKBsPGf2Apd3R5YiLeEneEvQNRhhSQ"],
                            ["QmUmsxM8yW1giskyfsMuj8arV7yHJnnAW7VeZ74fscDRrH","QmRJ8VfETzCAb2b7SHLKQ4PxK7Tp6DtF83qp6JeTrREUkN",
                            "QmUyULUs1HipCdLnreYKvNi7vnQ1GqBZWykMtowC6zn4uf","QmW6qbPgP5GyBn8kRxMDgpz6Cq4Tq3fiP3wz9UpE9b9HEg",
                            "QmRXC64MfpGetWk2KMWMdCpdJrbzKMFLw6YSAAbbSSnsWn","QmX8gUbMwjYdcpkbxpV1HwiugcQzeCdk8TrA7kk2KA7rMB",
                            "QmeUFqdNVtKmaDoTSgYSubXmtTL3ykqUpQpYTYp7xv84b9","QmcDkKyfMnTRyD5QoRX9Qpb816wpdjRFn1N8ic7VoZibSm"],
                            ["QmUznb8u2y7PPA8oABQsXYchQ76iYiEHZ1Dhb9yxYCe1am","QmWAiWKgGSwYivuC8DXbHmTFCNEefTDfaTGP2dzGWfFYqk",
                            "QmfZez6LwCYEigP2WQkuqvpW7JkTojvCLLsKZEdRrosSEA","QmUzca955BbiGMbWpEoHiRxEwm85jKtw8iLUAtPymtDLV1",
                            "QmTQhXwFg2owjXtHZmrsQThsN5tut58Gp1y8wvtDQeKdWb","QmNoXmCGYYjWDb73xg4zS7EQhhjbccMAjkMvcoqDvabxu1",
                            "QmcjSQnaJJqXrXqh84Xpz4QqKGJnnDwz8HAoJgWbzrnx5W","QmTHeQ3HCvu7JG4Q8KU4MFGDHa1zYyCotSCPshzzYwPGbj"],
                            ["QmcufUThquBPFDLpxgoUQJxFxHWuPYKDqnftzzPYHqAEkV","QmNz9tBzm9WVNSyAyzxb6tagNt9hoxFcZxSfyfTe6w5xLV",
                            "QmUUTCXpufnyCHg9QXyP3GVz1yZha7A5wZrWUAbhGZzon9","QmWimnHXvg6432ym8knHbJwrUsb4wRuM6i8py5z2PGdH69",
                            "QmQN5HYkUyWGmnHugYaTPcTWSvzFLayhdSKp9wgMEjcJRG","QmUh18uZMkicx3uoE66h2eXe1X6jnchrUYFTghTbLk46FZ",
                            "QmZL7Z3VFnZbkrZ6hvhdkpZH7BUinwwEi5V1zKTqPYoTzW","QmTDSSNpqGJgZDZt1MWyG2Ax2g3hyTgC4332nAUJLbFrXy"]];

    string[] public param1 = ["9100006,10000066,1,1,2","9100013,10000067,1,1,2","9100021,10000067,1,1,2","9100018,10000066,1,1,2",
                                "9100022,10000065,1,1,2","9100029,10000065,1,1,2","9100027,10000066,1,1,2","9100024,10000067,1,1,2"];
    string[] public param2 = ["12,1246,ss,74,ss,180,ss,96,ss,0.12,ss,1.51,ss,0.64,ss,ss","8,954,ss,119,ss,143,ss,187,ss,0.18,ss,1.55,ss,0.93,ss,ss",
                                "8,990,ss,126,ss,130,ss,190,ss,0.18,ss,1.55,ss,0.93,ss,ss","12,1190,ss,72,ss,189,ss,100,ss,0.12,ss,1.53,ss,0.64,ss,ss",
                                "8,815,ss,208,ss,98,ss,138,ss,0.34,ss,1.67,ss,0.71,ss,ss","8,759,ss,198,ss,88,s,192,ss,0.34,ss,1.66,ss,0.70,ss,ss",
                                "12,1200,ss,71,ss,193,ss,96,ss,0.12,ss,1.51,ss,0.64,ss,ss","8,969,ss,118,ss,143,ss,184,ss,0.18,ss,1.55,ss,0.92,ss,ss"];
    string[][] public param3 = [["H061,1000541,8102202,8108006,0,1,10000071","H131,1000801,8133002,8114006,0,1,10000071","H211,1000701,8102002,8113006,0,1,10000071",
                                "H181,1001041,8102102,8108006,0,1,10000071","H221,1000903,8102002,8101006,0,1,10000071","H291,1001207,8104002,8117206,0,1,10000071",
                                "H271,1000641,8102102,8108006,0,1,10000071","H241,1000701,8133002,8113006,0,1,10000071"],
                                ["M061,1000541,8109012,8108006,0,2,10000071","M131,1000801,8119002,8114006,0,2,10000071","M211,1000701,8102002,8112006,0,2,10000071",
                                "M181,1001041,8127002,8108006,0,2,10000071","M221,1000904,8102002,8101006,0,2,10000071","M291,1001207,8103002,8117206,0,2,10000071",
                                "M271,1000641,8127002,8108006,0,2,10000071","M241,1000701,8102002,8111006,0,2,10000071"],
                                ["S061,1000541,8109022,8108006,0,3,10000071","S131,1000801,8118002,8114006,0,3,10000071","S211,1000701,8102002,8110006,0,3,10000071",
                                "S181,1001041,8109022,8108006,0,3,10000071","S221,1000906,8102002,8101006,0,3,10000071","S291,1001207,8102002,8117206,0,3,10000071",
                                "S271,1000641,8102202,8108006,0,3,10000071","S241,1000701,8116002,8112006,0,3,10000071"],
                                ["G061,1000541,8109023,8108007,8204003,4,10000072","G131,1000801,8117003,8114007,8203003,4,10000072","G211,1000701,8102003,8112007,8205003,4,10000072",
                                "G181,1001041,8102203,8108007,8204003,4,10000072","G221,1000910,8102003,8101007,8205003,4,10000072","G291,1001207,8103003,8117207,8207003,4,10000072",
                                "G271,1000641,8109013,8108007,8204003,4,10000072","G241,1000701,8120007,8115007,8207003,4,10000072"],
                                ["A061,1000541,8127003,8108007,8205003,5,10000072","A131,1000801,8120007,8114007,8206003,5,10000072","A211,1000701,8102003,8113007,8206003,5,10000072",
                                "A181,1001041,8127003,8108007,8203003,5,10000072","A221,1000902,8102003,8101007,8206003,5,10000072","A291,1001207,8104003,8117207,8207003,5,10000072",
                                "A271,1000641,8109013,8108007,8203003,5,10000072","A241,1000701,8119003,8113007,8206003,5,10000072"]];


    string[] public param4 = ["QmUiExxsDhH1DBq4CGcX364nD4UaohBYcbKmVzPD2FjVhs","3000114,10000067,1,1,2","8,1083,SS,140,SS,135,SS,154,SS,0.19,SS,1.56,SS,0.93,SS,ss","G311,1002539,8121033,8135003,8213003,4,10000072"];

    string[] public param5 = ["QmSBPcyuexhykVAMwj1BNdwXE5kbohqQPXRDgxLanGh2ZP","3000115,10000067,1,1,2","8,1011,SS,155,SS,126,SS,160,SS,0.19,SS,1.58,SS,0.92,SS,ss","A311,1002538,8102083,8136003,8213003,5,10000072"];


    mapping(address => bool) public whitelist;
    uint public desNum2 = 118*1e15;                                           //todo 
    uint public desNum5 = 295*1e15;                                           //todo 

    uint randomNumber;

     constructor () public {
        //   address token0 = IUniswapV2Pair(address(_uniswapV2Pair)).token0();
        // (uint r0,uint r1,) = IUniswapV2Pair(address(_uniswapV2Pair)).getReserves();
        // uint salt = usdtToken == token0?r0.mul(1000).div(r1):r1.mul(1000).div(r0);
         randomNumber = getRandom4RepeatHash(0)%1000000;
    }

     function getRandom(uint num) external {
        require(num == 2|| num == 5,"num");
        require(whitelist[msg.sender] ,"white list");
        whitelist[msg.sender] = false;

        uint price;
        if(num == 2)
        {
            price = desNum2;
        }else if(num == 5)
        {
            price = desNum5;
        }

        IERC20(stakeToken).safeTransferFrom(msg.sender,address(this),price);
        IERC20(stakeToken).safeTransfer(withdrawAddr,price);

        for(uint i=0;i<num;i++)
        {
            bool male = randomNumber.mod(2)==0;
            uint rannum = randomNumber.mod(10000);
            uint _parame = randomNumber.mod(8);
            uint _meta;
            bool lightcat = false;
            bool darkcat = false;

            if(rannum<typeRate[0])
            {
                _meta = 1;
            }else if(rannum<typeRate[1])
            {
                _meta =2;
            }else if(rannum<typeRate[2])
            {
                _meta =3;
            }else if(rannum<typeRate[3])
            {
                _meta =4;
                lightcat = randomNumber.mod(9) == 8;
            }else{
                _meta = 5;
                darkcat = randomNumber.mod(9) == 8;
            }

            if(lightcat)
            {
                nfttoken(_nfttoken).mint(msg.sender,male,_meta,param4[1],param4[2],param4[3],param4[0]);
            }else if(darkcat)
            {
                nfttoken(_nfttoken).mint(msg.sender,male,_meta,param5[1],param5[2],param5[3],param5[0]);
            }else{
                nfttoken(_nfttoken).mint(msg.sender,male,_meta,param1[_parame],param2[_parame],param3[_meta][_parame],urls[_meta][_parame]);
            }

            randomNumber = randomNumber>>8;
        }

        randomNumber = getRandom4RepeatHash(randomNumber)%1000000;
        
    }

    
    function withdraw( uint num) external onlyGovernance {
        IERC20(stakeToken).safeTransfer(msg.sender,num);
    }
    
    
    function setDesNum2( uint _desNum) external onlyGovernance {
        desNum2 = _desNum;
    }

    function setDesNum5( uint _desNum) external onlyGovernance {
        desNum5 = _desNum;
    }
    
    function setWithdrawAddr( address _withdrawAddr) external onlyGovernance {
        withdrawAddr = _withdrawAddr;
    }

    function addWhitelist( address[] calldata newlist) external onlyGovernance {
         for(uint i=0;i<newlist.length;i++){
             whitelist[newlist[i]] = true;
         }
        
    }

    
    function getRandom4RepeatHash(uint256 salt) public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        keccak256(
                            abi.encodePacked(
                                block.timestamp,
                                block.difficulty,
                                block.coinbase,
                                msg.sender,
                                salt
                            )
                        )
                    )
                )
            );
    }
}