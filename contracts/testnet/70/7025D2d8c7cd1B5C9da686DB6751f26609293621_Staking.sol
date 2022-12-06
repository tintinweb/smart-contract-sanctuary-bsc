/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
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
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)external returns (bool);
  function transferFrom(address from, address to, uint256 value)external returns (bool);
  function burn(uint256 value)external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}
contract Staking {
using SafeMath for uint256;


struct Deposit {
	Details[] _detail;	
    uint256 total_stake;
	}

struct Details {
    uint256 amount;
    uint256 roi;
	uint256 start;
    uint256 end;
}

      struct User{
         mapping(IBEP20 => Deposit) Deposits;
             }

     struct Data{
      uint256 time;
        uint8 percent;
        IBEP20 _tokenaddress;
     }

       struct planinfo {
		Data[] _data;
	}
    
 address private owner;

  modifier onlyAdmin() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

      mapping (address => User) internal users;
        mapping (IBEP20 => planinfo) internal INFO;

     event NewDeposit(address indexed user, uint256 amount);

    function invest(uint256 amount ,IBEP20 _token) external {
        // require(INFO[_token],"Invalid token");
        require(_token.balanceOf(msg.sender)>=amount,"Low Balance");
        require(_token.allowance(msg.sender,address(this))>=amount,"Invalid allowance amount");
        _token.transferFrom(msg.sender,address(this),amount);
        uint8 roi = 10;
        users[msg.sender].Deposits[_token]._detail.push(Details(amount,roi,block.timestamp,block.timestamp));
        emit NewDeposit(msg.sender,amount);
    }

   function totalstake(address user,IBEP20 _TKN) public view returns (uint256) {
        //return (users[user].Deposits[_TKN].amount);
    }

  function withdrawToken(IBEP20 _token , uint256 amount) external onlyAdmin {
        _token.transfer(owner,amount);
    }
    
    
}