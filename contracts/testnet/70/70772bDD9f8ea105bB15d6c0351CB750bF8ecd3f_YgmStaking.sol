// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

abstract contract YgmStakingBase is Ownable, Pausable {
    // Stake event
    event Stake(
        address indexed account,
        uint256 indexed tokenId,
        uint256 timestamp
    );
    // UnStake event
    event UnStake(
        address indexed account,
        uint256 indexed tokenId,
        uint256 timestamp
    );
    // Withdraw Earn event
    event WithdrawEarn(
        address indexed account,
        uint256 amount,
        uint256 timestamp
    );

    // Staking data
    struct StakingData {
        address account;
        bool state;
    }

    // Total number of all staked YGM
    uint32 public stakeTotals;
    // The number of accounts in staking
    uint32 public accountTotals;

    // todo YGM token
    IERC721 ygm;
    // Create_time
    uint64 public create_time;

    // todo usdt token
    IERC20 usdt;
    // todo Time period
    uint64 public perPeriod;

    // Payment account
    address public paymentAccount;
    // Rate
    uint64 public earnRate = 70;

    // Staking Data
    mapping(uint256 => StakingData) public stakingDatas;

    // List of account staking tokenId
    mapping(address => uint256[]) stakingTokenIds;

    // The amount of usdt shared by all users on a certain day
    mapping(uint256 => uint256) day_total_usdt;

    // The total amount of ygm staked on a certain day
    mapping(uint256 => uint256) day_total_stake;

    // The time a user staked
    mapping(address => uint256) public stakeTime;

    // The income obtained by the user's previous stake
    mapping(address => uint256) public stakeEarnAmount;

    // Set the amount of usdt allocated on a certain day (onlyOwner)
    function setDayAmount(
        uint256 _usdtAmount
    ) external onlyOwner returns (bool) {
        uint256 _days = getDays(create_time, block.timestamp);
        day_total_usdt[_days] += _usdtAmount;
        _syncDayTotalStake();
        return true;
    }

    // Set create time and per period time (onlyOwner)
    function start(
        uint256 _create_time,
        uint256 _period
    ) public onlyOwner returns (bool) {
        require(_create_time > 0 && _period > 0, "set time error");
        create_time = uint64(_create_time);
        perPeriod = uint64(_period);
        return true;
    }

    // Set eran rate (onlyOwner)
    function setRate(uint256 _rate) external onlyOwner returns (bool) {
        require(_rate <= 100, "set rate error");
        earnRate = uint64(_rate);
        return true;
    }

    // Set YGM contract address (onlyOwner)
    function setYgm(address _ygmAddress) external onlyOwner returns (bool) {
        ygm = IERC721(_ygmAddress);
        return true;
    }

    // Set usdt contract address (onlyOwner)
    function setUsdt(address _usdtAddress) external onlyOwner returns (bool) {
        usdt = IERC20(_usdtAddress);
        return true;
    }

    // Set payment account address (onlyOwner)
    function setPayAccount(
        address _payAccount
    ) external onlyOwner returns (bool) {
        paymentAccount = _payAccount;
        return true;
    }

    // Withdraw YGM (onlyOwner) No profit, only withdraw YGM
    function withdrawYgm(
        address _account,
        uint256 _tokenId
    ) external onlyOwner returns (bool) {
        StakingData memory _data = stakingDatas[_tokenId];
        require(_data.state == true, "tokenId isn't staked");
        require(_data.account == _account, "tokenId doesn't belong to account");
        ygm.safeTransferFrom(address(this), _account, _tokenId);
        // Update _account's stake earn Amount
        stakeEarnAmount[_account] = getReward(_account);

        // Delete tokenId in stakingTokenIds
        _deleteTokenIdInList(_account, _tokenId);

        // Delete tokenId in stakingDatas
        delete stakingDatas[_tokenId];

        // Sub stake Totals
        stakeTotals -= 1;
        _syncDayTotalStake();
        return true;
    }

    // Get the total amount of staking on a certain day
    function getDayTotalStake(uint256 _day) external view returns (uint256) {
        return day_total_stake[_day];
    }

    // Get the total amount of USDT on a certain day
    function getDayTotalUsdt(uint256 _day) external view returns (uint256) {
        return day_total_usdt[_day];
    }

    // Get account staking tokenId list
    function getStakingTokenIds(
        address _account
    ) external view returns (uint256[] memory) {
        uint256[] memory _tokenIds = stakingTokenIds[_account];
        return _tokenIds;
    }

    // Get account staking tokenId amount
    function getStakingAmount(
        address _account
    ) external view returns (uint256) {
        return stakingTokenIds[_account].length;
    }

    // Get the index of the current day
    function getCurrentDay() external view returns (uint256) {
        uint256 _day = getDays(create_time, block.timestamp);
        return _day;
    }

    function getDays(
        uint256 _startTime,
        uint256 _endtime
    ) public view returns (uint256) {
        require(_startTime < _endtime, "Not yet start time");
        uint256 _days = (_endtime - _startTime) / perPeriod;
        return _days;
    }

    function getReward(address _sender) public view returns (uint256) {
        if (stakeTime[_sender] > 0) {
            uint256 staking_amount = stakingTokenIds[_sender].length;
            if (staking_amount == 0) {
                return stakeEarnAmount[_sender];
            }
            uint256 _start = getDays(create_time, stakeTime[_sender]);
            uint256 _end = getDays(create_time, block.timestamp);
            uint256 _totalEarn = 0;

            for (uint256 i = _start; i < _end; i++) {
                if (day_total_stake[i] > 0) {
                    uint256 _earn = (day_total_usdt[i] * staking_amount) /
                        day_total_stake[i];
                    _totalEarn += _earn;
                }
            }
            return _totalEarn + stakeEarnAmount[_sender];
        } else {
            return 0;
        }
    }

    function _syncDayTotalStake() internal {
        uint256 _days = getDays(create_time, block.timestamp);
        day_total_stake[_days] = stakeTotals;
    }

    function _withdrawEarn(address _account) internal returns (uint256) {
        // Calculate the withdrawal ratio
        uint256 _realEarnAmount;
        uint256 _days = getDays(create_time, block.timestamp);
        uint256 _earnAmount = stakeEarnAmount[_account];
        _realEarnAmount = (_earnAmount * earnRate) / 100;
        day_total_usdt[_days] += (_earnAmount - _realEarnAmount);
        require(_realEarnAmount > 0, "Insufficient withdrawal balance");
        // Reset stakeEarnAmount[account]
        delete stakeEarnAmount[_account];
        // TransferFrom USDT
        usdt.transferFrom(paymentAccount, _account, _realEarnAmount);
        return _realEarnAmount;
    }

    function _deleteTokenIdInList(address _account, uint256 _tokenId) internal {
        // Delete tokenId in stakingTokenIds
        uint256 _len = stakingTokenIds[_account].length;
        for (uint256 j = 0; j < _len; j++) {
            if (stakingTokenIds[_account][j] == _tokenId) {
                stakingTokenIds[_account][j] = stakingTokenIds[_account][
                    _len - 1
                ];
                stakingTokenIds[_account].pop();
                break;
            }
        }
        // Sub account total
        if (stakingTokenIds[_account].length == 0) {
            accountTotals -= 1;
        }
    }

    // Update stake earn (modifier)
    modifier updateEarn() {
        address _sender = _msgSender();
        if (create_time < stakeTime[_sender]) {
            stakeEarnAmount[_sender] = getReward(_sender);
        }
        stakeTime[_sender] = block.timestamp;
        _;
    }
}

