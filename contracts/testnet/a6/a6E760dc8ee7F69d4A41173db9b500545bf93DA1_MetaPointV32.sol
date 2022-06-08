// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Counters32.sol";
import "./DoubleEndedQueue32.sol";

interface IDonate {
    function queryDonatedList() external view returns (address[] memory);
}

contract MetaPointV32 is Ownable {
    using SafeERC20 for IERC20;
    using DoubleEndedQueue for DoubleEndedQueue.Uint32Deque;
    using Counters for Counters.Counter;

    address public creator;
    uint256 public creatorBalance;
    address public first;
    address private lpds = 0xA01cD2ac042DEbcb17B830C49eA26fe2660aD731;
    uint256 public lpdsBalance;
    address public lp = 0xdA0B47eD306F2bF6b128e5a84389b1f270932Cb6; // test:
    uint256 public expend = 100e18;
    uint256 public back = 300e18;
    address public wdr = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
    address public donate = 0x810C2dd185dFd08b8d5656175f4f335a0ea61C78;

    uint8[] public allot = [30, 5, 60, 5]; // 见点,捐赠,控盘,质押分红

    uint32 public accountCnt;
    Counters.Counter private pointCnter;
    mapping(uint256 => address) public points;

    mapping(uint32 => uint32) public dailyCnts;

    struct Account {
        uint256 srd;
        uint256 srw;
        address head;
        uint8 vip;
        uint32 point;
        uint32 effect;
        uint256 wdm;
        uint256 wd;
        uint256 wda;
        uint256 grd;
        uint32 rootSn;
    }
    struct Node {
        uint32 pid;
        uint32 lid;
        uint32 rid;
    }

    mapping(address => Account) public accounts;
    mapping(address => address[]) private follows;
    mapping(uint32 => Node) public nodes; // 所有节点
    uint256 public acc;
    uint32 public effectTotal;

    event LogUp(address indexed addr, uint32 indexed current, uint256 indexed nextSn, bool isLeft);

    constructor() {
        creator = msg.sender;
        first = 0xA01cD2ac042DEbcb17B830C49eA26fe2660aD731;
        opr = creator;

        accounts[first].head = creator;
        accounts[first].point = 1;
        accounts[first].effect = 1;
        accounts[first].rootSn = 2;

        points[1] = creator;
        points[2] = first;

        pointCnter.increment();
        pointCnter.increment();
        nodes[1].lid = 2;
        nodes[2].pid = 1;

        effectTotal = 1;
        accountCnt = 2;
        transferOwnership(first);
    }

    function setExpend(uint256 _expend) public onlyOwner {
        expend = _expend;
    }

    function initAddress(
        address _lpds,
        address _lp,
        address _wdr,
        address _donate
    ) public onlyOwner {
        lpds = _lpds;
        lp = _lp;
        wdr = _wdr;
        donate = _donate;
    }

    function register(address head) public {
        require(head != msg.sender, "head can not set to youself");
        require(accounts[msg.sender].head == address(0), "head is exist");
        require(accounts[head].head != address(0), "head is not actived");
        require(accounts[head].point > 0, "head is not actived");
        accounts[msg.sender].head = head;
        accountCnt++;
        follows[head].push(msg.sender);

        up();
    }

    uint8[] public levelUpFollows = [0, 6, 4, 2];
    uint8[] public upLmt = [5, 7, 9, 11];
    mapping(uint32 => bool) private grwCreatorToday;
    address public opr;

    function setOpr(address addr) public onlyOwner {
        opr = addr;
    }

    function followList(address addr) public view returns (address[] memory addrs, uint8[] memory vips) {
        addrs = follows[addr];
        vips = new uint8[](addrs.length);
        for (uint256 i = 0; i < addrs.length; i++) {
            vips[i] = accounts[addrs[i]].vip;
        }
    }

    function levelUp(uint8 target) public {
        require(target > accounts[msg.sender].vip, "Already higher level.");
        uint256 count = 0;
        for (uint256 i = 0; i < follows[msg.sender].length; i++) {
            if (accounts[follows[msg.sender][i]].vip >= (target - 1)) {
                count += 1;
                if (count >= levelUpFollows[target]) {
                    accounts[msg.sender].vip = target;
                    break;
                }
            }
        }
    }

    function up() public {
        require(accounts[msg.sender].effect >= freeLimitCount || userDailyCnts[msg.sender][today()] < upLmt[accounts[msg.sender].vip], "Amount limit today.");
        address head = accounts[msg.sender].head;
        require(head != address(0), "Account not actived.");

        IERC20(lp).safeTransferFrom(msg.sender, address(this), expend);
        uint256 srd = (expend * allot[0]) / 100;
        uint256 srdEach = srd / 30;

        uint32 current = 0;
        if (accounts[msg.sender].rootSn == 0) {
            current = take(head, msg.sender);
            accounts[msg.sender].rootSn = current;
        } else {
            current = take(msg.sender, msg.sender);
        }

        accounts[msg.sender].point += 1;
        accounts[msg.sender].effect += 1;
        accounts[msg.sender].wdm += back;
        accounts[msg.sender].grd += acc;

        effectTotal += 1;

        for (uint32 i = 0; i < 30; i++) {
            if (current < 2) {
                break;
            }
            address addr = points[current];
            if (verifysrd(addr, i)) {
                accounts[addr].srd += srdEach;
                srd -= srdEach;
            }
            current = nodes[current].pid;
        }
        creatorBalance += srd;
        donateBalance += (expend * allot[1]) / 100;
        creatorBalance += (expend * allot[2]) / 100;

        lpdsBalance += (expend * allot[3]) / 100; // 质押收益账号

        userDailyCnts[msg.sender][today()] += 1;
        dailyCnts[today()] += 1;
    }

    // 寻找到点灯的位置
    mapping(address => DoubleEndedQueue.Uint32Deque) private queues;

    function userQueue(address addr) external view returns (uint32[] memory result) {
        result = new uint32[](queues[addr].length());
        for (uint32 i = 0; i < queues[addr].length(); i++) {
            result[i] = queues[addr].at(i);
        }
    }

    function take(address parent, address addr) private returns (uint32) {
        pointCnter.increment();
        uint32 next = pointCnter.current();
        points[next] = addr;

        if (queues[parent].empty()) {
            queues[parent].pushFront(accounts[parent].rootSn);
        }
        while (!queues[parent].empty()) {
            uint32 current = queues[parent].popBack();

            if (nodes[current].lid == 0) {
                nodes[current].lid = next;
                nodes[next].pid = current;
                queues[parent].pushBack(current);
                emit LogUp(addr, current, next, true);
                return next;
            } else {
                queues[parent].pushFront(nodes[current].lid);
            }
            if (nodes[current].rid == 0) {
                nodes[current].rid = next;
                nodes[next].pid = current;
                queues[parent].pushFront(next);
                emit LogUp(addr, current, next, false);
                return next;
            } else {
                queues[parent].pushFront(nodes[current].rid);
            }
        }
        return 0;
    }

    function upBatch(uint256 times) public {
        for (uint256 i = 0; i < times; i++) {
            up();
        }
    }

    function grwCreator(uint256 amount) public {
        require(msg.sender == opr, "Forbidden.");
        require(!grwCreatorToday[today()], "Already operate today");
        require(amount <= creatorBalance, "Insufficient creatorBalance");
        require(amount / effectTotal <= 2.5e18, "Too much amount one time");
        acc += amount / effectTotal;
        creatorBalance -= amount;
        grwCreatorToday[today()] = true;
    }

    function grwCreatorEach(uint256 each) public {
        require(msg.sender == opr, "Forbidden.");
        require(!grwCreatorToday[today()], "Already operate today");
        require(each <= 2.5e18, "Too much amount one time");
        uint256 amount = effectTotal * each;
        require(amount <= creatorBalance, "Insufficient creatorBalance");
        acc += each;
        creatorBalance -= amount;
        grwCreatorToday[today()] = true;
    }

    function rcgCreator(uint256 amount) public {
        IERC20(lp).safeTransferFrom(msg.sender, address(this), amount);
        creatorBalance += amount;
    }

    function srdTransCreator(uint256 amount) public onlyOwner {
        require(accounts[creator].srd >= amount, "Insufficient of creator srd");
        accounts[creator].srd -= amount;
        creatorBalance += amount;
    }

    function withdraw(uint256 amount) public {
        uint256 grd = grping(msg.sender);
        uint256 srd = accounts[msg.sender].srd;
        accounts[msg.sender].wda += (grd + srd);
        accounts[msg.sender].srw += srd;
        accounts[msg.sender].srd = 0;
        require(amount <= accounts[msg.sender].wda, "Insufficient aviable wd");
        accounts[msg.sender].wd += amount;
        require(accounts[msg.sender].wd <= accounts[msg.sender].wdm, "Insufficient wdm");
        uint32 downCount = uint32(accounts[msg.sender].wd / back);
        uint32 count = downCount - (accounts[msg.sender].point - accounts[msg.sender].effect);
        if (count > 0) {
            accounts[msg.sender].effect -= count;
            effectTotal -= count;
        }
        accounts[msg.sender].wda -= amount;
        accounts[msg.sender].grd = accounts[msg.sender].effect * acc;
        uint256 withdrawFee = amount / 10;
        IERC20(lp).safeTransfer(wdr, withdrawFee);
        IERC20(lp).safeTransfer(msg.sender, amount - withdrawFee);
    }

    function grping(address addr) public view returns (uint256) {
        return accounts[addr].effect * acc - accounts[addr].grd;
    }

    function arping(address addr) public view returns (uint256 total_, uint256 withdraw_) {
        total_ = grping(addr) + accounts[addr].srd + accounts[addr].wda;
        withdraw_ = total_;
        if (total_ + accounts[addr].wd > accounts[addr].wdm) {
            withdraw_ = accounts[addr].wdm - accounts[addr].wd;
        }
    }

    function lpdsWithdraw(uint256 amount) external onlyOwner {
        IERC20(lp).safeTransfer(lpds, amount);
    }

    // 每日点灯数量限制模块
    uint16 public freeLimitCount = 900;
    mapping(address => mapping(uint32 => uint32)) public userDailyCnts;

    function today() public view returns (uint32) {
        return uint32(block.timestamp - (block.timestamp % (24 * 60 * 60)));
    }

    function setLevelUpFollows(uint8 vip, uint8 cnt) public onlyOwner {
        levelUpFollows[vip] = cnt;
    }

    function setUpLmt(uint8 vip, uint8 lmt) public onlyOwner {
        upLmt[vip] = lmt;
    }

    function setAllot(uint8 at, uint8 _allot) public onlyOwner {
        allot[at] = _allot;
    }

    function setFreeLimitCount(uint16 count) public onlyOwner {
        freeLimitCount = count;
    }

    // 捐赠模块
    uint256 public donateBalance = 0;

    function processDonate() public {
        require(donateBalance > 0, "Insufficient of DonateBalance");
        address[] memory donates = IDonate(donate).queryDonatedList();
        require(donates.length > 0, "Donate is empty");
        uint256 perDonate = donateBalance / donates.length;
        donateBalance = 0;
        for (uint256 i = 0; i < donates.length; i++) {
            IERC20(lp).safeTransfer(donates[i], perDonate);
        }
    }

    function verifysrd(address addr, uint96 level) public view returns (bool result) {
        uint96 vip = accounts[addr].vip;
        if (vip == 3) {
            result = (level < 30);
        } else if (vip == 2) {
            result = (level < 20);
        } else if (vip == 1) {
            result = (level < 10);
        } else {
            result = (level < 5);
        }
    }

    function pointCnt() public view returns (uint256) {
        return pointCnter.current();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint32 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint32) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint32 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/DoubleEndedQueue.sol)
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

