// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.10;

import "IOasisVault.sol";
import "AccessManager.sol";
import "IERC20.sol";

contract OasisVault is IOasisVault, AccessManager {
    address public receiver;

    constructor(IRoleRegistry _roleRegistry, address _receiver) {
        setRoleRegistry(_roleRegistry);
        receiver = _receiver;
    }

    receive() external payable {
        emit TokenReceived(msg.sender, msg.value);
    }

    function changeReceiver(address _receiver)
        external
        override
        onlyRole(Roles.ADMIN)
    {
        receiver = _receiver;
    }

    function withdrawChainToken(uint256 _amount)
        external
        override
        onlyRole(Roles.VAULT_WITHDRAWER)
    {
        payable(receiver).transfer(_amount);
        emit ChainTokenWithdrawed(_amount);
    }

    function withdrawERC20Token(address _tokenAddress, uint256 _amount)
        external
        override
        onlyRole(Roles.VAULT_WITHDRAWER)
    {
        IERC20(_tokenAddress).transfer(receiver, _amount);
        emit ERC20Withdrawed(_tokenAddress, _amount);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.10;

interface IOasisVault {
    event TokenReceived(address sender, uint256 amount);

    event ChainTokenWithdrawed(uint256 amount);

    event ERC20Withdrawed(address tokenAddress, uint256 amount);

    function changeReceiver(address _receiver) external;

    function withdrawChainToken(uint256 _amount) external;

    function withdrawERC20Token(address _tokenAddress, uint256 _amount)
        external;
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "RoleLibrary.sol";

import "IRoleRegistry.sol";

/**
 * @notice Provides modifiers for authorization
 */
contract AccessManager {
    IRoleRegistry internal roleRegistry;
    bool public isInitialised = false;

    modifier onlyRole(bytes32 role) {
        require(roleRegistry.hasRole(role, msg.sender), "Unauthorized access");
        _;
    }

    modifier onlyGovernance() {
        require(
            roleRegistry.hasRole(Roles.ADMIN, msg.sender),
            "Unauthorized access"
        );
        _;
    }

    modifier onlyRoles2(bytes32 role1, bytes32 role2) {
        require(
            roleRegistry.hasRole(role1, msg.sender) ||
                roleRegistry.hasRole(role2, msg.sender),
            "Unauthorized access"
        );
        _;
    }

    function setRoleRegistry(IRoleRegistry _roleRegistry) public {
        require(!isInitialised, "RoleRegistry already initialised");
        roleRegistry = _roleRegistry;
        isInitialised = true;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.10;

library Roles {
    bytes32 internal constant ADMIN = "admin";
    bytes32 internal constant REVENUE_MANAGER = "revenue_manager";
    bytes32 internal constant MISSION_TERMINATOR = "mission_terminator";
    bytes32 internal constant DAPP_GUARD = "dapp_guard";
    bytes32 internal constant DAPP_GUARD_KILLER = "dapp_guard_killer";
    bytes32 internal constant MISSION_CONFIGURATOR = "mission_configurator";
    bytes32 internal constant VAULT_WITHDRAWER = "vault_withdrawer";
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.10;

interface IRoleRegistry {
    function grantRole(bytes32 _role, address account) external;

    function revokeRole(bytes32 _role, address account) external;

    function hasRole(bytes32 _role, address account)
        external
        view
        returns (bool);
}

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