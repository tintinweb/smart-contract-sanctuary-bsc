/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.4.24;


interface ERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract Token is ERC20 {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) private balance;
    
    mapping(address => mapping(address => uint256)) private allowed;

    constructor() public {
        name = "TAC";
        symbol = "TACTOKEN";
        decimals = 6;
        totalSupply = 10000 * 10 ** uint256(decimals);
        balance[msg.sender] = totalSupply;
    }

    function balanceOf(address account) external   view returns (uint256) {
        return balance[account];
    }

    function transfer(address to, uint amount) external   returns (bool) {
        require(to != address(0));
        require(balance[msg.sender] >= amount);
        require(balance[to] + amount >= balance[to]);

        balance[msg.sender] -= amount;
        balance[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) external  view returns (uint256) {
        return allowed[owner][spender];
    }

    function transferFrom(address from, address to,uint256 amount) external  returns (bool) {
        require(to != address(0));
        require(balance[from] >= amount);
        require(balance[to] + amount >= balance[to]);

        balance[from] -= amount;
        balance[to] += amount;

        allowed[from][msg.sender] -= amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        address owner = msg.sender;
        emit Approval(owner, spender, amount);
        return true;
    }


    string[] zhuanzhangs;
    string[] archives;

    function getZhuanzhang() public view returns(string memory) {
        string memory temp;
        for(uint i = 0; i < zhuanzhangs.length; i++){
            temp = strConcat(temp, ",");
            temp = strConcat(temp, zhuanzhangs[i]);
        }
        return temp;
    }

    function getArchive() public view returns(string memory) {
        string memory temp;
        for(uint i = 0; i < archives.length; i++){
            temp = strConcat(temp, ",");
            temp = strConcat(temp, archives[i]);
        }
        return temp;
    }

    
    function addZhuanzhang(string str) public {
      zhuanzhangs.push(str);
    }

    function addArchive(string str) public {
      archives.push(str);
    }


    function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory ba = bytes(_a);
        bytes memory bb = bytes(_b);
        string memory ret = new string(ba.length + bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint ia = 0; ia < ba.length; ia++)bret[k++] = ba[ia];
        for (uint ib = 0; ib < bb.length; ib++) bret[k++] = bb[ib];
        return string(ret);
   } 

}