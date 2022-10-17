// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";
import "./PolicyStore.sol";

contract PolicyDecisionPoint is Ownable {
    PolicyStore public store;
    
    function configurePolicyStore(address _store) public onlyOwner {
        require(address(store) == address(0), "policy store is already configured!");
        store = PolicyStore(_store);
    }
    
    function evaluatePolicyForUser(SecurityTypes.Policy memory policy, address user) internal view returns (SecurityTypes.PolicyEffect) {
        for (uint i=0; i < policy.rules.length; i++) {
            if (!store.hasRole(user, policy.rules[i].role)) continue;
            SecurityTypes.PolicyEffect effect = policy.rules[i].effect;
            if (effect == SecurityTypes.PolicyEffect.GRANT || effect == SecurityTypes.PolicyEffect.DENY) return effect;
        }
        return SecurityTypes.PolicyEffect.UNKNOWN;
    }

    function isPolicyDefined(SecurityTypes.Policy memory policy) internal view returns (bool) {
        return policy.rules.length > 0;
    }
    
    function isAuthorized(bytes32 resource, bytes32 action, address user) public view returns (bool) {
        require(address(store) != address(0), "!store");
        SecurityTypes.Policy memory policy = store.fetchPolicy(resource, action);
        SecurityTypes.PolicyEffect effect = SecurityTypes.PolicyEffect.UNKNOWN;
        if (isPolicyDefined(policy)) {
            effect = evaluatePolicyForUser(policy, user);
        }
        if (effect == SecurityTypes.PolicyEffect.UNKNOWN) {
           policy = store.fetchPolicy(resource, SecurityTypes.ANY);
           if (isPolicyDefined(policy)) {
              effect = evaluatePolicyForUser(policy, user);
           }
        }
        if (effect == SecurityTypes.PolicyEffect.UNKNOWN) {
           policy = store.fetchPolicy(SecurityTypes.ANY, SecurityTypes.ANY);
           if (isPolicyDefined(policy)) {
              effect = evaluatePolicyForUser(policy, user);
           }
        }
        return (effect == SecurityTypes.PolicyEffect.GRANT);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;
import "../common/Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    function initOwnerAfterCloning(address newOwner) public {
        require(_owner == address(0), "Ownable: owner has already been initialized");
        emit OwnershipTransferred(address(0), newOwner);
        _owner = newOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0x000000000000000000000031337000b017000d0114);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;
pragma experimental ABIEncoderV2;

import "./SecurityTypes.sol";

interface PolicyStore {
    function fetchPolicy(bytes32 resource, bytes32 action) external view returns (SecurityTypes.Policy memory);
    function fetchRole(bytes32 role, address user) external view returns (SecurityTypes.Role memory);
    function fetchRoleMembers(bytes32 role) external view returns (address[] memory);
    function fetchUserRoles(address user) external view returns (bytes32[] memory);
    function hasRole(address user, bytes32 role) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;
pragma experimental ABIEncoderV2;

library SecurityTypes {
    bytes32 public constant ANY = 0x0;
    
    enum PolicyEffect { UNKNOWN, GRANT, DENY }
    
    struct Rule {
       bytes32 role;
       PolicyEffect effect;
    }
    
    struct Policy {
       Rule[] rules;
    }
    
    struct Role {
       bytes32 adminRole;
       string label;
    }
}