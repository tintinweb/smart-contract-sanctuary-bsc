//SPDX-License-Identifier: MIT-open-group
pragma solidity ^0.8.7;
import "./Diamond.sol";
import "./interfaces/IDiamondLoupe.sol";
import "./interfaces/IDiamondCut.sol";


interface iApp {
    function initialize(uint64 _poolId, address _beacon, string memory _exchangeName) external payable;
    function updateFacets(IDiamondCut.FacetCut[] memory iFC) external;
}

interface prBeacon {
    struct sExchangeInfo {
        address chefContract;
        address routerContract;
        address rewardToken;
        address intermediateToken;
        address baseToken;
        string pendingCall;
        string contractType_solo;
        string contractType_pooled;
        bool psV2;
    }
    function getExchangeInfo(string memory _name) external view returns (sExchangeInfo memory);
    function getExchange(string memory _exchange) external returns(address);
    function getAddress(string memory _user) external returns(address);
}

contract DiamondFactory {
    address public beaconContract;
    mapping (address=>bool) adminUsers;
    mapping (address=>bool) godUsers;

    mapping (address => address[]) public proxyContracts;
    address[] public proxyContractsUsers;

    event NewProxy(address proxy, address user);
    bytes32 public constant DEPLOYER = keccak256("DEPLOYER");
    
    bool public paused;


    modifier adminUser {
        require(adminUsers[msg.sender] == true,"Locked function");
        _;
    }

    modifier godUser {
        require(godUsers[msg.sender] == true, "Locked function");
        _;
    }

    ///@notice Initialize the proxy factory contract
    ///@param _beacon the address of the beacon contract
    constructor (address _beacon, address _godUser, address _adminUser) {
        require(_beacon != address(0), "Beacon Contract required");
        beaconContract = _beacon;
        adminUsers[_adminUser] = true;
        adminUsers[_godUser] = true;

        godUsers[_godUser] = true;
    }

    ///@notice Sets the address of the beacon contract
    ///@param _sourceAddr the address of the source diamond contract
    function setSourceAddress(address _sourceAddr) public godUser {
        beaconContract = _sourceAddr;
    }

    ///@notice Sets the address of the beacon contract
    ///@dev call when beacon contract gets updated
    ///@param _beaconContract the address of the beacon contract
    function setBeacon(address _beaconContract) public godUser {
        beaconContract = _beaconContract;
    }



    ///@notice Allows admin to add an existing proxy contract to the list of proxy contracts for a user
    ///@param _proxyContract the address of the proxy contract
    ///@param _user the address of the user
    function addProxy(address _proxyContract, address _user) public adminUser {
        require(_proxyContract != address(0), "Proxy Contract required");
        require(_user != address(0), "User required");
        if (proxyContracts[msg.sender].length == 0) proxyContractsUsers.push(msg.sender);
        proxyContracts[_user].push(_proxyContract);
    }

    ///@notice Allows admin to add multiple  proxy contracts to the list of proxy contracts for a user
    ///@param _proxyContract the array of address for proxy contracts
    ///@param _user the address of the user
    function addProxyArray(address[] calldata _proxyContract, address _user) public adminUser {
        require(_proxyContract.length >0, "Proxy Contract required");
        require(_user != address(0), "User required");
        if (proxyContracts[msg.sender].length == 0) proxyContractsUsers.push(msg.sender);
        for (uint i = 0; i < _proxyContract.length; i++) {
            proxyContracts[_user].push(_proxyContract[i]);
        }
    }

    ///@notice Returns the last proxy contract created (or added) for a specific user
    ///@param _user the address of the user
    ///@return the address of the proxy contract
    function getLastProxy(address _user) public view returns (address) {
        require(_user != address(0), "User required");
        return proxyContracts[_user][proxyContracts[_user].length - 1];
    }

    ///@notice Gets bytecode of proxyContract
    ///@return the bytecode of the proxy contract
    function getBytecode() private pure returns (bytes memory) {
        bytes memory result = abi.encodePacked(type(Diamond).creationCode);
        return result;
    }

    
    ///@notice Creates a new proxy contract for a specific exchange and pool. 
    ///@dev Proxy contract is owned by calling user
    ///@dev for Solo contracts, only one proxy contract is needed unless custom logic contract is needed
    ///@param _pid the pool id
    ///@param _exchange the name of the exchange
    ///@return the address of the proxy contract
    function initialize(uint64  _pid, string memory _exchange, uint poolType, uint _salt) public payable adminUser returns (address) {   
        require(paused == false, "Proxy Factory is paused");     
        require(beaconContract != address(0), "Beacon Contract required");
        require(bytes(_exchange).length > 0,"Exchange Name cannot be empty");
        require(_salt > 0, "Salt must be provided");
        require(poolType > 0,"OOPS");

        prBeacon.sExchangeInfo memory exchangeInfo = prBeacon(beaconContract).getExchangeInfo(_exchange);
        require(exchangeInfo.chefContract != address(0), "Chef Contract required");

        address sourceAddr = prBeacon(beaconContract).getExchange(exchangeInfo.contractType_pooled);

        address proxy = _clone(sourceAddr,_salt);

        if (proxyContracts[msg.sender].length == 0) proxyContractsUsers.push(msg.sender);
        proxyContracts[msg.sender].push(address(proxy));

        IDiamondLoupe.Facet[] memory fc = IDiamondLoupe(address(sourceAddr)).facets();
        require(fc.length > 0, "No facets found");


        IDiamondCut.FacetCut[] memory iFC = new IDiamondCut.FacetCut[](fc.length);

        for (uint i=0; i < fc.length; i++) {
            iFC[i].facetAddress = fc[i].facetAddress;
            iFC[i].action = IDiamondCut.FacetCutAction.Add;
            iFC[i].functionSelectors = fc[i].functionSelectors;
        }

        Diamond.DiamondArgs memory _args;
        _args.owner = address(this);
        Diamond(payable(proxy)).initialize(iFC, _args);
        
        emit NewProxy(address(proxy), msg.sender);

        iApp(address(proxy)).initialize{value:msg.value}(_pid, beaconContract, _exchange);    
        
        return address(proxy);
    }


    function updateFacets(IDiamondCut.FacetCut[] memory iFC) external godUser {    
        address sourceAddr = prBeacon(beaconContract).getExchange("MULTIEXCHANGEPOOLED");

        for (uint i = 0;i<proxyContractsUsers.length;i++) {
            if (proxyContracts[proxyContractsUsers[i]].length > 0) {
                iApp(sourceAddr).updateFacets(iFC);
                for (uint t = 0; t < proxyContracts[proxyContractsUsers[i]].length;t++) {
                    address _c =  proxyContracts[proxyContractsUsers[i]][t];
                    iApp(_c).updateFacets(iFC);
                }
            }

        }
    }

    ///@notice generates an address of a new proxy contract
    ///@dev used in front end
    ///@param _salt the salt value for the address
    ///@return the address of the proxy contract
    function getAddress(uint _salt) public view returns (address)
    {
        require(_salt > 0, "Salt must be provided");
        bytes32 newsalt = keccak256(abi.encodePacked(_salt,msg.sender));

        bytes memory bytecode = getBytecode();
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), newsalt, keccak256(bytecode))
        );

        return address(uint160(uint(hash)));
    }    

    ///@notice adds new user to administrator role
    ///@param _user the address of the user

    function addAdmin(address _user) public godUser {
        adminUsers[_user] = true;
    }

    ///@notice removes user from administrator role
    ///@param _user the address of the user
    function removeAdmin(address _user) public godUser {
        adminUsers[_user] = false;
    }

    function updateGodUser(address _user, bool _state) public godUser {
        require(_user != msg.sender, "Can't modify self");
        godUsers[_user] = _state;
    }

    ///@notice Clones a proxy contract
    ///@param a the address of the source contract
    ///@param salt salt value for the address
    ///@return addr the address of the proxy contract

    function _clone(address a, uint256 salt) internal returns (address) {
        address retval;
        assembly {
        mstore(0x0, or(0x5880730000000000000000000000000000000000000000803b80938091923cF3, mul(a, 0x1000000000000000000)))
        retval := create2(0, 0, 0x20, salt)
        if iszero(extcodesize(retval)) {
            revert(0, 0)
        }
        }
        return retval;
    }

    ///@notice returns list of contracts for a specific user
    ///@param _addr the address of the user
    ///@return the list of contracts
    function returnContracts(address _addr) public view returns (address[] memory){
        return proxyContracts[_addr];
    }

    ///@notice Allow admin to pause deposits
    ///@dev Just flips the status, no direct allowance of setting
    function pause() public godUser {
        paused = !paused;
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

import "../interfaces/IDiamondCut.sol";

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint16 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint16 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        // maps function selector to the facet address and
        // the position of the selector in the facetFunctionSelectors.selectors array
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        // maps facet addresses to function selectors
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        // facet addresses
        address[] facetAddresses;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
        // address of the source diamond
        address diamondFactory;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        address _owner =  diamondStorage().contractOwner;
        require(msg.sender == _owner, "LibDiamond: Must be contract owner");
    }

    function setDiamondFactory(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.diamondFactory;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function diamondFactory() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().diamondFactory;
    }

    function enforceIsDiamondFactory() internal view {
        require(msg.sender == diamondStorage().diamondFactory, "LibDiamond: Must be Diamond Factory");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // uint16 selectorCount = uint16(diamondStorage().selectors.length);
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        uint16 selectorPosition = uint16(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            enforceHasContractCode(_facetAddress, "LibDiamondCut: New facet has no code");
            ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = uint16(ds.facetAddresses.length);
            ds.facetAddresses.push(_facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress == address(0), "LibDiamondCut: Can't add function that already exists");
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(selector);
            ds.selectorToFacetAndPosition[selector].facetAddress = _facetAddress;
            ds.selectorToFacetAndPosition[selector].functionSelectorPosition = selectorPosition;
            selectorPosition++;
        }
    }

    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        uint16 selectorPosition = uint16(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            enforceHasContractCode(_facetAddress, "LibDiamondCut: New facet has no code");
            ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = uint16(ds.facetAddresses.length);
            ds.facetAddresses.push(_facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress != _facetAddress, "LibDiamondCut: Can't replace function with same function");
            removeFunction(oldFacetAddress, selector);
            // add function
            ds.selectorToFacetAndPosition[selector].functionSelectorPosition = selectorPosition;
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(selector);
            ds.selectorToFacetAndPosition[selector].facetAddress = _facetAddress;
            selectorPosition++;
        }
    }

    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        require(_facetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            removeFunction(oldFacetAddress, selector);
        }
    }

    function removeFunction(address _facetAddress, bytes4 _selector) internal {
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
        // an immutable function is a function defined directly in a diamond
        require(_facetAddress != address(this), "LibDiamondCut: Can't remove immutable function");
        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds.selectorToFacetAndPosition[_selector].functionSelectorPosition;
        uint256 lastSelectorPosition = ds.facetFunctionSelectors[_facetAddress].functionSelectors.length - 1;
        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds.facetFunctionSelectors[_facetAddress].functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[selectorPosition] = lastSelector;
            ds.selectorToFacetAndPosition[lastSelector].functionSelectorPosition = uint16(selectorPosition);
        }
        // delete the last selector
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[lastFacetAddressPosition];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds.facetFunctionSelectors[lastFacetAddress].facetAddressPosition = uint16(facetAddressPosition);
            }
            ds.facetAddresses.pop();
            delete ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
        }
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title ERC-173 Contract Ownership Standard
///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
/* is ERC165 */
interface IERC173 {
    /// @dev This emits when ownership of a contract changes.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Get the address of the owner
    /// @return owner_ The address of the owner.
    function owner() external view returns (address owner_);

