//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "./Lib.sol";
contract LibTest {    
    uint256 public haha;
    function libCall(uint256 aa)
        external
    {
       Lib.test(aa, haha);
    }


}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;


library Lib {
    function test(uint256 aa, uint256 haha)
        external
    {
       haha=aa;
    }

}