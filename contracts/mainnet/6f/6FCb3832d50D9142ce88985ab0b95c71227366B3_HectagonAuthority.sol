// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./interfaces/IHectagonAuthority.sol";
import "./types/HectagonAccessControlled.sol";

contract HectagonAuthority is IHectagonAuthority, HectagonAccessControlled {
    /* ========== STATE VARIABLES ========== */

    address public override governor;

    address public override guardian;

    address public override policy;

    address public override vault;

    address public newGovernor;

    address public newGuardian;

    address public newPolicy;

    address public newVault;

    /* ========== Constructor ========== */

    constructor(
        address _governor,
        address _guardian,
        address _policy,
        address _vault
    ) HectagonAccessControlled(IHectagonAuthority(address(this))) {
        governor = _governor;
        emit GovernorPushed(address(0), governor, true);
        guardian = _guardian;
        emit GuardianPushed(address(0), guardian, true);
        policy = _policy;
        emit PolicyPushed(address(0), policy, true);
        vault = _vault;
        emit VaultPushed(address(0), vault, true);
    }

    /* ========== GOV ONLY ========== */

    function pushGovernor(address _newGovernor, bool _effectiveImmediately) external onlyGovernor {
        if (_effectiveImmediately) governor = _newGovernor;
        newGovernor = _newGovernor;
        emit GovernorPushed(governor, newGovernor, _effectiveImmediately);
    }

    function pushGuardian(address _newGuardian, bool _effectiveImmediately) external onlyGovernor {
        if (_effectiveImmediately) guardian = _newGuardian;
        newGuardian = _newGuardian;
        emit GuardianPushed(guardian, newGuardian, _effectiveImmediately);
    }

    function pushPolicy(address _newPolicy, bool _effectiveImmediately) external onlyGovernor {
        if (_effectiveImmediately) policy = _newPolicy;
        newPolicy = _newPolicy;
        emit PolicyPushed(policy, newPolicy, _effectiveImmediately);
    }

    function pushVault(address _newVault, bool _effectiveImmediately) external onlyGovernor {
        if (_effectiveImmediately) vault = _newVault;
        newVault = _newVault;
        emit VaultPushed(vault, newVault, _effectiveImmediately);
    }

    /* ========== PENDING ROLE ONLY ========== */

    function pullGovernor() external {
        require(msg.sender == newGovernor, "!newGovernor");
        emit GovernorPulled(governor, newGovernor);
        governor = newGovernor;
    }

    function pullGuardian() external {
        require(msg.sender == newGuardian, "!newGuard");
        emit GuardianPulled(guardian, newGuardian);
        guardian = newGuardian;
    }

    function pullPolicy() external {
        require(msg.sender == newPolicy, "!newPolicy");
        emit PolicyPulled(policy, newPolicy);
        policy = newPolicy;
    }

    function pullVault() external {
        require(msg.sender == newVault, "!newVault");
        emit VaultPulled(vault, newVault);
        vault = newVault;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IHectagonAuthority {
    /* ========== EVENTS ========== */

    event GovernorPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event GuardianPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event PolicyPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event VaultPushed(address indexed from, address indexed to, bool _effectiveImmediately);

    event GovernorPulled(address indexed from, address indexed to);
    event GuardianPulled(address indexed from, address indexed to);
    event PolicyPulled(address indexed from, address indexed to);
    event VaultPulled(address indexed from, address indexed to);

    /* ========== VIEW ========== */

    function governor() external view returns (address);

    function guardian() external view returns (address);

    function policy() external view returns (address);

    function vault() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../interfaces/IHectagonAuthority.sol";

error UNAUTHORIZED();

/**
 *   @dev Reasoning for this contract = modifiers literaly copy code
 *   instead of pointing towards the logic to execute. Over many
 *   functions this bloats contract size unnecessarily.
 */
abstract contract HectagonAccessControlled {
    /* ========== EVENTS ========== */

    event AuthorityUpdated(IHectagonAuthority authority);

    /* ========== STATE VARIABLES ========== */

    IHectagonAuthority public authority;

    /* ========== Constructor ========== */

    constructor(IHectagonAuthority _authority) {
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }

    /* ========== "MODIFIERS" ========== */

    modifier onlyGovernor() {
        _onlyGovernor();
        _;
    }

    modifier onlyGuardian() {
        _onlyGuardian();
        _;
    }

    modifier onlyPolicy() {
        _onlyPolicy();
        _;
    }

    modifier onlyVault() {
        _onlyVault();
        _;
    }

    /* ========== GOV ONLY ========== */

    function setAuthority(IHectagonAuthority _newAuthority) external {
        _onlyGovernor();
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }

    /* ========== INTERNAL CHECKS ========== */

    function _onlyGovernor() internal view {
        if (msg.sender != authority.governor()) revert UNAUTHORIZED();
    }

    function _onlyGuardian() internal view {
        if (msg.sender != authority.guardian()) revert UNAUTHORIZED();
    }

    function _onlyPolicy() internal view {
        if (msg.sender != authority.policy()) revert UNAUTHORIZED();
    }

    function _onlyVault() internal view {
        if (msg.sender != authority.vault()) revert UNAUTHORIZED();
    }
}