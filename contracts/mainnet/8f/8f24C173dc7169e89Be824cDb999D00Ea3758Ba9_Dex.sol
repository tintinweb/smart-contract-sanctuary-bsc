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
import './eqnox_structs.sol';
import './safemath.sol';
import './eqnox_dex_interfaces.sol';

abstract contract Helpers
{
    function _toBytes16(uint256 x) internal pure returns (bytes16 b) {
       return bytes16(bytes32(x));
    }

    function generateID(address x, uint256 y, bytes1 z) internal pure returns (bytes16 b) {
        b = _toBytes16(uint256(keccak256(abi.encodePacked(x, y, z))));
    }
}

abstract contract Events is Helpers
{
    event StakeListed(bytes16 listingId, address sellerAddress, uint256 price, uint256 validUntilBlockNumber);
    event ListingConfirmed(bytes16 listingId, address sellerAddress);
    event StakeBought(bytes16 listingId, address sellerAddress, address buyerAddress);
    event ListingCancelled(bytes16 listingId, address sellerAddress);
}

abstract contract Data is Events
{
    bool public IS_DEX_OPEN;
    uint256 public MKT_DENOMINATOR;
    uint256 public MKT_NUMERATOR;
    uint256 public EXPIRATION_BLOCK_TIME;
    uint256 public MAX_GLOBAL_UNCONFIRMED_LISTINGS;
    uint256 public MAX_USER_UNCONFIRMED_LISTINGS;
    address public MKT_ADDRESS_1;
    address public MKT_ADDRESS_2;
    IToken public TOKEN_CONTRACT;
    IDexStorage public STORAGE_CONTRACT;
    IBEP20 public BUSD_CONTRACT;
    uint256 public MIN_LISTING_PRICE;
    uint256 public MAX_LISTING_PRICE;
    uint256 public SECURITY_DEPOSIT;
}

