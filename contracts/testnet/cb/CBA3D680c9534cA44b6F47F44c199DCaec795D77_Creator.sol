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

//Created by Altrucoin.com - Block based fee distributor for V6.0.0 Vault

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import '@openzeppelin/contracts/access/Ownable.sol';

interface IFeeDsitributorFactory {
    function createFeeDistributor(
        address _token,
        address _dualToken,
        bool _dualTokenVault
    ) external returns (address);
}

interface IStakingFactory {
    function createStaking(
        address token_,
        address dualToken_,
        address payable feeDistributorV6_,
        uint256 rewardsPerBlock_,
        uint256 dualRewardsPerBlock_,
        uint256 tokenDecimals_,
        uint256 dualTokenDecimals_
    ) external returns (address);
}

interface IFeeDistributor {
    function setVault(address vault) external;

    function transferOwnership(address newOwner) external;
}

interface IVault {
    function transferOwnership(address newOwner) external;
}

contract Creator is Ownable {
    address public partnerAdmin;
    address public router;
    address[] private _vaults;

    IFeeDsitributorFactory public feeDistributorFactory;
    IStakingFactory public stakingFactory;

    mapping(address => address[2]) private stakings;

    constructor(address partnerAdmin_, address router_) {
        partnerAdmin = partnerAdmin_;
        router = router_;
    }

    function setFeeDistributorFactory(address newFactory) external onlyOwner {
        feeDistributorFactory = IFeeDsitributorFactory(newFactory);
    }

    function setStakingFactory(address newFactory) external onlyOwner {
        stakingFactory = IStakingFactory(newFactory);
    }

    function getStaking(address token) external view returns (address[2] memory) {
        return stakings[token];
    }

    function getAllVaults() external view returns (address[] memory) {
        return _vaults;
    }

    function changeAdmin(address newPartnerAdmin) external {
        require(msg.sender == partnerAdmin);
        partnerAdmin = newPartnerAdmin;
    }

    function createStaking(
        address token,
        address dualToken,
        bool dualTokenVault,
        uint256 rewardsPerBlock,
        uint256 dualRewardsPerBlock,
        uint256 tokenDecimals,
        uint256 dualTokenDecimals
    ) external {
        // require(
        //     stakings[token][0] == address(0) && stakings[token][1] == address(0),
        //     'Staking Vault alredy exists'
        // ); TODO add on prod !!!

        address _feeDistributor = feeDistributorFactory.createFeeDistributor(
            token,
            dualToken,
            dualTokenVault
        );
        address _vault = stakingFactory.createStaking(
            token,
            dualToken,
            payable(_feeDistributor),
            rewardsPerBlock,
            dualRewardsPerBlock,
            tokenDecimals,
            dualTokenDecimals
        );

        stakings[token] = [_vault, _feeDistributor];
        _vaults.push(_vault);
        IFeeDistributor(_feeDistributor).setVault(_vault);

        IVault(_vault).transferOwnership(msg.sender);
        IFeeDistributor(_feeDistributor).transferOwnership(msg.sender);
    }
}