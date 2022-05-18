/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

pragma solidity ^0.8.11;

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)
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

// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)
/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

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
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

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

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)
/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

//SPDX-License-Identifier: MIT
interface ICrownNFT is IERC721, IERC721Enumerable {
    struct CrownTraits {
        uint256 reduce;
        uint256 aprBonus;
        uint256 lockDeadline;
        bool staked;
    }

    function getTraits(uint256) external view returns (CrownTraits memory);

    function mintValidTarget(uint256 number) external returns (uint256);

    function burn(uint256 tokenId) external;

    function stakeOrUnstake(uint256, bool) external;
}

contract Mining {
    uint256 public mintedQuantity;

    /**
     * percent: % change
     * action: 0 decreasing, 1: increasing
     */
    struct Propsal {
        uint256 percent;
        uint8 action;
    }

    struct Mint {
        uint256 id;
        address owner;
        uint256 timestamp;
        uint256 amount;
        uint256 duration;
        uint256 contributeNFTId;
        uint256 receiveNFTId;
    }

    event Minted(
        uint256 indexed id,
        address indexed owner,
        uint256 amount,
        uint256 indexed duration,
        uint256 contributeNFTId,
        uint256 receiveNFTId
    );

    event Claimed(
        uint256 indexed id,
        address indexed owner,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 duration
    );

    address _WDAtokenAddress;
    address _owner;

    ICrownNFT CrownContract;
    Propsal public p;
    // maps address of user to stake
    mapping(address => Mint[]) vault;

    constructor(address _token) {
        _WDAtokenAddress = _token;
        _owner = msg.sender;
    }

    /** ============== TEST ONLY ================ */
    function removeDuration(uint256 mintingId) public {
        vault[msg.sender][mintingId].timestamp = 0;
    }

    function setCrownContract(address _CrownAddress) external {
        CrownContract = ICrownNFT(_CrownAddress);
    }

    uint256 maxPercentProposal = 10;

    function setMaxPercentProposal(uint256 percent) external {
        maxPercentProposal = percent;
    }

    address WinDaoAddress;

    function setWinDAOAddress(address _newWinDaoAddress) external {
        WinDaoAddress = _newWinDaoAddress;
    }

    /** ============== END OF TEST ONLY ============== */

    /**
     * @param percentChange: update percent proposal
     * @param action: 0 deceasing, 1: increasting
     */
    function setProposal(uint256 percentChange, uint8 action) external {
        require(
            msg.sender == _owner || msg.sender == WinDaoAddress,
            "Ownable: Not owner"
        );
        require(percentChange <= maxPercentProposal, "Percentage too big");
        p.action = action;
        p.percent = percentChange;
    }

    function getWDAByPackageId(uint8 packageId, uint256 nftId)
        public
        view
        returns (uint256, uint256)
    {
        uint256 finalAmount;
        uint256 duration;
        if (packageId == 1) {
            finalAmount = 330000 * 10**18;
            duration = 360;
        } else if (packageId == 2) {
            finalAmount = 800000 * 10**18;
            duration = 180;
        } else if (packageId == 3) {
            finalAmount = 2000000 * 10**18;
            duration = 90;
        }
        require(finalAmount > 0, "Invalid Mining Package");
        if (p.percent != 0) {
            if (p.action == 0) {
                finalAmount += ((finalAmount * p.percent) / 100);
            } else {
                finalAmount -= ((finalAmount * p.percent) / 100);
            }
        }
        if (nftId != 0) {
            require(
                CrownContract.ownerOf(nftId) == msg.sender,
                "Ownable: Not owner"
            );
            ICrownNFT.CrownTraits memory nftDetail = CrownContract.getTraits(
                nftId
            );
            require(nftDetail.staked == false, "Crown staked");
            finalAmount -= ((finalAmount * nftDetail.reduce) / 100);
        }
        return (finalAmount, duration);
    }

    /**
     * @param _miningType: 1, 2, 3
     * @param _nftId: apply nft to reduce fee
     */
    function mint(uint8 _miningType, uint256 _nftId) external {
        require(CrownContract.totalSupply() < 5000, "Over Crown supply");
        (uint256 finalAmount, uint256 duration) = getWDAByPackageId(
            _miningType,
            _nftId
        );

        uint256 allowance = IERC20(_WDAtokenAddress).allowance(
            msg.sender,
            address(this)
        );
        require(allowance >= finalAmount, "Over allowance WDA");
        if (_nftId != 0) {
            CrownContract.stakeOrUnstake(_nftId, true);
        }
        IERC20(_WDAtokenAddress).transferFrom(
            msg.sender,
            address(this),
            finalAmount
        );
        // mint crown for this mining
        CrownContract.mintValidTarget(1);
        uint256 receiveTokenId = CrownContract.tokenOfOwnerByIndex(
            address(this),
            CrownContract.balanceOf(address(this)) - 1
        );
        //
        vault[msg.sender].push(
            Mint(
                mintedQuantity,
                msg.sender,
                block.timestamp,
                finalAmount,
                duration,
                _nftId,
                receiveTokenId
            )
        );
        emit Minted(
            mintedQuantity,
            msg.sender,
            finalAmount,
            duration,
            _nftId,
            receiveTokenId
        );
        mintedQuantity++;
    }

    function claim(uint256 _mintingId) external {
        Mint memory minted = vault[msg.sender][_mintingId];
        require(msg.sender == minted.owner, "Ownable: Not owner");
        uint256 lastTimeCheck = minted.timestamp;
        uint256 stakeDuration = minted.duration;
        // phải đúng thời hạn mới claim được
        require(
            block.timestamp >= (lastTimeCheck + (stakeDuration * 24 * 60 * 60)),
            "Minting locked"
        );
        // delete mining
        if (minted.contributeNFTId != 0) {
            CrownContract.stakeOrUnstake(minted.contributeNFTId, false);
        }
        delete vault[msg.sender][_mintingId];
        //
        CrownContract.transferFrom(
            address(this),
            msg.sender,
            minted.receiveNFTId
        );
        emit Claimed(
            minted.id,
            minted.owner,
            minted.receiveNFTId,
            minted.amount,
            minted.duration
        );
        IERC20(_WDAtokenAddress).transfer(msg.sender, minted.amount);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        require(msg.sender == _owner, "Ownable: Not owner");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        _owner = newOwner;
    }
}