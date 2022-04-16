/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract WertoEscrow {
	address payable private owner;
	address[] private approvedSubOwners;
	bool private paused;
	uint private feePercent;
	uint private lockupTime;
	uint private minimumBid;
	uint private minimumBidPercent;
	uint private ownerBalance;

	struct Bid {
		uint amount;
		address payable bidder;
		uint timestamp;
	}

	mapping(address => bool) private subOwners;
	mapping(address => uint) private balances;
	mapping(uint => address) private postSellers;
	mapping(uint => Bid) private bids;

	event makeOffer(
		uint indexed postId,
		address indexed bidder,
		address indexed outbid,
		uint amount,
		uint timestamp
	);

	event cancelOffer(
		uint indexed postId,
		address indexed bidder,
		uint amount,
		uint timestamp
	);

	event acceptOffer(
		uint indexed postId,
		address indexed seller,
		address indexed buyer,
		uint amount,
		uint timestamp
	);

	event withdraw(
		address indexed account,
		uint amount,
		uint timestamp
	);

	constructor() {
		owner = payable(msg.sender);
		paused = false;
		feePercent = 8;
		lockupTime = 24 * 3600; //seconds
		minimumBid = 0.01 * 10**18; //0.01 ETH
		minimumBidPercent = 10;
		ownerBalance = 0;
	}

	modifier onlyOwner {
		require(msg.sender == owner, 'Only owner');
		_;
	}

	modifier onlyOwners {
		require(subOwners[msg.sender] || msg.sender == owner, 'Only owners');
		_;
	}

	modifier notPaused {
		require(!paused, 'Contract is paused');
		_;
	}

	function MakeOffer(uint postId) public payable notPaused {
		if(bids[postId].amount > 0) {
			if(msg.value - (msg.value % 10**10) < bids[postId].amount + (bids[postId].amount * minimumBidPercent / 100) - ((bids[postId].amount * minimumBidPercent / 100) % 10**10)) revert('Offer too low');
		} else {
			if((msg.value - (msg.value % 10**10)) < minimumBid) revert('Offer too low');
		}

		if(bids[postId].amount > 0) {
			(bool success,) = bids[postId].bidder.call{value: bids[postId].amount}('');

			if(!success) balances[bids[postId].bidder] += bids[postId].amount;
		}

		address outbidder = bids[postId].bidder;

		bids[postId].bidder = payable(msg.sender);
		bids[postId].timestamp = block.timestamp;
		bids[postId].amount = msg.value - (msg.value % 10**10);

		emit makeOffer(
			postId,
			msg.sender,
			outbidder,
			msg.value - (msg.value % 10**10),
			block.timestamp
		);
	}

	function CancelOffer(uint postId) public notPaused {
		require(bids[postId].bidder == msg.sender, 'Current offer has a different owner');
		require(bids[postId].amount > 0, 'Balance is empty');
		require((bids[postId].timestamp + lockupTime) <= block.timestamp, 'Minimum offer lock time has not expired');
		
		uint sendValue = bids[postId].amount;

		bids[postId].amount = 0;

		(bool success,) = bids[postId].bidder.call{value: sendValue}('');
		require(success, 'Transfer failed');

		emit cancelOffer(
			postId,
			bids[postId].bidder,
			sendValue,
			block.timestamp
		);
	}

	function AcceptOffer(uint postId, address payable seller, uint price) public onlyOwners notPaused {
		AcceptOfferHandler(postId, seller, price, false);
	}

	function AcceptOfferSeller(uint postId, uint price) public notPaused {
		AcceptOfferHandler(postId, payable(msg.sender), price, true);
	}

	function AcceptOfferHandler(uint postId, address payable seller, uint price, bool asSeller) private notPaused {
		if(asSeller) require(postSellers[postId] == seller, 'Not an owner of the item');
		require(bids[postId].amount >= price, 'Invalid price specified');

		uint sendValue = bids[postId].amount - (bids[postId].amount * feePercent / 100);
		uint ownerShare = bids[postId].amount * feePercent / 100;

		bids[postId].amount = 0;

		delete postSellers[postId];

		(bool success,) = seller.call{value: sendValue}('');

		if(!success) balances[seller] += sendValue;

		emit acceptOffer(
			postId,
			seller,
			bids[postId].bidder,
			sendValue,
			block.timestamp
		);

		if(ownerShare > 0) {
			(bool ownSuccess,) = owner.call{value: ownerShare}('');

			if(!ownSuccess) ownerBalance += ownerShare;
		}
	}

	function Withdraw() public notPaused {
		require(balances[msg.sender] > 0, 'Balance is empty');

		uint sendValue = balances[msg.sender];
		
		balances[msg.sender] = 0;

		(bool success,) = msg.sender.call{value: sendValue}('');
		require(success, 'Transfer failed');
	
		emit withdraw(
			msg.sender,
			sendValue,
			block.timestamp
		);
	}

	function GetPostSeller(uint postId) public view onlyOwners returns (address) {
		return postSellers[postId];
	}

	function SetPostSeller(uint postId, address postSeller) public onlyOwners {
		postSellers[postId] = postSeller;
	}

	function GetBid(uint postId) public view returns (uint timestamp, address bidder, uint amount) {
		return (bids[postId].timestamp, bids[postId].bidder, bids[postId].amount);
	}

	function GetBidMinimum() public view returns (uint) {
		return minimumBid;
	}

	function SetBidMinimum(uint amount) public onlyOwners {
		require(amount >= 10**10, 'Invalid minimum');
		minimumBid = amount;
	}

	function SetBidMinimumPercent(uint percent) public onlyOwners {
		require(percent >= 0 && percent <= 100, 'Invalid percent');
		minimumBidPercent = percent;
	}

	function GetBidLockupTime() public view returns (uint) {
		return lockupTime;
	}

	function SetBidLockupTime(uint duration) public onlyOwners {
		require(duration <= (365 * 24 * 3600), 'Invalid duration');
		lockupTime = duration;
	}

	function GetFeePercent() public view returns (uint) {
		return feePercent;
	}

	function SetFeePercent(uint percent) public onlyOwners {
		feePercent = percent;
	}

	function GetBalance(address bidder) public view returns (uint) {
		return balances[bidder];
	}

	function GetOwnerBalance() public view onlyOwners returns (uint) {
		return ownerBalance;
	}

	function OwnerWithdraw() public onlyOwner {
		require(ownerBalance > 0, 'Balance is empty');

		uint sendValue = ownerBalance;
		ownerBalance = 0;

		(bool success,) = msg.sender.call{value: sendValue}('');
		require(success, 'Transfer failed');
	}

	function SetPause(bool state) public onlyOwners {
		paused = state;
	}

	function SetOwner(address payable newOwner) public onlyOwner {
		owner = newOwner;
	}

	function SetSubOwner(address subOwner, bool approved) public onlyOwner {
		subOwners[subOwner] = approved;

		if(approved) approvedSubOwners.push(subOwner);
	}

	function GetSubOwners() public view onlyOwners returns (address[] memory)  {
		return approvedSubOwners;
	}

	function IsSubOwner(address subOwner) public view returns (bool) {
		return subOwners[subOwner];
	}

	receive() external payable {
		revert('Unidentified transaction');
	}

	fallback() external payable {
		revert('Unidentified transaction');
	}
}