/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

//SPDX-License-Identifier: MTI
pragma solidity ^0.8.15;

interface ERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Dapp {
    //USDT
    ERC20 USDT;
    // time
    uint256 TIME_LOCK = 1 weeks;
    uint256 TIME_PROFIT = 3 hours;
    // address
    address OWNER;
    address LIQUIDITY;
    address DEVELOPER;
    // Percentage
    uint8 PERCENTAGE_GAIN = 22;
    uint8 PERCENTAGE_REF = 28;
    uint8[4] PERCENTAGE_REF_ARRAY = [92,10,4,1];
    // batch scheme
    struct BATCH {
        uint256 TIME;
        uint256 AMOUNT;
        uint256 GAIN;
        bool STATE;
    }
    // modifier
    modifier OnlyOwner {
        require(msg.sender == OWNER,"You don't have access to this feature");
        _;
    }
    modifier OnlyDeveloperAndOwner {
        require(msg.sender == OWNER || msg.sender == DEVELOPER,"You don't have access to this feature");
        _;
    }
    modifier NoContract {
        require(!isContract(msg.sender),"We do not allow contracts");
        _;
    }
    // construtor0
    constructor (ERC20 addressUSDT, address _owner, address _liquidity){
        USDT = addressUSDT;
        OWNER = _owner;
        LIQUIDITY = _liquidity;
    }
    // balance
    mapping(address => uint256) BALANCE;
    mapping(address => uint256) TIME_LOCKED;
    mapping(address => uint256) GAIN_REF;
    // address BATCH
    mapping(address => BATCH[]) MY_BATCH;
    // REFERENCE
    mapping(address => uint256) REF_TO_ADDRESS;
    mapping(uint256 => address) REF_TO_NUMBERS;
    mapping(address => address) INVITED;
    // event
    event _WITHDRAW(address indexed account, uint256 indexed amount);
    event _INVERTER(address indexed account, uint256 indexed amount);
    event _GAIN(address indexed account, uint256 indexed gain, uint256 indexed index);
    // functions { }

