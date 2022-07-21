/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

pragma solidity ^0.6.0;

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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
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
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract USDTTOOL {
    event Make(address indexed account,uint8 id,uint8 t,uint256 total,uint256 usdAmount,uint256 artAmount);
    using SafeMath  for uint;
    address private _USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private _ART = 0x90345A10D2a08fe0390160501e535DD6A985eAC9;
    address private _ART_USDT = 0xc49ae9b73AACfE69A432A80f2073f2C43bc87097;
    address private _master = 0x5447411D0F091372C245E1B57a1c709538FF2517;

    constructor () public{
        
    }

    function make(uint8 id,uint256 amount) public returns(bool status){
        require(amount > 0 ,"error");
        uint256 usdART = amount.mul(6).div(10);
        uint256 bART = IERC20(_ART).balanceOf(_ART_USDT);
        uint256 bAUSDT = IERC20(_USDT).balanceOf(_ART_USDT);
        uint256 bAAmount = usdART.mul(bART).div(bAUSDT);
    
        uint256 usd = amount.mul(4).div(10);

        require(IERC20(_USDT).transferFrom(msg.sender,_master,usd),"USDT transfer error");
        require(IERC20(_ART).transferFrom(msg.sender,_master,bAAmount),"ART transfer error");
        emit Make(msg.sender,id,3,amount,usd,bAAmount);
        return true;
    }

    function getMaster() public view returns (address){
        return _master;
    }

    function setMaster(address addr) public {
        require(msg.sender == _master);
        _master = addr;
    }
}