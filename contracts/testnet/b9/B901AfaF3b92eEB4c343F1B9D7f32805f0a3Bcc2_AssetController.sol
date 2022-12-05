// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IAssetData.sol";
import "../interfaces/IAssetVault.sol";
import "../interfaces/IVaultFactory.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AssetController is ReentrancyGuard {

    address private owner;
    address public factory;
    address public assetData;

    constructor(address _vaultFactory, address _assetData) {
        owner = msg.sender;
        factory = _vaultFactory;
        assetData = _assetData;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only available to the owner"); 
        _;
    }

    /// Vault and asset addition and removal
    
    function addVaultAndAsset(address _assetAddress) external onlyOwner {
        address newVault = IVaultFactory(factory).createVault(_assetAddress);
        IAssetData(assetData).addAsset(_assetAddress, newVault);
    }

    /// Asset movements

    function depositAsset(address _assetAddress, uint256 _amount) public nonReentrant { 
        address vaultAddress = IAssetData(assetData).getVaultUsingAddress(_assetAddress);
        IAssetVault(vaultAddress).vaultAsset(msg.sender, _amount);
    }

    function approveWithdrawal(address _approvee, address _assetAddress, uint256 _amount) public {
        address vaultAddress = IAssetData(assetData).getVaultUsingAddress(_assetAddress);
        IAssetVault(vaultAddress).approveDevaulter(_approvee, _amount);
    }

    function withdrawAsset(address _assetAddress, uint256 _amount) public nonReentrant {
        address vaultAddress = IAssetData(assetData).getVaultUsingAddress(_assetAddress); 
        IAssetVault(vaultAddress).devaultAsset(msg.sender, _amount);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAssetData {

    function getVaultUsingAddress(address _assetAddress) external view returns (address);

    function getAssetUsingVault(address _vaultAddress) external view returns (address);

    function addAsset(address _aa, address _va) external;

    function deleteAsset(address _assetAddress, address _vaultAddress) external;

    function setAssetController(address _assetController) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAssetVault {

    function vaultAsset(address _depositor, uint256 _amount) external;

    function approveDevaulter(address _approvee, uint256 _amount) external;

    function devaultAsset(address _recipient, uint256 _amount) external;

    function vaultCounterasset(address _depositor, address _counterassetAddress, uint256 _amount) external;

    function approveCounterassetDevaulter(address _approvee, address _counterassetAddress, uint256 _amount) external;

    function devaultCounterasset(address _recipient, address _counterassetAddress, uint256 _amount) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVaultFactory {

    function createVault(address _assetAddress) external returns (address);

    function setOwner(address _owner) external;

    function setAssetController(address _assetController) external;

}