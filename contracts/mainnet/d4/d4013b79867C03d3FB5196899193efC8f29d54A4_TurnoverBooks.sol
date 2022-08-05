/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

struct Data
{
    mapping(address => uint256) userTurnover;
    mapping(uint256 => address) user;
    uint256 autoIncrement;
}

contract TurnoverBooks {

    mapping(address => Data) _data;

    address private _gate;

    address private _owner;

    address private _alternative;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyGate() {
        require(_gate == msg.sender || _owner == msg.sender, "Ownable: caller is not the gate");
        _;
    }

    modifier onlyAlternative() {
        require(_alternative == msg.sender, "Ownable: caller is not the alternative");
        _;
    }

    constructor () {
        _owner = msg.sender;
    }

    function setGate(address __gate) external onlyOwner
    {
        _gate = __gate;
    }

    function setAlternative(address __alternative) external onlyOwner
    {
        _alternative = __alternative;
    }

    function replace(address _tokenContract, address _sender, uint256 _turnover) external onlyAlternative
    {
        Data storage data = _data[_tokenContract];
        if (data.userTurnover[_sender] == 0)
        {
            data.autoIncrement++;
            data.user[data.autoIncrement] = _sender;
        }
        data.userTurnover[_sender] = _turnover;
    }

    function write(address _tokenContract, address _sender, uint256 _turnover) external onlyGate
    {
        Data storage data = _data[_tokenContract];
        if (data.userTurnover[_sender] == 0)
        {
            data.autoIncrement++;
            data.user[data.autoIncrement] = _sender;
        }
        data.userTurnover[_sender] += _turnover;
    }

    function get(address _tokenContract, address _sender) external view returns (uint256)
    {
        return _data[_tokenContract].userTurnover[_sender];
    }
}