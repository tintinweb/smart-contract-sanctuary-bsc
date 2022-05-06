/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.4;

interface ITest{
    function currentId() external view returns(uint256);
    function mint(address,uint256) external;
}
contract Test is ITest{
    uint256 public override currentId; 
    event Mint(address to, uint256 amount, uint256 currentid );
    function mint(address to, uint256 amount) external override {
        currentId+=amount;
        emit Mint(to,amount,currentId);
    }
}

contract Test2 {
    address public test;

    event ClaimChest(address to, uint256 amount, uint256 currentId);

    constructor(
        address _test
    ){
        test=_test;
    }
    function mint(uint256 amount) public {
       _mint(amount);
       uint256 temp = ITest(test).currentId();
       emit ClaimChest(msg.sender,amount,temp);
    }
    function _mint(uint256 amount) private {
         ITest(test).mint(msg.sender, amount);
    }

}