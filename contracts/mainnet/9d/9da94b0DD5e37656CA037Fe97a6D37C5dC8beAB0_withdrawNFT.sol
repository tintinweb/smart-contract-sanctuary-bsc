/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

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

interface ERC721
{
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );

  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );


  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external;
    
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;
    
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;

  function approve(
    address _approved,
    uint256 _tokenId
  )
    external;
    
  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external;

  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256);

  function ownerOf(
    uint256 _tokenId
  )
    external
    view
    returns (address);

  function getApproved(
    uint256 _tokenId
  )
    external
    view
    returns (address);

  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    view
    returns (bool);

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

interface propnfttoken {
    function mint(
        address _to,
        string calldata  param,
        string calldata _uri
    )   external;
}


contract withdrawNFT is Governance {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct nftInfo{
        address _tokenAddr;
        bool[] male;
        uint[] ids;
    }

    mapping(address => nftInfo) public _nftToken;

    string[] public urls = [  "QmYtkwZYdFxPh5oJQL3vhFEAT5kNJ7fezU3vnvPYoUwGu3"  ,
                               "Qmep2rofh8e1jY9pu7xs7iWeCMbNe7j296zYsyQxrXGp45" ,
                               "QmPnhBYN1PSsLhbsKVnwgbekUg5MVbcQwHfiVUVQbYcjVa" ,
                               "QmUK8bgSSVDueJU98zpATuURqm7CLgsjwj4LNLMvj1HZoG" ,
                               "QmV6g93m2A9nXJX2jbUausATtvyyr8joqNUj2XXbztUy7n" ,
                               "QmUmsxM8yW1giskyfsMuj8arV7yHJnnAW7VeZ74fscDRrH" ,
                                "QmYVymzpdr7MeHTwvD7Zavv62VeSasxwG9xWZ7RViYFAuL",
                               "QmeWuwYkpJoFCzx4LcXKgMpz23xc3RRketB4aTt1ayA43c" ,
                               "QmRJ8VfETzCAb2b7SHLKQ4PxK7Tp6DtF83qp6JeTrREUkN" ,
                               "QmUVqHz562ycU6TB1Xg4YmdeaLTYrm6BhDfrPoMv2d3AXV" ,
                                "QmbZ4AiLz1AjSrVvo3Afdxa284A5E5R6F1E3YiLCt28kVt",
                                "QmUyULUs1HipCdLnreYKvNi7vnQ1GqBZWykMtowC6zn4uf",
                                "QmW39ko7qD2QiJ2TZtyM9wwCXaoHXrDQ6hkHVXuHiijRPn",
                                "QmQv9T4JAiUc7mrEB2PXWSAhiL9eBA5DZYjSLHBN7yn1mC",
                                "QmW6qbPgP5GyBn8kRxMDgpz6Cq4Tq3fiP3wz9UpE9b9HEg",
                                "QmWSjxRvL5WHsVuVRSFVRQN8xnhjc9QvRgjV3zmVVNVhfC",
                                "QmbZ4AiLz1AjSrVvo3Afdxa284A5E5R6F1E3YiLCt28kVt",
                                "QmUyULUs1HipCdLnreYKvNi7vnQ1GqBZWykMtowC6zn4uf",
                                "QmReuDvC5wgDurXTddyEnt1vvG6pZgVt4FZMFPHDcL7q1m",
                                "QmQ5rAVFLVnLXYLdar56qVcoPW4bNcgBG44HHsrXXRAgEm",
                               "QmX8gUbMwjYdcpkbxpV1HwiugcQzeCdk8TrA7kk2KA7rMB" ,
                                "QmUQgkZp3yf91RaJdvK5wpPbUrjjNJwVyscPaHgsYt46qo",
                                "QmQXig9ZPggjkoL1zfKPcNPjw61E1wpGzwKUmQj81kRMFT",
                                "QmeUFqdNVtKmaDoTSgYSubXmtTL3ykqUpQpYTYp7xv84b9",
                                "QmaTSWrkHQZtoPEX3sQdZW5sFLqWgDjSYffQhoSXZGKy2q",
                                "QmQxjJc4QCM3aeBwSKBsPGf2Apd3R5YiLeEneEvQNRhhSQ",
                                "QmcDkKyfMnTRyD5QoRX9Qpb816wpdjRFn1N8ic7VoZibSm"
                            ];

    string[] public param1 = ["0,3000211,H122,1,10000065,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                                "0,3000212,M122,2,10000065,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                                "0,3000213,S122,3,10000065,1,10000072,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2000611,H061,1,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2000612,M061,2,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2000613,S061,3,10000066,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2001311,H131,1,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2001312,M131,2,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2001313,S131,3,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002111,H211,1,10000067,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002112,M211,2,10000067,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002113,S211,3,10000067,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2001811,H181,1,10000066,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2001812,M181,2,10000066,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2001813,S181,3,10000066,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002211,H221,1,10000065,1,10000071,1,2,1,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002212,M221,2,10000065,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002213,S221,3,10000065,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002911,H291,1,10000065,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002912,M291,2,10000065,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002913,S291,3,10000065,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002711,H271,1,10000066,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002712,M271,2,10000066,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002713,S271,3,10000066,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002411,H241,1,10000067,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002412,M241,2,10000067,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3",
                                "0,2002413,S241,3,10000067,1,10000071,1,2,2,1,1,100,5,5,0,0,2,0,0,3"];

    string[] public param2 = ["8,873,SS,208,SS,105,SS,148,SS,0.34,SS,1.67,SS,0.71,SS,SS",
                            "8,844,SS,208,SS,109,SS,148,SS,0.34,SS,1.66,SS,0.71,SS,SS",
                            "8,815,SS,208,SS,113,SS,148,SS,0.35,SS,1.65,SS,0.71,SS,SS",
                            "12,1246,SS,74,SS,180,SS,96,SS,0.12,SS,1.51,SS,0.64,SS,SS",
                            "12,1246,SS,74,SS,180,SS,96,SS,0.12,SS,1.51,SS,0.64,SS,SS",
                            "12,1246,SS,74,SS,180,SS,96,SS,0.12,SS,1.51,SS,0.64,SS,SS",
                            "8,954,SS,119,SS,143,SS,187,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "8,954,SS,119,SS,143,SS,187,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "8,954,SS,119,SS,143,SS,187,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "8,990,SS,126,SS,130,SS,190,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "8,990,SS,126,SS,130,SS,190,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "8,990,SS,126,SS,130,SS,190,SS,0.18,SS,1.55,SS,0.93,SS,SS",
                            "12,1190,SS,72,SS,189,SS,100,SS,0.12,SS,1.53,SS,0.64,SS,SS",
                            "12,1190,SS,72,SS,189,SS,100,SS,0.12,SS,1.53,SS,0.64,SS,SS",
                            "12,1190,SS,72,SS,189,SS,100,SS,0.12,SS,1.53,SS,0.64,SS,SS",
                            "8,815,SS,208,SS,98,SS,138,SS,0.34,SS,1.67,SS,0.71,SS,SS",
                            "8,815,SS,208,SS,98,SS,138,SS,0.34,SS,1.67,SS,0.71,SS,SS",
                            "8,815,SS,208,SS,98,SS,138,SS,0.34,SS,1.67,SS,0.71,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS",
                            "8,759,SS,198,SS,88,S,192,SS,0.34,SS,1.66,SS,0.70,SS,SS"
                            ];

    string[] public param3 = ["1003521,0,0,ui_pg_chongzhuang,8305003,3,2,ui_dt_ruilidaji,8327007,3,7,ui_qt_xuanyunchongji,8401003,3,0,ui_qt_qiangzhuang",
                            "1003544,0,0,ui_pg_chongzhuang,8306003,3,2,ui_qt_ruilidaji,8303007,3,4,ui_qt_fensui,8411003,3,0,ui_pg_zhuaji",
                            "1003505,0,0,ui_pg_chongzhuang,8307003,3,2,ui_dt_fuji,8137007,3,4,ui_pg_zhuaji,8409003,3,0,ui_dt_huifu",
                            "1002841,0,0,ui_pg_pikan,8302202,2,2,ui_dt_gangyituxi,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1002841,0,0,ui_pg_pikan,8309012,2,2,ui_dt_fanzhen,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1002841,0,0,ui_pg_pikan,8309022,2,2,ui_dt_fandun,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003101,0,0,ui_pg_tanshe,8333002,2,2,ui_qt_mengdu,8314006,2,4,ui_qt_mengdu,0,0,0,0",
                            "1003101,0,0,ui_pg_tanshe,8319002,2,2,ui_dt_shuairuo,8314006,2,4,ui_qt_mengdu,0,0,0,0",
                            "1003101,0,0,ui_pg_tanshe,8318002,2,2,ui_dt_weihe,8314006,2,4,ui_qt_mengdu,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8302002,2,2,ui_dt_shandiantuxi,8313006,2,4,ui_qt_yexing,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8302002,2,2,ui_dt_shandiantuxi,8312006,2,4,ui_qt_fenliyiji,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8302002,2,2,ui_dt_shandiantuxi,8310006,2,4,ui_qt_huifu,0,0,0,0",
                            "1003341,0,0,ui_pg_yaoshi,8302102,2,2,ui_dt_yingyongtuxi,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003341,0,0,ui_pg_yaoshi,8327002,2,3,ui_dt_xuanyunchongji,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003341,0,0,ui_pg_yaoshi,8309022,2,2,ui_dt_fandun,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003203,0,0,ui_pg_quanji,8302002,2,2,ui_dt_shandiantuxi,8301006,2,4,ui_qt_duci,0,0,0,0",
                            "1003204,0,0,ui_pg_quanji,8302002,2,2,ui_dt_shandiantuxi,8301006,2,4,ui_qt_duci,0,0,0,0",
                            "1003206,0,0,ui_pg_quanji,8302002,2,2,ui_dt_shandiantuxi,8301006,2,4,ui_qt_duci,0,0,0,0",
                            "1003406,0,0,ui_pg_chongzhuang,8304002,2,2,ui_pg_zhuaji,8317006,2,4,ui_qt_shikongtisu,0,0,0,0",
                            "1003406,0,0,ui_pg_chongzhuang,8303002,2,2,ui_dt_fensui,8317006,2,4,ui_qt_shikongtisu,0,0,0,0",
                            "1003406,0,0,ui_pg_chongzhuang,8302002,2,2,ui_dt_shandiantuxi,8317006,2,4,ui_qt_shikongtisu,0,0,0,0",
                            "1002941,0,0,ui_pg_touchui,8302102,2,2,ui_dt_yingyongtuxi,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1002941,0,0,ui_pg_touchui,8327002,2,3,ui_dt_xuanyunchongji,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1002941,0,0,ui_pg_touchui,8302202,2,2,ui_dt_gangyituxi,8308006,2,4,ui_qt_tiaoxintongji,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8333002,2,2,ui_qt_mengdu,8313006,2,4,ui_qt_yexing,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8302002,2,2,ui_dt_shandiantuxi,8311006,2,4,ui_dt_jiafang,0,0,0,0",
                            "1003001,0,0,ui_pg_chongzhuang,8316002,2,2,ui_dt_huifu,8312006,2,4,ui_qt_fenliyiji,0,0,0,0"
                            ];

    constructor () public {
    }

    function withdraw() public{
        uint lenn = _nftToken[msg.sender].ids.length;
        // uint ccurtime = block.timestamp;
        address curAddr;
        for(uint i=0;i<lenn;i++)
        {
            curAddr = _nftToken[msg.sender]._tokenAddr;
            nfttoken(curAddr).mint(
            msg.sender,
            _nftToken[msg.sender].male[i],
            0,
            param1[_nftToken[msg.sender].ids[i]],
            param2[_nftToken[msg.sender].ids[i]],
            param3[_nftToken[msg.sender].ids[i]],
            urls[_nftToken[msg.sender].ids[i]]
            );
        }
        for(uint i=0;i<lenn;i++)
        {
            _nftToken[msg.sender].ids.pop();
            _nftToken[msg.sender].male.pop();
        }

    }

    function withdrawNFTbalanceOf(address ac) public view returns(uint256 ){
        return _nftToken[ac].ids.length;
    }

    function setNFTwithdraw(
        address ac,
        address nftaddr,
        bool[] calldata nmale,
        uint[] calldata num
    )
      external
      onlyGovernance{

        // nftInfo memory itemIn;
        _nftToken[ac]._tokenAddr = nftaddr;
        _nftToken[ac].male = nmale;
        _nftToken[ac].ids = num;
    }

    function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    returns(bytes4){
        return 0x150b7a02;
    }


}