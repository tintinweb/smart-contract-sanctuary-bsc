//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract HunterSale {      
    address public saleContractAddress;
    address public owner;
    uint256 public gasLimit = 1 * 10**16; //0.01 BNB
    uint256 public amountBuy = 1 * 10**16; //0.01 BNB

    constructor(address _saleContract, address _owner) {        
        saleContractAddress = _saleContract;
        owner = _owner;
    }

    function setSaleContract(address _saleContract) public {
        require(msg.sender == owner);
        saleContractAddress = _saleContract;
    }

    function setGasLimit(uint256 _gas) public {
        require(msg.sender == owner);
        gasLimit = _gas;
    }   

    function setAmountBuy(uint256 _amount) public {
        require(msg.sender == owner);
        amountBuy = _amount;
    }

    function contribute() public payable {
        require(msg.sender == owner);
        bytes memory payload = abi.encodeWithSignature("contribute()");        
        (bool success, ) = address(saleContractAddress).call{gas: gasLimit, value: amountBuy}(payload);
        require(success, "fail to call function in master contract"); 
    }

    receive() external payable {}
}