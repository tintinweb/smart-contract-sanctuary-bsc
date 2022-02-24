// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/AppStorage.sol";

contract Box {
    
    AppStorage internal s;

    event ValueChanged(uint256 value);

    function initialize() public {
        s._auth = new Auth(msg.sender);
    }

    function store(uint256 value) public {
        // Require that the caller is registered as an administrator in Auth
        require(s._auth.isAdministrator(msg.sender), "Unauthorized");

        s._value = value;
        emit ValueChanged(value);
    }

    function retrieve() public view returns (uint256) {
        return s._value;
    }
}

// AppStorage.sol

// Import Auth from the access-control subdirectory
import "./access-control/Auth.sol";


struct AppStorage {
  uint256 _value;
  Auth _auth;
  
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auth {
    address private _administrator;

    constructor(address deployer) {
        // Make the deployer of the contract the administrator
        _administrator = deployer;
    }

    function isAdministrator(address user) public view returns (bool) {
        return user == _administrator;
    }
}