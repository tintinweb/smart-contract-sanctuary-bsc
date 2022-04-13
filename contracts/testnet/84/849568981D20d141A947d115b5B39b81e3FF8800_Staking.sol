/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;



// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface ICrownNFT is IERC721, IERC721Enumerable {
    struct CrownTraits {
        uint256 reduce;
        uint256 aprBonus;
        uint256 lockDeadline;
        bool staked;
    }

    function getTraits(uint256) external view returns (CrownTraits memory);

    function mintValidTarget(uint256 number) external;
}


contract Staking {
    uint256 public totalStaked;

    /**
     * @param owner: address of user staked
     * @param timestamp: last time check
     * @param stakingType: 0 -> unfixed, 1: fixed
     * @param amount: amount that user spent
     */
    struct Stake {
        address owner;
        uint32 timestamp;
        uint8 stakingType;
        uint256 amount;
        uint256 claimed;
        uint8 duration;
        uint16 apr;
    }

    event Staked(
        address indexed owner,
        uint256 indexed amount,
        uint8 indexed stakingType,
        uint32 timestamp,
        uint8 _duration,
        uint16 apr
    );
    event Unstaked(
        address indexed owner,
        uint8 indexed stakingType,
        uint256 claimed
    );
    event Claimed(address indexed owner, uint256 indexed amount);
    address _WDAtokenAddress;
    address _owner;
    ICrownNFT CrownContract;
    // maps address of user to stake
    mapping(address => Stake[]) vault;
    mapping(address => uint256) public ownerStakingCount;

    constructor(address _token) {
        _WDAtokenAddress = _token;
        _owner = msg.sender;
    }

    function setCrownContract(address _CrownAddress) external {
        require(_onlyOwnerOf(_owner));
        CrownContract = ICrownNFT(_CrownAddress);
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
     * @param _duration: staking duration
     * @return apr matching to duration
     */
    function _getAprByDuration(uint8 _duration) internal pure returns (uint16) {
        require(
            _duration == 1 || _duration == 3 || _duration == 6,
            "Invalid duration staking time"
        );
        if (_duration == 1) {
            return 100;
        } else if (_duration == 3) {
            return 138;
        } else {
            return 220;
        }
    }

    function _getBonusNFT(uint8 duration, uint256 amount)
        internal
        pure
        returns (bool)
    {
        if (amount >= 330000 && duration == 12) {
            return true;
        } else if (amount >= 800000 && duration == 6) {
            return true;
        } else if (amount >= 2000000 && duration == 3) {
            return true;
        }
        return false;
    }

    /**
     * @param _stakingType: 0-> unfixed, 1 -> fixed
     * @param _nftApr: nft id for more % bonus nft
     * @param _amount: amount user spent
     * @param _duration: duration
     */
    function stake(
        uint8 _stakingType,
        uint16 _nftApr,
        uint256 _amount,
        uint8 _duration
    ) external {
        uint16 _apr = _stakingType == 0
            ? 5
            : _nftApr + _getAprByDuration(_duration);
        totalStaked += _amount;
        vault[msg.sender].push(
            Stake(
                msg.sender,
                uint32(block.timestamp),
                _stakingType,
                _amount,
                0,
                _duration,
                _apr
            )
        );
        ownerStakingCount[msg.sender]++;
        uint256 allowance = IERC20(_WDAtokenAddress).allowance(
            msg.sender,
            address(this)
        );
        require(allowance >= _amount, "Over allowance WDA");
        IERC20(_WDAtokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        emit Staked(
            msg.sender,
            _amount,
            _stakingType,
            uint32(block.timestamp),
            _duration,
            _apr
        );
    }

    function _mintCrownTo(address _to) internal {
        CrownContract.mintValidTarget(1);
        uint256 _newTokenId = CrownContract.tokenOfOwnerByIndex(
            address(this), 
            CrownContract.balanceOf(address(this)) - 1
        );
        CrownContract.transferFrom(
            address(this),
            _to,
            _newTokenId
        );
    }

    function claim(uint256 _stakingId) external {
        Stake memory staked = vault[msg.sender][_stakingId];
        require(_onlyOwnerOf(staked.owner), "Ownable: Not owner");
        uint32 lastTimeCheck = staked.timestamp;
        uint8 stakeDuration = staked.duration;
        // nếu là gói cố định thì phải đúng thời hạn mới claim được
        if (staked.stakingType == 1) {
            require(
                uint32(block.timestamp) >=
                    uint32(
                        lastTimeCheck +
                            (uint32(stakeDuration) * 30 * 24 * 60 * 60)
                    ),
                "Staking locked"
            );
        }
        uint256 _amountUserSpent = staked.amount;
        uint256 earned = 0;
        if (staked.stakingType == 1) {
            // uint16 _aprByDuration = staked.apr * stakeDuration / 12; // calculate apr by duration
            _deleteStakingPackage(msg.sender, _stakingId); // gói cố định rút xong thì unstake luôn
            ownerStakingCount[msg.sender]--;
            // tránh số lẻ
            earned =
                ((_amountUserSpent * staked.apr * stakeDuration) / 12 / 100) +
                _amountUserSpent;
            // thưởng nft nếu user staking valid
            bool isGetBonusNFT = _getBonusNFT(stakeDuration, _amountUserSpent);
            if (isGetBonusNFT) {
                _mintCrownTo(msg.sender);
            }
        } else {
            uint32 stakedTimeClaim = (uint32(block.timestamp) - lastTimeCheck) /
                1 days;
            // uint16 _aprByDuration = (staked.apr / 12) / 30 ; // calculate apr by date

            // tránh số lẻ
            earned =
                (_amountUserSpent * staked.apr * stakedTimeClaim) /
                12 /
                30; // tiền lãi theo ngày * số ngày
            vault[msg.sender][_stakingId].claimed += earned;
            vault[msg.sender][_stakingId].timestamp = uint32(block.timestamp);
        }
        if (earned > 0) {
            IERC20(_WDAtokenAddress).transfer(msg.sender, earned);
            emit Claimed(msg.sender, earned);
        }
    }

    function unstake(uint256 _stakingId) external {
        Stake memory staked = vault[msg.sender][_stakingId];
        require(_onlyOwnerOf(staked.owner), "Ownable: Not owner");
        // xoá staking
        _deleteStakingPackage(msg.sender, _stakingId);
        ownerStakingCount[msg.sender]--;
        uint32 lastTimeCheck = staked.timestamp;
        uint8 stakeDuration = staked.duration;
        uint256 _amountUserSpent = staked.amount;
        // nếu là gói cố định thì phải đúng thời hạn mới claim được
        uint256 earned = 0;
        if (staked.stakingType == 1) {
            // đủ hạn rút và bấm huỷ thì sẽ rút tiền xong tự huỷ
            if (
                uint32(block.timestamp) >=
                uint32(
                    lastTimeCheck + (uint32(stakeDuration) * 30 * 24 * 60 * 60)
                )
            ) {
                earned =
                    ((_amountUserSpent *
                        uint256(staked.apr) *
                        uint256(stakeDuration)) /
                        12 /
                        100) +
                    _amountUserSpent;
                // thưởng crown
                bool isGetBonusNFT = _getBonusNFT(
                    stakeDuration,
                    _amountUserSpent
                );
                if (isGetBonusNFT) {
                    _mintCrownTo(msg.sender);
                }
            } else {
                // chưa đủ hạn rút thì chỉ trả lại số gốc
                earned = _amountUserSpent;
            }
        } else {
            uint256 stakedTimeClaim = uint256(
                (block.timestamp - uint256(lastTimeCheck)) / 1 days
            );
            // uint16 _aprByDuration = (staked.apr / 12) / 30 ; // calculate apr by date

            // tránh số lẻ
            earned =
                (_amountUserSpent * uint256(staked.apr) * stakedTimeClaim) /
                12 /
                30; // tiền lãi theo ngày * số ngày
            // trả gốc
            earned += _amountUserSpent;
        }
        IERC20(_WDAtokenAddress).transfer(msg.sender, earned);
        emit Claimed(msg.sender, earned);
    }

    function _deleteStakingPackage(address account, uint256 stakingId)
        internal
    {
        emit Unstaked(
            account,
            vault[account][stakingId].stakingType,
            vault[account][stakingId].claimed
        );
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