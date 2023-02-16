// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract split{    
    address[2] wallets;
    address owner;
    event Sent(address[2] wallets,uint value);
    
    constructor(address[2] memory _wallets) {
        wallets=_wallets;
        owner=msg.sender;
    }

    receive() external payable {
       splitValue();
    }

    function splitValue() public payable {
        bool sent1 = payable(wallets[0]).send(msg.value/2);
        require(sent1,"Send is failed");
        bool sent2 = payable(wallets[1]).send(msg.value/2);
        require(sent2,"Send is failed");
        emit Sent(wallets,msg.value);
    }

    function changeWallets(address[2] memory _wallets) external {
        require(msg.sender==owner,"Not an owner");
        wallets=_wallets;
    }

    function checkWallets() external view returns(address[2] memory) {
        return(wallets);
    }
}