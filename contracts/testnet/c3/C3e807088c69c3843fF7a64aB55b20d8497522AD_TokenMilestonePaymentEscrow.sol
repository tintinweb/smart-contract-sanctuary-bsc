// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import './interface/ITokenMilestonePaymentEscrow.sol';
import './interface/ITokenMilestonePaymentEscrowNFT.sol';

contract TokenMilestonePaymentEscrow is AccessControl, ITokenMilestonePaymentEscrow {
    using Counters for Counters.Counter;

    bytes32 public constant CREATIVE_REWARDS_WITHDRAWER_ROLE = keccak256('CREATIVE_REWARDS_WITHDRAWER_ROLE');
    bytes32 public constant CREATIVE_REWARDS_SETTER_ROLE = keccak256('CREATIVE_REWARDS_SETTER_ROLE');
    uint8 public constant ESCROW_ID_SUFFIX = 12;

    uint256 public creativeRewardPercent = 0.02 ether;
    uint256 public discountCreativeRewardPercent = 0.002 ether;
    uint256 public discountEARHolding = 998 ether;

    uint256 public buyerIncentive100 = 3170068 ether;
    uint256 public buyerIncentive90 = 1500000 ether;
    uint256 public buyerIncentive80 = 500000 ether;
    uint256 public buyerIncentive70 = 50000 ether;
    uint256 public buyerIncentive60 = 1000 ether;

    ITokenMilestonePaymentEscrowNFT public immutable escrowNFT;
    IERC20Metadata public immutable earthaToken;

    mapping(uint256 => EscrowDetail) private _escrowDetail;
    Counters.Counter private _escrowIdTracker = Counters.Counter(1);

    mapping(IERC20Metadata => uint256) public unpaidCreativeRewards;

    constructor(ITokenMilestonePaymentEscrowNFT escrowNFT_, IERC20Metadata earthaToken_) AccessControl() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CREATIVE_REWARDS_WITHDRAWER_ROLE, _msgSender());
        _setupRole(CREATIVE_REWARDS_SETTER_ROLE, _msgSender());

        escrowNFT = escrowNFT_;
        earthaToken = earthaToken_;
    }

    modifier withdrawerOnly() {
        require(
            hasRole(CREATIVE_REWARDS_WITHDRAWER_ROLE, _msgSender()),
            'TokenEscrow: must have withdrawer role to withdrawCreativeRewards'
        );
        _;
    }
    modifier setterOnly() {
        require(
            hasRole(CREATIVE_REWARDS_SETTER_ROLE, _msgSender()),
            'TokenEscrow: must have setter role to setCreativeRewards'
        );
        _;
    }

    function createEscrow(
        address to,
        uint256 value,
        bool canRefund,
        uint256 terminatedTime,
        uint256 canRefundTime,
        IERC20Metadata token,
        bool isSellerBurden
    ) external virtual override {
        uint256 creativeReward = getCreativeReward(value, to, isSellerBurden, _msgSender());
        uint256 total = value + creativeReward;
        if (isSellerBurden) {
            total = value;
        }
        require(token.allowance(_msgSender(), address(this)) > total);
        token.transferFrom(_msgSender(), address(this), total);
        uint256 buyerIncentive = getBuyerIncentive(creativeReward, _msgSender());
        EscrowDetail memory ed =
            EscrowDetail({
                creater: _msgSender(),
                recipient: to,
                createrTokenId: 0,
                recipientTokenId: 0,
                value: value,
                valueBalance: value,
                creativeReward: creativeReward,
                buyerIncentive: buyerIncentive,
                status: EscrowStatus.Pending,
                token: token,
                canRefund: canRefund,
                terminatedTime: terminatedTime,
                canRefundTime: canRefundTime,
                isSellerBurden: isSellerBurden
            });
        uint256 escrowId = _escrowIdTracker.current() * 100 + ESCROW_ID_SUFFIX;
        _escrowDetail[escrowId] = ed;
        _escrowIdTracker.increment();

        emit CreateNewEscrow(escrowId, ed.creater, ed.recipient);
    }

    function buyerSettlement(uint256 escrowId) external virtual override {
        EscrowDetail storage ed = _escrowDetail[escrowId];
        address createrAddress = ed.createrTokenId != 0 ? escrowNFT.ownerOf(ed.createrTokenId) : ed.creater;
        address recipientAddress = ed.recipientTokenId != 0 ? escrowNFT.ownerOf(ed.recipientTokenId) : ed.recipient;
        require(createrAddress == _msgSender(), 'TokenEscrow: not creater');
        require(ed.status == EscrowStatus.Pending, 'TokenEscrow: EscrowStatus is not Pending');

        ed.status = EscrowStatus.Completed;
        uint256 decimals = 10**ed.token.decimals();
        uint256 percent = (ed.valueBalance*decimals)/ed.value;

        uint256 creativeReward = ((ed.creativeReward * percent) / decimals);
        uint256 buyerIncentive = ((ed.buyerIncentive * percent) / decimals);

        unpaidCreativeRewards[ed.token] += (creativeReward - buyerIncentive);

        uint256 value = ed.valueBalance;
        if (ed.isSellerBurden) {
            value -= creativeReward;
        }
        ed.valueBalance = 0;

        ed.token.transfer(recipientAddress, value);
        ed.token.transfer(createrAddress, buyerIncentive);

        emit BuyerSettlement(escrowId, createrAddress, recipientAddress, value, ed);
    }

    function buyerSettlement(uint256 escrowId,uint256 amount) external virtual override {
        EscrowDetail storage ed = _escrowDetail[escrowId];
        address createrAddress = ed.createrTokenId != 0 ? escrowNFT.ownerOf(ed.createrTokenId) : ed.creater;
        address recipientAddress = ed.recipientTokenId != 0 ? escrowNFT.ownerOf(ed.recipientTokenId) : ed.recipient;
        require(createrAddress == _msgSender(), 'TokenEscrow: not creater');
        require(ed.status == EscrowStatus.Pending, 'TokenEscrow: EscrowStatus is not Pending');
        require(ed.valueBalance >= amount, 'TokenEscrow: Not enough balance');

        if(ed.valueBalance == amount) {
            ed.status = EscrowStatus.Completed;
        }
        uint256 decimals = 10**ed.token.decimals();
        uint256 percent = (amount*decimals)/ed.value;

        uint256 creativeReward = ((ed.creativeReward * percent) / decimals);
        uint256 buyerIncentive = ((ed.buyerIncentive * percent) / decimals);

        unpaidCreativeRewards[ed.token] += (creativeReward - buyerIncentive);

        uint256 value = amount;
        if (ed.isSellerBurden) {
            value -= creativeReward;
        }
        ed.valueBalance -= amount;

        ed.token.transfer(recipientAddress, value);
        ed.token.transfer(createrAddress, buyerIncentive);

        emit BuyerSettlement(escrowId, createrAddress, recipientAddress, value, ed);
    }

    function sellerSettlement(uint256 escrowId) external virtual override {
        EscrowDetail storage ed = _escrowDetail[escrowId];
        address createrAddress = ed.createrTokenId != 0 ? escrowNFT.ownerOf(ed.createrTokenId) : ed.creater;
        address recipientAddress = ed.recipientTokenId != 0 ? escrowNFT.ownerOf(ed.recipientTokenId) : ed.recipient;
        require(recipientAddress == _msgSender(), 'TokenEscrow: not recepient');
        require(ed.status == EscrowStatus.Pending, 'TokenEscrow: EscrowStatus is not Pending');
        require(ed.terminatedTime < block.timestamp, 'TokenEscrow: terminatedTime error');
        uint256 decimals = 10**ed.token.decimals();
        uint256 percent = (ed.valueBalance*decimals)/ed.value;

        uint256 creativeReward = ((ed.creativeReward * percent) / decimals);

        ed.status = EscrowStatus.Terminated;

        unpaidCreativeRewards[ed.token] += creativeReward;

        uint256 value = ed.valueBalance;
        if (ed.isSellerBurden) {
            value -= creativeReward;
        }
        ed.valueBalance = 0;

        ed.token.transfer(recipientAddress, value);

        emit SellerSettlement(escrowId, createrAddress, recipientAddress, ed, value);
    }

    function refund(uint256 escrowId) external virtual override {
        EscrowDetail storage ed = _escrowDetail[escrowId];
        address createrAddress = ed.createrTokenId != 0 ? escrowNFT.ownerOf(ed.createrTokenId) : ed.creater;
        address recipientAddress = ed.recipientTokenId != 0 ? escrowNFT.ownerOf(ed.recipientTokenId) : ed.recipient;
        require(createrAddress == _msgSender() || recipientAddress == _msgSender(), 'TokenEscrow: not user');
        require(ed.status == EscrowStatus.Pending, 'TokenEscrow: EscrowStatus is not Pending');
        require(ed.canRefund, 'TokenEscrow: can not refund');
        require(ed.canRefundTime >= block.timestamp, 'TokenEscrow: canRefundTime error');
        uint256 decimals = 10**ed.token.decimals();
        uint256 percent = (ed.valueBalance*decimals)/ed.value;

        uint256 creativeReward = ((ed.creativeReward * percent) / decimals);
        uint256 buyerIncentive = ((ed.buyerIncentive * percent) / decimals);

        uint256 total = ed.valueBalance + creativeReward-buyerIncentive;
        if (ed.isSellerBurden) {
            total = ed.valueBalance;
        }

        ed.valueBalance = 0;
        ed.status = EscrowStatus.Refunded;
        ed.token.transfer(createrAddress, total);

        emit Refund(escrowId, createrAddress, recipientAddress, total);
    }

    function createBuyerEscrowNFT(uint256 escrowId) external virtual override {
        EscrowDetail storage ed = _escrowDetail[escrowId];
        require(ed.creater == _msgSender(), 'TokenEscrow: not creater');
        require(ed.status == EscrowStatus.Pending, 'TokenEscrow: EscrowStatus is not Pending');
        require(ed.createrTokenId == 0, 'TokenEscrow: Already exists');
        uint256 tokenId = escrowNFT.mintToBuyer(ed.creater, escrowId);
        ed.createrTokenId = tokenId;
        emit CreateBuyerEscrowNFT(escrowId, tokenId, ed.creater);
    }

    function createSellerEscrowNFT(uint256 escrowId) external virtual override {
        EscrowDetail storage ed = _escrowDetail[escrowId];
        require(ed.recipient == _msgSender(), 'TokenEscrow: not recipient');
        require(ed.status == EscrowStatus.Pending, 'TokenEscrow: EscrowStatus is not Pending');
        require(ed.recipientTokenId == 0, 'TokenEscrow: Already exists');
        if (ed.canRefund) {
            require(ed.canRefundTime < block.timestamp, 'TokenEscrow: canRefundTime error');
        }
        uint256 tokenId = escrowNFT.mintToSeller(ed.recipient, escrowId);
        ed.recipientTokenId = tokenId;
        emit CreateSellerEscrowNFT(escrowId, tokenId, ed.recipient);
    }

    function getEscrowDetail(uint256 escrowId) external view virtual override returns (EscrowDetail memory) {
        return _escrowDetail[escrowId];
    }

    function withdrawCreativeRewards(address recipient, IERC20Metadata token) external virtual override withdrawerOnly() {
        require(unpaidCreativeRewards[token] > 0, 'TokenEscrow: unpaidCreativeRewards is 0');
        token.transfer(recipient, unpaidCreativeRewards[token]);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl) returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function getCreativeRewardPercent(
        address to,
        bool isSellerBurden,
        address from
    ) public view virtual override returns (uint256) {
        uint256 balance = earthaToken.balanceOf(from);
        if (isSellerBurden) {
            balance = earthaToken.balanceOf(to);
        }
        if (balance >= discountEARHolding) {
            return discountCreativeRewardPercent;
        } else {
            return creativeRewardPercent;
        }
    }

    function getCreativeReward(
        uint256 amount,
        address to,
        bool isSellerBurden,
        address from
    ) public view virtual override returns (uint256) {
        return ((amount * getCreativeRewardPercent(to, isSellerBurden, from)) / 1 ether);
    }

    function getBuyerIncentivePercent(address from) public view virtual override returns (uint256) {
        uint256 balance = earthaToken.balanceOf(from);
        uint256 percent = 0.5 ether;
        if (balance >= buyerIncentive100) {
            percent = 1 ether;
        } else if (balance >= buyerIncentive90) {
            percent = 0.9 ether;
        } else if (balance >= buyerIncentive80) {
            percent = 0.8 ether;
        } else if (balance >= buyerIncentive70) {
            percent = 0.7 ether;
        } else if (balance >= buyerIncentive60) {
            percent = 0.6 ether;
        }
        return percent;
    }

    function getBuyerIncentive(uint256 creativeReward, address from) public view virtual override returns (uint256) {
        return ((creativeReward * getBuyerIncentivePercent(from)) / 1 ether);
    }

    function setCreativeRewardPercent(uint256 reword) external virtual override setterOnly() {
        creativeRewardPercent = reword;
    }

    function setDiscountCreativeRewardPercent(uint256 discount) external virtual override setterOnly() {
        discountCreativeRewardPercent = discount;
    }

    function setBuyerIncentive(
        uint256 buyerIncentive100_,
        uint256 buyerIncentive90_,
        uint256 buyerIncentive80_,
        uint256 buyerIncentive70_,
        uint256 buyerIncentive60_
    ) external virtual override setterOnly() {
        buyerIncentive100 = buyerIncentive100_;
        buyerIncentive90 = buyerIncentive90_;
        buyerIncentive80 = buyerIncentive80_;
        buyerIncentive70 = buyerIncentive70_;
        buyerIncentive60 = buyerIncentive60_;
    }

    function setDiscountEARHolding(uint256 ear) external virtual override setterOnly() {
        discountEARHolding = ear;
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

interface ITokenMilestonePaymentEscrowNFT is IERC721 {
    function totalSupply() external view returns (uint256);

    function mintToBuyer(address to, uint256 escrowId) external returns (uint256);
    function mintToSeller(address to, uint256 escrowId) external returns (uint256);
}

// SPDX-License-Identifier: GPL-2.0-or-later
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
pragma solidity ^0.8.4;

interface ITokenMilestonePaymentEscrow {
    event CreateNewEscrow(uint256 escrowId, address indexed creater, address indexed recipient);
    event BuyerSettlement(
        uint256 indexed escrowId,
        address indexed creater,
        address indexed recipient,
        uint256 amount,
        EscrowDetail ed
    );
    event SellerSettlement(
        uint256 indexed escrowId,
        address indexed creater,
        address indexed recipient,
        EscrowDetail ed,
        uint256 amount
    );
    event Refund(
        uint256 indexed escrowId,
        address indexed creater,
        address indexed recipient,
        uint256 amount
    );
    event CreateBuyerEscrowNFT(uint256 indexed escrowId, uint256 tokenId, address tokenCreater);
    event CreateSellerEscrowNFT(uint256 indexed escrowId, uint256 tokenId, address tokenCreater);

    enum EscrowStatus {Pending, Completed, Terminated, Refunded}

    struct EscrowDetail {
        address creater;
        address recipient;
        uint256 createrTokenId;
        uint256 recipientTokenId;
        uint256 value;
        uint256 valueBalance;
        uint256 creativeReward;
        uint256 buyerIncentive;
        IERC20Metadata token;
        EscrowStatus status;
        bool canRefund;
        uint256 canRefundTime;
        uint256 terminatedTime;
        bool isSellerBurden;
    }

    function createEscrow(
        address to,
        uint256 value,
        bool canRefund,
        uint256 terminatedTime,
        uint256 canRefundTime,
        IERC20Metadata token,
        bool isSellerBurden
    ) external;

    function buyerSettlement(uint256 escrowId) external;

    function buyerSettlement(uint256 escrowId,uint256 amount) external;

    function sellerSettlement(uint256 escrowId) external;

    function refund(uint256 escrowId) external;

    function createBuyerEscrowNFT(uint256 escrowId) external;

    function createSellerEscrowNFT(uint256 escrowId) external;

    function getEscrowDetail(uint256 escrowId) external view returns (EscrowDetail memory);

    function withdrawCreativeRewards(address recipient, IERC20Metadata token) external;

    function getCreativeReward(
        uint256 amount,
        address to,
        bool isSellerBurden,
        address from
    ) external returns (uint256);

    function getCreativeRewardPercent(
        address to,
        bool isSellerBurden,
        address from
    ) external returns (uint256);

    function setCreativeRewardPercent(uint256 reword) external;

    function setDiscountCreativeRewardPercent(uint256 discount) external;

    function setBuyerIncentive(
        uint256 buyerIncentive100_,
        uint256 buyerIncentive90_,
        uint256 buyerIncentive80_,
        uint256 buyerIncentive70_,
        uint256 buyerIncentive60_
    ) external;

    function setDiscountEARHolding(uint256 ear) external;

    function getBuyerIncentive(uint256 creativeReward, address from) external returns (uint256);

    function getBuyerIncentivePercent(address from) external returns (uint256);
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}