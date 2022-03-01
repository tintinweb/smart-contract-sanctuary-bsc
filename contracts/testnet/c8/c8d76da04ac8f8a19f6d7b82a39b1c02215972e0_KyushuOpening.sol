/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**

 * `````````.```````...`````....````....`````..........`````....````....`````....`````.....````````.
 * ```````...``````...```````..````...````.....-:/+/:-....````...````....`````....````......````````
 * ``````...``````....``````..````...````..-+syyyysyyyso/...````..````...`````....`````.....````````
 * `````....``````...``````...```...```...+yyyyys:.+syyyys:...``...````...`````...`````......```````
 * `````....``````...``````..````..```..`+yyyys/``.`.oyyyys-..```...```...`````....````......```````
 * `````....``````...`````...````..```...yyyy+.`:-.--`:syyy/...``...```....````....``````....```````
 * `````....``````...`````...````..```..`sys:`-:.```-:../sy:...``...```...`````....``````....```````
 * ```````..``````...`````...````...```..:ss+o+///////so+s+...```...```...`````....`````.....```````
 * ```````..``````....`````...````..```...-oyyyyyyyyyyyys/...```...```....`````...``````.....```````
 * ```````..``````....`````...````...````...:+ossyyyso+:....```...``.-:-.`````....``````....````````
 * ````````..``````....`````...``````..````.....-----.....````...`+so//oo:://///-``````.....```````.
 * ````````..```````....`````....`````...```````.....``````....```:-...`.--....-:`````.....````````.
 * :////:-:++-......`.....````....``````.....``````````......````../..`````....``````..../h-``````..
 * mmNNmmmmmmmmmmmmmddhysosyysyysyhddddyo+/-.............`````-/+sydhs/-.--:/+++///:::::+yhyyyhddddm
 * NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNmmmdhhhhhysoooo+oshmNNNNNNNNNNmmmNNNNNNmmmmmmmmNNNNNNNNNNN
 * NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
 *
 *                        .---.  _        _              .--.             
 *                        : .; ::_;      :_;            : .--'            
 *                        :   .'.-. .--. .-.,-.,-. .--. `. `. .-..-.,-.,-.
 *                        : :.`.: :`._-.': :: ,. :' .; : _`, :: :; :: ,. :
 *                        :_;:_;:_;`.__.':_;:_;:_;`._. ;`.__.'`.__.':_;:_;
 *                                                 .-. :                  
 *                                                 `._.'                  
 * 
 *  https://risingsun.finance/
 */

 /**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IERC165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {

  event Transfer(
    address indexed from,
    address indexed to,
    uint indexed tokenId
  );

  event Approval(
    address indexed owner,
    address indexed approved,
    uint indexed tokenId
  );

  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );

  function balanceOf(address owner) external view returns (uint balance);

  function ownerOf(uint tokenId) external view returns (address owner);

  function safeTransferFrom(
    address from,
    address to,
    uint tokenId
  ) external;

  function transferFrom(
    address from,
    address to,
    uint tokenId
  ) external;

  function approve(address to, uint tokenId) external;

  function getApproved(uint tokenId)
    external
    view
    returns (address operator);

  function setApprovalForAll(address operator, bool _approved) external;

  function isApprovedForAll(address owner, address operator)
    external
    view
    returns (bool);

  function safeTransferFrom(
    address from,
    address to,
    uint tokenId,
    bytes calldata data
  ) external;
}

interface IERC721Enumerable is IERC721 {

  function totalSupply() external view returns (uint);
  function tokenOfOwnerByIndex(address owner, uint index)
    external
    view
    returns (uint tokenId);
  function tokenByIndex(uint index) external view returns (uint);
}

interface IERC721Receiver {
  function onERC721Received(
    address operator,
    address from,
    uint tokenId,
    bytes calldata data
  ) external returns (bytes4);
}

enum Permission {
    Authorize,
    Unauthorize,
    LockPermissions,

    AdjustVariables,
    RetrieveTokens,

    MintLand
}

/**
 * Allows for contract ownership along with multi-address authorization for different permissions
 */
