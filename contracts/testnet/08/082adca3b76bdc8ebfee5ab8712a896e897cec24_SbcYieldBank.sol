/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// File: contracts/_test.sol


pragma solidity 0.8.13;


interface IBEP20  {
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


contract SbcYieldBank {
    
    // call it SbcYieldBank
    string public name = "SbcBank";
    
    // create 2 state variables
    address public BNB;
    address public sbcToken;


    address[] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;


    // in constructor pass in the address for BNB token and your custom bank token
    // that will be used to pay interest
    constructor() public {
        BNB = 0xB8c77482e45F1F44dE1745F52C74426C631bDD52;
        sbcToken = 0x68D2C77348b4Dc8b86d37d74e66558E31ef818B7;
    }


    // allow user to stake BNB tokens in contract
    
    function stakeTokens(uint _amount) public {

        // Trasnfer BNB tokens to contract for staking
        IBEP20 (BNB).transferFrom(msg.sender, address(this), _amount);

        // Update the staking balance in map
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // Add user to stakers array if they haven't staked already
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status to track
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

        // allow user to unstake total balance and withdraw BNB from the contract
    
     function unstakeTokens() public {

    	// get the users staking balance in BNB
    	uint balance = stakingBalance[msg.sender];
    
        // reqire the amount staked needs to be greater then 0
        require(balance > 0, "staking balance can not be 0");
    
        // transfer BNB tokens out of this contract to the msg.sender
        IBEP20 (BNB).transfer(msg.sender, balance);
    
        // reset staking balance map to 0
        stakingBalance[msg.sender] = 0;
    
        // update the staking status
        isStaking[msg.sender] = false;

} 


    // Issue bank tokens as a reward for staking
    
    function issueInterestToken() public {
        for (uint i=0; i<stakers.length; i++) {
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            
    // if there is a balance transfer the SAME amount of bank tokens to the account that is staking as a reward
            
            if(balance >0 ) {
                IBEP20 (sbcToken).transfer(recipient, balance);
                
            }
            
        }
        
    }
}