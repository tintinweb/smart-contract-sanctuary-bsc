// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./library/ReverseDutchAuctionBase.sol";
import "./library/IReverseDutchAuction.sol";

contract ReverseDutchAuctionNative is ReverseDutchAuctionBase, IReverseDutchAuction {

    /* solhint-disable */
    constructor(
        address trustedNFTAddress,
        address treasury,
        uint256 minUnitPrice_,
        uint256 minBid_,
        uint256 maxBid_,
        uint256 maxTotalBid_
    ) ReverseDutchAuctionBase(
        trustedNFTAddress,
        treasury,
        minUnitPrice_,
        minBid_,
        maxBid_,
        maxTotalBid_
    ) {
        
    }
    /* solhint-enable */
    
    function bidETH() external payable override {
        _processBid(msg.value);
    }

    function bid(uint256) external pure override {
        revert(FORBIDDEN_ERR);
    }

    function refund() external override {
        address payable sender = payable(_msgSender());
        sender.transfer(_processRefund());
    }

    function claim() external override {
        (uint256 reward, uint256 change) = _processClaim();
        if (reward != 0)
            _transferLotItems(_msgSender(), reward);
        if (change != 0)
            payable(msg.sender).transfer(change);
    }

    function claimTreasury() external override {
        address payable sender = payable(_treasury);
        sender.transfer(_processClaimTreasury());
    }

    function claimLotChange() external override {
        super._processClaimLotChange();
    }

    function refundLot() external override {
        super._processRefundLot();
    }

    function stage() external override returns(Stages) {
        return super._getStage();
    }

    function lastCommittedStage() external override view returns (Stages) {
        return _stage;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "./Stages.sol";
import "./IterableAddressSet.sol";

// solhint-disable not-rely-on-time
// solhint-disable indent

abstract contract ReverseDutchAuctionBase is Ownable(), IERC721Receiver, ERC721Holder {
    using IterableAddressSet for IterableAddressSet.Set;

    /** Events
     */
    event Bid(address indexed sender, uint256 amount);
    event Refunded(address indexed sender);
    event ClaimedReward(address indexed sender, uint256 reward);
    event ClaimedChange(address indexed sender, uint256 change);
    event FinishTimestampUpdated(uint256 ts);
    event StartTimestampUpdated(uint256 ts);

    event Started();
    event Scheduled();
    event Ongoing();
    event Finalized();
    event Aborted();

    /** Error messages
     */
    string public constant FORBIDDEN_ERR = "errno#1";
    string public constant WRONG_STAGE_ERR = "errno#2";
    string public constant INVALID_AMOUNT_ERR = "errno#3";
    string public constant INCONSISTENT_TIMESTAMPS_ERR = "errno#4";
    string public constant INCONSISTENT_AUCTION_STATE_ERR = "errno#5";

    /** State public
     */
    mapping(address => uint256) public submissions;
    mapping(address => bool) public rewardClaimed;
    uint256 public totalSubmissionAmount;

    IERC721 public trustedNFT;
    uint256[] public nftIds;

    uint256 public startTimestamp;
    uint256 public finishTimestamp;
    bool public treasuryClaimed;
    
    /** State public immutable
     */
    uint256 public immutable minUnitPrice;
    uint256 public immutable minBid;
    uint256 public immutable maxBid;
    uint256 public immutable maxTotalBid;
    
    /** State internal
     */
    IterableAddressSet.Set internal _bidMakers;
    Stages internal _stage;
    address internal _nftOwner;
    address internal _treasury;
    uint256 internal _nftIdPtr = 0;
    
    /** Modifiers
     */
    modifier isCreated {
        require(_stage == Stages.Created, WRONG_STAGE_ERR);
        _;
    }

    modifier isScheduled {
        _countdown();
        require(_stage == Stages.Scheduled, WRONG_STAGE_ERR);
        _;
    }

    modifier isOngoing {
        _countdown();
        require(_stage == Stages.Ongoing, WRONG_STAGE_ERR); 
        _;
    }

    modifier isScheduledOrOngoint {
        _countdown();
        require(
            _stage == Stages.Ongoing ||
            _stage == Stages.Scheduled,
            WRONG_STAGE_ERR
        );
        _;
    }

    modifier isFinalized {
        _countdown();
        require(_stage == Stages.Finalized, WRONG_STAGE_ERR);
        _;
    }

    modifier isOngoingOrAborted {
        _countdown();
        require(
            _stage == Stages.Ongoing || _stage == Stages.Aborted,
            WRONG_STAGE_ERR
        );
        _;
    }

    modifier notFinalizedOrAborted {
        _countdown();
        require(_stage != Stages.Aborted && _stage != Stages.Finalized, WRONG_STAGE_ERR);
        _;
    }

    modifier isAborted {
        require(_stage == Stages.Aborted, WRONG_STAGE_ERR);
        _;
    }

    /** Constructor
     */
    /* solhint-disable func-visibility */
    constructor (
        address trustedNFTAddress,
        address treasury,
        uint256 minUnitPrice_,
        uint256 minBid_,
        uint256 maxBid_,
        uint256 maxTotalBid_
    ) {
        trustedNFT = IERC721(trustedNFTAddress);
        minUnitPrice = minUnitPrice_;
        minBid = minBid_;
        maxBid = maxBid_;
        maxTotalBid = maxTotalBid_;
        _treasury = treasury;
        _setStage(Stages.Created);
    }
    /* solhint-enable func-visibility */

    function initialize(
        address nftOwner, 
        uint256[] memory nftIds_, 
        uint256 startTimestamp_, 
        uint256 finishTimestamp_
    ) external onlyOwner isCreated {
        require(nftIds_.length > 0);
        _nftOwner = nftOwner;
        nftIds = nftIds_;
        require(
            finishTimestamp_ > startTimestamp_ &&
            startTimestamp_ > block.timestamp,
            INCONSISTENT_TIMESTAMPS_ERR
        );
        finishTimestamp = finishTimestamp_;
        startTimestamp = startTimestamp_;
        _setStage(Stages.Scheduled);
        for (uint i = 0; i < nftIds_.length; ++i)
            trustedNFT.safeTransferFrom(_nftOwner, address(this), nftIds_[i]);
    }

    function setStartTimestamp(uint256 ts) external onlyOwner isScheduled {
        require(_stage != Stages.Finalized && _stage != Stages.Aborted, WRONG_STAGE_ERR);
        require(finishTimestamp == 0 || ts < finishTimestamp, INCONSISTENT_TIMESTAMPS_ERR);
        require(ts > block.timestamp, INCONSISTENT_TIMESTAMPS_ERR);
        emit StartTimestampUpdated(ts);
        startTimestamp = ts;
        if (finishTimestamp != 0)
            _setStage(Stages.Scheduled);
    }

    function setFinishTimestamp(uint256 ts) external onlyOwner isScheduledOrOngoint {
        require(_stage != Stages.Finalized && _stage != Stages.Aborted, WRONG_STAGE_ERR);
        require(ts > startTimestamp, INCONSISTENT_TIMESTAMPS_ERR);
        require(ts > block.timestamp, INCONSISTENT_TIMESTAMPS_ERR);
        finishTimestamp = ts;
        emit FinishTimestampUpdated(ts);
        if (startTimestamp != 0)
            _setStage(Stages.Scheduled);
    }

    function forceFinalize() external onlyOwner isOngoing {
        require(!_isInconsistent(), INCONSISTENT_AUCTION_STATE_ERR);
        _setStage(Stages.Finalized);
    }

    function abort() external onlyOwner notFinalizedOrAborted {
        _setStage(Stages.Aborted);
    }

    /// @notice issue: owner access!
    function setTreasury(address treasury) external onlyOwner {
        _treasury = treasury;
    }

    function getTreasury() external view onlyOwner returns (address) {
        return _treasury;
    }

    /** Internal functions
     */

    function _transferLotItems(address to, uint256 n) internal {
        require(_nftIdPtr + n <= nftIds.length);
        for (uint i = 0; i < n; ++i) {
            trustedNFT.safeTransferFrom(address(this), to, nftIds[_nftIdPtr]);
            _nftIdPtr++;
        }
    }

    function _processBid(uint256 amount) internal isOngoing {
        uint256 senderNewTotalBid = submissions[_msgSender()] + amount;
        require(
            (
                amount <= maxBid && 
                amount >= minBid &&
                senderNewTotalBid <= maxTotalBid
            ),
            INVALID_AMOUNT_ERR
        );
        submissions[_msgSender()] = senderNewTotalBid;
        totalSubmissionAmount += amount;
        _bidMakers.add(_msgSender());
        emit Bid(_msgSender(), amount);
    }

    function _processRefund() internal isOngoingOrAborted returns(uint256) {
        uint256 senderTotalBid = submissions[_msgSender()];
        require(senderTotalBid != 0, INVALID_AMOUNT_ERR);
        submissions[_msgSender()] = 0;
        totalSubmissionAmount -= senderTotalBid;
        _bidMakers.remove(_msgSender());

        emit Refunded(_msgSender());
        return senderTotalBid;
    }

    function _processClaim() internal isFinalized returns(uint256, uint256) {
        require(!rewardClaimed[_msgSender()], INVALID_AMOUNT_ERR);
        rewardClaimed[_msgSender()] = true;

        uint256 reward = _getRewardUnitsCount(_msgSender());
        uint256 change = _getChange(_msgSender());

        emit ClaimedReward(_msgSender(), reward);
        emit ClaimedChange(_msgSender(), change);

        return (reward, change);
    }

    function _processClaimTreasury() internal isFinalized returns (uint256) {
        require(!treasuryClaimed, INVALID_AMOUNT_ERR);
        require(
            _msgSender() == _treasury,
            FORBIDDEN_ERR
        );
        treasuryClaimed = true;
        uint256 unitPrice = _getUnitPrice();
        return _calcUnits() * unitPrice;
    }

    function _processClaimLotChange() internal isFinalized {
        require(
            _msgSender() == _nftOwner,
            FORBIDDEN_ERR
        );
        uint256 change = nftIds.length - _calcUnits();
        _transferLotItems(_nftOwner, change);
    }
 
    function _processRefundLot() internal isAborted {
        require(
            _msgSender() == _nftOwner,
            FORBIDDEN_ERR
        );
        _transferLotItems(_nftOwner, nftIds.length);
    }

    function _calcUnits() internal view returns (uint256) {
        uint256 units = 0;
        uint256 unitPrice = _getUnitPrice();
        for (uint256 i = 0; i < _bidMakers.keys.length; ++i)
            units += submissions[_bidMakers.keys[i]] / unitPrice;
        return units;
    }

    /// @notice floor! 
    function _getUnitPrice() internal view returns(uint256) {
        return totalSubmissionAmount / nftIds.length;
    }

    function _getRewardUnitsCount(address sender) internal view returns(uint256) {
        return submissions[sender] / _getUnitPrice();
    }

    function _getChange(address sender) internal view returns(uint256) {
        return submissions[sender] % _getUnitPrice();
    }

    function _getStage() internal returns(Stages) {
        _countdown();
        return _stage;
    }

    function _setStage(Stages newStage) internal {
        if (newStage == Stages.Scheduled)
            emit Scheduled();
        else if (newStage == Stages.Ongoing)
            emit Ongoing();
        else if (newStage == Stages.Finalized)
            emit Finalized();
        else if (newStage == Stages.Aborted)
            emit Aborted();
        _stage = newStage;
    }

    function _isInconsistent() internal view returns (bool) {
        return (
            _getUnitPrice() < minUnitPrice || 
            _calcUnits() > nftIds.length
        );
    }

    function _countdown() internal {
        if (_stage == Stages.Scheduled && block.timestamp >= startTimestamp)
            _setStage(Stages.Ongoing);
        if (_stage == Stages.Ongoing && block.timestamp > finishTimestamp)
            _setStage(Stages.Finalized);
        if (_stage == Stages.Finalized && _isInconsistent())
            _setStage(Stages.Aborted);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Stages.sol";

/// @dev an external interface for reversed dutch auction
interface IReverseDutchAuction {
    
    /// @notice bids an amount in ether
    function bidETH() external payable;

    /// @notice bids an amount in specified token
    function bid(uint256) external;

    /// @notice refunds money if aborted or not yet finalized
    function refund() external;

    /// @notice claims reward and change if finalized
    function claim() external;

    /// @notice claims treasury and change if finalized
    function claimTreasury() external;

    /// @notice claims unused NFT's
    function claimLotChange() external;

    /// @notice refunds treasury if aborted
    function refundLot() external;

    /// @notice returns *actual* auction stage and updates it
    function stage() external returns(Stages);

    /// @notice returns *inconsistent* auction stage
    function lastCommittedStage() external view returns (Stages);

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

pragma solidity ^0.8.7;

/// @dev solhint gone crazy
// solhint-disable 

enum Stages {
    Created,
    Scheduled,
    Ongoing,
    Finalized,
    Aborted
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

library IterableAddressSet {

    struct Set {
        address[] keys;
        mapping(address => uint256) ids;
    }

    function inside(Set storage self, address x) public view returns (bool) {
        return self.ids[x] != 0;
    }

    function add(Set storage self, address x) public {
        if (!inside(self, x)) {
            self.keys.push(x);
            self.ids[x] = self.keys.length;
        }
    }

    function remove(Set storage self, address x) public {
        if (inside(self, x)) {
            uint256 id = self.ids[x] - 1;
            uint256 last = self.keys.length - 1;
            if (id != last) {
                self.ids[self.keys[last]] = id + 1;
                (
                    self.keys[last],
                    self.keys[id]
                ) = (
                    self.keys[id],
                    self.keys[self.keys.length - 1]
                );
            }
            delete self.ids[x];
            self.keys.pop();
        }
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