/**
*@dev The global listing manager contract handles dynamic data through key identification (in this case, unconfirmed and active listings)
**/
abstract contract ListingManager is Data
{
    string internal unconfirmedKey = "unconfirmed";
    string internal activeKey = "active";

    /**
    *@dev adds an identifier to the last position.
    **/
    function _addIdentifier(string memory key, EqnoxStructs.GlobalListingIdentifier memory identifier) internal
    {
        uint256 count = STORAGE_CONTRACT.globalIdentifierCount(key);
        STORAGE_CONTRACT.setGlobalListingIdentifier(key, count, identifier);
        STORAGE_CONTRACT.setGlobalIdentifierCount(key, count+1);
    }

    /**
    *@dev removes an identifier from a dynamic array identified by a key and a numerical index.
    * Whenever an identifier is removed from any position other than the last one, the last identifier occupies that position, avoiding blank spaces.  
    **/
    function _removeIdentifier(string memory key, uint256 index) internal
    {
        EqnoxStructs.GlobalListingIdentifier memory identifier = STORAGE_CONTRACT.globalListingIdentifiers(key, index);
        uint256 identifierCount = STORAGE_CONTRACT.globalIdentifierCount(key);
        if(identifier.sellerAddress == address(0x0))
        {
            return;
        }
        STORAGE_CONTRACT.deleteGlobalListingIdentifier(key, index);

        if(identifierCount > 1 && index < identifierCount - 1)
        {
            EqnoxStructs.GlobalListingIdentifier memory lastIdentifier = STORAGE_CONTRACT.globalListingIdentifiers(key, identifierCount-1);
            EqnoxStructs.Listing memory listing = STORAGE_CONTRACT.userListings(identifier.sellerAddress, identifier.listingId);
            listing.globalIndex = index;
            STORAGE_CONTRACT.setGlobalListingIdentifier(key, index, lastIdentifier);
            STORAGE_CONTRACT.setUserListing(listing.sellerAddress, listing.listingId, listing);
            STORAGE_CONTRACT.deleteGlobalListingIdentifier(key, identifierCount-1);
        }
        STORAGE_CONTRACT.setGlobalIdentifierCount(key, identifierCount - 1);
    }

    /**
    *@dev The number of unconfirmed listings
    **/
    function unconfirmedListingCount() external view returns (uint256)
    {
        return STORAGE_CONTRACT.globalIdentifierCount(unconfirmedKey);
    }

    /**
    *@dev The number of active listings
    **/
    function activeListingCount() external view returns (uint256)
    {
        return STORAGE_CONTRACT.globalIdentifierCount(activeKey);
    }

    /**
    *@dev adds an active identifier. See _addIdentifier
    **/
    function _addActiveIdentifier(EqnoxStructs.GlobalListingIdentifier memory identifier) internal
    {
        _addIdentifier(activeKey, identifier);
    }

    /**
    *@dev removes an active identifier. See _removeIdentifier
    **/
    function _removeActiveIdentifier(uint256 index) internal
    {
        _removeIdentifier(activeKey, index);
    }

    /**
    *@dev adds an unconfirmed identifier. See _addIdentifier
    **/
    function _addUnconfirmedIdentifier(EqnoxStructs.GlobalListingIdentifier memory identifier) internal
    {
        _addIdentifier(unconfirmedKey, identifier);
    }

    /**
    *@dev removes an unconfirmed identifier. See _removeIdentifier
    **/
    function _removeUnconfirmedIdentifier(uint256 index) internal
    {
        _removeIdentifier(unconfirmedKey, index);
    }

    /**
    *@dev checks if listing is expired
    **/
    function _isUnconfirmedListingExpired(uint256 index) internal view returns (bool)
    {
        EqnoxStructs.GlobalListingIdentifier memory identifier = STORAGE_CONTRACT.globalListingIdentifiers(unconfirmedKey, index);
        return (identifier.expirationBlock < block.number);
    }

    /**
    *@dev searches for the next expired unconfirmed listing
    **/
    function _getNextExpiredUnconfirmed() internal view returns(bool, uint256) 
    {
        uint256 count = STORAGE_CONTRACT.globalIdentifierCount(unconfirmedKey);
        for(uint256 counter = 0; counter < count; counter++)
        {
            if(_isUnconfirmedListingExpired(counter))
            {
                return (true, counter);
            }
        }
        return (false, 0);
    }

    /**
    * @dev searches for an unconfirmed listing with the same characteristics as the stake
    **/
    function _lookUpSameUnconfirmedListing(EqnoxStructs.Stake memory stake) internal view returns(bool, uint256)
    {
        uint256 count = STORAGE_CONTRACT.globalIdentifierCount(unconfirmedKey);
        for(uint256 i = 0; i < count; i++)
        {
            EqnoxStructs.GlobalListingIdentifier memory id = STORAGE_CONTRACT.globalListingIdentifiers(unconfirmedKey, i);
            EqnoxStructs.Listing memory currentListing = STORAGE_CONTRACT.userListings(id.sellerAddress, id.listingId);
            if(_compareStakeToListing(stake, currentListing))
            {
                return (true, i);
            }
        }
        return (false, 0);
    }

    /**
    * @dev compares a stake to the data on a listing.
    **/
    function _compareStakeToListing(EqnoxStructs.Stake memory stake, EqnoxStructs.Listing memory listing) internal pure returns (bool)
    {
        return listing.startingTokenDay == stake.stakeStartTokenDay ||
                    listing.stakedAmount == stake.stakeAmount ||
                    listing.stakeShares == stake.shares;
    }
}

