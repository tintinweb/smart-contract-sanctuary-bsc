/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.21;
interface Wol {
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
interface SwapPair {
    function transferFrom(address from, address to, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
}
interface IsRegister {
    function isUserExists(address from) external pure returns (bool);
}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = (a - (a % b)) / b;
        return c;
    }
    // function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    //     require(b > 0, errorMessage);
    //     uint256 c = (a - (a % b)) / b;
    //     return c;
    // }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
 
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
 
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
contract Lp{
    using SafeMath for uint256;

    mapping (address => uint256) public balances;  //入金LP
    mapping (address => uint256) public ToReceive;  //wol待领取
    event BuyToSell(address indexed userAddress , uint256 money, uint8 types);  //type = 1 买入   2卖出
    event Withdrawal(address indexed userAddress , uint256 b, uint8 types); //type = 1 提现wol type = 2 提现wol1
    struct Ap{
        uint256 lp;
        uint256 createtime; 
        uint256 createtime1; 
        uint256 isOut;
    }
    struct day{
        uint256 TotalLp;
        uint256 createtime;
        uint256 wol;    //当天产出wol
    }
    struct authInfo {
        address authAddress;
        uint types;
    }
    mapping(address=>Ap[]) public LpList;
    string public name; 
    uint8 public decimals; 
    string public symbol; 
    address public owner;         
    uint256 public DayWol; //每天产出多少WOL
    uint256 public BaseLp = 10000000000; //叠加
    uint256 public GrowthBl = 1000000000; //叠加比例
    uint256 public TotalLp = 0;
    day[] public DaysList;
    uint256 old_date;
    SwapPair SwapAddress; //LP代币
    Wol WolAddress; //Wol代币
    IsRegister RegisterAddress; //用于判断主合约是否注册
    address SransferAuthAddress = 0xCf8151E14533Bc8bc22E646A2d4B798fd2bba8AC;  //扣款地址
    address public AdminAddress;
    uint WithdrawalCharge = 20; //提现LP手续费
    authInfo[] authAddresss; //授权注册
    // constructor(uint256 _wol, uint256 _dayWol, SwapPair _SwapAddress) public {
    constructor(SwapPair _SwapAddress, Wol _WolAddress, IsRegister _RegisterAddress) {
    // constructor() {
        uint _dayWol = 10000000000;
        name = "LP";                                  
        decimals = 18;                         
        symbol = "LP";                       
        owner = msg.sender;
        DayWol = _dayWol;
        SwapAddress = _SwapAddress;
        WolAddress = _WolAddress;
        RegisterAddress = _RegisterAddress;
    }
    modifier checkOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier checkRegister() {
        require(RegisterAddress.isUserExists(msg.sender),'no register');
        _;
    }
    modifier checkAdmin() {
        require(msg.sender == AdminAddress);
        _;
    }
    modifier checkAuth() {
        uint8 isauth= 0;
        if(msg.sender == AdminAddress) {
            isauth = 1;
        } else {
            for(uint i = 0; i< authAddresss.length ; i++) {
                if(authAddresss[i].authAddress == msg.sender && authAddresss[i].types == 1) {
                    isauth = 1;
                    break;
                }        
            }
        }
        
        require(isauth == 1 ,'invalid operation');
        _;
    } 
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    //添加质押
    function AddLp(uint _value) checkRegister public returns(bool){
        (bool success, bytes memory returndata) = address(SwapAddress).call{ value: 0 }(abi.encodeWithSelector(SwapAddress.transferFrom.selector, msg.sender,address(this), _value));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        } 
        _value = _value.div(10000000000);
        balances[msg.sender] = balances[msg.sender].add(_value);
        LpList[msg.sender].push(Ap(_value,block.timestamp,block.timestamp,1));
        TotalLp = TotalLp.add(_value);
        emit BuyToSell(msg.sender,_value,1);    
        return true;
    }
    //拿出质押
    function OutLp() checkRegister public returns(bool){
        require(balances[msg.sender] > 0 ,"Lp lt 0");
        uint256 getLp = balances[msg.sender].mul(10000000000);
        uint256 gettotalLp = getLp;
        getLp = getLp.mul(WithdrawalCharge).div(100);
        (bool success, bytes memory returndata) = address(SwapAddress).call{ value: 0 }(abi.encodeWithSelector(SwapAddress.transfer.selector, msg.sender, getLp));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        }
        TotalLp = TotalLp.sub(balances[msg.sender]);
        ToReceive[msg.sender] = GetWol(msg.sender); //平台代币
 
