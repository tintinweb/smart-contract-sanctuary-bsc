//SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity ^0.8.0;

import "./lib_core.sol";

contract Exchange_Aggregator_DEMO1 is Context {

    // Version 0.1.0
    /**
    * @dev Structs
    */


    /**
    * @dev Data Structures and Global Variables
    */

    //
    // Contract owner address.
    //
    address private $owner;

    //
    // Contract mark.
    //
    string public $mark;

    //
    // Contract activeness status.
    //
    bool public $active = true;

    /**
    * @dev Constructor
    */

    // Simply setup contract owner by its deployer and its mark
    constructor(
        string memory mark
    ) {
        $owner = msg.sender;
        $mark = mark;
    }


    /**
    * @dev Events
    */

    event SWAP_SUCCESS(bool success, bytes result);


    /**
    * @dev Public Functionalities
    */

    // Test to swap Token A with Token B on their pair with a sample forked Pancake Swap's Router.
    function swap(address router/* , bytes memory payload */, uint amountIn, uint amountOutMin) external {
        address[] memory addresses = new address[](2);
        addresses[0] = address(0x1379fF160F8102603c6B1D8DB3E2694cEbd124cB);
        addresses[1] = address(0x49dAE028dD455aca60eD7A183633e88c064D49fe);

        bytes memory payload = abi.encodeWithSignature(
            "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
            amountIn, // uint amountIn,
            amountOutMin, // uint amountOutMin,
            addresses, // address[] calldata path,
            _msgSender(), // address to,
            block.timestamp + 1000// uint deadline
        );
        (bool success_, bytes memory result_) = _rllcall(router, payload);
        emit SWAP_SUCCESS(success_, result_);
    }

    //๋ 
    //
    //

    /**
    * @dev Core, Pure, Functionals
    */

    // Remote Contract Low-Level Call
    function _rllcall(
        address _contract,
        bytes memory payload
    ) internal returns (bool, bytes memory) {
        {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success_, bytes memory result_) = address(_contract).delegatecall(payload);
            return (success_, result_);
        }
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
    assembly {
        addr := mload(add(bys, 16))
    }
}
    
}