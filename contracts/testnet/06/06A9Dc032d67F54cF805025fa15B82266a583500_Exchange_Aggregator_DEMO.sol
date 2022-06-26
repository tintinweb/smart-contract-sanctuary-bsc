//SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity ^0.8.0;

import "./lib_core.sol";

contract Exchange_Aggregator_DEMO is Context {

    // Version 0.2.2
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

    struct swapRoute {
        address router;
        address[] tokens;
        uint amountIn;
        uint amountOutMin; 
    }

    // Test to swap Token A with Token B on their pair with a sample forked Pancake Swap's Router.
    function swap(uint amountOutMin, swapRoute[] memory xs, string memory fnSelector, bool test) external {

        uint totalAmountOut;

        for (uint i = 0; i < xs.length; i++) {
            swapRoute memory x = xs[i];
            uint256 amountOutActual = _internal_swap(x.router, x.tokens, x.amountIn, x.amountOutMin, fnSelector);
            totalAmountOut = totalAmountOut + amountOutActual;
        }
        if (totalAmountOut < amountOutMin) {
            revert();
        }

        // emit SWAP_SUCCESS(success_, result_);
        if (test) { revert(); }
    }

    //๋ 
    //
    //

    /**
    * @dev Core, Pure, Functionals
    */

    // Test to swap Token A with Token B on their pair with a sample forked Pancake Swap's Router.
    function _internal_swap(
        address router,
        address[] memory tokens,
        uint amountIn,
        uint amountOutMin,
        string memory selector) internal 
        returns (
            uint256
        )
    {
        bytes memory payload = abi.encodeWithSignature(
            selector,
            amountIn,
            amountOutMin,
            tokens, // address[] calldata path,
            _msgSender(), // address to,
            block.timestamp + 1000// uint deadline
        );
        (bool success_, bytes memory result_) = _lowlvcall(router, payload);
        if (!success_) {
            if (result_.length < 68) revert();
            assembly {
                result_ := add(result_, 0x04)
            }
            revert(abi.decode(result_, (string)));
        }
        (,,,uint256 amountOut) = abi.decode(result_, (uint256, uint256, uint256, uint256));
        return amountOut;
    }

    // Low-Level Call to Remote Contract
    function _lowlvcall(
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