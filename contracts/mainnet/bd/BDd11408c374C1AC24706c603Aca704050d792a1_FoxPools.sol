// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ExchangeDomainV1 {

    enum AssetType {NO_USE, ETH, ERC20, ERC1155, ERC721, ERC721Deprecated}

    struct Asset {
        address token;
        uint tokenId;
        AssetType assetType;
    }

    struct OrderKey {
        /* who signed the order */
        address owner;
        /* random number */
        uint salt;

        /* what has owner */
        Asset sellAsset;

        /* what wants owner */
        Asset buyAsset;
    }

    struct Order {
        OrderKey key;

        /* how much has owner (in wei, or UINT256_MAX if ERC-721) */
        uint selling;
        /* how much wants owner (in wei, or UINT256_MAX if ERC-721) */
        uint buying;

        /* fee for selling */
        uint sellerFee;
    }

    /* An ECDSA signature. */
    struct Sig {
        /* v parameter */
        uint8 v;
        /* r parameter */
        bytes32 r;
        /* s parameter */
        bytes32 s;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./ExchangeDomainV1.sol";
import "./ExchangeStateV1.sol";
import "./ExchangeOrdersHolderV1.sol";
import "../tokens/HasSecondarySaleFees.sol";
import "../utils/Bytes.sol";
import "../utils/String.sol";
import "../utils/Uint.sol";
import "../proxy/ERC20TransferProxy.sol";
import "../proxy/TransferProxy.sol";
import "../proxy/TransferProxyForDeprecated.sol";



contract ExchangeV1 is Ownable, ExchangeDomainV1 {
    using SafeMath for uint;
    using UintLibrary for uint;
    using StringLibrary for string;
    using BytesLibrary for bytes32;

    enum FeeSide {NONE, SELL, BUY}

    event Buy(
        address indexed sellToken, uint256 indexed sellTokenId, uint256 sellValue,
        address owner,
        address buyToken, uint256 buyTokenId, uint256 buyValue,
        address buyer,
        uint256 amount,
        uint256 salt
    );

    event Cancel(
        address indexed sellToken, uint256 indexed sellTokenId,
        address owner,
        address buyToken, uint256 buyTokenId,
        uint256 salt
    );

    bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;
    uint256 private constant UINT256_MAX = 2 ** 256 - 1;

    address payable public beneficiary;
    address public buyerFeeSigner;

    TransferProxy public transferProxy;
    TransferProxyForDeprecated public transferProxyForDeprecated;
    ERC20TransferProxy public erc20TransferProxy;
    ExchangeStateV1 public state;
    ExchangeOrdersHolderV1 public ordersHolder;

    constructor(
        TransferProxy _transferProxy, TransferProxyForDeprecated _transferProxyForDeprecated, ERC20TransferProxy _erc20TransferProxy, ExchangeStateV1 _state,
        ExchangeOrdersHolderV1 _ordersHolder, address payable _beneficiary, address _buyerFeeSigner
    ) {
        transferProxy = _transferProxy;
        transferProxyForDeprecated = _transferProxyForDeprecated;
        erc20TransferProxy = _erc20TransferProxy;
        state = _state;
        ordersHolder = _ordersHolder;
        beneficiary = _beneficiary;
        buyerFeeSigner = _buyerFeeSigner;
    }

    function setBeneficiary(address payable newBeneficiary) external onlyOwner {
        beneficiary = newBeneficiary;
    }

    function setBuyerFeeSigner(address newBuyerFeeSigner) external onlyOwner {
        buyerFeeSigner = newBuyerFeeSigner;
    }

    function exchange(
        Order calldata order,
        Sig calldata sig,
        uint buyerFee,
        Sig calldata buyerFeeSig,
        uint amount,
        address buyer
    ) payable external {
        validateOrderSig(order, sig);
        validateBuyerFeeSig(order, buyerFee, buyerFeeSig);
        uint paying = order.buying.mul(amount).div(order.selling);
        verifyOpenAndModifyOrderState(order.key, order.selling, amount);
        require(order.key.sellAsset.assetType != AssetType.ETH, "ETH is not supported on sell side");
        if (order.key.buyAsset.assetType == AssetType.ETH) {
            validateEthTransfer(paying, buyerFee);
        }
        FeeSide feeSide = getFeeSide(order.key.sellAsset.assetType, order.key.buyAsset.assetType);
        if (buyer == address(0x0)) {
            buyer = msg.sender;
        }
        transferWithFeesPossibility(order.key.sellAsset, amount, order.key.owner, buyer, feeSide == FeeSide.SELL, buyerFee, order.sellerFee, order.key.buyAsset);
        transferWithFeesPossibility(order.key.buyAsset, paying, msg.sender, order.key.owner, feeSide == FeeSide.BUY, order.sellerFee, buyerFee, order.key.sellAsset);
        emitBuy(order, amount, buyer);
    }

    function validateEthTransfer(uint value, uint buyerFee) internal view {
        uint256 buyerFeeValue = value.bp(buyerFee);
        require(msg.value == value + buyerFeeValue, "msg.value is incorrect");
    }

    function cancel(OrderKey calldata key) external {
        require(key.owner == msg.sender, "not an owner");
        state.setCompleted(key, UINT256_MAX);
        emit Cancel(key.sellAsset.token, key.sellAsset.tokenId, msg.sender, key.buyAsset.token, key.buyAsset.tokenId, key.salt);
    }

    function validateOrderSig(
        Order memory order,
        Sig memory sig
    ) internal view {
        if (sig.v == 0 && sig.r == bytes32(0x0) && sig.s == bytes32(0x0)) {
            require(ordersHolder.exists(order), "incorrect signature");
        } else {
            require(prepareMessage(order).recover(sig.v, sig.r, sig.s) == order.key.owner, "incorrect signature");
        }
    }

    function validateBuyerFeeSig(
        Order memory order,
        uint buyerFee,
        Sig memory sig
    ) internal view {
        require(prepareBuyerFeeMessage(order, buyerFee).recover(sig.v, sig.r, sig.s) == buyerFeeSigner, "incorrect buyer fee signature");
    }

    function prepareBuyerFeeMessage(Order memory order, uint fee) public pure returns (string memory) {
        return keccak256(abi.encode(order, fee)).toString();
    }

    function prepareMessage(Order memory order) public pure returns (string memory) {
        return keccak256(abi.encode(order)).toString();
    }

    function transferWithFeesPossibility(Asset memory firstType, uint value, address from, address to, bool hasFee, uint256 sellerFee, uint256 buyerFee, Asset memory secondType) internal {
        if (!hasFee) {
            transfer(firstType, value, from, to);
        } else {
            transferWithFees(firstType, value, from, to, sellerFee, buyerFee, secondType);
        }
    }

    function transfer(Asset memory asset, uint value, address from, address to) internal {
        if (asset.assetType == AssetType.ETH) {
            payable(to).transfer(value);
        } else if (asset.assetType == AssetType.ERC20) {
            require(asset.tokenId == 0, "tokenId should be 0");
            erc20TransferProxy.erc20safeTransferFrom(IERC20(asset.token), from, to, value);
        } else if (asset.assetType == AssetType.ERC721) {
            require(value == 1, "value should be 1 for ERC-721");
            transferProxy.erc721safeTransferFrom(IERC721(asset.token), from, to, asset.tokenId);
        } else if (asset.assetType == AssetType.ERC721Deprecated) {
            require(value == 1, "value should be 1 for ERC-721");
            transferProxyForDeprecated.erc721TransferFrom(IERC721(asset.token), from, to, asset.tokenId);
        } else {
            transferProxy.erc1155safeTransferFrom(IERC1155(asset.token), from, to, asset.tokenId, value, "");
        }
    }

    function transferWithFees(Asset memory firstType, uint value, address from, address to, uint256 sellerFee, uint256 buyerFee, Asset memory secondType) internal {
        uint restValue = transferFeeToBeneficiary(firstType, from, value, sellerFee, buyerFee);
        if (
            secondType.assetType == AssetType.ERC1155 && IERC1155(secondType.token).supportsInterface(_INTERFACE_ID_FEES) ||
            (secondType.assetType == AssetType.ERC721 || secondType.assetType == AssetType.ERC721Deprecated) && IERC721(secondType.token).supportsInterface(_INTERFACE_ID_FEES)
        ) {
            HasSecondarySaleFees withFees = HasSecondarySaleFees(secondType.token);
            address payable[] memory recipients = withFees.getFeeRecipients(secondType.tokenId);
            uint[] memory fees = withFees.getFeeBps(secondType.tokenId);
            require(fees.length == recipients.length);
            for (uint256 i = 0; i < fees.length; i++) {
                (uint newRestValue, uint current) = subFeeInBp(restValue, value, fees[i]);
                restValue = newRestValue;
                transfer(firstType, current, from, recipients[i]);
            }
        }

        transfer(firstType, restValue, from, payable(to));
    }

    function transferFeeToBeneficiary(Asset memory asset, address from, uint total, uint sellerFee, uint buyerFee) internal returns (uint) {
        (uint restValue, uint sellerFeeValue) = subFeeInBp(total, total, sellerFee);
        uint buyerFeeValue = total.bp(buyerFee);
        uint beneficiaryFee = buyerFeeValue.add(sellerFeeValue);
        if (beneficiaryFee > 0) {
            transfer(asset, beneficiaryFee, from, beneficiary);
        }
        return restValue;
    }

    function emitBuy(Order memory order, uint amount, address buyer) internal {
        emit Buy(order.key.sellAsset.token, order.key.sellAsset.tokenId, order.selling,
            order.key.owner,
            order.key.buyAsset.token, order.key.buyAsset.tokenId, order.buying,
            buyer,
            amount,
            order.key.salt
        );
    }

    function subFeeInBp(uint value, uint total, uint feeInBp) internal pure returns (uint newValue, uint realFee) {
        return subFee(value, total.bp(feeInBp));
    }

    function subFee(uint value, uint fee) internal pure returns (uint newValue, uint realFee) {
        if (value > fee) {
            newValue = value - fee;
            realFee = fee;
        } else {
            newValue = 0;
            realFee = value;
        }
    }

    function verifyOpenAndModifyOrderState(OrderKey memory key, uint selling, uint amount) internal {
        uint completed = state.getCompleted(key);
        uint newCompleted = completed.add(amount);
        require(newCompleted <= selling, "not enough stock of order for buying");
        state.setCompleted(key, newCompleted);
    }

    function getFeeSide(AssetType sellType, AssetType buyType) internal pure returns (FeeSide) {
        if ((sellType == AssetType.ERC721 || sellType == AssetType.ERC721Deprecated) &&
            (buyType == AssetType.ERC721 || buyType == AssetType.ERC721Deprecated)) {
            return FeeSide.NONE;
        }
        if (uint(sellType) > uint(buyType)) {
            return FeeSide.BUY;
        }
        return FeeSide.SELL;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../role/OwnableOperatorRole.sol";
import "./ExchangeDomainV1.sol";

contract ExchangeStateV1 is OwnableOperatorRole {

    // keccak256(OrderKey) => completed
    mapping(bytes32 => uint256) public completed;

    function getCompleted(ExchangeDomainV1.OrderKey calldata key) view external returns (uint256) {
        return completed[getCompletedKey(key)];
    }

    function setCompleted(ExchangeDomainV1.OrderKey calldata key, uint256 newCompleted) external onlyOperator {
        completed[getCompletedKey(key)] = newCompleted;
    }

    function getCompletedKey(ExchangeDomainV1.OrderKey memory key) pure public returns (bytes32) {
        return keccak256(abi.encodePacked(key.owner, key.sellAsset.token, key.sellAsset.tokenId, key.buyAsset.token, key.buyAsset.tokenId, key.salt));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./ExchangeDomainV1.sol";

contract ExchangeOrdersHolderV1 {

    mapping(bytes32 => OrderParams) internal orders;

    struct OrderParams {
        /* how much has owner (in wei, or UINT256_MAX if ERC-721) */
        uint selling;
        /* how much wants owner (in wei, or UINT256_MAX if ERC-721) */
        uint buying;

        /* fee for selling */
        uint sellerFee;
    }

    function add(ExchangeDomainV1.Order calldata order) external {
        require(msg.sender == order.key.owner, "order could be added by owner only");
        bytes32 key = prepareKey(order);
        orders[key] = OrderParams(order.selling, order.buying, order.sellerFee);
    }

    function exists(ExchangeDomainV1.Order calldata order) external view returns (bool) {
        bytes32 key = prepareKey(order);
        OrderParams memory params = orders[key];
        return params.buying == order.buying && params.selling == order.selling && params.sellerFee == order.sellerFee;
    }

    function prepareKey(ExchangeDomainV1.Order memory order) internal pure returns (bytes32) {
        return keccak256(abi.encode(
                order.key.sellAsset.token,
                order.key.sellAsset.tokenId,
                order.key.owner,
                order.key.buyAsset.token,
                order.key.buyAsset.tokenId,
                order.key.salt
            ));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";

abstract contract HasSecondarySaleFees is ERC165Storage {

    event SecondarySaleFees(uint256 tokenId, address[] recipients, uint[] bps);

    /*
     * bytes4(keccak256('getFeeBps(uint256)')) == 0x0ebd4c7f
     * bytes4(keccak256('getFeeRecipients(uint256)')) == 0xb9c4d9fb
     *
     * => 0x0ebd4c7f ^ 0xb9c4d9fb == 0xb7799584
     */
    bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;

    constructor() {
        _registerInterface(_INTERFACE_ID_FEES);
    }

    function getFeeRecipients(uint256 id) external virtual view returns (address payable[] memory);
    function getFeeBps(uint256 id) external view virtual returns (uint[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library BytesLibrary {
    function toString(bytes32 value) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[i*2] = alphabet[uint8(value[i] >> 4)];
            str[1+i*2] = alphabet[uint8(value[i] & 0x0f)];
        }
        return string(str);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Uint.sol";

library StringLibrary {
    using UintLibrary for uint256;

    function append(string memory a, string memory b) internal pure returns (string memory) {
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        bytes memory bab = new bytes(ba.length + bb.length);
        uint k = 0;
        for (uint i = 0; i < ba.length; i++) bab[k++] = ba[i];
        for (uint i = 0; i < bb.length; i++) bab[k++] = bb[i];
        return string(bab);
    }

    function append(string memory a, string memory b, string memory c) internal pure returns (string memory) {
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        bytes memory bc = bytes(c);
        bytes memory bbb = new bytes(ba.length + bb.length + bc.length);
        uint k = 0;
        for (uint i = 0; i < ba.length; i++) bbb[k++] = ba[i];
        for (uint i = 0; i < bb.length; i++) bbb[k++] = bb[i];
        for (uint i = 0; i < bc.length; i++) bbb[k++] = bc[i];
        return string(bbb);
    }

    function recover(string memory message, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        bytes memory msgBytes = bytes(message);
        bytes memory fullMessage = concat(
            bytes("\x19Ethereum Signed Message:\n"),
            bytes(msgBytes.length.toString()),
            msgBytes,
            new bytes(0), new bytes(0), new bytes(0), new bytes(0)
        );
        return ecrecover(keccak256(fullMessage), v, r, s);
    }

    function concat(bytes memory ba, bytes memory bb, bytes memory bc, bytes memory bd, bytes memory be, bytes memory bf, bytes memory bg) internal pure returns (bytes memory) {
        bytes memory resultBytes = new bytes(ba.length + bb.length + bc.length + bd.length + be.length + bf.length + bg.length);
        uint k = 0;
        for (uint i = 0; i < ba.length; i++) resultBytes[k++] = ba[i];
        for (uint i = 0; i < bb.length; i++) resultBytes[k++] = bb[i];
        for (uint i = 0; i < bc.length; i++) resultBytes[k++] = bc[i];
        for (uint i = 0; i < bd.length; i++) resultBytes[k++] = bd[i];
        for (uint i = 0; i < be.length; i++) resultBytes[k++] = be[i];
        for (uint i = 0; i < bf.length; i++) resultBytes[k++] = bf[i];
        for (uint i = 0; i < bg.length; i++) resultBytes[k++] = bg[i];
        return resultBytes;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library UintLibrary {
    using SafeMath for uint;

    function toString(uint256 value) internal pure returns (string memory) {
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

    function bp(uint value, uint bpValue) internal pure returns (uint) {
        return value.mul(bpValue).div(10000);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../role/OwnableOperatorRole.sol";

contract ERC20TransferProxy is OwnableOperatorRole {

    function erc20safeTransferFrom(IERC20 token, address from, address to, uint256 value) external onlyOperator {
        require(token.transferFrom(from, to, value), "failure while transferring");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../role/OwnableOperatorRole.sol";

contract TransferProxy is OwnableOperatorRole {

    function erc721safeTransferFrom(IERC721 token, address from, address to, uint256 tokenId) external onlyOperator {
        token.safeTransferFrom(from, to, tokenId);
    }

    function erc1155safeTransferFrom(IERC1155 token, address from, address to, uint256 id, uint256 value, bytes calldata data) external onlyOperator {
        token.safeTransferFrom(from, to, id, value, data);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../role/OwnableOperatorRole.sol";

contract TransferProxyForDeprecated is OwnableOperatorRole {

    function erc721TransferFrom(IERC721 token, address from, address to, uint256 tokenId) external onlyOperator {
        token.transferFrom(from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./OperatorRole.sol";

contract OwnableOperatorRole is Ownable, OperatorRole {
    function addOperator(address account) external onlyOwner {
        _addOperator(account);
    }

    function removeOperator(address account) external onlyOwner {
        _removeOperator(account);
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

import "../utils/Roles.sol";

contract OperatorRole is Context {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    Roles.Role private _operators;

    modifier onlyOperator() {
        require(isOperator(_msgSender()), "OperatorRole: caller does not have the Operator role");
        _;
    }

    function isOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }

    function _addOperator(address account) internal {
        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _removeOperator(address account) internal {
        _operators.remove(account);
        emit OperatorRemoved(account);
    }
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC165.sol";

/**
 * @dev Storage based implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165Storage is ERC165 {
    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId) || _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    function transferFrom(
        address sender,
        address recipient,
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

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./proxy/ERC20TransferProxy.sol";
import "./role/OwnableOperatorRole.sol";
import "./StoreDomain.sol";

contract PrizeState is OwnableOperatorRole {
    using SafeMath for uint;

    mapping (uint256 => mapping(address => uint256)) private dayLiquid;
    mapping (uint256 => address[]) private dayLiquidRank;
    mapping (uint256 => uint256) private dayLiquidTotal;
    mapping (uint256 => mapping(address => uint256)) private dayInvitee;
    mapping (uint256 => address[]) private dayInviteeRank;
    mapping (uint256 => uint256) private dayInviteeTotal;

    mapping(uint256 => uint256) private _dayPrize;

    function getDayLiquid(uint256 _day, address _account) external view returns(uint256) {
        return dayLiquid[_day][_account];
    }
    function setDayLiquid(uint256 _day, address _account, uint256 _amount) external onlyOperator {
        dayLiquid[_day][_account] = _amount;
    }

    function getDayLiquidTotal(uint256 _day) external view returns(uint256) {
        return dayLiquidTotal[_day];
    }
    function setDayLiquidTotal(uint256 _day, uint256 _amount) external onlyOperator {
        dayLiquidTotal[_day] = _amount;
    }

    function getDayInvitee(uint256 _day, address _account) external view returns(uint256) {
        return dayInvitee[_day][_account];
    }
    function setDayInvitee(uint256 _day, address _account, uint256 _amount) external onlyOperator {
        dayInvitee[_day][_account] = _amount;
    }

    function getDayInviteeTotal(uint256 _day) external view returns(uint256) {
        return dayInviteeTotal[_day];
    }
    function setDayInviteeTotal(uint256 _day, uint256 _amount) external onlyOperator {
        dayInviteeTotal[_day] = _amount;
    }

    function getDayLiquidRank(uint256 _day) external view returns(address[] memory) {
        return dayLiquidRank[_day];
    }
    function setDayLiquidRank(uint256 _day, address[] memory _accounts) external onlyOperator {
        dayLiquidRank[_day] = _accounts;
    }
    function addDayLiquidRank(uint256 _day, address _account) external onlyOperator {
        dayLiquidRank[_day].push(_account);
    }

    function getDayInviteeRank(uint256 _day) external view returns(address[] memory) {
        return dayInviteeRank[_day];
    }
    function setDayInviteeRank(uint256 _day, address[] memory _accounts) external onlyOperator {
        dayInviteeRank[_day] = _accounts;
    }
    function addDayInviteeRank(uint256 _day, address _account) external onlyOperator {
        dayInviteeRank[_day].push(_account);
    }

    function getDayPrize(uint256 _day) external view returns(uint256) {
        return _dayPrize[_day];
    }
    function setDayPrize(uint256 _day, uint256 _amount) external onlyOperator {
        _dayPrize[_day] = _amount;
    }
    function addDayPrize(uint256 _day, uint256 _amount) external onlyOperator {
        _dayPrize[_day] = _dayPrize[_day].add(_amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./proxy/ERC20TransferProxy.sol";
import "./role/OwnableOperatorRole.sol";

contract StoreDomain {
    struct User {
        uint256 liquid;
        uint256 lastLiquid;
        address referrer;

        uint256 inviteeCount;
        uint256 groupCount;

        uint256 rewardTime;
        uint256 outTime;

        uint256 rounds;
        uint256 withdrawRounds;
    }

    struct Reward {
        uint256 liquid;
        uint256 group;
    }

    struct Withdrawn {
        uint256 liquid;
        uint256 group;
        uint256 prize;
    }

    struct Pool {
        uint256 total;
        uint256 withdraw;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "./StoreDomain.sol";
import "./FoxPools.sol";
import "./FoxState.sol";
import "./PrizeState.sol";

contract FoxStore is Ownable, StoreDomain {
    using SafeMath for uint;

    FoxPools pools;
    FoxState state;
    PrizeState prizeState;

    uint256 constant ONE_DAY = 24 hours;
    uint256 public constant MIN_AMOUNT_FIRST = 10000 * 10**18;
    uint256 public constant MIN_AMOUNT_RISK = 1000000 * 10**18;

    event Deposit(address indexed user, User);
    event Withdraw(address indexed user, User);
    event Risk(uint256 indexed rounds);

    struct IReward {
        uint256 liquid;
        uint256 group;
        uint256 prize;
    }

    struct IRank {
        address account;
        uint256 amount;
        uint256 reward;
    }

    constructor(FoxPools _pools, FoxState _state, PrizeState _prizeState) {
        pools = _pools;
        state = _state;
        prizeState = _prizeState;
    }

    function _clearUser(address _account) private {
        User memory _user = state.getUser(_account);
        Reward memory _reward = state.getReward(_account);
        Withdrawn memory _withdrawn = state.getWithdrawn(_account);

        delete _reward.liquid;
        delete _withdrawn.liquid;

        _reward.group = _reward.group.sub(_withdrawn.group);
        delete _withdrawn.group;

        delete _withdrawn.prize;

        delete _user.liquid;
        delete _user.lastLiquid;

        _user.outTime = _user.outTime == 0 ? block.timestamp : _user.outTime;

        state.setUser(_account, _user);
        state.setReward(_account, _reward);
        state.setWithdrawn(_account, _withdrawn);
    }

    function deposit(uint256 amount, address _referrer) external {
        require(state.getUserJoined(_referrer) || _referrer == address(0x0), "FoxStore: user not join");

        if (state.getUserJoined(msg.sender)) {
            updateLiquid(msg.sender);

            if (isOutWithRisk(msg.sender)) {
                _clearUser(msg.sender);
            }

            checkUpOneDay(msg.sender);
        }

        User memory user = state.getUser(msg.sender);

        if (!state.getUserJoined(msg.sender)) {
            require(amount >= MIN_AMOUNT_FIRST, "First must greater than 1 Fox");
        } else {
            require(amount >= user.lastLiquid.mul(105).div(100), "Must 5% greater than last amount");
        }

        pools.deposit(msg.sender, amount.mul(90).div(100), amount.mul(5).div(100), amount.mul(5).div(100));
        prizeState.addDayPrize(currentDay(), amount.mul(6).div(100));

        user.liquid = user.liquid.add(amount);
        user.lastLiquid = amount;
        user.rewardTime = block.timestamp;

        user.withdrawRounds = pools.rounds();
        user.outTime = 0;

        if (!state.getUserJoined(msg.sender) || (user.inviteeCount == 0 && user.referrer == address(0x0))) {
            user.referrer = _referrer;
            updateRef(_referrer, true);
            updateGroupCount(_referrer);
        } else {
            updateRef(user.referrer, false);
        }

        updatePrize(msg.sender, user.referrer, amount, currentDay());

        if (!state.getUserJoined(msg.sender)) {
            state.setUserJoined(msg.sender, true);
            state.addHoldUserNum();
        }

        state.setUser(msg.sender, user);

        emit Deposit(msg.sender, user);
    }

    function checkUpOneDay(address _account) internal {
        User memory _user = state.getUser(msg.sender);
        Reward memory _reward = state.getReward(msg.sender);

        if (_user.outTime != 0 && block.timestamp.sub(_user.outTime) > ONE_DAY) {
            _reward.group = state.getWithdrawn(msg.sender).group;
        }
        state.setReward(_account, _reward);
    }

    function updateLiquid(address _account) internal {
        User memory _user = state.getUser(_account);
        Reward memory _reward = state.getReward(_account);

        _user.rewardTime = block.timestamp;
        _reward.liquid = liquidReward(_account);

        state.setUser(_account, _user);
        state.setReward(_account, _reward);
    }

    function updatePrize(address _account, address _ref, uint256 _amount, uint256 _day) internal {
        uint256 _dayLiquid = prizeState.getDayLiquid(_day, _account);
        uint256 _dayLiquidTotal = prizeState.getDayLiquidTotal(_day);

        prizeState.setDayLiquid(_day, _account, _dayLiquid.add(_amount));

        if (_dayLiquid.add(_amount) >= 1000000 * 10**18) {
            if (_dayLiquid < 1000000 * 10**18) {
                prizeState.addDayLiquidRank(_day, _account);
                prizeState.setDayLiquidTotal(_day, _dayLiquidTotal.add(_dayLiquid).add(_amount));
            } else {
                prizeState.setDayLiquidTotal(_day, _dayLiquidTotal.add(_amount));
            }
        }

        if (_ref == address(0x0) || !state.getUserJoined(_ref)) return;

        uint256 _dayInvitee = prizeState.getDayInvitee(_day, _ref);
        uint256 _dayInviteeTotal = prizeState.getDayInviteeTotal(_day);

        prizeState.setDayInvitee(_day, _ref, _dayInvitee.add(_amount));

        if (_dayInvitee.add(_amount) >= 200000 * 10**18) {
            if (_dayInvitee < 200000 * 10**18) {
                prizeState.addDayInviteeRank(_day, _ref);
                prizeState.setDayInviteeTotal(_day, _dayInviteeTotal.add(_dayInvitee).add(_amount));
            } else {
                prizeState.setDayInviteeTotal(_day, _dayInviteeTotal.add(_amount));
            }
        }
    }

    function updateRef(address refAddr, bool added) internal {
        if (refAddr == address(0x0)) return;

        User memory ref = state.getUser(refAddr);

        if (added) {
            ref.inviteeCount += 1;
        }

        state.setUser(refAddr, ref);
    }

    function updateGroupCount(address _parent) private  {
        address parent = _parent;
        uint256 dis = 1;

        while(parent != address(0x0) && dis <= 10) {
            User memory user = state.getUser(parent);

            user.groupCount += 1;
            state.setUser(parent, user);

            parent = user.referrer;
            dis++;
        }
    }

    function _withdraw(address _account, uint256 _liquid, uint256 _group, uint256 _prize) private {
        User memory _user = state.getUser(_account);

        pools.withdraw(_account, _liquid.add(_group), _prize);

        Withdrawn memory _withdrawn = state.getWithdrawn(_account);

        _withdrawn.liquid = _withdrawn.liquid.add(_liquid);
        _withdrawn.group = _withdrawn.group.add(_group);
        _withdrawn.prize = _withdrawn.prize.add(_prize);
        state.setWithdrawn(_account, _withdrawn);

        _user.withdrawRounds = pools.rounds();
        state.setUser(_account, _user);

        updateGroup(_account, _liquid);

        emit Withdraw(_account, _user);
    }

    function withdraw() external {
        if (isOutWithRisk(msg.sender)) {
            _clearUser(msg.sender);
            return;
        }

        updateLiquid(msg.sender);

        Reward memory _reward = state.getReward(msg.sender);
        Withdrawn memory _withdrawn = state.getWithdrawn(msg.sender);

        uint256 max = state.getUser(msg.sender).liquid.mul(16).div(10);
        uint256 _prizeReward = totalPrizeReward(msg.sender);

        uint256 _totalReward = _reward.liquid.add(_reward.group).add(_prizeReward);
        if (max >= _totalReward) {
            _withdraw(
                msg.sender,
                _reward.liquid.sub(_withdrawn.liquid),
                _reward.group.sub(_withdrawn.group),
                0
            );
        } else {
            _withdraw(
                msg.sender,
                _reward.liquid.mul(max).div(_totalReward).sub(_withdrawn.liquid),
                _reward.group.mul(max).div(_totalReward).sub(_withdrawn.group),
                0
            );
        }

        bool clearFlag;
        if (isOut(msg.sender)) {
            clearFlag = true;
            _clearUser(msg.sender);
        }

        if ((block.timestamp - pools.lastRiskTime()) > 30 * ONE_DAY && pools.mining().total.sub(pools.mining().withdraw) < MIN_AMOUNT_RISK.add(pools.fullJoined().div(block.timestamp.sub(pools.initTime()).div(ONE_DAY).add(200)))) {
            emitRisk();
            if (isOutWithRisk(msg.sender) && !clearFlag) {
                _clearUser(msg.sender);
            }
        }
    }

    function withdrawPrize() external {
        if (isOutWithRisk(msg.sender)) {
            _clearUser(msg.sender);
            return;
        }

        updateLiquid(msg.sender);

        Reward memory _reward = state.getReward(msg.sender);
        Withdrawn memory _withdrawn = state.getWithdrawn(msg.sender);

        uint256 max = state.getUser(msg.sender).liquid.mul(16).div(10);
        uint256 _prizeReward = totalPrizeReward(msg.sender);

        uint256 _totalReward = _reward.liquid.add(_reward.group).add(_prizeReward);
        if (max >= _totalReward) {
            _withdraw(
                msg.sender,
                0,
                0,
                _prizeReward.sub(_withdrawn.prize)
            );
        } else {
            _withdraw(
                msg.sender,
                0,
                0,
                _prizeReward.mul(max).div(_totalReward).sub(_withdrawn.prize)
            );
        }
        prizeState.setDayLiquid(currentDay() -1, msg.sender, 0);
        prizeState.setDayInvitee(currentDay() -1, msg.sender, 0);

        bool clearFlag;
        if (isOut(msg.sender)) {
            clearFlag = true;
            _clearUser(msg.sender);
        }

        if ((block.timestamp - pools.lastRiskTime()) > 30 * ONE_DAY && pools.mining().total.sub(pools.mining().withdraw) < MIN_AMOUNT_RISK.add(pools.fullJoined().div(block.timestamp.sub(pools.initTime()).div(ONE_DAY).add(200)))) {
            emitRisk();
            if (isOutWithRisk(msg.sender) && !clearFlag) {
                _clearUser(msg.sender);
            }
        }
    }

    function updateGroup(address _account, uint256 _amount) private  {
        address parent = state.getUser(_account).referrer;
        uint256 dis = 1;

        while(parent != address(0x0) && dis <= 10) {
            User memory user = state.getUser(parent);
            Reward memory reward = state.getReward(parent);

            if (dis <= user.inviteeCount && user.liquid > 0 && canReward(parent)) {
                if (dis == 1) {
                    reward.group = reward.group
                        .add(_amount);
                } else if (dis == 2) {
                    reward.group = reward.group
                        .add(_amount.mul(50).div(100));
                } else if (dis == 3) {
                    reward.group = reward.group
                        .add(_amount.mul(40).div(100));
                } else if (dis == 4) {
                    reward.group = reward.group
                        .add(_amount.mul(30).div(100));
                } else if (dis == 5) {
                    reward.group = reward.group
                        .add(_amount.mul(20).div(100));
                } else {
                    reward.group = reward.group
                        .add(_amount.mul(10).div(100));
                }
            }

            state.setReward(parent, reward);

            parent = user.referrer;
            dis++;
        }
    }

    function emitRisk() private {
        pools.addRounds();
        pools.updateLastRiskTime();

        emit Risk(pools.rounds());
    }

    function liquidReward(address _account) public view returns(uint256) {
        User memory _user = state.getUser(_account);
        Reward memory _reward = state.getReward(_account);
        Withdrawn memory _withdrawn = state.getWithdrawn(_account);
        Pool memory _mining = pools.mining();

        uint256 hackReward = Math.max(_reward.liquid, _withdrawn.liquid);
        uint256 withdrawn = hackReward
            .add(_reward.group)
            .add(_withdrawn.prize);
        uint256 _joinAmount = _user.liquid;

        uint256 rewardPerDay;
        if (withdrawn >= _joinAmount.mul(16).div(10)) {
            rewardPerDay = 0;
        } else {
            rewardPerDay = (_mining.total.sub(_mining.withdraw))
                .mul(state.staticRate()).div(10000)
                .mul(_joinAmount.mul(16).div(10).sub(withdrawn))
                .div(pools.fullJoined().mul(16).div(10).sub(pools.totalWithdraw()));
        }

        return block.timestamp.sub(_user.rewardTime)
            .div(ONE_DAY).mul(rewardPerDay)
            .add(hackReward);
    }

    function prizeLiquidReward(address _account) public view returns(uint256) {
        uint256 _day = currentDay() - 1;

        uint256 _dayLiquid = prizeState.getDayLiquid(_day, _account);
        uint256 _dayLiquidTotal = prizeState.getDayLiquidTotal(_day);

        if (_dayLiquidTotal == 0) return 0;

        uint256 _totalPrize = pools.prize().total.sub(pools.prize().withdraw);
        uint256 _reward;
        if (_dayLiquid >= 1000000 * 10**18) {
            _reward = _totalPrize.mul(15).div(100);
        } else {
            _reward = 0;
        }

        return _reward.mul(_dayLiquid).div(_dayLiquidTotal);
    }

    function prizeInviteeReward(address _account) public view returns(uint256) {
        uint256 _day = currentDay() - 1;

        uint256 _dayInvitee = prizeState.getDayInvitee(_day, _account);
        uint256 _dayInviteeTotal = prizeState.getDayInviteeTotal(_day);

        if (_dayInviteeTotal == 0) return 0;

        uint256 _totalPrize = pools.prize().total.sub(pools.prize().withdraw);
        uint256 _reward;
        if (_dayInvitee >= 200000 * 10**18) {
            _reward = _totalPrize.mul(15).div(100);
        } else {
            _reward = 0;
        }

        return _reward.mul(_dayInvitee).div(_dayInviteeTotal);
    }

    function totalPrizeReward(address _account) public view returns(uint256) {
        Withdrawn memory _withdrawn = state.getWithdrawn(_account);

        return prizeLiquidReward(_account)
            .add(prizeInviteeReward(_account))
            .add(_withdrawn.prize);
    }

    function canReward(address _account) public view returns(bool) {
        User memory _user = state.getUser(_account);
        Reward memory _reward = state.getReward(_account);

        return _user.liquid.mul(16).div(10) > _reward.group.add(totalPrizeReward(_account)).add(liquidReward(_account));
    }

    function isOut(address _account) public view returns(bool) {
        User memory _user = state.getUser(_account);
        Withdrawn memory _withdrawn = state.getWithdrawn(_account);

        return _user.liquid.mul(16).div(10) <= _withdrawn.liquid.add(_withdrawn.group).add(_withdrawn.prize);
    }

    function isOutWithRisk(address _account) public view returns(bool) {
        User memory _user = state.getUser(_account);
        Withdrawn memory _withdrawn = state.getWithdrawn(_account);

        return (pools.rounds() > _user.withdrawRounds) && (_withdrawn.liquid.add(_withdrawn.group).add(_withdrawn.prize) >= _user.liquid);
    }

    function currentDay() public view returns(uint256) {
        return block.timestamp.div(ONE_DAY);
    }

    function getUser(address _account) external view returns(User memory) {
        return state.getUser(_account);
    }

    function getReward(address _account) external view returns(IReward memory) {
        Reward memory _reward = state.getReward(_account);

        return IReward({
            liquid: liquidReward(_account),
            group: _reward.group,
            prize: totalPrizeReward(_account)
        });
    }

    function getWithdrawn(address _account) external view returns(Withdrawn memory) {
        return state.getWithdrawn(_account);
    }

    function mining() external view returns(Pool memory) {
        return pools.mining();
    }

    function prize() external view returns(Pool memory) {
        return pools.prize();
    }

    function totalLiquid() external view returns(uint256) {
        return pools.total();
    }

    function getDayLiquid(address _account) external view returns(uint256) {
        return prizeState.getDayLiquid(currentDay() - 1, _account);
    }

    function getDayLiquidTotal() external view returns(uint256) {
        return prizeState.getDayLiquidTotal(currentDay() - 1);
    }

    function getDayInvitee(address _account) external view returns(uint256) {
        return prizeState.getDayInvitee(currentDay() - 1, _account);
    }

    function getDayInviteeTotal() external view returns(uint256) {
        return prizeState.getDayInviteeTotal(currentDay() - 1);
    }

    function getDayLiquidRank() external view returns(IRank[] memory) {
        address[] memory accounts = prizeState.getDayLiquidRank(currentDay() - 1);
        IRank[] memory rank = new IRank[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            uint256 amount = prizeState.getDayLiquid(currentDay() - 1, accounts[i]);
            uint256 reward = prizeLiquidReward(accounts[i]);
            rank[i] = IRank({
                account: accounts[i],
                amount: amount,
                reward: reward
            });
        }
        return rank;
    }

    function getDayInviteeRank() external view returns(IRank[] memory) {
        address[] memory accounts = prizeState.getDayInviteeRank(currentDay() - 1);
        IRank[] memory rank = new IRank[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            uint256 amount = prizeState.getDayInvitee(currentDay() - 1, accounts[i]);
            uint256 reward = prizeInviteeReward(accounts[i]);
            rank[i] = IRank({
                account: accounts[i],
                amount: amount,
                reward: reward
            });
        }
        return rank;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
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
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./proxy/ERC20TransferProxy.sol";
import "./role/OwnableOperatorRole.sol";
import "./StoreDomain.sol";

contract FoxPools is OwnableOperatorRole {
    using SafeMath for uint;

    ERC20TransferProxy erc20Proxy;
    IERC20 token;

    uint256 public total;
    StoreDomain.Pool private _mining;
    StoreDomain.Pool private _prize;
    address public dev;

    address public withdrawer;

    uint256 public rounds;
    uint256 public fullJoined;
    uint256 public totalWithdraw;

    uint256 public lastRiskTime;
    uint256 public initTime;

    uint256 public fee = 2;

    constructor(address _dev, address _withdrawer, ERC20TransferProxy _erc20Proxy, IERC20 _token) {
        dev = _dev;
        withdrawer = _withdrawer;
        erc20Proxy = _erc20Proxy;
        token = _token;

        lastRiskTime = block.timestamp;
        initTime = block.timestamp;
    }

    function mining() external view returns(StoreDomain.Pool memory) {
        return _mining;
    }

    function prize() external view returns(StoreDomain.Pool memory) {
        return _prize;
    }

    function setDev(address _dev) external onlyOwner {
        dev = _dev;
    }

    function setWithdrawer(address _withdrawer) external onlyOwner {
        withdrawer = _withdrawer;
    }

    function deposit(address _account, uint256 _miningAmount, uint256 _prizeAmount, uint256 _devAmount) external onlyOperator returns(bool) {
        uint256 _amount = _miningAmount.add(_prizeAmount).add(_devAmount);

        fullJoined = fullJoined.add(_amount);

        total = total.add(_amount);

        _mining.total = _mining.total.add(_miningAmount);
        _prize.total = _prize.total.add(_prizeAmount);

        erc20Proxy.erc20safeTransferFrom(token, _account, address(this), _amount);
        token.transfer(dev, _devAmount);

        return true;
    }

    function withdraw(address _account, uint256 _miningAmount, uint256 _prizeAmount) external onlyOperator returns(bool) {
        require(_miningAmount <= _mining.total.sub(_mining.withdraw), "Pool: mining amount not enougth");
        require(_prizeAmount <= _prize.total.sub(_prize.withdraw), "Pool: prize amount not enougth");

        totalWithdraw = totalWithdraw.add(_miningAmount).add(_prizeAmount);
        _mining.withdraw = _mining.withdraw.add(_miningAmount);
        _prize.withdraw = _prize.withdraw.add(_prizeAmount);

        uint256 amount = _miningAmount.add(_prizeAmount);
        uint256 feeBalance = amount.mul(fee).div(100);
        token.transfer(_account, amount - feeBalance);
        token.transfer(withdrawer, feeBalance);

        return true;
    }

    function addRounds() external onlyOperator {
        rounds++;
    }

    function updateLastRiskTime() external onlyOperator {
        lastRiskTime = block.timestamp;
    }

    function ownerWithdraw(uint256 _amount) external returns(bool) {
        require(msg.sender == withdrawer, "Must be withdrawer");

        uint256 balance = token.balanceOf(address(this));
        require(_amount <= balance, "_amount too big");

        return token.transfer(withdrawer, _amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./proxy/ERC20TransferProxy.sol";
import "./role/OwnableOperatorRole.sol";
import "./StoreDomain.sol";

contract FoxState is OwnableOperatorRole {
    using SafeMath for uint;

    mapping(address => StoreDomain.User) private user;
    mapping(address => StoreDomain.Reward) private reward;
    mapping(address => StoreDomain.Withdrawn) private withdrawn;
    mapping(address => bool) private userJoined;

    uint256 public holdUserNum;

    uint256 public staticRate = 150;

    function getUser(address _account) external view returns(StoreDomain.User memory) {
        return user[_account];
    }
    function setUser(address _account, StoreDomain.User memory _user) external onlyOperator {
        user[_account] = _user;
    }

    function getReward(address _account) external view returns(StoreDomain.Reward memory) {
        return reward[_account];
    }
    function setReward(address _account, StoreDomain.Reward memory _reward) external onlyOperator {
        reward[_account] = _reward;
    }

    function getWithdrawn(address _account) external view returns(StoreDomain.Withdrawn memory) {
        return withdrawn[_account];
    }
    function setWithdrawn(address _account, StoreDomain.Withdrawn memory _withdrawn) external onlyOperator {
        withdrawn[_account] = _withdrawn;
    }

    function getUserJoined(address _account) external view returns(bool) {
        return userJoined[_account];
    }
    function setUserJoined(address _account, bool _joined) external onlyOperator {
        userJoined[_account] = _joined;
    }

    function getHoldUserNum() external view returns(uint256) {
        return holdUserNum;
    }
    function setHoldUserNum(uint256 num) external onlyOperator {
        holdUserNum = num;
    }
    function addHoldUserNum() external onlyOperator {
        holdUserNum++;
    }

    function setStaticRate(uint256 _rate) external onlyOwner {
        staticRate = _rate;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Reward is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct User {
        uint256 v1Reward;
        uint256 v2Reward;
        uint256 freeBalance;
    }

    struct ImportUser {
        address account;
        uint256 v1Reward;
        uint256 v2Reward;
        uint256 freeBalance;
    }

    IERC20 public fox;
    IERC20 public wool;

    uint256 public amountPer = 2000;

    address private _burnPool = address(0x000000000000000000000000000000000000dEaD);

    mapping(address => User) internal users;

    constructor(IERC20 fox_, IERC20 wool_) {
        fox = fox_;
        wool = wool_;
    }

    function importUsers(ImportUser[] calldata _importUsers) external onlyOwner {
        for (uint256 i = 0; i < _importUsers.length; i++) {
            users[_importUsers[i].account] = User({
                v1Reward: _importUsers[i].v1Reward,
                v2Reward: _importUsers[i].v2Reward,
                freeBalance: _importUsers[i].freeBalance
            });
        }
    }

    function rewarded(address _account) public view returns(uint256) {
        User memory user = users[_account];
        return user.freeBalance.add(user.v1Reward).add(user.v2Reward);
    }

    function withdraw(uint256 amount) external {
        uint256 totalReward = rewarded(msg.sender);
        uint256 withdrawReward = amount.mul(amountPer);
        if (totalReward < withdrawReward) {
            withdrawReward = totalReward;
            amount = totalReward.div(amountPer);
        }

        require(amount > 0, "Reward: amount must gt zero");

        User storage user = users[msg.sender];

        wool.safeTransferFrom(
            address(msg.sender),
            _burnPool,
            amount
        );
        safeFoxTransfer(msg.sender, withdrawReward);
        user.freeBalance = user.freeBalance.sub(
            user.freeBalance.mul(withdrawReward).div(totalReward)
        );
        user.v1Reward = user.v1Reward.sub(
            user.v1Reward.mul(withdrawReward).div(totalReward)
        );
        user.v2Reward = user.v2Reward.sub(
            user.v2Reward.mul(withdrawReward).div(totalReward)
        );
    }

    function getUser(address account) external view returns(User memory) {
        return users[account];
    }

    function setAmountPer(uint256 newAmount) external onlyOwner {
        amountPer = newAmount;
    }

    function safeFoxTransfer(address _to, uint256 _amount) internal {
        uint256 foxBal = IERC20(fox).balanceOf(address(this));
        if (_amount > foxBal) {
            fox.transfer(_to, foxBal);
        } else {
            fox.transfer(_to, _amount);
        }
    }

    function emergencyWithdraw() external onlyOwner {
        fox.transfer(msg.sender, IERC20(fox).balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract FoxPEV2 is Ownable {
    using SafeERC20 for IERC20;

    struct User {
        address referrer;
        address leader;
        uint256 amount;
        uint256 reward;
        uint256 groupReward;
        bool isLeader;
        bool hasWithdraw;
    }

    IERC20 public fox;
    IERC20 public buyToken;

    uint256 public pricePer = 50 * 10**18;
    uint256 public amountPer = 100000 * 10**18;

    uint256 public totalAmount;
    uint256 public totalFunds;

    uint256 rate = 0;

    address private _burnPool = address(0x000000000000000000000000000000000000dEaD);
    address private buyTokenReceiver;

    mapping(address => User) internal users;

    constructor(IERC20 fox_, IERC20 buyToken_, address buyTokenReceiver_) {
        fox = fox_;
        buyToken = buyToken_;
        buyTokenReceiver = buyTokenReceiver_;
    }

    function updateLeaderReward(address account, uint256 reward) internal {
        address leader = users[account].leader;

        if (users[leader].isLeader && !users[leader].hasWithdraw) {
            users[leader].reward += reward;
            users[leader].groupReward += reward;
        }
    }

    function buy(address referrer, uint256 amount) external {
        require(amount > 0, "FoxPEV2: amount great than 1");
        require(users[msg.sender].amount + amount <= 50, "FoxPEV2: buy amount less than 50");
        require(totalAmount <= 5600, "FoxPEV2: Sold out");

        if (!users[msg.sender].isLeader && users[msg.sender].amount == 0) {
            users[msg.sender].referrer = referrer;
            if (users[referrer].leader != address(0)) {
                users[msg.sender].leader = users[referrer].leader;
            } else {
                require(users[referrer].isLeader, "FoxPEV2: referrer must be leader when referrer has not leader");
                users[msg.sender].leader = referrer;
            }
        }
        users[msg.sender].amount += amount;
        if (!users[msg.sender].hasWithdraw) {
            users[msg.sender].reward += amount * amountPer * 2;
        }

        buyToken.safeTransferFrom(
            address(msg.sender),
            buyTokenReceiver,
            amount * pricePer
        );
        totalAmount += amount;
        totalFunds += amount * pricePer;
        updateLeaderReward(msg.sender, amount * amountPer * 2 * 15 / 100);
    }

    function rewarded(address account) public view returns(uint256) {
        return users[account].reward * rate / 100;
    }

    function withdraw() external {
        uint256 rewardWithdraw = rewarded(msg.sender);

        safeFoxTransfer(msg.sender, rewardWithdraw);
        if (users[msg.sender].reward - rewardWithdraw > 0) {
            safeFoxTransfer(_burnPool, users[msg.sender].reward - rewardWithdraw);
        }
        users[msg.sender].reward = 0;
        users[msg.sender].groupReward = 0;
        users[msg.sender].hasWithdraw = true;
    }

    function getUser(address account) external view returns(User memory) {
        return users[account];
    }

    function setPricePer(uint256 newPrice) external onlyOwner {
        pricePer = newPrice;
    }

    function setAmountPer(uint256 newAmount) external onlyOwner {
        amountPer = newAmount;
    }

    function setBuyTokenReceiver(address newBuyTokenReceiver) external onlyOwner {
        buyTokenReceiver = newBuyTokenReceiver;
    }

    function setLeader(address leader, bool isLeader) external onlyOwner {
        users[leader].isLeader = isLeader;
    }

    function importLeaders(address[] memory leaders) external onlyOwner {
        for (uint256 i = 0; i < leaders.length; i++) {
            users[leaders[i]].isLeader = true;
        }
    }

    function setRate() external onlyOwner {
        require(rate < 100, "FoxPEV2: rate has the maximum");
        if (rate == 0) {
            rate = 40;
        } else {
            rate += 6;
        }
    }

    function safeFoxTransfer(address _to, uint256 _amount) internal {
        uint256 foxBal = IERC20(fox).balanceOf(address(this));
        if (_amount > foxBal) {
            fox.transfer(_to, foxBal);
        } else {
            fox.transfer(_to, _amount);
        }
    }

    function emergencyWithdraw() external onlyOwner {
        fox.transfer(msg.sender, IERC20(fox).balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract WOOL is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor() {
        _name = "WOOL Token";
        _symbol = "WOOL";
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import './interfaces/IUniswapV2Router02.sol';
import './interfaces/IUniswapV2Factory.sol';

contract FoxToken is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name = "FoxToken";
    string private _symbol = "FOX";

    address private _burnPool = address(0x000000000000000000000000000000000000dEaD);
    uint256 public _burnFee = 5;
    uint256 public _swapFee = 5;
    uint256 private _previousBurnFee = _burnFee;
    uint256 private _previousSwapFee = _swapFee;

    mapping (address => bool) private _isExcludedFromFee;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    uint256 private numTokensSellToAddToLiquidity = 500000 * 10**18;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    // pancake on bsc-testnet 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3 https://pancake.kiemtienonline360.com/#/swap
    constructor (address router02) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router02);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Pair = _uniswapV2Pair;

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_uniswapV2Pair] = true;

        _mint(_msgSender(), 10000000000 * 10**18);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function excludeAccount(address account) external onlyOwner {
        require(!_isExcludedFromFee[account], "Account is already excluded");

        _isExcludedFromFee[account] = true;
    }

    function includeAccount(address account) external onlyOwner {
        require(_isExcludedFromFee[account], "Account is already excluded");

        _isExcludedFromFee[account] = false;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setFees(uint256 burnFee_, uint256 swapFee_) external onlyOwner {
        _burnFee = burnFee_;
        _swapFee = swapFee_;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);
        checkSwapAndLiquify(sender, recipient);

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            removeAllFee();
        }

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        uint256 burnAmount = amount * _burnFee / 1000;
        uint256 swapAmount = amount * _swapFee / 1000;
        _balances[recipient] += (amount - burnAmount - swapAmount);
        _balances[_burnPool] += burnAmount;
        _balances[address(this)] += swapAmount;

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            restoreAllFee();
        }

        emit Transfer(sender, recipient, amount - burnAmount - swapAmount);
        emit Transfer(sender, _burnPool, burnAmount);
        emit Transfer(sender, address(this), swapAmount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function removeAllFee() private {
        _previousBurnFee = _burnFee;
        _previousSwapFee = _swapFee;
        _burnFee = 0;
        _swapFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _swapFee = _previousSwapFee;
    }

    function checkSwapAndLiquify(address sender, address recipient) private {
        if (
            swapAndLiquifyEnabled &&
            !inSwapAndLiquify &&
            sender != uniswapV2Pair &&
            recipient != uniswapV2Pair &&
            (balanceOf(address(this)) >= numTokensSellToAddToLiquidity)
        ) {
            //add liquidity
            swapAndLiquify(numTokensSellToAddToLiquidity);
        }
    }

    function swapAndLiquify(uint256 amount) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = amount / 2;
        uint256 otherHalf = amount - half;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SaveToken is Ownable {
    function withdrawToken(address _token, address _recipient, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(_recipient, _amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IReferrer.sol";

contract Referrer is Ownable, IReferrer {
    mapping(address => address) referrers;
    mapping(address => address[]) children;
    mapping(address => bool) operators;

    constructor() {
        operators[msg.sender] = true;
    }

    function getReferrer(address account) public override view returns (address) {
        return referrers[account];
    }

    function getChildrenLength(address _account) public override view returns (uint256) {
        return children[_account].length;
    }

    function getChildren(
        address _account, uint256 from, uint256 length
    ) public override view returns(address[] memory _children) {
        _children = new address[](length);
        uint256 j;
        for (uint256 i = from; i < from + length; i++) {
            _children[j++] = children[_account][i];
        }
    }


    function setReferrer(
        address _account, address _referrer
    ) public override returns(address, address) {
        require(operators[msg.sender] || owner() == msg.sender, "Only operator or owner call");
        if (_referrer == address(0) || _account == _referrer) {
            return (_account, _referrer);
        }

        if (referrers[_account] == address(0)) {
            referrers[_account] = _referrer;
            children[_referrer].push(_account);
            return (_account, _referrer);
        }

        return (_account, referrers[_account]);
    }

    function importReferrers(
        address[] calldata _accounts, address[] calldata _referrers
    ) public override onlyOwner returns(uint256) {
        require(_accounts.length == _referrers.length, "Referrer: _accounts.length != _referrers.length");

        for (uint256 i = 0; i < _accounts.length; i++) {
            setReferrer(_accounts[i], _referrers[i]);
        }

        return _accounts.length;
    }

    function addOperators(address[] calldata _accounts) external onlyOwner {
        for (uint256 i = 0; i < _accounts.length; i++) {
            operators[_accounts[i]] = true;
        }
    }

    function removeOperators(address[] calldata _accounts) external onlyOwner {
        for (uint256 i = 0; i < _accounts.length; i++) {
            operators[_accounts[i]] = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IReferrer {
    function getReferrer(address _account) external view returns (address);
    function getChildrenLength(address _account) external view returns (uint256);
    function getChildren(address _account, uint256 from, uint256 length) external view returns(address[] calldata);
    function setReferrer(address _account, address _referrer) external returns(address, address);
    function importReferrers(address[] calldata _accounts, address[] calldata _referrers) external returns(uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IReferrer.sol";

contract MinerV2 is Ownable {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 depositBlock;
    }
    struct PoolInfo {
        IUniswapV2Pair lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTokenPerShare;
        uint256 lpBalance;
        uint256 lockBlock;
        uint256 ratio;
    }

    IERC20 public token;
    uint256 public tokenPerBlock = 69444444444444444444;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    IReferrer referrer;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public maxReward = 134000000 * 10**18;
    uint256 public sendedReward;
    IERC20 oldLp;
    IERC20 newLp;

    event Deposit(address indexed user, uint256 indexed pid, address indexed referrer, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(IERC20 _token, uint256 _startBlock, IReferrer _referrer, IERC20 _oldLp, IERC20 _newLp) {
        token = _token;
        startBlock = _startBlock;
        referrer = _referrer;
        oldLp = _oldLp;
        newLp = _newLp;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function add(
        uint256 _allocPoint,
        uint256 _lockBlock,
        uint256 _ratio,
        IUniswapV2Pair _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accTokenPerShare: 0,
                lpBalance: 0,
                lockBlock: _lockBlock,
                ratio: _ratio
            })
        );
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint256 _lockBlock,
        uint256 _ratio,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].lockBlock = _lockBlock;
        poolInfo[_pid].ratio = _ratio;
    }

    function extras(address _account) public view returns(uint256) {
        uint256 length = referrer.getChildrenLength(_account);
        return length > 20 ? 20 : length;
    }

    function pendingToken(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        if (user.amount == 0) {
            return 0;
        }

        uint256 accTokenPerShare = pool.accTokenPerShare;
        if (block.number > pool.lastRewardBlock && pool.lpBalance != 0) {
            uint256 multiplier = block.number.sub(pool.lastRewardBlock);
            uint256 tokenReward =
                multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accTokenPerShare = accTokenPerShare.add(
                tokenReward.mul(1e12).div(pool.lpBalance)
            );
        }

        uint256 pending = user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);

        return pending.mul(
            extras(msg.sender).add(100)
        ).div(100);
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.lpBalance == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number.sub(pool.lastRewardBlock);
        uint256 tokenReward =
            multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        pool.accTokenPerShare = pool.accTokenPerShare.add(
            tokenReward.mul(1e12).div(pool.lpBalance)
        );
        pool.lastRewardBlock = block.number;
    }

    function _claim(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
            safeTokenTransfer(
                msg.sender,
                pending.mul(
                    extras(msg.sender).add(100)
                ).div(100)
            );
        }
    }

    function claim(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        _claim(_pid);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
    }

    function exchangeOld(uint256 _amount) public {
        oldLp.transferFrom(msg.sender, address(this), _amount);
        newLp.transfer(msg.sender, _amount);
        deposit(2, _amount.mul(1).div(10), referrer.getReferrer(msg.sender));
        deposit(3, _amount.mul(3).div(10), referrer.getReferrer(msg.sender));
        deposit(4, _amount.mul(6).div(10), referrer.getReferrer(msg.sender));
    }

    function deposit(uint256 _pid, uint256 _amount, address _referrer) public {
        updateReferrer(_referrer);
        _claim(_pid);
        depositLp(msg.sender, _amount, _pid);

        if (_amount > 0) {
            lpReward(_pid, _amount);
        }
        emit Deposit(msg.sender, _pid, referrer.getReferrer(msg.sender), _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        PoolInfo storage pool = poolInfo[_pid];
        require(block.number >= user.depositBlock.add(pool.lockBlock), "withdraw: no arrival block");
        require(user.amount >= _amount, "withdraw: not good");
        _claim(_pid);
        withdrawLp(msg.sender, _amount, _pid);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        withdrawLp(msg.sender, user.amount, _pid);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function emergencyWithdrawToken(uint256 _amount) public onlyOwner {
        token.transfer(msg.sender, _amount);
    }

    function emergencyWithdrawOldLp() public onlyOwner {
        oldLp.transfer(msg.sender, oldLp.balanceOf(address(this)));
    }

    function emergencyWithdrawNewLp() public onlyOwner {
        newLp.transfer(msg.sender, newLp.balanceOf(address(this)));
    }

    function setSendedReward(uint256 _amount) public onlyOwner {
        sendedReward = _amount;
    }

    function getTokenAmountWithLp(IUniswapV2Pair _lp, IERC20 _token, uint256 _lpAmount) public view returns(uint256) {
        return _token.balanceOf(address(_lp))
            .mul(_lpAmount)
            .div(_lp.totalSupply());
    }

    function lpReward(uint256 _pid, uint256 _amount) internal {
        if (sendedReward >= maxReward) {
            return;
        }
        PoolInfo memory pool = poolInfo[_pid];
        if (pool.ratio == 0) {
            return;
        }

        uint256 rewardByLp = getTokenAmountWithLp(pool.lpToken, token, _amount);

        address me = msg.sender;
        for (uint256 i = 0; i < 8; i++) {
            uint256 myReward =
                rewardByLp.mul(pool.ratio).div(100)
                    .mul(100).div((2**i).mul(100));

            if (sendedReward.add(myReward) > maxReward) {
                myReward = maxReward.sub(sendedReward);
            }

            safeTokenTransfer(me, myReward);
            sendedReward = sendedReward.add(myReward);
            me = referrer.getReferrer(me);

            if (me == address(0x0)) {
                break;
            }
        }
    }

    function updateReferrer(address _referrer) internal {
        referrer.setReferrer(msg.sender, _referrer);
    }

    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = token.balanceOf(address(this));
        if (_amount > tokenBal) {
            token.transfer(_to, tokenBal);
        } else {
            token.transfer(_to, _amount);
        }
    }

    function depositLp(address from, uint256 amount, uint256 pid) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        pool.lpToken.transferFrom(
            from,
            address(this),
            amount
        );
        pool.lpBalance = pool.lpBalance.add(amount);
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        user.depositBlock = block.number;
    }

    function withdrawLp(address to, uint256 amount, uint256 pid) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        pool.lpToken.transfer(to, amount);
        pool.lpBalance = pool.lpBalance.sub(amount);
        user.amount = user.amount.sub(amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IReferrer.sol";

contract Miner is Ownable {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 withdrawBlock;
    }
    struct PoolInfo {
        IUniswapV2Pair lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTokenPerShare;
        uint256 lpBalance;
        uint256 lockBlock;
        uint256 ratio;
    }

    IERC20 public token;
    uint256 public tokenPerBlock = 69444444444444444444;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    IReferrer referrer;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public maxReward = 200000000 * 10**18;
    uint256 public sendedReward;

    event Deposit(address indexed user, uint256 indexed pid, address indexed referrer, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(IERC20 _token, uint256 _startBlock, IReferrer _referrer) {
        token = _token;
        startBlock = _startBlock;
        referrer = _referrer;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function add(
        uint256 _allocPoint,
        uint256 _lockBlock,
        uint256 _ratio,
        IUniswapV2Pair _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accTokenPerShare: 0,
                lpBalance: 0,
                lockBlock: _lockBlock,
                ratio: _ratio
            })
        );
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint256 _lockBlock,
        uint256 _ratio,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].lockBlock = _lockBlock;
        poolInfo[_pid].ratio = _ratio;
    }

    function extras(address _account) public view returns(uint256) {
        uint256 length = referrer.getChildrenLength(_account);
        return length > 20 ? 20 : length;
    }

    function pendingToken(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        if (user.amount == 0) {
            return 0;
        }

        uint256 accTokenPerShare = pool.accTokenPerShare;
        if (block.number > pool.lastRewardBlock && pool.lpBalance != 0) {
            uint256 multiplier = block.number.sub(pool.lastRewardBlock);
            uint256 tokenReward =
                multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accTokenPerShare = accTokenPerShare.add(
                tokenReward.mul(1e12).div(pool.lpBalance)
            );
        }

        uint256 pending = user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);

        return pending.mul(
            extras(msg.sender).add(100)
        ).div(100);
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.lpBalance == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number.sub(pool.lastRewardBlock);
        uint256 tokenReward =
            multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        pool.accTokenPerShare = pool.accTokenPerShare.add(
            tokenReward.mul(1e12).div(pool.lpBalance)
        );
        pool.lastRewardBlock = block.number;
    }

    function _claim(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
            safeTokenTransfer(
                msg.sender,
                pending.mul(
                    extras(msg.sender).add(100)
                ).div(100)
            );
        }
    }

    function claim(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        _claim(_pid);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
    }

    function deposit(uint256 _pid, uint256 _amount, address _referrer) public {
        updateReferrer(_referrer);
        _claim(_pid);
        depositLp(msg.sender, _amount, _pid);

        if (_amount > 0) {
            lpReward(_pid, _amount);
        }
        emit Deposit(msg.sender, _pid, referrer.getReferrer(msg.sender), _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.number >= user.withdrawBlock, "withdraw: no arrival block");
        require(user.amount >= _amount, "withdraw: not good");
        _claim(_pid);
        withdrawLp(msg.sender, _amount, _pid);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        withdrawLp(msg.sender, user.amount, _pid);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function emergencyWithdrawToken(uint256 _amount) public onlyOwner {
        token.transfer(msg.sender, _amount);
    }

    function getTokenAmountWithLp(IUniswapV2Pair _lp, IERC20 _token, uint256 _lpAmount) public view returns(uint256) {
        return _token.balanceOf(address(_lp))
            .mul(_lpAmount)
            .div(_lp.totalSupply());
    }

    function lpReward(uint256 _pid, uint256 _amount) internal {
        if (sendedReward >= maxReward) {
            return;
        }
        PoolInfo memory pool = poolInfo[_pid];
        if (pool.ratio == 0) {
            return;
        }

        uint256 rewardByLp = getTokenAmountWithLp(pool.lpToken, token, _amount);

        address me = msg.sender;
        for (uint256 i = 0; i < 8; i++) {
            uint256 myReward =
                rewardByLp.mul(pool.ratio).div(100)
                    .mul(100).div((2**i).mul(100));

            if (sendedReward.add(myReward) > maxReward) {
                myReward = maxReward.sub(sendedReward);
            }

            safeTokenTransfer(me, myReward);
            sendedReward = sendedReward.add(myReward);
            me = referrer.getReferrer(me);

            if (me == address(0x0)) {
                break;
            }
        }
    }

    function updateReferrer(address _referrer) internal {
        referrer.setReferrer(msg.sender, _referrer);
    }

    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = token.balanceOf(address(this));
        if (_amount > tokenBal) {
            token.transfer(_to, tokenBal);
        } else {
            token.transfer(_to, _amount);
        }
    }

    function depositLp(address from, uint256 amount, uint256 pid) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        pool.lpToken.transferFrom(
            from,
            address(this),
            amount
        );
        pool.lpBalance = pool.lpBalance.add(amount);
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        user.withdrawBlock = block.number.add(pool.lockBlock);
    }

    function withdrawLp(address to, uint256 amount, uint256 pid) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        pool.lpToken.transfer(to, amount);
        pool.lpBalance = pool.lpBalance.sub(amount);
        user.amount = user.amount.sub(amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract FoxPE is Ownable {
    using SafeERC20 for IERC20;

    struct User {
        address referrer;
        address leader;
        uint256 amount;
        uint256 reward;
        uint256 groupReward;
        bool isLeader;
        bool hasWithdraw;
    }

    IERC20 public fox;
    IERC20 public buyToken;

    uint256 public pricePer = 50 * 10**18;
    uint256 public amountPer = 100000 * 10**18;

    uint256 public totalAmount;
    uint256 public totalFunds;

    uint256 rate = 0;

    address private _burnPool = address(0x000000000000000000000000000000000000dEaD);
    address private buyTokenReceiver;

    mapping(address => User) internal users;

    constructor(IERC20 fox_, IERC20 buyToken_, address buyTokenReceiver_) {
        fox = fox_;
        buyToken = buyToken_;
        buyTokenReceiver = buyTokenReceiver_;
    }

    function updateLeaderReward(address account, uint256 reward) internal {
        address leader = users[account].leader;

        if (users[leader].isLeader && !users[leader].hasWithdraw) {
            users[leader].reward += reward;
            users[leader].groupReward += reward;
        }
    }

    function buy(address referrer, uint256 amount) external {
        require(amount > 0, "FoxPE: amount great than 1");
        require(users[msg.sender].amount + amount <= 50, "FoxPE: buy amount less than 50");
        require(totalAmount <= 5600, "FoxPE: Sold out");

        if (!users[msg.sender].isLeader && users[msg.sender].amount == 0) {
            users[msg.sender].referrer = referrer;
            if (users[referrer].leader != address(0)) {
                users[msg.sender].leader = users[referrer].leader;
            } else {
                require(users[referrer].isLeader, "FoxPE: referrer must be leader when referrer has not leader");
                users[msg.sender].leader = referrer;
            }
        }
        users[msg.sender].amount += amount;
        if (!users[msg.sender].hasWithdraw) {
            users[msg.sender].reward += amount * amountPer * 2;
        }

        buyToken.safeTransferFrom(
            address(msg.sender),
            buyTokenReceiver,
            amount * pricePer
        );
        totalAmount += amount;
        totalFunds += amount * pricePer;
        updateLeaderReward(msg.sender, amount * amountPer * 2 * 15 / 100);
    }

    function rewarded(address account) public view returns(uint256) {
        return users[account].reward * rate / 100;
    }

    function withdraw() external {
        uint256 rewardWithdraw = rewarded(msg.sender);

        safeFoxTransfer(msg.sender, rewardWithdraw);
        if (users[msg.sender].reward - rewardWithdraw > 0) {
            safeFoxTransfer(_burnPool, users[msg.sender].reward - rewardWithdraw);
        }
        users[msg.sender].reward = 0;
        users[msg.sender].groupReward = 0;
        users[msg.sender].hasWithdraw = true;
    }

    function getUser(address account) external view returns(User memory) {
        return users[account];
    }

    function setPricePer(uint256 newPrice) external onlyOwner {
        pricePer = newPrice;
    }

    function setAmountPer(uint256 newAmount) external onlyOwner {
        amountPer = newAmount;
    }

    function setBuyTokenReceiver(address newBuyTokenReceiver) external onlyOwner {
        buyTokenReceiver = newBuyTokenReceiver;
    }

    function setLeader(address leader, bool isLeader) external onlyOwner {
        users[leader].isLeader = isLeader;
    }

    function importLeaders(address[] memory leaders) external onlyOwner {
        for (uint256 i = 0; i < leaders.length; i++) {
            users[leaders[i]].isLeader = true;
        }
    }

    function setRate() external onlyOwner {
        require(rate < 100, "FoxPE: rate has the maximum");
        if (rate == 0) {
            rate = 40;
        } else {
            rate += 6;
        }
    }

    function safeFoxTransfer(address _to, uint256 _amount) internal {
        uint256 foxBal = IERC20(fox).balanceOf(address(this));
        if (_amount > foxBal) {
            fox.transfer(_to, foxBal);
        } else {
            fox.transfer(_to, _amount);
        }
    }

    function emergencyWithdraw() external onlyOwner {
        fox.transfer(msg.sender, IERC20(fox).balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./tokens/ERC721Base.sol";
import "./utils/Bytes.sol";
import "./role/OwnableOperatorRole.sol";

contract FoxERC721 is Ownable, ERC721Base, OwnableOperatorRole {
    using StringLibrary for string;
    using BytesLibrary for bytes32;

    address private _burnPool = address(0x000000000000000000000000000000000000dEaD);
    IERC20 public token;
    uint256 public burnAmount;

    constructor (string memory name, string memory symbol, IERC20 _token, uint256 _burnAmount) ERC721Base(name, symbol) {
        _registerInterface(bytes4(keccak256('MINT_WITH_ADDRESS')));
        token = _token;
        burnAmount = _burnAmount;
    }

    function mint(uint256 tokenId, uint8 v, bytes32 r, bytes32 s, Fee[] memory _fees, string memory tokenURI) public {
        require(isOperator(keccak256(abi.encodePacked(this, tokenId)).toString().recover(v, r, s)), "owner should sign tokenId");
        _mint(msg.sender, tokenId, _fees);
        _setTokenURI(tokenId, tokenURI);
        token.transferFrom(msg.sender, _burnPool, burnAmount);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external {
        _setTokenURI(tokenId, _tokenURI);
    }

    function setToken(IERC20 _token) external onlyOwner {
        token = _token;
    }

    function setBurnAmount(uint256 _burnAmount) external onlyOwner {
        burnAmount = _burnAmount;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../utils/String.sol";
import "./HasSecondarySaleFees.sol";

abstract contract ERC721Base is HasSecondarySaleFees, ERC721URIStorage {
    struct Fee {
        address payable recipient;
        uint256 value;
    }

    // id => fees
    mapping (uint256 => Fee[]) public fees;

    /**
     * @dev Constructor function
     */
    constructor (string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Base: caller is not owner nor approved");
        _burn(tokenId);
    }

    function exists(uint256 tokenId) external view virtual returns (bool) {
        return _exists(tokenId);
    }

    function getFeeRecipients(uint256 id) public view override returns (address payable[] memory) {
        Fee[] memory _fees = fees[id];
        address payable[] memory result = new address payable[](_fees.length);
        for (uint i = 0; i < _fees.length; i++) {
            result[i] = _fees[i].recipient;
        }
        return result;
    }

    function getFeeBps(uint256 id) public view override returns (uint[] memory) {
        Fee[] memory _fees = fees[id];
        uint[] memory result = new uint[](_fees.length);
        for (uint i = 0; i < _fees.length; i++) {
            result[i] = _fees[i].value;
        }
        return result;
    }

    function _mint(address to, uint256 tokenId, Fee[] memory _fees) internal {
        _mint(to, tokenId);
        // address[] memory recipients = new address[](_fees.length);
        // uint[] memory bps = new uint[](_fees.length);
        // for (uint i = 0; i < _fees.length; i++) {
        //     require(_fees[i].recipient != address(0x0), "Recipient should be present");
        //     require(_fees[i].value != 0, "Fee value should be positive");
        //     fees[tokenId].push(_fees[i]);
        //     recipients[i] = _fees[i].recipient;
        //     bps[i] = _fees[i].value;
        // }
        // if (_fees.length > 0) {
        //     emit SecondarySaleFees(tokenId, recipients, bps);
        // }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Storage, ERC721) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || ERC165Storage.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC721.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721 {
  constructor() ERC721("Mock ERC721", "mockerc721") {}

  function mint(address to, uint256 tokenId) external virtual {
    super._mint(to, tokenId);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
  constructor() ERC20("Mock ERC20", "mockERC20") {}

  function mint(address to, uint256 tokenId) external virtual {
    super._mint(to, tokenId);
  }
}