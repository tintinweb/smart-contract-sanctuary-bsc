/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed
    library SafeMath {//konwnsec//IERC20 接口
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
// assert(b > 0); // Solidity automatically throws when dividing by 0
            uint256 c = a / b;
// assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c; 
        }
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b; 
        }

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c; 
        }
    }

    interface Erc20Token {//konwnsec//ERC20 接口
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }
 
// 基类合约
    contract Base {
        using SafeMath for uint;
        Erc20Token constant internal USDT  = Erc20Token(0x55d398326f99059fF775485246999027B3197955); 
        Erc20Token constant internal EPT   = Erc20Token(0xCDAbD94A40e25E80Cd4CE1D73C8f93e368BD1069); 
        Erc20Token constant internal ARR   = Erc20Token(0xb37b866871882124C3E7E301d936C29089c43987); 
 


        uint256 EPTRate  = 1000;
        uint256 ARRRate  = 1000;
        uint256 ATTRate  = 1000;

 
        uint256 authenticationO   = 0;
        uint256 authenticationP   = 0;
        uint256 authenticationC   = 1;
        uint256 dayMax   = 10000000000000000000000000000000000000;
        uint256 dayAll   = 0;
        uint256 times   = 0;

        address  public  _owner;
        address  public Operator;
        bool  public Open;


    function setEPTRate (uint256 newRate,uint256 tokenType) public onlyOperator() onlyOpen()  {
        if(tokenType == 0){
            EPTRate =newRate;
        }
        else  if(tokenType == 1){
            ARRRate =newRate;
        }
        else if(tokenType == 2){
            ATTRate =newRate;
        }
    }

    modifier onlyOpen() {
        require(Open, "_owner Open"); _;
    }

    modifier onlyauthentication() {
        require(authenticationC == authenticationO);
        require(authenticationC == authenticationP);_;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied"); _;
    }

    modifier onlyOperator() {
        require(msg.sender == Operator, "Permission denied"); _;
    }
    modifier isZeroAddr(address addr) {
        require(addr != address(0), "Cannot b'e a zero address"); _; 
    }

    function transferOwnership(address newOwner) public onlyOwner onlyauthentication {
        require(newOwner != address(0));
         authenticationC = authenticationC.add(1);
        _owner = newOwner;
    }

    function setDayMax(uint256 Quantity) public onlyOwner onlyauthentication {
        authenticationC = authenticationC.add(1);
        dayMax = Quantity;
    }


    

    function setAuthenticationP() public onlyOperator {
        authenticationP = authenticationC;
    }

    function setAuthenticationO() public onlyOwner {
        authenticationO = authenticationC;
    }


     function setOpenOrClose() public onlyOwner {
        Open = !Open;
    }


    function transferOperatorship(address newOperator) public onlyOperator onlyauthentication {
        require(newOperator != address(0));
        authenticationC = authenticationC.add(1);
        Operator = newOperator;
    }

 

  
    receive() external payable {}  
}

contract jr is Base {
 
 
    constructor()
    public {
        _owner = msg.sender; 
        Operator = msg.sender; 
    }

     function Recharge(uint256 Quantity,uint256 tokenType) public   {
          if(tokenType == 0){
            EPT.transferFrom(address(msg.sender), address(this), Quantity);
         }
        else if(tokenType == 1){
            ARR.transferFrom(address(msg.sender), address(this), Quantity);
         }
        else  if(tokenType == 2){
            USDT.transferFrom(address(msg.sender), address(this), Quantity);
         }
    }

     function withdrawal(address Addrs,uint256 Quantity,uint256 tokenType) public onlyOperator() onlyOpen(){
        if(times<=block.timestamp){
            times = block.timestamp.add(86400);
            dayAll = 0;
        }
        dayAll = dayAll.add(Quantity);
        require(dayAll <= dayMax, "dayMax");
          if(tokenType == 0){
            EPT.transfer(Addrs, Quantity);
         }
        else if(tokenType == 1){
            ARR.transfer(Addrs, Quantity);
         }
        else     if(tokenType == 2){
            USDT.transfer(Addrs, Quantity);
         }
    }

    function withdrawalbatch(address[] calldata  Addrs,uint256[] calldata Quantity,uint256 tokenType) public onlyOperator() onlyOpen(){
        if(times<=block.timestamp){
            times = block.timestamp.add(86400);
            dayAll = 0;
        }
        for (uint256 i = 0; i < Addrs.length; i++) {
            address add = Addrs[i];
            uint256 Q = Quantity[i];
            if (add != address(0))
            {
                dayAll = dayAll.add(Q);
                require(dayAll <= dayMax, "dayMax");
                if(tokenType == 0){
                    EPT.transfer(add, Q);
                }
                else if(tokenType == 1){
                    ARR.transfer(add, Q);
                }
                else if(tokenType == 2){
                    USDT.transfer(add, Q);
                }
            }
        }
    }
   
    function extract(uint256 Quantity,uint256 tokenType)public  {
        if(tokenType == 0){
            EPT.transferFrom(address(msg.sender), address(1), Quantity.mul(EPTRate).div(1000));
         }
        else  if(tokenType == 1){
            EPT.transferFrom(address(msg.sender), address(1), Quantity.mul(ARRRate).div(1000));
         }
        else if(tokenType == 2){
            EPT.transferFrom(address(msg.sender), address(1), Quantity.mul(ATTRate).div(1000));
         }

    }
 
}