abstract contract RSunAuth {
    struct PermissionLock {
        bool isLocked;
        uint64 expiryTime;
    }

    address public owner;
    mapping(address => mapping(uint => bool)) private authorizations; // uint is permission index
    
    uint constant NUM_PERMISSIONS = 6; // always has to be adjusted when Permission element is added or removed
    mapping(string => uint) permissionNameToIndex;
    mapping(uint => string) permissionIndexToName;

    mapping(uint => PermissionLock) lockedPermissions;

    constructor(address owner_) {
        owner = owner_;
        for (uint i; i < NUM_PERMISSIONS; i++) {
            authorizations[owner_][i] = true;
        }

        // a permission name can't be longer than 32 bytes
        permissionNameToIndex["Authorize"] = uint(Permission.Authorize);
        permissionNameToIndex["Unauthorize"] = uint(Permission.Unauthorize);
        permissionNameToIndex["LockPermissions"] = uint(Permission.LockPermissions);
        permissionNameToIndex["AdjustVariables"] = uint(Permission.AdjustVariables);
        permissionNameToIndex["RetrieveTokens"] = uint(Permission.RetrieveTokens);
        permissionNameToIndex["MintLand"] = uint(Permission.MintLand);

        permissionIndexToName[uint(Permission.Authorize)] = "Authorize";
        permissionIndexToName[uint(Permission.Unauthorize)] = "Unauthorize";
        permissionIndexToName[uint(Permission.LockPermissions)] = "LockPermissions";
        permissionIndexToName[uint(Permission.AdjustVariables)] = "AdjustVariables";
        permissionIndexToName[uint(Permission.RetrieveTokens)] = "RetrieveTokens";
        permissionIndexToName[uint(Permission.MintLand)] = "MintLand";
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "Ownership required."); _;
    }

    /**
     * Function to require caller to be authorized
     */
    function authorizedFor(Permission permission) internal view {
        require(!lockedPermissions[uint(permission)].isLocked, "Permission is locked.");
        require(isAuthorizedFor(msg.sender, permission), string(abi.encodePacked("Not authorized. You need the permission ", permissionIndexToName[uint(permission)])));
    }

    /**
     * Authorize address for one permission
     */
    function authorizeFor(address adr, string memory permissionName) public {
        authorizedFor(Permission.Authorize);
        uint permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = true;
        emit AuthorizedFor(adr, permissionName, permIndex);
    }

    /**
     * Authorize address for multiple permissions
     */
    function authorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public {
        authorizedFor(Permission.Authorize);
        for (uint i; i < permissionNames.length; i++) {
            uint permIndex = permissionNameToIndex[permissionNames[i]];
            authorizations[adr][permIndex] = true;
            emit AuthorizedFor(adr, permissionNames[i], permIndex);
        }
    }

    /**
     * Authorize address for all permissions
     */
    function authorizeForAllPermissions(address adr) public {
        authorizedFor(Permission.Authorize);
        for (uint i; i < NUM_PERMISSIONS; i++) {
            authorizations[adr][i] = true;
        }
    }

    /**
     * Remove address' authorization
     */
    function unauthorizeFor(address adr, string memory permissionName) public {
        authorizedFor(Permission.Unauthorize);
        require(adr != owner, "Can't unauthorize owner");

        uint permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = false;
        emit UnauthorizedFor(adr, permissionName, permIndex);
    }

    /**
     * Unauthorize address for multiple permissions
     */
    function unauthorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public {
        authorizedFor(Permission.Unauthorize);
        require(adr != owner, "Can't unauthorize owner");

        for (uint i; i < permissionNames.length; i++) {
            uint permIndex = permissionNameToIndex[permissionNames[i]];
            authorizations[adr][permIndex] = false;
            emit UnauthorizedFor(adr, permissionNames[i], permIndex);
        }
    }

    /**
     * Unauthorize address for all permissions
     */
    function unauthorizeForAllPermissions(address adr) public {
        authorizedFor(Permission.Unauthorize);
        for (uint i; i < NUM_PERMISSIONS; i++) {
            authorizations[adr][i] = false;
        }
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorizedFor(address adr, string memory permissionName) public view returns (bool) {
        return authorizations[adr][permissionNameToIndex[permissionName]];
    }

    /**
     * Return address' authorization status
     */
    function isAuthorizedFor(address adr, Permission permission) public view returns (bool) {
        return authorizations[adr][uint(permission)];
    }

    /**
     * Transfer ownership to new address. Caller must be owner.
     */
    function transferOwnership(address payable adr) public onlyOwner {
        address oldOwner = owner;
        owner = adr;
        for (uint i; i < NUM_PERMISSIONS; i++) {
            authorizations[oldOwner][i] = false;
            authorizations[owner][i] = true;
        }
        emit OwnershipTransferred(oldOwner, owner);
    }

    /**
     * Get the index of the permission by its name
     */
    function getPermissionNameToIndex(string memory permissionName) public view returns (uint) {
        return permissionNameToIndex[permissionName];
    }
    
    /**
     * Get the time the timelock expires
     */
    function getPermissionUnlockTime(string memory permissionName) public view returns (uint) {
        return lockedPermissions[permissionNameToIndex[permissionName]].expiryTime;
    }

    /**
     * Check if the permission is locked
     */
    function isLocked(string memory permissionName) public view returns (bool) {
        return lockedPermissions[permissionNameToIndex[permissionName]].isLocked;
    }

    /*
     *Locks the permission from being used for the amount of time provided
     */
    function lockPermission(string memory permissionName, uint64 time) public virtual {
        authorizedFor(Permission.LockPermissions);

        uint permIndex = permissionNameToIndex[permissionName];
        uint64 expiryTime = uint64(block.timestamp) + time;
        lockedPermissions[permIndex] = PermissionLock(true, expiryTime);
        emit PermissionLocked(permissionName, permIndex, expiryTime);
    }
    
    /*
     * Unlocks the permission if the lock has expired 
     */
    function unlockPermission(string memory permissionName) public virtual {
        require(block.timestamp > getPermissionUnlockTime(permissionName) , "Permission is locked until the expiry time.");
        uint permIndex = permissionNameToIndex[permissionName];
        lockedPermissions[permIndex].isLocked = false;
        emit PermissionUnlocked(permissionName, permIndex);
    }

    event PermissionLocked(string permissionName, uint permissionIndex, uint64 expiryTime);
    event PermissionUnlocked(string permissionName, uint permissionIndex);
    event OwnershipTransferred(address from, address to);
    event AuthorizedFor(address adr, string permissionName, uint permissionIndex);
    event UnauthorizedFor(address adr, string permissionName, uint permissionIndex);
}

