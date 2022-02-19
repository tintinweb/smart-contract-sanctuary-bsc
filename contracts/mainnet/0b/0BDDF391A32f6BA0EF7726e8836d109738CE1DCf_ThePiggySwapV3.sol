/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

/**
  _____ _____ _____  _______     __   _____          _____  _____  ______ _   _ 
 |  __ \_   _/ ____|/ ____\ \   / /  / ____|   /\   |  __ \|  __ \|  ____| \ | |
 | |__) || || |  __| |  __ \ \_/ /  | |  __   /  \  | |__) | |  | | |__  |  \| |
 |  ___/ | || | |_ | | |_ | \   /   | | |_ | / /\ \ |  _  /| |  | |  __| | . ` |
 | |    _| || |__| | |__| |  | |    | |__| |/ ____ \| | \ \| |__| | |____| |\  |
 |_|   |_____\_____|\_____|  |_|     \_____/_/    \_\_|  \_\_____/|______|_| \_|

                                              


*/


pragma solidity ^0.4.26; // solhint-disable-line

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ThePiggySwapV3 {
    
    address piggies = 0xB93e4681d13095B0bC2E264F2CB22143d9fd0D53; 
    address tpg = 0x84E2bCd9320B19EB33cE84275bef6D464D811b4c; 
    uint256 public changekurs = 200;
    address public ceoAddress;
    address public ceoAddress1;

    constructor() public{
        ceoAddress=msg.sender;
        ceoAddress1=address(0xFaa39adA2F5612a88817161147A56D3b137acD40);
    }

     function WithdrawlPiggy(address to, uint256 amount) public {
        require(msg.sender == ceoAddress);     
        ERC20(piggies).transfer(to, amount);
    }

    function WithdrawlTPG(address to, uint256 amount) public {
        require(msg.sender == ceoAddress);      
        ERC20(tpg).transfer(to, amount);
    }
    
    function buyTPG(uint256 amount) public {
        uint256 balance = ERC20(tpg).balanceOf(address(this));
        uint256 tpg_amount =  SafeMath.div(SafeMath.mul(amount,changekurs),1e9);
        require(balance >= tpg_amount, "ERC20: Balance to low");

        ERC20(piggies).transferFrom(msg.sender, address(this), amount);
        ERC20(tpg).transfer(address(msg.sender), tpg_amount);      
    }

    function SET_KURS(uint256 value) external {
       require(msg.sender == ceoAddress);
        changekurs = value;
        
    }  


    //magic happens here
    function calculateTrade(uint256 amount) public view returns(uint256) {
        return SafeMath.div(amount,changekurs);
    }

    function supplyTPG() public view returns(uint256) {
        return ERC20(tpg).balanceOf(address(this));
    }
   
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
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