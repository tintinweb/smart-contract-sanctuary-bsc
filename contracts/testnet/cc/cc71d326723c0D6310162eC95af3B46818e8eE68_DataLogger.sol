/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// File: interfaces/IDataLog.sol



pragma solidity 0.8.11;


enum DataSource {
    Campaign,
    MarketPlace,
    SuperFarm,
    Swap
}

enum DataAction {
    Buy,
    Refund,
    ClaimDeed,
    List,
    Unlist,
    AddLp,
    RemoveLp,
    Swap
}

interface IDataLog {
    
    function log(address from, DataSource source, DataAction action, uint data1, uint data2) external;

}


// File: interfaces/IRoleAccess.sol



pragma solidity 0.8.11;

interface IRoleAccess {
    function isAdmin(address user) view external returns (bool);
    function isDeployer(address user) view external returns (bool);
    function isConfigurator(address user) view external returns (bool);
    function isApprover(address user) view external returns (bool);
    function isRole(string memory roleName, address user) view external returns (bool);
}

// File: DataLogger.sol



pragma solidity 0.8.11;



contract DataLogger is IDataLog {

    // Access rights control
    IRoleAccess private _roles;
    mapping (address => bool) public allowedSource;
    
    event SetSource(address source, bool allowed);
    
    event Log(address indexed from, DataSource indexed source, DataAction action, uint data1, uint data2);

    modifier onlyAdmin() {
        require(_roles.isAdmin(msg.sender), "Not Admin");
        _;
    }

    constructor(IRoleAccess rolesRegistry)
    {
        _roles = rolesRegistry;
    }

    function setSource(address source, bool allowed) external onlyAdmin {
        allowedSource[source] = allowed;
        emit SetSource(source, allowed);
    }

    function log(address from, DataSource source, DataAction action, uint data1, uint data2) external {
        require(allowedSource[msg.sender], "Not allowed to log");
        emit Log(from, source, action, data1, data2);
    }
}