        balances[msg.sender] = 0;
        for(uint i = 0; i < LpList[msg.sender].length ; i++) {
            if(LpList[msg.sender][i].isOut == 1){
                LpList[msg.sender][i].isOut = 0;
            }
        }
        emit BuyToSell(msg.sender,gettotalLp,2);   
        return true;
    }
    //获取可提现的wol
    function GetWol(address _address) public view returns(uint){
        return Compute(_address).add(ToReceive[_address]);
    }
   
    //计算得到的wol  typs = 1 计算wol  = 2 计算wol1
    function Compute(address _UserAddress) public view returns(uint256 WolNumber){
       
        for(uint i = 0; i < LpList[_UserAddress].length ; i++) {
            for(uint j=0; j < DaysList.length; j++) {   
                if(LpList[_UserAddress][i].isOut == 1 && LpList[_UserAddress][i].createtime < DaysList[j].createtime){
                    WolNumber = WolNumber.add(DaysList[j].wol.mul(LpList[_UserAddress][i].lp).div(DaysList[j].TotalLp));
                } 
            }  
        }
    }
    //领取wol
    function WithdrawWol() checkRegister public returns(bool){
        uint256 wol = GetWol(msg.sender);
        require(wol > 0 ,"wol lp 0");

        (bool success, bytes memory returndata) = address(WolAddress).call{ value: 0 }(abi.encodeWithSelector(WolAddress.transferFrom.selector, address(SransferAuthAddress), msg.sender, wol)); 
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        }
        uint timestamp = block.timestamp;
        for(uint i = 0; i < LpList[msg.sender].length ; i++) {
            LpList[msg.sender][i].createtime = timestamp;
        }
        ToReceive[msg.sender] = 0;
        emit Withdrawal(msg.sender,wol,1);    
        return true;
    }
    //触发每天收益
    function Touch(uint _date) checkOwner public{
        require(_date != old_date ,"time error");
        require(TotalLp > 0 ,"total lp 0");
        old_date = _date; 
        uint256 CalculateDayWol = Calculate();
        DaysList.push(day(TotalLp, block.timestamp, CalculateDayWol));
    }
    //计算每日发放的wol币的增长比例
    function Calculate() public view returns(uint256){
        uint256 bl = TotalLp.div(BaseLp);
        if(bl > 1){
            return DayWol.add(bl.sub(1).mul(GrowthBl));
        }else{
            return DayWol;
        }
 
    }
    //修改调用合约的代币
    function SetSwapAddress(SwapPair _address) checkAdmin public {
        SwapAddress = _address;
    }
    //修改调用主币合约
    function SetWolAddress(Wol _address) checkAdmin public {
        WolAddress = _address;
    }
    //修改调用注册合约
    function SetRegisterAddress(IsRegister _address) checkAdmin public {
        RegisterAddress = _address;
    }
    //修改授权扣款代币地址
    function SetSransferAuthAddress(address _address) checkAdmin public {
        SransferAuthAddress = _address;
    }
    //设置每天产出多少wol
    function SetDayWol(uint256 _value) checkAdmin public{
        DayWol = _value;
    }
    //设置取出LP代币手续费
    function SetWithdrawalCharge(uint256 _value) checkAdmin public{
        WithdrawalCharge = _value;
    }
    //修改每天产出的wol币的基数跟比例
    function SetGrowthBl(uint256 _value, uint256 _value1) checkAdmin public{
        BaseLp = _value;
        GrowthBl = _value1;
    }
    //LP代币提取
    function LpWithdraw(address _address, uint _value) checkAdmin public {
        (bool success, bytes memory returndata) = address(SwapAddress).call{ value: 0 }(abi.encodeWithSelector(SwapAddress.transfer.selector, _address, _value)); 
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        }
    }
    //设置操作者
    function SetAdminAddress(address _address) public{
        if(AdminAddress == 0x0000000000000000000000000000000000000000){
            require(msg.sender == owner);
        }else{
            require(msg.sender == AdminAddress);
        }
        AdminAddress = _address;
    }
}