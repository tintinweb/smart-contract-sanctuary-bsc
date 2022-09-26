/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

pragma solidity ^0.6.12;


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


contract MainStakev2 {
    
    // call it MainStrain Stake
    string public name = "MainStrain Stake v2";
    
    // create 2 state variables
    address public usdc;
    address public StakeToken;
    address public taxAccount;

    // in constructor pass in the address for USDC token and your custom bank token
    // that will be used to pay interest
    constructor() public {
        usdc = 0x64544969ed7EBf5f083679233325356EbE738930;
        StakeToken = 0xC3039D0078C96fFb1372D0aEF387Ae8611bDa961;// INPUT-YOUR-TOKEN-ADDRESS-HERE;
        taxAccount = 0xe187624b84E13Eb3eEf07BEb346E76CF499aa832;// INPUT-YOUR-ADDRESS-HERE;

    }


    // allow user to stake usdc tokens in contract    
    function stakeTokens(uint _amount) public {
        // Transfer usdc tokens to contract for staking
        require( IERC20(usdc).transferFrom(msg.sender, address(this), _amount) );
        addShares(msg.sender,_amount);
    }

    // allow user to unstake total balance and withdraw USDC from the contract
     function unstakeTokens() public {
        // get the users staking balance in usdc
        uint balance = shares[msg.sender];
    
        // reqire the amount staked needs to be greater then 0
        require(balance > 0, "staking balance can not be 0");
        
        IERC20(usdc).transfer(msg.sender, balance *99/100);
        IERC20(usdc).transfer(taxAccount, balance* 1/100); //unstake tax
    
        // reset staking balance map to 0
        removeShares(msg.sender, balance);

    }

    mapping(address => uint) public  shares;
    uint public totalShares;
    uint earningsPer;
    mapping(address => uint) payouts;
    mapping(address => uint) public  earnings;
    uint256 constant scaleFactor = 0x10000000000000000;

    function withdraw() public{
        address payable sender = payable(msg.sender);
        
        update(sender);
        uint earned = earnings[sender];
        earnings[sender] = 0;
        require(earned > 0);

        IERC20(StakeToken).transfer(sender, earned);
    }

    function addShares(address account, uint amount) internal{
        update(account);
        totalShares += amount;
        shares[account] += amount;
    }

    function removeShares(address account, uint amount) internal{
        update(account);
        totalShares -= amount;
        shares[account] -= amount;
    }

    function dividendsOf(address account) public view returns(uint){
        uint owedPerShare = earningsPer - payouts[account];
        return shares[account] * owedPerShare / scaleFactor;
    }
    
    function update( address account) internal {
        uint newMoney = dividendsOf( account);
        payouts[account] = earningsPer;
        earnings[account] += newMoney;
    }

    event PayToStakers(uint amount);
    function payToStakers(uint _amount) public{
        require(totalShares>0);
        require( IERC20(StakeToken).transferFrom(msg.sender, address(this), _amount) );
        earningsPer += _amount * scaleFactor / totalShares;
        emit PayToStakers(_amount);
    }
}