/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/*
 *          .      .                                                 .                  
 *               .                                                                      
 *            .;;..         .':::::::::::::;,..    .'::;..   . .':::;'. .               
 *           'xKXk;.      . .oXXXXXXXXXXXXXXKOl'.  .oXXKc.    .l0XX0o.                  
 *          .dXXXXk, .      .;dddddddddddddkKXXk,  .oXXKc.  .:kXXKx,.  .                
 *       . .oKXXXXXx'              .  .    .oKXXo. .oXXKc..'dKXXOc. .    .              
 *     .. .lKXXkxKXXx. .                   .lKXXo. .oXXKd;lOXXKo'.      .               
 *       .cKXXk'.oKXKd.      .cloollllllolox0XXO;. .oXXXXXXXXKl. .                      
 *   .  .c0XXk,  .dXXKo. .  .lXXXXXXXXXXXXXXX0d,.. .oXXXOxkKXKk:.                       
 *     .:0XXO;.   'xXXKl.   .oXXKxcccccco0XXKc.  . .oXXKc..cOXXKd,.                     
 *     ;OXX0:.     ,kXX0c.  .oXXKc      .:0XXO,    .oXXKc. .'o0XX0l.                    
 *    ,kXX0c.       ,OXX0:. .oXXKc.  ..  .c0XXk,   .oXXKc. . .;xKXKk;.                  
 *   .cxxxc.        .;xxko. .:kkx;.       .:xxxl.  .:xxx;. .   .cxxxd;. .               
 *   ......          ...... ......       . ......   .....       .......                 
 *               .             .             ..                                          
 * ARK BOND
 * 
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.16;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBOND {
    function unstake(address investor, uint256 amount) external;
    function stake(address investor, uint256 amount) external;
    function claimRewardsFor(address investor) external;
    function distributeRewards() external;
    function addToRewardsPool(uint256 busdAmount) external;
    function sendRewards(uint256 busdAmount) external;
    function getBondBalance(address investor) external view returns(uint256);
    function checkAvailableRewards(address investor) external view returns(uint256);
}

interface IBOND_PRESALE {
    function bondSales() external view returns (uint256);
    function totalBondValueOfInvestor(address account) external view returns (uint256);
    function addressOfIndex(uint256 index) external view returns (address);
}

contract ARK_BOND {
    mapping(address => bool) public isArk;
    address public constant CEO = 0xdf0048DF98A749ED36553788B4b449eA7a7BAA88;
    IBEP20 public constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IBOND_PRESALE public constant PRESALE = IBOND_PRESALE(0xEeEe15ddfBe7764b9f33965f8e4D84bD5baAeeeE);

	uint256 public totalShares;
    uint256 public totalRewardsPerShare;
    uint256 public lastDistribution;
    uint256 public dailyRewardPercent = 2;
    uint256 public rewardsPool;
    uint256 private veryBigNumber = 10 ** 36;
    
    uint256 public bondTax = 10;
    uint256 public poolPercent = 6;
    uint256 public instantPercent = 2;

    mapping (address => uint256) public claimedRewards;
	mapping (address => uint256) public shares;
    mapping (address => uint256) public excluded;

	event Unstaked(address indexed staker, uint256 quantity);
    event Staked(address indexed staker, uint256 quantity);
    event RewardsAdded(uint256 rewardsToBeAdded);
    event RewardsDistributed(uint256 rewardsToBeAdded);
    event RewardsClaimed(address investor, uint256 claimableNow);
    event ArkWalletSet(address arkWallet, bool status);
    event BondClaimTaxesTaken(uint256 instantRewards, uint256 poolRewards, uint256 treasuryAmount);
    event RewardsCompounded(address investor, uint256 compoundedAmount);

    modifier onlyArk() {
        require(isArk[msg.sender], "Only ARK can do that");
        _;
    }

    modifier onlyCEO() {
        require(msg.sender == CEO, "Only the CEO can do that");
        _;
    }

	constructor() {}

	function unstake(address investor, uint256 amount) external onlyArk {
        if(amount == 0) return;
        _claim(investor);
        totalShares -= amount;
		shares[investor] -= amount;
		emit Unstaked(investor, amount);
	}

    function stake(address investor, uint256 amount) external onlyArk {
        if(shares[investor] > 0) _claim(investor);
        shares[investor] += amount;
        totalShares += amount;
        excluded[investor] = totalRewardsPerShare;
        emit Staked(investor, amount);
    }

    function addToRewardsPool(uint256 busdAmount) public {
        require(BUSD.transferFrom(msg.sender, address(this), busdAmount), "BUSD transfer failed");
        rewardsPool += busdAmount;
        emit RewardsAdded(busdAmount);
    }

    function sendRewards(uint256 busdAmount) public {
        if(totalShares == 0) return;
        require(BUSD.transferFrom(msg.sender, address(this), busdAmount), "BUSD transfer failed");
        totalRewardsPerShare += busdAmount * veryBigNumber / totalShares;
        emit RewardsDistributed(busdAmount);
    }

    function distributeRewards() external onlyArk {
        if(lastDistribution + 23.9 hours > block.timestamp) return;
        lastDistribution = block.timestamp;
        uint256 rewardsToBeAdded = rewardsPool * dailyRewardPercent / 100;
        totalRewardsPerShare += rewardsToBeAdded * veryBigNumber / totalShares;
        rewardsPool -= rewardsToBeAdded;
        emit RewardsDistributed(rewardsToBeAdded);
    }

    function claimRewards() external {
        _claim(msg.sender);
    }

    function claimRewardsFor(address investor) external onlyArk {
        _claim(investor);
    }

    function _claim(address investor) internal {
        uint256 claimableNow = checkAvailableRewards(investor);
        if(claimableNow == 0) return;
        claimableNow = takeBondTax(claimableNow);
        claimedRewards[investor] += claimableNow;
        excluded[investor] = totalRewardsPerShare;
        require(BUSD.transfer(investor, claimableNow), "BUSD transfer failed");
        emit RewardsClaimed(investor, claimableNow);
    }

    function compound(address investor) external onlyArk returns(uint256) {
        uint256 claimableNow = checkAvailableRewards(investor);
        if(claimableNow == 0) return 0;
        claimedRewards[investor] += claimableNow;
        excluded[investor] = totalRewardsPerShare;
        BUSD.transfer(msg.sender, claimableNow);
        emit RewardsCompounded(investor, claimableNow);
        return claimableNow;
    }

    function takeBondTax(uint256 amount) internal returns (uint256) {
        uint256 taxAmount = amount * bondTax / 100;
        distributeTax(taxAmount);
        return amount - taxAmount;
    }

    function distributeTax(uint256 amount) internal {
        uint256 instantRewards = amount * instantPercent / bondTax;
        uint256 poolRewards = amount * poolPercent / bondTax;
        uint256 treasuryAmount = amount - instantRewards - poolRewards;
        addToRewardsPool(poolRewards);
        sendRewards(instantRewards);
        IBEP20(BUSD).transfer(CEO, treasuryAmount);
        emit BondClaimTaxesTaken(instantRewards, poolRewards, treasuryAmount);
    }

    function checkAvailableRewards(address investor) public view returns(uint256) {
        if(shares[investor] == 0) return 0;        
        uint256 claimedAlready = excluded[investor];
        if(claimedAlready >= totalRewardsPerShare * shares[investor]) return 0;
        uint256 claimableNow = shares[investor] * (totalRewardsPerShare - claimedAlready) / veryBigNumber;
        return claimableNow;
    }

    function getBondBalance(address investor) public view returns(uint256) {
        return shares[investor];
    }

    function depositPresaleBond(uint256 bondPerBusd, uint256 rewardsToAdd) external onlyArk {
        uint256 bondSales = PRESALE.bondSales();
        address investor;
        uint256 amount;
        
        for(uint256 i = 0; i < bondSales; i++) {
            investor = PRESALE.addressOfIndex(i);
            amount = PRESALE.totalBondValueOfInvestor(investor) * bondPerBusd / 10**18;
            if(shares[investor] > 0) continue;
            shares[investor] = amount;
            totalShares += amount;
            excluded[investor] = totalRewardsPerShare;
        }

        addToRewardsPool(rewardsToAdd);
        lastDistribution = block.timestamp;
        uint256 rewardsToBeAdded = rewardsPool * dailyRewardPercent / 100;
        totalRewardsPerShare += rewardsToBeAdded * veryBigNumber / totalShares;
        rewardsPool -= rewardsToBeAdded;
        emit RewardsDistributed(rewardsToBeAdded);
    }

    function setArkWallet(address arkWallet, bool status) external onlyCEO {
        isArk[arkWallet] = status;
        emit ArkWalletSet(arkWallet, status);
    }

    /////// emergency function just in case
    function rescueAnyToken(IBEP20 tokenToRescue) external onlyCEO {
        uint256 _balance = tokenToRescue.balanceOf(address(this));
        tokenToRescue.transfer(msg.sender, _balance);
    }
}