/**
* @dev The DEX manager contract handles the financial operations of the DEX
**/
abstract contract DexManager is ListingManager
{
    using SafeMath for uint256;

    /**
    *@dev deletes a listing that is unconfirmed in a certain position
    **/
    function _clearExpiredUnconfirmedListing(uint256 index) internal
    {
        EqnoxStructs.GlobalListingIdentifier memory expiredListingId = STORAGE_CONTRACT.globalListingIdentifiers(unconfirmedKey,index);
        EqnoxStructs.Listing memory expiredListing = STORAGE_CONTRACT.userListings(expiredListingId.sellerAddress,expiredListingId.listingId);
        expiredListing.state = EqnoxStructs.ListingState.Annulled;
        STORAGE_CONTRACT.setUserListing(expiredListingId.sellerAddress,expiredListingId.listingId, expiredListing);
        uint256 unconfirmedListingCount = STORAGE_CONTRACT.userUnconfirmedListingCount(expiredListingId.sellerAddress);
        STORAGE_CONTRACT.setUserUnconfirmedListingCount(expiredListing.sellerAddress,unconfirmedListingCount - 1);
        uint256 busdToMarketing = expiredListing.securityDeposit.div(2);
        STORAGE_CONTRACT.transferBusd(MKT_ADDRESS_1, busdToMarketing);
        STORAGE_CONTRACT.transferBusd(MKT_ADDRESS_2, busdToMarketing);
        _removeUnconfirmedIdentifier(index);
    }

    /**
    * @dev removes the next expired unconfirmed listing, sending the security deposit to the marketing wallets.
    **/
    function _clearNextExpiredUnconfirmedListing() internal
    {
        (bool isExpired, uint256 index) =_getNextExpiredUnconfirmed(); 
        require(isExpired, "The queue for listing confirmation is full. Please try again later.");
        _clearExpiredUnconfirmedListing(index);
    }

    /**
    * @dev Lists a stake.
    **/ 
    function listStake(bytes16 stakeId, uint256 price) external
    {
        require(IS_DEX_OPEN, "Activities at the DEX are currently unavailable");
        require(price >= MIN_LISTING_PRICE, "Listing price below minimum");
        require(price <= MAX_LISTING_PRICE, "Listing price above maximum");
        _listStake(msg.sender, stakeId, price);
    }

    /**
    * @dev Lists a stake. It first confirms if there are slots available. If no slots are found, then it tries to delete the next expired unconfirmed listing.
    *      The expired listing is annulled. The account sends the security deposit to the contract, and a listing is stored with data related to the stake.
    **/ 
    function _listStake(address sellerAddress, bytes16 stakeId, uint256 price) internal
    {

        require(STORAGE_CONTRACT.userUnconfirmedListingCount(sellerAddress) < MAX_USER_UNCONFIRMED_LISTINGS, "You have unconfirmed listings.");
        require(BUSD_CONTRACT.balanceOf(sellerAddress) >= SECURITY_DEPOSIT, "Account does not have enough BUSD to list stake");
        require(BUSD_CONTRACT.allowance(sellerAddress, address(STORAGE_CONTRACT)) >= SECURITY_DEPOSIT, "Not enough BUSD allowed to list stake");
        require(TOKEN_CONTRACT.stakeCount(sellerAddress) > 0, "Account has no stakes");

        if(STORAGE_CONTRACT.globalIdentifierCount(unconfirmedKey) == MAX_GLOBAL_UNCONFIRMED_LISTINGS)
        {
            _clearNextExpiredUnconfirmedListing();
        }

        EqnoxStructs.Stake memory stake = TOKEN_CONTRACT.stakes(sellerAddress, stakeId);
        require(stake.stakeId == stakeId, "No stake found");
        require(stake.stakeState == EqnoxStructs.StakeState.Active, "You can only list active stakes");

        require(STORAGE_CONTRACT.transferBusdFrom(sellerAddress, address(STORAGE_CONTRACT), SECURITY_DEPOSIT), "Unable to transfer required BUSD");

        (bool isFound, uint256 index) =_lookUpSameUnconfirmedListing(stake); 
        if(isFound)
        {
            require(_isUnconfirmedListingExpired(index), "There's a listing undergoing with the same characteristics");
            _clearExpiredUnconfirmedListing(index);
        }
        
        bytes16 newId = generateID(sellerAddress, STORAGE_CONTRACT.userListingCount(sellerAddress), 0x01);
        EqnoxStructs.Listing memory newListing;
        newListing.listingId = newId;
        newListing.stakeId = stakeId;
        newListing.state = EqnoxStructs.ListingState.Unconfirmed;
        newListing.price = price;
        newListing.sellerAddress = sellerAddress;
        newListing.stakedAmount =  stake.stakeAmount;
        newListing.startingTokenDay = stake.stakeStartTokenDay;
        newListing.stakeShares = stake.shares;
        newListing.securityDeposit = SECURITY_DEPOSIT;
        newListing.blockNumber = block.number;
        newListing.globalIndex = STORAGE_CONTRACT.globalIdentifierCount(unconfirmedKey);
        
        
        EqnoxStructs.GlobalListingIdentifier memory identifier;
        identifier.sellerAddress = sellerAddress;
        identifier.listingId = newId;
        identifier.expirationBlock = newListing.blockNumber + EXPIRATION_BLOCK_TIME;

        STORAGE_CONTRACT.setUserListing(sellerAddress,newId, newListing);
        STORAGE_CONTRACT.setUserListingCount(sellerAddress, STORAGE_CONTRACT.userListingCount(sellerAddress) + 1); 
        STORAGE_CONTRACT.setUserUnconfirmedListingCount(sellerAddress, STORAGE_CONTRACT.userUnconfirmedListingCount(sellerAddress) + 1); 
        _addUnconfirmedIdentifier(identifier);
        emit StakeListed(newId, sellerAddress, price, identifier.expirationBlock);
    }

    /**
    * @dev Generic method to list stakes according to a certain key
    **/ 
    function _globalListingPagination(string memory key, uint256 offset, uint256 length) internal view returns (EqnoxStructs.Listing[] memory listingList)
    {
        uint256 count = STORAGE_CONTRACT.globalIdentifierCount(key);
         if(offset >= count){
            listingList = new EqnoxStructs.Listing[](0);
            return listingList;
        }

        if(offset + length > count) {
            length = count - offset;
        }

        listingList = new EqnoxStructs.Listing[](length);

        uint256 end = offset + length;

        for(uint256 i = 0; offset < end; offset++) {
            EqnoxStructs.GlobalListingIdentifier memory id = STORAGE_CONTRACT.globalListingIdentifiers(key, i);
            listingList[i] = STORAGE_CONTRACT.userListings(id.sellerAddress, id.listingId);
            i++;
        }
    }

    /**
    * @dev Lists the active listings
    **/ 
    function activeListingPagination(uint256 offset, uint256 length) external view returns (EqnoxStructs.Listing[] memory listingList)
    {
        return _globalListingPagination(activeKey, offset, length);
    }  

    /**
    * @dev Lists the overall unconfirmed listings
    **/ 
    function unconfirmedListingPagination(uint256 offset, uint256 length) external view returns (EqnoxStructs.Listing[] memory listingList)
    {
        return _globalListingPagination(unconfirmedKey, offset, length);
    }

    /**
    * @dev Lists the stakes the address is selling
    **/ 
    function userListingPagination(address account, uint256 offset, uint256 length) external view returns (EqnoxStructs.Listing[] memory listingList)
    {
        uint256 count = STORAGE_CONTRACT.userListingCount(account);
        if(offset >= count) {
            listingList = new EqnoxStructs.Listing[](0);
            return listingList;
        }

        if(offset + length > count) {
            length = count - offset;
        }

        listingList = new EqnoxStructs.Listing[](length);
        
        uint256 end = offset + length;
        
        for(uint256 i = 0; offset < end; offset++) {
            bytes16 listingId = generateID(account, offset, 0x01);
            listingList[i] = STORAGE_CONTRACT.userListings(account, listingId);
            i++;
        }
    }

    /**
    * @dev Lists the stakes bought by the address
    **/ 
    function userBoughtListingPagination(address account, uint256 offset, uint256 length) external view returns (EqnoxStructs.Listing[] memory listingList)
    {
        uint256 count = STORAGE_CONTRACT.userBoughtListingCount(account);

        if(offset >= count) {
            listingList = new EqnoxStructs.Listing[](0);
            return listingList;
        }

        if(offset + length > count) {
            length = count - offset;
        }

        listingList = new EqnoxStructs.Listing[](length);
        
        uint256 end = offset + length;
        
        for(uint256 i = 0; offset < end; offset++) {
            EqnoxStructs.GlobalListingIdentifier memory id = STORAGE_CONTRACT.userBoughtListings(account,offset);
            listingList[i] = STORAGE_CONTRACT.userListings(id.sellerAddress, id.listingId);
            i++;
        }
    }

    /**
    *@dev Confirms an unconfirmed listing.
    **/
    function confirmListing(bytes16 listingId, bytes16 stakeId) external
    {
        require(STORAGE_CONTRACT.userUnconfirmedListingCount(msg.sender) > 0, "No unconfirmed listings available");
        _confirmListing(msg.sender, listingId, stakeId);
    }

    /**
    * @dev Confirms an unconfirmed listing by associating the transfered stake with the listing. The listings becomes active.
    **/ 
    function _confirmListing(address sellerAddress, bytes16 listingId, bytes16 stakeId) internal
    {
        address storageAddress = address(STORAGE_CONTRACT);
        EqnoxStructs.Stake memory stake = TOKEN_CONTRACT.stakes(storageAddress, stakeId);
        require(stake.stakeId == stakeId && stake.stakeState == EqnoxStructs.StakeState.Active, "No stake found");
        require(STORAGE_CONTRACT.stakeListing(stakeId) == bytes16(0x0), "Stake already listed");
        EqnoxStructs.Listing memory listing = STORAGE_CONTRACT.userListings(sellerAddress, listingId);
        require(listing.listingId == listingId, "No listing found");
        require(listing.state == EqnoxStructs.ListingState.Unconfirmed, "The listing must be unconfirmed");
        require(_compareStakeToListing(stake, listing), "The stake and the listing don't match");
        EqnoxStructs.Stake memory oldStake = TOKEN_CONTRACT.stakes(sellerAddress, listing.stakeId);
        require(oldStake.stakeState == EqnoxStructs.StakeState.Moved, "The stake hasn't been transfered to the contract");
        listing.stakeId = stakeId;
        listing.state = EqnoxStructs.ListingState.Active;
        EqnoxStructs.GlobalListingIdentifier memory identifier = STORAGE_CONTRACT.globalListingIdentifiers(unconfirmedKey, listing.globalIndex);
        _removeUnconfirmedIdentifier(listing.globalIndex);
        listing.globalIndex = STORAGE_CONTRACT.globalIdentifierCount(activeKey);
        _addActiveIdentifier(identifier);
        STORAGE_CONTRACT.setStakeListing(stakeId, listingId);
        STORAGE_CONTRACT.setUserUnconfirmedListingCount(sellerAddress, STORAGE_CONTRACT.userUnconfirmedListingCount(sellerAddress) - 1);
        STORAGE_CONTRACT.setUserListing(listing.sellerAddress, listing.listingId, listing);
        STORAGE_CONTRACT.setUserActiveListingCount(sellerAddress, STORAGE_CONTRACT.userActiveListingCount(sellerAddress) + 1);
        STORAGE_CONTRACT.approveBusd(storageAddress, listing.securityDeposit);
        STORAGE_CONTRACT.transferBusd(sellerAddress, listing.securityDeposit);
        emit ListingConfirmed(listing.listingId, sellerAddress);
    }

    /**
    * @dev Cancels a listing.
    **/
    function cancelListing(bytes16 listingId) external
    {
        _cancelListing(msg.sender, listingId);
    }

    /**
    * @dev Cancels a listing. Returns the stake to the owner
    **/
    function _cancelListing(address sellerAddress, bytes16 listingId) internal
    {
        EqnoxStructs.Listing memory listing = STORAGE_CONTRACT.userListings(sellerAddress, listingId);
        require(listing.listingId == listingId, "No listing found");
        require(listing.state == EqnoxStructs.ListingState.Active , "The listing must be  active.");
        _removeActiveIdentifier(listing.globalIndex);
        listing.state = EqnoxStructs.ListingState.Cancelled;
        STORAGE_CONTRACT.setUserListing(listing.sellerAddress, listing.listingId, listing);
        STORAGE_CONTRACT.setUserActiveListingCount(sellerAddress, STORAGE_CONTRACT.userActiveListingCount(sellerAddress) - 1);
        STORAGE_CONTRACT.moveStake(listing.stakeId, listing.sellerAddress);
        emit ListingCancelled(listingId, sellerAddress);
    }
    
    /**
    * @dev Executes the purchase of a stake.
    **/
    function buyStake(address sellerAddress, bytes16 listingId) external
    {
        _buyStake(msg.sender, sellerAddress, listingId);
    }

    /**
    * @dev Executes the purchase of a stake, transfering the stake to the buyer, and the amount to user and marketing.
    **/
    function _buyStake(address buyerAddress, address sellerAddress, bytes16 listingId) internal
    {
        EqnoxStructs.Listing memory listing = STORAGE_CONTRACT.userListings(sellerAddress, listingId);
        require(listing.listingId == listingId, "No listing found");
        require(listing.state == EqnoxStructs.ListingState.Active, "The listing must be active.");

        uint256 busdToStakeOwner = listing.price.mul(MKT_DENOMINATOR.sub(MKT_NUMERATOR)).div(MKT_DENOMINATOR);
        uint256 busdToMarketing = (listing.price.sub(busdToStakeOwner)).div(2);

        STORAGE_CONTRACT.transferBusdFrom(buyerAddress, MKT_ADDRESS_1, busdToMarketing);
        STORAGE_CONTRACT.transferBusdFrom(buyerAddress, MKT_ADDRESS_2, busdToMarketing);
        STORAGE_CONTRACT.transferBusdFrom(buyerAddress, listing.sellerAddress, busdToStakeOwner);

        STORAGE_CONTRACT.moveStake(listing.stakeId, buyerAddress);
        listing.state = EqnoxStructs.ListingState.Sold;

        STORAGE_CONTRACT.setUserActiveListingCount(sellerAddress, STORAGE_CONTRACT.userActiveListingCount(sellerAddress) - 1);
        STORAGE_CONTRACT.setUserListing(listing.sellerAddress, listing.listingId, listing);

        uint256 boughtListingCount = STORAGE_CONTRACT.userBoughtListingCount(buyerAddress);
        EqnoxStructs.GlobalListingIdentifier memory identifier = STORAGE_CONTRACT.globalListingIdentifiers(activeKey, listing.globalIndex);
        STORAGE_CONTRACT.setUserBoughtListingIdentifier(buyerAddress, boughtListingCount, identifier);
        STORAGE_CONTRACT.setUserBoughtListingCount(buyerAddress, boughtListingCount + 1);

        _removeActiveIdentifier(listing.globalIndex);

        emit StakeBought(listingId, sellerAddress, buyerAddress);
    }

    /**
    * @dev fetches the index for the next expired unconfirmed listing.
    **/
    function nextExpiredUnconfirmed() external view returns(bool, uint256)
    {
        return _getNextExpiredUnconfirmed();
    }
}

