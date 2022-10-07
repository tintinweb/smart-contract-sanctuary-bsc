/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMathInt {
    
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

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
        require(b != 0);
        return a % b;
    }

}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Swap {

    IBEP20 public usdt ;

    IBEP20 public token;
    address public owner;

    uint256 public perDollarPrice;  //in decimals
    uint256 public startime ;
    uint256 public endtime;

    uint256 public minDeposit;  //2$
    uint256 public maxDeposit;

    mapping (address => uint256) public record;

    address[] public indexRecord;

    modifier onlyOwner {
        require(owner == msg.sender,"Caller must be Ownable!!");
        _;
    }

    constructor(address _usdt, address _presaleToken, uint buyprice  ,uint _startime, uint _endtime,uint _minbuy,uint _maxbuy ){
        owner = msg.sender;
        perDollarPrice = buyprice;
        usdt = IBEP20(_usdt);
        token = IBEP20(_presaleToken);
        startime = _startime;
        endtime =_endtime;
        minDeposit = _minbuy;
        maxDeposit = _maxbuy ;
    }

    function Balance(address _user) public view returns(uint){
        return token.balanceOf(_user);
    }

    function remainingToken() public view returns(uint){
        return token.balanceOf(address(this));
    }
     function changendtime(uint _endtime) external onlyOwner{
         endtime =_endtime;

    }
    function changeprice(uint buyprice) external onlyOwner{
        perDollarPrice  = buyprice;

    }


function buy(uint amount) public {
        require(block.timestamp>=startime,"presale not started");
        require(block.timestamp<= endtime,"presale has closed");
        require(amount >= minDeposit,"You cannot buy less then min amount");
        require(amount <= maxDeposit,"You cannot buy max then max amount");

            usdt.transferFrom(msg.sender,address(this),amount);
  
          //   usdt.transfer(owner,amount);


            uint temp = amount / 10 ** 18;
            uint multiplier = perDollarPrice  * temp;
            token.transfer(msg.sender,multiplier);
            record[msg.sender] += multiplier;

        }

     function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner{
        IBEP20 tokenContract = IBEP20(_tokenContract);
      
        tokenContract.transfer(msg.sender, _amount);
    }
    
    function getBalance(address _user) public view returns (uint){
        return record[_user];
    }


}