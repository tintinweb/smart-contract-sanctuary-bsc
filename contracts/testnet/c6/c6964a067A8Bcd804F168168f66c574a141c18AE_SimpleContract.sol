// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract SimpleContract {

    function encode( bytes memory payload ) public pure returns ( bytes memory result ){
        return result = abi.encode(payload);
    }

}