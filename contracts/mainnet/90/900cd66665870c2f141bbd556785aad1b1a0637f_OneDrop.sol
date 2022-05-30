// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./OneDropHelper.sol";

/**
  * @title Airdrop-OneDrop
  * @author René Hochmuth
 */

contract OneDrop is OneDropHelpers{

    address public immutable INSURANCE_ADDRESS;

    modifier onlyMaster() {

        require(
            msg.sender == masterAddress,
            "OneDrop: ACCESS_DENIED!"
        );
        _;
    }

    modifier isRegisterAllowed() {

        require(
            registerAllowed == true,
            "Onedrop: REGISTER_NOT_ALLOWED"
        );
        _;
    }

    modifier registerNotAllowed() {

        require(
            registerAllowed == false,
            "Onedrop: REGISTER_STILL_OPEN"
        );
        _;
    }

    constructor(
        address _rewardToken,
        address _wisbToken,
        address _insuranceAddress,
        uint256 _maxStartDay
    )

    {
        masterAddress = msg.sender;
        latestTotalShares = 1;
        MAX_START_DAY = _maxStartDay;

        rewardToken = IERC20(
            _rewardToken
        );

        wisbToken = IWISB(
            _wisbToken
        );

        wisbInsurance = IWISBInsurance(
            _insuranceAddress
        );

        INSURANCE_ADDRESS = _insuranceAddress;
    }

    function addAirdropRewards(
        uint256 _amount
    )
        registerNotAllowed
        onlyMaster
        external
        returns (bool)
    {
        require(
            addRewardsAllowed == true,
            "Onedrop: ADDING_REWARDS_NOT_ALLOWED"
        );

        _increaseTotalRewards(
            _amount
        );

        rewardToken.transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        addRewardsAllowed = false;

        return true;
    }

    function changeMaster(
        address _newMaster
    )
        external
        onlyMaster
    {
        masterAddress = _newMaster;
    }

    function findEligibleStakes(
        address _user
    )
        external
        view
        returns (bytes16[] memory)
    {
        bytes16 lastID = wisbToken.latestStakeID(_user);

        require(
            lastID != ZERO_BYTES,
            "Onedrop: NO_STAKES_AT_ALL"
        );

        uint256 counter;
        uint256 counter2;
        uint256 length =  _determineLengthStakeArray(
            _user,
            lastID
        );

        uint64 startDay;
        uint64 lockdays;
        uint64 finalDay;
        uint64 closeDay;

        bytes16[] memory rawIDs = new bytes16[](length);
        bool[] memory rawBools = new bool[](length);

        for (uint i= 0 ; i< length; i++){

            rawIDs[i] = wisbToken.generateID(
                _user,
                i,
                0x01
            );

            (
                ,
                ,
                ,
                startDay,
                lockdays,
                finalDay,
                closeDay,
                ,
                ,
                ,
                ,

            )
                = wisbToken.stakes(
                    _user,
                    rawIDs[i]
                );

            if (_investigateRequirements(
                    lockdays,
                    closeDay,
                    finalDay,
                    startDay,
                    rawIDs[i]
                )       == true) {

                    rawBools[i] = true;
                    counter +=1;
                    continue;
                }

                rawBools[i] = false;
        }

        bytes16[] memory returnIDs = new bytes16[](counter);

        for ( uint i = 0; i < length; i++) {
            if (rawBools[i] == true){
                returnIDs[counter2] = rawIDs[i];
                counter2 += 1;
            }
        }

       return returnIDs;
    }

    function findEligibleInsuranceStakes(
        address _user
    )
        external
        view
        returns (bytes16[] memory)
    {
        uint256 currentAmount = wisbInsurance.getStakedAmount(
            _user,
            0
        );

        require(
            currentAmount > 0,
            "OneDrop: NO_INSURANCE_STAKES"
        );

        uint256 length = _determineLengthInsuranceStakeArray(
            _user
        );
        uint256 counter;
        uint256 counter2;
        uint256 counter3;

        uint64 startDay;
        uint64 lockdays;
        uint64 finalDay;
        uint64 closeDay;

        address owner;

        bytes16[] memory rawIDs = new bytes16[](length);
        bool[] memory rawBools = new bool[](length);

        while (currentAmount > 0) {

        (
            rawIDs[counter],
            ,
            ,
            ,
            ,
            owner,
        ) =         wisbInsurance.insuranceStakes(
                        _user,
                        counter
                    );

        (
            ,
            ,
            ,
            startDay,
            lockdays,
            finalDay,
            closeDay,
            ,
            ,
            ,
            ,

        )
            = wisbToken.stakes(
                INSURANCE_ADDRESS,
                rawIDs[counter]
            );

        if ( (_investigateRequirements(
                    lockdays,
                    closeDay,
                    finalDay,
                    startDay,
                    rawIDs[counter]
                )
                    && owner == _user

                ) == true) {

                    rawBools[counter] = true;
                    counter2 += 1;
                }

                counter +=1;
                currentAmount = wisbInsurance.getStakedAmount(
                    _user,
                    counter
                );
        }

        bytes16[] memory returnIDs = new bytes16[](counter2);

        for (uint256 i = 0; i < length; i++) {

            if (rawBools[i] == true) {
                returnIDs[counter3] = rawIDs[i];
                counter3 += 1;
            }
       }

       return returnIDs;
    }

    function registerStake(
        bytes16 _ID
    )
        isRegisterAllowed
        public

    {
        (
            uint256 stakesShares,
            ,
            ,
            uint64 startDay,
            uint64 lockdays,
            uint64 finalDay,
            uint64 closeDay,
            ,
            ,
            ,
            ,

        ) = wisbToken.stakes(
            msg.sender,
            _ID
        );

        _checkRequirementsUpdateStakeMappings(
            lockdays,
            _ID,
            false,
            stakesShares,
            finalDay,
            startDay,
            closeDay
        );
    }

    function registerStakeBulk(
        bytes16[] memory _ID
    )
        external
    {
        for (uint256 i = 0; i < _ID.length; i++) {
            registerStake(_ID[i]);
        }
    }

    function registerInsuranceStake(
        bytes16 _ID
    )
        isRegisterAllowed
        public
    {
        uint256 firstStakeAmount = wisbInsurance.getStakedAmount(
            msg.sender,
            0
        );
        require(
            firstStakeAmount > 0,
            "OneDrop:NO_INSURANCE_STAKES_MADE"
        );

        uint256 length = _determineLengthInsuranceStakeArray(
            msg.sender
        );

        bytes16 actualID;

        address actualOwner;

        for (uint i=0; i < length; i++) {

            (
                actualID,
                ,
                ,
                ,
                ,
                actualOwner,
            ) = wisbInsurance.insuranceStakes(
                msg.sender,
                i
            );

            if (actualID == _ID) break;
        }

        require(
            actualID == _ID && actualOwner == msg.sender,
            "Airdrop: NOT_YOUR_STAKE"
        );

        (
            uint256 stakesShares,
            ,
            ,
            uint64 startDay,
            uint64 lockdays,
            uint64 finalDay,
            ,
            ,
            ,
            ,
            ,

        ) = wisbToken.stakes(
            INSURANCE_ADDRESS,
            _ID
        );

        _checkRequirementsUpdateStakeMappings(
            lockdays,
            _ID,
            true,
            stakesShares,
            finalDay,
            startDay,
            0
        );
    }

    function registerInsuranceStakeBulk(
        bytes16[] memory _ID
    )
        external
    {
        for (uint256 i = 0; i < _ID.length; i++) {
            registerInsuranceStake(
                _ID[i]
            );
        }
    }

    function showRewardUser(
        address _user
    )
        external
        view
        returns (uint256 result)
    {
        result = _calculateRewardUser(
            _user,
            userShares[_user]
        );
    }

    function showMyRewards()
        external
        view
        returns (uint256)
    {
        uint256 shares = userShares[msg.sender];
        uint256 result = _calculateRewardUser(
            msg.sender,
            shares
        );

        return result;
    }

    function getRewardUser()
        external
    {

        uint256 amount = _calculateRewardUser(
            msg.sender,
            userShares[msg.sender]
        );

        reduktor[msg.sender] = totalRewards;

        rewardToken.transfer(
            msg.sender,
            amount
        );

    }

    function enableAddRewards()
        onlyMaster
        external
    {
        addRewardsAllowed = true;
    }

    function disableAddRewards()
        onlyMaster
        external
    {
        addRewardsAllowed = false;
    }

    function enableRegister()
        onlyMaster
        external
    {
        uint256 currentDay = wisbToken.currentWiseDay();

        START_REGISTER_DAY = currentDay;
        registerAllowed = true;
    }

    function disableRegister()
        onlyMaster
        external
    {
        registerAllowed = false;
    }

}