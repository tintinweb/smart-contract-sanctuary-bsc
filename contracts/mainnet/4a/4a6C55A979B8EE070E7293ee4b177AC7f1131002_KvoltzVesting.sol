// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./BEP20.sol";

contract KvoltzVesting is Ownable{

    BEP20 private kvoltzToken;
    BEP20 private busdToken;
    address constant BUSD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    mapping(address => uint) private seedSaleTokens;
    mapping(address => uint) private seedSaleTokensReceived;
    mapping(address => uint) private privateSaleTokens;
    mapping(address => uint) private privateSaleTokensReceived;
    mapping(address => uint) private advisorsTokens;
    mapping(address => uint) private advisorsTokensReceived;
    mapping(address => uint) private airdropTokens;
    mapping(address => uint) private airdropTokensReceived;
    mapping(address => bool) private isAdmin;

    address[] private seedSaleBuyers;
    address[] private privateSaleBuyers;
    address[] private advisors;
    address[] private airdrop;
    address immutable private mainWallet;

    bool private seedSaleOpen;
    bool private privateSaleOpen;
    bool private tgeSet;

    uint private tgeTimestamp;

    uint constant ONE_MONTH_IN_SECONDS = 2592000;

    uint constant SEED_TOKENS = 8000000 ether;
    uint constant SEED_CLIFF = 90 days;
    uint constant SEED_VESTING = 950; //9.5%
    uint constant SEED_TGE = 500; //5%

    uint constant PRIVATE_TOKENS = 10000000 ether;
    uint constant PRIVATE_CLIFF = 60 days;
    uint constant PRIVATE_VESTING = 925; //9.25%
    uint constant PRIVATE_TGE = 750; //7.5%

    uint constant ADVISORS_TOKENS = 3000000 ether;
    uint constant ADVISORS_CLIFF = 90 days;
    uint constant ADVISORS_VESTING = 950; //9.5%
    uint constant ADVISORS_TGE = 500; //5%

    uint constant AIRDROP_TOKENS = 1000000 ether;
    uint constant AIRDROP_CLIFF = 120 days;
    uint constant AIRDROP_VESTING = 950; //9.5%
    uint constant AIRDROP_TGE = 500; //5%

    event KvoltzAddressUpdated(address _kvoltzTokenAddress);
    event BUSDAddressUpdated(address _busdTokenAddress);
    event AdminStatusSet(address _address, bool _status);
    event SeedSalePurchased(uint _amount, address _address);
    event PrivateSalePurchased(uint _amount, address _address);
    event AdvisorsAdded(uint[] _amountKVZ, address[] _address);
    event AirdropAdded(uint[] _amountKVZ, address[] _address);
    event SeedSaleStatusChanged(bool _bool);
    event PrivateSaleStatusChanged(bool _bool);
    event TokenGenerationEventStarted();
    event TokensDistributed();

    constructor(address _mainWallet){
        busdToken = BEP20(BUSD_ADDRESS);
        seedSaleOpen = false;
        privateSaleOpen = false;
        mainWallet = _mainWallet;
        tgeSet = false;
        isAdmin[msg.sender] = true;
    }

    /*  Sets the token that will be vested by this Smart Contract. 
        It should be called as soon as the KVOLTZ token is deployed.
    */

    function setKvoltzTokenAddress(address _kvoltzTokenAddress) external onlyOwner{
        kvoltzToken = BEP20(_kvoltzTokenAddress);
        emit KvoltzAddressUpdated(_kvoltzTokenAddress);
    }

    /*  Sets the token that will used to buy the Seed/Private Sale.
        This token is set to BUSD by default, so it might not be necessary.
    */

    function setBUSDTokenAddress(address _busdTokenAddress) external onlyOwner{
        busdToken = BEP20(_busdTokenAddress);
        emit BUSDAddressUpdated(_busdTokenAddress);
    }

    /*  Gives Admin privileges to a wallet.*/

    function setAdmin(address _address, bool _status) external onlyOwner{
        isAdmin[_address] = _status;
        emit AdminStatusSet(_address, _status);
    }

    /* Returns the total amount of active vesting tokens in the Seed Sale.*/

    function getSeedTokens() public view returns(uint seedTokensSold){
        uint seedTokensSum = 0;
        for(uint i = 0; i < seedSaleBuyers.length; i++){
            address receiverSeed = seedSaleBuyers[i];
            seedTokensSum += seedSaleTokens[receiverSeed];
        }
        seedTokensSold = seedTokensSum;
    }

    /* Returns the total amount of active vesting tokens in the Private Sale.*/

    function getPrivateTokens() public view returns(uint privateTokensSold){
        uint privateTokensSum = 0;
        for(uint i = 0; i < privateSaleBuyers.length; i++){
            address receiverPrivate = privateSaleBuyers[i];
            privateTokensSum += privateSaleTokens[receiverPrivate];
        }
        privateTokensSold = privateTokensSum;
    }

    /* Returns the total amount of active vesting tokens for advisors.*/

    function getAdvisorsTokens() public view returns(uint advisorsTokensSold){
        uint advisorsTokensSum = 0;
        for(uint i = 0; i < advisors.length; i++){
            address receiveradvisors = advisors[i];
            advisorsTokensSum += advisorsTokens[receiveradvisors];
        }
        advisorsTokensSold = advisorsTokensSum;
    }

    /* Returns the total amount of active vesting tokens in the Airdrop.*/

    function getAirdropTokens() public view returns(uint airdropTokensSold){
        uint airdropTokensSum = 0;
        for(uint i = 0; i < airdrop.length; i++){
            address receiverairdrop = airdrop[i];
            airdropTokensSum += airdropTokens[receiverairdrop];
        }
        airdropTokensSold = airdropTokensSum;
    }

    /*  Allows the caller to buy Seed Sale tokens.
        Minimum amount is 5000 BUSD by default.
    */

    function buySeedSale(uint _amount) external{
        require(seedSaleOpen == true, "Seed Sale is closed.");
        require( _amount >= 5000 * 1 ether, "Seed Sale minimum amount is 5000 BUSD.");
        require(getSeedTokens() + _amount <= SEED_TOKENS, "Seed Sale cap reached.");
        busdToken.transferFrom(msg.sender, mainWallet, _amount);
        if(seedSaleTokens[msg.sender] == 0){
            seedSaleBuyers.push(msg.sender);
        }
        seedSaleTokens[msg.sender] += _amount * 100 / 5; // Price: 0,05 BUSD
        emit SeedSalePurchased(_amount, msg.sender);
    }

    /*  Allows the caller to buy Private Sale tokens.
        Minimum amount is 100 BUSD by default.
    */

    function buyPrivateSale(uint _amount) external{
        require(privateSaleOpen == true, "Seed Sale is closed.");
        require( _amount >= 100 * 1 ether, "Private Sale minimum amount is 100 BUSD.");
        require(getPrivateTokens() + _amount <= PRIVATE_TOKENS, "Private Sale cap reached.");
        busdToken.transferFrom(msg.sender, mainWallet, _amount);
        if(privateSaleTokens[msg.sender] == 0){
            privateSaleBuyers.push(msg.sender);
        }
        privateSaleTokens[msg.sender] += _amount * 100 / 6; // Price: 0,06 BUSD
        emit PrivateSalePurchased(_amount, msg.sender);
    }

    /*  Allows the admin to allocate Seed Sale tokens to a wallet.
        Minimum amount is 5000 BUSD by default.
    */

    function buySeedSalePix(uint _amount, address _address) external{
        require(isAdmin[msg.sender], "Caller is not an Admin");
        require(seedSaleOpen == true, "Seed Sale is closed.");
        require( _amount >= 5000 * 1 ether, "Seed Sale minimum amount is 5000 BUSD.");
        require(getSeedTokens() + _amount <= SEED_TOKENS, "Seed Sale cap reached.");
        if(seedSaleTokens[_address] == 0){
            seedSaleBuyers.push(_address);
        }
        seedSaleTokens[_address] += _amount * 100 / 5;
        emit SeedSalePurchased(_amount, _address);
    }

    /*  Allows the admin to allocate Private Sale tokens to a wallet.
        Minimum amount is 100 BUSD by default.
    */

    function buyPrivateSalePix(uint _amount, address _address) external{
        require(isAdmin[msg.sender], "Caller is not an Admin");
        require(privateSaleOpen == true, "Private Sale is closed.");
        require( _amount >= 100 * 1 ether, "Private Sale minimum amount is 100 BUSD.");
        require(getPrivateTokens() + _amount <= PRIVATE_TOKENS, "Private Sale cap reached.");
        if(privateSaleTokens[_address] == 0){
            privateSaleBuyers.push(_address);
        }
        privateSaleTokens[_address] += _amount * 100 / 6;
        emit PrivateSalePurchased(_amount, _address);
    }

    /*  Allows the admin to allocate Advisors tokens to a wallet.
        Arguments are arrays to allow multiple inclusions in a single call.
    */

    function setAdvisor(uint[] calldata _amountKVZ, address[] calldata _address) external onlyOwner{
        require(_amountKVZ.length == _address.length, "Each Address must have an amount.");
        uint tokensSum = 0;
        for(uint i = 0; i < _amountKVZ.length; i++){
            if(advisorsTokens[_address[i]] == 0){
                advisors.push(_address[i]);
            }
            advisorsTokens[_address[i]] += _amountKVZ[i];
            tokensSum += _amountKVZ[i];
        }
        require(getAdvisorsTokens() + tokensSum <= ADVISORS_TOKENS, "Advisors cap reached.");
        emit AdvisorsAdded(_amountKVZ, _address);
    }

    /*  Allows the admin to allocate Airdrop tokens to a wallet.
        Arguments are arrays to allow multiple inclusions in a single call.
    */

    function setAirdrop(uint[] calldata _amountKVZ, address[] calldata _address) external onlyOwner{
        require(_amountKVZ.length == _address.length, "Each Address must have an amount.");
        uint tokensSum = 0;
        for(uint i = 0; i < _amountKVZ.length; i++){
            if(advisorsTokens[_address[i]] == 0){
                airdrop.push(_address[i]);
            }
            airdropTokens[_address[i]] += _amountKVZ[i];
            tokensSum += _amountKVZ[i];
        }
        require(getAirdropTokens() + tokensSum <= AIRDROP_TOKENS, "Airdrop cap reached.");
        emit AirdropAdded(_amountKVZ, _address);
    }

    /* Allows to Open and Close the Seed Sale.*/

    function setSeedSaleStatus(bool _bool) external onlyOwner{
        seedSaleOpen = _bool;
        emit SeedSaleStatusChanged(_bool);
    }

    /* Allows to Open and Close the Private Sale.*/

    function setPrivateSaleStatus(bool _bool) external onlyOwner{
        privateSaleOpen = _bool;
        emit PrivateSaleStatusChanged(_bool);
    }

    /* Returns the remaining amount of Seed Sale vesting tokens of a wallet.*/

    function getAddressSeedSaleTokens(address _address) public view returns(uint){
        return (seedSaleTokens[_address] - seedSaleTokensReceived[_address]);
    }

    /* Returns the remaining amount of Private Sale vesting tokens of a wallet.*/

    function getAddressPrivateSaleTokens(address _address) public view returns(uint){
        return (privateSaleTokens[_address] - privateSaleTokensReceived[_address]);
    }

    /* Returns the remaining amount of Advisors vesting tokens of a wallet.*/

    function getAdvisorsTokens(address _address) public view returns(uint){
        return (advisorsTokens[_address] - advisorsTokensReceived[_address]);
    }

    /* Returns the remaining amount of Airdrop vesting tokens of a wallet.*/

    function getAirdropTokens(address _address) public view returns(uint){
        return (airdropTokens[_address] - airdropTokensReceived[_address]);
    }

    /*  Sets the starting timestamp for the vesting period.
        Also distributes the TGE tokens percentage.
    */

    function tokenGenerationEvent() external onlyOwner{
        require(!tgeSet, "TGE already set.");
        tgeTimestamp = block.timestamp;
        for(uint i = 0; i < seedSaleBuyers.length; i++){
            address receiverSeed = seedSaleBuyers[i];
            uint availableTokensSeed = seedSaleTokens[receiverSeed]*SEED_TGE/10000;
            kvoltzToken.transfer(receiverSeed, availableTokensSeed);
        }
        for(uint i = 0; i < privateSaleBuyers.length; i++){
            address receiverPrivate = privateSaleBuyers[i];
            uint availableTokensPrivate = privateSaleTokens[receiverPrivate]*PRIVATE_TGE/10000;
            kvoltzToken.transfer(receiverPrivate, availableTokensPrivate);
        }
        for(uint i = 0; i < advisors.length; i++){
            address receiverAdvisors = advisors[i];
            uint availableTokensAdvisors = advisorsTokens[receiverAdvisors]*ADVISORS_TGE/10000;
            kvoltzToken.transfer(receiverAdvisors, availableTokensAdvisors);
        }
        for(uint i = 0; i < airdrop.length; i++){
            address receiverAirdrop = airdrop[i];
            uint availableTokensAirdrop = airdropTokens[receiverAirdrop]*AIRDROP_TGE/10000;
            kvoltzToken.transfer(receiverAirdrop, availableTokensAirdrop);
        }
        tgeSet = true;
        emit TokenGenerationEventStarted();
    }

    /*  Returns the total amount of tokens that can currently be distributed.
        Should only be called after TGE is set, but can be called before to return the total amount of tokens that will be distributed.
    */

    function getAvailableTokens() external view returns(
        uint currentSeedSaleTokens, 
        uint currentPrivateSaleTokens, 
        uint currentAdvisorsTokens,
        uint currentAirdropTokens){
        uint currentTime = block.timestamp - tgeTimestamp;
        if(currentTime > SEED_CLIFF){
            uint seedVestingTime = currentTime - SEED_CLIFF;
            uint availableParcelsSeed = seedVestingTime/ONE_MONTH_IN_SECONDS + 1; 
            if(availableParcelsSeed>10){
                availableParcelsSeed = 10;
            }
            for(uint i = 0; i < seedSaleBuyers.length; i++){
                address receiverSeed = seedSaleBuyers[i];
                uint availableTokensSeed = seedSaleTokens[receiverSeed]*SEED_VESTING*availableParcelsSeed/10000 - seedSaleTokensReceived[receiverSeed];
                currentSeedSaleTokens = availableTokensSeed;
            }
        }
        if(currentTime > PRIVATE_CLIFF){
            uint privateVestingTime = currentTime - PRIVATE_CLIFF;
            uint availableParcelsPrivate = privateVestingTime/ONE_MONTH_IN_SECONDS + 1; 
            if(availableParcelsPrivate>10){
                availableParcelsPrivate = 10;
            }
            for(uint i = 0; i < privateSaleBuyers.length; i++){
                address receiverPrivate = privateSaleBuyers[i];
                uint availableTokensPrivate = privateSaleTokens[receiverPrivate]*PRIVATE_VESTING*availableParcelsPrivate/10000 - privateSaleTokensReceived[receiverPrivate];
                currentPrivateSaleTokens = availableTokensPrivate;
            }
        }
        if(currentTime > ADVISORS_CLIFF){
            uint advisorVestingTime = currentTime - ADVISORS_CLIFF;
            uint availableParcelsAdvisors = advisorVestingTime/ONE_MONTH_IN_SECONDS + 1; 
            if(availableParcelsAdvisors>10){
                availableParcelsAdvisors = 10;
            }
            for(uint i = 0; i < advisors.length; i++){
                address receiverAdvisors = advisors[i];
                uint availableTokensAdvisors = advisorsTokens[receiverAdvisors]*ADVISORS_VESTING*availableParcelsAdvisors/10000 - advisorsTokensReceived[receiverAdvisors];
                currentAdvisorsTokens = availableTokensAdvisors;
            }
        }
        if(currentTime > AIRDROP_CLIFF){
            uint airdropVestingTime = currentTime - AIRDROP_CLIFF;
            uint availableParcelsAirdrop = airdropVestingTime/ONE_MONTH_IN_SECONDS + 1; 
            if(availableParcelsAirdrop>10){
                availableParcelsAirdrop = 10;
            }
            for(uint i = 0; i < airdrop.length; i++){
                address receiverAirdrop = airdrop[i];
                uint availableTokensAirdrop = airdropTokens[receiverAirdrop]*AIRDROP_VESTING*availableParcelsAirdrop/10000 - airdropTokensReceived[receiverAirdrop];
                currentAirdropTokens = availableTokensAirdrop;
            }
        }

    }

    /*  Allows the admin to distribute all available vesting tokens.
        Should be called monthly. 
    */

    function distributeTokens() external{
        require(isAdmin[msg.sender], "Caller is not an Admin");
        require(tgeSet, "Token Generation Event timestamp is not set.");
        uint currentTime = block.timestamp - tgeTimestamp;
        if(currentTime > SEED_CLIFF){
            uint seedVestingTime = currentTime - SEED_CLIFF;
            uint availableParcelsSeed = seedVestingTime/ONE_MONTH_IN_SECONDS + 1; 
            if(availableParcelsSeed>10){
                availableParcelsSeed = 10;
            }
            for(uint i = 0; i < seedSaleBuyers.length; i++){
                address receiver = seedSaleBuyers[i];
                uint availableTokensSeed = seedSaleTokens[receiver]*SEED_VESTING*availableParcelsSeed/10000 - seedSaleTokensReceived[receiver];
                kvoltzToken.transfer(receiver, availableTokensSeed);
                seedSaleTokensReceived[receiver] += availableTokensSeed;
            }
        }
        if(currentTime > PRIVATE_CLIFF){
            uint privateVestingTime = currentTime - PRIVATE_CLIFF;
            uint availableParcelsPrivate = privateVestingTime/ONE_MONTH_IN_SECONDS + 1; 
            if(availableParcelsPrivate>10){
                availableParcelsPrivate = 10;
            }
            for(uint i = 0; i < privateSaleBuyers.length; i++){
                address receiver = privateSaleBuyers[i];
                uint availableTokensPrivate = privateSaleTokens[receiver]*PRIVATE_VESTING*availableParcelsPrivate/10000 - privateSaleTokensReceived[receiver];
                kvoltzToken.transfer(receiver, availableTokensPrivate);
                privateSaleTokensReceived[receiver] += availableTokensPrivate;
            }
        }
        if(currentTime > ADVISORS_CLIFF){
            uint advisorsVestingTime = currentTime - ADVISORS_CLIFF;
            uint availableParcelsAdvisors = advisorsVestingTime/ONE_MONTH_IN_SECONDS + 1; 
            if(availableParcelsAdvisors>10){
                availableParcelsAdvisors = 10;
            }
            for(uint i = 0; i < advisors.length; i++){
                address receiverAdvisors = advisors[i];
                uint availableTokensAdvisors = advisorsTokens[receiverAdvisors]*ADVISORS_VESTING*availableParcelsAdvisors/10000 - advisorsTokensReceived[receiverAdvisors];
                kvoltzToken.transfer(receiverAdvisors, availableTokensAdvisors);
                advisorsTokensReceived[receiverAdvisors] += availableTokensAdvisors;
            }
        }
        if(currentTime > AIRDROP_CLIFF){
            uint airdropVestingTime = currentTime - AIRDROP_CLIFF;
            uint availableParcelsAirdrop = airdropVestingTime/ONE_MONTH_IN_SECONDS + 1; 
            if(availableParcelsAirdrop>10){
                availableParcelsAirdrop = 10;
            }
            for(uint i = 0; i < airdrop.length; i++){
                address receiverAirdrop = airdrop[i];
                uint availableTokensAirdrop = airdropTokens[receiverAirdrop]*AIRDROP_VESTING*availableParcelsAirdrop/10000 - airdropTokensReceived[receiverAirdrop];
                kvoltzToken.transfer(receiverAirdrop, availableTokensAirdrop);
                airdropTokensReceived[receiverAirdrop] += availableTokensAirdrop;
            }
        }
        emit TokensDistributed();
        
    }

    /*  Allows the Owner to withdraw BUSD tokens from this contract.
        Should only be necessary if BUSD is mistakenly sent directly to the contract.
    */

    function withdraw() external onlyOwner{
        uint balance__ = busdToken.balanceOf(address(this));
        busdToken.transfer(msg.sender, balance__);
    }
}