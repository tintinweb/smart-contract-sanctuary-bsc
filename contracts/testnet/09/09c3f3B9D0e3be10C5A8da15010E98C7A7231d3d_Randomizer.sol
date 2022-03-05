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
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract InvestorManager is Ownable, ERC1155Holder {
    struct Investor {
        address investorAddress;
        address presenterAddress;
        uint256 level;
    }

    mapping(address => Investor) public investors;
    event CreateInvestor(address investorAddress, address presenterAddress);

    function createInvestor(address investorAddress, address presenterAddress) internal {
        investors[investorAddress] = Investor({
            investorAddress: investorAddress,
            presenterAddress: presenterAddress,
            level: investors[presenterAddress].level + 1
        });
        emit CreateInvestor(investorAddress, presenterAddress);
    }

    function createNormalUser(address investorAddress, address presenterAddress) public onlyOwner {
        if (isInvestor(investorAddress)) return;
        require(isInvestor(presenterAddress), 'PRESENTER_NOT_FOUND');
        createInvestor(investorAddress, presenterAddress);
    }

    function isInvestor(address presenterAddress) public view returns(bool) {
        return investors[presenterAddress].level != 0;
    }
}

contract IDO is InvestorManager {
    IERC20 public myToken;
    uint256 public TOKEN_UNIT = 1e9;

    constructor(IERC20 _myToken) {
        myToken = _myToken;
        createInvestor(owner(), address(0));
    }

    function normalizePresenterAddress(address presenterAddress) internal view returns(address) {
        if (presenterAddress != address(0)) return presenterAddress;
        return owner();
    }

    mapping(address => bool) public claimed;

    uint256 public PAYOUT_EACH_CLAIM = 1000 * TOKEN_UNIT;

    function setPayoutEachClaim(uint256 _PAYOUT_EACH_CLAIM) public onlyOwner {
        PAYOUT_EACH_CLAIM = _PAYOUT_EACH_CLAIM;
    }

    uint256 public CLAIM_FEE = 0.00002 ether;

    function setClaimFee(uint256 _CLAIM_FEE) public onlyOwner {
        CLAIM_FEE = _CLAIM_FEE;
    }

    function claim(address presenterAddress) public payable virtual {
        require(!claimed[msg.sender], 'ALREADY_CLAIMED');
        require(msg.value >= CLAIM_FEE, 'INSUFFICIENT_FUND');
        createNormalUser(msg.sender, normalizePresenterAddress(presenterAddress));
        claimed[msg.sender] = true;
        payWithCommission(msg.sender, PAYOUT_EACH_CLAIM);
    }

    function unclaim(address account) public onlyOwner {
        claimed[account] = false;
    }

    uint256 public totalPayout = 0;

    function payWithCommission(address receiver, uint256 value) internal {
        Payment[] memory payments = getPayments(receiver, value);
        uint256 payout = 0;
        for (uint256 index = 0; index < payments.length; index++) {
            Payment memory payment = payments[index];
            if (payment.value == 0 || payment.receiver == address(0)) continue;
            myToken.transfer(payment.receiver, payment.value);
            payout += payment.value;
        }
        totalPayout += payout;
    }

    struct Payment {
        uint256 value;
        address receiver;
    }

    uint256[] public rates = [100, 15, 5, 5];

    function getPayments(address receiver, uint256 value) public view returns(Payment[] memory result) {
        uint length = rates.length;
        result = new Payment[](rates.length);

        Investor memory current = investors[receiver];

        for (uint256 index = 0; index < length; index++) {
            if (current.investorAddress == address(0)) return result;
            result[index] = Payment({ receiver: current.investorAddress, value: value * rates[index] / 100 });
            current = getPresenter(current.investorAddress);
        }
        return result;
    }

    function getPresenter(address investorAddress) private view returns(Investor memory) {
        address presenterAddress = investors[investorAddress].presenterAddress;
        return investors[presenterAddress];
    }

    function withdrawCoin() public onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken(IERC20 token, uint256 amount) public onlyOwner() {
        token.transfer(msg.sender, amount);
    }
}

contract Types {
    enum RewardType { ERC1155, COIN, USDT, MAN, MON, NOTHING }
}

contract Randomizer is Ownable {
    uint256 public ERC1155_RATE = 2;
    uint256 public COIN_RATE = 3;
    uint256 public MAN_RATE = 5;
    uint256 public USDT_RATE = 3;
    uint256 public MON_RATE = 20;

    function setRates(uint256 _ERC1155_RATE, uint256 _MAN_RATE, uint256 _COIN_RATE, uint256 _USDT_RATE, uint256 _MON_RATE) public onlyOwner {
        ERC1155_RATE = _ERC1155_RATE;
        COIN_RATE = _COIN_RATE;
        MAN_RATE = _MAN_RATE;
        USDT_RATE = _USDT_RATE;
        MON_RATE = _MON_RATE;
    }

    function get() public view returns(Types.RewardType) {
        uint256 randomIn100 = getRandomIn100(block.timestamp, _msgSender());

        uint256 m1 = ERC1155_RATE;
        uint256 m2 = m1 + COIN_RATE;
        uint256 m3 = m2 + MAN_RATE;
        uint256 m4 = m3 + USDT_RATE;
        uint256 m5 = m4 + MON_RATE;

        if (randomIn100 < m1) return Types.RewardType.ERC1155;
        if (randomIn100 < m2) return Types.RewardType.COIN;
        if (randomIn100 < m3) return Types.RewardType.MAN;
        if (randomIn100 < m4) return Types.RewardType.USDT;
        if (randomIn100 < m5) return Types.RewardType.MON;

        return Types.RewardType.NOTHING;
    }
  
    function getRandomIn100(uint256 timestamp, address sender) public pure returns(uint256) {
        return uint256(keccak256(abi.encodePacked(timestamp, sender))) % 100;
    }
}

