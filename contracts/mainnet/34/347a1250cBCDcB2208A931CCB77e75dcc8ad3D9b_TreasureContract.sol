/**
 *Submitted for verification at BscScan.com on 2022-07-15
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
    function getValidatorStakedAmount(address validator) external view  returns (uint);
    function getAmountOfValidators() external view returns (uint256);

    function getAllValidators() external view returns (address[] memory);

    function getValidatorData(address validator)
        external
        view
        returns (uint256[3] memory);

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
        hasWritingRights[msg.sender] = true;
        percentageClaimFee = 30;
        dopTokenContractAddress = 0x1316F8e84c03e236355639f4d18018c55D3E23f9;
    }

    address public dopTokenContractAddress;
    address public managerContractAddress;
    uint256 public idNumber;
    uint256 percentageClaimFee;
    mapping(uint256 => ChestObject) private chestObjects;
    mapping(address => bool) public hasWritingRights;
    mapping(uint256 => ChestValidationStats[5]) public chestToValidationStats;
    mapping (address => uint[]) private validatorToValidations;
    uint256[] public activeChestIds;
    uint256 numberToAssignValidators = 5;
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
    }
    modifier onlyWriter() {
        require(hasWritingRights[msg.sender], 'Caller has no writing rights');
        _;
    }
    function dropTreasureChests(ChestObject[] calldata chests)
        external
        onlyWriter
        returns (bool)
    {
        for (uint256 i; i < chests.length; i++) {
            chestObjects[idNumber] = chests[i];
            chestObjects[idNumber].idNumber = idNumber;
            activeChestIds.push(idNumber);
            idNumber++;
        }
        return true;
    }
    function claim(
        uint256 chestId,
        int256 longitude,
        int256 latitude
    ) public returns (bool) {
        ChestObject memory chest = chestObjects[chestId];
        require(
            chest.claimant == address(0) || chest.claimant == msg.sender,
            'This treasure chest has already been calimed by someone else'
        );
        require(chest.status == 0, "This chest has already been claimed");
        require(
            chest.trueLocationLat ==
                keccak256(abi.encodePacked(latitude)) && chest.trueLocationLong == keccak256(abi.encodePacked(longitude)),
            'coordinates do not match'
        );
        ERC20 dopTokenContract = ERC20(dopTokenContractAddress);
        require(
            dopTokenContract.transferFrom(
                msg.sender,
                address(this),
                chestObjects[chestId].value * percentageClaimFee / 100
            ),
            'Make sure you have approved this address of your tokens'
        );
        chestObjects[chestId].claimant = msg.sender;
        chestObjects[chestId].status = 1;

        return true;
    }
    function assignValidators(PrepValidatorData[] calldata validatorData)
        external
        onlyWriter
    {
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
                chestToValidationStats[validatorData[i].id][k] = validatorData[
                    i
                ].validators[k];
                validatorToValidations[validatorData[i].validators[k].validator].push(validatorData[i].id);
            }
            chestObjects[validatorData[i].id].status = 2;
        }
    }

    function validate(
        uint256 chestId,
        uint256 decision
    ) public {
        ManagerContract manager = ManagerContract(managerContractAddress);
        uint stakedAmount = manager.getValidatorStakedAmount(msg.sender);
        require(stakedAmount > 0, "You are currently not able to validate due to, too low staked amount");
        require(chestObjects[chestId].status == 2, "This chest is not up for validation");
        require(
            decision == 1 || decision == 2,
            'Please chose a valid decision 1 or 2'
        );
        uint validatorIndex = 6;
        uint validatorChestIndex = 6;
        for(uint i; i < validatorToValidations[msg.sender].length;i++){
            if(validatorToValidations[msg.sender][i] == chestId){
                validatorIndex = i;
            }
        }
        for(uint i; i < chestToValidationStats[chestId].length;i++){
            if(chestToValidationStats[chestId][i].validator == msg.sender){
                validatorChestIndex = i;
            }
        }
        require(validatorIndex != 6, "You are not assigned as a validator for this chest");
        require(validatorChestIndex != 6, "You are not assigned as a validator in the chest, this is critical error");
        chestToValidationStats[chestId][validatorChestIndex].decision = decision;
        if (decision == 1) {
            chestObjects[chestId].yesVotes++;
        }
        chestObjects[chestId].voteCount++;
        validatorToValidations[msg.sender][validatorIndex] = validatorToValidations[msg.sender][validatorToValidations[msg.sender].length - 1];
        validatorToValidations[msg.sender].pop();
        ChestObject memory chest = chestObjects[chestId];
        if (chest.yesVotes >= 3 || chest.voteCount - chest.yesVotes >= 3) {
            chestObjects[chestId].status = 3;
            for(uint l = 0; l < chestToValidationStats[chestId].length; l++){
                for(uint f = 0; f < validatorToValidations[chestToValidationStats[chestId][l].validator].length; f++){
                    if(validatorToValidations[chestToValidationStats[chestId][l].validator][f] == chestId){
                        validatorToValidations[chestToValidationStats[chestId][l].validator][f] = validatorToValidations[chestToValidationStats[chestId][l].validator][validatorToValidations[chestToValidationStats[chestId][l].validator].length - 1];
                        validatorToValidations[chestToValidationStats[chestId][l].validator].pop();
                    }
                }
            }
        }
    }

    function finalize(uint256[] calldata chestIds) public onlyWriter {
        for (uint256 m = 0; m < chestIds.length; m++) {
            uint chestId = chestIds[m];
            ChestObject memory chest = chestObjects[chestId];
            require(chest.status == 3, 'This chest is not up for finalization');
            ERC20 dopTokenContract = ERC20(dopTokenContractAddress);
            ManagerContract managerContract = ManagerContract(
                managerContractAddress
            );
            if (chest.yesVotes >= 3) {
                    dopTokenContract.transfer(chest.claimant, chest.value);
                    uint length = chestToValidationStats[chestId].length;
                for (
                    uint256 i = 0;
                    i < length;
                    i++
                ) {
                    ChestValidationStats
                        memory chestValidationStats = chestToValidationStats[
                            chestId
                        ][i];
                    uint256[3] memory validatorDataResult = managerContract
                        .getValidatorData(chestValidationStats.validator);
                    ValidatorData memory validatorData = ValidatorData(
                        validatorDataResult[0],
                        validatorDataResult[1],
                        validatorDataResult[2]
                    );
                    if (chestValidationStats.decision == 1) {
                        dopTokenContract.transfer(
                            chestValidationStats.validator,
                            chest.value / 10
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
            } else if (chest.voteCount - chest.yesVotes >= 3) {
                for (
                    uint256 i = 0;
                    i < chestToValidationStats[chestId].length;
                    i++
                ) {
                    ChestValidationStats
                        memory chestValidationStats = chestToValidationStats[
                            chestId
                        ][i];
                    uint256[3] memory validatorDataResult = managerContract
                        .getValidatorData(
                            chestToValidationStats[chestId][i].validator
                        );
                    ValidatorData memory validatorData = ValidatorData(
                        validatorDataResult[0],
                        validatorDataResult[1],
                        validatorDataResult[2]
                    );
                    if (chestValidationStats.decision == 2) {
                        dopTokenContract.transfer(
                            chestValidationStats.validator,
                            chestObjects[chestId].value / 10
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
                chestObjects[chestId].claimant = address(0);
                chestObjects[chestId].status = 0;
                chestObjects[chestId].voteCount = 0;
                chestObjects[chestId].yesVotes = 0;
                delete chestToValidationStats[chestId];
            }
        }
    }
    function popInactiveChests() public onlyWriter{
        for (uint i = 0; i < activeChestIds.length; i++){
            if(chestObjects[activeChestIds[i]].status == 4){
                activeChestIds[i] = activeChestIds[activeChestIds.length - 1];
                activeChestIds.pop();
            }
        }
    }
    function popInactiveChestsBetweenIndices(uint from, uint to) public onlyWriter{
        for (uint i = from; i < to; i++){
            if(chestObjects[activeChestIds[i]].status == 4){
                activeChestIds[i] = activeChestIds[activeChestIds.length - 1];
                activeChestIds.pop();
            }
        }
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

    function dropCustomChest(
        int256 _lat,
        int256 _long,
        uint256 world,
        uint256 hotspot
    ) external onlyOwner {
        chestObjects[idNumber].idNumber = idNumber;
        chestObjects[idNumber].species = 'Exotic';
        chestObjects[idNumber].value = 1_000_000_000_000;
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
        idNumber++;
    }

    function setTokenAddress(address newAddress) external onlyOwner {
        dopTokenContractAddress = newAddress;
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

    function searchForClaimedChestBetweenIndices(uint from, uint to) public view returns (ChestObject[] memory){
        uint count;
        uint lastIndex;
        uint k = 0;
        if(activeChestIds.length <= to){
            lastIndex = activeChestIds.length;
        }else{
            lastIndex = to;
        }

        for(uint i = from; i < lastIndex; i++){
            if(chestObjects[activeChestIds[i]].status == 1){
                count++;
            }
        }

        ChestObject[] memory chests = new ChestObject[](count);
        for(uint i = from; i < lastIndex; i++){
            if(chestObjects[activeChestIds[i]].status == 1){
                chests[k] = chestObjects[activeChestIds[i]];
                k++;
            }
        }
        return chests;
    }
    function searchForClaimedChestIdsBetweenIndices(uint from, uint to) public view returns (uint[] memory){
        uint count;
        uint lastIndex;
        uint k = 0;
        if(activeChestIds.length  <= to){
            lastIndex = activeChestIds.length ;
        }else{
            lastIndex = to;
        }

        for(uint i = from; i < lastIndex; i++){
            if(chestObjects[activeChestIds[i]].status == 1){
                count++;
            }
        }

        uint[] memory chests = new uint[](count);
        for(uint i = from; i < lastIndex; i++){
            if(chestObjects[activeChestIds[i]].status == 1){
                chests[k] = chestObjects[activeChestIds[i]].idNumber;
                k++;
            }
        }
        return chests;
    }
    function searchForChestIdsWithValidatorsAssignedBetweenIndices(uint from, uint to) public view returns (uint[] memory){
        uint count;
        uint lastIndex;
        uint k = 0;
        if(activeChestIds.length <= to){
            lastIndex = activeChestIds.length;
        }else{
            lastIndex = to;
        }

        for(uint i = from; i < lastIndex; i++){
            if(chestObjects[activeChestIds[i]].status == 2){
                count++;
            }
        }

        uint[] memory chests = new uint[](count);
        for(uint i = from; i < lastIndex; i++){
            if(chestObjects[activeChestIds[i]].status == 2){
                chests[k] = chestObjects[activeChestIds[i]].idNumber;
                k++;
            }
        }
        return chests;
    }
    function searchForValidatedChestIdsBetweenIndices(uint from, uint to) public view returns (uint[] memory){
        uint count;
        uint lastIndex;
        uint k = 0;
        if(activeChestIds.length <= to){
            lastIndex = activeChestIds.length;
        }else{
            lastIndex = to;
        }

        for(uint i = from; i < lastIndex; i++){
            if(chestObjects[activeChestIds[i]].status == 3){
                count++;
            }
        }

        uint[] memory chests = new uint[](count);
        for(uint i = from; i < lastIndex; i++){
            if(chestObjects[activeChestIds[i]].status == 3){
                chests[k] = chestObjects[activeChestIds[i]].idNumber;
                k++;
            }
        }
        return chests;
    }
    function searchForValidatedChestsBetweenIndices(uint from, uint to) public view returns (ChestObject[] memory){
        uint count;
        uint lastIndex;
        uint k = 0;
        if(activeChestIds.length <= to){
            lastIndex = activeChestIds.length;
        }else{
            lastIndex = to;
        }

        for(uint i = from; i < lastIndex; i++){
            if(chestObjects[activeChestIds[i]].status == 3){
                count++;
            }
        }

        ChestObject[] memory chests = new ChestObject[](count);
        for(uint i = from; i < lastIndex; i++){
            if(chestObjects[activeChestIds[i]].status == 3){
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
        uint validationsLength = validatorToValidations[forUser].length;
        ReturnValidatorChestData[] memory toValidateChests = new ReturnValidatorChestData[](validationsLength);
        for(uint i = 0; i < validationsLength; i++){
            toValidateChests[i] = ReturnValidatorChestData(chestObjects[validatorToValidations[forUser][i]],i);
        }
        return toValidateChests;
    }
    function getAllToBeValidatedChestsSizeForUser(address forUser)
        public
        view
        returns (uint)
    {
        return validatorToValidations[forUser].length;
        
    }
    function getActiveChestsBetweenIndices(uint from, uint to) public view returns (ChestObject[] memory) {
        uint lastIndex;
        uint k = 0;
        if(activeChestIds.length <= to){
            lastIndex = activeChestIds.length;
        }else{
            lastIndex = to;
        }
        uint count;
        for (uint256 i = from; i < lastIndex; i++) {
            if (
                chestObjects[activeChestIds[i]].claimant == address(0) &&
                chestObjects[activeChestIds[i]].status == 0
            ){
                count++;
            }
        }
        ChestObject[] memory chests = new ChestObject[](count);
        for (uint256 i = from; i < lastIndex; i++) {
            if (
                chestObjects[activeChestIds[i]].claimant == address(0) &&
                chestObjects[activeChestIds[i]].status == 0
            ){
                chests[k] = chestObjects[activeChestIds[i]];
                k++;
            }
        }
        return chests;
    }
    function getChestsBetweenIndices(uint from, uint to) public view returns (ChestObject[] memory) {
        uint lastIndex;
        uint k = 0;
        if(idNumber - 1 <= to){
            lastIndex = idNumber - 1;
        }else{
            lastIndex = to;
        }
        ChestObject[] memory chests = new ChestObject[](to - from);
        for (uint256 i = from; i < lastIndex; i++) {
            chests[k] = chestObjects[i];
            k++;
        }
        return chests;
    }
    function getAllActiveChestIds() public view returns (uint256[] memory) {
        return activeChestIds;
    }

    function getChest(uint256 index) public view returns (ChestObject memory) {
        return chestObjects[index];
    }

    function setNumberToAssignValidators(uint256 newNumber) external onlyOwner {
        numberToAssignValidators = newNumber;
    }
    function getActiveChestIdsLength() public view returns (uint) {
        return activeChestIds.length;
    }
}