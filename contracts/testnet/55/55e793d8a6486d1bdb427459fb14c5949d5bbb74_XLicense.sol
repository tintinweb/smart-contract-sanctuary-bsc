/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
} 

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title XLicense
 * @author W3ak
 * @dev Of course I still love You!
 */
contract XLicense is Owner {
    struct project{
        string name;
        string build;
        string syncUrl;
        uint8 accessType; 
        string teleGroupId;
        string teleBotId; 
    }
    project pi;
    struct license{
        string key;
        string user;
        uint8 role;  
    }
    mapping(string => license) licenseList;
    string[] public licenseIdList;

    function setPI (string memory name, string memory build, string memory syncUrl, uint8 accessType, string memory teleGroupId, string memory teleBotId) isOwner public{
        pi = project(name, build, syncUrl, accessType, teleGroupId, teleBotId);
    }

    function getPI() public view returns(string memory, string memory, string memory, uint8, string memory, string memory){
        return (pi.name,pi.build, pi.syncUrl, pi.accessType, pi.teleGroupId, pi.teleBotId);
    }

    function setVersion(string memory build, string memory syncUrl) isOwner public{
        pi.build = build;
        pi.syncUrl = syncUrl;
    }

    function setTelegram(string memory teleGroupId, string memory teleBotId) isOwner public{
        pi.teleGroupId = teleGroupId;
        pi.teleBotId = teleBotId;
    }

    function setAccessType(uint8 accessType) isOwner public{
        pi.accessType = accessType;
    }

    function createLicense(string memory key, string memory user, uint8 role) isOwner public {
        license storage newLicense = licenseList[key];
        newLicense.key = key;
        newLicense.user = user;
        newLicense.role = role;
        licenseIdList.push(key);
    }

    function getLicense(string memory key) public view returns(string memory, string memory, uint8) {
        license storage s = licenseList[key];
        return (s.key, s.user, s.role);
    }

    function removeLicense(string memory key) isOwner public {
        delete licenseList[key];
    }
}