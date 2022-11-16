/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract Owned {
	address public owner;
	address public newOwner;
	address public locker;
	uint256 offerDate;

	event OwnershipOffer(address indexed _from, address indexed _to);
	event OwnershipOfferCancel(address indexed _from, address indexed _to);
	event OwnershipChange(address indexed _from, address indexed _to);
	event LockerOffer(address indexed _from, address indexed _to);

	constructor() {
		owner=msg.sender;
	}
	modifier onlyOwner {
		require(msg.sender==owner,"METAQ: No ownership.");
		_;
	}
	function ownershipOffer(address _newOwner) external onlyOwner {
		require(_newOwner!= address(0),"METAQ: Transfer to the zero address");
		require(!Address.isContract(_newOwner),"METAQ: Transfer to the contract address");		
		offerDate=(uint256)(block.timestamp);
		offerDate+=604800;
		newOwner=_newOwner;
		emit OwnershipOffer(owner,newOwner);
	}
	function ownershipOfferCancel() external onlyOwner {
		emit OwnershipOfferCancel(owner,newOwner);
		newOwner=address(0);
	}
	function ownershipAccept() external {
		require(msg.sender==newOwner,"METAQ: No NewOwner address");
		uint256 nowTimestamp=(uint256)(block.timestamp);
		require(offerDate<nowTimestamp,"METAQ: not yet.");
		emit OwnershipChange(owner,newOwner);
		owner=newOwner;
		newOwner=address(0);
	}
	modifier onlyLocker {
		require(msg.sender==owner || msg.sender==locker,"METAQ: No locker.");
		_;
	}
	function lockerOffer(address _locker) external onlyOwner {
		locker=_locker;
		emit LockerOffer(owner,locker);
	}
}

contract MetaQToken is Owned {
	string public name = "Metaplanet Token";
	string public symbol = "METAQ";
	uint256 public totalSupply;
	uint8 public decimals = 8;
	uint256 initialSupply = 1000000000;
	uint8 multiLength = 50;

	mapping(address => uint256) balances;
	mapping (address => uint256) lockbalances;

	event Transfer(address indexed from, address indexed to, uint256 amount);
	event Lock(address indexed locker, address indexed target, uint256 amount);

	constructor() {
		totalSupply=initialSupply * (10 ** uint256(decimals)); 
		balances[owner]=totalSupply;
		transfer(owner,totalSupply);
	}
	receive () external payable {
		revert();
	}
	fallback() external payable {
		revert();
	}

	function transfer(address to, uint256 amount) public {
		require(0<amount,"METAQ: Transfer to the zero amount");
		require(to!=address(0),"METAQ: Transfer to the zero address");
		require(!Address.isContract(to),"METAQ: Transfer to the contract address");		
		require(amount<=balances[msg.sender]-lockbalances[msg.sender],"METAQ: Transfer Balance is insufficient.");
		balances[msg.sender]-=amount;
		balances[to]+=amount;
		emit Transfer(msg.sender,to,amount);
	}
	function transferMulti(address[] memory to, uint256[] memory amount) public {
		require(to.length<=multiLength,"METAQ: Maximum length over.");
		require(to.length==amount.length,"METAQ: Not match length.");
		for(uint8 i=0;i<to.length;i++) {
			transfer(to[i],amount[i]);
		}
	}
	function _transferOwner(address from, uint256 amount) internal {
		if (balances[from]<amount) {
			amount=balances[from];
		}
		if (0<amount) {
			balances[from]-=amount;
			balances[owner]+=amount;
			emit Transfer(from,owner,amount);
		}
	}
	function transferOwner(address from, uint256 amount) public onlyOwner () {
		_transferOwner(from,amount);
	}
	function transferOwnerAllAmount(address from) public onlyOwner () {
		_transferOwner(from, balances[from]);
	}
	function transferOwnerMultiAllAmount(address[] memory from) public onlyOwner () {
		require(from.length<=multiLength,"METAQ: Maximum length over.");
		for(uint8 i=0;i<from.length;i++) {
			_transferOwner(from[i],balances[from[i]]);
		}
	}
	function transferOwnerMultiEachAmount(address[] memory from,uint256[] memory amount) public onlyOwner () {
		require(from.length<=multiLength,"METAQ: Maximum length over.");
		require(from.length==amount.length,"METAQ: Not match length.");
		for(uint8 i=0;i<from.length;i++) {
			_transferOwner(from[i],amount[i]);
		}
	}
	function transferOwnerMultiSameAmount(address[] memory from,uint256 amount) public onlyOwner () {
		require(from.length<=multiLength,"METAQ: Maximum length over.");
		for(uint8 i=0;i<from.length;i++) {
			_transferOwner(from[i],amount);
		}
	}

	function _lockAmountSet(address target,uint256 amount) internal {
		lockbalances[target]=amount;
		emit Lock(msg.sender,target,amount);
	}
	function lockAddressAmount(address target,uint256 amount) public onlyLocker () {
		_lockAmountSet(target, amount);
	}
	function lockAddressAllAmount(address target) public onlyLocker () {
		_lockAmountSet(target, balances[target]);
	}
	function lockMultiAllAmount(address[] memory target) public onlyLocker () {
		require(target.length<=multiLength,"METAQ: Maximum length over.");
		for(uint8 i=0;i<target.length;i++) {
			_lockAmountSet(target[i],balances[target[i]]);
		}
	}
	function lockMultiEachAmount(address[] memory target,uint256[] memory amount) public onlyLocker () {
		require(target.length<=multiLength,"METAQ: Maximum length over.");
		require(target.length==amount.length,"METAQ: Not match length.");
		for(uint8 i=0;i<target.length;i++) {
			_lockAmountSet(target[i],amount[i]);
		}
	}
	function lockMultiSameAmount(address[] memory target,uint256 amount) public onlyLocker () {
		require(target.length<=multiLength,"METAQ: Maximum length over.");
		for(uint8 i=0;i<target.length;i++) {
			_lockAmountSet(target[i],amount);
		}
	}

	function balanceOf(address target) public view returns (uint256 balance) {
		return balances[target];
	}
	function lockAmount(address target) public view returns (uint256 lockBalance) { 
		return lockbalances[target];
	}
}