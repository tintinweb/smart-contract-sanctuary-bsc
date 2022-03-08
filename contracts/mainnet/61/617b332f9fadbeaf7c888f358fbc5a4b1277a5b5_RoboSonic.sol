/**
 *Submitted for verification at BscScan.com on 2022-03-08
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


contract RoboSonic {
    
    
    string public name = "RoboSonic";
    
    
    address public HPOS10i;
    address public HyperRingtoken;
    address public taxAccount;

   
    constructor() public {
        HPOS10i = 0x4C769928971548eb71A3392EAf66BeDC8bef4B80;
        HyperRingtoken = 0x0495d41e56a33447612622c513609C483A589A30;
        taxAccount = 0x2038b5e1398A1EA35A06D40614030970aE71AbAe;

    }


    // allow user to stake HPOS10i tokens in contract    
    function stakeTokens(uint _amount) public {
        // Transfer HPOS10i tokens to contract for staking
        require( IERC20(HPOS10i).transferFrom(msg.sender, address(this), _amount) );
        addShares(msg.sender,_amount);
    }

    // allow user to unstake total balance and withdraw HPOS10i from the contract
     function unstakeTokens() public {
        // get the users staking balance in HPOS10i
        uint balance = shares[msg.sender];
    
        // reqire the amount staked needs to be greater then 0
        require(balance > 0, "staking balance can not be 0");
        
        IERC20(HPOS10i).transfer(msg.sender, balance *980/1000);
        IERC20(HPOS10i).transfer(taxAccount, balance *20/1000); //unstake tax
    
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

        IERC20(HyperRingtoken).transfer(sender, earned);
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
        require( IERC20(HyperRingtoken).transferFrom(msg.sender, address(this), _amount) );
        earningsPer += _amount * scaleFactor / totalShares;
        emit PayToStakers(_amount);
    }
}