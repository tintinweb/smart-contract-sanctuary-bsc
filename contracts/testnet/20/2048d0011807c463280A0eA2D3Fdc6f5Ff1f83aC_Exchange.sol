/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface sunSwapV1 {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function getTrxToTokenInputPrice(uint256 trx_sold) external view returns (uint256);
    function getTokenToTrxInputPrice(uint256 tokens_sold) external view returns (uint256);
    function getTokenToTrxOutputPrice(uint256 trx_bought) external view returns (uint256);
    function getTrxToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256);
}

contract Exchange {
    address public  owner;
    address public  administrator;

    mapping(string => uint) configNums;
    mapping(string => address) configAdds;

    event Withdraw(address token, address user, uint amount, address to);
    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == administrator, "Permission denied");
        _;
    }
    constructor() {
        configNums["rate"] = 2;
        //configAdds["sunSwap"] = 0xA2726afbeCbD8e936000ED684cEf5E2F5cf43008;
        configAdds["sunSwap"] = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;

        owner = msg.sender;
        administrator = msg.sender;
    }

    function changeOwner(address _add) external onlyOwner {
        require(_add != address(0));
        owner = _add;
    }

    function changeAdministrator(address _add) external onlyOwner {
        require(_add != address(0));
        administrator = _add;
    }

    function setConfigNums(string calldata _str,uint _num)public onlyOwner{
        configNums[_str] = _num;
    }
     function setConfigAdds(string calldata _str,address _add)public onlyOwner{
        configAdds[_str] = _add;
    }

    function trxExchangeUSDT() public payable {
        require(msg.value > 0, "The investment amount is empty");
        sunSwapV1(configAdds["sunSwap"]).transfer(msg.sender,100000);
    }

    function usdtExchangeTrx(uint _amount) public  {
        require(_amount > 0, "The investment amount is empty");
        payable(msg.sender).transfer(_amount);
        sunSwapV1(configAdds["sunSwap"]).transfer(address(this),100000);
    }


    function withdrawToken(address _token, address _add, uint _amount) external onlyOwner {
        sunSwapV1(_token).transfer(_add, _amount);
        emit Withdraw(_token, msg.sender, _amount, _add);
    }

     receive() external payable {}

}