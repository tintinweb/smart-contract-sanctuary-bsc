// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "Robot.sol";


interface RobotManager {

    function insert(string memory __name, address __robot, address __sender, address __trader, uint _version) external;
}


contract RobotCreater {

    address private _owner;

    address private _priceMachine;

    address private _tdex;

    address public _robotMananger;

    fallback() external
    {

    }

    receive() external payable
    {
        if (msg.value > 0)
        {

        }
    }

    constructor(){
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setRobotMananger(address __robotMananger) external onlyOwner
    {
        _robotMananger = __robotMananger;
    }

    function setPriceMachine(address __priceMachine) external onlyOwner
    {
        _priceMachine = __priceMachine;
    }

    function getPriceMachine() external view returns (address)
    {
        return _priceMachine;
    }

    function setTdex(address __tdex) external onlyOwner
    {
        _tdex = __tdex;
    }

    function getTdex() external view returns (address)
    {
        return _tdex;
    }

    function createTools(string memory name_, address tokenContract_, address trader_) external payable {
        require(msg.value >= 1e17, "The startup GAS fee is insufficient");
        Robot tools = new Robot();
        tools.setOwnership(msg.sender);
        tools.setTrader(trader_);
        tools.setTokenContract(tokenContract_);
        RobotManager(_robotMananger).insert(name_, address(tools), msg.sender, trader_, 1);
        TransferHelper.safeTransferETH(trader_, msg.value);
    }
}