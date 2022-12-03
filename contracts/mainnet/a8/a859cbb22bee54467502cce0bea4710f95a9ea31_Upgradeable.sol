/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

pragma solidity 0.5.16;


/// @title Ownable Contract
/// @author Anton Grigorev (@BaldyAsh)
contract Ownable {
    /// @notice Storage position of the owner address
    /// @dev The address of the current owner is stored in a
    /// constant pseudorandom slot of the contract storage
    /// (slot number obtained as a result of hashing a certain message),
    /// the probability of rewriting which is almost zero
    bytes32 private constant ownerPosition = keccak256("owner");

    /// @notice Contract constructor
    /// @dev Sets msg sender address as owner address
    constructor() public {
        setOwner(msg.sender);
    }

    /// @notice Check that requires msg.sender to be the current owner
    function requireOwner() internal view {
        require(msg.sender == getOwner(), "55f1136901"); // 55f1136901 - sender must be owner
    }

    /// @notice Returns contract owner address
    /// @return Owner address
    function getOwner() public view returns (address owner) {
        bytes32 position = ownerPosition;
        assembly {
            owner := sload(position)
        }
    }

    /// @notice Sets new owner address
    /// @param _newOwner New owner address
    function setOwner(address _newOwner) internal {
        bytes32 position = ownerPosition;
        assembly {
            sstore(position, _newOwner)
        }
    }

    /// @notice Transfers the control of the contract to new owner
    /// @dev msg.sender must be the current owner
    /// @param _newOwner New owner address
    function transferOwnership(address _newOwner) external {
        requireOwner();
        require(_newOwner != address(0), "f2fde38b01"); // f2fde38b01 - new owner cant be zero address
        setOwner(_newOwner);
    }
}



pragma solidity 0.5.16;

//import "./Ownable.sol";


/// @title Upgradeable contract
/// @author Anton Grigorev (@BaldyAsh)
contract Upgradeable is Ownable {
    /// @notice Storage position of the current implementation address.
    /// @dev The address of the current implementation is stored in a
    /// constant pseudorandom slot of the contract proxy contract storage
    /// (slot number obtained as a result of hashing a certain message),
    /// the probability of rewriting which is almost zero
    bytes32 private constant implementationPosition = keccak256(
        "implementation"
    );

    /// @notice Contract constructor
    /// @dev Calls Ownable contract constructor
    constructor() public Ownable() {}

    /// @notice Returns the current implementation contract address
    /// @return Implementaion contract address
    function getImplementation() public view returns (address implementation) {
        bytes32 position = implementationPosition;
        assembly {
            implementation := sload(position)
        }
    }

    /// @notice Sets new implementation contract address as current
    /// @param _newImplementation New implementation contract address
    function setImplementation(address _newImplementation) public {
        requireOwner();
        require(_newImplementation != address(0), "d784d42601"); // d784d42601 - new implementation must have non-zero address
        address currentImplementation = getImplementation();
        require(currentImplementation != _newImplementation, "d784d42602"); // d784d42602 - new implementation must have new address
        bytes32 position = implementationPosition;
        assembly {
            sstore(position, _newImplementation)
        }
    }

    /// @notice Sets new implementation contract address and call its initializer.
    /// @dev New implementation call is a low level delegatecall.
    /// @param _newImplementation the new implementation address.
    /// @param _newImplementaionCallData represents the msg.data to bet sent through the low level delegatecall.
    /// This parameter may include the initializer function signature with the needed payload.
    function setImplementationAndCall(
        address _newImplementation,
        bytes calldata _newImplementaionCallData
    ) external payable {
        setImplementation(_newImplementation);
        if (_newImplementaionCallData.length > 0) {
            (bool success, ) = address(this).call.value(msg.value)(
                _newImplementaionCallData
            );
            require(success, "e9c8588d01"); // e9c8588d01 - delegatecall has failed
        }
    }
}

pragma solidity 0.5.16;

//import "./Upgradeable.sol";


/// @title Upgradeable Proxy Contract
/// @author Anton Grigorev (@BaldyAsh)
contract Proxy is Upgradeable {
    /// @notice Contract constructor
    /// @dev Calls Upgradable contract constructor
    constructor() public Upgradeable() {}

    /// @notice Performs a delegatecall to the implementation contract.
    /// @dev Fallback function allows to perform a delegatecall to the given implementation.
    /// This function will return whatever the implementation call returns
    function() external payable {
        require(msg.data.length > 0, "9d96e2df01"); // 9d96e2df01 - calldata must not be empty
        address _impl = getImplementation();
        assembly {
            // The pointer to the free memory slot
            let ptr := mload(0x40)
            // Copy function signature and arguments from calldata at zero position into memory at pointer position
            calldatacopy(ptr, 0x0, calldatasize)
            // Delegatecall method of the implementation contract, returns 0 on error
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0x0, 0)
            // Get the size of the last return data
            let size := returndatasize
            // Copy the size length of bytes from return data at zero position to pointer position
            returndatacopy(ptr, 0x0, size)
            // Depending on result value
            switch result
                case 0 {
                    // End execution and revert state changes
                    revert(ptr, size)
                }
                default {
                    // Return data with length of size at pointers position
                    return(ptr, size)
                }
        }
    }
}