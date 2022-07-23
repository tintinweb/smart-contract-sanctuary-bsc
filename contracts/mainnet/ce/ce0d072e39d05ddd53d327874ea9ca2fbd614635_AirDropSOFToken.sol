/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

/**
  ____     ___    _____                _      ___   ____    ____    ____     ___    ____  
 / ___|   / _ \  |  ___|              / \    |_ _| |  _ \  |  _ \  |  _ \   / _ \  |  _ \ 
 \___ \  | | | | | |_     _____      / _ \    | |  | |_) | | | | | | |_) | | | | | | |_) |
  ___) | | |_| | |  _|   |_____|    / ___ \   | |  |  _ <  | |_| | |  _ <  | |_| | |  __/ 
 |____/   \___/  |_|               /_/   \_\ |___| |_| \_\ |____/  |_| \_\  \___/  |_|    
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
 **/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface SOFToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract AirDropSOFToken {
    using SafeMath for uint256;

    SOFToken public token_SOF;

    address erctoken = 0x258A1e13501Da18eA07950253e1adA4c48A05b74; /** SOF token **/
    uint256 transactionCount;
    uint256 public AMOUNT_TO_CLAIM = 10; 
    bool public contractStarted = true;
    address public owner;

    event TransferBlock( string email, uint256 timestamp, string link);
     struct TransferStruct {
        string email;
        uint256 timestamp;
        string link;
    }
    TransferStruct[] transactions;

    struct User {
        uint256 countClaim;
        uint256 lastClaimTime;
    }

    mapping(address => User) public users;

    constructor() {
        owner = msg.sender;
        token_SOF = SOFToken(erctoken);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    function Claim( string memory email, string memory link) public{
        require(contractStarted);
        User storage user = users[msg.sender];
       
        if (user.countClaim == 0) {
            token_SOF.transfer(msg.sender, AMOUNT_TO_CLAIM);
            transactionCount = transactionCount.add(1);
            user.countClaim = user.countClaim.add(1);
            user.lastClaimTime = block.timestamp;
            transactions.push(TransferStruct( email, block.timestamp, link));
           emit TransferBlock( email, block.timestamp, link);
        }
         user.countClaim =  user.countClaim.add(1);
    }

    function getUserInfo(address _adr) public view returns( uint256 _lastClaimTime,uint256 _countClaim) {
         _countClaim = users[_adr].countClaim;
         _lastClaimTime = users[_adr].lastClaimTime;
	}

    function getBalance() public view returns (uint256) {
        return token_SOF.balanceOf(address(this));
	}

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function PRC_AMOUNT_TO_CLAIM(uint256 value) external {
        require(msg.sender == owner, "Team use only.");
        require(value >= 0 && value <= 200000000000000000000000);
        AMOUNT_TO_CLAIM = value;
    }
}