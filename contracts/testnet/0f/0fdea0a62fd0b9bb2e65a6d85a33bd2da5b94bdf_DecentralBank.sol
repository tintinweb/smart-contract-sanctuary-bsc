// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
    import './RWD.sol';
    // import './Tether.sol';
contract DecentralBank {
    string public name ='Decentral Bank';
    address public owner;
    IERC20 public tether;
    IERC20 public rwd;

    address[] public stakers;

    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
constructor(address _rwd, address _tether) public {
    rwd = IERC20(_rwd);
    tether = IERC20(_tether);
    owner = msg.sender;
}
// staking 
function depositTokens(uint _amount) public {
    // Transfer tether tokens to this contract address for staking
    tether.transferFrom(msg.sender, address(this), _amount);

    //update Staking Balance
    stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

    if (!hasStaked[msg.sender]) {
        stakers.push(msg.sender);
    }

    //Update Staking Balance
    isStaking[msg.sender] = true;
    hasStaked[msg.sender] = true;
}

// issue rewards
function issueTokens() public {
// require the owner to issue tokens only
    require(msg.sender == owner, 'caller must be the owner');
        for (uint i=0; i<stakers.length; i++){
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            if(balance > 0) {
                rwd.transfer(recipient, balance);
            }
        }
    }

// unstake tokens
    function unstakeTokens() public {
        uint balance = stakingBalance[msg.sender];
        // require the amount to be greater than zero    
        // require( balance>0, "staking balance cannot be less than zero");
        // transfer the tokens to the specified contract address from our bank
        tether.transfer(msg.sender, balance);
        // reset staking balance
        stakingBalance[msg.sender] = 0;
        // Update Staking Status
        isStaking[msg.sender] = false;
    }
}