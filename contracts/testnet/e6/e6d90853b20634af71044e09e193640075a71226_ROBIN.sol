/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


contract EventContract {

        event depositWithdrawEvent(
            address indexed _address, 
            uint256 indexed amount
         );
            
        event depositCreateEvent(
            address indexed _address, 
            uint256 indexed amount, 
            uint32 finish_date,
            uint8 staking_days
        );

}

pragma solidity >=0.7.0 <0.9.0;


interface USDTInterface {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;


contract ROBIN is EventContract {

    uint256 constant MAX_DEPOSIT = 5000000000;
    uint256 constant MIN_DEPOSIT = 20000000;
    uint8 constant MIN_STAKE_DAYS = 5;
    uint8 constant MAX_STAKE_DAYS = 90;
    uint8 constant SERVICE_FEE_PERCENT = 3;
    uint8 constant DAILY_PERCENT = 16;
    
    string public name = "DEX Robin Hood Community";
    string public symbol = "ROBIN";
    uint8 public decimals = 6;
    
    address private income_reserve;
    bool private set_income_reserve = false;
    uint32 public activeDeposits = 0;
    
    struct Ini {
        uint serviceFee;
        address owner;
        address income;
    }

    Ini public ini;

    USDTInterface USDTContract = USDTInterface(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);

    mapping (bytes32 => bool) private queues;

    constructor() {
        ini.serviceFee = 0;
        ini.owner = address(this);
        ini.income = msg.sender;
    }

    function init (address _address) public returns (bool) {
        require(msg.sender == ini.income, "You cannot perform this action!");
        require(set_income_reserve == false, "Already init!");
        income_reserve = _address;
        set_income_reserve = true;
        return true;
    }

    function depositCreate(uint256 _amount, uint8 _day_stake) public returns (bool) {
        require(_amount >= MIN_DEPOSIT && _amount <= MAX_DEPOSIT, "Invalid deposit amount!");
        require(_day_stake >= MIN_STAKE_DAYS && _day_stake <= MAX_STAKE_DAYS, "Invalid staking days count!");
        require(msg.sender != address(0), "TRC20: mint to the zero address!");
        require(USDTContract.allowance(msg.sender, ini.owner) >= _amount, "No withdrawal permission or insufficient balance");
        USDTContract.transferFrom(msg.sender, ini.owner, _amount);
        ini.serviceFee += _amount / 100 * SERVICE_FEE_PERCENT;
        _addToQueue(msg.sender, _amount, uint32(block.timestamp + uint256(_day_stake) * 24 * 60 * 60), _day_stake);
        return true;
    }
    
    function _addToQueue (
            address _to,
            uint _value,
            uint32 _timestamp,
            uint8 _day_stake
        ) private  {
      
            bytes32 txId = keccak256(abi.encode(
                _to,
                _value,
                _timestamp,
                _day_stake
            ));
        
            require(!queues[txId], "already queues");
            
            queues[txId] = true;
            activeDeposits++;

            emit depositCreateEvent(_to, _value, uint32(_timestamp), _day_stake);
    }
    
    function depositWithdraw (
            address to,
            uint amount,
            uint32 finish_date,
            uint8 day_stake
        ) public returns (bool) {
            require(to == msg.sender || ini.income == msg.sender, "Invalid deposit owner!");
            require(block.timestamp >= finish_date, "Invalid timestamp, too early!");
            
            bytes32 txId = keccak256(abi.encode(
                to,
                amount,
                finish_date,
                day_stake
            ));
            
            require(queues[txId], "Deposit not found!");
            uint pecent = amount / 10000 * DAILY_PERCENT * day_stake;
            uint result = amount + pecent;

            require(USDTContract.balanceOf(ini.owner) >= result, "Not enough USDT on contract balance!");
            
            USDTContract.transfer(to, result);
            delete queues[txId];
            activeDeposits--;
            emit depositWithdrawEvent(to, result);
            
            return true;
    }
    
    function balanceOfUSDT() public view returns (uint256) {
        return USDTContract.balanceOf(ini.owner);
    }

    function setNewIncome(address destination) public returns (bool) {
        require(set_income_reserve == true, "income_reserve is no init");
        require(msg.sender == income_reserve,"You cannot perform this action");
        ini.income = destination;
        return true;
    }

    function serviceFeeWithdraw() public returns (bool) {
        require(
            msg.sender == ini.income,
            "You cannot perform this action"
        );
        USDTContract.transfer(msg.sender, ini.serviceFee);
        ini.serviceFee = 0;
        return true;
    }

}