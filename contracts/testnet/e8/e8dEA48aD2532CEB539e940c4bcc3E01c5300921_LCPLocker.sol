/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// ██╗      ██████╗██████╗     ██╗      ██████╗  ██████╗██╗  ██╗
// ██║     ██╔════╝██╔══██╗    ██║     ██╔═══██╗██╔════╝██║ ██╔╝
// ██║     ██║     ██████╔╝    ██║     ██║   ██║██║     █████╔╝ 
// ██║     ██║     ██╔═══╝     ██║     ██║   ██║██║     ██╔═██╗ 
// ███████╗╚██████╗██║         ███████╗╚██████╔╝╚██████╗██║  ██╗
// ╚══════╝ ╚═════╝╚═╝         ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝
                                                                                                                                       
// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// All copyrights, trademarks and patents belongs to Live Crypto Party livecryptoparty.com

interface IBEP20 {
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

contract LCPLocker {
    IBEP20 public token;
    using SafeMath for uint256;

    address payable public owner;
    uint256 public TotalTokenLocked; 
    mapping(address => uint256) public lockTime; 
    struct LockInfo{
        uint256 amount;
        uint256 unlockTime;
        uint256 withdrawTime;
    }
    mapping(address => LockInfo) public lockinfo;
    

    modifier onlyOwner() {
        require(msg.sender == owner, "BEP20: Not an owner");
        _;
    }

    event lockToken(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );
    event unLockToken(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );

    constructor(address payable _owner, address _token) {
        owner = _owner;
        token = IBEP20(_token);
    }

    // to lock token => for web3 use
    function lockTokens(
        address[] memory addresses,
        uint256[] memory amount,
        uint256[] memory _lockTime
    ) public {
        require(addresses.length == amount.length && addresses.length == _lockTime.length);
        uint256 totBal;
        for (uint256 i; i < addresses.length; i++) {
            totBal += amount[i];
            lockinfo[addresses[i]].amount = amount[i];
            lockinfo[addresses[i]].unlockTime = _lockTime[i];

        }
        token.transferFrom(msg.sender, address(this), totBal);
        emit lockToken(msg.sender, address(this), totBal);
    } 
    // to unlock token
    function UnLockTokens() public {
        require(
            block.timestamp >= lockinfo[msg.sender].unlockTime,
            "Unlock time not reached"
        );
        uint256 tokens = lockinfo[msg.sender].amount;
        token.transfer(msg.sender, tokens);

        lockinfo[msg.sender].unlockTime= block.timestamp;
        lockinfo[msg.sender].amount = 0; 

        emit unLockToken(address(this), msg.sender, tokens);
    }

   function UpdateTime(
        address[] memory addresses, 
        uint256[] memory _lockTime
    ) public {
        require(addresses.length == _lockTime.length); 

        for (uint256 i; i < addresses.length; i++) {   
            lockinfo[addresses[i]].unlockTime = _lockTime[i];

        } 
    }
    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function setToken(address newtoken) public onlyOwner {
        token = IBEP20(newtoken);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}