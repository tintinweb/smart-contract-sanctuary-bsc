/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

contract test{
    function isAssert(uint256 a, uint256 b) public returns(uint256 c) {
        assert(a + b != 0);
        c = a + b;
    }
    // 382 gas
    function isRequire(uint256 a, uint256 b) public returns(uint256 c) {
    require(a + b != 0);
    c = a + b;
    }

}