/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// File: contracts/superstake.sol


pragma solidity ^0.8.4;

interface ERC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface Staking_Standard {

    function deposit(address tokenAddress,address userAddress, uint256 amount) external;
    function withdraw(address tokenAddress,address userAddress, uint256 amount) external ;
    function pendingReward(address account) external view returns (uint256);
    function autoCompound(address tokenAddress, uint256 amount) external returns (uint256) ;
}

// adding modifiers is pending
contract SuperStakeV2 {
    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => address) public protocols;
    mapping(address => bool) public isStakingAllowed;
    mapping(address => bool) public isUnstakingAllowed;
    address public Push = 0x84E5eAb7501b43f5be6d5640182c05Bf9835b8Bd;

    event Deposit(address indexed user, address indexed tokenAddress, uint256 amount);
    event Withdraw(address indexed user, address indexed tokenAddress, uint256 amount);
    event AutoCompund(address indexed tokenAddress, uint256 amount);


    function Stake(address tokenAddress, uint256 amount) public {

        require(isStakingAllowed[tokenAddress],"staking not enabled");
        balances[msg.sender][tokenAddress] += amount ;
        ERC20 token = ERC20(tokenAddress);
        token.transferFrom(msg.sender, protocols[tokenAddress], amount);

        if(tokenAddress == Push){
            Staking_Standard( protocols[tokenAddress]).deposit(tokenAddress,msg.sender, amount);
            emit Deposit(msg.sender, tokenAddress, amount);
        }
        

    }

    function unStake(address tokenAddress, uint256 amount) public {

        require(isUnstakingAllowed[tokenAddress],"unstaking not enabled");
        require(amount <= balances[msg.sender][tokenAddress],"you can only withdraw your staked amount");
        balances[msg.sender][tokenAddress] -= amount ;

        if(tokenAddress == Push){
            Staking_Standard( protocols[tokenAddress]).withdraw(tokenAddress,msg.sender, amount);
            emit Withdraw(msg.sender, tokenAddress, amount);
        }
    }

    function autoCompond(address tokenAddress, uint _amount) public {

        if(tokenAddress == Push){
            uint autoAmount = Staking_Standard( protocols[tokenAddress]).autoCompound(tokenAddress, _amount);
            emit AutoCompund(tokenAddress, autoAmount);
        }

    }

    function addProtocols(address token, address protocol) public{
        protocols[token] = protocol;
        isStakingAllowed[token] = true;
        isUnstakingAllowed[token] = true;
    }

    function changeStakeStatus(address _token, bool _stake, bool _unstake) public{
        isStakingAllowed[_token] = _stake;
        isUnstakingAllowed[_token] = _unstake;
    }


}