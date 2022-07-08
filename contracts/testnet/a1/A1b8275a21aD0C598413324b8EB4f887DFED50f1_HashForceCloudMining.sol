//SPDX-License-Identifier: MIT 

pragma solidity ^0.8.15;

import "./IERC20.sol";
import "./Ownable.sol";

contract HashForceCloudMining is Ownable {
    address[] public hashForceAddress;
    address public busdTokenContractAddress;

    uint256 public fee;
    uint256 public minimumDeposit;

    uint public amountOfMiningMachinesAvailable;
    uint public amountOfMiningMachinesTotal;

    uint8 constant TOTAL_DEPOSIT_CONTRACT = 2;
    uint8 constant TIME_END_CONTRACT = 4;
    uint8 constant CRYPTOCURRENCY = 5;

    uint8 constant BITCOIN = 1;
    uint8 constant ETHEREUM = 2;

    mapping(uint8 => uint256) public minimumClaim;

    mapping(uint8 => string) public hashRateType;

    mapping(address => uint256) public discountForAccount;
    mapping(address => uint8) public depositRoundForTheAccount;
    mapping(address => mapping(uint256 => bool)) public accountClaim;
    mapping(address => mapping(uint256 => uint[])) public accountDetail;

    event Deposit(address indexed _account, uint8 _round, uint8 _contractDay, uint256 _totalPrice, uint8 _hashRateType);
    event Withdraw(address indexed _accountFrom, address indexed _accountTo, uint256 _amount);

    function deposit(uint8 _contractDay, uint256 _price, uint8 _hashRateType, uint8 _cryptocurrency) external
    {
        require(amountOfMiningMachinesAvailable > 0, "Mining machine not available");
        require(busdTokenContractAddress != address(0), "BUSD token is the zero address");
        require(_contractDay > 0 && _hashRateType >= 0, "Invalid values");
        require(_price >= minimumDeposit && _price != 0, "Invalid price");
        if(_hashRateType != 0)
        {
            require(bytes(hashRateType[_hashRateType]).length > 0, "Hash rate type is empty");
        }
        require(_cryptocurrency == BITCOIN || _cryptocurrency == ETHEREUM, "Invalid cryptocurrency");
        require(fee >= 0, "Invalid fee");
        require(discountForAccount[msg.sender] >= 0, "Invalid discount");
        
        uint256 calculatedFee = _price * fee / 100;
        uint256 calculatedDiscount = _price * discountForAccount[msg.sender] / 100;

        uint256 totalPrice = _price + calculatedFee - calculatedDiscount;
        
        IERC20 busdToken = IERC20(busdTokenContractAddress);

        uint256 balance = busdToken.balanceOf(msg.sender);
        require(balance >= totalPrice, "Your balance is insufficient");

        busdToken.transferFrom(msg.sender, address(this), totalPrice);

        uint timeNow = block.timestamp * 1000;
        uint timeEnd = timeNow + (_contractDay * 86400 * 1000);

        amountOfMiningMachinesAvailable -= 1;

        depositRoundForTheAccount[msg.sender] += 1;
        accountClaim[msg.sender][depositRoundForTheAccount[msg.sender]] = false;
        accountDetail[msg.sender][depositRoundForTheAccount[msg.sender]] = [_hashRateType, _contractDay, totalPrice, timeNow, timeEnd, _cryptocurrency];

        emit Deposit(msg.sender, depositRoundForTheAccount[msg.sender], _contractDay, totalPrice, _hashRateType);
    }

    function withdraw(uint8 _round, uint256 _amount, uint8 _cryptocurrency) external
    {
        require(accountClaim[msg.sender][_round] == false, "Unable to withdraw");
        require(accountDetail[msg.sender][_round][TIME_END_CONTRACT] > 0, "Permission denied");
        require(block.timestamp * 1000 >= accountDetail[msg.sender][_round][TIME_END_CONTRACT], "Cannot withdraw at the moment");
        
        require(_cryptocurrency == BITCOIN || _cryptocurrency == ETHEREUM, "Invalid cryptocurrency");
        require(accountDetail[msg.sender][_round][CRYPTOCURRENCY] == _cryptocurrency, "Not enough cryptocurrency");
        
        IERC20 busdToken = IERC20(busdTokenContractAddress);
        require(accountDetail[msg.sender][_round][TOTAL_DEPOSIT_CONTRACT] >= _amount, "Amount exceeds balance");
        require(busdToken.balanceOf(address(this)) >= _amount, "This contract amount exceeds balance");

        busdToken.transfer(msg.sender, _amount);

        accountDetail[msg.sender][_round][TOTAL_DEPOSIT_CONTRACT] -= _amount;

        emit Withdraw(address(this), msg.sender, _amount);
    }

    function claimReward(uint8 _round, uint256 _amount, uint8 _cryptocurrency) external
    {
        require(accountClaim[msg.sender][_round] == false, "Unable to claim");
        require(accountDetail[msg.sender][_round][TOTAL_DEPOSIT_CONTRACT] > 0, "Permission denied");
        require(_cryptocurrency == BITCOIN || _cryptocurrency == ETHEREUM, "Invalid cryptocurrency");
        require(_amount > minimumClaim[_cryptocurrency], "Not enough amount");

        accountClaim[msg.sender][_round] = true;
        accountDetail[msg.sender][_round][TOTAL_DEPOSIT_CONTRACT] = 0;
    }

    function transferBusdTokenFromContract(address  _to, uint256 _amount) external 
    {
        require(isHashForceAddress(msg.sender), "Permission denied");
        
        IERC20 busdToken = IERC20(busdTokenContractAddress);
        require(busdToken.balanceOf(address(this)) >= _amount, "This contract amount exceeds balance");

        busdToken.transfer(_to, _amount);
    }
        
    function isHashForceAddress(address _hashForceAddress) internal view returns (bool) 
    {
        for(uint i = 0; i < hashForceAddress.length; i++) 
        {
            if(_hashForceAddress == hashForceAddress[i])
            {
                return true;
            }
        }
        return false;
    }

    function setHashForceAddress(address[] memory _hashForceAddress) external onlyOwner 
    {
        hashForceAddress = _hashForceAddress;
    }

    function setAmountOfMiningMachinesTotal(uint _amountTotal, uint _amountAvailable) external onlyOwner
    {
        amountOfMiningMachinesTotal = _amountTotal;
        amountOfMiningMachinesAvailable = _amountAvailable;
    }

    function setHashRateType(uint8 _type, string memory _typeDescription) external onlyOwner
    {
        require(_type > 0, "Invalid type");

        hashRateType[_type] = _typeDescription;
    }

    function setMinimumDeposit(uint256 _minimumDeposit) external onlyOwner
    {
        require(_minimumDeposit > 0, "Invalid minimum deposit");

        minimumDeposit = _minimumDeposit;
    }

    function setMinimumClaim(uint8 _cryptocurrency, uint256 _minimumClaim) external onlyOwner
    {
        require(_minimumClaim > 0, "Invalid minimum claim");
        require(_cryptocurrency == BITCOIN || _cryptocurrency == ETHEREUM, "Invalid cryptocurrency");

        minimumClaim[_cryptocurrency] = _minimumClaim;
    }

    function setFeeValue(uint256 _fee) external onlyOwner
    {
        require(_fee > 0, "Invalid fee");
        
        fee = _fee;
    }

    function setDiscountForAccount(address _account, uint256 _discount) external onlyOwner
    {
        discountForAccount[_account] = _discount;
    }

    function setBusdTokenContractAddress(address _busdTokenContractAddress) external onlyOwner
    {
        busdTokenContractAddress = _busdTokenContractAddress;
    }
    
    function getAccountDetail(address _account, uint _round) public view returns (uint256[] memory)
    {
        return accountDetail[_account][_round];
    }
}