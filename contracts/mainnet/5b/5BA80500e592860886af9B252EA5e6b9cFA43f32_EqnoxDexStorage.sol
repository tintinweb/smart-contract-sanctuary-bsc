// SPDX-License-Identifier: MIT

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* EEEEEEEEEEEEEEEEEEEEEE       QQQQQQQQQ       NNNNNNNN        NNNNNNNN       OOOOOOOOO       XXXXXXX       XXXXXXX  *
* E::::::::::::::::::::E     QQ:::::::::QQ     N:::::::N       N::::::N     OO:::::::::OO     X:::::X       X:::::X  *
* E::::::::::::::::::::E   QQ:::::::::::::QQ   N::::::::N      N::::::N   OO:::::::::::::OO   X:::::X       X:::::X  *
* EE::::::EEEEEEEEE::::E  Q:::::::QQQ:::::::Q  N:::::::::N     N::::::N  O:::::::OOO:::::::O  X::::::X     X::::::X  *
*   E:::::E       EEEEEE  Q::::::O   Q::::::Q  N::::::::::N    N::::::N  O::::::O   O::::::O  XXX:::::X   X:::::XXX  *
*   E:::::E               Q:::::O     Q:::::Q  N:::::::::::N   N::::::N  O:::::O     O:::::O     X:::::X X:::::X     *
*   E::::::EEEEEEEEEE     Q:::::O     Q:::::Q  N:::::::N::::N  N::::::N  O:::::O     O:::::O      X:::::X:::::X      *
*   E:::::::::::::::E     Q:::::O     Q:::::Q  N::::::N N::::N N::::::N  O:::::O     O:::::O       X:::::::::X       *
*   E:::::::::::::::E     Q:::::O     Q:::::Q  N::::::N  N::::N:::::::N  O:::::O     O:::::O       X:::::::::X       *
*   E::::::EEEEEEEEEE     Q:::::O     Q:::::Q  N::::::N   N:::::::::::N  O:::::O     O:::::O      X:::::X:::::X      *
*   E:::::E               Q:::::O  QQQQ:::::Q  N::::::N    N::::::::::N  O:::::O     O:::::O     X:::::X X:::::X     *
*   E:::::E       EEEEEE  Q::::::O Q::::::::Q  N::::::N     N:::::::::N  O::::::O   O::::::O  XXX:::::X   X:::::XXX  *
* EE::::::EEEEEEEE:::::E  Q:::::::QQ::::::::Q  N::::::N      N::::::::N  O:::::::OOO:::::::O  X::::::X     X::::::X  *
* E::::::::::::::::::::E   QQ::::::::::::::Q   N::::::N       N:::::::N   OO:::::::::::::OO   X:::::X       X:::::X  *
* E::::::::::::::::::::E     QQ:::::::::::Q    N::::::N        N::::::N     OO:::::::::OO     X:::::X       X:::::X  *
* EEEEEEEEEEEEEEEEEEEEEE       QQQQQQQQ::::QQ  NNNNNNNN         NNNNNNN       OOOOOOOOO       XXXXXXX       XXXXXXX  *
*                                      Q:::::Q                                                                       *
*                                       QQQQQQ                                                                       *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * /
/*
Project Name:   Equinox
Ticker:         EQNOX
Decimals:       18
Token type:     Certificate of deposit
EQNOX has everything a good staking token should have:
- EQNOX is immutable
- EQNOX has no owner
- EQNOX has daily auctions
- EQNOX has daily rewards for auction participants
- EQNOX has an Automated Market Maker built in
- EQNOX has a stable supply and liquidity growth
- EQNOX has a 1.8% daily inflation that slowly decays over time
- EQNOX has shares that go up when stakes are ended 
- EQNOX has penalties for ending stakes early
- EQNOX has 10% rewards for referrals 
- EQNOX has a sticky referral system
- EQNOX has flexible splitting and merging of stakes
- EQNOX allows transferring stakes to different accounts
- EQNOX has no end date for stakes
Also, EQNOX is the first certificate of deposit aligned with the seasons:
- Every season change has a predictable impact on how EQNOX behaves
- Harvest season is the most important season for EQNOX
- It's when old holders leave, new ones join, and diamond hands are rewarded
- Stakes can only be created outside harvest season
- Stakes can only be ended without penalty during harvest season
- Stakes that survive harvest get more valuable and earn more interest
*/

