/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract calculator {
    uint256 public result;

    function addition (uint256 a,uint256 b) public {
        result = a + b ;
    }

    function subtraction (uint256 a,uint256 b) public {
        require(a >= b," a is less than b");
        result = a - b ;
    }

    function multiplication (uint256 a,uint256 b) public {
        result = a * b ;
    }

        function mudulous (uint256 a,uint256 b) public {
        result = a % b ;
    }
            function division (uint256 a,uint256 b) public {
        result = a / b ;
    }
}