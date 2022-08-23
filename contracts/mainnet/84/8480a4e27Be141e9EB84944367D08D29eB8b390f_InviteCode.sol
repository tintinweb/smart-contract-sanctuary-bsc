/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

struct NetWork {
    uint256 number;
    uint channel;
    uint level;
    uint time;
    string code;
    address owner_;
    address super_;
}

interface Body {

    function init(address __first) external;

    function setGate(address __gate) external;

    function setChannel(address _sender, uint _channel) external;

    function getInfoFromId(uint256 _id) external view returns (NetWork memory);

    function getTotal() external view returns (uint256);

    function getTotalOfChannel(uint _channel) external view returns (uint256);

    function getInfo(address _sender) external view returns (NetWork memory);

    function getCode(address _sender) external view returns (string memory);

    function getSuper(address _sender) external view returns (address);

    function getChildrenLength(address _sender) external view returns (uint256);

    function getChildrenFrom(address _sender, uint index) external view returns (address);

    function post(address _sender, string memory _inviteCode) external returns (bool, address);
}

struct ChannelDist {
    address manager;
    uint distM;
}

contract InviteCode {

    Body private _body;
    address private _owner;
    address private _admin;

    mapping(uint => ChannelDist) _distOfChannel;
    uint channelDistD = 100;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(_admin == msg.sender || _owner == msg.sender, "Ownable: caller is not the admin");
        _;
    }

    function setAdmin(address __admin) external onlyOwner
    {
        _admin = __admin;
    }

    constructor (address __body) {
        _owner = msg.sender;
        _body = Body(__body);
    }

    function setChannel(address _sender, uint _channel) external onlyAdmin
    {
        _body.setChannel(_sender, _channel);
    }

    function setChannelManager(address _sender, uint _channel, uint _distM) external onlyAdmin
    {
        require(_body.getTotalOfChannel(_channel) > 0, "_channel invalid!");
        require(_distM >= 0 && _distM <= 100, "_distM has to be between 0 and 100!");

        _distOfChannel[_channel].manager = _sender;
        _distOfChannel[_channel].distM = _distM;
    }

    function post(string memory _inviteCode) external
    {
        address _sender = msg.sender;
        _body.post(_sender, _inviteCode);
    }

    function postAdmin(string memory _inviteCode, address _sender) external onlyAdmin
    {
        _body.post(_sender, _inviteCode);
    }

    function getTotal() external view onlyAdmin returns (uint256)
    {
        return _body.getTotal();
    }

    function getTotalOfChannel(uint _channel) external view onlyAdmin returns (uint256)
    {
        return _body.getTotalOfChannel(_channel);
    }

    function getInfoFromId(uint256 _id) external view onlyAdmin returns (
        uint256 number,
        uint channel,
        uint level,
        uint time,
        string memory code,
        address owner_,
        address super_
    )
    {
        NetWork memory info = _body.getInfoFromId(_id);
        number = info.number;
        channel = info.channel;
        level = info.level;
        time = info.time;
        code = info.code;
        owner_ = info.owner_;
        super_ = info.super_;
    }

    function getInfo(address _sender) external view returns (
        uint256 number,
        uint channel,
        uint level,
        uint time,
        string memory code,
        address owner_,
        address super_
    )
    {
        NetWork memory info = _body.getInfo(_sender);
        number = info.number;
        channel = info.channel;
        level = info.level;
        time = info.time;
        code = info.code;
        owner_ = info.owner_;
        super_ = info.super_;
    }

    function getChannelManager(uint _channel) external view returns (address manager, uint distM, uint distD)
    {
        return (_distOfChannel[_channel].manager, _distOfChannel[_channel].distM, channelDistD);
    }

    function getUserChannelManager(address _sender) external view returns (address manager, uint distM, uint distD)
    {
        uint _channel = _body.getInfo(_sender).channel;
        return (_distOfChannel[_channel].manager, _distOfChannel[_channel].distM, channelDistD);
    }

    function getCode(address _sender) external view returns (string memory)
    {
        return _body.getCode(_sender);
    }

    function getSuper(address _sender) external view returns (address)
    {
        return _body.getSuper(_sender);
    }

    function getChildrenLength(address _sender) external view returns (uint256)
    {
        return _body.getChildrenLength(_sender);
    }

    function getChildrenFrom(address _sender, uint index) external view returns (address)
    {
        return _body.getChildrenFrom(_sender, index);
    }
}