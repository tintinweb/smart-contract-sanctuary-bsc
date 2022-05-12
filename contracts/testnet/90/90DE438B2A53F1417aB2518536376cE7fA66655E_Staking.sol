/**
 *Submitted for verification at BscScan.com on 2022-05-12
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

contract Staking {
    uint256 public totalStaked;

    /**
     * percent: % change
     * action: 0 decreasing, 1: increasing
     */
    struct Propsal {
        uint256 percent;
        uint8 action;
    }

    /**
     * @param owner: address of user staked
     * @param timestamp: last time check
     * @param amount: amount that user spent
     */
    struct Stake {
        uint256 stakeId;
        address owner;
        uint256 timestamp;
        uint256 amount;
        uint256 nftId;
        uint8 duration;
        uint16 apr;
    }

    event Staked(
        uint256 indexed stakeId,
        address indexed owner,
        uint256 amount,
        uint8 duration,
        uint16 apr,
        uint256 nftId
    );

    event Unstaked(
        uint256 indexed stakeId,
        address indexed owner,
        uint256 claimed
    );

    event Claimed(
        uint256 indexed stakeId,
        address indexed owner,
        uint256 indexed amount
    );

    IERC20 WDATokenAddress;
    address _owner;
    address _DaoTreasuryWallet;

    ICrownNFT CrownContract;
    Propsal public p;

    // maps address of user to stake
    mapping(address => Stake[]) vault;

    constructor() {
        _owner = msg.sender;
    }

    //** -------------- TEST ONLY --------------- */
    function removeDuration(uint256 stakingId) public {
        vault[msg.sender][stakingId].timestamp = 0;
    }

    function setCrownContract(address _CrownAddress) external {
        require(_onlyOwnerOf(_owner));
        CrownContract = ICrownNFT(_CrownAddress);
    }

    function setDaoTreasuryWallet(address newAddress) external {
        _DaoTreasuryWallet = newAddress;
    }

    uint256 maxPercent = 10;

    function setMaxPercent(uint256 maxP) external {
        require(_onlyOwnerOf(_owner), "Ownable: Not owner");
        maxPercent = maxP;
    }

    function setWDAToken(IERC20 token) external {
        WDATokenAddress = token;
    }

    //** -------------- END OF TEST ONLY --------------- */

    /**
     * @dev function for the future voting for update staking v2
     */
    function withdrawWDAToDAOTreasury() external {
        require(msg.sender == _owner);
        uint256 amount = WDATokenAddress.balanceOf(address(this));
        WDATokenAddress.transfer(_DaoTreasuryWallet, amount);
    }

    /**
     * @param percentChange: update percent proposal
     * @param action: 0 deceasing, 1: increasting
     */
    function setProposal(uint256 percentChange, uint8 action) external {
        require(_onlyOwnerOf(_owner), "Ownable: Not owner");
        require(percentChange <= maxPercent, "Percentage too big");
        p.action = action;
        p.percent = percentChange;
    }

    /**
     * @param _ownerAddress: validatation address
     * @return true/false
     */
    function _onlyOwnerOf(address _ownerAddress) internal view returns (bool) {
        if (msg.sender == _ownerAddress) {
            return true;
        }
        return false;
    }

    /**
     * @param id: 1 fixed - 30, 2 fixed - 90, 3 fixed - 180, 0: unfixed
     */
    function getPackageDetailById(uint256 id, uint256 nftId)
        public
        view
        returns (uint16, uint8)
    {
        uint16 apr = 5;
        uint8 duration = 0;
        if (id != 0) {
            if (id == 1) {
                apr = 100;
                duration = 30;
            } else if (id == 3) {
                apr = 138;
                duration = 90;
            } else {
                apr = 220;
                duration = 180;
            }

            if (nftId != 0) {
                require(
                    CrownContract.ownerOf(nftId) == msg.sender,
                    "Ownable: Not owner"
                );
                ICrownNFT.CrownTraits memory detailNFT = CrownContract
                    .getTraits(nftId);
                require(detailNFT.staked == false, "Crown staked");
                uint256 aprBonus = detailNFT.aprBonus;

                apr += uint16(aprBonus);
            }

            if (p.percent != 0) {
                apr = p.action == 0
                    ? apr - uint16(p.percent)
                    : apr + uint16(p.percent);
            }
        }
        return (apr, duration);
    }

    /**
     * @param _stakingId: 1 fixed - 30, 2 fixed - 90, 3 fixed - 180, 0: unfixed
     * @param _nftId: nft id for more % bonus nft
     * @param _amount: amount user spent
     */
    function stake(
        uint8 _stakingId,
        uint256 _nftId,
        uint256 _amount
    ) external {
        (uint16 apr, uint8 duration) = getPackageDetailById(_stakingId, _nftId);
        uint256 allowance = WDATokenAddress.allowance(
            msg.sender,
            address(this)
        );
        require(allowance >= _amount, "Over allowance WDA");
        WDATokenAddress.transferFrom(msg.sender, address(this), _amount);

        if (_nftId != 0) {
            CrownContract.stakeOrUnstake(_nftId, true);
        }

        totalStaked += _amount;
        uint256 newStakeId = vault[msg.sender].length;
        vault[msg.sender].push(
            Stake(
                newStakeId,
                msg.sender,
                block.timestamp,
                _amount,
                _nftId,
                duration,
                apr
            )
        );
        emit Staked(newStakeId, msg.sender, _amount, duration, apr, _nftId);
    }

    function claim(uint256 _stakingId) external {
        Stake memory staked = vault[msg.sender][_stakingId];
        require(_onlyOwnerOf(staked.owner), "Ownable: Not owner");
        uint256 lastTimeCheck = staked.timestamp;
        uint256 stakeDuration = uint256(staked.duration);
        if (stakeDuration != 0) {
            require(
                block.timestamp >=
                    (lastTimeCheck + (stakeDuration * 24 * 60 * 60)),
                "Staking locked"
            );
        }
        // nếu là gói cố định thì phải đúng thời hạn mới claim được
        uint256 finalApr = uint256(staked.apr);
        uint256 _amountUserSpent = staked.amount;
        uint256 earned = 0;
        if (stakeDuration != 0) {
            _deleteStakingPackage(msg.sender, _stakingId); // gói cố định rút xong thì unstake luôn
            // tránh số lẻ
            earned =
                ((_amountUserSpent * // user spend
                    finalApr * // calculate apr
                    stakeDuration) / // convert to month
                    12 /
                    100) +
                _amountUserSpent;
        } else {
            uint256 stakedTimeClaim = (block.timestamp - lastTimeCheck) /
                1 days;
            // tránh số lẻ
            earned = (_amountUserSpent * finalApr * stakedTimeClaim) / 12 / 30; // tiền lãi theo ngày * số ngày
            vault[msg.sender][_stakingId].timestamp = uint32(block.timestamp);
        }
        if (earned > 0) {
            WDATokenAddress.transfer(msg.sender, earned);
            emit Claimed(_stakingId, msg.sender, earned);
        }
    }

    function unstake(uint256 _stakingId) external {
        Stake memory staked = vault[msg.sender][_stakingId];
        require(staked.duration == 0, "Cannot unstake fixed staking package");
        require(_onlyOwnerOf(staked.owner), "Ownable: Not owner");
        // xoá staking
        _deleteStakingPackage(msg.sender, _stakingId);
        uint256 lastTimeCheck = staked.timestamp;
        uint256 _amountUserSpent = staked.amount;
        uint256 earned = 0;
        uint256 stakedTimeClaim = (block.timestamp - lastTimeCheck) / 1 days;
        // tránh số lẻ
        earned =
            (_amountUserSpent * uint256(staked.apr) * stakedTimeClaim) /
            12 /
            30; // tiền lãi theo ngày * số ngày
        // trả gốc
        earned += _amountUserSpent;
        emit Unstaked(_stakingId, msg.sender, earned);
        if (earned > 0) {
            WDATokenAddress.transfer(msg.sender, earned);
            emit Claimed(_stakingId, msg.sender, earned);
        }
    }

    function getEarned(uint256 stakingId) external view returns (uint256) {
        Stake memory ownerStaking = vault[msg.sender][stakingId];
        require(_onlyOwnerOf(ownerStaking.owner), "Ownable: Not owner");
        require(ownerStaking.duration == 0, "Not valid staking");
        uint256 stakedTimeClaim = (block.timestamp - ownerStaking.timestamp) /
            1 days;
        uint256 finalApr = uint256(ownerStaking.apr);
        // tránh số lẻ
        return (ownerStaking.amount * finalApr * stakedTimeClaim) / 12 / 30; // tiền lãi theo ngày * số ngày
    }

    function _deleteStakingPackage(address account, uint256 stakingId)
        internal
    {
        if (vault[account][stakingId].nftId != 0) {
            CrownContract.stakeOrUnstake(
                vault[account][stakingId].nftId,
                false
            );
        }
        delete vault[account][stakingId];
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
        require(_onlyOwnerOf(_owner), "Ownable: Not owner");
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