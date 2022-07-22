/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

// SPDX-License-Identifier: GPL-3.0
// File: contracts/Owner.sol



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
// File: contracts/XLicense.sol



pragma solidity >=0.7.0 <0.9.0;

/**
 * @title XLicense
 * @author W3ak
 * @dev Of course I still love You!
 */
contract XLicense is Owner {
    struct projectInfo{
        string _name;
        string _build;
        string _syncUrl;
        uint8 _accessType; 
        string _teleGroupId;
        string _teleBotId; 
    }
    projectInfo pi;
    struct license{
        string _key;
        string _user;
        uint8 _role;  
    }
    mapping(string => license) licenseList;
    string[] licenseIdList;

    function setProjectInfo (string memory name, string memory build, string memory syncUrl, uint8 accessType, string memory teleGroupId, string memory teleBotId) isOwner public{
        pi = projectInfo(name, build, syncUrl, accessType, teleGroupId, teleBotId);
    }

    function getProjectInfo() public view returns(string memory, string memory, string memory, uint8, string memory, string memory){
        return (pi._name,pi._build, pi._syncUrl, pi._accessType, pi._teleGroupId, pi._teleBotId);
    }

    function setVer(string memory build, string memory syncUrl) isOwner public{
        pi._build = build;
        pi._syncUrl = syncUrl;
    }

    function setReportEndpoint(string memory teleGroupId, string memory teleBotId) isOwner public{
        pi._teleGroupId = teleGroupId;
        pi._teleBotId = teleBotId;
    }

    function setAccessType(uint8 accessType) isOwner public{
        pi._accessType = accessType;
    }

    function addLic(string memory key, string memory user, uint8 role) isOwner public {
        license storage newLicense = licenseList[key];
        newLicense._key = key;
        newLicense._user = user;
        newLicense._role = role;
        licenseIdList.push(key);
    }

    function addMultipleLic(license[] memory _data) isOwner public {
        for(uint i = 0; i< _data.length; i++){
            license storage newLicense = licenseList[_data[i]._key];
            newLicense._key = _data[i]._key;
            newLicense._user = _data[i]._user;
            newLicense._role = _data[i]._role;
            licenseIdList.push(_data[i]._key);
        }
    }

    function getLic(string memory key) public view returns(string memory, string memory, uint8) {
        license storage s = licenseList[key];
        return (s._key, s._user, s._role);
    }

    function getLicByIndex(uint index) public view returns(string memory, string memory, uint8) {
        license storage s = licenseList[licenseIdList[index]];
        return (s._key, s._user, s._role);
    }

    function removeLic(string memory key) isOwner public {
        delete licenseList[key];
    }
}