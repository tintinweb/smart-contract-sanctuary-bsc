pragma solidity ^0.5.0;

import "../book-room/BaseProxy.sol";

contract PriceProxy is BaseProxy {
    constructor(address gov) public BaseProxy(gov) {}
}

pragma solidity ^0.5.0;

contract BaseProxy {
    bytes32 private constant LOGIC_ADDR_POSITION = keccak256("org.velo.logic.address");
    bytes32 private constant PROXY_OWNER_POSITION = keccak256("org.velo.proxy.owner");

    modifier onlyProxyOwner() {
        require(msg.sender == getProxyOwner(), "caller must be proxy owner");
        _;
    }

    constructor(address owner) public {
        _setProxyOwner(owner);
    }

    function transferOwnership(address newOwner) public onlyProxyOwner {
        require(newOwner != address(0), "newOwner must not be address(0)");
        _setProxyOwner(newOwner);
    }

    function upgradeTo(address newLogic) public onlyProxyOwner {
        _upgradeTo(newLogic);
    }

    function getProxyOwner() public view returns (address owner) {
        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            owner := sload(position)
        }
    }

    function initialize(address logic, bytes memory data) public payable {
        require(getLogic() == address(0), "logic address must be address(0)");
        _setLogic(logic);
        if(data.length > 0) {
            (bool success,) = logic.delegatecall(data);
            require(success, "delegatecall must return success");
        }
    }

    function getLogic() public view returns (address logic) {
        bytes32 position = LOGIC_ADDR_POSITION;
        assembly {
            logic := sload(position)
        }
    }

    function () payable external {
        address logic = getLogic();
        require(logic != address(0), "logic contract must not point to address(0)");
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, logic, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function _upgradeTo(address newLogic) private {
        address currentLogic = getLogic();
        require(currentLogic != newLogic, "logic must be pointed to the new address");
        _setLogic(newLogic);
    }

    function _setLogic(address newLogic) private {
        bytes32 position = LOGIC_ADDR_POSITION;
        assembly {
            sstore(position, newLogic)
        }
    }

    function _setProxyOwner(address newOwner) private {
        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            sstore(position, newOwner)
        }
    }
}