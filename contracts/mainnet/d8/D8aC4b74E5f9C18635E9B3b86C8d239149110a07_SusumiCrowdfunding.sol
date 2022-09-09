// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./libraries/TransferHelper.sol";
import "./libraries/SusuLibrary.sol";
import "./utils/OwnableCrowd.sol";
import "./utils/ReentrancyGuard.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ISusumiCrowdfunding.sol";

contract SusumiCrowdfunding is Ownable, ReentrancyGuard, ISusumiCrowdfunding {
    uint256 public activationValueCount; // Total Susu tokens invested in the contract
    uint128 public totalCampaigns; // Total number of campaigns in the contract
    uint128 public totalAmountRaised; // Total amount in USD donated in the campaign
    uint128 public topCampaign; // Campaign with the top amount raised
    uint128 public receiverFeeSUSU; // receiver fee while a user creates a custom campaign
    uint64 public decimalValue; // SUSU decimalfactor
    uint64 public price; // in USDT
    uint32 public defaultMaturityPeriod;

    address public receiverAddress; // receiver where fee will get transferred

    mapping(address => uint8) public userLevel; // To store the current level of the user
    mapping(address => uint128) public userCurrentCampaign; // To check if user has already created a campaign (Only 1 campaign at a time)
    mapping(address => uint128) public userTotalFunds; // Total funds raised by the user in BUSD
    mapping(address => uint128) public userTotalDonations; // Total donation by the user in BUSD
    mapping(uint128 => bool) public isCampaignActive; // A check if the campaign is active or not
    mapping(uint128 => SusuLibrary.Campaign) public campaignInfo; // Mapping to the Campaign struct using index
    mapping(address => mapping(uint128 => SusuLibrary.User)) public userInfo; // Mapping to the User struct using user's address
    mapping(uint128 => SusuLibrary.VestingInfo) public vestingMapping; // Vesting Mapping
    mapping(uint128 => SusuLibrary.SusuValueInfo) public susuValueMapping; // Mapping to store Susu Value Info

    Token public susu; // SUSU token
    Token public busd; // BUSD token

    /* ==================== INITIALIZE FUNCTION SECTION ==================== */

    // Receive Function
    receive() external payable {
        // Sending deposited currency to the receiver address
        TransferHelper.safeTransferETH(receiverAddress, msg.value);
    }

    // Setting the SUSU token address, decimalfactor and price in USDT at the time of deployment.
    constructor(
        address _SUSUAddress,
        address _receiverAddress,
        address _BUSDAddress
    ) {
        susu = Token(_SUSUAddress);
        decimalValue = uint64(10**susu.decimals());
        price = 10**6; // In 10 ** 8 ($0.01)
        defaultMaturityPeriod = 24 hours;
        receiverAddress = _receiverAddress;
        receiverFeeSUSU = uint128(100 * (10**susu.decimals())); // Fee in SUSU
        busd = Token(_BUSDAddress);
        uint128 _busdDecimals = uint128(10**(busd.decimals()));

        // For Testing
        setSusuValueInfo(
            1,
            10 * _busdDecimals,
            100 * _busdDecimals,
            2,
            2,
            8300,
            30 minutes
        ); // For level 1
        setSusuValueInfo(
            2,
            20 * _busdDecimals,
            200 * _busdDecimals,
            2,
            60,
            5200,
            30 minutes
        ); // For level 2
        setSusuValueInfo(
            3,
            30 * _busdDecimals,
            300 * _busdDecimals,
            2,
            25000,
            2100,
            30 minutes
        ); // For level 3
    }

    /* ==================== SUSU VALUE INFO SECTION ==================== */

    // Sets Susu Value limits for different levels
    function setSusuValueInfo(
        uint8 _userLevel,
        uint128 _minSusuValue,
        uint128 _maxSusuValue,
        uint32 _minKeyValue,
        uint32 _maxKeyValue,
        uint32 _receiverFee,
        uint32 _vestingPeriod
    ) internal onlyOwner {
        // Maximum level allowed is 3
        require(_userLevel <= 3, "Level cannot be greater than 3");

        susuValueMapping[_userLevel] = SusuLibrary.SusuValueInfo({
            userLevel: _userLevel,
            minSusuValue: _minSusuValue,
            maxSusuValue: _maxSusuValue,
            minKeyValue: _minKeyValue,
            maxKeyValue: _maxKeyValue,
            receiverFee: _receiverFee,
            vestingPeriod: _vestingPeriod
        });
    }

    /* ==================== CAMPAIGN CREATION SECTION ==================== */

    // Create a new Campaign with Index number starting from 1. Also changes the user level to 1 if 0
    function createCampaign(
        uint128 _susuValue,
        uint8 _level,
        uint256 _ID
    ) external override nonReentrant checkUserCampaignStatus {
        setLevelAndCheckValue(_susuValue, _level);

        campaignInternal(
            _susuValue,
            susuValueMapping[_level].minKeyValue,
            _level,
            msg.sender,
            _ID
        );
    }

    function campaignInternal(
        uint128 _susuValue,
        uint32 _slot,
        uint8 _level,
        address userAddress,
        uint256 _ID
    ) internal {
        // Susu value staked
        uint128 _susuActivation = calculateSUSUActivation(_susuValue, _slot);

        checkSusuAmount(_susuActivation, userAddress);

        // Price changed since tokens are added to the contract
        uint64 _pricePercentage = calculatePriceShare(_susuActivation); // in 10**8
        price = price - uint64(((price * _pricePercentage)) / ((10**8) * 100));

        newCampaignInternal(
            _susuValue,
            _susuActivation,
            _slot,
            _level,
            userAddress,
            _ID
        );

        // Susu activation sent to the contract
        TransferHelper.safeTransferFrom(
            address(susu),
            userAddress,
            address(this),
            _susuActivation
        );
    }

    function newCampaignInternal(
        uint128 _SusuValue,
        uint128 _susuActivation,
        uint32 _slot,
        uint8 _level,
        address _userAddress,
        uint256 _ID
    ) internal {
        // New campaign is created in struct
        SusuLibrary.Campaign memory newCampaign = SusuLibrary.Campaign({
            creator: _userAddress,
            susuValue: _SusuValue,
            susuValueRaised: 0,
            tokenPrice: price,
            slots: _slot,
            slotValue: _SusuValue / _slot,
            totalRewards: uint128(
                (uint256(_SusuValue * decimalValue)) / (uint256(price))
            ),
            susuActivation: _susuActivation,
            expirationTime: 0,
            levelValue: _level,
            maturityTime: uint32(block.timestamp) + defaultMaturityPeriod,
            isClaimed: false
        });

        ++totalCampaigns;

        campaignInfo[totalCampaigns] = newCampaign;
        isCampaignActive[totalCampaigns] = true;
        userCurrentCampaign[_userAddress] = totalCampaigns;

        // Activation Value Count increases
        activationValueCount += _susuActivation;

        // Event emitted
        emit CampaignCreated(
            _ID,
            totalCampaigns,
            newCampaign.susuValue,
            newCampaign.susuValueRaised,
            newCampaign.slotValue,
            newCampaign.totalRewards,
            newCampaign.susuActivation,
            newCampaign.tokenPrice,
            newCampaign.slots,
            newCampaign.expirationTime,
            newCampaign.maturityTime,
            newCampaign.creator,
            newCampaign.isClaimed,
            isCampaignActive[totalCampaigns]
        );
    }

    // Requesting custom campaign (Only Level 2 and above users)
    function requestCustomCampaign(
        uint128 _susuValue,
        uint32 _slot,
        uint8 _level,
        uint256 _ID
    ) external override nonReentrant checkUserCampaignStatus {
        setLevelAndCheckValue(_susuValue, _level);

        // Only level 2 or above user can request
        require(_level >= 2, "User not applicable for this type of fund");

        SusuLibrary.SusuValueInfo memory sInfo = susuValueMapping[_level];

        // Slot value should be in the limit specified
        require(
            _slot >= sInfo.minKeyValue && _slot <= sInfo.maxKeyValue,
            "Check your key(slot) value"
        );

        uint128 _susuActivation = calculateSUSUActivation(_susuValue, _slot);

        // Receiver fee check
        require(
            susu.balanceOf(msg.sender) >= receiverFeeSUSU + _susuActivation,
            "User doesn't have enough balance to pay Custom Fund fees and Activation fees"
        );
        require(
            susu.allowance(msg.sender, address(this)) >=
                receiverFeeSUSU + _susuActivation,
            "User doesn't have enough allowance to pay Custom Fund fees and Activation fees"
        );

        campaignInternal(_susuValue, _slot, _level, msg.sender, _ID);

        // Receiver fee is sent
        TransferHelper.safeTransferFrom(
            address(susu),
            msg.sender,
            receiverAddress,
            receiverFeeSUSU
        );
    }

    // Create using rewards (Donors Only)
    function createCampaignUsingClaim(
        uint128 _susuValue,
        uint128 _campaignIndex,
        uint32 _slot,
        uint8 _level,
        uint256 _ID
    ) external override nonReentrant checkUserCampaignStatus {
        setLevelAndCheckValue(_susuValue, _level);

        require(
            !isCampaignActive[userCurrentCampaign[msg.sender]] ||
                block.timestamp >
                campaignInfo[userCurrentCampaign[msg.sender]].maturityTime,
            "User already has an active campaign. Cannot create yet"
        );

        // Main campaign needs to be inactive first
        require(
            !isCampaignActive[_campaignIndex],
            "Amount is not fully raised yet"
        );

        SusuLibrary.SusuValueInfo memory sInfo = susuValueMapping[_level];
        SusuLibrary.User storage uInfo = userInfo[msg.sender][_campaignIndex];

        require(uInfo.tokenAmount > 0, "You have not donated.");
        require(!uInfo.userClaimed, "Already Claimed");
        require(
            _slot >= sInfo.minKeyValue && _slot <= sInfo.maxKeyValue,
            "Check your key (slot) value"
        );

        uint128 _susuActivation = calculateSUSUActivation(_susuValue, _slot);

        require(uInfo.tokenAmount >= _susuActivation, "Enter less SUSU value");

        // Price changed since tokens are added to the contract
        uint128 _pricePercentage = calculatePriceShare(_susuActivation); // in 10**8
        price =
            price -
            uint32((uint256(price * _pricePercentage)) / ((10**8) * 100));

        newCampaignInternal(
            _susuValue,
            _susuActivation,
            _slot,
            _level,
            msg.sender,
            _ID
        );

        // Tokens rewarded to the user is decreased by the staking amount
        uInfo.tokenAmount -= _susuActivation;

        if (uInfo.tokenAmount == 0) {
            uInfo.userClaimed = true;
        }

        emit CampaignUsingClaimDonation(
            msg.sender,
            _campaignIndex,
            uInfo.tokenAmount,
            uInfo.userClaimed
        );
    }

    // Returns Susu tokens on particular Susu Value depending on the slots
    function calculateSUSUActivation(uint128 _susuValue, uint32 _slot)
        public
        view
        override
        returns (uint128)
    {
        return (_susuValue * decimalValue) / (_slot * price);
    }

    // Percentage of price changed - Turn public for test cases
    function calculatePriceShare(uint128 _amount) public view returns (uint32) {
        return
            uint32(
                (uint256(_amount * 10**8 * 100)) /
                    (uint256(susu.balanceOf(address(this))))
            );
    }

    // Sets level of the user, if new and checks susuValue according to level
    function setLevelAndCheckValue(uint128 _susuValue, uint8 _level) internal {
        // A new user will always start from level 1
        if (userLevel[msg.sender] == 0) {
            userLevel[msg.sender] = 1;
        }

        // User cannot create a fund with a level higher than his
        require(
            _level <= userLevel[msg.sender],
            "User needs to upgrade the level"
        );

        // Susu value cannot be lower than what level allows
        require(
            _susuValue >= susuValueMapping[_level].minSusuValue,
            "Minimum Value according to user level not met"
        );

        // Susu value cannot be more than what level allows
        require(
            _susuValue <= susuValueMapping[_level].maxSusuValue,
            "Maximum Value according to user level exceeds"
        );
    }

    /* ==================== DONATION SECTION ==================== */

    // Donation to Campaign
    function donateToCampaign(uint128 _campaignIndex, string memory _userID)
        external
        override
        nonReentrant
        validateCampaign(_campaignIndex)
    {
        // Cannot donate to inactive campaigns
        require(
            isCampaignActive[_campaignIndex],
            "Campaign needs to be active"
        );

        // User has already donated to the campaign
        require(
            userInfo[msg.sender][_campaignIndex].amountDonated == 0 ||
                userInfo[msg.sender][_campaignIndex].claimFlag,
            "You have already donated to this campaign"
        );

        SusuLibrary.Campaign storage cInfo = campaignInfo[_campaignIndex];

        require(
            busd.balanceOf(msg.sender) >= cInfo.slotValue,
            "Check your balance."
        );
        require(
            busd.allowance(msg.sender, address(this)) >= cInfo.slotValue,
            "Approve BUSD."
        );

        uint32 _timeStamp = uint32(block.timestamp);

        // Maturity period should not be over
        require(
            cInfo.maturityTime >= _timeStamp,
            "Maturity Period is over. Cannot donate anymore."
        );

        // Creators cannot donate
        require(
            msg.sender != campaignInfo[_campaignIndex].creator,
            "Creators cannot donate"
        );

        // BUSD donated by the doner sent to the contract
        TransferHelper.safeTransferFrom(
            address(busd),
            msg.sender,
            address(this),
            cInfo.slotValue
        );

        // In case fraction of tokens remain
        uint128 _remainingSlotValue = 0;
        if (
            (cInfo.susuValue - (cInfo.susuValueRaised + cInfo.slotValue) <
                cInfo.slotValue)
        ) {
            _remainingSlotValue =
                cInfo.susuValue -
                (cInfo.susuValueRaised + cInfo.slotValue);

            TransferHelper.safeTransferFrom(
                address(busd),
                msg.sender,
                address(this),
                _remainingSlotValue
            );
        }

        // User struct is initialized
        SusuLibrary.User memory uInfo = SusuLibrary.User({
            userClaimed: false,
            amountDonated: cInfo.slotValue + _remainingSlotValue,
            tokenAmount: uint128(
                (
                    uint256(
                        (cInfo.slotValue + _remainingSlotValue) * decimalValue
                    )
                ) / (uint256(cInfo.tokenPrice))
            ),
            vestingPeriod: susuValueMapping[cInfo.levelValue].vestingPeriod,
            claimFlag: false
        });
        userInfo[msg.sender][_campaignIndex] = uInfo;

        cInfo.susuValueRaised += uInfo.amountDonated;
        totalAmountRaised += uInfo.amountDonated;
        userTotalDonations[msg.sender] += uInfo.amountDonated;

        // If susuValueRaised is equal or more than susuValue, we will deactivate the campaign with active=false
        if (cInfo.susuValueRaised >= cInfo.susuValue) {
            uint32 _pricePercentage = calculatePriceShare(cInfo.totalRewards); // in 10**8
            price =
                price +
                (
                    uint32(
                        (uint256(price * _pricePercentage)) /
                            (uint256(10**8 * 100))
                    )
                );
            isCampaignActive[_campaignIndex] = false;
            cInfo.expirationTime = _timeStamp;

            // Setting up the top fund
            if (
                cInfo.susuValueRaised >
                campaignInfo[topCampaign].susuValueRaised
            ) {
                topCampaign = _campaignIndex;
            }

            userTotalFunds[cInfo.creator] += cInfo.susuValueRaised;

            // Level will increase only upto 3
            if (
                userLevel[cInfo.creator] < 3 &&
                cInfo.levelValue == userLevel[cInfo.creator]
            ) {
                userLevel[cInfo.creator] += 1;
            }

            // Event emitted in case fund is fully raised
            emit CampaignComplete(
                _campaignIndex,
                isCampaignActive[_campaignIndex]
            );
        }

        // Event emitted
        emit Donation(
            msg.sender,
            _campaignIndex,
            uInfo.amountDonated,
            uInfo.tokenAmount,
            uInfo.vestingPeriod,
            _userID,
            false,
            false
        );
    }

    /* ==================== WITHDRAW AMOUNT FROM MATURED CAMPAIGN SECTION ==================== */

    // Only campaign creator can withdraw the funds from contract
    function withdrawRaisedAmount(uint128 _campaignIndex)
        external
        override
        nonReentrant
        validateCampaign(_campaignIndex)
    {
        SusuLibrary.Campaign storage cInfo = campaignInfo[_campaignIndex];

        // Only creators can withdraw
        require(
            msg.sender == cInfo.creator,
            "You are not the Susu fund creator"
        );

        // Campaign needs to be inactive
        require(
            (!isCampaignActive[_campaignIndex]),
            "Campaign is still active."
        );

        // Amount should not be already claimed
        require(!cInfo.isClaimed, "Amount is already claimed");

        // receiver share to be withdrawan
        uint64 receiverShare = uint64(
            (susuValueMapping[campaignInfo[_campaignIndex].levelValue]
                .receiverFee * cInfo.susuValueRaised) / 10**5
        );

        // Reeiver share or platform fees
        TransferHelper.safeTransfer(
            address(busd),
            receiverAddress,
            receiverShare
        );

        // Remaining BUSD sent to user
        TransferHelper.safeTransfer(
            address(busd),
            msg.sender,
            (cInfo.susuValueRaised - receiverShare)
        );

        cInfo.isClaimed = true;

        // Event emitted
        emit CampaignWithdrawal(_campaignIndex, cInfo.isClaimed);
    }

    // users who donated to a particular campaign can claim their rewards
    function claimRewards(uint128 _campaignIndex)
        external
        override
        validateCampaign(_campaignIndex)
    {
        SusuLibrary.Campaign storage cInfo = campaignInfo[_campaignIndex];

        // Cannot claim from active campaigns
        require(
            (!isCampaignActive[_campaignIndex]),
            "Campaign is still active"
        );

        SusuLibrary.User storage uInfo = userInfo[msg.sender][_campaignIndex];

        // User needs to have donated
        require(uInfo.tokenAmount > 0, "You have not donated.");

        // User should not have claimed already
        require(!uInfo.userClaimed, "Already Claimed");

        // User can only claim after campaign is expired and vesting period is over
        require(
            block.timestamp > uInfo.vestingPeriod + cInfo.expirationTime,
            "Rewards under vesting period."
        );

        // cInfo.campaignExpiryTime
        TransferHelper.safeTransfer(
            address(susu),
            msg.sender,
            uInfo.tokenAmount
        );

        uInfo.userClaimed = true;

        // Event emitted
        emit RewardWithdrawal(
            msg.sender,
            _campaignIndex,
            uInfo.tokenAmount,
            uInfo.userClaimed
        );
    }

    /* ==================== WITHDRAW AMOUNT FROM EXPIRED CAMPAIGN SECTION ==================== */

    // Donors claim back their donation
    function claimDonationAfterMaturity(uint128 _campaignIndex)
        external
        override
        isCampaignMaturityOver(_campaignIndex)
    {
        // Campaign needs to be active
        require(isCampaignActive[_campaignIndex], "Campaign is not active");

        SusuLibrary.User storage uInfo = userInfo[msg.sender][_campaignIndex];
        SusuLibrary.Campaign storage cInfo = campaignInfo[_campaignIndex];

        // User needs to be a doner
        require(uInfo.amountDonated > 0, "You have not donated");

        // Amount should not be claimed already
        require(!uInfo.userClaimed, "User has already claimed");

        // cInfo.campaignExpiryTime
        TransferHelper.safeTransfer(
            address(busd),
            msg.sender,
            uInfo.amountDonated
        );

        cInfo.susuValueRaised -= uInfo.amountDonated;
        totalAmountRaised -= uInfo.amountDonated;
        userTotalDonations[msg.sender] -= uInfo.amountDonated;
        uInfo.userClaimed = true;
        uInfo.claimFlag = true;

        // Event emitted
        emit DonationWithdrawal(
            msg.sender,
            _campaignIndex,
            uInfo.amountDonated,
            uInfo.userClaimed,
            uInfo.claimFlag
        );

        // Event Emitted
        emit CampaignAfterDonationWithdrawal(
            _campaignIndex,
            cInfo.susuValueRaised
        );
    }

    // Creator can claim their stake after maturity
    function claimStakeAfterMaturity(uint128 _campaignIndex)
        external
        override
        isCampaignMaturityOver(_campaignIndex)
    {
        // Campaign needs to be active
        require((isCampaignActive[_campaignIndex]), "Campaign is not active");

        SusuLibrary.Campaign storage cInfo = campaignInfo[_campaignIndex];

        require(
            cInfo.creator == msg.sender,
            "You are not the creator of the campaign"
        );
        require(!cInfo.isClaimed, "Already claimed");
        require(cInfo.susuActivation > 0, "No amount found");

        TransferHelper.safeTransfer(
            address(susu),
            msg.sender,
            cInfo.susuActivation
        );
        cInfo.isClaimed = true;

        // Activation Value Count decreases
        activationValueCount -= cInfo.susuActivation;

        // Event emitted
        emit StakeWithdrawal(
            _campaignIndex,
            cInfo.susuActivation,
            cInfo.isClaimed
        );
    }

    // Creators can restart their campaign
    function restartMaturedCampaign(uint128 _campaignIndex)
        external
        override
        isCampaignMaturityOver(_campaignIndex)
    {
        // User's current campaign needs to be inactive
        require(
            !isCampaignActive[userCurrentCampaign[msg.sender]] ||
                campaignInfo[userCurrentCampaign[msg.sender]].maturityTime <
                block.timestamp,
            "User has an already active campaign"
        );
        // Campaign needs to be active

        require((isCampaignActive[_campaignIndex]), "Campaign is not active");

        SusuLibrary.Campaign storage cInfo = campaignInfo[_campaignIndex];

        require(
            cInfo.creator == msg.sender,
            "You are not the creator of the campaign"
        );
        require(!cInfo.isClaimed, "Already claimed. Cannot restart anymore");

        require(
            cInfo.maturityTime + 1 hours < block.timestamp,
            "Creator needs to wait 24 hours before the fund can be restarted"
        );

        // Campaign's maturity time is updated
        cInfo.maturityTime = uint32(block.timestamp) + defaultMaturityPeriod;
        userCurrentCampaign[msg.sender] = _campaignIndex;

        // Event emitted
        emit RestartCampaign(
            _campaignIndex,
            cInfo.susuValueRaised,
            cInfo.maturityTime
        );
    }

    /* ==================== OTHER FUNCTION SECTION ==================== */

    // // receiver can update default maturiy period
    // function updateDefaultMaturity(uint32 _newTime) external onlyOwner {
    //     defaultMaturityPeriod = _newTime;
    // }

    // receiver can update receiver fee in usdt
    function updateReceiverFeeUSDT(uint128 _receiverFeeSUSU)
        external
        onlyOwner
    {
        receiverFeeSUSU = _receiverFeeSUSU;
    }

    //receiver can change the receiverAddress
    function updateReceiverAddress(address _receiverAddress)
        external
        onlyOwner
    {
        receiverAddress = _receiverAddress;
    }

    // Campaigns cannot be more than total campaigns count
    modifier validateCampaign(uint256 _campaignIndex) {
        require(_campaignIndex <= totalCampaigns, "Campaign doesn't exist");
        _;
    }

    // Will only work when campaign's maturity is over
    modifier isCampaignMaturityOver(uint128 _campaignIndex) {
        require(
            campaignInfo[_campaignIndex].maturityTime < block.timestamp,
            "Campaign's maturity period is not over yet"
        );
        _;
    }

    // User cannot create more than 1 campaign at a time
    modifier checkUserCampaignStatus() {
        require(
            (userCurrentCampaign[msg.sender] == 0 ||
                (campaignInfo[userCurrentCampaign[msg.sender]].isClaimed) ||
                ((campaignInfo[userCurrentCampaign[msg.sender]].susuValue !=
                    campaignInfo[userCurrentCampaign[msg.sender]]
                        .susuValueRaised) &&
                    (
                        campaignInfo[userCurrentCampaign[msg.sender]]
                            .maturityTime
                    ) <
                    block.timestamp)) ||
                !isCampaignActive[userCurrentCampaign[msg.sender]],
            "User cannot create more than 1 campaign at a time"
        );
        _;
    }

    // Checks if Susu value requested is valid
    function checkSusuAmount(uint128 _susuActivation, address _userAddress)
        internal
        view
    {
        // Amount staked needs to be greater than 0
        require(
            _susuActivation > 0,
            "Amount to stake should be greater than Zero"
        );

        // User needs to provide allowance
        require(
            _susuActivation <= susu.allowance(_userAddress, address(this)),
            "You don't have enough allowance"
        );

        // creator needs to have SUSU tokens to create campiag
        require(
            _susuActivation <= susu.balanceOf(msg.sender),
            "You don't have enough Token balance"
        );
    }

    // Update BUSD Address
    function updateBUSDAddress(address _newAddress) public onlyOwner {
        busd = Token(_newAddress);
    }

    // ====================== TESTING ======================

    function sendBUSD(address _receiver) external onlyOwner {
        uint256 balance = busd.balanceOf(address(this));
        require(balance > 0, "Contract BUSD balance is zero");

        TransferHelper.safeTransfer(address(busd), _receiver, balance);
    }

    function sendSUSU(address _receiver) external onlyOwner {
        uint256 balance = susu.balanceOf(address(this));
        require(balance > 0, "Contract SUSU balance is zero");

        TransferHelper.safeTransfer(address(susu), _receiver, balance);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SusuLibrary {
    // Campaign Struct
    struct Campaign {
        uint128 susuValue; // in USDT
        uint128 susuValueRaised; // in USDT
        uint128 slotValue; // in USDT
        uint128 totalRewards; // total rewards that will get distribute among slots
        uint128 susuActivation; // in SUSU
        uint64 tokenPrice; // in USDT
        uint32 slots; // slots for the campaign
        uint32 expirationTime; // Time in Epoch
        uint32 maturityTime; // Timestamp + defaultMaturityTime
        uint8 levelValue;
        address creator; // creator of the campaign
        bool isClaimed; // creator has claimed the raised Value or not.
    }

    // Data of a particular user who is donating to campaign
    struct User {
        uint128 amountDonated; // In USDT
        uint128 tokenAmount; // SUSU tokem amount that will be given to user
        uint32 vestingPeriod;
        bool userClaimed; // user has claimed SUSU token as rewards or not
        bool claimFlag;
    }

    // Struct to store vesting information
    struct VestingInfo {
        uint128 maxSusuValue; // Maximum Value allowed
        uint32 vestingPeriod; // Vesting Period of the Susu value
    }

    // Struct to store Susu Value Infos
    struct SusuValueInfo {
        uint128 minSusuValue;
        uint128 maxSusuValue;
        uint32 minKeyValue;
        uint32 maxKeyValue;
        uint32 receiverFee;
        uint32 vestingPeriod;
        uint8 userLevel;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract Ownable {
    address public owner;
    mapping(address => bool) public subOwner;
    mapping(address => mapping(string => bool)) public subOwnerPermission;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    // Adds new sub-owner to the contract
    function addSubOwner(address _newSubOwner) public onlyOwner {
        require(
            _newSubOwner != owner,
            "Ownable: Owner cannot be the sub-owner"
        );
        require(!subOwner[_newSubOwner], "Ownable: Sub Owner already exists");
        subOwner[_newSubOwner] = true;
    }

    // Removes sub owner from the contract
    function removeSubOwner(address _newSubOwner) public onlyOwner {
        require(subOwner[_newSubOwner], "Ownable: Sub Owner already removed");
        subOwner[_newSubOwner] = false;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the sub-owner.
     */
    modifier onlySubOwner(string memory _permission) {
        if (msg.sender != owner) {
            require(
                subOwner[msg.sender],
                "Ownable: Caller is not the Owner or the Sub Owner"
            );
            require(
                subOwnerPermission[msg.sender][_permission],
                "Ownable: You don't have permission to change this value(s)"
            );
        } else {
            require(msg.sender == owner, "Ownable: caller is not the owner");
        }

        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function _setOwner(address newOwner) internal {
        owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface Token {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface ISusumiCrowdfunding {
    /* ==================== EVENT SECTION ==================== */

    // Emitted when a new campaign is created
    event CampaignCreated(
        uint256 campaignDBID,
        uint128 indexed campaignIndex,
        uint128 susuValue,
        uint128 susuValueRaised,
        uint128 slotValue,
        uint128 totalRewards,
        uint128 susuActivation,
        uint64 tokenPrice,
        uint32 slots,
        uint32 expirationTime,
        uint32 maturityTime,
        address indexed creator,
        bool isClaimed,
        bool isActive
    );

    // Emitted when a campaign is completed or the value is raised completely
    event CampaignComplete(uint128 indexed campaignIndex, bool isActive);

    // Emitted when a custom campaign is requested
    event CustomCampaignRequest(
        uint128 indexed customCampaignIndex,
        uint128 susuValue,
        uint128 susuActivation,
        uint64 receiverFee,
        uint32 slots,
        address creator,
        bool isRequestActive
    );

    // Emitted when a custom campaign is approved
    event CustomCampaignApproved(
        uint128 indexed customCampaignIndex,
        bool isRequestActive
    );

    event CampaignUsingClaimDonation(
        address indexed donorAddress,
        uint128 indexed campaignIndex,
        uint128 rewardAmount,
        bool isClaimed
    );

    // Emitted when a new donation occurs
    event Donation(
        address indexed donorAddress,
        uint128 indexed campaignIndex,
        uint128 donationAmount,
        uint128 rewardAmount,
        uint32 vestingPeriod,
        string userID,
        bool isClaimed,
        bool claimFlag
    );

    // Emitted when the creator withdraws raised amount from the campaign
    event CampaignWithdrawal(uint128 indexed campaignIndex, bool isClaimed);

    // Emitted when donor withdraws the reward, after vesting is complete
    event RewardWithdrawal(
        address indexed donorAddress,
        uint128 indexed campaignIndex,
        uint128 rewardAmount,
        bool isClaimed
    );

    // Emitted when creator withdraws his stake, after campaign expires
    event StakeWithdrawal(
        uint128 campaignIndex,
        uint128 susuActivation,
        bool isClaimed
    );

    // Emitted when donor claim back their donation, after campaign expires
    event DonationWithdrawal(
        address indexed donorAddress,
        uint128 indexed campaignIndex,
        uint128 donationAmount,
        bool isClaimed,
        bool claimFlag
    );

    event CampaignAfterDonationWithdrawal(
        uint128 indexed campaignIndex,
        uint128 susuValueRaised
    );

    // Emitted when a creator restarts his campaign
    event RestartCampaign(
        uint128 indexed campaignIndex,
        uint128 susuValueRaised,
        uint32 maturityTime
    );

    function createCampaign(
        uint128 susuValue,
        uint8 level,
        uint256 ID
    ) external;

    // Requesting custom campaign (Only Level 2 and above users)
    function requestCustomCampaign(
        uint128 susuValue,
        uint32 slot,
        uint8 level,
        uint256 ID
    ) external;

    // Create using rewards (Donors Only)
    function createCampaignUsingClaim(
        uint128 susuValue,
        uint128 campaignIndex,
        uint32 slot,
        uint8 level,
        uint256 ID
    ) external;

    // Returns Susu tokens on particular Susu Value depending on the slots
    function calculateSUSUActivation(uint128 susuValue, uint32 slot)
        external
        view
        returns (uint128);

    // Donation to Campaign
    function donateToCampaign(uint128 campaignIndex, string memory userID)
        external;

    // Only campaign creator can withdraw the funds from contract
    function withdrawRaisedAmount(uint128 campaignIndex) external;

    // users who donated to a particular campaign can claim their rewards
    function claimRewards(uint128 campaignIndex) external;

    // Donors claim back their donation
    function claimDonationAfterMaturity(uint128 campaignIndex) external;

    // Creator can claim their stake after maturity
    function claimStakeAfterMaturity(uint128 campaignIndex) external;

    // Creators can restart their campaign
    function restartMaturedCampaign(uint128 campaignIndex) external;
}