contract IDOWithReward is IDO {
    IERC1155 public erc1155ForReward;
    IERC20 public usdt;
    IERC20 public mon;
    IERC20 public man;
    Randomizer public randomizer;

    constructor(IERC20 _man, IERC20 _usdt, IERC20 _mon, IERC1155 _erc1155ForReward, Randomizer _randomizer) IDO(_man) {
        erc1155ForReward = _erc1155ForReward;
        usdt = _usdt;
        randomizer = _randomizer;
        mon = _mon;
        man = _man;
    }

    function setRandomizer(Randomizer _randomizer) public onlyOwner {
        randomizer = _randomizer;
    }

    event Reward(Types.RewardType rewardType);

    function claim(address presenterAddress) public payable override {
        super.claim(presenterAddress);

        Types.RewardType randomRewardType = randomizer.get();

        if (randomRewardType == Types.RewardType.NOTHING) return payNothing();

        if (randomRewardType == Types.RewardType.ERC1155) {
            return isAbleToPayERC1155() ? payERC1155() : payNothing();
        }

        if (randomRewardType == Types.RewardType.COIN) {
            return isAbleToPayCoin() ? payCoin() : payNothing();
        }

        if (randomRewardType == Types.RewardType.MAN) {
            return isAbleToPayMan() ? payMan() : payNothing();
        }

        if (randomRewardType == Types.RewardType.USDT) {
            return isAbleToPayUsdt() ? payUsdt() : payNothing();
        }

        if (randomRewardType == Types.RewardType.MON) {
            return isAbleToPayMon() ? payMon() : payNothing();
        }

        revert("INVALID_RANDOM_VALUE");
    }

    uint256 public erc1155TokenId = 0;

    uint256 public erc1155Quantity = 1;

    function isAbleToPayERC1155() public view returns(bool) {
        return erc1155ForReward.balanceOf(address(this), erc1155TokenId) >= erc1155Quantity;
    }

    function payERC1155() internal {
        erc1155ForReward.safeTransferFrom(
            address(this),
            _msgSender(),
            erc1155TokenId,
            erc1155Quantity,
            ""
        );
        emit Reward(Types.RewardType.ERC1155);
    }

    uint256 public COIN_REWARD_AMOUNT = 2 ether;

    function isAbleToPayCoin() public view returns(bool) {
        return address(this).balance >= COIN_REWARD_AMOUNT;
    }

    function setCoinRewardAmount(uint256 _COIN_REWARD_AMOUNT) public onlyOwner {
        COIN_REWARD_AMOUNT = _COIN_REWARD_AMOUNT;
    }

    function payCoin() internal {
        payable(_msgSender()).transfer(COIN_REWARD_AMOUNT);
        emit Reward(Types.RewardType.COIN);
    }

    uint256 public MAN_REWARD_AMOUNT = 25000 * 5 * 1e9;

    function isAbleToPayMan() public view returns(bool) {
        return man.balanceOf(address(this)) >= MAN_REWARD_AMOUNT;
    }

    function payMan() internal {
        man.transfer(_msgSender(), MAN_REWARD_AMOUNT);
        emit Reward(Types.RewardType.MAN);
    }

    function setManRewardAmount(uint256 _MAN_REWARD_AMOUNT) public onlyOwner {
        MAN_REWARD_AMOUNT = _MAN_REWARD_AMOUNT;
    }

    uint256 public USDT_REWARD_AMOUNT = 50 * 1000000;

    function isAbleToPayUsdt() public view returns(bool) {
        return usdt.balanceOf(address(this)) >= USDT_REWARD_AMOUNT;
    }

    function setUsdtRewardAmount(uint256 _USDT_REWARD_AMOUNT) public onlyOwner {
        USDT_REWARD_AMOUNT = _USDT_REWARD_AMOUNT;
    }

    function payUsdt() internal {
        usdt.transfer(_msgSender(), USDT_REWARD_AMOUNT);
        emit Reward(Types.RewardType.USDT);
    }

    uint256 public MON_REWARD_AMOUNT = 25000 * 1e18;

    function isAbleToPayMon() public view returns(bool) {
        return mon.balanceOf(address(this)) >= MON_REWARD_AMOUNT;
    }

    function setMonRewardAmount(uint256 _MON_REWARD_AMOUNT) public onlyOwner {
        MON_REWARD_AMOUNT = _MON_REWARD_AMOUNT;
    }

    function payMon() internal {
        usdt.transfer(_msgSender(), MON_REWARD_AMOUNT);
        emit Reward(Types.RewardType.MON);
    }

    function payNothing() internal {
        emit Reward(Types.RewardType.NOTHING);
    }
}