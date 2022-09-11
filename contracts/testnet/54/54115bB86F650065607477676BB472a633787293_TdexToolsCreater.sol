// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "TdexToolsOriginal.sol";

struct Info {
    address contract_;
    address sender_;
    string name_;
    uint time_;
}

contract TdexToolsCreater {

    mapping(address => address[]) _record;

    mapping(address => Info) _info;

    address private _owner;

    address private _priceMachine;

    address private _tdex;

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

    function createTools(string memory name_, address trader) external payable {
        require(msg.value >= 1e17, "The startup GAS fee is insufficient");
        TdexToolsOriginal tools = new TdexToolsOriginal();
        tools.setOwnership(msg.sender);
        tools.setTraders(trader);
        _record[msg.sender].push(address(tools));
        _info[address(tools)] = Info(address(tools), msg.sender, name_, block.timestamp);
        TransferHelper.safeTransferETH(trader, msg.value);
    }

    function getMyToolsCount(address sender_) external view returns (uint) {
        return _record[sender_].length;
    }

    function getMyToolsAtIndex(address sender, uint index) external view returns (address contract_, address sender_, string memory name_, uint time_)
    {
        Info storage info =  _info[_record[sender][index]];
        contract_ = info.contract_;
        sender_ = info.sender_;
        name_ = info.name_;
        time_ = info.time_;
    }
}