/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

pragma solidity ^0.8.10;

//SPDX-License-Identifier: Unlicensed

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            'Ownable: new owner is the zero address'
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface ManagerContract {
    function setValidatorDataLockPeriode(address validator)
        external
        returns (bool);

    function getValidatorStakedAmount(address validator)
        external
        view
        returns (uint256);

    function getAmountOfValidators() external view returns (uint256);

    function getAllValidators() external view returns (address[] memory);

    function getValidatorData(address validator)
        external
        view
        returns (uint256[4] memory);

    function resetValidatorDataLosses(address validator)
        external
        returns (bool);

    function increaseValidatorDataLosses(address validator)
        external
        returns (bool);

    function setValidatorDataCooldown(address validator)
        external
        returns (bool);

    function increaseValidatorDataStakeReduction(address validator)
        external
        returns (uint256);

    function getRequiredAmountToJoinValidators()
        external
        view
        returns (uint256);

    function getAmountAllowedLosses() external view returns (uint256);
}

contract TreasureContract is Ownable {
    receive() external payable {}

    constructor() {
        validationCooldown = 1800;
        hasWritingRights[msg.sender] = true;
        dopTokenContractAddress = 0x1316F8e84c03e236355639f4d18018c55D3E23f9;
        managerContractAddress = 0xf5CEf1C90C344349E981DF804294fD82DE1E6389;
        busdTokenContractAddress = 0x1316F8e84c03e236355639f4d18018c55D3E23f9;
        devWallet = 0xE1032FF98B26b634393612E59819DcEe39F8c4b8;
        claimFee = 500_000_000_000;
        customDropFee = 1000_000_000_000_000_000;
        validatorRewardPercentage = 12;
        numberToAssignValidators = 5;
        requiredNumberOfVotes = 3;
        chestTypeToRequiredAmountToClaim['common'] = 0;
        chestTypeToRequiredAmountToClaim['uncommon'] = 50_000_000_000_000;
        chestTypeToRequiredAmountToClaim['epic'] = 100_000_000_000_000;
        chestTypeToRequiredAmountToClaim['rare'] = 1000_000_000_000_000;
        chestTypeToRequiredAmountToClaim['custom'] = 0;
        protestFee = 1000_000_000_000;
    }

    event ChestsDropped(uint256[5] indexed chestIds);
    event ChestDropped(uint256 indexed chestId);
    event ChestClaimed(
        address indexed claimant,
        uint256 indexed chestId,
        int256[2] indexed coords
    );
    event ValidatorsAssigned(
        uint256 indexed chestId,
        address[5] indexed validators
    );
    event ValidatorValidated(
        address indexed validator,
        uint256 indexed chestId
    );
    event RewardedLoot(address indexed rewardedTo, uint256 amount);
    event ValidatorRewarded(address indexed validator, uint256 amount);
    event ValidatorAssigned(address indexed validator, uint256 indexed chestId);

    address public dopTokenContractAddress;
    address public managerContractAddress;
    address public busdTokenContractAddress;
    address public devWallet;

    function setDevWallet(address newDevWallet) external onlyOwner {
        devWallet = newDevWallet;
    }

    mapping(uint256 => ChestObject) private chestObjects;
    mapping(address => bool) public hasWritingRights;
    mapping(uint256 => ChestValidationStats[5]) public chestToValidationStats;
    mapping(address => uint256[]) private validatorToValidations;
    mapping(string => uint256) chestTypeToRequiredAmountToClaim;

    uint256 public idNumber;
    uint256 public percentageClaimFee;
    uint256 public customDropFee;
    uint256 public claimFee;
    uint256 public protestFee;
    uint256 public validationCooldown;
    uint256[] public activeChestIds;
    uint256 numberToAssignValidators;
    uint256 public requiredNumberOfVotes;
    uint256 validatorRewardPercentage;

    struct ChestObject {
        string species;
        uint256 idNumber;
        int256[2] locationPhoto;
        uint8 status;
        uint8 voteCount;
        uint8 yesVotes;
        address claimant;
        uint256 value;
        bytes32 trueLocationLat;
        bytes32 trueLocationLong;
        bytes32[2] number;
        uint256 validationCooldown;
        //uint256 protestDeadline;
    }
    //Used as input to external function to appoint validators to a chest
    struct PrepValidatorData {
        uint256 id;
        ChestValidationStats[5] validators;
    }
    struct ChestValidationStats {
        address validator;
        uint256 decision;
    }
    struct ValidatorData {
        uint256 losses;
        uint256 cooldown;
        uint256 stakeReductionAmount;
        uint256 lockPeriode;
    }
    modifier onlyWriter() {
        require(hasWritingRights[msg.sender], 'Caller has no writing rights');
        _;
    }

    function dropCustomChest(
        int256 _lat,
        int256 _long,
        uint256 world,
        uint256 hotspot,
        uint256 valueInSacha
    ) external onlyOwner {
        chestObjects[idNumber].idNumber = idNumber;
        chestObjects[idNumber].species = 'Custom';
        chestObjects[idNumber].value = valueInSacha;
        chestObjects[idNumber].trueLocationLat = keccak256(
            abi.encodePacked(_lat)
        );
        chestObjects[idNumber].trueLocationLong = keccak256(
            abi.encodePacked(_long)
        );
        chestObjects[idNumber].number = [
            keccak256(abi.encodePacked(world, idNumber)),
            keccak256(abi.encodePacked(hotspot, idNumber))
        ];
        activeChestIds.push(idNumber);
        emit ChestDropped(idNumber);
        idNumber++;
    }

    function dropTreasureChests(ChestObject[] memory chests)
        external
        onlyWriter
        returns (bool)
    {
        for (uint256 i; i < chests.length; i++) {
            chestObjects[idNumber].idNumber = idNumber;
            chestObjects[idNumber].species = chests[i].species;
            chestObjects[idNumber].trueLocationLat = chests[i].trueLocationLat;
            chestObjects[idNumber].trueLocationLong = chests[i]
                .trueLocationLong;
            chestObjects[idNumber].value = chests[i].value;
            chestObjects[idNumber].number = chests[i].number;
            activeChestIds.push(idNumber);
            idNumber++;
        }
        return true;
    }

    function claim(
        uint256 chestId,
        int256 latitude,
        int256 longitude
    ) public returns (bool) {
        ChestObject memory chest = chestObjects[chestId];
        require(
            chest.claimant == address(0) || chest.claimant == msg.sender,
            'This treasure chest has already been calimed by someone else'
        );
        require(chest.status == 0, 'This chest has already been claimed');
        require(
            chest.trueLocationLat == keccak256(abi.encodePacked(latitude)) &&
                chest.trueLocationLong ==
                keccak256(abi.encodePacked(longitude)),
            'coordinates do not match'
        );
        ERC20 dopTokenContract = ERC20(dopTokenContractAddress);
        uint256 claimantCurrentBalance = dopTokenContract.balanceOf(msg.sender);
        require(
            claimantCurrentBalance >=
                chestTypeToRequiredAmountToClaim[chest.species],
            'You are not eligible to claim this chest'
        );
        require(
            dopTokenContract.transferFrom(msg.sender, address(this), claimFee),
            'Make sure you have approved this address of your tokens'
        );
        chestObjects[chestId].claimant = msg.sender;
        chestObjects[chestId].status = 1;
        chestObjects[chestId].locationPhoto = [latitude, longitude];

        emit ChestClaimed(msg.sender, chestId, [latitude, longitude]);
        return true;
    }

    function assignValidators(PrepValidatorData[] calldata validatorData)
        external
        onlyWriter
    {
        address[5] memory validators;
        for (uint256 i = 0; i < validatorData.length; i++) {
            require(
                chestObjects[validatorData[i].id].status == 1,
                'A chest in this list has not the right status'
            );
            require(
                chestObjects[validatorData[i].id].claimant != address(0),
                'This chest has not yet been claimed'
            );
            for (uint256 k = 0; k < numberToAssignValidators; k++) {
                validators[k] = validatorData[i].validators[k].validator;
                chestToValidationStats[validatorData[i].id][k] = validatorData[
                    i
                ].validators[k];
                validatorToValidations[validatorData[i].validators[k].validator]
                    .push(validatorData[i].id);
            }
            chestObjects[validatorData[i].id].status = 2;
            chestObjects[validatorData[i].id].validationCooldown =
                block.timestamp +
                validationCooldown;
            emit ValidatorsAssigned(validatorData[i].id, validators);
        }
    }

    function reAssignValidators(PrepValidatorData[] calldata validatorData)
        external
        onlyWriter
    {
        for (uint256 i = 0; i < validatorData.length; i++) {
            uint256 chestId = validatorData[i].id;
            ChestObject memory chest = chestObjects[chestId];
            require(chest.status == 2, 'This chest is not reassignable');
            require(
                chest.validationCooldown <= block.timestamp,
                'Validation time limit not reached'
            );
            for (
                uint256 j = 0;
                j < chestToValidationStats[validatorData[i].id].length;
                j++
            ) {
                if (chestToValidationStats[chestId][j].decision == 0) {
                    address newValidator = validatorData[i]
                        .validators[j]
                        .validator;
                    address prevValidator = chestToValidationStats[chestId][j]
                        .validator;
                    uint256 prevValidatorIndex;

                    chestToValidationStats[validatorData[i].id][j]
                        .validator = newValidator;
                    validatorToValidations[newValidator].push(chestId);

                    for (
                        uint256 z = 0;
                        z < validatorToValidations[prevValidator].length;
                        z++
                    ) {
                        if (
                            validatorToValidations[prevValidator][z] == chestId
                        ) {
                            prevValidatorIndex = z;
                        }
                    }

                    validatorToValidations[prevValidator][
                        prevValidatorIndex
                    ] = validatorToValidations[prevValidator][
                        validatorToValidations[prevValidator].length - 1
                    ];
                    validatorToValidations[prevValidator].pop();
                    emit ValidatorAssigned(newValidator, chestId);
                }
            }
            chestObjects[chestId].validationCooldown =
                block.timestamp +
                validationCooldown;
        }
    }

    function validate(uint256 chestId, uint256 decision) public {
        ManagerContract manager = ManagerContract(managerContractAddress);
        uint256 stakedAmount = manager.getValidatorStakedAmount(msg.sender);
        require(
            stakedAmount > 0,
            'You are currently not able to validate due to, too low staked amount'
        );
        require(
            chestObjects[chestId].status == 2,
            'This chest is not up for validation'
        );
        require(
            decision == 1 || decision == 2,
            'Please chose a valid decision 1 or 2'
        );
        uint256 validatorIndex = 6;
        uint256 validatorChestIndex = 6;
        for (uint256 i; i < validatorToValidations[msg.sender].length; i++) {
            if (validatorToValidations[msg.sender][i] == chestId) {
                validatorIndex = i;
            }
        }
        for (uint256 i; i < chestToValidationStats[chestId].length; i++) {
            if (
                chestToValidationStats[chestId][i].validator == msg.sender &&
                chestToValidationStats[chestId][i].decision == 0
            ) {
                validatorChestIndex = i;
            }
        }
        require(
            validatorIndex != 6,
            'You are not assigned as a validator for this chest'
        );
        require(
            validatorChestIndex != 6,
            'You are not assigned as a validator in the chest, this is critical error'
        );
        chestToValidationStats[chestId][validatorChestIndex]
            .decision = decision;
        if (decision == 1) {
            chestObjects[chestId].yesVotes++;
        }
        chestObjects[chestId].voteCount++;
        validatorToValidations[msg.sender][
            validatorIndex
        ] = validatorToValidations[msg.sender][
            validatorToValidations[msg.sender].length - 1
        ];
        validatorToValidations[msg.sender].pop();
        ChestObject memory chest = chestObjects[chestId];
        if (
            chest.yesVotes == requiredNumberOfVotes ||
            chest.voteCount - chest.yesVotes >= requiredNumberOfVotes
        ) {
            chestObjects[chestId].status = 3;
            for (
                uint256 l = 0;
                l < chestToValidationStats[chestId].length;
                l++
            ) {
                for (
                    uint256 f = 0;
                    f <
                    validatorToValidations[
                        chestToValidationStats[chestId][l].validator
                    ].length;
                    f++
                ) {
                    if (
                        validatorToValidations[
                            chestToValidationStats[chestId][l].validator
                        ][f] == chestId
                    ) {
                        validatorToValidations[
                            chestToValidationStats[chestId][l].validator
                        ][f] = validatorToValidations[
                            chestToValidationStats[chestId][l].validator
                        ][
                            validatorToValidations[
                                chestToValidationStats[chestId][l].validator
                            ].length - 1
                        ];
                        validatorToValidations[
                            chestToValidationStats[chestId][l].validator
                        ].pop();
                    }
                }
            }
        }
        ManagerContract managerContract = ManagerContract(
            managerContractAddress
        );
        managerContract.setValidatorDataLockPeriode(msg.sender);
        emit ValidatorValidated(msg.sender, chestId);
    }

    function finalize(uint256[] calldata chestIds) public onlyWriter {
        for (uint256 m = 0; m < chestIds.length; m++) {
            uint256 chestId = chestIds[m];
            ChestObject memory chest = chestObjects[chestId];
            require(chest.status == 3, 'This chest is not up for finalization');
            ERC20 dopTokenContract = ERC20(dopTokenContractAddress);
            ManagerContract managerContract = ManagerContract(
                managerContractAddress
            );
            if (chest.yesVotes >= requiredNumberOfVotes) {
                dopTokenContract.transfer(chest.claimant, chest.value);
                uint256 length = chestToValidationStats[chestId].length;
                for (uint256 i = 0; i < length; i++) {
                    ChestValidationStats
                        memory chestValidationStats = chestToValidationStats[
                            chestId
                        ][i];
                    uint256[4] memory validatorDataResult = managerContract
                        .getValidatorData(chestValidationStats.validator);
                    ValidatorData memory validatorData = ValidatorData(
                        validatorDataResult[0],
                        validatorDataResult[1],
                        validatorDataResult[2],
                        validatorDataResult[3]
                    );
                    if (chestValidationStats.decision == 1) {
                        uint256 validatorReward = (claimFee / 100) *
                            validatorRewardPercentage;
                        dopTokenContract.transfer(
                            chestValidationStats.validator,
                            validatorReward
                        );
                        emit ValidatorRewarded(
                            chestValidationStats.validator,
                            (claimFee / validatorRewardPercentage) * 100
                        );
                    } else if (chestValidationStats.decision == 2) {
                        if (block.number >= validatorData.cooldown) {
                            managerContract.setValidatorDataCooldown(
                                chestValidationStats.validator
                            );
                            managerContract.resetValidatorDataLosses(
                                chestValidationStats.validator
                            );
                        } else {
                            managerContract.increaseValidatorDataLosses(
                                chestValidationStats.validator
                            );
                        }
                    }
                }
                chestObjects[chestIds[m]].status = 4;
                //chestObjects[chestIds[m]].protestDeadline = block.number + 28800;
                emit RewardedLoot(chest.claimant, chest.value);
            } else if (
                chest.voteCount - chest.yesVotes >= requiredNumberOfVotes
            ) {
                for (
                    uint256 i = 0;
                    i < chestToValidationStats[chestId].length;
                    i++
                ) {
                    ChestValidationStats
                        memory chestValidationStats = chestToValidationStats[
                            chestId
                        ][i];
                    uint256[4] memory validatorDataResult = managerContract
                        .getValidatorData(
                            chestToValidationStats[chestId][i].validator
                        );
                    ValidatorData memory validatorData = ValidatorData(
                        validatorDataResult[0],
                        validatorDataResult[1],
                        validatorDataResult[2],
                        validatorDataResult[3]
                    );
                    if (chestValidationStats.decision == 2) {
                        uint256 validatorReward = (claimFee / 100) *
                            validatorRewardPercentage;
                        dopTokenContract.transfer(
                            chestValidationStats.validator,
                            validatorReward
                        );
                        emit ValidatorRewarded(
                            chestValidationStats.validator,
                            (claimFee / validatorRewardPercentage) * 100
                        );
                    } else if (chestValidationStats.decision == 1) {
                        if (block.number > validatorData.cooldown) {
                            managerContract.setValidatorDataCooldown(
                                chestValidationStats.validator
                            );
                            managerContract.resetValidatorDataLosses(
                                chestValidationStats.validator
                            );
                        } else {
                            managerContract.increaseValidatorDataLosses(
                                chestValidationStats.validator
                            );
                        }
                    }
                }
                //chestObjects[chestIds[m]].protestDeadline = block.number + 28800;
                chestObjects[chestId].claimant = address(0);
                chestObjects[chestId].status = 0;
                chestObjects[chestId].voteCount = 0;
                chestObjects[chestId].yesVotes = 0;
                chestObjects[chestId].locationPhoto[0] = 0;
                chestObjects[chestId].locationPhoto[1] = 0;
                delete chestToValidationStats[chestId];
                emit ChestDropped(chest.idNumber);
            }
        }
    }

    // function protestClaim(uint chestId) public returns(bool){
    //     ERC20 dopContract = ERC20(dopTokenContractAddress);
    //     dopContract.transferFrom(msg.sender, address(this), protestFee);
    //     chestObjects[chestId].status = 5;
    //     return true;
    // }
    function getInactiveChestIndicesBetweenIndexes(uint256 from, uint256 to)
        public
        view
        returns (uint256[] memory inactiveIndices)
    {
        uint256 k = 0;
        if (from > activeChestIds.length) {
            return inactiveIndices;
        }
        if (activeChestIds.length < to) {
            to = activeChestIds.length;
        }
        for (uint256 i = from; i < to; i++) {
            if (chestObjects[activeChestIds[i]].status == 4) {
                inactiveIndices[k] = i;
                k++;
            }
        }
    }

    function popInactiveChestsByIndices(uint256[] calldata indices)
        public
        onlyWriter
    {
        for (uint256 i = indices.length - 1; i >= 0; i--) {
            require(chestObjects[activeChestIds[i]].status == 4); //&& chestObjects[activeChestIds[i]].protestDeadline < block.number);
            if (chestObjects[activeChestIds[indices[i]]].status == 4) {
                activeChestIds[indices[i]] = activeChestIds[
                    activeChestIds.length - 1
                ];
                activeChestIds.pop();
            }
        }
    }

    function setUserDropFee(uint256 newFee) external onlyOwner returns (bool) {
        customDropFee = newFee;
        return true;
    }

    function setClaimFee(uint256 newClaimFee)
        external
        onlyOwner
        returns (bool)
    {
        claimFee = newClaimFee;
        return true;
    }

    function setRequiredNumberOfVotes(uint256 newValue)
        external
        onlyOwner
        returns (bool)
    {
        requiredNumberOfVotes = newValue;
        return true;
    }

    function setValidationCooldown(uint256 newCooldownInSeconds)
        external
        onlyOwner
        returns (bool)
    {
        validationCooldown = newCooldownInSeconds;
        return true;
    }

    function setValidatorRewardPercentage(
        uint256 newRewardValidatorRewardPercentage
    ) external onlyOwner returns (bool) {
        validatorRewardPercentage = newRewardValidatorRewardPercentage;
        return true;
    }

    function giveWritingRights(address contractAddress)
        external
        onlyOwner
        returns (bool)
    {
        hasWritingRights[contractAddress] = true;
        return true;
    }

    function removeWritingRights(address contractAddress)
        external
        onlyOwner
        returns (bool)
    {
        hasWritingRights[contractAddress] = false;
        return true;
    }

    function setPercentageClaimFee(uint256 newValue) external onlyOwner {
        percentageClaimFee = newValue;
    }

    function setManagerContractAddress(address newAddress) external onlyOwner {
        managerContractAddress = newAddress;
    }

    function getTotalChestCount() public view returns (uint256) {
        return activeChestIds.length;
    }

    struct ReturnValidatorChestData {
        ChestObject chest;
        uint256 validatorIndex;
    }

    function searchForClaimedChestBetweenIndices(uint256 from, uint256 to)
        public
        view
        returns (ChestObject[] memory)
    {
        uint256 count;
        uint256 lastIndex;
        uint256 k = 0;
        if (activeChestIds.length <= to) {
            lastIndex = activeChestIds.length;
        } else {
            lastIndex = to;
        }

        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 1) {
                count++;
            }
        }

        ChestObject[] memory chests = new ChestObject[](count);
        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 1) {
                chests[k] = chestObjects[activeChestIds[i]];
                k++;
            }
        }
        return chests;
    }

    function searchForClaimedChestIdsBetweenIndices(uint256 from, uint256 to)
        public
        view
        returns (uint256[] memory)
    {
        uint256 count;
        uint256 lastIndex;
        uint256 k = 0;
        if (activeChestIds.length <= to) {
            lastIndex = activeChestIds.length;
        } else {
            lastIndex = to;
        }

        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 1) {
                count++;
            }
        }

        uint256[] memory chests = new uint256[](count);
        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 1) {
                chests[k] = chestObjects[activeChestIds[i]].idNumber;
                k++;
            }
        }
        return chests;
    }

    function searchForProtestedChestIdsBetweenIndices(uint256 from, uint256 to)
        public
        view
        returns (uint256[] memory)
    {
        uint256 count;
        uint256 lastIndex;
        uint256 k = 0;
        if (activeChestIds.length <= to) {
            lastIndex = activeChestIds.length;
        } else {
            lastIndex = to;
        }

        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 5) {
                count++;
            }
        }

        uint256[] memory chests = new uint256[](count);
        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 5) {
                chests[k] = chestObjects[activeChestIds[i]].idNumber;
                k++;
            }
        }
        return chests;
    }

    function searchForChestIdsWithValidatorsAssignedBetweenIndices(
        uint256 from,
        uint256 to
    ) public view returns (uint256[] memory) {
        uint256 count;
        uint256 lastIndex;
        uint256 k = 0;
        if (activeChestIds.length <= to) {
            lastIndex = activeChestIds.length;
        } else {
            lastIndex = to;
        }

        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 2) {
                count++;
            }
        }

        uint256[] memory chests = new uint256[](count);
        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 2) {
                chests[k] = chestObjects[activeChestIds[i]].idNumber;
                k++;
            }
        }
        return chests;
    }

    function searchForValidatedChestIdsBetweenIndices(uint256 from, uint256 to)
        public
        view
        returns (uint256[] memory)
    {
        uint256 count;
        uint256 lastIndex;
        uint256 k = 0;
        if (activeChestIds.length <= to) {
            lastIndex = activeChestIds.length;
        } else {
            lastIndex = to;
        }

        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 3) {
                count++;
            }
        }

        uint256[] memory chests = new uint256[](count);
        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 3) {
                chests[k] = chestObjects[activeChestIds[i]].idNumber;
                k++;
            }
        }
        return chests;
    }

    function searchForValidatedChestsBetweenIndices(uint256 from, uint256 to)
        public
        view
        returns (ChestObject[] memory)
    {
        uint256 count;
        uint256 lastIndex;
        uint256 k = 0;
        if (activeChestIds.length <= to) {
            lastIndex = activeChestIds.length;
        } else {
            lastIndex = to;
        }

        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 3) {
                count++;
            }
        }

        ChestObject[] memory chests = new ChestObject[](count);
        for (uint256 i = from; i < lastIndex; i++) {
            if (chestObjects[activeChestIds[i]].status == 3) {
                chests[k] = chestObjects[activeChestIds[i]];
                k++;
            }
        }
        return chests;
    }

    function getAllToBeValidatedChestsForUser(address forUser)
        public
        view
        returns (ReturnValidatorChestData[] memory)
    {
        uint256 validationsLength = validatorToValidations[forUser].length;
        ReturnValidatorChestData[]
            memory toValidateChests = new ReturnValidatorChestData[](
                validationsLength
            );
        for (uint256 i = 0; i < validationsLength; i++) {
            toValidateChests[i] = ReturnValidatorChestData(
                chestObjects[validatorToValidations[forUser][i]],
                i
            );
        }
        return toValidateChests;
    }

    function getActiveChestsBetweenIndices(uint256 from, uint256 to)
        public
        view
        returns (ChestObject[] memory)
    {
        uint256 lastIndex;
        uint256 k = 0;
        if (activeChestIds.length <= to) {
            lastIndex = activeChestIds.length;
        } else {
            lastIndex = to;
        }
        uint256 count;
        for (uint256 i = from; i < lastIndex; i++) {
            if (
                chestObjects[activeChestIds[i]].claimant == address(0) &&
                chestObjects[activeChestIds[i]].status == 0
            ) {
                count++;
            }
        }
        ChestObject[] memory chests = new ChestObject[](count);
        for (uint256 i = from; i < lastIndex; i++) {
            if (
                chestObjects[activeChestIds[i]].claimant == address(0) &&
                chestObjects[activeChestIds[i]].status == 0
            ) {
                chests[k] = chestObjects[activeChestIds[i]];
                k++;
            }
        }
        return chests;
    }

    function getAllActiveChestIds() public view returns (uint256[] memory) {
        return activeChestIds;
    }

    function getChest(uint256 index) public view returns (ChestObject memory) {
        return chestObjects[index];
    }

    function getActiveChestIdsLength() public view returns (uint256) {
        return activeChestIds.length;
    }
}