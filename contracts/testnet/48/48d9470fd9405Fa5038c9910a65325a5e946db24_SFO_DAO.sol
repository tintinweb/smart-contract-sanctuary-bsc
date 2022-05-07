// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SFO_DAO is Ownable {
    using SafeERC20 for IERC20;
    // Dao module
    struct Dao {
        string logo;
        string nameCn;
        string nameEn;
        string descCn;
        string descEn;
        string twittter;
        string telegram;
        string discord;
        address token;
        address lp;
        uint32 memberCount;
        bool status; // true:正常;false:删除
    }
    struct Councli {
        address addr;
        uint256 frozen;
        bool status; //true:正常;false:赎回
    }
    Dao[] private daos;
    mapping(uint16 => Councli[]) public daoCounclis;

    function daoAdd(
        string[] calldata params,
        address token,
        address lp
    ) public {
        require(!daoExist(token), "Dao exist.");
        uint256 frozenAmount = IERC20(token).totalSupply() / 100;
        IERC20(token).safeTransferFrom(msg.sender, address(this), frozenAmount);
        daos.push(
            Dao({
                logo: params[0], //
                nameCn: params[1],
                nameEn: params[2],
                descCn: params[3],
                descEn: params[4],
                twittter: params[5],
                telegram: params[6],
                discord: params[7],
                token: token,
                lp: lp,
                memberCount: 1,
                status: true
            })
        );
        daoCounclis[uint16(daos.length - 1)].push(
            Councli({
                addr: msg.sender, //
                frozen: frozenAmount,
                status: true
            })
        );
    }

    function daoList() public view returns (Dao[] memory) {
        return daos;
    }

    function daoExist(address token) public view returns (bool) {
        for (uint32 i = 0; i < daos.length; i++) {
            if (daos[i].token == token) {
                return true;
            }
        }
        return false;
    }

    function daoRemove(uint16 daoAt) public onlyOwner {
        daos[daoAt].status = false;
    }

    function councliAssign(uint16 daoAt, address[] memory addrs) public onlyOwner {
        for (uint16 i = 0; i < addrs.length; i++) {
            uint16 councliAt_ = councliAt(daoAt, addrs[i]);
            if (councliAt_ == 0) {
                daoCounclis[daoAt].push(
                    Councli({
                        addr: addrs[i], //
                        frozen: 0,
                        status: true
                    })
                );
            } else if (!daoCounclis[daoAt][councliAt_].status) {
                daoCounclis[daoAt][councliAt_].status = true;
                daoCounclis[daoAt][councliAt_].frozen = 0;
            }
        }
    }

    function councliApply(uint16 daoAt) public {
        uint16 councliAt_ = councliAt(daoAt, msg.sender);
        require(councliAt_ == 0 || !daoCounclis[daoAt][councliAt_].status, "You are already the councli.");

        uint256 frozenAmount = IERC20(daos[daoAt].token).totalSupply() / 100;
        IERC20(daos[daoAt].token).safeTransferFrom(msg.sender, address(this), frozenAmount);
        if (councliAt_ == 0) {
            daoCounclis[daoAt].push(
                Councli({
                    addr: msg.sender, //
                    frozen: frozenAmount,
                    status: true
                })
            );
        } else {
            daoCounclis[daoAt][councliAt_].frozen = frozenAmount;
            daoCounclis[daoAt][councliAt_].status = true;
        }
    }

    function councliQuit(uint16 daoAt) public {
        uint16 councliAt_ = councliAt(daoAt, msg.sender);
        require(councliAt_ != 0 && daoCounclis[daoAt][councliAt_].status, "You are not the councli.");
        daoCounclis[daoAt][councliAt_].status = false;
        IERC20(daos[daoAt].token).safeTransfer(msg.sender, daoCounclis[daoAt][councliAt_].frozen);
    }

    function councliAt(uint16 daoAt, address addr) public view returns (uint16) {
        for (uint16 i = 0; i < daoCounclis[daoAt].length; i++) {
            if (daoCounclis[daoAt][i].addr == addr) {
                return i;
            }
        }
        return 0;
    }

    function lpToTokenPrice(address lp, address token) public view returns (uint256) {
        return (IERC20(token).balanceOf(lp) * 2) / IERC20(lp).totalSupply();
    }

    // Proposal module
    struct Proposal {
        uint16 daoAt; // org array At
        string name;
        string desc;
        uint8 content; // 10:普通提案;20:重要提案;30:核心提案
        uint8 label; // 10:决策相关;20:发展相关;30:决策相关
        uint256 reward;
        uint32 startTime;
        uint32 endTime;
        bool mutilOption; // false:单选;true:多选
        string[] options; // 选项
        uint256[] votes; // 得票数
        uint256 totalVote;
        address initiate;
        uint256 frozenAmount; // 发起提案时质押的数量
        uint8 status; // 10:正常;20:已结束(提案人修改);40:被owner删除
    }
    struct Vote {
        address voter;
        uint256 lpAmount; // 0:token;!0:lp
        uint256 tokenAmount;
        bool status; // true:已投票;false:已赎回
    }
    mapping(uint16 => Proposal[]) private daoProposals;
    mapping(uint16 => mapping(uint16 => Vote[])) private proposalVotes;

    function proposalAdd(
        uint16 daoAt,
        string[] memory strParams,
        uint256[] memory uintParams,
        bool mutilOption,
        string[] memory options
    ) public {
        uint16 councliAt_ = councliAt(daoAt, msg.sender);
        uint256 frozenAmount;
        if (councliAt_ == 0 || daoCounclis[daoAt][councliAt_].status == false) {
            frozenAmount = IERC20(daos[daoAt].token).totalSupply() / 100;
            IERC20(daos[daoAt].token).safeTransferFrom(msg.sender, address(this), frozenAmount);
        }
        if (uintParams[2] != 0) {
            IERC20(daos[daoAt].token).safeTransferFrom(msg.sender, address(this), uintParams[2]);
        }
        daoProposals[daoAt].push(
            Proposal({
                daoAt: daoAt,
                name: strParams[0],
                desc: strParams[1],
                content: uint8(uintParams[0]),
                label: uint8(uintParams[1]),
                reward: uintParams[2],
                startTime: uint32(uintParams[3]),
                endTime: uint32(uintParams[4]),
                mutilOption: mutilOption,
                options: options,
                votes: new uint256[](options.length),
                totalVote: 0,
                initiate: msg.sender,
                frozenAmount: frozenAmount,
                status: 10
            })
        );
    }

    function proposalEdit(
        uint16 daoAt,
        uint16 proposalAt,
        string[] memory strParams,
        uint256[] memory uintParams,
        bool mutilOption,
        string[] memory options
    ) public {
        require(block.timestamp < daoProposals[daoAt][proposalAt].startTime, "Proposal already start.");
        require(daoProposals[daoAt][proposalAt].initiate == msg.sender, "You are not the initiate.");
        daoProposals[daoAt][proposalAt].name = strParams[0];
        daoProposals[daoAt][proposalAt].desc = strParams[1];
        daoProposals[daoAt][proposalAt].content = uint8(uintParams[0]);
        daoProposals[daoAt][proposalAt].label = uint8(uintParams[1]);
        daoProposals[daoAt][proposalAt].reward = uint8(uintParams[2]);
        daoProposals[daoAt][proposalAt].startTime = uint8(uintParams[3]);
        daoProposals[daoAt][proposalAt].endTime = uint8(uintParams[4]);
        daoProposals[daoAt][proposalAt].mutilOption = mutilOption;
        daoProposals[daoAt][proposalAt].options = options;
    }

    function proposalFinsh(uint16 daoAt, uint16 proposalAt) public {
        require(daoProposals[daoAt][proposalAt].initiate == msg.sender, "You are not the initiate.");
        require(block.timestamp >= daoProposals[daoAt][proposalAt].endTime, "Proposal not end.");
        daoProposals[daoAt][proposalAt].status = 20;
        // 返回质押的款
        if (daoProposals[daoAt][proposalAt].frozenAmount != 0) {
            IERC20(daos[daoAt].token).safeTransfer(msg.sender, daoProposals[daoAt][proposalAt].frozenAmount);
        }
    }

    function proposalRemove(uint16 daoAt, uint16 proposalAt) public onlyOwner {
        daoProposals[daoAt][proposalAt].status = 40;
    }

    // user module
    mapping(address => mapping(uint16 => bool)) public userDao;

    function daoJoin(uint16 daoAt) public {
        require(!userDao[msg.sender][daoAt], "You are already the member.");
        userDao[msg.sender][daoAt] = true;
        daos[daoAt].memberCount++;
    }

    function daoQuit(uint16 daoAt) public {
        require(userDao[msg.sender][daoAt], "You are not the member.");
        userDao[msg.sender][daoAt] = false;
        daos[daoAt].memberCount--;
    }

    function vote(
        uint16 daoAt,
        uint16 proposalAt,
        bool lp,
        uint8[] memory options,
        uint256[] memory amounts
    ) public {
        require(daoProposals[daoAt][proposalAt].status == 10, "Proposal status error.");
        require(block.timestamp >= daoProposals[daoAt][proposalAt].startTime && block.timestamp <= daoProposals[daoAt][proposalAt].endTime, "proposal not vote time.");
        require(!lp || daos[daoAt].lp != address(0), "Dao not allow lp");
        require(!daoProposals[daoAt][proposalAt].mutilOption || options.length == 1, "Proposal not allow mutilOption");
        if (lp) {
            uint256 lpPrice = lpToTokenPrice(daos[daoAt].lp, daos[daoAt].token);
            uint256 totalAmount;
            for (uint8 i = 0; i < options.length; i++) {
                daoProposals[daoAt][proposalAt].votes[options[i]] += (amounts[i] * lpPrice) / 1e18;
                daoProposals[daoAt][proposalAt].totalVote += (amounts[i] * lpPrice) / 1e18;
                totalAmount += amounts[i];
            }
            IERC20(daos[daoAt].lp).safeTransferFrom(msg.sender, address(this), totalAmount);
            proposalVotes[daoAt][proposalAt].push(
                Vote({
                    voter: msg.sender, //
                    lpAmount: totalAmount,
                    tokenAmount: totalAmount * lpPrice,
                    status: true
                })
            );
        } else {
            uint256 totalAmount;
            for (uint8 i = 0; i < options.length; i++) {
                daoProposals[daoAt][proposalAt].votes[options[i]] += amounts[i];
                daoProposals[daoAt][proposalAt].totalVote += amounts[i];
                totalAmount += amounts[i];
            }
            IERC20(daos[daoAt].token).safeTransferFrom(msg.sender, address(this), totalAmount);
            proposalVotes[daoAt][proposalAt].push(
                Vote({
                    voter: msg.sender, //
                    lpAmount: 0,
                    tokenAmount: totalAmount,
                    status: true
                })
            );
        }
    }

    function voteFinsh(uint16 daoAt, uint16 proposalAt) public {
        require(daoProposals[daoAt][proposalAt].status == 20, "Proposal not end.");
        uint256 totalLp;
        uint256 totalToken;
        uint256 totalReward;
        for (uint16 i = 0; i < proposalVotes[daoAt][proposalAt].length; i++) {
            if (proposalVotes[daoAt][proposalAt][i].voter == msg.sender && proposalVotes[daoAt][proposalAt][i].status) {
                proposalVotes[daoAt][proposalAt][i].status = false;
                if (proposalVotes[daoAt][proposalAt][i].lpAmount == 0) {
                    totalToken += proposalVotes[daoAt][proposalAt][i].tokenAmount;
                }
                totalLp += proposalVotes[daoAt][proposalAt][i].lpAmount;
                totalReward += proposalVotes[daoAt][proposalAt][i].tokenAmount;
            }
        }
        if (daoProposals[daoAt][proposalAt].reward != 0) {
            totalReward = (totalReward * daoProposals[daoAt][proposalAt].reward) / daoProposals[daoAt][proposalAt].totalVote;
        }
        if (totalLp > 0) {
            IERC20(daos[daoAt].lp).safeTransfer(msg.sender, totalLp);
        }
        if (totalToken > 0) {
            IERC20(daos[daoAt].token).safeTransfer(msg.sender, totalToken);
        }
        if (totalReward > 0) {
            IERC20(daos[daoAt].token).safeTransfer(msg.sender, totalReward);
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