// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Address.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./IERC20.sol";
import "./IERC721.sol";

import "./Pausable.sol";

import "./Whitelist.sol";

contract WoolFactory is Pausable, Whitelist {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 claimed;  // How many tokens claimed?
        uint256 xClaimed; // How many claims total?

        uint256 lastClaimTime; // When was the last claim time?

        // Tier ID to quantity of items held
        mapping(uint256 => uint256) itemCount;
    }

    // Contract interfaces
    IERC20 public rewardsToken;   // WOOL token

    mapping(uint256 => address) watchedContracts;
    mapping(address => UserInfo) internal _users;

    constructor (address _WOOL) {
        rewardsToken = IERC20(_WOOL);
        addAddressToWhitelist(msg.sender);
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Find claimed amount of WOOL by an address
    function claimedOf(address _user) external view returns (uint256) {
        return (_users[_user].claimed);
    }

    // Find how many claims total an address has made
    function claimsOf(address _user) external view returns (uint256) {
        return (_users[_user].xClaimed);
    }

    // How much WOOL is available for the user to mint
    function availableWoolOf(address _user) public view returns (uint256) {

        // Get the last time of action, calculate the difference between then and now.
        uint256 _lastClaim = lastClaimTimeOf(_user);
        uint256 _timeDiff = ((block.timestamp).sub(_lastClaim));
        
        // Find the 'tokens per second' and multiply by the time difference
        uint256 _wps = woolPerSecondOf(_user);
        uint256 _toMint = ((_wps).mul(_timeDiff));

        return _toMint;
    }

    // WOOL per Second of an address
    function woolPerSecondOf(address _user) public view returns (uint256) {
        (uint256 _tier1, uint256 _tier2, uint256 _tier3, uint256 _tier4, uint256 _tier5, uint256 _tier6) = viewItems(_user);

        uint256 _tokensPerYear = (
            (_tier1 * getMintPriceOf(1)) + 
            (_tier2 * getMintPriceOf(2)) + 
            (_tier3 * getMintPriceOf(3)) + 
            (_tier4 * getMintPriceOf(4)) + 
            (_tier5 * getMintPriceOf(5)) + 
            (_tier6 * getMintPriceOf(6))
        );

        uint256 _tokensPerDay = (_tokensPerYear.div(365));
        uint256 _tokensPerSec = (_tokensPerDay.div(86400));

        return (_tokensPerSec);
    }

    // Last Claim Time of an address
    function lastClaimTimeOf(address _user) public view returns (uint256) {

        // If the user has not claimed even once, their first claim time is yet untracked
        // For this, we keep their timestamp at the latest one of the block.
        if (_users[_user].xClaimed == 0) {
            return block.timestamp;
        }
        return (_users[_user].lastClaimTime);
    }

    // Get item count of a single tier for one _user
    function totalItemsOfTier(address _user, uint256 _tierId) public view returns (uint256) {
        return (_users[_user].itemCount[_tierId]);
    }

    // Get item counts from all tiers for one _user
    function viewItems(address _user) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        uint256 _tier1 = _users[_user].itemCount[1];
        uint256 _tier2 = _users[_user].itemCount[2];
        uint256 _tier3 = _users[_user].itemCount[3];
        uint256 _tier4 = _users[_user].itemCount[4];
        uint256 _tier5 = _users[_user].itemCount[5];
        uint256 _tier6 = _users[_user].itemCount[6];

        return (_tier1, _tier2, _tier3, _tier4, _tier5, _tier6);
    }

    // Find a count of all NFTs from all tiers for an address (stored numbers)
    function totalItemsOf(address _user) external view returns (uint256) {
        uint256 _tier1 = _users[_user].itemCount[1];
        uint256 _tier2 = _users[_user].itemCount[2];
        uint256 _tier3 = _users[_user].itemCount[3];
        uint256 _tier4 = _users[_user].itemCount[4];
        uint256 _tier5 = _users[_user].itemCount[5];
        uint256 _tier6 = _users[_user].itemCount[6];

        return (
            _tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6
        );
    }

    // Get the price of one of the NFTs (by Tier ID)
    function getMintPriceOf(uint256 _tier) public pure returns (uint256) {

        if (_tier == 1) {return 2e18;}
        if (_tier == 2) {return 4e18;}
        if (_tier == 3) {return 8e18;}
        if (_tier == 4) {return 16e18;}
        if (_tier == 5) {return 32e18;}
        if (_tier == 6) {return 64e18;}

        return 0;
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Add an address to the watched items index
    function addItem(uint256 _tier, address _item) external onlyWhitelisted() {
        require(_item != address(0), "INVALID_ADDRESS");
        
        watchedContracts[_tier] = _item;
    }

    // Store numbers of NFTs to calculate earnings from (stops buy-claim exploit)
    function updateItems(address _user) external onlyWhitelisted() {
        _users[_user].itemCount[1] = IERC721(watchedContracts[1]).balanceOf(_user);
        _users[_user].itemCount[2] = IERC721(watchedContracts[2]).balanceOf(_user);
        _users[_user].itemCount[3] = IERC721(watchedContracts[3]).balanceOf(_user);
        _users[_user].itemCount[4] = IERC721(watchedContracts[4]).balanceOf(_user);
        _users[_user].itemCount[5] = IERC721(watchedContracts[5]).balanceOf(_user);
        _users[_user].itemCount[6] = IERC721(watchedContracts[6]).balanceOf(_user);
    }

    // Claim Tokens
    function claimTokens(address _user) onlyWhitelisted() external returns (uint256) {

        uint256 _rewards = rewardsToken.balanceOf(address(this));

        // Find the current earnings of a user
        uint256 _toMint = availableWoolOf(_user);

        if (_toMint > 0) {
            // Mint the appropriate tokens
            // Note: This finds the minimum - user entitlement or available rewards
            rewardsToken.safeTransfer(_user, SafeMath.min(_rewards, _toMint));
        }

        // Update stats
        _users[_user].lastClaimTime = block.timestamp;
        _users[_user].claimed += _toMint;
        _users[_user].xClaimed += 1;

        // Return the amount minted
        return _toMint;
    }

    // Set the Rewards Token Address
    function setRewardsToken(address _addr) public onlyOwner() {
        require(Address.isContract(_addr) && _addr != address(0), "INVALID_ADDRESS");
        rewardsToken = IERC20(_addr);
    }
}