contract Dex is DexManager
{
    address public DEX_MANAGER;

    modifier onlyDexManager() {
        require(
            msg.sender == DEX_MANAGER,
            "Wrong sender."
        );
        _;
    }

    /**
    *@dev switches the DEX state.
    **/
    function switchDex() external onlyDexManager {
        IS_DEX_OPEN=!IS_DEX_OPEN;
    }

    /**
    * @dev set the marketing denominator. MKT% = numerator/denominator*100.
    **/
    function setMarketingDenominator(uint256 denominator) external onlyDexManager
    {
        MKT_DENOMINATOR = denominator;
    }

    /**
    * @dev set the marketing numerator. MKT% = numerator/denominator*100.
    **/
    function setMarketingNumerator(uint256 numerator) external onlyDexManager
    {
        MKT_NUMERATOR = numerator;
    }

    /**
    * @dev Sets the maximum price for a listing. Expected value N is N*10E18
    */
    function setMaxListingPrice(uint256 price) external onlyDexManager
    {
        require(price > 0, "Value cannot be 0");
        MAX_LISTING_PRICE = price;
    }

    /**
    * @dev Sets the minimum price for a listing. Expected value N is N*10E18
    */
    function setMinListingPrice(uint256 price) external onlyDexManager
    {
        require(price > 0, "Value cannot be 0");
        MIN_LISTING_PRICE = price;
    }
    
    
    /**
    * @dev sets the amount of blocks required for a listing to expire. 1 block ~ 3.5s 
    **/
    function setExpirationBlockTimespan(uint256 blockSpan) external onlyDexManager
    {
        EXPIRATION_BLOCK_TIME = blockSpan;
    }
 
    /**
    * @dev sets the EQNOX token address
    **/
    function setTokenContract(address contractAddress) external onlyDexManager
    {
        TOKEN_CONTRACT = IToken(contractAddress);
    }

    /**
    * @dev sets the DEX storage contract
    **/
    function setDexStorageContract(address contractAddress) external onlyDexManager
    {
        STORAGE_CONTRACT = IDexStorage(contractAddress);
    }

    /**
    * @dev sets the first marketing address
    **/
    function setMarketingAddress1(address marketingAddress) external onlyDexManager
    {
        MKT_ADDRESS_1 = marketingAddress;
    }

    /**
    * @dev sets the second marketing address
    **/
    function setMarketingAddress2(address marketingAddress) external onlyDexManager
    {
        MKT_ADDRESS_2 = marketingAddress;
    }

    /**
    * @dev changes the security deposit needed to make a listing. Expected value N is N*10E18
    **/
    function setSecurityDeposit(uint256 deposit) external onlyDexManager
    {
        SECURITY_DEPOSIT = deposit;
    }

     /**
    * @dev changes the maximum amount of overall unconfirmed listings for a user. 
    **/       
    function setMaxUserUnconfirmedListings(uint256 listings) external onlyDexManager
    {
        require(listings> 0, "Value cannot be 0");
        MAX_USER_UNCONFIRMED_LISTINGS = listings;
    }
 
     /**
    * @dev changes the maximum amount of overall unconfirmed listings.
    **/
    function setMaxGlobalUnconfirmedListings(uint256 listings) external onlyDexManager
    {
        require(listings> 0, "Value cannot be 0");
        MAX_GLOBAL_UNCONFIRMED_LISTINGS = listings;
    }

    function revokeAccess() external onlyDexManager {
        DEX_MANAGER = address(0x0);
    }

    /**
    * @dev cancels a listing. Can be deleted if necessary.
    **/
    function cancelUserListing(address sellerAddress, bytes16 listingId) external onlyDexManager
    {
        return _cancelListing(sellerAddress, listingId);
    }

    /**
   * @dev transfers a stake to an account as long as it's not associated to a listing
   **/
    function transferUnlistedStake(address toAddress, bytes16 stakeId) external onlyDexManager
    {
        require(STORAGE_CONTRACT.stakeListing(stakeId) == bytes16(0x0), "The stake is associated to a listing");
        STORAGE_CONTRACT.moveStake(stakeId, toAddress);
    }

   /**
   * @dev transfers BUSD on the contract to an account
   **/
    function transferBusd(address toAddress, uint256 amount) external onlyDexManager
    {
        STORAGE_CONTRACT.transferBusd(toAddress, amount);
    }

    constructor()
     {
        DEX_MANAGER = msg.sender;

        BUSD_CONTRACT = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        MKT_ADDRESS_1 = address(0xeAdb283c3459fE9cD3d87966F00F536372dD7167);
        MKT_ADDRESS_2 = address(0x1720b3f672AE3811D14086B502Aab83aC4F4a302);
        TOKEN_CONTRACT = IToken(0x05486aDfD491130FCD38233c1Cb125FCb2bFb803);
        EXPIRATION_BLOCK_TIME = 600;
        IS_DEX_OPEN = true;
        MAX_GLOBAL_UNCONFIRMED_LISTINGS = 5;
        MAX_LISTING_PRICE = 25000e18;
        MIN_LISTING_PRICE = 5e18;
        MAX_USER_UNCONFIRMED_LISTINGS = 1;
        MKT_NUMERATOR = 2;
        MKT_DENOMINATOR = 100;
        SECURITY_DEPOSIT = 25e18;
     }
}