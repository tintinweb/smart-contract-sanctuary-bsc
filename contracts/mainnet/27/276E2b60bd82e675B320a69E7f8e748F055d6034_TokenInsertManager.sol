/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

struct Token {
    address tokenContract;
    string symbol;
    string name;
    uint decimals;
}

interface TokenManager {

    function insertToken(address __tokenContract) external returns (bool);

    function removeToken(address __tokenContract) external returns (bool);

    function getToken(address __tokenContract) external view returns (Token memory token);

    function getTokenMapLength() external view returns (uint length);

    function getTokenAddressList(uint256 start, uint256 end) external view returns (address[] memory list);
}

contract TokenInsertManager {

    address private _owner;
    mapping(address => bool) private _adminMap;
    TokenManager private _mananger;
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor (address __mananger) {
        _owner = msg.sender;
        _mananger = TokenManager(__mananger);
    }

    function addAdmin(address __admin) external onlyOwner
    {
        _adminMap[__admin] = true;
    }

    function removeAdmin(address __admin) external onlyOwner
    {
        delete _adminMap[__admin];
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(_adminMap[msg.sender] == true || _owner == msg.sender, "Ownable: caller is not the admin");
        _;
    }


    function insertToken(address __tokenContract) external onlyAdmin returns (bool)
    {
        return _mananger.insertToken(__tokenContract);
    }

    function removeToken(address __tokenContract) external onlyAdmin returns (bool)
    {
        return _mananger.removeToken(__tokenContract);
    }

    function getToken(address __tokenContract) external view returns (Token memory token)
    {
        return _mananger.getToken(__tokenContract);
    }

    function getTokenMapLength() external view returns (uint length)
    {
        return _mananger.getTokenMapLength();
    }

    function getTokenAddressList(uint256 start, uint256 end) external view returns (address[] memory list)
    {
        return _mananger.getTokenAddressList(start, end);
    }
}