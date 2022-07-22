/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-25
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
    address public  stakeToken;
    address public  withdrawAddr;
    address public _nfttoken = 0xeF72810496b5A4a76eaa1Fd940Fb09D1e36E75e8;  //todo
    IERC20 public uniswapV2Pair;
    
    uint[] public typeRate =[3300,6600,9900,9950];
    string[][] public urls = [["QmUK8bgSSVDueJU98zpATuURqm7CLgsjwj4LNLMvj1HZoG","QmYVymzpdr7MeHTwvD7Zavv62VeSasxwG9xWZ7RViYFAuL"
                            ,"QmUVqHz562ycU6TB1Xg4YmdeaLTYrm6BhDfrPoMv2d3AXV","QmW39ko7qD2QiJ2TZtyM9wwCXaoHXrDQ6hkHVXuHiijRPn",
                            "QmWSjxRvL5WHsVuVRSFVRQN8xnhjc9QvRgjV3zmVVNVhfC","QmReuDvC5wgDurXTddyEnt1vvG6pZgVt4FZMFPHDcL7q1m",
                            "QmUQgkZp3yf91RaJdvK5wpPbUrjjNJwVyscPaHgsYt46qo","QmaTSWrkHQZtoPEX3sQdZW5sFLqWgDjSYffQhoSXZGKy2q",
                            "QmZ8pi5LrtMWG5u9L47fFZL8oE5cZ4EYc1SFB7iWsdXSpo"],
                            ["QmV6g93m2A9nXJX2jbUausATtvyyr8joqNUj2XXbztUy7n","QmeWuwYkpJoFCzx4LcXKgMpz23xc3RRketB4aTt1ayA43c",
                            "QmbZ4AiLz1AjSrVvo3Afdxa284A5E5R6F1E3YiLCt28kVt","QmQv9T4JAiUc7mrEB2PXWSAhiL9eBA5DZYjSLHBN7yn1mC",
                            "QmaGQfupesmKb86gHqnJQwSSQL9HWbYtRKEujVipJtF1zz","QmQ5rAVFLVnLXYLdar56qVcoPW4bNcgBG44HHsrXXRAgEm",
                            "QmQXig9ZPggjkoL1zfKPcNPjw61E1wpGzwKUmQj81kRMFT","QmQxjJc4QCM3aeBwSKBsPGf2Apd3R5YiLeEneEvQNRhhSQ",
                            "QmcqcrwVSKhFdppWe4jne56kmZyM1mzXLX442QYtCFzMas"],
                            ["QmUmsxM8yW1giskyfsMuj8arV7yHJnnAW7VeZ74fscDRrH","QmRJ8VfETzCAb2b7SHLKQ4PxK7Tp6DtF83qp6JeTrREUkN",
                            "QmUyULUs1HipCdLnreYKvNi7vnQ1GqBZWykMtowC6zn4uf","QmW6qbPgP5GyBn8kRxMDgpz6Cq4Tq3fiP3wz9UpE9b9HEg",
                            "QmRXC64MfpGetWk2KMWMdCpdJrbzKMFLw6YSAAbbSSnsWn","QmX8gUbMwjYdcpkbxpV1HwiugcQzeCdk8TrA7kk2KA7rMB",
                            "QmeUFqdNVtKmaDoTSgYSubXmtTL3ykqUpQpYTYp7xv84b9","QmcDkKyfMnTRyD5QoRX9Qpb816wpdjRFn1N8ic7VoZibSm",
                            "Qmc7AuhTJETtmmAxGCjTT6dTxtksFA23J2rb2NDtWkWKt6"],
                            ["QmUznb8u2y7PPA8oABQsXYchQ76iYiEHZ1Dhb9yxYCe1am","QmWAiWKgGSwYivuC8DXbHmTFCNEefTDfaTGP2dzGWfFYqk",
                            "QmfZez6LwCYEigP2WQkuqvpW7JkTojvCLLsKZEdRrosSEA","QmUzca955BbiGMbWpEoHiRxEwm85jKtw8iLUAtPymtDLV1",
                            "QmTQhXwFg2owjXtHZmrsQThsN5tut58Gp1y8wvtDQeKdWb","QmNoXmCGYYjWDb73xg4zS7EQhhjbccMAjkMvcoqDvabxu1",
                            "QmcjSQnaJJqXrXqh84Xpz4QqKGJnnDwz8HAoJgWbzrnx5W","QmTHeQ3HCvu7JG4Q8KU4MFGDHa1zYyCotSCPshzzYwPGbj",
                            "QmaxqsABaFzcWQrGJKTm272j1EfGLceRFchtALaJTJVUN9"],
                            ["QmcufUThquBPFDLpxgoUQJxFxHWuPYKDqnftzzPYHqAEkV","QmNz9tBzm9WVNSyAyzxb6tagNt9hoxFcZxSfyfTe6w5xLV",
                            "QmUUTCXpufnyCHg9QXyP3GVz1yZha7A5wZrWUAbhGZzon9","QmWimnHXvg6432ym8knHbJwrUsb4wRuM6i8py5z2PGdH69",
                            "QmQN5HYkUyWGmnHugYaTPcTWSvzFLayhdSKp9wgMEjcJRG","QmUh18uZMkicx3uoE66h2eXe1X6jnchrUYFTghTbLk46FZ",
                            "QmZL7Z3VFnZbkrZ6hvhdkpZH7BUinwwEi5V1zKTqPYoTzW","QmTDSSNpqGJgZDZt1MWyG2Ax2g3hyTgC4332nAUJLbFrXy",
                            "QmV7AHcFvEqNv2BpVVggjAZpstBgkwbHh83BMJV3ww5ktg"]];

    string[][] public param1 = [["0,2000611,H061,1,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2001311,H131,1,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002111,H211,1,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2001811,H181,1,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002211,H221,1,10000065,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002911,H291,1,10000065,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002711,H271,1,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002411,H241,1,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2004311,H100021,1,10000065,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3"],
                            ["0,2000612,M061,2,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2001312,M131,2,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002112,M211,2,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2001812,M181,2,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002212,M221,2,10000065,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002912,M291,2,10000065,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002712,M271,2,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002412,M241,2,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2004611,M100051,2,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3"],
                            ["0,2000613,S061,3,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2001313,S131,3,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002113,S211,3,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2001813,S181,3,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002213,S221,3,10000065,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002913,S291,3,10000065,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002713,S271,3,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002413,S241,3,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2004411,S100031,3,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3"],
                            ["0,2000614,G061,4,10000066,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2001314,G131,4,10000067,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002114,G211,4,10000067,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2001814,G181,4,10000066,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002214,G221,4,10000065,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002914,G291,4,10000065,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002714,G271,4,10000066,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002414,G241,4,10000067,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2004211,G100011,4,10000067,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3"],
                            ["0,2000615,A061,5,10000066,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2001315,A131,5,10000067,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002115,A211,5,10000067,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2001815,A181,5,10000066,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002215,A221,5,10000065,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002915,A291,5,10000065,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002715,A271,5,10000066,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2002415,A241,5,10000067,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                            "0,2004511,A100041,5,10000065,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3"]];
    string[][] public param2 = [["12,1246,SS,74,SS,180,SS,96,SS,0.12,SS,1.51,SS,0.64,SS,SS",
                            "8,954,SS,119,SS,143,SS,187,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "8,990,SS,126,SS,130,SS,190,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "12,1190,SS,72,SS,189,SS,100,SS,0.12,SS,1.53,SS,0.64,SS,SS",
                            "8,815,SS,208,SS,98,SS,138,SS,0.34,SS,1.67,SS,0.71,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,837,SS+3,218,SS+4,95,SS+1,159,SS+2,0.47,SS+3,1.89,SS+4,0.71,SS+2,SS+3"],
                            ["12,1246,SS,74,SS,180,SS,96,SS,0.12,SS,1.51,SS,0.64,SS,SS",
                            "8,954,SS,119,SS,143,SS,187,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "8,990,SS,126,SS,130,SS,190,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "12,1190,SS,72,SS,189,SS,100,SS,0.12,SS,1.53,SS,0.64,SS,SS",
                            "8,815,SS,208,SS,98,SS,138,SS,0.34,SS,1.67,SS,0.71,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "12,1189,SS+7,73,S,184,SS+7,112,SS+4,0.18,SS,1.6,SS,0.64,SS+4,SS+3"],
                            ["12,1246,SS,74,SS,180,SS,96,SS,0.12,SS,1.51,SS,0.64,SS,SS",
                            "8,954,SS,119,SS,143,SS,187,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "8,990,SS,126,SS,130,SS,190,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "12,1190,SS,72,SS,189,SS,100,SS,0.12,SS,1.53,SS,0.64,SS,SS",
                            "8,815,SS,208,SS,98,SS,138,SS,0.34,SS,1.67,SS,0.71,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,899,SS+4,151,SS+4,133,SS+3,216,SS+4,0.25,SS+2,1.67,SS+2,0.93,SS+4,SS+3"],
                            ["12,1246,SS,74,SS,180,SS,96,SS,0.12,SS,1.51,SS,0.64,SS,SS",
                            "8,954,SS,119,SS,143,SS,187,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "8,990,SS,126,SS,130,SS,190,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "12,1190,SS,72,SS,189,SS,100,SS,0.12,SS,1.53,SS,0.64,SS,SS",
                            "8,815,SS,208,SS,98,SS,138,SS,0.34,SS,1.67,SS,0.71,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,889,SS+3,155,SS+4,129,SS+3,216,SS+4,0.25,SS+2,1.67,SS+2,0.93,SS+4,SS+3"],
                            ["12,1246,SS,74,SS,180,SS,96,SS,0.12,SS,1.51,SS,0.64,SS,SS",
                            "8,954,SS,119,SS,143,SS,187,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "8,990,SS,126,SS,130,SS,190,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "12,1190,SS,72,SS,189,SS,100,SS,0.12,SS,1.53,SS,0.64,SS,SS",
                            "8,815,SS,208,SS,98,SS,138,SS,0.34,SS,1.67,SS,0.71,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,795,SS,233,SS+6,85,S,224,SS+13,0.46,SS+1,1.87,SS+2,0.7,SS,SS+3"]];
    string[][] public param3 = [["1002841,0,0,ui_pg_pikan,8302202,2,2,ui_dt_gangyituxi,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003101,0,0,ui_pg_tanshe,8333002,2,2,ui_qt_mengdu,8314006,2,4,ui_qt_mengdu,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8302002,2,2,ui_dt_shandiantuxi,8313006,2,4,ui_qt_yexing,0,0,0,0",
                            "1003341,0,0,ui_pg_yaoshi,8302102,2,2,ui_dt_yingyongtuxi,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003203,0,0,ui_pg_quanji,8302002,2,2,ui_dt_shandiantuxi,8301006,2,4,ui_qt_duci,0,0,0,0",
                            "1003406,0,0,ui_pg_chongzhuang,8304002,2,2,ui_pg_zhuaji,8317006,2,4,ui_qt_shikongtisu,0,0,0,0",
                            "1002941,0,0,ui_pg_touchui,8302102,2,2,ui_dt_yingyongtuxi,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8333002,2,2,ui_qt_mengdu,8313006,2,4,ui_qt_yexing,0,0,0,0",
                            "1003603,0,0,ui_pg_quanji,8304002,2,2,ui_pg_zhuaji,8301006,2,4,ui_qt_duci,0,0,0,0"],
                            ["1002841,0,0,ui_pg_pikan,8309012,2,2,ui_dt_fanzhen,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003101,0,0,ui_pg_tanshe,8319002,2,2,ui_dt_shuairuo,8314006,2,4,ui_qt_mengdu,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8302002,2,2,ui_dt_shandiantuxi,8312006,2,4,ui_qt_fenliyiji,0,0,0,0",
                            "1003341,0,0,ui_pg_yaoshi,8327002,2,3,ui_dt_xuanyunchongji,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003204,0,0,ui_pg_quanji,8302002,2,2,ui_dt_shandiantuxi,8301006,2,4,ui_qt_duci,0,0,0,0",
                            "1003406,0,0,ui_pg_chongzhuang,8303002,2,2,ui_dt_fensui,8317006,2,4,ui_qt_shikongtisu,0,0,0,0",
                            "1002941,0,0,ui_pg_touchui,8327002,2,3,ui_dt_xuanyunchongji,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8302002,2,2,ui_dt_shandiantuxi,8311006,2,4,ui_dt_jiafang,0,0,0,0",
                            "1003641,0,0,ui_pg_quanji,8309022,2,2,ui_dt_fandun,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0"],
                            ["1002841,0,0,ui_pg_pikan,8309022,2,2,ui_dt_fandun,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003101,0,0,ui_pg_tanshe,8318002,2,2,ui_dt_weihe,8314006,2,4,ui_qt_mengdu,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8302002,2,2,ui_dt_shandiantuxi,8310006,2,4,ui_qt_huifu,0,0,0,0",
                            "1003341,0,0,ui_pg_yaoshi,8309022,2,2,ui_dt_fandun,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003206,0,0,ui_pg_quanji,8302002,2,2,ui_dt_shandiantuxi,8301006,2,4,ui_qt_duci,0,0,0,0",
                            "1003406,0,0,ui_pg_chongzhuang,8302002,2,2,ui_dt_shandiantuxi,8317006,2,4,ui_qt_shikongtisu,0,0,0,0",
                            "1002941,0,0,ui_pg_touchui,8302202,2,2,ui_dt_gangyituxi,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8316002,2,2,ui_dt_huifu,8312006,2,4,ui_qt_fenliyiji,0,0,0,0",
                            "1003601,0,0,ui_pg_quanji,8333002,2,2,ui_qt_mengdu,8140006,2,4,ui_qt_huifu,0,0,0,0"],
                            ["1002841,0,0,ui_pg_pikan,8309023,3,2,ui_dt_fandun,8308007,3,4,ui_qt_tiaoxintongji,8404003,3,0,ui_qt_jianren",
                            "1003101,0,0,ui_pg_tanshe,8317003,3,2,ui_dt_shikongtisu,8314007,3,4,ui_qt_mengdu,8403003,3,0,ui_qt_jianshuo",
                            "1003001,0,0,ui_pg_chongzhuang,8302003,3,2,ui_dt_shandiantuxi,8312007,3,4,ui_qt_fenliyiji,8405003,3,0,ui_pg_zhuaji",
                            "1003341,0,0,ui_pg_yaoshi,8302203,3,2,ui_dt_gangyituxi,8308007,3,4,ui_qt_tiaoxintongji,8404003,3,0,ui_qt_jianren",
                            "1003210,0,0,ui_pg_quanji,8302003,3,2,ui_dt_shandiantuxi,8301007,3,4,ui_qt_duci,8405003,3,0,ui_pg_zhuaji",
                            "1003406,0,0,ui_pg_chongzhuang,8303003,3,2,ui_dt_fensui,8317007,3,4,ui_qt_shikongtisu,8407003,3,0,ui_dt_yumou",
                            "1002941,0,0,ui_pg_touchui,8309013,3,2,ui_dt_fanzhen,8308007,3,4,ui_qt_tiaoxintongji,8404003,3,0,ui_qt_jianren",
                            "1003001,0,0,ui_pg_chongzhuang,8320007,3,4,ui_qt_ruilidaji,8315007,3,4,ui_dt_fuhuo,8407003,3,0,ui_dt_yumou",
                            "1003601,0,0,ui_pg_quanji,8317003,3,2,ui_dt_shikongtisu,8138007,3,4,ui_dt_fuhuo,8403003,3,0,ui_qt_jianshuo"],
                            ["1002841,0,0,ui_pg_pikan,8327003,3,3,ui_dt_xuanyunchongji,8308007,3,4,ui_qt_tiaoxintongji,8405003,3,0,ui_pg_zhuaji",
                            "1003101,0,0,ui_pg_tanshe,8320007,3,4,ui_qt_ruilidaji,8314007,3,4,ui_qt_mengdu,8406003,3,0,ui_pg_zhuaji",
                            "1003001,0,0,ui_pg_chongzhuang,8302003,3,2,ui_dt_shandiantuxi,8313007,3,4,ui_qt_yexing,8406003,3,0,ui_pg_zhuaji",
                            "1003341,0,0,ui_pg_yaoshi,8327003,3,3,ui_dt_xuanyunchongji,8308007,3,4,ui_qt_tiaoxintongji,8403003,3,0,ui_qt_jianshuo",
                            "1003202,0,0,ui_pg_quanji,8302003,3,2,ui_dt_shandiantuxi,8301007,3,4,ui_qt_duci,8406003,3,0,ui_pg_zhuaji",
                            "1003406,0,0,ui_pg_chongzhuang,8304003,3,2,ui_pg_zhuaji,8317007,3,4,ui_qt_shikongtisu,8407003,3,0,ui_dt_yumou",
                            "1002941,0,0,ui_pg_touchui,8309013,3,2,ui_dt_fanzhen,8308007,3,4,ui_qt_tiaoxintongji,8403003,3,0,ui_qt_jianshuo",
                            "1003001,0,0,ui_pg_chongzhuang,8319003,3,2,ui_dt_shuairuo,8313007,3,4,ui_qt_yexing,8406003,3,0,ui_pg_zhuaji",
                            "1003610,0,0,ui_pg_quanji,8302003,3,2,ui_dt_shandiantuxi,8139007,3,4,ui_qt_fensui,8405003,3,0,ui_pg_zhuaji"]];


    string[] public param4 = ["QmUiExxsDhH1DBq4CGcX364nD4UaohBYcbKmVzPD2FjVhs","0,2004014,G311,4,10000067,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3","8,1083,SS,140,SS,135,SS,154,SS,0.19,SS,1.56,SS,0.93,SS,SS","1002739,0,0,ui_pg_zhuaji,8321034,4,2,ui_dt_feixue,8135004,4,4,ui_dt_fuhuo,8413004,4,0,ui_dt_fandun"];

    string[] public param5 = ["QmSBPcyuexhykVAMwj1BNdwXE5kbohqQPXRDgxLanGh2ZP","0,2004015,A311,5,10000067,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3","8,1011,SS,155,SS,126,SS,160,SS,0.19,SS,1.58,SS,0.92,SS,SS","1002740,0,0,ui_pg_zhuaji,8302084,4,2,ui_dt_shandiantuxi,8136004,4,4,ui_e_heidongbo,8413004,4,0,ui_dt_fandun"];


    mapping(address => uint) public whitelist;
    uint public desNum2 = 98*1e18;                                            
    uint public desNum5 = 245*1e18;                                           

    uint randomNumber;
    bool public ranlock = true;

    uint public startTime = now + 365 days;
    uint public endTime;

     constructor (address new_stakeToken,address new_withdrawAddr,address new_nfttoken) public {
        stakeToken = new_stakeToken;
        withdrawAddr = new_withdrawAddr;
        _nfttoken = new_nfttoken;
         randomNumber = getRandom4RepeatHash(0);
    }

    modifier onlylock {
        require(ranlock, "lock");
        ranlock = false;
        _;
    }

    function getRandom(uint num) external onlylock {
        require(block.timestamp >= startTime && block.timestamp<= endTime,"time err");
        require(num == 2|| num == 5,"num");
        require(whitelist[msg.sender] > 0 ,"white list");
        whitelist[msg.sender] = whitelist[msg.sender].sub(1);

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
            uint _parame = randomNumber.mod(9);
            uint _meta;
            bool lightcat = false;
            bool darkcat = false;

            if(rannum<typeRate[0])
            {
                _meta = 0;
            }else if(rannum<typeRate[1])
            {
                _meta =1;
            }else if(rannum<typeRate[2])
            {
                _meta =2;
            }else if(rannum<typeRate[3])
            {
                _meta =3;
                lightcat = randomNumber.mod(10) == 9;
            }else{
                _meta = 4;
                darkcat = randomNumber.mod(10) == 9;
            }

            if(lightcat)
            {
                nfttoken(_nfttoken).mint(msg.sender,male,_meta.add(1),param4[1],param4[2],param4[3],param4[0]);
            }else if(darkcat)
            {
                nfttoken(_nfttoken).mint(msg.sender,male,_meta.add(1),param5[1],param5[2],param5[3],param5[0]);
            }else{
                nfttoken(_nfttoken).mint(msg.sender,male,_meta.add(1),param1[_meta][_parame],param2[_meta][_parame],param3[_meta][_parame],urls[_meta][_parame]);
            }

            randomNumber = randomNumber>>8;
        }

        randomNumber = getRandom4RepeatHash(randomNumber.mod(1000000));
        ranlock = true;
    }

    
    function withdraw( uint num) external onlyGovernance {
        IERC20(stakeToken).safeTransfer(msg.sender,num);
    }

    function setTimes( uint newstartTime,  uint newendTime) external onlyGovernance {       //todo
        startTime = newstartTime;
        endTime = newendTime;
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

    function addWhitelist( address[] calldata newlist,uint[] calldata newnum) external onlyGovernance {
        require(newlist.length <= newnum.length,"err");
         for(uint i=0;i<newlist.length;i++){
             whitelist[newlist[i]] = whitelist[newlist[i]].add(newnum[i]);
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