interface ILandCrates is IERC721Enumerable {
    function crates(uint id) external returns (uint8);
}

interface ILands is IERC721Enumerable {
    function mintLand(address _user, uint _landType, uint _landRegion) external;
}

contract KyushuOpening is RSunAuth, IERC721Receiver {
    // CONSTANTS
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // EXTERNAL
    ILandCrates public kyuCrates;
    ILands public lands;

    // METADATA
    enum LandType { Hill, Mountain, Coast }

    // EVENTS
    event CrateOpened(address indexed user, uint indexed crateId);
    
    constructor(address _kyushuCratesAdr, address _landsAdr) RSunAuth(msg.sender) {
        kyuCrates = ILandCrates(_kyushuCratesAdr);
        lands = ILands(_landsAdr);
    }

    /**
     * Allow opening Kyushu Land Crates. Creates a Land and Special Crates.
     */
    function openCrate(uint crateId) public {
        require(kyuCrates.ownerOf(crateId) == msg.sender, "Wrong owner");

        uint8 landType = kyuCrates.crates(crateId);

        // INTERACTIONS
        lands.mintLand(msg.sender, landType, 0); // 0 is Kyushu region type
        kyuCrates.safeTransferFrom(msg.sender, DEAD, crateId); // reverts on failure

        emit CrateOpened(msg.sender, crateId);
    }

    function openCrates(uint[] memory crateIds) external {
        for (uint i = 0; i < crateIds.length; i++) {
            openCrate(crateIds[i]);
        }
    }

    function retrieveTokens(address token, uint amount) external {
        authorizedFor(Permission.RetrieveTokens);
        require(IBEP20(token).transfer(msg.sender, amount), "Transfer failed");
    }

    function retrieveBNB(uint amount) external {
        authorizedFor(Permission.RetrieveTokens);
        (bool success,) = payable(msg.sender).call{ value: amount }("");
        require(success, "Failed to retrieve BNB");
    }

    function onERC721Received(address, address, uint, bytes calldata) public pure override returns (bytes4) {
        return 0x150b7a02;
    }
}