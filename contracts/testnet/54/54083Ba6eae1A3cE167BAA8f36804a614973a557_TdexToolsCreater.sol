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

    constructor(){

    }

    function createTools(string memory name_) external {
        TdexToolsOriginal tools = new TdexToolsOriginal();
        tools.setOwnership(msg.sender);
        _record[msg.sender].push(address(tools));
        _info[address(tools)] = Info(address(tools), msg.sender, name_, block.timestamp);
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