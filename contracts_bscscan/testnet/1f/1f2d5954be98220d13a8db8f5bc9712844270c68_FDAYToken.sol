/**
 * SPDX-License-Identifier: MIT
 */

pragma solidity 0.8.7;

import "./Initializable.sol";
import "./PoolUpgradeable.sol";
import "./PredictionUpgradeable.sol";
import "./UUPSUpgradeable.sol";
import "./OwnableUpgradeable.sol";
import "./Proxy.sol";

contract FDAYToken is Initializable, PoolUpgradeable, PredictionUpgradeable, UUPSUpgradeable, OwnableUpgradeable {

/// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function __FDAYToken_init(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 initialSupply,
        address owner
    ) private onlyInitializing {
        __ERC20_init(name, symbol, decimals);
        __ERC20Burnable_init_unchained();
        __FDAYToken_init_unchained(initialSupply, owner);
    }

    function __FDAYToken_init_unchained(
        uint256 initialSupply,
        address owner
    ) private onlyInitializing {
        _mint(owner, initialSupply);
    }

    function initialize(
        address owner
    ) public initializer {
        uint8 __decimals = 18;
        __Ownable_init();
        transferOwnership(owner);
        __UUPSUpgradeable_init();
        __FDAYToken_init("Kon Day", "KDAY", __decimals, 7888 * (10 ** 6) * (10 ** __decimals), owner);
        __PoolUpgradeable_init();
        __PredictionUpgradeable_init();
    }

    function getOwner() external view override returns (address) {
        return __owner();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    uint256[50] private __gap;

}

contract UUPSProxy is Proxy, ERC1967UpgradeUpgradeable {

    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * It's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic) payable initializer {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        __ERC1967Upgrade_init();
        _upgradeToAndCall(
            _logic, 
            abi.encodeWithSelector(FDAYToken(address(0)).initialize.selector, msg.sender), 
            false
        );
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view override returns (address) {
        return _getImplementation();
    }

    uint256[50] private __gap;

}