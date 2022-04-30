// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./FixedStaking.sol";
import "./FlexibleStaking.sol";

contract Tiers is ERC1155Holder, Ownable {
    FixedStaking public fixedStaking;
    FlexibleStaking public flexibleStaking;

    uint256 public requiredPercent = 20;
    uint256[5] public tiers = [1, 2000 ether, 5000 ether, 10000 ether, 20000 ether];

    constructor(
        address _fixedStaking,
        address _flexibleStaking,
        uint256 _requiredPercent,
        uint256[5] memory _tiers
    ) {
        fixedStaking = FixedStaking(_fixedStaking);
        flexibleStaking = FlexibleStaking(_flexibleStaking);
        requiredPercent = _requiredPercent;
        for (uint256 i = 0; i < tiers.length; i++) {
            tiers[i] = _tiers[i];
        }
    }

    function changeRequiredPercent(uint256 _requiredPercent)
        external
        onlyOwner
    {
        require(
            _requiredPercent >= 0 && _requiredPercent <= 100,
            "Required percent should be between 0 and 100"
        );
        requiredPercent = _requiredPercent;
    }

    function changeTiers(uint256[5] calldata _tiers) external onlyOwner {
        tiers = _tiers;
    }

    function checkUserTier(address _account) external view returns (uint256) {
        uint256 totalFixedStaked = fixedStaking.userTotalStaked(_account);
        uint256 totalFlexibleStaked = flexibleStaking.userStake(_account);
        uint256 totalUserStaked = (totalFlexibleStaked * requiredPercent) /
            100 +
            totalFixedStaked;
        for (uint256 i = 0; i < tiers.length; i++) {
            if (totalUserStaked < tiers[i]) {
                return i;
            }
        }
        return tiers.length;
    }

    function getTiers() external view returns (uint256[5] memory) {
        return tiers;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FixedStaking is Ownable {
    IERC20 public fitToken;
    address public feeAddress;

    uint256[5] public periods = [30 days, 60 days, 90 days, 180 days, 365 days];
    uint16[5] public rates = [904, 1973, 3082, 6904, 16000];
    uint256 public FEE_RATE = 40;
    uint256[5] public rewardsPool;
    uint256 public MAX_STAKES = 100;

    struct Stake {
        uint8 class;
        uint256 initialAmount;
        uint256 finalAmount;
        uint256 timestamp;
        bool unstaked;
    }

    Stake[] public stakes;
    mapping(address => uint256[]) public stakesOf;
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public totalStaked;

    event Staked(
        address indexed sender,
        uint8 indexed class,
        uint256 amount,
        uint256 finalAmount
    );
    event Unstaked(address indexed sender, uint8 indexed class, uint256 amount);
    event IncreaseRewardsPool(address indexed adder, uint256 added);
    event IncreaseRewardPoolForClass(
        address indexed adder,
        uint256 added,
        uint8 class
    );

    constructor(IERC20 _fitToken, address _feeAddress) {
        fitToken = _fitToken;
        feeAddress = _feeAddress;
    }

    function stakesInfo(uint256 _from, uint256 _to)
        public
        view
        returns (Stake[] memory s)
    {
        s = new Stake[](_to - _from);
        for (uint256 i = _from; i < _to; i++) s[i - _from] = stakes[i];
    }

    function stakesInfoAll() public view returns (Stake[] memory s) {
        uint256 stakeLength = stakes.length;
        s = new Stake[](stakeLength);
        for (uint256 i = 0; i < stakeLength; i++) s[i] = stakes[i];
    }

    function stakesLength() public view returns (uint256) {
        return stakes.length;
    }

    function myStakes(address _me)
        public
        view
        returns (Stake[] memory s, uint256[] memory indexes)
    {
        uint256 stakeLength = stakesOf[_me].length;
        s = new Stake[](stakeLength);
        indexes = new uint256[](stakeLength);
        for (uint256 i = 0; i < stakeLength; i++) {
            indexes[i] = stakesOf[_me][i];
            s[i] = stakes[indexes[i]];
        }
    }

    function myActiveStakesCount(address _me) public view returns (uint256 l) {
        uint256[] storage _s = stakesOf[_me];
        uint256 stakeLength = _s.length;
        for (uint256 i = 0; i < stakeLength; i++)
            if (!stakes[_s[i]].unstaked) l++;
    }

    function stake(uint8 _class, uint256 _amount) public {
        require(_class < 5, "Wrong class");
        require(_amount > 0, "Cannot Stake 0 Tokens");
        require(
            myActiveStakesCount(msg.sender) < MAX_STAKES,
            "MAX_STAKES overflow"
        );
        uint256 _finalAmount = _amount + (_amount * rates[_class]) / 10000;
        require(
            rewardsPool[_class] >= _finalAmount - _amount,
            "Rewards pool is empty for now"
        );
        rewardsPool[_class] -= _finalAmount - _amount;
        fitToken.transferFrom(msg.sender, address(this), _amount);
        uint256 _index = stakes.length;
        stakesOf[msg.sender].push(_index);
        stakes.push(
            Stake({
                class: _class,
                initialAmount: _amount,
                finalAmount: _finalAmount,
                timestamp: block.timestamp,
                unstaked: false
            })
        );
        ownerOf[_index] = msg.sender;
        totalStaked[msg.sender] += _amount;
        emit Staked(msg.sender, _class, _amount, _finalAmount);
    }

    function unstake(uint256 _index) public {
        require(msg.sender == ownerOf[_index], "Not correct index");
        Stake storage _s = stakes[_index];
        require(!_s.unstaked, "Already unstaked");
        require(
            block.timestamp >= _s.timestamp + periods[_s.class],
            "Staking period not finished"
        );
        uint256 _reward = (_s.initialAmount * rates[_s.class]) / 10000;
        uint256 total = _s.initialAmount + _reward;
        uint256 _fee = (_reward * FEE_RATE) / 1000;
        total -= _fee;
        fitToken.transfer(feeAddress, _fee);
        fitToken.transfer(msg.sender, total);
        _s.unstaked = true;
        totalStaked[msg.sender] -= _s.initialAmount;
        emit Unstaked(msg.sender, _s.class, _s.finalAmount);
    }

    function returnAccidentallySent(IERC20 _fitToken) public onlyOwner {
        require(
            address(_fitToken) != address(fitToken),
            "Unable to withdraw staking token"
        );
        uint256 _amount = _fitToken.balanceOf(address(this));
        _fitToken.transfer(msg.sender, _amount);
    }

    function increaseRewardsPool(uint256[] memory _amount) public onlyOwner {
        require(_amount.length == rates.length, "Only 5 amount valid");
        uint256 amountLength = _amount.length;
        uint256 summary = 0;
        for (uint256 i = 0; i < amountLength; i++) {
            rewardsPool[i] += _amount[i];
            summary += _amount[i];
        }
        fitToken.transferFrom(msg.sender, address(this), summary);
        emit IncreaseRewardsPool(msg.sender, summary);
    }

    function increaseRewardPoolForClass(uint8 _class, uint256 _amount)
        public
        onlyOwner
    {
        require(_class < 5, "Wrong class");
        rewardsPool[_class] += _amount;
        fitToken.transferFrom(msg.sender, address(this), _amount);
        emit IncreaseRewardPoolForClass(msg.sender, _amount, _class);
    }

    function updateMax(uint256 _max) external onlyOwner {
        MAX_STAKES = _max;
    }

    function changeFeeAddress(address newFeeAddress) external onlyOwner {
        require(newFeeAddress != address(0), "Zero address");
        feeAddress = newFeeAddress;
    }

    function updateFeeRate(uint256 newFeeRate) external onlyOwner {
        FEE_RATE = newFeeRate;
    }

    function userTotalStaked(address _account) public view returns (uint256) {
        return totalStaked[_account];
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlexibleStaking is Ownable {
    IERC20 public fitToken;
    address public cashbackAddr;

    uint256 public rewardPool;
    // About 1000 tokens per day
    uint256 public rewardRate = 11574074074074074;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 public totalValueLocked;
    mapping(address => uint256) balances;

    modifier onlyCashback() {
        require(msg.sender == cashbackAddr);
        _;
    }

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        uint256 reward = earned(_account);
        rewards[_account] = reward;
        userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        _;
    }

    constructor(address _fitToken, address _cashbackAddr) {
        fitToken = IERC20(_fitToken);
        cashbackAddr = _cashbackAddr;
    }

    function increaseRewardPool(uint256 _amount) external onlyOwner {
        fitToken.transferFrom(msg.sender, address(this), _amount);
        rewardPool += _amount;
    }

    function changeRewardRate(uint256 _amount) external onlyOwner {
        rewardRate = _amount;
    }

    function stake(uint256 _amount) external {
        _stake(msg.sender, _amount, msg.sender);
    }

    function stakeFromCashback(address _user, uint256 _amount)
        external
        onlyCashback
    {
        _stake(_user, _amount, msg.sender);
    }

    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "Reward should be more than 0");
        require(
            rewardPool >= rewards[msg.sender],
            "Reward pool is less than your reward"
        );
        rewards[msg.sender] = 0;
        rewardPool -= reward;
        fitToken.transfer(msg.sender, reward);
    }

    function withdraw() external updateReward(msg.sender) {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Amount should be more than 0");
        require(
            totalValueLocked >= amount,
            "Total supply is less than amount to withdraw"
        );
        totalValueLocked -= amount;
        balances[msg.sender] = 0;
        fitToken.transfer(msg.sender, amount);
    }

    function userStake(address _account) external view returns (uint256) {
        return balances[_account];
    }

    function getAPYStaked() public view returns (uint256) {
        return (rewardRate * 60 * 60 * 24 * 365 * 100) / totalValueLocked;
    }

    function getAPYNotStaked(uint256 _stake) public view returns (uint256) {
        return (rewardRate * 60 * 60 * 24 * 365 * 100) / (totalValueLocked + _stake);
    }

    function earnedAlready(address _account) external view returns (uint256) {
        uint256 _rewardPerTokenStored = rewardPerToken();
        uint256 _lastUpdateTime = block.timestamp;
        uint256 _rewardPerToken;
        if (totalValueLocked == 0) {
            _rewardPerToken = rewardPerTokenStored;
        } else {
            _rewardPerToken =
                _rewardPerTokenStored +
                (((block.timestamp - _lastUpdateTime) * rewardRate * 1e32) /
                    totalValueLocked);
        }
        uint256 reward = ((balances[_account] *
            (_rewardPerToken - userRewardPerTokenPaid[_account])) / 1e32) +
            rewards[_account];
        return reward;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalValueLocked == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e32) /
                totalValueLocked);
    }

    function _stake(
        address _staker,
        uint256 _amount,
        address _payer
    ) internal updateReward(_staker) {
        require(_amount > 0, "Amount should be more than 0");
        totalValueLocked += _amount;
        balances[_staker] += _amount;
        fitToken.transferFrom(_payer, address(this), _amount);
    }

    function earned(address _account) internal view returns (uint256) {
        return
            ((balances[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e32) +
            rewards[_account];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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