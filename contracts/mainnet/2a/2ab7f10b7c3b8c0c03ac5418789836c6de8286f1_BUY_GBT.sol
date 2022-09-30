/**
 *Submitted for verification at BscScan.com on 2022-09-30
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
    
    function sqrt(uint x) internal pure returns(uint) {
        uint z = (x + 1 ) / 2;
        uint y = x;
        while(z < y){
          y = z;
          z = ( x / z + z ) / 2;
        }
        return y;
     }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

interface ERC20 {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
}

contract BUY_GBT {
    using SafeMath for uint256;
    using Address for address;

    ERC20 public BUSD;
    ERC20 public GBT;

    address public contract_owner;
    uint256 public usdt_p = 1;// 1USDT = 400GBT
    uint256 public gbt_p = 400;// 1USDT = 400GBT

    event owner_withdraw(address to_addr, uint256 _value, string _type);
    event buy_list(uint256 usdt_p, uint256 gbt_p, uint256 usdt_num, uint256 gbt_num);

    constructor() public {
        contract_owner = msg.sender; 
        BUSD = ERC20(0x55d398326f99059fF775485246999027B3197955);
        GBT = ERC20(0x4dF24862a18A9CB329Bcd6d1c42d7c0E5f405997); 
    }

    modifier onlyOwner() {
        require(msg.sender == contract_owner);
        _;
    }

    function buy_GBT(uint256 usdt_num) public returns (bool) {
        uint256 BUSD_B = BUSD.balanceOf(msg.sender);
        uint256 allowance = BUSD.allowance(msg.sender, address(this));
        require(allowance >= usdt_num, "Check the BUSD allowance.");
        require(BUSD_B >= usdt_num,"Check your BUSD balance.");

        BUSD.transferFrom(msg.sender, address(this), usdt_num);

        uint256 gbt_num = usdt_num.mul(gbt_p) / usdt_p;

        uint256 GBT_B = GBT.balanceOf(address(this));
        require(GBT_B >= gbt_num,"Check the GBT balance.");
        
        GBT.transfer(msg.sender, gbt_num);

        emit buy_list(usdt_p, gbt_p, usdt_num, gbt_num);

        return true; 
    }

    function withdraw_usdt(address w_addr) public onlyOwner{
        require(w_addr!=address(0),"Address Error.");
        address contract_addr = address(this);
        uint256 contract_balance = BUSD.balanceOf(contract_addr);
        BUSD.transfer(w_addr, contract_balance);
        
        emit owner_withdraw(w_addr, contract_balance, "BUSD");
    }

    function withdraw_gbt(address w_addr) public onlyOwner{
        require(w_addr!=address(0),"Address Error.");
        address contract_addr = address(this);
        uint256 contract_balance = GBT.balanceOf(contract_addr);
        GBT.transfer(w_addr, contract_balance);
        
        emit owner_withdraw(w_addr, contract_balance, "GBT");
    }

    function set_usdt_gbt(uint256 _usdt_p, uint256 _gbt_p) public onlyOwner{
        require(_usdt_p > 0 && _gbt_p > 0);
        usdt_p = _usdt_p;
        gbt_p = _gbt_p;
    }

}