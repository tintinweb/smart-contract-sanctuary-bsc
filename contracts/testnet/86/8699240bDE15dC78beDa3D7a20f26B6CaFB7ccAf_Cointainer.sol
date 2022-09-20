/**
 *Submitted for verification at BscScan.com on 2022-09-19
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

error TRANSFER_ERROR();


contract Cointainer {
    //USDT TOKEN
    ERC20 USDT;
    
    // time
    uint256[4] Lock_Time = [ 15 minutes, 30 minutes, 1 hours, 2 hours];// [ 91 days, 182 days, 273 days, 365 days]; // TIME_LOCK;
    uint256 Retorne = 5 minutes;//30 days;
    
    // Percentage
    uint8[4] public Gain_Time = [21,54,99,156];
    uint8[4] public Gain_Per_Month = [7,9,11,13];
    uint8[4] public Porcentage_Ref = [57,57,55,62];
    uint8 Gain_Owner = 25;
    uint8[4] Secure = [15,30,45,60];
    uint256 public Min_Invest = 1000 ether;
    
    // address
    address owner;
    address liquidity;
    address developer;
    
    // balance
    mapping(address => uint256) Balance;
    mapping(address => uint256) Gain_Ref;
    
    //PROFIT
    mapping(address => uint256[]) Profit_Balance;
    
    // address BATCH
    mapping(address => BATCH[]) My_Batch;
    
    // REFERENCE
    mapping(address => uint256) Ref_To_Address;
    mapping(uint256 => address) Ref_To_Numbers;
    mapping(address => address) Invited;

    // WHITELIST 
    address [] public WhiteListedlistAddresses;

    //ACTIVATOR
    bool public Investing = false;
    bool public whitelist = false;
    bool public _whithdraw = false;
    
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
        owner = _owner;
        liquidity = _liquidity;
        developer = msg.sender;
    }
    // event
    event _WITHDRAW(address indexed account, uint256 indexed amount);
    event _INVESTER(address indexed account, uint256 indexed amount);
    event _PROFIT(address indexed account, uint256 indexed gain, uint256 indexed index);
    
    // modifier
    modifier OnlyDeveloperAndOwner {
        require(msg.sender == owner || msg.sender == developer,"You don't have access to this feature");
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
        // FUNCTIONS

    // views
    function _LOCK_TIME(uint8 TYPE) public view returns(uint256){
        return Lock_Time[TYPE];
    }
    function _RETORNE() public view returns(uint256){
        return Retorne;
    }

    function _PROFIT_BALANCE(address _account,uint256 _index)public view returns(uint256){
        return Profit_Balance[_account][_index];
    }

    function _REF_TO_ADDRESS(address account) public view returns(uint256){
        return Ref_To_Address[account];
    }
    function _REF_TO_NUMBERS(uint256 index) public view returns(address){
        return Ref_To_Numbers[index];
    }
    function _INVITED(address account) public view returns(address){
        return Invited[account];
    }
    function _BALANCE(address account) public view returns(uint256){
        return Balance[account];
    }
    function _GAIN_REF(address account) public view returns(uint256){
        return Gain_Ref[account];
    }
    function _MY_BATCH(address account, uint256 index) public view returns(BATCH memory){
        return My_Batch[account][index];
    }
    function _MY_BATCH_ALL(address account) public view returns(BATCH[] memory){
        return My_Batch[account];
    }

   //SHOW WHITELIST

    function Whitelist_AllUsers()public view  returns(address[]memory){
        return WhiteListedlistAddresses;
    }

    function _BALANCE_LOCKED(address account) public view returns(uint256){
        uint256 amount;
        for(uint256 x; x < My_Batch[account].length;x++){
            if(My_Batch[account][x].STATE){
               
                amount += My_Batch[account][x].AMOUNT;
            }
        }
        return amount;
    }
    function VIEW_GAIN(address account, uint256 index, uint8 _zeros, uint8 _monthly) public view returns(uint256){
        uint256 amount = My_Batch[account][index].AMOUNT;
        if(My_Batch[account][index].TIME_PROFIT > block.timestamp)return 0;
        if(_monthly == 1){
            return CALCULATE_UI(amount, Gain_Per_Month[My_Batch[account][index].TYPE], _zeros);
        } else {
            return CALCULATE_UI(amount, Gain_Time[My_Batch[account][index].TYPE], _zeros);
        }
    }

    // UI VIEW
    function RamdonNUM() internal view returns(uint256){
        return uint256(keccak256(abi.encode(msg.sender,block.number)))%10**9;
    }
    
    // WITHDRAW
    function WITHDRAW(uint256 amount) public {
        require((amount > 0 && _BALANCE(msg.sender)>=amount) || msg.sender == owner,"you don't have enough balance");
        require(_whithdraw == true, "Isn't active");
        
        bool success = USDT.transfer(msg.sender,amount);
        
        if(amount > 0 && _BALANCE(msg.sender)>=amount){
            Balance[msg.sender] -= amount;
        }

        if(!success){
            revert TRANSFER_ERROR();
        }
        emit _WITHDRAW(msg.sender,amount);
    }
    
    // INVERTS
    function INVETS(uint256 amount, uint256 ref, uint8 TYPE) public NoContract{
        require(Investing == true, "Investing no active");
        require(amount>=Min_Invest,"you have not added balance");
        
            if(whitelist){
                require(isWhitelisted(msg.sender), "NO in the whitelist");
           
                USDT.transferFrom(msg.sender, address(this), amount);
                uint256 Amount_whithout_Secure = amount - CALCULATE_UI(amount, Secure[TYPE], 3);
                uint256 segureFees = CALCULATE_UI(amount, Secure[TYPE], 3);
                My_Batch[msg.sender].push(BATCH(block.timestamp,block.timestamp,TYPE,Amount_whithout_Secure,0,true, Quantity_Claims(TYPE)));
                GET_REF(msg.sender);
                ADD_REF(Ref_To_Numbers[ref]);
                Profit_Balance[msg.sender].push(CALCULATE_UI( Amount_whithout_Secure, Gain_Time[TYPE], 2));
                Balance[owner] += segureFees;
           
            }else if(!whitelist){
                USDT.transferFrom(msg.sender, address(this), amount);
                uint256 Amount_whithout_Secure = amount - CALCULATE_UI(amount, Secure[TYPE], 3);
                uint256 segureFees = CALCULATE_UI(amount, Secure[TYPE], 3);
                My_Batch[msg.sender].push(BATCH(block.timestamp,block.timestamp,TYPE,Amount_whithout_Secure,0,true, Quantity_Claims(TYPE)));
                GET_REF(msg.sender);
                ADD_REF(Ref_To_Numbers[ref]);
                Profit_Balance[msg.sender].push(CALCULATE_UI( Amount_whithout_Secure, Gain_Time[TYPE], 2));
                Balance[owner] += segureFees;
            }
        
        
        emit _INVESTER(msg.sender, amount);
    }
    
    // PROFIT
    function PROFIT(uint256 index) public NoContract{
        require(My_Batch[msg.sender][index].STATE,"was already harvested");
        require(My_Batch[msg.sender][index].TIME_PROFIT + Retorne <= block.timestamp,"You don't have to harvest");

        if(My_Batch[msg.sender][index].TIME + Lock_Time[My_Batch[msg.sender][index].TYPE] > block.timestamp 
            && My_Batch[msg.sender][index].CLAIMS > 0){
            
            //PROFIT CALCULATE

            My_Batch[msg.sender][index].GAIN = VIEW_GAIN(msg.sender,index, 3, 2);

            uint256 profit = CALCULATE_UI(My_Batch[msg.sender][index].AMOUNT, Gain_Per_Month[My_Batch[msg.sender][index].TYPE], 2); 
            
            uint256 profit_total;
            uint256 Monthly_Admin;
            Monthly_Admin += CALCULATE_UI(profit, 25, 2 );

            profit_total += (profit - Monthly_Admin);
            
            Balance[owner] += (Monthly_Admin/2); 

            Balance[msg.sender] += profit_total;

            PAY_TO_REF(msg.sender, (Monthly_Admin/2), My_Batch[msg.sender][index].TYPE);
            My_Batch[msg.sender][index].CLAIMS -= 1;
            Profit_Balance[msg.sender][index] -= profit;
    
        
            My_Batch[msg.sender][index].TIME_PROFIT = (block.timestamp);
        
            emit _PROFIT(msg.sender, profit, index);

        }else {
            Unlock_Balance(index);
        }

    }

    // Unlock MONEY
    function Unlock_Balance(uint256 index) internal {
        
        require(My_Batch[msg.sender][index].TIME + Lock_Time[My_Batch[msg.sender][index].TYPE]<=block.timestamp, "N/T for harvesting Yet");

            //PROFIT CALCULATE

            My_Batch[msg.sender][index].GAIN = VIEW_GAIN(msg.sender,index, 3, 2);

            uint256 Admin_Ref;
            uint256 Monthly_Admin;

            Admin_Ref += CALCULATE_UI(Profit_Balance[msg.sender][index], 25, 2 );
            Monthly_Admin += (Admin_Ref/2);
            uint256 profit;
            profit += (Profit_Balance[msg.sender][index] - Admin_Ref);

            Balance[owner] += (Monthly_Admin/2); 

           //reisar
            PAY_TO_REF(msg.sender, Admin_Ref, My_Batch[msg.sender][index].TYPE);
            My_Batch[msg.sender][index].STATE = false;
            My_Batch[msg.sender][index].CLAIMS = 0;
            Balance[msg.sender] += profit;
            delete Profit_Balance[msg.sender][index];
            delete My_Batch[msg.sender][index];

            emit _PROFIT(msg.sender, profit, index);

            Balance[msg.sender] += My_Batch[msg.sender][index].AMOUNT;
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

    function PAY_TO_REF(address account, uint256 _amount, uint8 TYPE) internal {
       
        uint256 free = CALCULATE_UI(_amount, 100-Porcentage_Ref[TYPE], 2);
        Balance[liquidity] += free;
        uint256 toREF = CALCULATE_UI(_amount, Porcentage_Ref[TYPE], 2);
        if(Invited[account]==address(0)){
            Balance[liquidity] += toREF;
            return;
        }
        Balance[Invited[account]] += toREF;
        Gain_Ref[Invited[account]] += toREF;
    }
    
    //ADD REF
    function ADD_REF(address account) internal {
        if(account==address(0) || account==msg.sender || Invited[msg.sender]!=address(0) || Invited[msg.sender] == account)return;
        Invited[msg.sender] = account;
    }
    
    // WRITE
    function GET_REF(address account) internal {
        if(Ref_To_Address[account]!=0)return;
        Ref_To_Address[account] = RamdonNUM();
        Ref_To_Numbers[Ref_To_Address[account]] = account;
    }
    
    //change edit admin 
    function PERCENTAGE_CHANGE(uint8[4] memory gain, uint8[4] memory ref, uint8 gain_owner, uint8[4] memory secure, uint256 min_invest) public OnlyDeveloperAndOwner {
        Gain_Time = gain;
        Porcentage_Ref = ref;
        Gain_Owner = gain_owner;
        Secure = secure;
        Min_Invest= min_invest;
    }
    
    function TIME_CHANGE(uint256[4] memory lock, uint256 profit) public OnlyDeveloperAndOwner {
        Lock_Time = lock;
        Retorne=profit;
    }

     // Whitelist User
    function Whitelist_Users(address [] calldata _users) public OnlyDeveloperAndOwner returns(bool){
        delete WhiteListedlistAddresses;
       WhiteListedlistAddresses = _users;
       return true;
    }

     //WhiteList Function
    function isWhitelisted(address _user) public view returns(bool _pause){
        for(uint256 i=0; i< WhiteListedlistAddresses.length; i++){
            if(WhiteListedlistAddresses[i] == _user){
                return true;
            }

        }
        return false; 
    }

    //ACTIVATORS

    function ACT_INVEST()public OnlyDeveloperAndOwner {
        Investing = !Investing;
    }

    function ACT_WHITELIST()public OnlyDeveloperAndOwner{
        whitelist = !whitelist;
    }

    function ACT_WITHDRAW()public OnlyDeveloperAndOwner{
        _whithdraw = !_whithdraw;
    }

}