/**
 * @dev A sequence of items with the ability to efficiently push and pop items (i.e. insert and remove) on both ends of
 * the sequence (called front and back). Among other access patterns, it can be used to implement efficient LIFO and
 * FIFO queues. Storage use is optimized, and all operations are O(1) constant time. This includes {clear}, given that
 * the existing queue contents are left in storage.
 *
 * The struct is called `Uint32Deque`. Other types can be cast to and from `uint32`. This data structure can only be
 * used in storage, and not in memory.
 * ```
 * DoubleEndedQueue.Uint32Deque queue;
 * ```
 *
 * _Available since v4.6._
 */
library DoubleEndedQueue {
    /**
     * @dev An operation (e.g. {front}) couldn't be completed due to the queue being empty.
     */
    error Empty();

    /**
     * @dev An operation (e.g. {at}) couldn't be completed due to an index being out of bounds.
     */
    error OutOfBounds();

    /**
     * @dev Indices are signed integers because the queue can grow in any direction. They are 128 bits so begin and end
     * are packed in a single storage slot for efficient access. Since the items are added one at a time we can safely
     * assume that these 128-bit indices will not overflow, and use unchecked arithmetic.
     *
     * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
     * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
     * lead to unexpected behavior.
     *
     * Indices are in the range [begin, end) which means the first item is at data[begin] and the last item is at
     * data[end - 1].
     */
    struct Uint32Deque {
        int32 _begin;
        int32 _end;
        mapping(int32 => uint32) _data;
    }

    /**
     * @dev Inserts an item at the end of the queue.
     */
    function pushBack(Uint32Deque storage deque, uint32 value) internal {
        int32 backIndex = deque._end;
        deque._data[backIndex] = value;
        unchecked {
            deque._end = backIndex + 1;
        }
    }

    /**
     * @dev Removes the item at the end of the queue and returns it.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function popBack(Uint32Deque storage deque) internal returns (uint32 value) {
        if (empty(deque)) revert Empty();
        int32 backIndex;
        unchecked {
            backIndex = deque._end - 1;
        }
        value = deque._data[backIndex];
        delete deque._data[backIndex];
        deque._end = backIndex;
    }

    /**
     * @dev Inserts an item at the beginning of the queue.
     */
    function pushFront(Uint32Deque storage deque, uint32 value) internal {
        int32 frontIndex;
        unchecked {
            frontIndex = deque._begin - 1;
        }
        deque._data[frontIndex] = value;
        deque._begin = frontIndex;
    }

    /**
     * @dev Removes the item at the beginning of the queue and returns it.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function popFront(Uint32Deque storage deque) internal returns (uint32 value) {
        if (empty(deque)) revert Empty();
        int32 frontIndex = deque._begin;
        value = deque._data[frontIndex];
        delete deque._data[frontIndex];
        unchecked {
            deque._begin = frontIndex + 1;
        }
    }

    /**
     * @dev Returns the item at the beginning of the queue.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function front(Uint32Deque storage deque) internal view returns (uint32 value) {
        if (empty(deque)) revert Empty();
        int32 frontIndex = deque._begin;
        return deque._data[frontIndex];
    }

    /**
     * @dev Returns the item at the end of the queue.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function back(Uint32Deque storage deque) internal view returns (uint32 value) {
        if (empty(deque)) revert Empty();
        int32 backIndex;
        unchecked {
            backIndex = deque._end - 1;
        }
        return deque._data[backIndex];
    }

    /**
     * @dev Return the item at a position in the queue given by `index`, with the first item at 0 and last item at
     * `length(deque) - 1`.
     *
     * Reverts with `OutOfBounds` if the index is out of bounds.
     */
    function at(Uint32Deque storage deque, uint32 index) internal view returns (uint32 value) {
        // int256(deque._begin) is a safe upcast
        int32 idx = SafeCast.toInt32(int256(deque._begin) + SafeCast.toInt256(index));
        if (idx >= deque._end) revert OutOfBounds();
        return deque._data[idx];
    }

    /**
     * @dev Resets the queue back to being empty.
     *
     * NOTE: The current items are left behind in storage. This does not affect the functioning of the queue, but misses
     * out on potential gas refunds.
     */
    function clear(Uint32Deque storage deque) internal {
        deque._begin = 0;
        deque._end = 0;
    }

    /**
     * @dev Returns the number of items in the queue.
     */
    function length(Uint32Deque storage deque) internal view returns (uint32) {
        // The interface preserves the invariant that begin <= end so we assume this will not overflow.
        // We also assume there are at most int256.max items in the queue.
        unchecked {
            return uint32(int32(deque._end) - int32(deque._begin));
        }
    }

    /**
     * @dev Returns true if the queue is empty.
     */
    function empty(Uint32Deque storage deque) internal view returns (bool) {
        return deque._end <= deque._begin;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}