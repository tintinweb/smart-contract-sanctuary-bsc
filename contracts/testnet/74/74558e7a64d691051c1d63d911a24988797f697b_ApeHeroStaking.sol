// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./ApeHeroPOWEmission.sol";
import "./ApeHeroStakingPool.sol";
import "./ApeHeroRarity.sol";
import "./ApeHeroStakingAccount.sol";

contract ApeHeroStaking is ApeHeroPOWEmission, ReentrancyGuard, IERC721Receiver {
    using Address for address;
    using Strings for uint;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct ContractData {
        PoolData[] activePools;
        PoolData[] inactivePools;
        uint defaultLockupDuration;
        uint defaultLockupPenalty;
        uint maxDepositPerTx;
        uint maxWithdrawPerTx;
        uint emissionStart;
        uint penaltyBalance;
        uint burnedPenaltyBalance;
        address POW;
        address MASTER_APE;
        address VAULT;
    }

    ApeHeroRarity private RarityManager;
    ApeHeroStakingAccount private AccountManager;
    ApeHeroStakingPool private PoolManager;

    // --- settings --- //
    address public MASTER_APE;
    address public VAULT;
    uint public MAX_DEPOSIT_PER_TX = 10;
    uint public MAX_WITHDRAW_PER_TX = 5;

    // --- POW --- //
    uint public PENALTY_BALANCE;
    uint public BURNED_PENALTY_BALANCE;

    // events
    event FundsDirectlyDeposited(address sender, uint amount, uint timestamp);
    event FundsReceived(address sender, uint amount, uint timestamp);
    event Deposited(uint pid, address depositor, AssetType assetType, NFTType nftType, address asset, uint[] tokenIdsOrAmount, uint timestamp);
    event Withdrew(uint pid, address withdrawer, AssetType assetType, NFTType nftType, address asset, uint[] tokenIdsOrAmount, uint timestamp);
    event EmergencyReleased(uint pid, address executor, address affectedAccount, AssetType assetType, address asset, uint[] tokenIdsOrAmount, uint timestamp);

    event Payout(address indexed account, uint pid, VestedRewards rewards, uint timestamp);
    event AccountUpdated(address indexed account, uint timestamp);
    event RewardEmissionStarted(uint blockNumber, uint timestamp);

    constructor(
        address powToken, address masterApe, address vault,
        address accountManager, address poolManager, address rarityManager
    ) Ownable() {
        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        _grantRole(ADMIN, owner());
        _grantRole(OPERATOR, owner());

        POW = powToken;
        VAULT = vault;
        MASTER_APE = masterApe;
        AccountManager = ApeHeroStakingAccount(accountManager);
        PoolManager = ApeHeroStakingPool(poolManager);
        RarityManager = ApeHeroRarity(rarityManager);
    }

    // --- fallback/received --- //
    receive() external payable {
        emit FundsReceived(_msgSender(), msg.value, block.timestamp);
    }

    fallback() external payable {
        emit FundsDirectlyDeposited(_msgSender(), msg.value, block.timestamp);
    }

    // --- overrides --- //
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // --- ADMIN --- //
    function setMaxDepositPerTx(uint max) external onlyRole(ADMIN) {
        MAX_DEPOSIT_PER_TX = max;
    }

    function setMaxWithdrawPerTx(uint max) external onlyRole(ADMIN) {
        MAX_WITHDRAW_PER_TX = max;
    }

    function startRewardEmission() external onlyRole(ADMIN) {
        require(EMISSION_START == 0, "Emission already started");

        uint startTime = IMasterApe(MASTER_APE).EMISSION_START();
        require(startTime > 0, "POW emission has not started");

        EMISSION_START = startTime;
        PoolManager.activatePoolManager(startTime);
        emit RewardEmissionStarted(block.number, block.timestamp);
    }

    function burnPenaltyBalance() external onlyAdminAndOperator {
        if (PENALTY_BALANCE > 0) {
            IPOW(POW).burn(PENALTY_BALANCE);
            BURNED_PENALTY_BALANCE += PENALTY_BALANCE;
            PENALTY_BALANCE = 0;
        }
    }

    // --- UTILS / INTERNAL --- //
    function handleLockupPenalty(address account, uint deposited, Pool memory pool) internal returns (bool) {
        if (
            EMISSION_START == 0 || pool.lockupDuration == 0 || pool.lockupPenalty == 0 ||
            (block.timestamp - deposited) >= pool.lockupDuration
        ) {
            return true;
        }

        if ((block.timestamp - deposited) < pool.lockupDuration) {
            require(
                IPOW(POW).balanceOf(account) >= pool.lockupPenalty,
                "Insufficient $POW balance to pay for lockup penalty"
            );
            IPOW(POW).transferFrom(account, address(this), pool.lockupPenalty);
            PENALTY_BALANCE += pool.lockupPenalty;
            return true;
        }

        return false;
    }

    // --- STAKING --- //
    function _depositNFT(address account, address asset, address assetVoucher, uint tokenId, uint pid, Rarity rarity, bool isAssetDeposit) internal {
        IERC721(asset).safeTransferFrom(account, address(this), tokenId);
        IVoucher(assetVoucher).mint(1, account);
        AccountManager.createAccountAssets(account, asset, tokenId, AssetType.NFT, rarity, pid);
        isAssetDeposit ? PoolManager.addPoolAssets(pid, 1) : PoolManager.addPoolBoosters(pid, 1);
        AccountManager.addAccountAssets(account, pid, tokenId, true, isAssetDeposit);
    }

    function depositNFT(address account, Pool memory pool, uint pid, uint[] memory tokens, NFTType nftType) internal nonReentrant {
        uint _assetsCount = AccountManager.accountAssetsCount(account, pid, true);
        uint _boostersCount;
        bool isAssetDeposit = nftType == NFTType.Asset;
        if (isAssetDeposit) {
            if (pool.maxAssets > 0) {
                require((_assetsCount + tokens.length) <= pool.maxAssets, "Maximum assets deposit limit reached");
            }
            if (pool.assetRarity != Rarity.NONE) {
                require(RarityManager.validateRarity(pool.asset, pool.assetRarity, tokens), "Invalid rarity");
            }
        } else {
            require(_assetsCount > 0, "Cannot deposit boosters without assets in pool");
            _boostersCount = AccountManager.accountBoostersCount(account, pid);
            if (pool.maxBoosters > 0) {
                require((_boostersCount + tokens.length) <= pool.maxBoosters, "Maximum boosters deposit limit reached");
            }
        }

        AccountManager.settleAccountPoolBalance(account, pid);
        address asset = isAssetDeposit ? pool.asset : pool.booster;
        address assetVoucher = isAssetDeposit ? pool.assetVoucher : pool.boosterVoucher;
        Rarity rarity = isAssetDeposit ? pool.assetRarity : Rarity.NONE;
        for (uint _idx = 0; _idx < tokens.length; _idx++) {
            _depositNFT(account, asset, assetVoucher, tokens[_idx], pid, rarity, isAssetDeposit);
        }

        emit Deposited(pid, account, pool.assetType, nftType, (isAssetDeposit ? pool.asset : pool.booster), tokens, block.timestamp);
    }

    function depositFungible(address account, Pool memory pool, uint pid, uint[] memory tokensAmount) internal nonReentrant {
        uint _amount = tokensAmount[0];
        require(_amount > 0, "Depositing amount must be greater than 0");

        uint _assetsCount = AccountManager.accountAssetsCount(account, pid, false);
        require(pool.maxAssets == 0 || (_amount + _assetsCount) <= pool.maxAssets,"Maximum assets deposit limit reached");
        require(IERC20(pool.asset).balanceOf(account) >= _amount, "Depositing amount cannot be great than owned balance");

        AccountManager.settleAccountPoolBalance(account, pid);
        IERC20(pool.asset).transferFrom(account, address(this), _amount);
        PoolManager.addPoolAssets(pid, _amount);
        AccountManager.addAccountAssets(account, pid, _amount, false, false);

        emit Deposited(pid, account, pool.assetType, NFTType.NONE, pool.asset, tokensAmount, block.timestamp);
    }

    function deposit(uint pid, uint[] memory tokenIdsOrAmount, NFTType nftType) public {
        if (nftType != NFTType.NONE) {
            require(tokenIdsOrAmount.length <= MAX_DEPOSIT_PER_TX, "NFT amount exceeds max deposit limit. Try depositing fewer items per transaction");
        }

        Pool memory _pool = PoolManager.getPoolWithoutRewards(pid);
        require(_pool.status == PoolStatus.ACTIVE, "Pool is not active");

        AccountManager.settleAccountPoolBalance(_msgSender(), pid);
        if (nftType == NFTType.NONE) {
            depositFungible(_msgSender(), _pool, pid, tokenIdsOrAmount);
        } else {
            depositNFT(_msgSender(), _pool, pid, tokenIdsOrAmount, nftType);
        }
        AccountManager.settleAccountPoolBalanceAfterUpdate(_msgSender(), pid);
    }

    function _withdrawNFT(address account, address asset, address assetVoucher, uint tokenId, uint pid, bool isAssetWithdraw) internal {
        IERC721(asset).safeTransferFrom(address(this), account, tokenId);
        IVoucher(assetVoucher).burn(1, account);

        isAssetWithdraw ? PoolManager.subtractPoolAssets(pid, 1) : PoolManager.subtractPoolBoosters(pid, 1);
        AccountManager.removeAccountAssets(account, pid, asset, tokenId, true, isAssetWithdraw);
    }

    function _removeBoostersIfNoAssets(address account, uint pid, Pool memory pool, bool isNFT) internal {
        if (
            AccountManager.accountAssetsCount(account, pid, isNFT) == 0 &&
            AccountManager.accountBoostersCount(account, pid) > 0
        ) {
            Asset[] memory _allPoolBoosters = AccountManager.accountPoolAssets(account, pid, pool, true);
            for (uint _idx = 0; _idx < _allPoolBoosters.length; _idx++) {
                _withdrawNFT(account, pool.booster, pool.boosterVoucher, _allPoolBoosters[_idx].tokenIdOrAmount, pid, false);
            }
        }
    }

    function withdrawNFT(address account, Pool memory pool, uint pid, uint[] memory tokens, NFTType nftType, bool mustPayPenalty) internal nonReentrant {
        uint _assetsCount = AccountManager.accountAssetsCount(account, pid, true);
        uint _boostersCount = AccountManager.accountBoostersCount(account, pid);
        bool isAssetWithdraw = nftType == NFTType.Asset;
        require(
            isAssetWithdraw ? (_assetsCount > 0) : (_boostersCount > 0),
            "No assets found in pool"
        );

        address asset = isAssetWithdraw ? pool.asset : pool.booster;
        address assetVoucher = isAssetWithdraw ? pool.assetVoucher : pool.boosterVoucher;
        for (uint _idx = 0; _idx < tokens.length; _idx++) {
            require(AccountManager.assetOwner(account, asset, tokens[_idx]), "Not owner of asset");
            if (mustPayPenalty && isAssetWithdraw) {
                require(
                    handleLockupPenalty(account, AccountManager.assetDeposited(asset, tokens[_idx]), pool),
                    "Unable to withdraw without paying lockup penalty"
                );
            }
            _withdrawNFT(account, asset, assetVoucher, tokens[_idx], pid, isAssetWithdraw);
        }
        if (isAssetWithdraw) {
            _removeBoostersIfNoAssets(account, pid, pool, true);
        }

        emit Withdrew(pid, account, pool.assetType, nftType, asset, tokens, block.timestamp);
    }

    function withdrawFungible(address account, Pool memory pool, uint pid, uint[] memory tokensAmount, bool mustPayPenalty) internal nonReentrant {
        uint _assetsCount = AccountManager.accountAssetsCount(account, pid, false);
        uint _amount = tokensAmount[0];
        require(
            (_amount > 0) && (_amount <= _assetsCount),
            "Withdraw amount must be greater than 0 and smaller or equal to deposited balance"
        );

        if (mustPayPenalty) {
            require(
                handleLockupPenalty(account, AccountManager.fungibleAssetDeposited(_msgSender(), pid), pool),
                "Unable to withdraw without paying lockup penalty"
            );
        }

        PoolManager.subtractPoolAssets(pid, _amount);
        AccountManager.removeAccountAssets(account, pid, pool.asset, _amount, false, false);
        IERC20(pool.asset).transfer(account, _amount);
        _removeBoostersIfNoAssets(account, pid, pool, false);

        emit Withdrew(pid, account, pool.assetType, NFTType.NONE, pool.asset, tokensAmount, block.timestamp);
    }

    function withdraw(uint pid, uint[] memory tokenIdsOrAmount, NFTType nftType) public {
        if (nftType != NFTType.NONE) {
            require(tokenIdsOrAmount.length <= MAX_WITHDRAW_PER_TX, "NFT amount exceeds max withdrawal limit. Withdraw fewer items per transaction");
        }

        Pool memory _pool = PoolManager.getPoolWithoutRewards(pid);
        AccountManager.settleAccountPoolBalance(_msgSender(), pid);
        if (nftType == NFTType.NONE) {
            withdrawFungible(_msgSender(), _pool, pid, tokenIdsOrAmount, true);
        } else {
            withdrawNFT(_msgSender(), _pool, pid, tokenIdsOrAmount, nftType, true);
        }
        AccountManager.settleAccountPoolBalanceAfterUpdate(_msgSender(), pid);
    }

    function emergencyRelease(address account, uint pid, uint limit) external onlyRole(ADMIN) {
        Pool memory _pool = PoolManager.getPoolWithoutRewards(pid);
        bool isFungiblePool = _pool.assetType == AssetType.Fungible;
        uint _assetsCount = AccountManager.accountAssetsCount(account, pid, !isFungiblePool);
        require(_assetsCount > 0, "Account has no assets in this pool");
        uint _limit = _assetsCount > (limit > 0 ? limit : 10) ? limit : _assetsCount;

        Asset[] memory _poolAssets = isFungiblePool ?
            AccountManager.accountPoolFungibleAssets(account, pid, _pool, false) :
            AccountManager.accountPoolAssets(account, pid, _pool, false);

        uint[] memory _tokenIdsOrAmount = new uint[](isFungiblePool ? 1 : _limit);

        AccountManager.settleAccountPoolBalance(_msgSender(), pid);
        if (isFungiblePool) {
            _tokenIdsOrAmount[0] = _poolAssets[0].tokenIdOrAmount;
            withdrawFungible(account, _pool, pid, _tokenIdsOrAmount, false);
        } else {
            for (uint _idx = 0; _idx < _limit; _idx++) {
                _tokenIdsOrAmount[_idx] = _poolAssets[_idx].tokenIdOrAmount;
            }
            withdrawNFT(account, _pool, pid, _tokenIdsOrAmount, NFTType.Asset, false);
        }
        AccountManager.settleAccountPoolBalanceAfterUpdate(_msgSender(), pid);

        emit EmergencyReleased(pid, _msgSender(), account, _pool.assetType, _pool.asset, _tokenIdsOrAmount, block.timestamp);
    }

    // --- REWARDS --- //
    function claimPoolRewards(uint pid) external nonReentrant {
        require(EMISSION_START != 0, "Reward emission not started");

        VestedRewards memory _rewards = AccountManager.claimPoolRewards(_msgSender(), pid);
        emit Payout(_msgSender(), pid, _rewards, block.timestamp);
    }

    function claimAllPoolsRewards() external nonReentrant {
        require(EMISSION_START != 0, "Reward emission not started");

        VestedRewards memory _rewards = AccountManager.claimAllPoolsRewards(_msgSender());
        emit Payout(_msgSender(), 0, _rewards, block.timestamp);
    }

    // --- basic info --- //
    function cData() public view returns (ContractData memory) {
        return ContractData(
            PoolManager.getPoolsByStatus(PoolStatus.ACTIVE),
            PoolManager.getPoolsByStatus(PoolStatus.INACTIVE),
            PoolManager.DEFAULT_LOCKUP_DURATION(),
            PoolManager.DEFAULT_LOCKUP_PENALTY(),
            MAX_DEPOSIT_PER_TX,
            MAX_WITHDRAW_PER_TX,
            EMISSION_START,
            PENALTY_BALANCE,
            BURNED_PENALTY_BALANCE,
            POW,
            MASTER_APE,
            VAULT
        );
    }

    function wData(address account) public view returns (AccountData memory) {
        return AccountManager.accountData(account);
    }

    function aData() public view returns (AccountData memory) {
        return wData(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

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
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./ApeHeroTypes.sol";

interface IVoucher is IERC20 {
    function mint(uint amount, address recipient) external;
    function burn(uint amount, address account) external;
}

interface IPOW is IERC20 {
    function EMISSION_START() external view returns (uint);
    function mint(uint amount, address recipient) external;
    function burn(uint amount) external;
}

interface IMasterApe is IERC20 {
    function EMISSION_START() external view returns (uint);
    function getLastEmittedWeek(AccountType accountType) external view returns (uint);
    function stakingPayout(address account, uint amount) external returns (VestedRewards memory);
}

interface IVault {
    function deposit(address forAccount, uint amount) external;
}

interface IStakingPool {
    function getPool(uint pid) external view returns (PoolData memory);
    function getPoolCollections(uint[] memory pids) external view returns (PoolData[] memory);
    function getPoolCollectionsWithoutRewards(uint[] memory pids) external view returns (Pool[] memory);
}

contract ApeHeroPOWEmission is Ownable, AccessControlEnumerable {
    address public POW;
    uint public GENESIS_BLOCK;
    uint public EMISSION_START;
    uint WEEK_IN_SECONDS = 604800;

    // --- supply --- //
    uint public MAX_SUPPLY = 600000000e18;
    uint public STAKING_MAX_SUPPLY = 150000000e18;
    uint public FUTURE_ROADMAP_MAX_SUPPLY = 150000000e18;
    uint public INITIAL_LIQUIDITY_MAX_SUPPLY = 60000000e18;
    uint public MARKETING_MAX_SUPPLY = 150000000e18;
    uint public TEAM_MAX_SUPPLY = 90000000e18;

    // emission schedule for both staking & future roadmap
    uint[] public WEEKLY_EMISSION_SCHEDULE = [
        0, 12902400e18, 9676800e18, 6451200e18, 5644800e18, 4838400e18, 4032000e18, 3225600e18, 2822400e18, 2419200e18, 2016000e18, 1612800e18, 1512000e18,
        1411200e18, 1310400e18, 1209600e18, 1108800e18, 1008000e18, 907200e18, 806400e18, 705600e18, 604800e18, 504000e18, 403200e18
    ];
    uint[] public MAX_WEEKLY_EMISSION_SCHEDULE = [
        0, 12902400e18, 22579200e18, 29030400e18, 34675200e18, 39513600e18, 43545600e18, 46771200e18, 49593600e18, 52012800e18, 54028800e18, 55641600e18,
        57153600e18, 58564800e18, 59875200e18, 61084800e18, 62193600e18, 63201600e18, 64108800e18, 64915200e18, 65620800e18, 66225600e18, 66729600e18,
        67132800e18
    ];

    uint public FIRST_CLIFF_WEEKLY_EMISSION_RATE = 302400e18;
    uint public FIRST_CLIFF_EMISSION_TOTAL_SUPPLY = 40219200e18;
    uint public SECOND_CLIFF_WEEKLY_EMISSION_RATE = 201600e18;
    uint public SECOND_CLIFF_EMISSION_TOTAL_SUPPLY = 41932800e18;
    uint public THIRD_CLIFF_WEEKLY_EMISSION_RATE = 100800e18;

    // --- cliff/halving schedules --- //
    uint public FIRST_CLIFF_WEEK = 24;
    uint public SECOND_CLIFF_WEEK = 157;
    uint public THIRD_CLIFF_WEEK = 365;

    // vesting
    uint public VESTED_FULL_WEEK = 49;
    uint[] public VESTED_SCHEDULE = [
        0, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51, 53,
        55, 57, 59, 61, 63, 65, 67, 69, 71, 73, 75, 77, 79, 81, 83, 85, 87, 89, 91, 93, 95, 97, 99
    ];

    // unlocking
    uint public UNLOCK_START_WEEK = 30;
    uint public UNLOCK_FULL_WEEK = 49;
    uint[] public UNLOCK_SCHEDULE = [400, 500, 600, 700, 800, 900, 1000, 1200, 1400, 1600, 2000, 2600, 3400, 4200, 5200, 6200, 7200, 8400, 9600];

    // vars
    uint public WEEKLY_INTERVAL = 583200; // (6 hours flexibility)
    uint public MONTHLY_INTERVAL = 2397600; // (6 hours flexibility)

    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32 public constant MINTER = keccak256("MINTER");
    bytes32 public constant OPERATOR = keccak256("OPERATOR");
    bytes32 public constant CONTROLLER = keccak256("CONTROLLER");

    // --- modifiers --- //
    modifier onlyController() {
        require(hasRole(CONTROLLER, _msgSender()), "CONTROLLER role required");
        _;
    }

    modifier onlyAdminAndOperator() {
        require(
            hasRole(ADMIN, _msgSender()) || hasRole(OPERATOR, _msgSender()),
            "ADMIN or OPERATOR role required"
        );
        _;
    }

    // --- utils --- //
    function currentWeek() public view returns (uint) {
        if (EMISSION_START == 0) {
            return 0;
        }
        uint _secondsSinceGenesis = block.timestamp - EMISSION_START;
        return (_secondsSinceGenesis / WEEK_IN_SECONDS) + ((_secondsSinceGenesis % WEEK_IN_SECONDS) > 0 ? 1 : 0);
    }

    function currentMoment(uint ts) public view returns (CurrentMoment memory) {
        if (EMISSION_START == 0) {
            return CurrentMoment(0, 0, 0, 0, 0);
        }
        uint _timestamp = ts > 0 ? ts : block.timestamp;
        uint _secondsSinceGenesis = _timestamp - EMISSION_START;
        uint _secondsSinceWeekStarted = _secondsSinceGenesis % WEEK_IN_SECONDS;
        return CurrentMoment({
            timestamp: _timestamp,
            week: (_secondsSinceGenesis / WEEK_IN_SECONDS) + (_secondsSinceWeekStarted > 0 ? 1 : 0),
            secondsSinceGenesis: _secondsSinceGenesis,
            secondsSinceWeekStarted: _secondsSinceWeekStarted,
            secondsUntilWeekEnds: WEEK_IN_SECONDS - _secondsSinceWeekStarted
        });
    }

    function currentVestedForWeek(uint week) public view returns (uint) {
        return week >= VESTED_FULL_WEEK ? 1e4 : VESTED_SCHEDULE[week] * 100;
    }

    function currentVested() public view returns (uint) {
        return currentVestedForWeek(currentWeek());
    }

    function checkAfter(uint checkpoint, uint afterInterval) public view returns (bool) {
        return (block.timestamp - checkpoint) >= afterInterval;
    }

    function monthlyEmissionWeekFor(uint lastEmittedWeek) public view returns (uint) {
        uint _eWeek = currentWeek();
        if ((lastEmittedWeek + 3) == _eWeek) {
            _eWeek += 1;
        }
        return _eWeek;
    }

    function weeklyEmissionWeekFor(uint lastEmittedWeek) public view returns (uint) {
        uint _eWeek = currentWeek();
        if (lastEmittedWeek == _eWeek) {
            _eWeek = lastEmittedWeek + 1;
        }
        return _eWeek;
    }

    function getStandardYieldEmissionForWeek(uint weekNum) public view returns (uint) {
        if (weekNum >= THIRD_CLIFF_WEEK) {
            return THIRD_CLIFF_WEEKLY_EMISSION_RATE;
        } else if (weekNum >= SECOND_CLIFF_WEEK) {
            return SECOND_CLIFF_WEEKLY_EMISSION_RATE;
        } else if (weekNum >= FIRST_CLIFF_WEEK) {
            return FIRST_CLIFF_WEEKLY_EMISSION_RATE;
        }
        return WEEKLY_EMISSION_SCHEDULE[weekNum];
    }

    function getMaxStandardYieldEmissionForWeek(uint weekNum) public view returns (uint) {
        uint _maxYieldForWeek;
        if (weekNum < FIRST_CLIFF_WEEK) {
            _maxYieldForWeek = MAX_WEEKLY_EMISSION_SCHEDULE[weekNum];
        } else {
            _maxYieldForWeek = MAX_WEEKLY_EMISSION_SCHEDULE[23];
            if (weekNum >= THIRD_CLIFF_WEEK) {
                _maxYieldForWeek +=
                    FIRST_CLIFF_EMISSION_TOTAL_SUPPLY +
                    SECOND_CLIFF_EMISSION_TOTAL_SUPPLY +
                    ((1 + weekNum - THIRD_CLIFF_WEEK) * THIRD_CLIFF_WEEKLY_EMISSION_RATE);
            } else if (weekNum >= SECOND_CLIFF_WEEK) {
                _maxYieldForWeek +=
                FIRST_CLIFF_EMISSION_TOTAL_SUPPLY +
                ((1 + weekNum - SECOND_CLIFF_WEEK) * SECOND_CLIFF_WEEKLY_EMISSION_RATE);
            } else if (weekNum >= FIRST_CLIFF_WEEK) {
                _maxYieldForWeek += ((1 + weekNum - FIRST_CLIFF_WEEK) * FIRST_CLIFF_WEEKLY_EMISSION_RATE);
            }
        }
        return _maxYieldForWeek;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./ApeHeroPOWEmission.sol";

contract ApeHeroStakingPool is ApeHeroPOWEmission {
    using EnumerableSet for EnumerableSet.UintSet;

    struct AccruedRewards {
        uint assets;
        uint boosters;
        uint lastUpdated;
    }

    struct ContractData {
        PoolData[] activePools;
        PoolData[] inactivePools;
        uint emissionStart;
        uint multiplierTotal;
        uint defaultLockupDuration;
        uint defaultLockupPenalty;
    }

    // pools
    uint public DEFAULT_LOCKUP_DURATION = 604800;
    uint public DEFAULT_LOCKUP_PENALTY = 100e18;
    uint public MULTIPLIER_TOTAL;
    uint public CURRENT_POOL_ID;
    EnumerableSet.UintSet private ACTIVE_POOLS;
    EnumerableSet.UintSet private INACTIVE_POOLS;
    EnumerableSet.UintSet private REMOVED_POOLS;
    mapping(uint => Pool) private POOLS;

    // rewards
    // {[pid]: uint<earned rewards, week, time>}
    mapping(uint => uint) private POOL_LIFETIME_ASSETS_REWARDS;
    mapping(uint => uint) private POOL_LIFETIME_BOOSTERS_REWARDS;
    mapping(uint => uint) private POOL_LIFETIME_REWARDS_LAST_UPDATE;

    // events
    event PoolAdded(uint pid, uint timestamp);
    event PoolBoosterUpdated(uint pid, uint timestamp);
    event PoolStatusChanged(uint pid, PoolStatus status, uint timestamp);
    event PoolLockupUpdated(uint pid, uint duration, uint penalty, uint timestamp);
    event PoolBoosterSharesUpdated(uint pid, uint boosterShares, uint timestamp);
    event PoolMultiplierUpdated(uint pid, uint multiplier, uint timestamp);
    event PoolManagerActivated(address controller, uint timestamp);

    constructor() Ownable() {
        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        _grantRole(ADMIN, owner());
    }

    // --- utils --- //
    function updatePoolsMultiplierTotal() internal {
        uint _multiplierTotal;
        uint _activePoolsCount = ACTIVE_POOLS.length();
        for (uint idx = 0; idx < _activePoolsCount; idx++) {
            _multiplierTotal += POOLS[ACTIVE_POOLS.at(idx)].multiplier;
        }
        MULTIPLIER_TOTAL = _multiplierTotal;
    }

    function accruedRewardsForWeek(uint week, uint durationInSeconds, Pool memory pool) internal view returns (AccruedRewards memory) {
        if (EMISSION_START == 0 || durationInSeconds == 0) {
            return AccruedRewards(0, 0, 0);
        }

        uint _accruedRewards = durationInSeconds * (((getStandardYieldEmissionForWeek(week) * pool.multiplier) / MULTIPLIER_TOTAL) / WEEK_IN_SECONDS);
        uint _accruedBoostersRewards = pool.totalBoosters > 0 ? ((pool.boosterShares * _accruedRewards) / 1e4) / pool.totalBoosters : 0;
        uint _accruedAssetsRewards = pool.totalAssets > 0 ? (((1e4 - pool.boosterShares) * _accruedRewards) / 1e4) / pool.totalAssets : 0;
        return AccruedRewards({assets : _accruedAssetsRewards, boosters : _accruedBoostersRewards, lastUpdated : 0});
    }

    function getAccruedLifetimeRewards(uint pid, CurrentMoment memory cMoment) internal view returns (AccruedRewards memory) {
        Pool memory _pool = POOLS[pid];

        AccruedRewards memory _accruedRewards;
        uint _accruedAssetsRewards;
        uint _accruedBoostersRewards;
        CurrentMoment memory _lastUpdate = currentMoment(
            POOL_LIFETIME_REWARDS_LAST_UPDATE[pid] == 0 ? EMISSION_START : POOL_LIFETIME_REWARDS_LAST_UPDATE[pid]
        );

        // same week
        if (_lastUpdate.week == cMoment.week) {
            _accruedRewards = accruedRewardsForWeek(cMoment.week, cMoment.timestamp - _lastUpdate.timestamp, _pool);
            _accruedAssetsRewards = _accruedRewards.assets;
            _accruedBoostersRewards = _accruedRewards.boosters;
        } else {
            // week of last update
            _accruedRewards = accruedRewardsForWeek(_lastUpdate.week, _lastUpdate.secondsUntilWeekEnds, _pool);
            _accruedAssetsRewards += _accruedRewards.assets;
            _accruedBoostersRewards += _accruedRewards.boosters;

            // weeks in between
            for (uint _wIdx = (_lastUpdate.week + 1); _wIdx < cMoment.week; _wIdx++) {
                _accruedRewards = accruedRewardsForWeek(_wIdx, WEEK_IN_SECONDS, _pool);
                _accruedAssetsRewards += _accruedRewards.assets;
                _accruedBoostersRewards += _accruedRewards.boosters;
            }

            // this week
            _accruedRewards = accruedRewardsForWeek(cMoment.week, cMoment.secondsSinceWeekStarted, _pool);
            _accruedAssetsRewards += _accruedRewards.assets;
            _accruedBoostersRewards += _accruedRewards.boosters;
        }

        return AccruedRewards({
            assets : POOL_LIFETIME_ASSETS_REWARDS[pid] + _accruedAssetsRewards,
            boosters : POOL_LIFETIME_BOOSTERS_REWARDS[pid] + _accruedBoostersRewards,
            lastUpdated : cMoment.timestamp
        });
    }

    function updatePoolLifetimeRewards(uint pid, CurrentMoment memory cMoment) internal {
        AccruedRewards memory _accruedRewards = getAccruedLifetimeRewards(pid, cMoment);

        POOL_LIFETIME_ASSETS_REWARDS[pid] = _accruedRewards.assets;
        POOL_LIFETIME_BOOSTERS_REWARDS[pid] = _accruedRewards.boosters;
        POOL_LIFETIME_REWARDS_LAST_UPDATE[pid] = cMoment.timestamp;
    }

    function updateAllPoolsLifetimeRewards() internal {
        Pool[] memory _allActivePools = getPoolsByStatusWithoutShares(PoolStatus.ACTIVE);

        for (uint _idx = 0; _idx < _allActivePools.length; _idx++) {
            updatePoolLifetimeRewards(_allActivePools[_idx].pid, currentMoment(block.timestamp));
        }
    }

    // --- ADMIN --- //
    function setDefaultLockupDuration(uint duration) external onlyRole(ADMIN) {
        DEFAULT_LOCKUP_DURATION = duration;
    }

    function setDefaultLockupPenalty(uint penalty) external onlyRole(ADMIN) {
        DEFAULT_LOCKUP_PENALTY = penalty;
    }

    function updatePoolBoosterShares(uint pid, uint boosterShares) external onlyRole(ADMIN) {
        require(boosterShares != POOLS[pid].boosterShares, "Booster shares unchanged");

        POOLS[pid].boosterShares = boosterShares;
        updatePoolLifetimeRewards(pid, currentMoment(block.timestamp));

        emit PoolBoosterSharesUpdated(pid, boosterShares, block.timestamp);
    }

    function updatePoolMultiplier(uint pid, uint multiplier) external onlyRole(ADMIN) {
        require(multiplier != POOLS[pid].multiplier, "Multiplier unchanged");

        POOLS[pid].multiplier = multiplier;
        updatePoolsMultiplierTotal();
        updatePoolLifetimeRewards(pid, currentMoment(block.timestamp));

        emit PoolMultiplierUpdated(pid, multiplier, block.timestamp);
    }

    function updatePoolLockup(uint pid, uint duration, uint penalty) external onlyRole(ADMIN) {
        POOLS[pid].lockupDuration = duration;
        POOLS[pid].lockupPenalty = penalty;

        emit PoolLockupUpdated(pid, duration, penalty, block.timestamp);
    }

    function setPoolStatus(uint pid, PoolStatus status) external onlyRole(ADMIN) {
        require(status != POOLS[pid].status, "Pool already has requested status");

        if (status == PoolStatus.REMOVED) {
            require(POOLS[pid].status != PoolStatus.ACTIVE, "Cannot remove active pool");
            POOLS[pid].status = status;
            INACTIVE_POOLS.remove(pid);
            REMOVED_POOLS.add(pid);
        } else {
            POOLS[pid].status = status;
            if (status == PoolStatus.ACTIVE) {
                INACTIVE_POOLS.remove(pid);
                ACTIVE_POOLS.add(pid);
            } else {
                ACTIVE_POOLS.remove(pid);
                INACTIVE_POOLS.add(pid);
            }
            updatePoolsMultiplierTotal();
            updateAllPoolsLifetimeRewards();
        }

        emit PoolStatusChanged(pid, status, block.timestamp);
    }

    function addPool(
        AssetType assetType, uint multiplier, address asset, address assetVoucher, Rarity assetRarity, uint maxAssets
    ) public onlyRole(ADMIN) returns (uint)
    {
        uint newPoolId = CURRENT_POOL_ID + 1;
        POOLS[newPoolId] = Pool(
            newPoolId, assetType, multiplier,
            asset, assetVoucher, 0, assetRarity, maxAssets,
            address(0), address(0), 0, 0, 0,
            DEFAULT_LOCKUP_DURATION, DEFAULT_LOCKUP_PENALTY,
            PoolStatus.INACTIVE
        );

        INACTIVE_POOLS.add(newPoolId);
        CURRENT_POOL_ID = newPoolId;

        emit PoolAdded(newPoolId, block.timestamp);
        return newPoolId;
    }

    function updatePoolBooster(
        uint pid, address booster, address boosterVoucher, uint boosterShares, uint maxBoosters
    ) public onlyRole(ADMIN) {
        POOLS[pid].booster = booster;
        POOLS[pid].boosterVoucher = boosterVoucher;
        POOLS[pid].boosterShares = boosterShares;
        POOLS[pid].maxBoosters = maxBoosters;

        emit PoolBoosterUpdated(pid, block.timestamp);
    }

    function addPoolWithBooster(
        AssetType assetType, uint multiplier, address asset, address assetVoucher, Rarity assetRarity, uint maxAssets,
        address booster, address boosterVoucher, uint boosterShares, uint maxBoosters
    ) external onlyRole(ADMIN) {
        uint _pid = addPool(assetType, multiplier, asset, assetVoucher, assetRarity, maxAssets);
        updatePoolBooster(_pid, booster, boosterVoucher, boosterShares, maxBoosters);
    }

    function syncPoolsRewards() external onlyAdminAndOperator {
        updateAllPoolsLifetimeRewards();
    }

    // --- CONTROLLER --- //
    function activatePoolManager(uint startTime) external onlyController {
        require(EMISSION_START == 0, "Pool Manager already activated");
        EMISSION_START = startTime;

        emit PoolManagerActivated(_msgSender(), block.timestamp);
    }

    function addPoolAssets(uint pid, uint amount) external onlyController {
        if (amount > 0) {
            POOLS[pid].totalAssets += amount;
            updatePoolLifetimeRewards(pid, currentMoment(block.timestamp));
        }
    }

    function subtractPoolAssets(uint pid, uint amount) external onlyController {
        if (amount > 0) {
            if (amount > POOLS[pid].totalAssets) {
                POOLS[pid].totalAssets = 0;
            } else {
                POOLS[pid].totalAssets -= amount;
            }
            updatePoolLifetimeRewards(pid, currentMoment(block.timestamp));
        }
    }

    function addPoolBoosters(uint pid, uint amount) external onlyController {
        if (amount > 0) {
            POOLS[pid].totalBoosters += amount;
            updatePoolLifetimeRewards(pid, currentMoment(block.timestamp));
        }
    }

    function subtractPoolBoosters(uint pid, uint amount) external onlyController {
        if (amount > 0) {
            if (amount > POOLS[pid].totalBoosters) {
                POOLS[pid].totalBoosters = 0;
            } else {
                POOLS[pid].totalBoosters -= amount;
            }
            updatePoolLifetimeRewards(pid, currentMoment(block.timestamp));
        }
    }

    // --- external/public --- //
    function getPoolRewards(uint pid) public view returns (PoolRewards memory) {
        CurrentMoment memory _currentMoment = currentMoment(block.timestamp);
        if (EMISSION_START == 0) {
            return PoolRewards({
            cMoment : _currentMoment,
            assetsLifetime : 0, assetsTotalPerSecond : 0, assetsPerItemPerSecond : 0,
            boostersLifetime : 0, boostersTotalPerSecond : 0, boostersPerItemPerSecond : 0
            });
        }
        Pool memory _pool = POOLS[pid];
        AccruedRewards memory _accruedLifetimeRewards = getAccruedLifetimeRewards(pid, _currentMoment);

        uint _poolTotalRewardsPerSecond =
            ((getStandardYieldEmissionForWeek(_currentMoment.week) * _pool.multiplier) / MULTIPLIER_TOTAL) / WEEK_IN_SECONDS;
        uint _poolBoostersRewardsPerSecond = _pool.totalBoosters > 0 ? ((_pool.boosterShares * _poolTotalRewardsPerSecond) / 1e4) : 0;
        uint _poolAssetsRewardsPerSecond = _poolTotalRewardsPerSecond - _poolBoostersRewardsPerSecond;

        return PoolRewards({
            cMoment : _currentMoment,
            assetsLifetime : _accruedLifetimeRewards.assets,
            assetsTotalPerSecond : _poolAssetsRewardsPerSecond,
            assetsPerItemPerSecond : _pool.totalAssets > 0 ? (_poolAssetsRewardsPerSecond / _pool.totalAssets) : 0,
            boostersLifetime : _accruedLifetimeRewards.boosters,
            boostersTotalPerSecond : _poolBoostersRewardsPerSecond,
            boostersPerItemPerSecond : _pool.totalBoosters > 0 ? (_poolBoostersRewardsPerSecond / _pool.totalBoosters) : 0
        });
    }

    function getPool(uint pid) public view returns (PoolData memory) {
        return PoolData({
            pool : POOLS[pid],
            rewards : getPoolRewards(pid),
            lastUpdate : POOL_LIFETIME_REWARDS_LAST_UPDATE[pid]
        });
    }

    function getPoolWithoutRewards(uint pid) external view returns (Pool memory) {
        return POOLS[pid];
    }

    function getPoolCollections(uint[] memory pids) external view returns (PoolData[] memory) {
        PoolData[] memory _allPools = new PoolData[](pids.length);
        for (uint _idx = 0; _idx < pids.length; _idx++) {
            _allPools[_idx] = getPool(pids[_idx]);
        }
        return _allPools;
    }

    function getPoolCollectionsWithoutRewards(uint[] memory pids) external view returns (Pool[] memory) {
        Pool[] memory _allPools = new Pool[](pids.length);
        for (uint _idx = 0; _idx < pids.length; _idx++) {
            _allPools[_idx] = POOLS[pids[_idx]];
        }
        return _allPools;
    }

    function getPoolsByStatus(PoolStatus status) public view returns (PoolData[] memory) {
        uint _poolsCount;
        if (status == PoolStatus.ACTIVE) {
            _poolsCount = ACTIVE_POOLS.length();
        } else if (status == PoolStatus.INACTIVE) {
            _poolsCount = INACTIVE_POOLS.length();
        } else {
            _poolsCount = REMOVED_POOLS.length();
        }

        PoolData[] memory _pools;
        if (_poolsCount == 0) {
            return _pools;
        }
        _pools = new PoolData[](_poolsCount);
        for (uint idx = 0; idx < _poolsCount; idx++) {
            if (status == PoolStatus.ACTIVE) {
                _pools[idx] = getPool(ACTIVE_POOLS.at(idx));
            } else if (status == PoolStatus.INACTIVE) {
                _pools[idx] = getPool(INACTIVE_POOLS.at(idx));
            } else {
                _pools[idx] = getPool(REMOVED_POOLS.at(idx));
            }
        }
        return _pools;
    }

    function getPoolsByStatusWithoutShares(PoolStatus status) public view returns (Pool[] memory) {
        uint _poolsCount;
        if (status == PoolStatus.ACTIVE) {
            _poolsCount = ACTIVE_POOLS.length();
        } else if (status == PoolStatus.INACTIVE) {
            _poolsCount = INACTIVE_POOLS.length();
        } else {
            _poolsCount = REMOVED_POOLS.length();
        }

        Pool[] memory _pools;
        if (_poolsCount == 0) {
            return _pools;
        }
        _pools = new Pool[](_poolsCount);
        for (uint idx = 0; idx < _poolsCount; idx++) {
            if (status == PoolStatus.ACTIVE) {
                _pools[idx] = POOLS[ACTIVE_POOLS.at(idx)];
            } else if (status == PoolStatus.INACTIVE) {
                _pools[idx] = POOLS[INACTIVE_POOLS.at(idx)];
            } else {
                _pools[idx] = POOLS[REMOVED_POOLS.at(idx)];
            }
        }
        return _pools;
    }

    function cData() external view returns (ContractData memory) {
        return ContractData(
            getPoolsByStatus(PoolStatus.ACTIVE),
            getPoolsByStatus(PoolStatus.INACTIVE),
            EMISSION_START,
            MULTIPLIER_TOTAL,
            DEFAULT_LOCKUP_DURATION,
            DEFAULT_LOCKUP_PENALTY
        );
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ApeHeroTypes.sol";

contract ApeHeroRarity is Ownable, AccessControlEnumerable {
    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32 public constant OPERATOR = keccak256("OPERATOR");

    mapping(address => mapping(uint => Rarity)) private ASSETS_RARITIES;
    mapping(address => mapping(Rarity => uint)) private ASSET_RARITY_TOTAL;

    constructor() Ownable() {
        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        _grantRole(ADMIN, owner());
        _grantRole(OPERATOR, owner());
    }

    modifier onlyAdminAndOperator() {
        require(
            hasRole(ADMIN, _msgSender()) || hasRole(OPERATOR, _msgSender()),
            "ADMIN or OPERATOR role required"
        );
        _;
    }

    // --- ADMIN/OPERATOR --- //
    function addRarities(address asset, Rarity rarity, uint[] calldata tokenIds) external onlyAdminAndOperator {
        require(rarity != Rarity.NONE, "Invalid asset rarity");

        Rarity _currentRarity;
        for (uint idx = 0; idx < tokenIds.length; idx++) {
            _currentRarity = ASSETS_RARITIES[asset][tokenIds[idx]];
            if (_currentRarity == rarity) {
                continue;
            } else {
                ASSETS_RARITIES[asset][tokenIds[idx]] = rarity;
                ASSET_RARITY_TOTAL[asset][rarity] += 1;
                if (ASSET_RARITY_TOTAL[asset][_currentRarity] > 0) {
                    ASSET_RARITY_TOTAL[asset][_currentRarity] -= 1;
                }
            }
        }
    }

    function removeRarities(address asset, uint[] calldata tokenIds) external onlyAdminAndOperator {
        Rarity _currentRarity;
        for (uint idx = 0; idx < tokenIds.length; idx++) {
            _currentRarity = ASSETS_RARITIES[asset][tokenIds[idx]];
            if (_currentRarity == Rarity.NONE) {
                continue;
            } else {
                ASSETS_RARITIES[asset][tokenIds[idx]] = Rarity.NONE;
                if (ASSET_RARITY_TOTAL[asset][_currentRarity] > 0) {
                    ASSET_RARITY_TOTAL[asset][_currentRarity] -= 1;
                }
            }
        }
    }

    // --- public --- //
    function validateRarity(address asset, Rarity assetRarity, uint[] calldata tokenIds) external view returns (bool) {
        bool _validRarity = true;
        for (uint idx = 0; idx < tokenIds.length; idx++) {
            if (ASSETS_RARITIES[asset][tokenIds[idx]] != assetRarity) {
                _validRarity = false;
                break;
            }
        }
        return _validRarity;
    }

    function getRarityTotal(address asset, Rarity rarity) external view returns (uint) {
        return ASSET_RARITY_TOTAL[asset][rarity];
    }

    function getRarity(address asset, uint tokenId) external view returns (Rarity) {
        return ASSETS_RARITIES[asset][tokenId];
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./ApeHeroPOWEmission.sol";

contract ApeHeroStakingAccount is ApeHeroPOWEmission {
    using EnumerableSet for EnumerableSet.UintSet;

    // --- account rewards --- //
    // {[account]: {[pid]: uint<rewards>}
    mapping(address => mapping(uint => uint)) private ACCOUNT_ACCRUED_POOL_ASSETS_REWARDS;
    mapping(address => mapping(uint => uint)) private ACCOUNT_PAID_POOL_ASSETS_REWARDS;
    mapping(address => mapping(uint => uint)) private ACCOUNT_CLAIMED_POOL_ASSETS_REWARDS;

    mapping(address => mapping(uint => uint)) private ACCOUNT_ACCRUED_POOL_BOOSTERS_REWARDS;
    mapping(address => mapping(uint => uint)) private ACCOUNT_PAID_POOL_BOOSTERS_REWARDS;
    mapping(address => mapping(uint => uint)) private ACCOUNT_CLAIMED_POOL_BOOSTERS_REWARDS;

    // --- assets --- //
    // {[assetCA]: {[tokenId]: Asset}}
    mapping(address => mapping(uint => Asset)) private ASSETS;

    // {[account]: uint
    mapping(address => uint) private ACCOUNT_ASSETS_TOTAL;
    mapping(address => uint) private ACCOUNT_BOOSTERS_TOTAL;

    // {[account]: [pid,]}
    mapping(address => EnumerableSet.UintSet) private ACCOUNT_POOLS;
    // {[account]: {[pid]: uint<total>}}
    mapping(address => mapping(uint => uint)) private ACCOUNT_POOL_FUNGIBLE_ASSETS;
    // {[account]: {[pid]: uint<block.timestamp>}}
    mapping(address => mapping(uint => uint)) private ACCOUNT_POOL_FUNGIBLE_ASSETS_DEPOSITED;
    // {[account]: {[pid]: [tokenId, ]}}
    mapping(address => mapping(uint => EnumerableSet.UintSet)) private ACCOUNT_POOL_ASSETS;
    // {[account]: {[pid]: [tokenId, ]}}
    mapping(address => mapping(uint => EnumerableSet.UintSet)) private ACCOUNT_POOL_BOOSTERS;

    address MasterApe;
    address StakingPool;
    constructor(address masterApe, address poolManager) Ownable() {
        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        _grantRole(ADMIN, owner());

        MasterApe = masterApe;
        StakingPool = poolManager;
    }

    function updateAccountPools(address account, uint pid) internal {
        if (
            (ACCOUNT_POOL_FUNGIBLE_ASSETS[account][pid] == 0) &&
            (ACCOUNT_POOL_ASSETS[account][pid].length() == 0) &&
            (ACCOUNT_POOL_BOOSTERS[account][pid].length() == 0)
        ) {
            ACCOUNT_POOLS[account].remove(pid);
        } else if (
            (ACCOUNT_POOL_FUNGIBLE_ASSETS[account][pid] > 0) ||
            (ACCOUNT_POOL_ASSETS[account][pid].length() > 0) ||
            (ACCOUNT_POOL_BOOSTERS[account][pid].length() > 0)
        ) {
            ACCOUNT_POOLS[account].add(pid);
        }
    }

    // --- CONTROLLER --- //
    function createAccountAssets(
        address account, address poolAsset, uint tokenId, AssetType assetType, Rarity rarity, uint pid
    ) external onlyController {
        ASSETS[poolAsset][tokenId] = Asset(
            account, poolAsset, tokenId, assetType, rarity, pid, block.timestamp
        );
    }

    function addAccountAssets(address account, uint pid, uint tokenIdOrAmount, bool isNFT, bool isAssetNFT) external onlyController {
        if (isNFT) {
            if (isAssetNFT) {
                ACCOUNT_ASSETS_TOTAL[account] += 1;
                ACCOUNT_POOL_ASSETS[account][pid].add(tokenIdOrAmount);
            } else {
                ACCOUNT_BOOSTERS_TOTAL[account] += 1;
                ACCOUNT_POOL_BOOSTERS[account][pid].add(tokenIdOrAmount);
            }
        } else {
            if (ACCOUNT_POOL_FUNGIBLE_ASSETS[account][pid] == 0) {
                ACCOUNT_ASSETS_TOTAL[account] += 1;
            }
            ACCOUNT_POOL_FUNGIBLE_ASSETS[account][pid] += tokenIdOrAmount;
            ACCOUNT_POOL_FUNGIBLE_ASSETS_DEPOSITED[account][pid] = block.timestamp;
        }
        updateAccountPools(account, pid);
    }

    function removeAccountAssets(address account, uint pid, address poolAsset, uint tokenIdOrAmount, bool isNFT, bool isAssetNFT) external onlyController {
        if (isNFT) {
            if (isAssetNFT) {
                ACCOUNT_ASSETS_TOTAL[account] -= 1;
                ACCOUNT_POOL_ASSETS[account][pid].remove(tokenIdOrAmount);
            } else {
                ACCOUNT_BOOSTERS_TOTAL[account] -= 1;
                ACCOUNT_POOL_BOOSTERS[account][pid].remove(tokenIdOrAmount);
            }
            delete ASSETS[poolAsset][tokenIdOrAmount];
        } else {
            ACCOUNT_POOL_FUNGIBLE_ASSETS[account][pid] -= tokenIdOrAmount;
            if (ACCOUNT_POOL_FUNGIBLE_ASSETS[account][pid] == 0) {
                ACCOUNT_ASSETS_TOTAL[account] -= 1;
            }
        }
        updateAccountPools(account, pid);
    }

    function settleAccountPoolBalance(address account, uint pid) public onlyController {
        PoolData memory _poolData = IStakingPool(StakingPool).getPool(pid);
        uint _assetsCount = ACCOUNT_POOL_ASSETS[account][pid].length();
        uint _boostersCount = ACCOUNT_POOL_BOOSTERS[account][pid].length();

        if (_assetsCount > 0) {
            uint _lifetimeAssetsRewards = _assetsCount * _poolData.rewards.assetsLifetime;
            uint _pendingAssetsRewards = _lifetimeAssetsRewards -
                ACCOUNT_PAID_POOL_ASSETS_REWARDS[account][pid] + ACCOUNT_ACCRUED_POOL_ASSETS_REWARDS[account][pid];
            ACCOUNT_ACCRUED_POOL_ASSETS_REWARDS[account][pid] += _pendingAssetsRewards;
            ACCOUNT_PAID_POOL_ASSETS_REWARDS[account][pid] = _lifetimeAssetsRewards;
        }

        if (_boostersCount > 0) {
            uint _lifeTimeBoostersRewards = _boostersCount * _poolData.rewards.boostersLifetime;
            uint _pendingBoostersRewards = _lifeTimeBoostersRewards -
                ACCOUNT_PAID_POOL_BOOSTERS_REWARDS[account][pid] + ACCOUNT_ACCRUED_POOL_BOOSTERS_REWARDS[account][pid];
            ACCOUNT_ACCRUED_POOL_BOOSTERS_REWARDS[account][pid] += _pendingBoostersRewards;
            ACCOUNT_PAID_POOL_BOOSTERS_REWARDS[account][pid] = _lifeTimeBoostersRewards;
        }
    }

    function settleAccountPoolBalanceAfterUpdate(address account, uint pid) public onlyController {
        PoolData memory _poolData = IStakingPool(StakingPool).getPool(pid);
        uint _assetsCount = ACCOUNT_POOL_ASSETS[account][pid].length();
        uint _boostersCount = ACCOUNT_POOL_BOOSTERS[account][pid].length();

        if (_assetsCount > 0) {
            ACCOUNT_PAID_POOL_ASSETS_REWARDS[account][pid] = _assetsCount * _poolData.rewards.assetsLifetime;
        }

        if (_boostersCount > 0) {
            ACCOUNT_PAID_POOL_BOOSTERS_REWARDS[account][pid] = _boostersCount * _poolData.rewards.boostersLifetime;
        }
    }

    function claimPoolRewards(address account, uint pid) public onlyController returns (VestedRewards memory) {
        settleAccountPoolBalance(account, pid);

        uint _accruedRewards = ACCOUNT_ACCRUED_POOL_ASSETS_REWARDS[account][pid] + ACCOUNT_ACCRUED_POOL_BOOSTERS_REWARDS[account][pid];
        require(_accruedRewards > 0, "Insufficient accrued pool balance");

        VestedRewards memory _rewards = IMasterApe(MasterApe).stakingPayout(account, _accruedRewards);
        require(_rewards.total > 0, "Payout failed");

        ACCOUNT_CLAIMED_POOL_ASSETS_REWARDS[account][pid] += ACCOUNT_ACCRUED_POOL_ASSETS_REWARDS[account][pid];
        ACCOUNT_CLAIMED_POOL_BOOSTERS_REWARDS[account][pid] += ACCOUNT_ACCRUED_POOL_BOOSTERS_REWARDS[account][pid];
        ACCOUNT_ACCRUED_POOL_ASSETS_REWARDS[account][pid] = 0;
        ACCOUNT_ACCRUED_POOL_BOOSTERS_REWARDS[account][pid] = 0;

        return _rewards;
    }

    function claimAllPoolsRewards(address account) public onlyController returns (VestedRewards memory) {
        uint _totalRewards;
        uint _vestedRewards;
        uint _lockedRewards;
        uint _poolsCount = ACCOUNT_POOLS[account].length();
        VestedRewards memory _paidRewards;
        for (uint idx = 0; idx < _poolsCount; idx++) {
            _paidRewards = claimPoolRewards(account, ACCOUNT_POOLS[account].at(idx));
            _totalRewards += _paidRewards.total;
            _vestedRewards += _paidRewards.vested;
            _lockedRewards += _paidRewards.locked;
        }

        return VestedRewards({total: _totalRewards, vested: _vestedRewards, locked: _lockedRewards});
    }

    // --- public/external --- //
    function pendingPoolRewards(uint pid, address account) public view returns (AccountRewards memory) {
        PoolData memory _poolData = IStakingPool(StakingPool).getPool(pid);

        uint _pendingAssetsRewards;
        if (ACCOUNT_POOL_ASSETS[account][pid].length() > 0) {
            _pendingAssetsRewards = ACCOUNT_ACCRUED_POOL_ASSETS_REWARDS[account][pid] +
            ((ACCOUNT_POOL_ASSETS[account][pid].length() * _poolData.rewards.assetsLifetime) - ACCOUNT_PAID_POOL_ASSETS_REWARDS[account][pid]);
        }

        uint _pendingBoostersRewards;
        if (ACCOUNT_POOL_BOOSTERS[account][pid].length() > 0) {
            _pendingBoostersRewards = ACCOUNT_ACCRUED_POOL_BOOSTERS_REWARDS[account][pid] +
            ((ACCOUNT_POOL_BOOSTERS[account][pid].length() * _poolData.rewards.boostersLifetime) - ACCOUNT_PAID_POOL_BOOSTERS_REWARDS[account][pid]);
        }

        uint _totalPendingRewards = _pendingAssetsRewards + _pendingBoostersRewards;
        uint _vestedPendingRewards = (currentVested() * _totalPendingRewards) / 1e4;
        return AccountRewards({
            rewards: VestedRewards({
                total: _totalPendingRewards,
                vested: _vestedPendingRewards,
                locked: _totalPendingRewards - _vestedPendingRewards
            }),
            pendingRewards: ItemizedRewards({
                total: _totalPendingRewards,
                assets: _pendingAssetsRewards,
                boosters: _pendingBoostersRewards
            }),
            claimedRewards: ItemizedRewards({
                total: ACCOUNT_CLAIMED_POOL_ASSETS_REWARDS[account][pid] + ACCOUNT_CLAIMED_POOL_BOOSTERS_REWARDS[account][pid],
                assets: ACCOUNT_CLAIMED_POOL_ASSETS_REWARDS[account][pid],
                boosters: ACCOUNT_CLAIMED_POOL_BOOSTERS_REWARDS[account][pid]
            })
        });
    }

    function pendingAllPoolsRewards(address account) public view returns (AccountRewards memory) {
        uint _poolsCount = ACCOUNT_POOLS[account].length();
        AccountRewards memory _allPoolsRewards;
        AccountRewards memory _poolPendingRewards;
        for (uint idx = 0; idx < _poolsCount; idx++) {
            _poolPendingRewards = pendingPoolRewards(ACCOUNT_POOLS[account].at(idx), account);

            _allPoolsRewards.rewards.total += _poolPendingRewards.rewards.total;
            _allPoolsRewards.rewards.vested += _poolPendingRewards.rewards.vested;
            _allPoolsRewards.rewards.locked += _poolPendingRewards.rewards.locked;

            _allPoolsRewards.pendingRewards.total += _poolPendingRewards.pendingRewards.total;
            _allPoolsRewards.pendingRewards.assets += _poolPendingRewards.pendingRewards.assets;
            _allPoolsRewards.pendingRewards.boosters += _poolPendingRewards.pendingRewards.boosters;

            _allPoolsRewards.claimedRewards.total += _poolPendingRewards.claimedRewards.total;
            _allPoolsRewards.claimedRewards.assets += _poolPendingRewards.claimedRewards.assets;
            _allPoolsRewards.claimedRewards.boosters += _poolPendingRewards.claimedRewards.boosters;
        }

        return _allPoolsRewards;
    }

    function accountPoolPids(address account) public view returns (uint[] memory) {
        uint _poolsCount = ACCOUNT_POOLS[account].length();
        uint[] memory _allAccountPools = new uint[](_poolsCount);
        for (uint idx = 0; idx < _poolsCount; idx++) {
            _allAccountPools[idx] = ACCOUNT_POOLS[account].at(idx);
        }
        return _allAccountPools;
    }

    function accountPools(address account) public view returns (AccountPool[] memory) {
        uint[] memory _allPoolPids = accountPoolPids(account);
        uint _poolsCount = _allPoolPids.length;
        if (_poolsCount == 0) {
            return new AccountPool[](0);
        }
        PoolData[] memory _allPools = IStakingPool(StakingPool).getPoolCollections(_allPoolPids);
        AccountPool[] memory _allAccountPools = new AccountPool[](_poolsCount);
        for (uint _idx = 0; _idx < _poolsCount; _idx++) {
            _allAccountPools[_idx] = AccountPool({
                pid: _allPoolPids[_idx],
                totalAssets: _allPools[_idx].pool.assetType == AssetType.NFT ?
                    ACCOUNT_POOL_ASSETS[account][_allPoolPids[_idx]].length() : ACCOUNT_POOL_FUNGIBLE_ASSETS[account][_allPoolPids[_idx]],
                totalBoosters: ACCOUNT_POOL_BOOSTERS[account][_allPoolPids[_idx]].length(),
                rewards: pendingPoolRewards(_allPoolPids[_idx], account)
            });
        }

        return _allAccountPools;
    }

    function accountPoolFungibleAssets(address account, uint pid, Pool memory pool, bool includeBoosters) public view returns (Asset[] memory) {
        uint _assetsCount;
        if (ACCOUNT_POOL_FUNGIBLE_ASSETS[account][pid] > 0) {
            _assetsCount = 1;
        }
        uint _boostersCount = ACCOUNT_POOL_BOOSTERS[account][pid].length();
        Asset[] memory _allPoolAssets = new Asset[](includeBoosters ? (_assetsCount + _boostersCount) : _assetsCount);
        uint _aIdx = 0;

        // get assets
        if (_assetsCount > 0) {
            _allPoolAssets[_aIdx] = Asset(
                account, pool.asset, ACCOUNT_POOL_FUNGIBLE_ASSETS[account][pid],
                AssetType.Fungible, Rarity.NONE, pid, ACCOUNT_POOL_FUNGIBLE_ASSETS_DEPOSITED[account][pid]
            );
            _aIdx += 1;
        }

        // get boosters
        if (includeBoosters) {
            for (uint _bIdx = 0; _bIdx < _boostersCount; _bIdx++) {
                _allPoolAssets[_aIdx] = ASSETS[pool.booster][ACCOUNT_POOL_BOOSTERS[account][pid].at(_bIdx)];
                _aIdx += 1;
            }
        }

        return _allPoolAssets;
    }

    function accountPoolAssets(address account, uint pid, Pool memory pool, bool includeBoosters) public view returns (Asset[] memory) {
        uint _assetsCount = ACCOUNT_POOL_ASSETS[account][pid].length();
        uint _boostersCount = ACCOUNT_POOL_BOOSTERS[account][pid].length();
        Asset[] memory _allPoolAssets = new Asset[](includeBoosters ? (_assetsCount + _boostersCount) : _assetsCount);
        uint _aIdx = 0;

        // get assets
        for (uint _idx = 0; _idx < _assetsCount; _idx++) {
            _allPoolAssets[_aIdx] = ASSETS[pool.asset][ACCOUNT_POOL_ASSETS[account][pid].at(_idx)];
            _aIdx += 1;
        }

        // get boosters
        if (includeBoosters) {
            for (uint _bIdx = 0; _bIdx < _boostersCount; _bIdx++) {
                _allPoolAssets[_aIdx] = ASSETS[pool.booster][ACCOUNT_POOL_BOOSTERS[account][pid].at(_bIdx)];
                _aIdx += 1;
            }
        }

        return _allPoolAssets;
    }

    function accountAssets(address account, bool includeBoosters) public view returns (Asset[] memory) {
        uint[] memory _allPoolPids = accountPoolPids(account);
        if (_allPoolPids.length == 0) {
            return new Asset[](0);
        }

        Asset[] memory _allAccountAssets = new Asset[](
            ACCOUNT_ASSETS_TOTAL[account] + ACCOUNT_BOOSTERS_TOTAL[account]
        );
        Pool[] memory _allPools = IStakingPool(StakingPool).getPoolCollectionsWithoutRewards(_allPoolPids);
        uint _pid;
        uint _assetsCount;
        uint _boostersCount;
        uint _pIdx;
        uint _idx;
        uint _aIdx = 0;

        for (_idx = 0; _idx < _allPoolPids.length; _idx++) {
            _pid = _allPoolPids[_idx];

            if (_allPools[_idx].assetType == AssetType.NFT) {
                _assetsCount = ACCOUNT_POOL_ASSETS[account][_pid].length();
            } else if (
                _allPools[_idx].assetType == AssetType.Fungible &&
                ACCOUNT_POOL_FUNGIBLE_ASSETS[account][_pid] > 0
            ) {
                _assetsCount = 1;
            }
            _boostersCount = ACCOUNT_POOL_BOOSTERS[account][_pid].length();

            Asset[] memory _poolAssets = _allPools[_idx].assetType == AssetType.Fungible ?
                accountPoolFungibleAssets(account, _pid, _allPools[_idx], includeBoosters) :
                accountPoolAssets(account, _pid, _allPools[_idx], includeBoosters);

            for (_pIdx = 0; _pIdx < (_assetsCount + (includeBoosters ? _boostersCount : 0)); _pIdx++) {
                _allAccountAssets[_aIdx] = _poolAssets[_pIdx];
                _aIdx += 1;
            }
        }

        return _allAccountAssets;
    }

    function accountAssetsCount(address account, uint pid, bool isNFT) public view returns (uint) {
        return isNFT ? ACCOUNT_POOL_ASSETS[account][pid].length() : ACCOUNT_POOL_FUNGIBLE_ASSETS[account][pid];
    }

    function accountBoostersCount(address account, uint pid) public view returns (uint) {
        return ACCOUNT_POOL_BOOSTERS[account][pid].length();
    }

    function assetOwner(address account, address asset, uint tokenId) external view returns(bool) {
        return account == ASSETS[asset][tokenId].owner;
    }

    function assetDeposited(address asset, uint tokenId) external view returns (uint) {
        return ASSETS[asset][tokenId].deposited;
    }

    function fungibleAssetDeposited(address account, uint pid) external view returns (uint) {
        return ACCOUNT_POOL_FUNGIBLE_ASSETS_DEPOSITED[account][pid];
    }

    function accountData(address account) public view returns (AccountData memory) {
        return AccountData({
            assets: accountAssets(account, true),
            pools: accountPools(account),
            rewards: pendingAllPoolsRewards(account)
        });
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

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
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
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
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

enum AssetType {
    NFT, Fungible
}

enum NFTType {
    NONE, Asset, Booster
}

enum Rarity {
    NONE, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY
}

enum AccountType {
    FutureRoadmap,
    InitialLiquidity,
    Marketing,
    Staking,
    Team
}

enum PoolStatus {
    INACTIVE,
    ACTIVE,
    REMOVED
}

struct CurrentMoment {
    uint timestamp;
    uint week;
    uint secondsSinceGenesis;
    uint secondsSinceWeekStarted;
    uint secondsUntilWeekEnds;
}

struct Pool {
    uint pid; AssetType assetType; uint multiplier;
    address asset; address assetVoucher; uint totalAssets; Rarity assetRarity; uint maxAssets;
    address booster; address boosterVoucher; uint totalBoosters; uint boosterShares; uint maxBoosters;
    uint lockupDuration; uint lockupPenalty;
    PoolStatus status;
}

struct PoolRewards {
    CurrentMoment cMoment;
    uint assetsLifetime;
    uint assetsTotalPerSecond;
    uint assetsPerItemPerSecond;
    uint boostersLifetime;
    uint boostersTotalPerSecond;
    uint boostersPerItemPerSecond;
}

struct PoolData {
    Pool pool;
    PoolRewards rewards;

    uint lastUpdate;
}

struct Asset {
    address owner;
    address asset;
    uint tokenIdOrAmount;
    AssetType assetType;
    Rarity rarity;

    // staked info
    uint pid; uint deposited;
}

struct ItemizedRewards {
    uint total;
    uint assets;
    uint boosters;
}

struct VestedRewards {
    uint total;
    uint vested;
    uint locked;
}

struct AccountRewards {
    VestedRewards rewards;
    ItemizedRewards pendingRewards;
    ItemizedRewards claimedRewards;
}

struct AccountPool {
    uint pid;
    uint totalAssets;
    uint totalBoosters;
    AccountRewards rewards;
}

struct AccountData {
    Asset[] assets;
    AccountPool[] pools;
    AccountRewards rewards;
}