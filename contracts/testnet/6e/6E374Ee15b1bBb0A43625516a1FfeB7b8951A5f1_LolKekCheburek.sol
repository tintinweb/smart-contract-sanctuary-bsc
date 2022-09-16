/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

pragma solidity >=0.4.25 <0.9.0;

contract LolKekCheburek {
    uint256 public number;
    address public marketingWallet;

    constructor() {
        number = 0;
        marketingWallet = 0x902cd52FB44A1D2559F6bF576CEBe8c075cdbdE8;
    }

    function increment(uint256 _value) public {
        number = number + _value;
    }

    function reset() public {
        number = 0;
    }
}