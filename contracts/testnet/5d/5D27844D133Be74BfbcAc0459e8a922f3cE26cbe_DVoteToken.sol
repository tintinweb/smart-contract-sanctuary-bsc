// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./ShortArray.sol";

interface ERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface TdexTokenManager {

    function insertToken(address _tokenContract) external returns (bool);

    function setTokenIconUrl(address __tokenContract, string memory __url) external;
}

enum ToAuditStatus { Reviewing, Through, NotThrough, Finished } // 枚举

struct TokenInfo {
    string name;
    string symbol;
    string url;
    uint8 decimals;
    ToAuditStatus status;
    address sender;
}

contract DVoteToken {

    address _gate;
    address _owner;
    address _admin;

    address[] _toAuditList;                 // 待审核
    address[] _toThroughList;               // 审核通过
    address[] _toNotThroughList;            // 审核未通过
    mapping(address => TokenInfo) _tokenInfo;

    address private _tdexTokenManager;

    constructor () {
        _owner = msg.sender;
        _admin = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyGate() {
        require(_gate == msg.sender, "Ownable: caller is not the gate");
        _;
    }

    modifier onlyAdmin() {
        require(_admin == msg.sender, "Ownable: caller is not the admin");
        _;
    }

    function setGate(address __gate) external onlyOwner
    {
        _gate = __gate;
    }

    function setAdmin(address __admin) external onlyOwner
    {
        _admin = __admin;
    }

    function isAdmin(address __admin) external view returns (bool)
    {
        if (_admin == __admin)
            return true;
        return false;
    }

    function setTdexTokenManager(address __tdexTokenManager) external onlyOwner
    {
        _tdexTokenManager = __tdexTokenManager;
    }

    function insertTokenInfo(address __tokenContract, address __sender, string memory __url) external onlyGate
    {
        _tokenInfo[__tokenContract] = TokenInfo({
            name:ERC20(__tokenContract).name(),
            symbol:ERC20(__tokenContract).symbol(),
            decimals:ERC20(__tokenContract).decimals(),
            url:__url,
            status:ToAuditStatus.Reviewing,
            sender:__sender
        });

        ShortArrayHelper.insert(_toAuditList, __tokenContract);
    }

    function auditTdexToken(address __tokenContract, bool __isThrough) external onlyAdmin
    {
        ShortArrayHelper.remove(_toAuditList, __tokenContract);
        if (__isThrough)
        {
            ShortArrayHelper.insert(_toThroughList, __tokenContract);
            _tokenInfo[__tokenContract].status = ToAuditStatus.Through;
        }
        else
        {
            ShortArrayHelper.insert(_toNotThroughList, __tokenContract);
            _tokenInfo[__tokenContract].status = ToAuditStatus.NotThrough;
        }
    }

    function subTdexToken(address __tokenContract) external
    {
        require(_tokenInfo[__tokenContract].sender == msg.sender, "Not permissions");
        require(_tokenInfo[__tokenContract].status == ToAuditStatus.Through, "Not approved");

        _tokenInfo[__tokenContract].status = ToAuditStatus.Finished;

        TdexTokenManager(_tdexTokenManager).insertToken(__tokenContract);
        TdexTokenManager(_tdexTokenManager).setTokenIconUrl(__tokenContract, _tokenInfo[__tokenContract].url);
    }

    function tokenInfo(address __tokenContract) external view returns (TokenInfo memory)
    {
        return _tokenInfo[__tokenContract];
    }

    function getToAuditList(uint start, uint count) external view returns (TokenInfo[] memory)
    {
        uint begin = start;
        uint end = (start + count >= _toAuditList.length) ? (_toAuditList.length) : (start + count);
        uint length = end-begin;
        TokenInfo[] memory list = new TokenInfo[](length);
        uint i = begin;
        for (uint j=0; j<length; j++)
        {
            list[j] = _tokenInfo[_toAuditList[i]];
            i++;
            if (i == length) break;
        }
        return list;
    }

    function getToThroughList(uint start, uint count) external view returns (TokenInfo[] memory)
    {
        uint begin = start;
        uint end = (start + count >= _toThroughList.length) ? (_toThroughList.length) : (start + count);
        uint length = end-begin;
        TokenInfo[] memory list = new TokenInfo[](length);
        uint i = begin;
        for (uint j=0; j<length; j++)
        {
            list[j] = _tokenInfo[_toThroughList[i]];
            i++;
            if (i == length) break;
        }
        return list;
    }

    function getToNotThroughList(uint start, uint count) external view returns (TokenInfo[] memory)
    {
        uint begin = start;
        uint end = (start + count >= _toNotThroughList.length) ? (_toNotThroughList.length) : (start + count);
        uint length = end-begin;
        TokenInfo[] memory list = new TokenInfo[](length);
        uint i = begin;
        for (uint j=0; j<length; j++)
        {
            list[j] = _tokenInfo[_toNotThroughList[i]];
            i++;
            if (i == length) break;
        }
        return list;
    }
}