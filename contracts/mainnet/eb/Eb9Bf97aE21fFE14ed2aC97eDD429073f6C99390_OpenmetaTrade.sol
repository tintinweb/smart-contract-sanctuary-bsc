// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./TradeModel.sol";
import "../utils/Validation.sol";
import "../libraries/TransferHelper.sol";

contract OpenmetaTrade is Validation, TradeModel {
    struct DealOrderStatus {
        bool dealRes;
        bool auctionRes;
    }

    IOpenmetaController public controller;
    address public feeRewardToken;
    mapping(address => uint256) public feeReturns;
    mapping(bytes32 => DealOrderStatus) public dealOrderStatus;

    modifier checkOrderCaller(
        MakerOrder memory _makerOrder,
        DealOrder memory _dealOrder
    ) {
        if (_makerOrder.saleType == SaleType.TYPE_AUCTION) {
            require(
                controller.isSigAddress(msg.sender),
                "caller is not the signer"
            );
        } else {
            require(msg.sender == _dealOrder.taker, "caller is not the taker");
        }
        _;
    }

    event PerformOrder(
        bytes32 indexed makerOrderHash,
        bytes32 indexed dealOrderHash,
        SaleType saleType,
        address maker,
        address taker,
        uint256 dealAmount,
        uint256 totalFee,
        DealOrderStatus dealRes
    );
    event Claim(address indexed user, uint256 amount);

    constructor(address _controller, address _rewardToken)
        EIP712("Openmeta NFT Trade", "2.0.0")
    {
        controller = IOpenmetaController(_controller);
        feeRewardToken = _rewardToken;
    }

    function performOrder(
        NftInfo memory _nftInfo,
        MakerOrder memory _makerOrder,
        DealOrder memory _dealOrder
    )
        external
        payable
        checkOrderCaller(_makerOrder, _dealOrder)
        checkDeadline(_dealOrder.deadline)
        returns (bytes32 dealOrderHash, uint256 totalFee)
    {
        require(
            controller.isSupportPayment(_makerOrder.paymentToken),
            "not support payment token"
        );
        require(
            _dealOrder.quantity <= _makerOrder.quantity,
            "order quantity not verified"
        );

        dealOrderHash = getOrderHashBySig(
            _nftInfo,
            _makerOrder,
            _dealOrder,
            controller
        );
        require(
            !dealOrderStatus[dealOrderHash].dealRes,
            "deal order has been completed"
        );

        /// When the order type is auction, check whether the conditions are met.
        /// If not, the transfer will not be processed and the event flag will be false
        bool processRes = true;
        bool isOriginToken = controller.isOriginToken(_makerOrder.paymentToken);
        if (_makerOrder.saleType == SaleType.TYPE_AUCTION) {
            require(
                !isOriginToken,
                "auctions do not support chain-based coins"
            );

            (uint256 nftBalance, uint256 amountBalance) = getOrderUserBalance(
                _nftInfo,
                _makerOrder,
                _dealOrder.taker,
                isOriginToken
            );

            if (
                (_dealOrder.minted && nftBalance < _dealOrder.quantity) ||
                amountBalance < _dealOrder.dealAmount
            ) {
                processRes = false;
            }
        }

        /// If the conditions are met, initiate a transfer to complete the order transaction
        if (processRes) {
            totalFee = _transferForTakeFee(
                _nftInfo,
                _makerOrder,
                _dealOrder,
                isOriginToken
            );
        }

        DealOrderStatus memory deal_res = DealOrderStatus(true, processRes);
        dealOrderStatus[dealOrderHash] = deal_res;

        emit PerformOrder(
            _dealOrder.makerOrderHash,
            dealOrderHash,
            _makerOrder.saleType,
            _makerOrder.maker,
            _dealOrder.taker,
            _dealOrder.dealAmount,
            totalFee,
            deal_res
        );
    }

    /// ### Transaction fee refund ###
    /// Takers can get transaction fee rebates by holding MDX Token
    function claim() external {
        uint256 amount = feeReturns[msg.sender];
        require(amount > 0, "insufficient reward");

        uint256 balance = IERC20(feeRewardToken).balanceOf(address(this));
        require(balance >= amount, "insufficient balance");

        feeReturns[msg.sender] = feeReturns[msg.sender] - amount;
        TransferHelper.safeTransfer(feeRewardToken, msg.sender, amount);

        emit Claim(msg.sender, amount);
    }

    function setController(address _controller) external {
        require(_controller != address(0), "zero address");
        require(
            msg.sender == address(controller),
            "the caller is not the controller"
        );

        controller = IOpenmetaController(_controller);
    }

    function getOrderUserBalance(
        NftInfo memory _nftInfo,
        MakerOrder memory _makerOrder,
        address _taker,
        bool _originToken
    ) public view returns (uint256 nftBalance, uint256 amountBalance) {
        if (_nftInfo.tokenType == TokenType.TYPE_ERC721) {
            if (
                IERC721(_nftInfo.nftToken).ownerOf(_nftInfo.tokenId) ==
                _makerOrder.maker
            ) {
                nftBalance = 1;
            }
        }

        if (_nftInfo.tokenType == TokenType.TYPE_ERC1155) {
            nftBalance = IERC1155(_nftInfo.nftToken).balanceOf(
                _makerOrder.maker,
                _nftInfo.tokenId
            );
        }

        if (_originToken) {
            amountBalance = _taker.balance;
        } else {
            amountBalance = IERC20(_makerOrder.paymentToken).balanceOf(_taker);
        }
    }

    function _transferForTakeFee(
        NftInfo memory _nftInfo,
        MakerOrder memory _makerOrder,
        DealOrder memory _dealOrder,
        bool _originToken
    ) internal returns (uint256) {
        /// Calculate the total fees for this order
        address feeTo = controller.feeTo();
        (
            uint256 amount,
            uint256 totalFee,
            uint256 txFee,
            uint256 authorFee
        ) = controller.checkFeeAmount(
                _dealOrder.dealAmount,
                _makerOrder.authorProtocolFee
            );

        /// Complete transaction transfer based on payment token type
        if (_originToken) {
            require(msg.value >= _dealOrder.dealAmount, "insufficient value");

            TransferHelper.safeTransferETH(_makerOrder.maker, amount);

            if (txFee > 0) {
                TransferHelper.safeTransferETH(feeTo, txFee);
            }

            if (authorFee > 0) {
                TransferHelper.safeTransferETH(_dealOrder.author, authorFee);
            }
        } else {
            TransferHelper.safeTransferFrom(
                _makerOrder.paymentToken,
                _dealOrder.taker,
                _makerOrder.maker,
                amount
            );

            if (txFee > 0) {
                require(feeTo != address(0), "zero fee address");
                TransferHelper.safeTransferFrom(
                    _makerOrder.paymentToken,
                    _dealOrder.taker,
                    feeTo,
                    txFee
                );
            }

            if (authorFee > 0) {
                require(_dealOrder.author != address(0), "zero author address");
                TransferHelper.safeTransferFrom(
                    _makerOrder.paymentToken,
                    _dealOrder.taker,
                    _dealOrder.author,
                    authorFee
                );
            }
        }

        /// Check whether the order NFT Token has been minted.
        /// If it has been minted, call the contract transfer method,
        /// otherwise mint the NFT tokenid and send it to the taker
        if (_dealOrder.minted) {
            if (_nftInfo.tokenType == TokenType.TYPE_ERC721) {
                IERC721(_nftInfo.nftToken).safeTransferFrom(
                    _makerOrder.maker,
                    _dealOrder.taker,
                    _nftInfo.tokenId
                );
            }
            if (_nftInfo.tokenType == TokenType.TYPE_ERC1155) {
                IERC1155(_nftInfo.nftToken).safeTransferFrom(
                    _makerOrder.maker,
                    _dealOrder.taker,
                    _nftInfo.tokenId,
                    _dealOrder.quantity,
                    ""
                );
            }
        } else {
            require(_makerOrder.quantity == 1, "mint quantity not verified");

            controller.mint(_dealOrder.taker, _nftInfo.tokenId, 1);
        }

        feeReturns[_dealOrder.taker] =
            feeReturns[_dealOrder.taker] +
            _dealOrder.rewardAmount;

        return totalFee;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "../interface/IOpenmetaController.sol";

abstract contract TradeModel is EIP712{
    bytes32 public constant MAKER_ORDER_TYPEHASH    =   keccak256(
        "MakerOrder(bytes32 nftTokenHash,address maker,uint256 quantity,address paymentToken,uint256 authorProtocolFee,uint8 saleType,uint256 startTime,uint256 endTime,uint256 createTime,uint256 cancelTime)"
    );
    bytes32 public constant TAKER_ORDER_TYPEHASH    =   keccak256(
        "TakerOrder(bytes32 makerOrderHash,address taker,address author,uint256 dealAmount,uint256 rewardAmount,uint256 salt,bool minted,uint256 createTime)"
    );
    bytes32 public constant DEAL_ORDER_TYPEHASH    =   keccak256(
        "DealOrder(bytes32 makerOrderHash,address taker,address author,uint256 dealAmount,uint256 rewardAmount,uint256 salt,bool minted,uint256 deadline,uint256 createTime,bytes takerSig,uint256 quantity)"
    );

    enum TokenType{ TYPE_BASE, TYPE_ERC721, TYPE_ERC1155 }  /// Unused type: TYPE_BASE
    enum SaleType{ TYPE_BASE, TYPE_MARKET, TYPE_AUCTION }   // Unused type: TYPE_BASE, TYPE_MARKET

    struct NftInfo {
        address nftToken;           // The NFT contract address of the transaction
        uint256 tokenId;            // The tokenid of the NFT contract address
        uint256[] batchTokenIds;
        uint256[] batchTokenPrice;
        TokenType tokenType;        // Order nft token type: ERC721 or ERC1155
        uint256 chainId;
        uint256 salt;
    }

    struct MakerOrder {
        bytes32 nftTokenHash;       // Struct NftInfo hash
        address maker;              // Maker's address for the order
        uint256 price;              // The price of the order
        uint256 quantity;           // Quantity of the order NFT sold
        address paymentToken;       // Token address for payment
        uint256 authorProtocolFee;  // Copyright fees for NFT authors
        SaleType saleType;          // Order trade type: Market or Auction
        uint256 startTime;          // Sales start time
        uint256 endTime;            // Sales end time
        uint256 createTime;
        uint256 cancelTime;
        bytes signature;
    }

    struct DealOrder {
        bytes32 makerOrderHash;     // Maker order hash
        address taker;              // Taker's address for the order
        address author;             // NFT author address
        uint256 dealAmount;         // The final transaction amount of the order
        uint256 rewardAmount;       // Reward amount returned by holding coins
        uint256 salt;
        bool minted;                // Whether the NFT has been minted
        uint256 deadline;           // Deal order deadline
        uint256 createTime;
        bytes takerSig;             // Taker's address signature
        uint256 quantity;           // The actual quantity of NFTs in the deal order
        bytes signature;            // Operator address signature
    }

    function getOrderHashBySig (
        NftInfo memory _nftInfo, 
        MakerOrder memory _makerOrder, 
        DealOrder memory _dealOrder, 
        IOpenmetaController _controller
    ) internal view returns(bytes32 dealOrderHash) {
        require(
            _makerOrder.quantity >= _dealOrder.quantity && _dealOrder.quantity > 0,
            "order quantity verification failed"
        );

        require(
            _nftInfo.batchTokenIds.length == _nftInfo.batchTokenPrice.length,
            "batch token arrays do not match"
        );

        bool hashTokenId = false;
        uint256 tokenIdLen = _nftInfo.batchTokenIds.length;
        for (uint256 i = 0; i < tokenIdLen; i++) {
            if (
                _nftInfo.batchTokenIds[i] == _nftInfo.tokenId &&
                _nftInfo.batchTokenPrice[i] == _makerOrder.price
            ) {
                hashTokenId = true;
            }
        }
        require(hashTokenId, "nft token data validation failed");

        uint256 dealAmount = _makerOrder.price * _dealOrder.quantity;
        require(_dealOrder.dealAmount >= dealAmount, "order deal amount verification failed");

        bytes32 makerOrderHash = _makerOrderSig(_nftInfo, _makerOrder);
        require(makerOrderHash == _dealOrder.makerOrderHash, "maker order hash does not match");

        _takerOrderSig(_dealOrder);
        dealOrderHash = _dealOrderSig(_dealOrder, _controller);
    }

    function _makerOrderSig(NftInfo memory _nftInfo, MakerOrder memory _order) private view returns(bytes32 makerOrderHash) {
        bytes32 nftTokenHash = keccak256(abi.encodePacked(
            _nftInfo.nftToken, 
            _nftInfo.batchTokenIds,
            _nftInfo.batchTokenPrice,
            _nftInfo.tokenType, 
            block.chainid, 
            _nftInfo.salt
        ));
        require(nftTokenHash == _order.nftTokenHash, "Failed to verify nft token hash");

        makerOrderHash = _hashTypedDataV4(keccak256(abi.encode(
            MAKER_ORDER_TYPEHASH,
            nftTokenHash,
            _order.maker,
            _order.quantity,
            _order.paymentToken,
            _order.authorProtocolFee,
            _order.saleType,
            _order.startTime,
            _order.endTime,
            _order.createTime,
            _order.cancelTime
        )));

        address signer = ECDSA.recover(makerOrderHash, _order.signature);
        require(signer == _order.maker, "Failed to verify maker signature");
    }

    function _takerOrderSig(DealOrder memory _order) private view {
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
            TAKER_ORDER_TYPEHASH,
            _order.makerOrderHash,
            _order.taker,
            _order.author,
            _order.dealAmount,
            _order.rewardAmount,
            _order.salt,
            _order.minted,
            _order.createTime
        )));

        address signer = ECDSA.recover(digest, _order.takerSig);
        require(signer == _order.taker, "Failed to verify taker signature");
    }

    function _dealOrderSig(
        DealOrder memory _order, 
        IOpenmetaController _controller
    ) private view returns(bytes32 dealOrderHash) {
        dealOrderHash = _hashTypedDataV4(keccak256(abi.encode(
            DEAL_ORDER_TYPEHASH,
            _order.makerOrderHash,
            _order.taker,
            _order.author,
            _order.dealAmount,
            _order.rewardAmount,
            _order.salt,
            _order.minted,
            _order.deadline,
            _order.createTime,
            keccak256(_order.takerSig),
            _order.quantity
        )));
        address signer = ECDSA.recover(dealOrderHash, _order.signature);

        require(
            _controller.isSigAddress(signer), 
            "Failed to verify singer signature"
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import './BlockTimestamp.sol';

abstract contract Validation is BlockTimestamp {
    modifier checkDeadline(uint256 deadline) {
        require(_blockTimestamp() <= deadline, 'Transaction too old');
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper:safeApprove: approve failed");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper:safeTransfer: transfer failed");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper:transferFrom: transferFrom failed");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper:safeTransferETH: ETH transfer failed");
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
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOpenmetaController {
    struct SupportPayment {
        address token;
        string symbol;
        bool status;
    }

    function feeTo() external view returns(address);

    function sigAddress() external view returns(address);

    function creaters(uint256) external view returns(address);

    function supportPayments(address) external view returns(SupportPayment memory);

    function isOriginToken(address _paymentToken) external pure returns(bool res);

    function checkFeeAmount(
        uint256 _amount,
        uint256 _authorProtocolFee
    ) external view returns(uint256 txAmount, uint256 totalFee, uint256 txFee, uint256 authorFee);

    function getMaximumFee(uint256 _amount) external view returns(uint256 maximumFee);

    function isSigAddress(address _addr) external view returns(bool);

    function isSupportPayment(address _paymentToken) external view returns(bool isSupport);
    
    function mint(address _to, uint256 _tokenId, uint256 _amount) external;
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
pragma solidity ^0.8.10;

/// @title Function for getting block timestamp
/// @dev Base contract that is overridden for tests
abstract contract BlockTimestamp {
    /// @dev Method that exists purely to be overridden for tests
    /// @return The current block timestamp
    function _blockTimestamp() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}