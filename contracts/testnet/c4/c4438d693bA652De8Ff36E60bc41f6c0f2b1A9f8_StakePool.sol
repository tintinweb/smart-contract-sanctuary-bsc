// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../interfaces/IMembership.sol";
import "../../externalContract/openzeppelin/Math.sol";
import "./StakePoolBase.sol";

contract StakePool is StakePoolBase {
    modifier onlyNextPool() {
        require(msg.sender == nextPoolAddress, "StakePool/caller-is-not-nextStakePool");
        _;
    }

    constructor(
        address _membershipAddress,
        address _stakeVaultAddress,
        address _forwAddress
    ) {
        membershipAddress = _membershipAddress;
        stakeVaultAddress = _stakeVaultAddress;
        forwAddress = _forwAddress;
        manager = msg.sender;
    }

    // external function onlyManager
    function setNextPool(address _address) external onlyManager {
        nextPoolAddress = _address;
    }

    function setSettleInterval(uint256 interval) external onlyManager {
        settleInterval = interval;
    }

    function setSettlePeriod(uint256 period) external onlyManager {
        settlePeriod = period;
    }

    function setRankInfo(
        uint256[] memory _interestBonusLending,
        uint256[] memory _forwardBonusLending,
        uint256[] memory _minimumstakeAmount
    ) external onlyManager {
        require(
            _interestBonusLending.length == _forwardBonusLending.length,
            "stakePool/input-does-not-have-same-length"
        );

        require(
            _forwardBonusLending.length == _minimumstakeAmount.length,
            "stakePool/input-does-not-have-same-length-2"
        );
        for (uint8 i = 0; i < _interestBonusLending.length; i++) {
            RankInfo memory rankInfo = RankInfo(
                _interestBonusLending[i],
                _forwardBonusLending[i],
                _minimumstakeAmount[i]
            );
            rankInfos[i] = rankInfo;
        }
    }

    function resetStakeInfo() external onlyNextPool {
        // TODO: implement
    }

    function pause(bytes4 _func) external onlyOwner {
        require(_func != bytes4(0), "");
        _pause(_func);
    }

    function unPause(bytes4 _func) external onlyOwner {
        require(_func != bytes4(0), "");
        _unpause(_func);
    }

    // external function

    // TODO: removed
    function settle(uint256 nftId) external nonReentrant whenFuncNotPaused(msg.sig) {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        _settle(nftId);
    }

    function stake(uint256 nftId, uint256 amount)
        external
        nonReentrant
        whenFuncNotPaused(msg.sig)
        returns (StakeInfo memory)
    {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        return _stake(nftId, amount);
    }

    function unstake(uint256 nftId, uint256 amount)
        external
        nonReentrant
        whenFuncNotPaused(msg.sig)
        returns (StakeInfo memory)
    {
        nftId = IMembership(membershipAddress).usableTokenId(nftId);
        return _unstake(nftId, amount);
    }

    function getRankInfo(uint8 _rank) external view returns (RankInfo memory) {
        return rankInfos[_rank];
    }

    // internal function

    function _settle(uint256 nftId) internal {
        StakeInfo memory nftStakeInfo = stakeInfos[nftId];
        uint64 poolLastSettleTimestamp = uint64(block.timestamp) -
            ((uint64(block.timestamp) - poolStartTimestamp) % uint64(settleInterval));
        require(uint64(block.timestamp) > poolStartTimestamp, "StakePool/this-is-pool-start-ts");
        uint256 I = Math.min(
            uint256(
                (poolLastSettleTimestamp - nftStakeInfo.lastSettleTimestamp) /
                    uint256(settleInterval)
            ),
            settlePeriod
        );
        if (I != 0) {
            for (uint256 index = 0; index < I; index++) {
                nftStakeInfo.claimableAmount += nftStakeInfo.payPattern[index];
                nftStakeInfo.payPattern[index] = 0;
            }
        }

        // Not sure shift left array
        for (uint256 i = 0; i < I; i++) {
            for (uint256 x = 0; x < nftStakeInfo.payPattern.length - 1; x++) {
                nftStakeInfo.payPattern[x] = nftStakeInfo.payPattern[x + 1];
            }
            delete nftStakeInfo.payPattern[nftStakeInfo.payPattern.length - 1];
        }
        nftStakeInfo.lastSettleTimestamp = poolLastSettleTimestamp;
        stakeInfos[nftId] = nftStakeInfo;
    }

    function _stake(uint256 nftId, uint256 amount) internal returns (StakeInfo memory) {
        StakeInfo memory nftStakeInfo = stakeInfos[nftId];
        // TODO: fix
        if (nftStakeInfo.startTimestamp != 0) {
            nftStakeInfo.startTimestamp = uint64(block.timestamp);
        }
        nftStakeInfo.stakeBalance += amount;
        nftStakeInfo.endTimestamp =
            uint64(block.timestamp) -
            poolStartTimestamp +
            uint64(settleInterval * settlePeriod);
        nftStakeInfo.endTimestamp -=
            (nftStakeInfo.endTimestamp % uint64(settleInterval)) +
            poolStartTimestamp;
        nftStakeInfo.payPattern = new uint256[](4);
        for (uint256 i = 0; i < nftStakeInfo.payPattern.length; i++) {
            if (i < 3) {
                nftStakeInfo.payPattern[i] = amount / settlePeriod;
            } else {
                nftStakeInfo.payPattern[i] =
                    nftStakeInfo.stakeBalance -
                    (3 * (amount / settlePeriod));
            }
        }
        stakeInfos[nftId] = nftStakeInfo;
        _updateNFTRank(nftId);

        _transferFromIn(
            IMembership(membershipAddress).ownerOf(nftId),
            stakeVaultAddress,
            forwAddress,
            amount
        );
        return nftStakeInfo;
    }

    function _unstake(uint256 nftId, uint256 amount) internal returns (StakeInfo memory) {
        StakeInfo memory nftStakeInfo = stakeInfos[nftId];
        _settle(nftId);

        require(nftStakeInfo.stakeBalance >= amount, "StakePool/unstake-balance-is-insufficient");
        if (nftStakeInfo.claimableAmount < amount) {
            amount = nftStakeInfo.claimableAmount;
        }
        nftStakeInfo.stakeBalance -= amount;
        nftStakeInfo.claimableAmount -= amount;

        _updateNFTRank(nftId);
        _transferFromOut(stakeVaultAddress, msg.sender, forwAddress, amount);
        return nftStakeInfo;
    }

    function _updateNFTRank(uint256 nftId) internal returns (uint8) {
        uint256 stakeBalance = stakeInfos[nftId].stakeBalance;
        uint8 currentRank = IMembership(membershipAddress).getRank(msg.sender, nftId);

        //  TODO: rankInfos can index out of bound, so that we should prevent it by add mock rank?
        if (
            stakeBalance >= rankInfos[currentRank].minimumStakeAmount ||
            stakeBalance < rankInfos[currentRank + 1].minimumStakeAmount
        ) {
            return currentRank;
        }

        bool increase = stakeBalance >= rankInfos[currentRank + 1].minimumStakeAmount;
        uint8 newRank = currentRank;

        do {
            if (
                stakeBalance >= rankInfos[newRank + 1].minimumStakeAmount ||
                stakeBalance < rankInfos[newRank].minimumStakeAmount
            ) {
                if (increase) {
                    newRank += 1;
                } else {
                    newRank -= 1;
                }
            }
        } while (newRank != 0 && newRank != rankLen - 1);

        IMembership(membershipAddress).updateRank(nftId, newRank);

        return newRank;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../externalContract/openzeppelin/IERC721Enumerable.sol";

interface IMembership is IERC721Enumerable {
    // External functions

    function getDefaultMembership(address owner) external view returns (uint256);

    function setDefaultMembership(uint256 tokenId) external;

    // function setNewPool(address newPool) external;

    function getPoolLists() external view returns (address[] memory);

    function mint(address to) external returns (uint256);

    // function setBaseURI(string memory baseTokenURI) external;

    function updateRank(uint256 tokenId, uint8 newRank) external;

    function usableTokenId(uint256 tokenId) external view returns (uint256);

    function getRank(uint256 tokenId) external view returns (uint8);

    function getRank(address pool, uint256 tokenId) external view returns (uint8);

    function currentPool() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../externalContract/openzeppelin/Ownable.sol";
import "../../externalContract/openzeppelin/ReentrancyGuard.sol";
import "../../externalContract/modify/SelectorPausable.sol";
import "../utils/AssetHandler.sol";
import "../utils/Manager.sol";

contract StakePoolBase is AssetHandler, Ownable, Manager, ReentrancyGuard, SelectorPausable {
    struct StakeInfo {
        uint256 stakeBalance;
        uint256 claimableAmount;
        uint64 startTimestamp;
        uint64 endTimestamp;
        uint64 lastSettleTimestamp;
        uint256[] payPattern;
    }

    struct RankInfo {
        uint256 interestBonusLending;
        uint256 forwardBonusLending;
        uint256 minimumStakeAmount;
    }

    address public membershipAddress;
    address public nextPoolAddress;
    address public stakeVaultAddress;
    address public forwAddress;
    uint64 public poolStartTimestamp;
    uint256 public settleInterval;
    uint256 public settlePeriod;
    uint256 public rankLen;
    mapping(uint256 => StakeInfo) public stakeInfos;
    mapping(uint8 => RankInfo) public rankInfos;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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

import "./Context.sol";

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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../openzeppelin/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract SelectorPausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account` and `function selector`.
     */
    event Paused(address account, bytes4 functionSelector);

    /**
     * @dev Emitted when the pause is lifted by `account` and `function selector`.
     */
    event Unpaused(address account, bytes4 functionSelector);

    mapping(bytes4 => bool) private _isPaused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        //_isPaused = false;
    }

    /**
     * @dev Returns true if the function selected is paused, and false otherwise.
     */
    function isPaused(bytes4 _func) public view virtual returns (bool) {
        return _isPaused[_func];
    }

    /**
     * @dev Modifier to make a function callable only when the function selected is not paused.
     *
     * Requirements:
     *
     * - The function selected must not be paused.
     */
    modifier whenFuncNotPaused(bytes4 _func) {
        require(!_isPaused[_func], "Pausable/function-is-paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the function selected is paused.
     *
     * Requirements:
     *
     * - The function selected must be paused.
     */
    modifier whenFuncPaused(bytes4 _func) {
        require(_isPaused[_func], "Pausable/function-is-not-paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The function selected must not be paused.
     */
    function _pause(bytes4 _func) internal virtual whenFuncNotPaused(_func) {
        _isPaused[_func] = true;
        emit Paused(_msgSender(), _func);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The function selected must be paused.
     */
    function _unpause(bytes4 _func) internal virtual whenFuncPaused(_func) {
        _isPaused[_func] = false;
        emit Unpaused(_msgSender(), _func);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../interfaces/IWethERC20.sol";
import "../../externalContract/openzeppelin/IERC20.sol";

import "./WETHHandler.sol";

contract AssetHandler {
    address public constant wethAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    //address public constant wethToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c  // bsc (Wrapped BNB)

    address public constant wethHandler = 0x64493B5B3419e116F9fbE3ec41cF2E65Ef15cAB6;

    function _transferFromIn(
        address from,
        address to,
        address token,
        uint256 amount
    ) internal {
        require(amount != 0, "AssetHandler/amount-is-zero");

        if (token == wethAddress) {
            require(amount == msg.value, "AssetHandler/value-not-matched");
            IWethERC20(wethAddress).deposit{value: amount}();
        } else {
            IERC20(token).transferFrom(from, to, amount);
        }
    }

    function _transferFromOut(
        address from,
        address to,
        address token,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }
        if (token == wethAddress) {
            IWethERC20(wethAddress).transfer(wethHandler, amount);
            WETHHandler(payable(wethHandler)).withdrawETH(to, amount);
            // (bool success, ) = to.call{value: amount}(new bytes(0));
            // require(success, "AssetHandler/withdraw-failed-1");
        } else {
            IERC20(token).transferFrom(from, to, amount);
        }
    }

    function _transferOut(
        address to,
        address token,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }
        if (token == wethAddress) {
            IWethERC20(wethAddress).transfer(wethHandler, amount);
            WETHHandler(payable(wethHandler)).withdrawETH(to, amount);
            // (bool success, ) = to.call{value: amount}(new bytes(0));
            // require(success, "AssetHandler/withdraw-failed-2");
        } else {
            IERC20(token).transfer(to, amount);
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
import "../../externalContract/openzeppelin/Context.sol";

pragma solidity 0.8.7;

contract Manager {
    address public manager;
    event TransferManager(address, address);

    constructor() {}

    modifier onlyManager() {
        require(manager == msg.sender, "Manager/caller-is-not-the-manager");
        _;
    }

    function transferManager(address newManager) public virtual onlyManager {
        require(newManager != address(0), "Manager/new-manager-is-the-zero-address");
        _transferManager(newManager);
    }

    function _transferManager(address newManager) internal virtual {
        address oldManager = manager;
        manager = newManager;
        emit TransferManager(oldManager, newManager);
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "./IWeth.sol";
import "../externalContract/openzeppelin/IERC20.sol";

interface IWethERC20 is IWeth, IERC20 {}

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "../../interfaces/IWeth.sol";

contract WETHHandler {
    address public constant wethAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    //address public constant wethToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c  // bsc (Wrapped BNB)

    function withdrawETH(address to, uint256 amount) external {
        IWeth(wethAddress).withdraw(amount);
        (bool success, ) = to.call{value: amount}(new bytes(0));
        require(success, "AssetHandler/withdraw-failed-1");
    }

    fallback() external {
        revert("fallback function not allowed");
    }

    receive() external payable {}
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

interface IWeth {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}