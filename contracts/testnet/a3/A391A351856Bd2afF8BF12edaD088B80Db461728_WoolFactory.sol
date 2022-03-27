// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Counters.sol";

import "./IERC20.sol";
import "./IERC721.sol";
import "./IEliteNFT.sol";
import "./IERC721Receiver.sol";

import "./WoolToken.sol";

import "./Whitelist.sol";
import "./ReentrancyGuard.sol";

interface IDegenNFT {
    function mint(address player) external returns (uint256);
}

contract WoolFactory is Whitelist, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    using Counters for Counters.Counter;

    /////////////
    // STRUCTS //
    /////////////

    struct DegenPlayer {
        uint256 claimed;  // How many tokens claimed?
        uint256 xClaimed; // How many claims total?

        uint256 lastClaimTime; // When was the last claim time?

        // Tier ID to quantity of items held
        mapping(uint256 => uint256) itemCount;
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        uint256 markupLevel;
        bool sold;
    }

    struct Tier {
        address collection;

        mapping(uint256 => MarketItem) queue;
        uint256 queueFront;
        uint256 queueBack;

        uint256 totalMinted;
        uint256 totalListed;
        uint256 totalItems;
    }

    ////////////////
    // INTERFACES //
    ////////////////

    IERC20    public payableToken;  // SH33P token
    WoolToken public rewardsToken;   // WOOL token

    /////////////////////////////////
    // CONFIGURABLES AND VARIABLES //
    /////////////////////////////////

    address public WOOLAddress;
    address public SHEEPAddress;
    address public reserveAddress;

    address[] public degenNFT;

    address public nftTier1;
    address public nftTier2;
    address public nftTier3;
    address public nftTier4;
    address public nftTier5;
    address public nftTier6;

    //////////////////
    // DATA MAPPING //
    //////////////////

    mapping(address => DegenPlayer) internal _degen;

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onClaimTokens(address sender, uint256 _lastClaim, uint256 _timeDiff, uint256 _wps, uint256 _toMint, uint256 timestamp);

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor (
        address _SHEEP, address _WOOL, address _reserveAddress, 
        address _nft1, address _nft2, address _nft3, address _nft4, address _nft5, address _nft6
    ) {
        nftTier1 = _nft1;
        nftTier2 = _nft2;
        nftTier3 = _nft3;
        nftTier4 = _nft4;
        nftTier5 = _nft5;
        nftTier6 = _nft6;

        WOOLAddress = _WOOL;
        SHEEPAddress = _SHEEP;

        payableToken = IERC20(SHEEPAddress);
        rewardsToken = WoolToken(WOOLAddress);

        reserveAddress = _reserveAddress;
    }

    receive() external payable {

    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Mint WOOL tokens, pro-rata of seconds since last claim
    // This contract must be whitelisted to mint the token
    function claimWool(address _user) nonReentrant() external returns (uint256) {
        
        uint256 _claimTotal = _claimWool(_user);
        _updateUserNFTs(_user);

        return _claimTotal;
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Get item count for all tiers, for one _user
    function getItems(address _user, bool _realtime) external view returns (
        uint256 _tier1Items, uint256 _tier2Items, uint256 _tier3Items, uint256 _tier4Items, uint256 _tier5Items, uint256 _tier6Items
    ) {
        if (_realtime == true) {
            return (
                getUserBalanceOfTier(_user, 1), 
                getUserBalanceOfTier(_user, 2), 
                getUserBalanceOfTier(_user, 3), 
                getUserBalanceOfTier(_user, 4), 
                getUserBalanceOfTier(_user, 5), 
                getUserBalanceOfTier(_user, 6)
            );
        } else {
            return (
                getUserItemCountOfTier(_user, 1), 
                getUserItemCountOfTier(_user, 2), 
                getUserItemCountOfTier(_user, 3), 
                getUserItemCountOfTier(_user, 4), 
                getUserItemCountOfTier(_user, 5), 
                getUserItemCountOfTier(_user, 6)
            );
        }
    }

    // Get count of all items across all tiers for one _user
    function getUserTotalItems(address _user) external view returns (uint256) {
        return (
            getUserItemCountOfTier(_user, 1) + getUserItemCountOfTier(_user, 2) + getUserItemCountOfTier(_user, 3) + 
            getUserItemCountOfTier(_user, 4) + getUserItemCountOfTier(_user, 5) + getUserItemCountOfTier(_user, 6)
        );
    }

    // Find a count of all NFTs from all tiers for an address (stored numbers)
    function recordedItemsOf(address _user) external view returns (uint256) {
        uint256 _tier1 = _degen[_user].itemCount[1];
        uint256 _tier2 = _degen[_user].itemCount[2];
        uint256 _tier3 = _degen[_user].itemCount[3];
        uint256 _tier4 = _degen[_user].itemCount[4];
        uint256 _tier5 = _degen[_user].itemCount[5];
        uint256 _tier6 = _degen[_user].itemCount[6];

        return (
            _tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6
        );
    }

    // Items of user as of right now (live balance check)
    function realtimeItemsOf(address _user) external view returns (uint256) {
        uint256 _tier1 = IERC721(nftTier1).balanceOf(_user);
        uint256 _tier2 = IERC721(nftTier2).balanceOf(_user);
        uint256 _tier3 = IERC721(nftTier3).balanceOf(_user);
        uint256 _tier4 = IERC721(nftTier4).balanceOf(_user);
        uint256 _tier5 = IERC721(nftTier5).balanceOf(_user);
        uint256 _tier6 = IERC721(nftTier6).balanceOf(_user);

        return (
            _tier1 + _tier2 + _tier3 + _tier4 + _tier5 + _tier6
        );
    }

    // Get tier of a contract address
    function getTierOf(address _contract) external view returns (uint256 _id) {
        if (_contract == nftTier1) {_id = 1;}
        if (_contract == nftTier2) {_id = 2;}
        if (_contract == nftTier3) {_id = 3;}
        if (_contract == nftTier4) {_id = 4;}
        if (_contract == nftTier5) {_id = 5;}
        if (_contract == nftTier6) {_id = 6;}
    }

    // Find claimed amount of WOOL by an address
    function claimedOf(address _user) external view returns (uint256) {
        return (_degen[_user].claimed);
    }

    // Find how many claims total an address has made
    function claimsOf(address _user) external view returns (uint256) {
        return (_degen[_user].xClaimed);
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

    // Get contract address of one of the NFTs (by Tier ID)
    function getContractOf(uint256 _tier) public view returns (address) {
        if (_tier == 1) {return nftTier1;}
        if (_tier == 2) {return nftTier2;}
        if (_tier == 3) {return nftTier3;}
        if (_tier == 4) {return nftTier4;}
        if (_tier == 5) {return nftTier5;}
        if (_tier == 6) {return nftTier6;}

        return address(0);
    }

    // Get live balance of items, for one _user
    function getUserBalanceOfTier(address _user, uint256 _tierId) public view returns (uint256) {
        address _nft = getContractOf(_tierId);
        return (IERC721(_nft).balanceOf(_user));
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

    // WOOL per Second of an address
    function woolPerSecondOf(address _user) public view returns (uint256) {
        uint256 _tier1 = _degen[_user].itemCount[1];
        uint256 _tier2 = _degen[_user].itemCount[2];
        uint256 _tier3 = _degen[_user].itemCount[3];
        uint256 _tier4 = _degen[_user].itemCount[4];
        uint256 _tier5 = _degen[_user].itemCount[5];
        uint256 _tier6 = _degen[_user].itemCount[6];

        uint256 _tokens = (
            (_tier1 * getMintPriceOf(1)) + 
            (_tier2 * getMintPriceOf(2)) + 
            (_tier3 * getMintPriceOf(3)) + 
            (_tier4 * getMintPriceOf(4)) + 
            (_tier5 * getMintPriceOf(5)) + 
            (_tier6 * getMintPriceOf(6))
        );

        uint256 _perDay = (_tokens.div(365));
        uint256 _perSec = (_perDay.div(86400));

        return (_perSec);
    }

    // Last Claim Time of an address
    function lastClaimTimeOf(address _user) public view returns (uint256) {

        // If the user has not claimed even once, their first claim time is yet untracked
        // For this, we keep their timestamp at the latest one of the block.
        if (_degen[_user].xClaimed == 0) {
            return block.timestamp;
        }
        return (_degen[_user].lastClaimTime);
    }

    // Get item count of a single tier for one _user
    function getUserItemCountOfTier(address _user, uint256 _tierId) public view returns (uint256) {
        return (_degen[_user].itemCount[_tierId]);
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    // Set the Rewards Token Address
    function setRewardsToken(address _newToken) public onlyOwner() {
        WOOLAddress = _newToken;
        rewardsToken = WoolToken(WOOLAddress);
    }

    ////////////////////////////////////
    // INTERNAL AND PRIVATE FUNCTIONS //
    ////////////////////////////////////

    // Claim Wool - call before anything which changes calculation parameters
    function _claimWool(address _user) internal returns (uint256) {
        uint256 _lastClaim = lastClaimTimeOf(_user);
        uint256 _timeDiff = ((block.timestamp).sub(_lastClaim));
        
        // Find the 'tokens per second' and multiply by the time difference
        uint256 _wps = woolPerSecondOf(_user);
        uint256 _toMint = availableWoolOf(_user);

        if (_toMint > 0) {
            // Mint the appropriate tokens
            rewardsToken.mint(_user, _toMint);
        }

        // Update stats
        _degen[_user].lastClaimTime = block.timestamp;
        _degen[_user].claimed += _toMint;
        _degen[_user].xClaimed += 1;

        // Tell the network, successful function
        emit onClaimTokens(_user, _lastClaim, _timeDiff, _wps, _toMint, block.timestamp);
        return _toMint;
    }

    // Store numbers of NFTs to calculate earnings from (stops buy-claim exploit)
    function _updateUserNFTs(address _user) internal {
        _degen[_user].itemCount[1] = IERC721(nftTier1).balanceOf(_user);
        _degen[_user].itemCount[2] = IERC721(nftTier2).balanceOf(_user);
        _degen[_user].itemCount[3] = IERC721(nftTier3).balanceOf(_user);
        _degen[_user].itemCount[4] = IERC721(nftTier4).balanceOf(_user);
        _degen[_user].itemCount[5] = IERC721(nftTier5).balanceOf(_user);
        _degen[_user].itemCount[6] = IERC721(nftTier6).balanceOf(_user);
    }
}