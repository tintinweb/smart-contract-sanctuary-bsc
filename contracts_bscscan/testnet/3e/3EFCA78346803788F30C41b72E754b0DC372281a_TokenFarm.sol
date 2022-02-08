/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

pragma solidity ^0.5.0;
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



contract TokenFarm {
    string public name = "DApp Token Farm";
    address public bankToken;
    address public busd;
    address public owner;

    address[] public stakers; // list of all investor that have staked
    address[] public stakersBNB; // list of all investor that have staked
    mapping(address => uint) public stakingBalance;
    mapping(address => uint) public stakingBalanceBNB;
    mapping(address => bool) public hasStaked; // long term staking status
    mapping(address => bool) public isStaking; // current staking status
    mapping(address => bool) public hasStakedBNB; // long term staking status
    mapping(address => bool) public isStakingBNB; // current staking status


    constructor() public {
        bankToken = address(0xc1312fe19e6666589760a4670Fd55B606EdE3AEd);
        busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        owner = msg.sender;
    }

    // 1. Stakes Tokens(Deposit)
    function stakeTokens(uint _amount) public {
        // Require amount greater than 0
        require(_amount > 0,"amount cannot be 0");

        // Transfer Mock Dai token to this contract for staking
        IERC20(busd).transferFrom(msg.sender, address(this), _amount);

        // Update staking balance
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Add user to stakers array *only* if they haven't staked already
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }
     function depositBNB(uint256) public payable returns(uint256){

         stakingBalanceBNB[msg.sender] += msg.value; // returns 0 if key is not in mapping
         return stakingBalanceBNB[msg.sender];
         // Update staking balance
        stakingBalanceBNB[msg.sender] = stakingBalanceBNB[msg.sender] + msg.value;

        // Add user to stakers array *only* if they haven't staked already
        if(!hasStakedBNB[msg.sender]) {
            stakersBNB.push(msg.sender);
        }

        // Update staking status
        isStakingBNB[msg.sender] = true;
        hasStakedBNB[msg.sender] = true;
    
     }


    // 2. Issuing Tokens TODO: Add feature to issue token every 10 blocks
    function issueTokens() public {

        require(msg.sender == owner, "caller must be the owner");

        // Iusse tokens to all stackers
        for (uint i=0; i < stakersBNB.length; i++) {
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];

            if (balance > 0) {
                IERC20(bankToken).transfer(recipient, balance);
            }
        }
    }

    // 3. Unstaking Tokens(Withdraw)
    function unstakeTokens() public {
        // Fetch staking balance of investor
        uint balance = stakingBalance[msg.sender];

        // Require amount is greater than 0
        require(balance > 0,"stake balance cannot be 0");

        // Transfer Mock Dai Token to this contract for staking
        IERC20(busd).transfer(msg.sender, balance);

        // Reset staking balance
        stakingBalance[msg.sender] = 0;

        // Update staking status
        isStaking[msg.sender] = false;
    }
     function withdrawBNB() public returns(uint256) {
        uint256 balance = stakingBalanceBNB[msg.sender];
        require(balance > 0, 'Account is empty');
     }
    // 4. Unstaking Tokens by amount(Withdraw)
    function unstakeTokensByAmount(uint _amount) public {
        // Fetch staking balance of investor
        uint balance = stakingBalance[msg.sender];

        // Require current staking balance is greater than 0
        require(balance > 0, "stake balance cannot be 0");

        uint finalBalance = balance - _amount;

        require(finalBalance >= 0, "investor amount to unstake can not be greater than current staking balance");

        // Transfer Mock Dai Token to this contract for staking
        IERC20(busd).transfer(msg.sender, _amount);

        // Reset staking balance
        stakingBalance[msg.sender] = finalBalance;

        // Update staking status
        if (finalBalance == 0 ) {
            isStaking[msg.sender] = false;
        } else {
            isStaking[msg.sender] = true;
        }
    }

}