    /// @notice Set the address of the new owner of the contract
    /// @dev Set _newOwner to address(0) to renounce any ownership.
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

// A loupe is a small magnifying glass used to look at diamonds.
// These functions look at diamonds
interface IDiamondLoupe {
    /// These functions are expected to be called frequently
    /// by tools.

    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return facets_ Facet
    function facets() external view returns (Facet[] memory facets_);

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external view returns (address[] memory facetAddresses_);

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
* 
* Implementation of a diamond.
/******************************************************************************/

import "./libraries/LibDiamond.sol";
import "./interfaces/IDiamondLoupe.sol";
import "./interfaces/IDiamondCut.sol";
import "./interfaces/IERC173.sol";
import "./interfaces/IERC165.sol";

contract Diamond {
    // more arguments are added to this struct
    // this avoids stack too deep errors

    struct DiamondArgs {
        address owner;
    }

    constructor(IDiamondCut.FacetCut[] memory _diamondCut, DiamondArgs memory _args) payable {
        initialize(_diamondCut, _args);        
    }

    function initialize(IDiamondCut.FacetCut[] memory _diamondCut, DiamondArgs memory _args) public {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.facetAddresses.length == 0, "Diamond already initialized");

        LibDiamond.diamondCut(_diamondCut, address(0), new bytes(0));

        LibDiamond.setContractOwner(_args.owner);

        // adding ERC165 data
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        // require(ds.facetAddresses.length > 0 , "Diamond not initialized");
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        require(facet != address(0), "Diamond: Function does not exist");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    receive() external payable {}
}