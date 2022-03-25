// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    address public owner;   // SLOT 0
    bytes32 private constant implementationPosition = keccak256("implementation.contract.diamond-alpha-bridge:2022");

    event Upgraded(address indexed implementation);
    event ProxyOwnershipTransfered(address indexed previousOwner, address indexed newOwner);

    constructor(address _impl) {
        owner = msg.sender;
        _setImplementation(_impl);
    }

    modifier onlyProxyOwner() {
        require(msg.sender == owner, "Only proxy owner");
        _;
    }

    // ===== INTERNAL FUNCTIONS ===== // 

    /**
     * @dev To store the address of implemenation contract into the storage internally
     * @param _newImplementation the address of the implementation contract
     */
    function _setImplementation(address _newImplementation) internal {
        bytes32 position = implementationPosition;
        assembly {
            sstore(position, _newImplementation)
        }
    }

    /**
     * @dev To execute the delegate call
     
     * @notice the implementation must be set to execute delegate call
     */
    function _delegatecall() internal {
        address _impl = implementation();
        require(_impl != address(0), "Implementation contract is setting to zero address");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(sub(gas(), 10000), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result 
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    // ===== GETTER FUNCTIONS ===== //

    /**
     * @dev To get the address of the implementation contract
     * @notice We load the value of `implemenationPosition` from storage using assembly
     */
    function implementation() public view returns (address impl) {
        bytes32 position = implementationPosition;
        assembly {
            impl := sload(position)
        }
    }

    // ===== PUBLIC FUNCTIONS ===== //

    /**
     * @dev To transfer the proxy's ownership
     * @param _newOwner the address of new owner 

     * @notice only proxyOwner can transfer ownership
     * @notice _newOwner must be different from zero address
     * @notice cannot transfer to the current owner
     */
    function transferProxyOwnership(address _newOwner) public onlyProxyOwner {
        require(_newOwner != address(0), "DABridgeProxy: Transfer ownership to zero address");
        require(_newOwner != owner, "DABridegeProxy: Transfer ownership to current owner");
        emit ProxyOwnershipTransfered(owner, _newOwner);
        owner = _newOwner;
    }

    /**
     * @dev To upgrade the implemenation of proxy contract
     * @param _newImplementation the address of new implementation contract

     * @notice only proxyOwner can upgrade 
     * @notice cannot upgrade to the current implementation
     */
    function upgradeTo(address _newImplementation) public onlyProxyOwner {
        address currentImplementation = implementation();
        require(currentImplementation != _newImplementation, "DABridgeProxy: Cannot upgrade to the current implementation");
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }

    fallback() external payable {
        _delegatecall();
    }

    receive() external payable {}
}