contract YgmStaking is ReentrancyGuard, ERC721Holder, YgmStakingBase {
    constructor(
        address ygmAddress,
        address usdtAddress,
        address _paymentAccount,
        uint256 _create_time,
        uint256 _perPeriod
    ) {
        ygm = IERC721(ygmAddress);
        usdt = IERC20(usdtAddress);
        paymentAccount = _paymentAccount;
        create_time = uint64(_create_time);
        perPeriod = uint64(_perPeriod);
    }

    // Batch stake YGM
    function stake(
        uint256[] calldata _tokenIds
    ) external whenNotPaused nonReentrant updateEarn returns (bool) {
        address _sender = _msgSender();
        uint256 _number = _tokenIds.length;
        require(_number > 0, "invalid tokenIds");

        for (uint256 i = 0; i < _number; i++) {
            require(_tokenIds[i] > 0, "invalid tokenId");
            require(!stakingDatas[_tokenIds[i]].state, "invalid stake state");
            require(ygm.ownerOf(_tokenIds[i]) == _sender, "invalid owner");
        }

        if (stakingTokenIds[_sender].length == 0) {
            accountTotals += 1;
        }

        for (uint256 i = 0; i < _number; i++) {
            uint256 _tokenId = _tokenIds[i];
            ygm.safeTransferFrom(msg.sender, address(this), _tokenId);
            // Add  staking Datas
            StakingData storage _data = stakingDatas[_tokenId];
            _data.account = _sender;
            _data.state = true;

            // Add _tokenId in stakingTokenIds[account] list
            stakingTokenIds[msg.sender].push(_tokenId);

            emit Stake(_sender, _tokenId, block.timestamp);
        }

        // Add stake Totals
        stakeTotals += uint32(_number);
        _syncDayTotalStake();
        return true;
    }

    // Batch stake YGM
    function unStake(
        uint256[] calldata _tokenIds
    ) external whenNotPaused nonReentrant updateEarn returns (bool) {
        address _sender = _msgSender();
        uint256 _number = _tokenIds.length;
        require(_number > 0, "invalid tokenIds");
        for (uint256 i = 0; i < _number; i++) {
            uint256 _tokenId = _tokenIds[i];
            require(_tokenId > 0, "invalid tokenId");
            StakingData memory _data = stakingDatas[_tokenId];
            require(_data.account == _sender, "invalid account");
            require(_data.state, "invalid stake state");

            // SafeTransferFrom
            ygm.safeTransferFrom(address(this), _data.account, _tokenId);

            // Delete tokenId in stakingTokenIds
            _deleteTokenIdInList(_sender, _tokenId);

            // Reset staking data
            delete stakingDatas[_tokenId];

            emit UnStake(_sender, _tokenId, block.timestamp);
        }
        // Withdraw Earn
        if (stakeEarnAmount[_sender] > 0) {
            uint256 amount = _withdrawEarn(_sender);
            emit WithdrawEarn(_sender, amount, block.timestamp);
        }
        // Sub stake Totals
        stakeTotals -= uint32(_number);
        _syncDayTotalStake();
        return true;
    }

    // Withdraw Earn USDT
    // (YGM is still stake in the contract)
    function withdrawEarn()
        external
        whenNotPaused
        nonReentrant
        updateEarn
        returns (bool)
    {
        address sender = _msgSender();
        require(stakeEarnAmount[sender] > 0, "Insufficient balance");
        uint256 amount = _withdrawEarn(sender);
        emit WithdrawEarn(sender, amount, block.timestamp);
        _syncDayTotalStake();
        return true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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