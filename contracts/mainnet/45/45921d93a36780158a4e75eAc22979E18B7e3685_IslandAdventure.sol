/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

//SPDX-License-Identifier: MIT
//https://islandsadventure.net/ -- WebSite
//https://t.me/islands_adventures -- Telegram
//https://discord.gg/qKXQcvZ6XE -- Discord
//https://twitter.com/islands_network -- Twitter

pragma solidity ^0.8.7;

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *  
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract IslandAdventure{
    address owner;
    IERC20 constant busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    uint256 public totalDeps;

    struct Account{
        uint256 goldBalance;
        uint256 scouts;
        bool isActive;
        address referral;
        uint256 referrals;
        uint256 referralsDep;
        uint256 lastZone;
        uint256 level;
        uint256 currZone;
        uint256 currLevel;
        uint256 timestamp;
        uint256 scoutsOnMission;
    }
    bool init = false;

    modifier initialized {
      require(init, 'Not initialized');
      _;
    }

    constructor(){
        owner = msg.sender;
    }

    function initialize() external {
      require(owner == msg.sender, "You aren't owner");
      require(!init);
      init = true;
    }

    mapping(address => Account) public players;

    function RecruitScouts(address ref, uint256 value) initialized external
    {
        address player = msg.sender;
        uint256 amount = value;
        require(amount > 0, "Too low amoount");
        if(players[player].isActive == false)
        {
            players[player].referral = ref;
            players[player].isActive = true;
            players[ref].referrals++;
        }
        ref = players[player].referral;
        players[player].scouts += amount;
        players[ref].referralsDep += amount;
        players[ref].scouts += (amount * 8) / 100;
        players[ref].goldBalance += (amount * 2) / 100;
        players[owner].scouts +=(amount * 5) / 100;
        uint256 marketFee = (value * 5) / 100;
        totalDeps += value;
        busd.transferFrom(msg.sender, owner, marketFee);
        busd.transferFrom(msg.sender, address(this), value - marketFee);
    }

    function withdraw(uint256 value) initialized external 
    {
        address player = msg.sender;
        require(players[player].goldBalance >= value && value > 0, "Insufficient balance or amount is 0");
        players[player].goldBalance -= value;
        uint256 transferAmount = value;
        busd.transfer(player, busd.balanceOf(address(this)) < transferAmount ? busd.balanceOf(address(this)) : transferAmount);
    }
    function startNewExpedition(uint256 zoneId, uint256 level) initialized external
    {
        address player = msg.sender;
        expeditionStartControl(zoneId, level, player);
    }

    function endExpedition(bool endType) initialized external
    {
        address player = msg.sender;
        require(block.timestamp - players[player].timestamp >= 86400, "It's too early");
        getReward(player, block.timestamp);
        if(endType == false)
        {
            expeditionStartControl(players[player].lastZone + 1, players[player].level, player);    
        }
        
    }
    function expeditionStartControl(uint256 zoneId, uint256 level, address player) internal
    {
        require(players[player].timestamp == 0, "Your team on expedition right now");
        require(players[player].lastZone >= zoneId - 1 	&& players[player].level >= level && players[player].scouts > 0, "You can't start this expedition right now, or your team is 0");
        players[player].currZone = zoneId;
        players[player].currLevel = level;
        players[player].timestamp = block.timestamp;
        uint256 scouts = players[player].scouts;
        players[player].scoutsOnMission = scouts;
        players[player].scouts -= scouts;
    }
    function getReward(address player, uint256 timestamp) internal
    {
        uint256 percents = getZones(players[player].currZone, players[player].currLevel);
        uint256 foundedGold = (players[player].scoutsOnMission * percents) / 1000;
        uint256 time = timestamp - players[player].timestamp - 86400;
        if(time >= 3600)
        {
            uint256 hrsMath = time / 3600;
            uint256 hrs = hrsMath  <= 24 ? hrsMath : 24;
            uint256 additionalGold = players[player].scoutsOnMission / 1000 * percents / 24 * hrs;
            players[player].goldBalance += additionalGold;
        }
        players[player].goldBalance += foundedGold;
        players[player].scouts += players[player].scoutsOnMission;
        players[player].scoutsOnMission = 0;
        players[player].timestamp = 0;
        if(players[player].currZone == 7 && players[player].level < 3)
        {
            players[player].lastZone = 0;
            players[player].level++;
        }
        else if(players[player].currZone == 7 && players[player].level == 3)
        {
            
        }
        else{
            players[player].lastZone++;
        }
    }
    function getZones(uint256 zoneId, uint256 levelId) internal pure returns (uint256)
    {
        if(levelId == 0) return [0, 10, 12, 14, 16, 18, 20, 22][zoneId];
        if(levelId == 1) return [0, 16, 18, 20, 22, 24, 26, 28][zoneId];
        if(levelId == 2) return [0, 20, 22, 24, 26, 28, 30, 32][zoneId];
        if(levelId == 3) return [0, 22, 24, 26, 28, 30, 32, 35][zoneId];
    } 
}