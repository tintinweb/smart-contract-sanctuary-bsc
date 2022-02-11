// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./IERC20.sol";
import "./IERC721.sol";

import "./Whitelist.sol";
import "./ReentrancyGuard.sol";

import "./FreeParticipantRegistry.sol";

interface IDegenNFT {
    function mint(address player) external returns (uint256);
}

contract WoolFactory is Whitelist, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /////////////
    // STRUCTS //
    /////////////
    
    struct DegenPlayer {
        uint256 claimed;  // How many tokens claimed?
        uint256 xClaimed; // How many claims total?

        uint256 lastClaimTime; // When was the last claim time?
    }

    ////////////////
    // INTERFACES //
    ////////////////

    IERC20    public token;
    IDegenNFT public degenNFT;

    FreeParticipantRegistry private freeParticipantRegistry;

    /////////////////////////////////
    // CONFIGURABLES AND VARIABLES //
    /////////////////////////////////

    address public SHEEPAddress;
    address public reserveAddress;

    address public nft1;
    address public nft2;
    address public nft3;
    address public nft4;
    address public nft5;
    address public nft6;

    uint256 public forReserve;
    uint256 public totalTiers;

    //////////////////
    // DATA MAPPING //
    //////////////////

    mapping(address => bool) internal _isDegenNFT;

    mapping(address => DegenPlayer) internal _degen;

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onBuyItem(address sender, address recipient, uint256 tierId, uint256 _timestamp);
    event onSellItem(address sender, address nftAddress, uint256 itemId, uint256 _timestamp);

    event onClaimTokens(address sender, uint256 _lastClaim, uint256 _timeDiff, uint256 _wps, uint256 _toMint, uint256 timestamp);

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor(address _SHEEP, address _nft1, address _nft2, address _nft3, address _nft4, address _nft5, address _nft6, address _reserveAddress) {
        nft1 = _nft1;
        nft2 = _nft2;
        nft3 = _nft3;
        nft4 = _nft4;
        nft5 = _nft5;
        nft6 = _nft6;

        _isDegenNFT[_nft1] = true;
        _isDegenNFT[_nft2] = true;
        _isDegenNFT[_nft3] = true;
        _isDegenNFT[_nft4] = true;
        _isDegenNFT[_nft5] = true;
        _isDegenNFT[_nft6] = true;

        totalTiers = 6;

        SHEEPAddress = _SHEEP;
        token = IERC20(SHEEPAddress);

        reserveAddress = _reserveAddress;
    }

    receive() external payable {

    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Buy an NFT, specifying recipient and tier.
    // Caller must approve this contract to spend their SH33P
    function buyItem(address _recipient, uint256 _tierId) nonReentrant() public returns (uint256) {
        require(_tierId >= 0 && _tierId < totalTiers, "INVALID_RANGE");

        // Collect Mint Payment if not a 'free participant'
        if(!freeParticipantRegistry.freeParticipant(msg.sender)){
            require(_collectMintFee(msg.sender, _tierId), 'Must pay minting fee');
        }

        // Mint Item
        uint256 _newItemID = _mintItem(_tierId, _recipient);

        forReserve += ((getPriceOf(_tierId)).mul(25)).div(100);

        // Tell the network, successful function!
        emit onBuyItem(msg.sender, _recipient, _tierId, block.timestamp);
        return _newItemID;
    }

    // Sell an NFT back to the system at 75% of the price paid for it
    // Caller must approve this contract to move their NFTs
    function sellItem(address _nftAddress, uint256 _itemId) nonReentrant() public returns (bool _success) {
        require(IERC721(_nftAddress).ownerOf(_itemId) == msg.sender, "ONLY_OWNER");
        require(_isDegenNFT[_nftAddress] == true, "INVALID_NFT");

        // Calculate refund amount for the item
        uint256 _refundAmount = ((getPriceOf(_itemId).mul(75)).div(100));

        // Collect the item from the user
        IERC721(_nftAddress).transferFrom(msg.sender, address(this), _itemId);

        // Give the seller their refund
        IERC20(SHEEPAddress).transfer(msg.sender, _refundAmount);

        // Tell the network, successful function!
        emit onSellItem(msg.sender, _nftAddress, _itemId, block.timestamp);
        return true;
    }

    // Mint WOOL tokens, pro-rata of seconds since last claim
    // This contract must be whitelisted to mint the token
    function claimWool() nonReentrant() public returns (uint256) {
        
        // Get the last time of action, calculate the difference between then and now.
        uint256 _lastClaim = lastClaimTimeOf(msg.sender);
        uint256 _timeDiff = ((block.timestamp).sub(_lastClaim));
        
        // Find the 'tokens per second' and multiply by the time difference
        uint256 _wps = woolPerSecondOf(msg.sender);
        uint256 _toMint = ((_wps).mul(_timeDiff));

        // Mint the appropriate tokens
        // wool.mint(msg.sender, _toMint);

        // Update stats
        _degen[msg.sender].lastClaimTime = block.timestamp;
        _degen[msg.sender].claimed += _toMint;
        _degen[msg.sender].xClaimed += 1;

        // Tell the network, successful function
        emit onClaimTokens(msg.sender, _lastClaim, _timeDiff, _wps, _toMint, block.timestamp);
        return _toMint;
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Get contract address of one of the NFTs (by Tier ID)
    function getContractOf(uint256 _tier) public view returns (address) {
        if (_tier == 1) {return nft1;}
        if (_tier == 2) {return nft2;}
        if (_tier == 3) {return nft3;}
        if (_tier == 4) {return nft4;}
        if (_tier == 5) {return nft5;}
        if (_tier == 6) {return nft6;}

        return address(0);
    }

    // Get the price of one of the NFTs (by Tier ID)
    function getPriceOf(uint256 _tier) public pure returns (uint256) {
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
        uint256 _tier1 = IERC721(nft1).balanceOf(_user);
        uint256 _tier2 = IERC721(nft2).balanceOf(_user);
        uint256 _tier3 = IERC721(nft3).balanceOf(_user);
        uint256 _tier4 = IERC721(nft4).balanceOf(_user);
        uint256 _tier5 = IERC721(nft5).balanceOf(_user);
        uint256 _tier6 = IERC721(nft6).balanceOf(_user);

        uint256 _tokens = (
            (_tier1 * getPriceOf(1)) + 
            (_tier2 * getPriceOf(2)) + 
            (_tier3 * getPriceOf(3)) + 
            (_tier4 * getPriceOf(4)) + 
            (_tier5 * getPriceOf(5)) + 
            (_tier6 * getPriceOf(6))
        );

        uint256 _perDay = (_tokens.div(365));
        uint256 _perSec = (_perDay.div(86400));

        return (_perSec);
    }

    // Last Claim Time of an address
    function lastClaimTimeOf(address _user) public view returns (uint256) {
        return (_degen[_user].lastClaimTime);
    }

    // NEW: Find claimed amount of WOOL by an address
    function claimedOf(address _user) public view returns (uint256) {
        return (_degen[_user].claimed);
    }

    // NEW: Find how many claims total an address has made
    function claimsOf(address _user) public view returns (uint256) {
        return (_degen[_user].xClaimed);
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    // Set the NFT Reward Reserve Address
    function setReserve(address _newReserve) public onlyOwner() {
        reserveAddress = _newReserve;
    }

    // Send the 25% non-refundable portions to the Reward Reserve
    function saveTokens() public onlyOwner() {
        _transferToReserve();
    }

    // Set the exemption list for fees and charges
    function setFreeParticipantRegistry(FreeParticipantRegistry _freeParticipantRegistry) public onlyOwner {
        freeParticipantRegistry = _freeParticipantRegistry;
    }

    // Set the Payment Token Address
    function setPaymentToken(address _newToken) public onlyOwner() {
        SHEEPAddress = _newToken;
        token = IERC20(SHEEPAddress);
    }

    ////////////////////////////////////
    // INTERNAL AND PRIVATE FUNCTIONS //
    ////////////////////////////////////

    function _mintItem(uint256 _tierId, address _recipient) internal returns (uint256) {
        address _contract = getContractOf(_tierId);
        return IDegenNFT(_contract).mint(_recipient);
    }

    function _collectMintFee(address payee, uint256 _tierId) internal returns(bool){

        uint256 _mintPrice = getPriceOf(_tierId);

        uint256 _amount0 = _mintPrice;
        uint256 _amount1 = _mintPrice.sub(_amount0);

        IERC20(SHEEPAddress).transferFrom(payee, address(this), _amount0);

        forReserve += _amount1;
        
        return true;
    }

    function _transferToReserve() internal returns(bool){
        IERC20(SHEEPAddress).transfer(reserveAddress, forReserve);
        return true;
    }
}