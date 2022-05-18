// SPDX-License-Identifier: MIT
pragma solidity =0.8.1;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./interfaces/ILeasing.sol";


contract Leasing is ILeasing {
    address private admin;
    uint256 private lendingID = 1;
    uint256 private rentingID = 1;
    uint256 private constant SECONDS_IN_DAY = 86400;
    mapping(bytes32 => Lending) private lendings;
    mapping(bytes32 => Renting) private rentings;

    modifier onlyAdmin() {
        require(msg.sender == admin, "TL::not admin");
        _;
    }
    
    constructor(
        address newAdmin
    ) {
        ensureIsNotZeroAddr(newAdmin);
        admin = newAdmin;
    }

    function lend(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint8[] memory maxRentDuration,
        uint8[] memory rentSharePercentage
    ) external override {
        bundleCall(
            handleLend,
            createLendCallData(
                nftAddress,
                tokenID,
                maxRentDuration,
                rentSharePercentage
            )
        );
    }

    function stopLend(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory _lendingID
    ) external override {
        bundleCall(
            handleStopLend,
            createActionCallData(
                nftAddress,
                tokenID,
                _lendingID,
                new uint256[](0)
            )
        );
    }

    function editLend(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint8[] memory maxRentDuration,
        uint8[] memory rentSharePercentage,
        uint256[] memory _lendingID
    ) external override {
        bundleCall(
            handleEditLend,
            createEditCallData(
                nftAddress,
                tokenID,
                _lendingID,
                new uint256[](0),
                maxRentDuration,
                new uint8[](0),
                rentSharePercentage
            )
        );
    }

    function editRent(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint8[] memory rentDuration,
        uint256[] memory _rentingID
    ) external override {
        bundleCall(
            handleEditRent,
            createEditCallData(
                nftAddress,
                tokenID,
                new uint256[](0),
                _rentingID,                
                new uint8[](0),
                rentDuration,
                new uint8[](0)
            )
        );
    }

    function rent(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint8[] memory rentDuration,
        uint256[] memory _lendingID
    ) external payable override {
        bundleCall(
            handleRent,
            createRentCallData(
                nftAddress,
                tokenID,
                _lendingID,
                rentDuration
            )
        );
    }

    function stopRent(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory _lendingID,
        uint256[] memory _rentingID
    ) external override {
        bundleCall(
            handleStopRent,
            createActionCallData(
                nftAddress,
                tokenID,
                _lendingID,
                _rentingID
            )
        );
    }

    function handleLend(ILeasing.CallData memory cd) private {
        for (uint256 i = cd.left; i < cd.right; i++) {
            ensureIsLendable(cd, i);
            bytes32 identifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    lendingID
                )
            );
            ILeasing.Lending storage lending = lendings[identifier];
            ensureIsNull(lending);            
            lendings[identifier] = ILeasing.Lending({
                lenderAddress: payable(msg.sender),
                maxRentDuration: cd.maxRentDuration[i],
                rentSharePercentage: cd.rentSharePercentage[i]
            });
            emit ILeasing.Lend(
                msg.sender,
                cd.nftAddress[cd.left],
                cd.tokenID[i],
                lendingID,
                cd.maxRentDuration[i],
                cd.rentSharePercentage[i]
            );
            lendingID++;
        }
        safeTransfer(
            cd,
            msg.sender,
            address(this)
        );
    }

    function handleStopLend(ILeasing.CallData memory cd) private {
        for (uint256 i = cd.left; i < cd.right; i++) {
            bytes32 lendingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.lendingID[i]
                )
            );
            Lending storage lending = lendings[lendingIdentifier];
            ensureIsNotNull(lending);
            ensureIsStoppable(lending, msg.sender);
            
            emit ILeasing.StopLend(cd.lendingID[i], uint32(block.timestamp));
            delete lendings[lendingIdentifier];
        }
        safeTransfer(
            cd,
            address(this),
            msg.sender
        );
    }

    function handleEditLend(ILeasing.CallData memory cd) private {
        for (uint256 i = cd.left; i < cd.right; i++) {
            bytes32 lendingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.lendingID[i]
                )
            );
            Lending storage lending = lendings[lendingIdentifier];
            ensureIsNotNull(lending);
            ensureIsStoppable(lending, msg.sender);
            
            lending.maxRentDuration = cd.maxRentDuration[i];
            lending.rentSharePercentage = cd.rentSharePercentage[i];
        }        
    }

    function handleRent(ILeasing.CallData memory cd) private {
        for (uint256 i = cd.left; i < cd.right; i++) {
            bytes32 lendingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.lendingID[i]
                )
            );
            bytes32 rentingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    rentingID
                )
            );
            ILeasing.Lending storage lending = lendings[lendingIdentifier];
            ILeasing.Renting storage renting = rentings[rentingIdentifier];
            ensureIsNotNull(lending);
            ensureIsNull(renting);
            ensureIsRentable(lending, cd, i, msg.sender);
            
            rentings[rentingIdentifier] = ILeasing.Renting({
                renterAddress: payable(msg.sender),
                rentDuration: cd.rentDuration[i],
                rentedAt: uint32(block.timestamp)
            });
            
            emit ILeasing.Rent(
                msg.sender,
                cd.lendingID[i],
                rentingID,
                cd.rentDuration[i],
                renting.rentedAt
            );
            rentingID++;
        }
        safeTransfer(
            cd,
            address(this),
            msg.sender
        );
    }

    function handleStopRent(ILeasing.CallData memory cd) private {
        for (uint256 i = cd.left; i < cd.right; i++) {
            bytes32 lendingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.lendingID[i]
                )
            );
            bytes32 rentingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.rentingID[i]
                )
            );
            ILeasing.Lending storage lending = lendings[lendingIdentifier];
            ILeasing.Renting storage renting = rentings[rentingIdentifier];
            ensureIsNotNull(lending);
            ensureIsNotNull(renting);
            ensureIsReturnable(renting, msg.sender, block.timestamp);
            
            emit ILeasing.StopRent(cd.rentingID[i], uint32(block.timestamp));
            delete rentings[rentingIdentifier];
        }
        safeTransfer(
            cd,
            msg.sender,
            address(this)
        );
    }

    function handleEditRent(ILeasing.CallData memory cd) private {
        for (uint256 i = cd.left; i < cd.right; i++) {
            bytes32 rentingIdentifier = keccak256(
                abi.encodePacked(
                    cd.nftAddress[cd.left],
                    cd.tokenID[i],
                    cd.rentingID[i]
                )
            );
            ILeasing.Renting storage renting = rentings[rentingIdentifier];
            
            ensureIsNotNull(renting);
            ensureIsRenter(renting, msg.sender);
            
            renting.rentDuration = cd.rentDuration[i];            
        }        
    }

    
    function bundleCall(
        function(ILeasing.CallData memory) handler,
        ILeasing.CallData memory cd
    ) private {
        require(cd.nftAddress.length > 0, "TL::no nfts");
        handler(cd);
    }

    function safeTransfer(
        CallData memory cd,
        address from,
        address to
    ) private {
        
        IERC721(cd.nftAddress[cd.left]).transferFrom(
            from,
            to,
            cd.tokenID[cd.left]
        );    
    }

    function getLending(
        address nftAddress,
        uint256 tokenID,
        uint256 _lendingID
    )
        external
        view
        returns (
            address,
            uint8,
            uint8
        )
    {
        bytes32 identifier = keccak256(
            abi.encodePacked(nftAddress, tokenID, _lendingID)
        );
        ILeasing.Lending storage lending = lendings[identifier];
        return (
            lending.lenderAddress,
            lending.maxRentDuration,
            lending.rentSharePercentage           
        );
    }

    function getRenting(
        address nftAddress,
        uint256 tokenID,
        uint256 _rentingID
    )
        external
        view
        returns (
            address,
            uint8,
            uint32
        )
    {
        bytes32 identifier = keccak256(
            abi.encodePacked(nftAddress, tokenID, _rentingID)
        );
        ILeasing.Renting storage renting = rentings[identifier];
        return (
            renting.renterAddress,
            renting.rentDuration,
            renting.rentedAt
        );
    }

    function createLendCallData(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint8[] memory maxRentDuration,
        uint8[] memory rentSharePercentage
    ) private pure returns (CallData memory cd) {
        cd = CallData({
            left: 0,
            right: 1,
            nftAddress: nftAddress,
            tokenID: tokenID,
            lendingID: new uint256[](0),
            rentingID: new uint256[](0),
            rentDuration: new uint8[](0),
            maxRentDuration: maxRentDuration,
            rentSharePercentage: rentSharePercentage
        });
    }

    function createRentCallData(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory _lendingID,
        uint8[] memory rentDuration
    ) private pure returns (CallData memory cd) {
        cd = CallData({
            left: 0,
            right: 1,
            nftAddress: nftAddress,
            tokenID: tokenID,
            lendingID: _lendingID,
            rentingID: new uint256[](0),
            rentDuration: rentDuration,
            maxRentDuration: new uint8[](0),
            rentSharePercentage: new uint8[](0)
        });
    }

    function createEditCallData(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory _lendingID,
        uint256[] memory _rentingID,
        uint8[] memory maxRentDuration,
        uint8[] memory rentDuration,
        uint8[] memory share
    ) private pure returns (CallData memory cd) {
        cd = CallData({
            left: 0,
            right: 1,
            nftAddress: nftAddress,
            tokenID: tokenID,
            lendingID: _lendingID,
            rentingID: _rentingID,
            rentDuration: rentDuration,
            maxRentDuration: maxRentDuration,
            rentSharePercentage: share
        });
    }

    function createActionCallData(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory _lendingID,
        uint256[] memory _rentingID
    ) private pure returns (CallData memory cd) {
        cd = CallData({
            left: 0,
            right: 1,
            nftAddress: nftAddress,
            tokenID: tokenID,
            lendingID: _lendingID,
            rentingID: _rentingID,
            rentDuration: new uint8[](0),
            maxRentDuration: new uint8[](0),
            rentSharePercentage: new uint8[](0)
        });
    }
    
    function ensureIsNotZeroAddr(address addr) private pure {
        require(addr != address(0), "TL::zero address");
    }

    function ensureIsZeroAddr(address addr) private pure {
        require(addr == address(0), "TL::not a zero address");
    }

    function ensureIsNull(Lending memory lending) private pure {
        ensureIsZeroAddr(lending.lenderAddress);
        require(lending.maxRentDuration == 0, "TL::duration not zero");
        require(lending.rentSharePercentage == 0, "TL::rent price not zero");
    }

    function ensureIsNotNull(Lending memory lending) private pure {
        ensureIsNotZeroAddr(lending.lenderAddress);
        require(lending.maxRentDuration != 0, "TL::duration zero");
        require(lending.rentSharePercentage != 0, "TL::rent price is zero");
    }

    function ensureIsNull(Renting memory renting) private pure {
        ensureIsZeroAddr(renting.renterAddress);
        require(renting.rentDuration == 0, "TL::duration not zero");
        require(renting.rentedAt == 0, "TL::rented at not zero");
    }

    function ensureIsNotNull(Renting memory renting) private pure {
        ensureIsNotZeroAddr(renting.renterAddress);
        require(renting.rentDuration != 0, "TL::duration is zero");
        require(renting.rentedAt != 0, "TL::rented at is zero");
    }

    function ensureIsLendable(CallData memory cd, uint256 i) private pure {
        require(cd.maxRentDuration[i] > 0, "TL::duration is zero");
        require(cd.maxRentDuration[i] <= type(uint8).max, "TL::not uint8");
        require(uint32(cd.rentSharePercentage[i]) > 0, "TL::rent price is zero");
    }

    function ensureIsRentable(
        Lending memory lending,
        CallData memory cd,
        uint256 i,
        address msgSender
    ) private pure {
        require(msgSender != lending.lenderAddress, "TL::cant rent own nft");
        require(cd.rentDuration[i] <= type(uint8).max, "TL::not uint8");
        require(cd.rentDuration[i] > 0, "TL::duration is zero");
        require(
            cd.rentDuration[i] <= lending.maxRentDuration,
            "TL::rent duration exceeds allowed max"
        );
    }

    function ensureIsReturnable(
        Renting memory renting,
        address msgSender,
        uint256 blockTimestamp
    ) private pure {
        require(renting.renterAddress == msgSender, "TL::not renter");
        require(
            !isPastReturnDate(renting, blockTimestamp),
            "TL::past return date"
        );
    }

    function ensureIsRenter(
        Renting memory renting,
        address msgSender
    ) private pure {
        require(renting.renterAddress == msgSender, "TL::not renter");        
    }

    function ensureIsStoppable(Lending memory lending, address msgSender)
        private
        pure
    {
        require(lending.lenderAddress == msgSender, "TL::not lender");
    }

    function isPastReturnDate(Renting memory renting, uint256 nowTime)
        private
        pure
        returns (bool)
    {
        require(nowTime > renting.rentedAt, "TL::now before rented");
        return
            nowTime - renting.rentedAt > renting.rentDuration * SECONDS_IN_DAY;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
pragma solidity =0.8.1;

interface ILeasing {
    event Lend(
        address indexed lenderAddress,
        address indexed nftAddress,
        uint256 indexed tokenID,
        uint256 lendingID,
        uint8 maxRentDuration,
        uint8 rentSharePercentage
    );

    event Rent(
        address indexed renterAddress,
        uint256 indexed lendingID,
        uint256 indexed rentingID,
        uint8 rentDuration,
        uint32 rentedAt
    );

    event StopLend(uint256 indexed lendingID, uint32 stoppedAt);

    event StopRent(uint256 indexed rentingID, uint32 stoppedAt);

    struct CallData {
        uint256 left;
        uint256 right;
        address[] nftAddress;
        uint256[] tokenID;
        uint8[] maxRentDuration;
        uint8[] rentSharePercentage;
        uint256[] lendingID;
        uint256[] rentingID;
        uint8[] rentDuration;        
    }

    struct Lending {
        address payable lenderAddress;
        uint8 maxRentDuration;
        uint8 rentSharePercentage;
    }

    struct Renting {
        address payable renterAddress;
        uint8 rentDuration;
        uint32 rentedAt;
    }

    // creates the lending structs and adds them to the enumerable set
    function lend(
        address[] memory nftAddress,
        uint256[] memory tokenID,        
        uint8[] memory maxRentDuration,
        uint8[] memory rentSharePercentage
    ) external;

    function stopLend(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory lendingID
    ) external;

    function editLend(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint8[] memory maxRentDuration,
        uint8[] memory rentSharePercentage,
        uint256[] memory _lendingID
    ) external;

    // // creates the renting structs and adds them to the enumerable set
    function rent(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint8[] memory rentDuration,
        uint256[] memory lendingID
    ) external payable;

    function stopRent(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint256[] memory lendingID,
        uint256[] memory rentingID
    ) external;

    function editRent(
        address[] memory nftAddress,
        uint256[] memory tokenID,
        uint8[] memory rentDuration,
        uint256[] memory _rentingID
    ) external;
    
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