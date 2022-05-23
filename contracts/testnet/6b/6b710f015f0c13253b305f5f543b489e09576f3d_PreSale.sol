/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
interface IBEP20 {
    function balanceOf(address account) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0, "divided by 0");
        uint c = a / b;
        return c;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}
library TransferHelper {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }
}
contract PreSale {
	using SafeMath for uint;
	using Address for address;
    bool public isEnds;
    uint public totalSupply;
    uint public soldAmount;
    uint public priceForUSDT;  
	uint public timePresaleBegin; 
    uint public holdersAmounts;
    uint public totalRaisedUSDT;//总共筹集到的USDT量
    mapping (address => uint) public balanceOf; //用户的bong量
    mapping (address => address) public inviter;//用户的邀请人
    mapping (address => uint) public spentUSDTAmount;//每个用户花费的USDT
    mapping (address => bool) public holderIsExist;
    address public owner;
	address public USDT;
    address public recipientWallet;
    address[] public holders;
    uint8 public decimals;
    event Offer(address indexed sender, uint indexed usdt, uint amountOfTokens);
    constructor() {
        owner = msg.sender;
        totalSupply = 1000000*(1e18);
        decimals = 18;
        priceForUSDT = 15*(1e16);
        USDT = 0xEdA5dA0050e21e9E34fadb1075986Af1370c7BDb;
        recipientWallet = 0xE3fd95E849Da4677839533709fbEEca39aF5FE5b;
    }
    function setPresaleTimeBegin(uint presaleTime) public {
        require(msg.sender == owner);
        timePresaleBegin = presaleTime;
    }
    function endsPresale(bool flag) public {
        require(msg.sender == owner);
        isEnds = flag;
    }
	function buyWithUSDT(address inviterOf, uint amount) external {
		require(block.timestamp >= timePresaleBegin, "it's not time yet");
		require(!isEnds, 'Bong has sold out');
        require(amount > 0, 'amount can not be zero');
        require(!msg.sender.isContract(), 'contract call is not permitted');
		require(IBEP20(USDT).allowance(msg.sender, address(this)) >= amount, 'allowance not enough');
		require(IBEP20(USDT).balanceOf(msg.sender) >= amount, 'balance not enough');
        if(!holderIsExist[msg.sender]) {
            holders.push(msg.sender);
            holdersAmounts = holdersAmounts.add(1);
            holderIsExist[msg.sender] = true;
        }
        if(inviterOf != address(0) && inviterOf != inviter[msg.sender]) {
            inviter[msg.sender] = inviterOf;
        }
        uint desiredAmount = amount.div(priceForUSDT).mul(1e18);
        require(desiredAmount <= totalSupply.sub(soldAmount), "exceeded total sale amount");
        TransferHelper.safeTransferFrom(USDT, msg.sender, recipientWallet, amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(desiredAmount);//增加总量
        soldAmount = soldAmount.add(desiredAmount);
        totalRaisedUSDT = totalRaisedUSDT.add(amount);
        spentUSDTAmount[msg.sender] = spentUSDTAmount[msg.sender].add(amount);
		emit Offer(msg.sender, amount, desiredAmount);
	}
}