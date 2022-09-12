/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

struct Info {
    string name;
    address robot;
    address sender;
    address trader;
    uint version;
    uint time;
}

interface Robot {

    function getTokenContract() external view returns (address);
}

contract RobotManager {

    mapping(address => address[]) _record;

    mapping(address => Info) _info;

    address private _owner;

    address[] private _adminList;

    mapping(address => bool) _adminMap;

    constructor(){
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(_adminMap[msg.sender] == true, "Ownable: caller is not the admin");
        _;
    }

    function addAdmin(address __admin) external onlyOwner
    {
        if (_adminMap[__admin] == false)
        {
            _adminMap[__admin] = true;

            {
                bool added = false;
                for (uint i=0; i<_adminList.length;i++)
                {
                    if (_adminList[i] == address(0))
                    {
                        _adminList[i] = __admin;
                        added = true;
                    }
                }
                if (added == false)
                {
                    _adminList.push(__admin);
                }
            }
        }
    }

    function removeTraders(address __admin) external onlyAdmin
    {
        if (_adminMap[__admin] == true)
        {
            delete _adminMap[__admin];

            {
                for (uint i=0; i<_adminList.length; i++)
                {
                    if (_adminList[i] == __admin)
                    {
                        _adminList[i] = address(0);
                    }
                }
            }
        }
    }

    function insert(string memory __name, address __robot, address __sender, address __trader, uint _version) external payable {

        _record[__sender].push(__robot);
        _info[__robot] = Info(__name, __robot, __sender, __trader, _version, block.timestamp);
    }

    function getMyRobotCount(address sender) external view returns (uint) {
        return _record[sender].length;
    }

    function getMyRobotAtIndex(address sender, uint index) external view returns (string memory name_, address robot_, address sender_, address trader_, uint version_, uint time_, address tokenContract_)
    {
        Info storage info =  _info[_record[sender][index]];
        name_ = info.name;
        robot_ = info.robot;
        sender_ = info.sender;
        trader_ = info.trader;
        version_ = info.version;
        time_ = info.time;
        tokenContract_ = Robot(robot_).getTokenContract();
    }
}