pragma solidity ^0.8.13;
import "./eqnox_structs.sol";
import "./eqnox_dex_interfaces.sol";

abstract contract Base
{
    IToken public TOKEN_CONTRACT;
    IBEP20 public BUSD_CONTRACT;
    
    address public DEX_MANAGER;
    modifier onlyDexManager() {
        require(msg.sender == DEX_MANAGER,"Wrong sender.");
        _;
    }

    address public DEX_CONTRACT;
    modifier onlyDexContract() {
        require(msg.sender == DEX_CONTRACT, "Wrong sender.");
        _;
    }

    function setTokenContract(address contractAddress) external onlyDexManager
    {
        TOKEN_CONTRACT = IToken(contractAddress);
    }

    function moveStake(bytes16 stakeId, address account) external onlyDexContract{
        TOKEN_CONTRACT.moveStake(stakeId, account);
    }
}

contract EqnoxDexStorage is Base
{

    function setDexContract(address contractAddress) external onlyDexManager 
    {
        DEX_CONTRACT = contractAddress;
    }

    mapping(address => uint256) public userUnconfirmedListingCount;
    function setUserUnconfirmedListingCount(address userAddress, uint256 listingCount) external onlyDexContract
    {
        userUnconfirmedListingCount[userAddress] = listingCount;
    }

    mapping(address => uint256) public userActiveListingCount;
    function setUserActiveListingCount(address userAddress, uint256 listingCount) external onlyDexContract
    {
        userActiveListingCount[userAddress] = listingCount;
    }

    mapping(address => uint256) public userListingCount;
    function setUserListingCount(address userAddress, uint256 listingCount) external onlyDexContract
    {
        userListingCount[userAddress] = listingCount;
    }

    mapping(address => uint256) public userBoughtListingCount;
    function setUserBoughtListingCount(address userAddress, uint256 listingCount) external onlyDexContract
    {
        userBoughtListingCount[userAddress] = listingCount;
    }

    mapping(string => uint256) public globalIdentifierCount;
    function setGlobalIdentifierCount(string memory key, uint256 identifierCount) external onlyDexContract
    {
        globalIdentifierCount[key] = identifierCount;
    }

    mapping(bytes16 => bytes16) public stakeListing;
    function setStakeListing(bytes16 stakeId, bytes16 listingId) external onlyDexContract
    {
        stakeListing[stakeId] = listingId;
    }

    mapping(address => mapping(bytes16 => EqnoxStructs.Listing)) public userListings;
    function setUserListing(address userAddress, bytes16 id, EqnoxStructs.Listing memory listing) external onlyDexContract
    {
        userListings[userAddress][id] = listing;
    }

    mapping(address => mapping(uint256 => EqnoxStructs.GlobalListingIdentifier)) public userBoughtListings;
    function setUserBoughtListingIdentifier(address userAddress, uint256 index, EqnoxStructs.GlobalListingIdentifier memory identifier) external onlyDexContract
    {
        userBoughtListings[userAddress][index] = identifier;
    }

    mapping(string => mapping(uint256 => EqnoxStructs.GlobalListingIdentifier)) public globalListingIdentifiers;
    function setGlobalListingIdentifier(string memory key, uint256 index, EqnoxStructs.GlobalListingIdentifier memory identifier) external onlyDexContract
    {
        globalListingIdentifiers[key][index] = identifier;
    }

    function deleteGlobalListingIdentifier(string memory key, uint256 index) external onlyDexContract
    {
        delete globalListingIdentifiers[key][index];
    }

    function transferBusd(address account, uint256 amount) external onlyDexContract
    {
        BUSD_CONTRACT.transfer(account, amount);
    }

    function transferStake(bytes16 stakeId, address to) external onlyDexManager
    {
        TOKEN_CONTRACT.moveStake(stakeId, to);
    }

    function transferBusdFrom(address from, address to, uint256 amount) external onlyDexContract returns(bool)
    {
        return BUSD_CONTRACT.transferFrom(from, to, amount);
    }

    function approveBusd(address account, uint256 amount) external onlyDexContract
    {
        BUSD_CONTRACT.approve(account, amount);
    }

    constructor()
    {
        BUSD_CONTRACT = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        TOKEN_CONTRACT = IToken(0x05486aDfD491130FCD38233c1Cb125FCb2bFb803);
        DEX_MANAGER = msg.sender;
    }
}