    // views
    function _TIME_LOCK() public view returns(uint256){
        return TIME_LOCK;
    }
    function _TIME_PROFIT() public view returns(uint256){
        return TIME_PROFIT;
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
    function _BALANCE_LOCKED(address account) public view returns(uint256){
        uint256 amount;
        for(uint256 x; x < MY_BATCH[account].length;x++){
            if(MY_BATCH[account][x].STATE){
                uint256 free = VIEW_GAIN(msg.sender,x) - CALCULATE_UI(VIEW_GAIN(msg.sender,x), PERCENTAGE_REF, 2);
                amount += MY_BATCH[account][x].AMOUNT + free;
            }
        }
        return amount;
    }
    function _TIME_LOCKED(address account) public view returns(uint256){
        return TIME_LOCKED[account];
    }
    function _MY_BATCH(address account, uint256 index) public view returns(BATCH memory){
        return MY_BATCH[account][index];
    }
    function _MY_BATCH_ALL(address account) public view returns(BATCH[] memory){
        return MY_BATCH[account];
    }
    // UI VIEW
    function RamdonNUM() internal view returns(uint256){
        return uint256(keccak256(abi.encode(msg.sender,block.number)))%10**9;
    }
    function VIEW_GAIN(address account, uint256 index) public view returns(uint256){
        uint256 amount = MY_BATCH[account][index].AMOUNT;
        if(MY_BATCH[account][index].TIME + TIME_PROFIT > block.timestamp)return 0;
        return CALCULATE_UI(amount, PERCENTAGE_GAIN, 4);
    }
    function CALCULATE_UI(uint256 amount, uint8 percentage, uint8 zero)internal pure returns(uint256){
        return amount * percentage / (10**zero);
    }
    // write
    function GET_REF(address account)internal{
        if(REF_TO_ADDRESS[account]!=0)return;
        REF_TO_ADDRESS[account] = RamdonNUM();
        REF_TO_NUMBERS[REF_TO_ADDRESS[account]] = account;
    }
    // change
    function PERCENTAGE_CHANGE(uint8 gain, uint8 ref, uint8[4] memory ref_array) public OnlyDeveloperAndOwner {
        PERCENTAGE_GAIN = gain;
        PERCENTAGE_REF = ref;
        PERCENTAGE_REF_ARRAY = ref_array;
    }
    function TIME_CHANGE(uint256 profit, uint256 lock) public OnlyDeveloperAndOwner {
        TIME_LOCK=lock;
        TIME_PROFIT=profit;
    }
    //owner
    function WITHDRAW_OWNER(uint256 amount) public OnlyOwner{
        USDT.transfer(msg.sender,amount);
    }
    function CHANGE_OWNER(address newOwner) public OnlyOwner{
        OWNER = newOwner;
    }
    // WITHDRAW
    function WITHDRAW(uint256 amount) public {
        require(amount > 0 && _BALANCE(msg.sender)>=amount,"you don't have enough balance");
        USDT.transfer(msg.sender,amount);
        BALANCE[msg.sender] -= amount;
        emit _WITHDRAW(msg.sender,amount);
    }
    // PAY
    function PAY_TO_REF(address account, uint256 amount) internal {
        amount = CALCULATE_UI(amount,PERCENTAGE_REF,2);
        uint256 free = CALCULATE_UI(amount, PERCENTAGE_REF_ARRAY[0],2);
        BALANCE[LIQUIDITY] += CALCULATE_UI(free, 50,2);
        if(INVITED[account]==address(0)){
            BALANCE[LIQUIDITY] += CALCULATE_UI(amount, PERCENTAGE_REF_ARRAY[1]+PERCENTAGE_REF_ARRAY[2]+PERCENTAGE_REF_ARRAY[3], 2);
            return;
        }
        BALANCE[INVITED[account]] += CALCULATE_UI(amount,PERCENTAGE_REF_ARRAY[1],2);
        GAIN_REF[INVITED[account]] += CALCULATE_UI(amount,PERCENTAGE_REF_ARRAY[1],2);
        if(INVITED[INVITED[account]]==address(0)){
            BALANCE[LIQUIDITY] += CALCULATE_UI(amount, PERCENTAGE_REF_ARRAY[2]+PERCENTAGE_REF_ARRAY[3],2);
            return;
        }
        BALANCE[INVITED[INVITED[account]]] += CALCULATE_UI(amount, PERCENTAGE_REF_ARRAY[2],2);
        GAIN_REF[INVITED[INVITED[account]]] += CALCULATE_UI(amount, PERCENTAGE_REF_ARRAY[2],2);
        if(INVITED[INVITED[INVITED[account]]]==address(0)){
            BALANCE[LIQUIDITY] += CALCULATE_UI(amount, PERCENTAGE_REF_ARRAY[3],2);
            return;
        }
        BALANCE[INVITED[INVITED[INVITED[account]]]] += CALCULATE_UI(amount,PERCENTAGE_REF_ARRAY[3],2);
        GAIN_REF[INVITED[INVITED[INVITED[account]]]] += CALCULATE_UI(amount,PERCENTAGE_REF_ARRAY[3],2);
    }
    // farm
    function FARM(uint256 index) public NoContract{
        require(MY_BATCH[msg.sender][index].STATE,"was already harvested");
        require(MY_BATCH[msg.sender][index].TIME + TIME_LOCK <= block.timestamp,"You don't have to harvest");
        MY_BATCH[msg.sender][index].STATE = false;
        uint256 free = VIEW_GAIN(msg.sender,index) - CALCULATE_UI(VIEW_GAIN(msg.sender,index), PERCENTAGE_REF, 2);
        MY_BATCH[msg.sender][index].GAIN = VIEW_GAIN(msg.sender,index);
        BALANCE[msg.sender] += MY_BATCH[msg.sender][index].AMOUNT + free;
        PAY_TO_REF(msg.sender, MY_BATCH[msg.sender][index].GAIN);
    }
    // INVERTS
    function INVETS(uint256 amount, uint256 ref) public NoContract{
        require(amount>0,"you have not added balance");
        require(TIME_LOCKED[msg.sender] + TIME_PROFIT <= block.timestamp, "This is not the time to invest");
        USDT.transferFrom(msg.sender, address(this), amount);
        MY_BATCH[msg.sender].push(BATCH(block.timestamp,amount,0,true));
        TIME_LOCKED[msg.sender] = block.timestamp;
        GET_REF(msg.sender);
        ADD_REF(REF_TO_NUMBERS[ref]);
    } 
    // REINVERTS 
    function REINVETS(uint256 index) public NoContract{
        require(MY_BATCH[msg.sender][index].STATE,"was already consumed");
        require(TIME_LOCKED[msg.sender] + TIME_PROFIT <= block.timestamp, "This is not the time to reinvest");
        uint256 free = VIEW_GAIN(msg.sender,index) - CALCULATE_UI(VIEW_GAIN(msg.sender,index), PERCENTAGE_REF, 2);
        require(MY_BATCH[msg.sender][index].AMOUNT + free > MY_BATCH[msg.sender][index].AMOUNT, "you do not have enough funds to reinvest");
        MY_BATCH[msg.sender].push(BATCH(block.timestamp,MY_BATCH[msg.sender][index].AMOUNT + free,0,true));
        MY_BATCH[msg.sender][index].STATE = false;
        MY_BATCH[msg.sender][index].GAIN = VIEW_GAIN(msg.sender,index);
        PAY_TO_REF(msg.sender, MY_BATCH[msg.sender][index].GAIN);
        TIME_LOCKED[msg.sender] = block.timestamp;
    }
    //ADD REF
    function ADD_REF(address account) internal {
        if(account==address(0) || account==msg.sender || INVITED[msg.sender]!=address(0) || INVITED[msg.sender] == account)return;
        INVITED[msg.sender] = account;
    }
    // is Contract
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.
        return account.code.length > 0;
    }
}