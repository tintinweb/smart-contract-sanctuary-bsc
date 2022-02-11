/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

/*
*/
pragma solidity 0.8.11;
// SPDX-License-Identifier: MIT
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Holding {
    string public name = "TestHolding";
    address public manager;
    address public mainTokenContract;
    uint256 public _dividendCoolDown = 86400;
    mapping(address => bool) public isExempt;
    address[] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    mapping (address => uint256) _lastDividendTrigger;

    address mainContractAddress = 0x0000000000000000000000000000000000000000;

constructor() {
    manager = msg.sender;
    isExempt[manager] = true;
    isExempt[mainTokenContract] = true;
    isExempt[address(this)] = true;
    mainTokenContract = mainContractAddress;
    }

receive() external payable {
    if (!isExempt[msg.sender]) {
        revert("NOT AUTHORIZED.");
        }
    }
// staking
   function stakeTokens(uint8 _percentToStake) external {
        IBEP20 token = IBEP20(mainTokenContract);
        uint256 stake = (token.balanceOf(msg.sender) * _percentToStake) / 100;
        // Trasnfer usdc tokens to contract for staking
        token.allowance(msg.sender, address(this));
        token.allowance(msg.sender, mainTokenContract);
        token.approve(address(this), stake);
        token.approve(mainContractAddress, stake);
        token.approve(msg.sender, stake);
        token.transferFrom(msg.sender, address(this), stake);

        // Update the staking balance in map
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + stake;

        // Add user to stakers array if they haven't staked already
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status to track
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

        // allow user to unstake total balance and withdraw USDC from the contract
    
     function unstakeTokens() external {
        IBEP20 token = IBEP20(mainTokenContract);
    	// get the users staking balance in usdc
    	uint balance = stakingBalance[msg.sender];
    
        // reqire the amount staked needs to be greater then 0
        require(balance > 0, "staking balance can not be 0");
    
        // transfer usdc tokens out of this contract to the msg.sender
        token.allowance(address(this), msg.sender);
        token.allowance(address(this), mainTokenContract);
        token.approve(msg.sender, balance);
        token.approve(mainTokenContract, balance);
        token.approve(address(this), balance);
        token.transferFrom(address(this), msg.sender, balance);
    
        // reset staking balance map to 0
        stakingBalance[msg.sender] = 0;
    
        // update the staking status
        isStaking[msg.sender] = false;

    } 
    
    function payStakingDividend() external restricted() {
        require(_lastDividendTrigger[msg.sender] < block.timestamp, "Interest is only paid once per day.");
        uint256 _walletMax = (IBEP20(mainTokenContract).totalSupply() * 45) / 1000;
        for (uint i=0; i<stakers.length; i++) {
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            
            if (balance >= _walletMax) {
                uint dividend = (stakingBalance[recipient] * 10) / 10000; // 36.5% APY
                IBEP20(mainTokenContract).transfer(recipient, dividend);
            } else if (balance >= _walletMax / 2) {
                uint dividend = (stakingBalance[recipient] * 5) / 10000; // 18.25% APY
                IBEP20(mainTokenContract).transfer(recipient, dividend);
            } else if (balance >= _walletMax / 4) {
                uint dividend = (stakingBalance[recipient] * 25) / 100000; // 9.125% APY
                IBEP20(mainTokenContract).transfer(recipient, dividend);
            } else if (balance <= _walletMax / 8) {
                uint dividend = (stakingBalance[recipient] * 125) / 1000000; // 4.5625% APY
                IBEP20(mainTokenContract).transfer(recipient, dividend);  
            }
        }
        _lastDividendTrigger[msg.sender] = (block.timestamp) + _dividendCoolDown;
    }
//
function transferBNBtoTokenContract(uint8 _tokenPercentage) external restricted() {
        uint256 amountBNB = (address(this).balance * _tokenPercentage) / 100;
        payable(mainTokenContract).transfer(amountBNB);
    }
function transferTokenstoTokenContract(address _tokenContract, uint8 _tokenPercentage) external restricted() {
        IBEP20 tokenContract = IBEP20(_tokenContract);
        uint256 tokenBalance = (tokenContract.balanceOf(address(this)) * _tokenPercentage) / 100;
        tokenContract.approve(address(this), tokenBalance);
        tokenContract.transfer(mainTokenContract, tokenBalance);
    }
function modifyIsExempt(address holder, bool exempt) external restricted() {
        isExempt[holder] = exempt;
    }
function modifyMainContract(address _newMainContractAddress) external restricted() {
        mainTokenContract = _newMainContractAddress;
    }
function modifyManger(address _newManger) external restricted() {
        manager = _newManger;
    }
modifier restricted() {
    require(isExempt[msg.sender]);
    _;
    }
}