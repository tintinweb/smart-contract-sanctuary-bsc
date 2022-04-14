// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./Whitelist.sol";

contract ItemCounter is Whitelist {

    struct DegenPlayer {

        // Tier ID to quantity of items held
        mapping(uint256 => uint256) itemCount;
    }

    mapping(uint256 => address) watchedContracts;
    mapping(address => DegenPlayer) internal _userData;

    constructor () {
        
    }

    // Get item count of a single tier for one _user
    function totalItemsOfTier(address _user, uint256 _tierId) public view returns (uint256) {
        return (_userData[_user].itemCount[_tierId]);
    }

    // Get item counts from all tiers for one _user
    function viewItems(address _user) external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        uint256 _tier1 = _userData[_user].itemCount[1];
        uint256 _tier2 = _userData[_user].itemCount[2];
        uint256 _tier3 = _userData[_user].itemCount[3];
        uint256 _tier4 = _userData[_user].itemCount[4];
        uint256 _tier5 = _userData[_user].itemCount[5];
        uint256 _tier6 = _userData[_user].itemCount[6];

        return (_tier1, _tier2, _tier3, _tier4, _tier5, _tier6);
    }

    // Find a count of all NFTs from all tiers for an address (stored numbers)
    function totalItemsOf(address _user) external view returns (uint256) {
        uint256 _tier1 = _userData[_user].itemCount[1];
        uint256 _tier2 = _userData[_user].itemCount[2];
        uint256 _tier3 = _userData[_user].itemCount[3];
        uint256 _tier4 = _userData[_user].itemCount[4];
        uint256 _tier5 = _userData[_user].itemCount[5];
        uint256 _tier6 = _userData[_user].itemCount[6];

        return (
            _tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6
        );
    }

    function addItem(uint256 _tier, address _item) external onlyWhitelisted() {
        require(_item != address(0), "INVALID_ADDRESS");
        
        watchedContracts[_tier] = _item;
    }

    // Store numbers of NFTs to calculate earnings from (stops buy-claim exploit)
    function updateItems(address _user) external onlyWhitelisted() {
        _userData[_user].itemCount[1] = IERC721(watchedContracts[1]).balanceOf(_user);
        _userData[_user].itemCount[2] = IERC721(watchedContracts[2]).balanceOf(_user);
        _userData[_user].itemCount[3] = IERC721(watchedContracts[3]).balanceOf(_user);
        _userData[_user].itemCount[4] = IERC721(watchedContracts[4]).balanceOf(_user);
        _userData[_user].itemCount[5] = IERC721(watchedContracts[5]).balanceOf(_user);
        _userData[_user].itemCount[6] = IERC721(watchedContracts[6]).balanceOf(_user);
    }
}