/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

pragma solidity ^0.4.0;

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
    
}


interface ERC20 {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address owner,address spender, uint256 value) external returns (bool);
}

contract R_token{
    using SafeMath for uint256;
    ERC20 public A_token;//舊代幣
    ERC20 public B_token;//新代幣

    address public contract_owner;
    uint256 public decimals = 18;

    event chg_log(address _addr,uint256 _num);
    event a_token(address _addr);
    event b_token(address _addr);

    constructor (address _A, address _B)  public {
        contract_owner = msg.sender; 
        require(_A != address(0) && _B != address(0));
        _set_A_TOKEN(_A);
        _set_B_TOKEN(_B);
    }

    modifier onlyOwner() {
        require(msg.sender == contract_owner);
        _;
    }
    // 欲回收代幣
    function _set_A_TOKEN(address _tokenAddr) public onlyOwner{
        require(_tokenAddr != 0);
        A_token = ERC20(_tokenAddr);

        emit a_token(_tokenAddr);
    }
    // 轉換新代幣
    function _set_B_TOKEN(address _tokenAddr) public onlyOwner{
        require(_tokenAddr != 0);
        B_token = ERC20(_tokenAddr);

        emit b_token(_tokenAddr);
    }

    function chg_Token(uint256 _num) public returns (bool) {
        uint256 A_balance = A_token.balanceOf(msg.sender);
        uint256 allowance = A_token.allowance(msg.sender, address(this));
        uint256 B_balance = B_token.balanceOf(address(this));
        require(A_balance >= _num,"Check your token balance");
        require(B_balance >= _num,"Not enough available balance.(B_Token)");
        if(allowance < _num)
        {
            bool r = A_token.approve(msg.sender,address(this), _num);
            require(r,"Check the A token allowance");
        }

        A_token.transferFrom(msg.sender, address(this), _num);//扣款
        B_token.transfer(msg.sender, _num);//新代幣給user

        emit chg_log(msg.sender, _num);

        return true;
    }
}