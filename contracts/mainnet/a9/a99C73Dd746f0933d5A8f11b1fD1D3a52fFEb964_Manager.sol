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

interface TreasureContract {
    function getAllToBeValidatedChestsSizeForUser(address forUser)
        external
        view
        returns (uint256);
}

abstract contract ManagerContract {
    function getAmountOfValidators() external view virtual returns (uint256);
    function getValidatorStakedAmount(address validator) external view virtual returns (uint);
    function getAllValidators()
        external
        view
        virtual
        returns (address[] memory);

    function getValidatorData(address validator)
        external
        view
        virtual
        returns (uint256[3] memory);

    function resetValidatorDataLosses(address validator)
        external
        virtual
        returns (bool);

    function increaseValidatorDataLosses(address validator)
        external
        virtual
        returns (bool);

    function setValidatorDataCooldown(address validator)
        external
        virtual
        returns (bool);

    function increaseValidatorDataStakeReduction(address validator)
        external
        virtual
        returns (bool);

    function getRequiredAmountToJoinValidators()
        external
        view
        virtual
        returns (uint256);

    function getAmountAllowedLosses() external view virtual returns (uint256);
}

contract Manager is Ownable, ManagerContract {
    receive() external payable {}

    constructor() {
        validatorStakingAmount = 100_000_000_000_000;
        stakeReductionAmount = validatorStakingAmount / 1000;
        amountAllowedLosses = 3;
        dopTokenContractAddress = 0x1316F8e84c03e236355639f4d18018c55D3E23f9;
        treasureContratAddress = 0x347a1250cBCDcB2208A931CCB77e75dcc8ad3D9b;
        hasWritingRights[msg.sender] = true;
    }

    address[] public validators;
    uint256 public validatorStakingAmount;
    uint256 public stakeReductionAmount;
    uint256 public amountAllowedLosses;
    address public dopTokenContractAddress;
    address public treasureContratAddress;
    mapping (address => uint) public validatorToStakedAmount;

    function getValidatorStakedAmount(address validator) public view override returns (uint){
        return validatorToStakedAmount[validator];
    }
    function setDdropsTokenAddress(address newAddress)
        external
        onlyOwner
        returns (address)
    {
        return dopTokenContractAddress = newAddress;
    }
    function setStakeReductionAmount(uint newAmount) external onlyOwner {
        stakeReductionAmount = newAmount;
    }
    function setTreasureContractAddress(address newTreasureContractAddress)
        external
        onlyOwner
    {
        treasureContratAddress = newTreasureContractAddress;
    }

    struct ValidatorData {
        uint256 losses;
        uint256 cooldown;
        uint256 stakeReduction;
    }
    //Manage contracts who can write to this contract
    mapping(address => bool) public hasWritingRights;
    mapping(address => ValidatorData) public validatorToValidatorData;

    function joinValidation() external {
        ERC20 dopTokenContract = ERC20(dopTokenContractAddress);
        require(
            dopTokenContract.transferFrom(
                msg.sender,
                address(this),
                validatorStakingAmount
            ),
            'Insufficient balance or tokens not approved'
        );
        validators.push(msg.sender);
        validatorToStakedAmount[msg.sender] = validatorToStakedAmount[msg.sender] + validatorStakingAmount;
    }
    function leaveValidation(uint256 addressIndex) public returns (bool) {
        ERC20 dopTokenContract = ERC20(dopTokenContractAddress);
        TreasureContract dopTreasure = TreasureContract(treasureContratAddress);
        uint256 yetToValidateNumber = dopTreasure
            .getAllToBeValidatedChestsSizeForUser(msg.sender);
        require(
            yetToValidateNumber == 0,
            'You have yet to be validated chests, please make sure you have fulfilled your validator obligations before leaving the validators'
        );
        require(
            validators[addressIndex] == msg.sender,
            'Your address could not be found at the specified index'
        );
        dopTokenContract.transfer(
            msg.sender,
            validatorStakingAmount -
            validatorToValidatorData[msg.sender].stakeReduction
        );
        if(validatorToValidatorData[msg.sender].stakeReduction > 0){
            dopTokenContract.transfer(
            dopTokenContractAddress,
            validatorToValidatorData[msg.sender].stakeReduction
        );
        }
        validatorToStakedAmount[msg.sender] = validatorToStakedAmount[msg.sender] - validatorStakingAmount;
        validatorToValidatorData[msg.sender].stakeReduction = 0;
        validators[addressIndex] = validators[validators.length - 1];
        validators.pop();
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

    modifier onlyWriter() {
        require(
            hasWritingRights[msg.sender] == true,
            'Caller has no writing rights'
        );
        _;
    }

    function getAmountOfValidators() external view override returns (uint256) {
        return validators.length;
    }

    function getAllValidators()
        external
        view
        override
        returns (address[] memory)
    {
        return validators;
    }

    function getValidatorsBetweenIndexes(uint from, uint to) public view returns (address[] memory) {
        require(to <= validators.length, "Index out of bounds");
        address[] memory _validators = new address[](to - from);
        uint256 k = 0;
        for (uint256 i = from; i < to; i++) {
            _validators[k] = validators[i];
            k++;
        }
        return _validators;
    }

    function getValidatorData(address validator)
        external
        view
        override
        returns (uint256[3] memory returnedValidatorData)
    {
        returnedValidatorData[0] = validatorToValidatorData[validator].losses;
        returnedValidatorData[1] = validatorToValidatorData[validator].cooldown;
        returnedValidatorData[2] = validatorToValidatorData[validator].stakeReduction;
    }

    function resetValidatorDataLosses(address validator)
        external
        override
        onlyWriter
        returns (bool)
    {
        validatorToValidatorData[validator].losses = 1;
        return true;
    }

    function increaseValidatorDataLosses(address validator)
        external
        override
        onlyWriter
        returns (bool)
    {   
        validatorToValidatorData[validator].losses++;
        if(validatorToValidatorData[validator].losses >= amountAllowedLosses){
            validatorToValidatorData[validator].losses = 0;
            validatorToValidatorData[validator].stakeReduction += stakeReductionAmount;
            validatorToValidatorData[validator].cooldown = 0;
        }
        return true;
    }

    function setValidatorDataCooldown(address validator)
        external
        override
        onlyWriter
        returns (bool)
    {
        validatorToValidatorData[validator].cooldown = block.number + 28800;
        return true;
    }

    function increaseValidatorDataStakeReduction(address validator)
        external
        override
        onlyWriter
        returns (bool)
    {
        if(validatorToValidatorData[validator].stakeReduction >= validatorToStakedAmount[validator]){
            ERC20 dopTokenContract = ERC20(dopTokenContractAddress);
            dopTokenContract.transfer(dopTokenContractAddress,validatorToStakedAmount[validator]);
            validatorToStakedAmount[validator] = 0;
            validatorToValidatorData[validator].stakeReduction = 0;

        }else{
            validatorToValidatorData[validator].stakeReduction += stakeReductionAmount;
        }
        return true;
    }

    function getRequiredAmountToJoinValidators()
        external
        view
        override
        returns (uint256)
    {
        return validatorStakingAmount;
    }

    function getAmountAllowedLosses() external view override returns (uint256) {
        return amountAllowedLosses;
    }
}