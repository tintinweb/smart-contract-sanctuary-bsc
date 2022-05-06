/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

pragma solidity ^0.6.6;

interface YiToken {
    function setMainPool(address pool_) external;
    function mint(address dest_) external;
}

contract ContractManager {
    address mainToken;
    function setTokenMain(address _addr) public {
        require(_addr != address(0), "token is invali");
        mainToken = _addr;
        // YiToken(_addr).setMainPool(address(this));
    }

    function allocation () public {
        require(mainToken != address(0), "token is invali");
        YiToken(mainToken).mint(address(this));
    }

}