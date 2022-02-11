/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.11;


contract TransferTool  {

     address payable public owner;

    //添加payable,支持在创建合约的时候，value往合约里面传eth
    
    constructor() payable {
         owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

  
      //直接转账
    function transferEth(address _to) payable public onlyOwner returns (bool){

        require(_to != address(0));
        payable(_to).transfer(msg.value);

        return true;

    }


    //value往合约里面传eth，注意该value最终平分发给所有账户
    function transferEthsAvg(address[] memory _tos) public payable onlyOwner returns (bool) {

        require(_tos.length > 0);

        uint avgValue = msg.value / _tos.length;

        for(uint i=0;i<_tos.length;i++){

            payable(_tos[i]).transfer(avgValue);

        }

        return true;

    }

    // 根据配额发送ETH
    function transferEths(address[] memory _tos,uint256[] memory values) payable public onlyOwner returns (bool) {
        require(_tos.length > 0,"tos cannot be empty!");

        require(_tos.length == values.length,"tos length must equal to values length!");

        uint  totalTransferValue;

        for (uint i=0;i<values.length;i++) {
            totalTransferValue += values[i];
        }
        require(msg.value >= totalTransferValue,"payable value must greater than values!");

        for(uint i=0;i<_tos.length;i++){

            payable(_tos[i]).transfer(values[i]);

        }

        return true;

    }

    function getBalance() public view returns (uint) {
        return address(this).balance;

    }

    // 充值
    function deposit() payable public {

    }

    // 提走ETH
   function withdraw() public {
        // get the amount of Ether stored in this contract
        uint amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = owner.call{value: amount}(""); 
        require(success, "Failed to send Ether");
    }


    

    function transferTokensAvg(address _tokenAddr,address[] memory _tos,uint v) public onlyOwner {
        
        require(_tos.length > 0);
       
        for(uint i=0;i<_tos.length;i++){  
            (bool success, ) = _tokenAddr.call(abi.encodeWithSignature("transferFrom(address,address,uint256)",msg.sender, _tos[i],v));
            require(success, "Failed to send token");
        }

    }


    function transferTokens(address _tokenAddr,address[] memory _tos,uint256[] memory values) public onlyOwner {
        
        require(_tos.length > 0);
        
        require(values.length > 0);
       
        require(values.length == _tos.length,"tos length must equal to values length!");
       
        for(uint i=0;i<_tos.length;i++){
            (bool success, ) = _tokenAddr.call(abi.encodeWithSignature("transferFrom(address,address,uint256)",msg.sender,_tos[i],values[i]));
            require(success, "Failed to send token");

        }

    }

}