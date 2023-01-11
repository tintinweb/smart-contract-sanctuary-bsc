//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;



contract ProxyContract_noAPI {
    address public implementation;
    address public admin;
    address public owner;
    int256  public sum;
    address public gw;

    event RequestData(bytes32 indexed requestData, uint256 data);

    constructor() {
        admin = msg.sender;

    }
    modifier onlyOwner {
        require(msg.sender == admin, "not the owner");
        _;
    }


   function _delegate(address _implementation) internal virtual {

        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }


    fallback() external payable {
        //call the api, we need to send the tx info, need to check how

        _delegate(implementation);
    }

    receive() external payable {
         _delegate(implementation);
    }

    function upgradeTo(address _implementation) external {
        require(msg.sender == admin, "not authorized");
        implementation = _implementation;
    }
}