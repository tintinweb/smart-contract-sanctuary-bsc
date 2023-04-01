/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DEX {
 using SafeMath for uint256;
    event Bought(uint amount);
    //event Sold(uint amount);
 // 1 wei Basecoin to 100 wei token
    uint public Rate=100;
    uint public RateUsdt=100;
    


    address public  ContractOwner;
    IERC20 public token;
    IERC20 public usdt;

    constructor(address TokenAddress,address _usdt ,uint _rate, uint _rateusdt) { 
           token = IERC20(TokenAddress);
           usdt = IERC20(_usdt);
           ContractOwner=msg.sender;
           Rate=_rate;
           RateUsdt=_rateusdt;
    }


     modifier onlyOwner() {
        require(msg.sender == ContractOwner, "sender is not the owner");
        _;
    }
    function change_token(IERC20 newtoken) public onlyOwner{
        token=newtoken;
    }


    function EtherToToken() payable public {
        uint UserSendEther = msg.value;
        uint UserGetToken=UserSendEther.mul(Rate);
        uint dexBalance = token.balanceOf(address(this));
        require(UserSendEther > 0, "You need to send some ether");
        require(UserGetToken <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, UserGetToken);
        emit Bought(UserGetToken);
    }
      function UsdtToToken(uint256 amount)  public {
        uint UserSendUsdt = amount;
        uint UserGetToken=UserSendUsdt.mul(RateUsdt);
        uint dexBalance = token.balanceOf(address(this));
        require(UserSendUsdt > 0, "You need to send some ether");
        require(UserGetToken <= dexBalance, "Not enough tokens in the reserve");
        usdt.transferFrom(msg.sender,address(this), amount);
        token.transfer(msg.sender, UserGetToken);
        emit Bought(UserGetToken);
    }


        function GetAmountsOut(uint UserSendEther)  view public returns (uint){
            return  UserSendEther * Rate;
        }
         function GetAmountsOutUsdt(uint UserSendUsdt)  view public returns (uint){
            return  UserSendUsdt * RateUsdt;
        }

        function SetRate(uint NewRate)    public onlyOwner {
             Rate= NewRate;
        }
         function SetRateUsdtToToken(uint NewRate)    public onlyOwner {
             RateUsdt= NewRate;
        }

       function TransferToken(address ToAddress,uint Amount)    public onlyOwner {
              token.transfer(ToAddress, Amount);
        }


       function TransferETH( address payable _receiver,uint256 _Amount) public onlyOwner  {
        (_receiver).transfer(_Amount);
       }

}