// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./LargeArray.sol";

struct Info {
    address from;
    address to;
    uint256 amount;
    uint time;
}

struct Data {
    uint256 autoId;
    mapping(uint256 => Info) record;
    mapping(address => LargeArray) allList;
    mapping(address => LargeArray) inList;
    mapping(address => LargeArray) outList;
}

contract TransferRecord {

    address private _owner;

    mapping(address => bool) _adminMap;

    mapping(address => bool) _operatorMap;

    mapping(address => Data) _data;


    constructor(){
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(_owner == msg.sender || _adminMap[msg.sender] == true, "Ownable: caller is not the admin");
        _;
    }

    modifier onlyOperator() {
        require(_adminMap[msg.sender] == true || _operatorMap[msg.sender] == true, "Ownable: caller is not the operator");
        _;
    }

    function addAdmin(address __admin) external onlyOwner
    {
        if (_adminMap[__admin] == false)
        {
            _adminMap[__admin] = true;
        }
    }

    function removeAdmin(address __admin) external onlyOwner
    {
        if (_adminMap[__admin] == true)
        {
            delete _adminMap[__admin];
        }
    }

    function addOperator(address __operator) external onlyAdmin
    {
        if (_operatorMap[__operator] == false)
        {
            _operatorMap[__operator] = true;
        }
    }

    function removeOperator(address __operator) external onlyAdmin
    {
        if (_operatorMap[__operator] == true)
        {
            delete _operatorMap[__operator];
        }
    }

    function insert(address __contract, address __from, address __to, uint256 __amount) external onlyOperator
    {
        Data storage data = _data[__contract];
        data.autoId++;
        uint256 id = data.autoId;
        data.record[id] = Info(__from, __to, __amount, block.timestamp);
        LargeArrayHelper.push(data.outList[__from], id);
        LargeArrayHelper.push(data.allList[__from], id);
        LargeArrayHelper.push(data.inList[__to], id);
        LargeArrayHelper.push(data.allList[__to], id);
    }

    function All(address __contract, address __sender, uint256 start, uint256 count) external view returns (Info[] memory)
    {
        Data storage data = _data[__contract];
        Info[] memory list;
        uint256[] memory ids = LargeArrayHelper.toReverseList(data.allList[__sender], start, start + count);
        if (ids.length > 0)
        {
            list = new Info[](ids.length);
            for (uint256 i=0; i<ids.length; i++)
            {
                list[i] = data.record[ids[i]];
            }
        }
        return list;
    }

    function In(address __contract, address __sender, uint256 start, uint256 count) external view returns (Info[] memory)
    {
        Data storage data = _data[__contract];
        Info[] memory list;
        uint256[] memory ids = LargeArrayHelper.toReverseList(data.inList[__sender], start, start + count);
        if (ids.length > 0)
        {
            list = new Info[](ids.length);
            for (uint256 i=0; i<ids.length; i++)
            {
                list[i] = data.record[ids[i]];
            }
        }
        return list;
    }

    function Out(address __contract, address __sender, uint256 start, uint256 count) external view returns (Info[] memory)
    {
        Data storage data = _data[__contract];
        Info[] memory list;
        uint256[] memory ids = LargeArrayHelper.toReverseList(data.outList[__sender], start, start + count);
        if (ids.length > 0)
        {
            list = new Info[](ids.length);
            for (uint256 i=0; i<ids.length; i++)
            {
                list[i] = data.record[ids[i]];
            }
        }
        return list;
    }
}