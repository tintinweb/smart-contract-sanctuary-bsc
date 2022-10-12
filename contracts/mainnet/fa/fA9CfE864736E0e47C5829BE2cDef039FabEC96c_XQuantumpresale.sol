/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract XQuantumpresale {

    //Mainnet
    //   IERC20 public usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    //   IERC20 public busd = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);

    //Testnet
     IERC20 public  usdt ;
     IERC20 public  busd ;
    
    IERC20 public token;

    bool public paused; 

    address public owner;

    uint256 public perDollarPrice;  //in decimals

    uint256 public UsdtoBnb; //one usd to bnb

    mapping (address => mapping (address => bool)) public referral;

    modifier onlyOwner {
        require(owner == msg.sender,"Caller must be Ownable!!");
        _;
    }

    constructor(uint256 _price,address _presaleToken , uint _perUsdtoBnb , address _usdt , address _busd){
        owner = msg.sender;
        perDollarPrice = _price;
        token = IERC20(_presaleToken);
        UsdtoBnb = _perUsdtoBnb;
        usdt = IERC20(_usdt);
        busd = IERC20(_busd);
    }

    //minimum deposit 20$
    //5% referral directly go to user account
    //$1 is 54,868

    function ikeBalance(address _user) public view returns(uint){
        return token.balanceOf(_user);
    }

    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function remainingToken() public view returns(uint){
        return token.balanceOf(address(this));
    }

    //per dollar price in decimals
    function setTokenPrice(uint _price) public onlyOwner{
        perDollarPrice = _price;
    }

    //per dollar price in decimals of bnb
    function setBnbPrice(uint _price) public onlyOwner{
        UsdtoBnb = _price;
    }

    function setPause(bool _value) public onlyOwner{
        paused = _value;
    }

    function setToken(address _token) public onlyOwner{
        token = IERC20(_token);
    }

    function setBusd(address _token) public onlyOwner{
        busd = IERC20(_token);
    }

    function setUsdt(address _token) public onlyOwner{
        usdt = IERC20(_token);
    }

    //pid for selection of token USDT -> 1 or BUSD -> 2
    function buyfromToken(uint _pid,address ref,uint amount) public {
        
        require(!paused,"Presale is Paused!!");
        uint check = 1;   

        if(ref == address(0) || ref == msg.sender || referral[msg.sender][ref]){}
        else{
            referral[msg.sender][ref] = true;
            check = 2;
        }

        if(_pid == 1){
            uint256 _amount =  usdt.allowance(msg.sender , address(this)) ;
           
            if(_amount > 100){
                if(check == 2){
                uint per5 = ( _amount * 5 ) / 100;
                uint per95 = ( _amount * 95 ) / 100;
                // usdt.transfer(ref,per5);
                // usdt.transfer(owner,per95);
                usdt.transferFrom(msg.sender,ref,per5);
                usdt.transferFrom(msg.sender,owner,per95);
                }
                else{
                    usdt.transferFrom(msg.sender,owner,_amount);
                }
            }
          


            uint temp = _amount;
         //  uint multiplier = temp * 10 **(token.decimals()) / 50000 ;
           uint multiplier = temp * 10 **(token.decimals()) / (perDollarPrice *10**12);

            token.transfer(msg.sender,multiplier);

        }
        else if(_pid == 2){
            uint256 _amount =  busd.allowance(msg.sender , address(this)) ;
           // busd.transferFrom(msg.sender,address(this),_amount);
            
            if(check == 2){
                uint per5 = ( _amount * 5 ) / 100;
                uint per95 = ( _amount * 95 ) / 100;
                busd.transferFrom(msg.sender,ref,per5);
                busd.transferFrom(msg.sender,owner,per95);
            //  busd.transfer(ref,per5);
            //  busd.transfer(owner,per95);
            }
            else{
              busd.transferFrom(msg.sender,owner,_amount);
            }

            uint temp = _amount;
            uint multiplier = temp * 10 **(token.decimals()) / (perDollarPrice *10**12); //(token.decimals() - usdt.decimals());
            token.transfer(msg.sender,multiplier);
        }
        else {
            revert("Wrong Selection!!");
        }


    }


    function buyFromNative(address ref) public payable {

        require(!paused,"Presale is Paused!!");

        uint check = 1;   

        if(ref == address(0) || ref == msg.sender || referral[msg.sender][ref]){}
        else{
            referral[msg.sender][ref] = true;
            check = 2;
        }

        uint value = msg.value   ;//* 10 **token.decimals() ;

        uint equaltousd = (value *10**2)*2 / UsdtoBnb;

        uint multiplier = (perDollarPrice *10**12)  * equaltousd;

        token.transfer(msg.sender,multiplier);

        if(check == 2){
            uint per5 = ( value * 5 ) / 100;
            uint per95 = ( value * 95 ) / 100;
            payable(ref).transfer(per5);
            payable(owner).transfer(per95);
        }
        else{
            payable(owner).transfer(value);
        }

    }

    function RescueFunds() public onlyOwner {
        payable(msg.sender).transfer( address(this).balance );
    }

    function RescueTokens(IERC20 _add,uint _amount,address _recipient) public onlyOwner{
        _add.transfer(_recipient,_amount);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

}