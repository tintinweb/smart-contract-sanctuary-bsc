/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

interface IERC20 {

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);

}
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



contract DefiBank {
    using SafeMath for uint256;

    // call it DefiBank
    string public name = "DefiBank";

    //Owner of the bank
    address private owner;

    // create 2 state variables
    address public busd;      // The token you will accept
    address public bankToken; // The token that represents your bank that will be used to pay interest
    uint256 public interestRate = 120;
    

    // create 1 array to add all your clients
    address[] public stakers;

    // create a 3 maps 
    mapping(address => uint) public stakingBalance; //Clients balance
    mapping(address => bool) public hasStaked; // Find out if this customer has created an account
    mapping(address => bool) public isStaking; // Find out if this customer is using their account
    mapping(address => uint256) private accounts;

    // In constructor pass in the address for USDC token,  set your custom bank token and the owner will be who will deploy the contract
    constructor() {
        busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        bankToken = address(0xc1312fe19e6666589760a4670Fd55B606EdE3AEd);
        owner = msg.sender;
    }

     // Change the ownership 
     function changeOwner(address newOwner) public {
    // require the permission of the current owner
        require(owner == msg.sender, "Your are not the current owner");
        owner = newOwner;
    }

    // allow user to deposit usdc tokens in your contract

    function depositBUSD(uint _amount) public {

        // Transfer usdc tokens to contract
        IERC20(busd).transferFrom(msg.sender, address(this), _amount);

        // Update the account balance in map
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Add user to stakers array if they haven't staked already
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status to track
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

     // allow user to withdraw total balance and withdraw USDC from the contract


     function depositBNB() public payable returns(uint256){

         stakingBalance[msg.sender] += msg.value; // returns 0 if key is not in mapping
         return stakingBalance[msg.sender];
     }

     function withdrawBUSD() public {

        // get the users staking balance in usdc
        uint balance = stakingBalance[msg.sender];

        // require the amount staked needs to be greater then 0
        require(balance > 0, "staking balance can not be 0");

        // transfer usdc tokens out of this contract to the msg.sender (client)
        IERC20(busd).transfer(msg.sender, balance);

        // reset staking balance map to 0
        stakingBalance[msg.sender] = 0;

        // update the staking status
        isStaking[msg.sender] = false;
    } 

    function withdrawBNB() public returns(uint256) {
        uint256 balance = stakingBalance[msg.sender];
        require(balance > 0, 'Account is empty');

        //Deduct from bank
        stakingBalance[msg.sender] -= balance;
        address payable receiver = payable(msg.sender);
        receiver.transfer(balance);
        return stakingBalance[msg.sender];
    }
    function setInterestRate(uint256 interestRate) private pure {
        interestRate = interestRate;
    }
    function calculateInterestRate(uint256 _amount) private view returns (uint256) {
        return _amount.mul(interestRate).div(
            10**3
        );
    }
    
}