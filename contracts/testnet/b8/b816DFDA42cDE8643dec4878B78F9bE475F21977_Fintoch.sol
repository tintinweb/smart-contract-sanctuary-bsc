/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// This is the ETH/ERC20 borrow contract for Fintoch.
//
// For 2-of-3 multisig, to authorize a spend, two signtures must be provided by 2 of the 3 owners.
// To generate the message to be signed, provide the destination address and
// spend amount (in wei) to the generateMessageToSign method.
// The signatures must be provided as the (v, r, s) hex-encoded coordinates.
// The S coordinate must be 0x00 or 0x01 corresponding to 0x1b and 0x1c, respectively.
//
// WARNING: The generated message is only valid until the next spend is executed.
//          after that, a new message will need to be calculated.
//
//
// INFO: This contract is ERC20 compatible.
// This contract can both receive ETH and ERC20 tokens.
// Notice that NFT (ERC721/ERC1155) is not supported. But can be transferred out throught spendAny.

contract Fintoch {

	struct BorrowInfo {
		string orderId;
		uint256 borrowAmount;
		address tokenAddress; // this address will be 0x0 when borrow ETH
	}

	BorrowInfo public borrowInfo;

	uint constant public MAX_OWNER_COUNT = 9;

	// The N addresses which control the funds in this contract. The
	// owners of M of these addresses will need to both sign a message
	// allowing the funds in this contract to be spent.
	mapping(address => bool) private isOwner;
	address[] private owners;
	uint private required;

	// The contract nonce is not accessible to the contract so we
	// implement a nonce-like variable for replay protection.
	uint256 private spendNonce = 0;

	bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

	// An event sent when funds are received.
	event Funded(address from, uint value);

	// An event sent when a spend is triggered to the given address.
	event Spent(address to, uint transfer);

	// An event sent when a liquidatedAssets is triggered to the given address.
	event Liquidated(address erc20contract, address fintochPool, uint transfer);

	// An event sent when an toSwap is executed.
	event Swapped(address routerAddress, uint transfer);

	// An event sent when a crossChain is triggered to the given address.
	event Crossed(address erc20contract, address to, uint transfer);

	// An event sent when an spendAny is executed.
	event SpentAny(address to, uint transfer);

	// An event sent when an setBorrowInfo is executed.
	event BorrowInfoUpdated(BorrowInfo newInfo);

	modifier validRequirement(uint ownerCount, uint _required) {
		require (ownerCount <= MAX_OWNER_COUNT
		&& _required <= ownerCount
			&& _required >= 1);
		_;
	}

	/// @dev Contract constructor sets initial owners and required number of confirmations.
	/// @param _owners List of initial owners.
	/// @param _required Number of required confirmations.
	constructor(address[] memory _owners, uint _required, BorrowInfo memory _borrowInfo) validRequirement(_owners.length, _required) {
		for (uint i = 0; i < _owners.length; i++) {
			//onwer should be distinct, and non-zero
			if (isOwner[_owners[i]] || _owners[i] == address(0x0)) {
				revert();
			}
			isOwner[_owners[i]] = true;
		}
		owners = _owners;
		required = _required;
		borrowInfo = _borrowInfo;
	}

	// The receive function for this contract.
	receive() external payable {
		if (msg.value > 0) {
			emit Funded(msg.sender, msg.value);
		}
	}

	// @dev Returns list of owners.
	// @return List of owner addresses.
	function getOwners() public view returns (address[] memory) {
		return owners;
	}

	function getSpendNonce() public view returns (uint256) {
		return spendNonce;
	}

	function getRequired() public view returns (uint) {
		return required;
	}

	function _safeTransfer(address token, address to, uint value) private {
		(bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
		require(success && (data.length == 0 || abi.decode(data, (bool))), 'Fintoch: TRANSFER_FAILED');
	}

	// Generates the message to sign given the output destination address and amount.
	// includes this contract's address and a nonce for replay protection.
	// One option to independently verify: https://leventozturk.com/engineering/sha3/ and select keccak
	function generateMessageToSign(address erc20Contract, address destination, uint256 value) private view returns (bytes32) {
		require(destination != address(this));
		//the sequence should match generateMultiSigV2 in JS
		bytes32 message = keccak256(abi.encodePacked(address(this), erc20Contract, destination, value, spendNonce));
		return message;
	}

	function _messageToRecover(address erc20Contract, address destination, uint256 value) private view returns (bytes32) {
		bytes32 hashedUnsignedMessage = generateMessageToSign(erc20Contract, destination, value);
		bytes memory prefix = "\x19Ethereum Signed Message:\n32";
		return keccak256(abi.encodePacked(prefix, hashedUnsignedMessage));
	}

	// Generates the message to sign given the output destination address and amount.
	// includes this contract's address and a nonce for replay protection.
	// One option to independently verify: https://leventozturk.com/engineering/sha3/ and select keccak
	function generateMessageToSignAny(address destination, uint256 value, bytes calldata data) private view returns (bytes32) {
		require(destination != address(this));
		//the sequence should match generateMultiSigV2 in JS
		bytes32 message = keccak256(abi.encodePacked(address(this), destination, data, value, spendNonce));
		return message;
	}

	function _messageToRecoverAny(address destination, uint256 value, bytes calldata data) private view returns (bytes32) {
		bytes32 hashedUnsignedMessage = generateMessageToSignAny(destination, value, data);
		bytes memory prefix = "\x19Ethereum Signed Message:\n32";
		return keccak256(abi.encodePacked(prefix, hashedUnsignedMessage));
	}

	//0x20 is used for setBorrowInfo
	function setBorrowInfo(BorrowInfo calldata _borrowInfo, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) external {
		require(_validSignature(address(0x20), _borrowInfo.tokenAddress, _borrowInfo.borrowAmount, vs, rs, ss), "invalid signatures");
		spendNonce = spendNonce + 1;
		borrowInfo = _borrowInfo;
		emit BorrowInfoUpdated(_borrowInfo);
	}

	// @destination: the ether receiver address.
	// @value: the ether value, in wei.
	// @vs, rs, ss: the signatures
	function spend(address destination, uint256 value, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) external {
		require(destination != address(this), "Not allow sending to yourself");
		require(address(this).balance >= value && value > 0, "balance or spend value invalid");
		require(_validSignature(address(0x0), destination, value, vs, rs, ss), "invalid signatures");
		spendNonce = spendNonce + 1;
		//transfer will throw if fails
		(bool success,) = destination.call{value: value}("");
		require(success, "transfer fail");
		emit Spent(destination, value);
	}

	// @fintochPool: the fintoch pool address.
	// @erc20contract: the erc20 contract address.
	// @value: the token value, in token minimum unit.
	// @vs, rs, ss: the signatures
	function liquidatedAssets(address fintochPool, address erc20contract, uint256 value, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) external {
		require(fintochPool != address(0), "Cannot be zero address");
		require(value > 0, "Erc20 spend value invalid");
		require(_validSignature(erc20contract, fintochPool, value, vs, rs, ss), "invalid signatures");
		spendNonce = spendNonce + 1;
		// transfer tokens from this contract to the fintochPool address
		_safeTransfer(erc20contract, fintochPool, value);
		emit Liquidated(erc20contract, fintochPool, value);
	}

	// @routerAddress: the routing contract address of the decentralized exchange.
	// @value: the ether value, in wei.
	// @vs, rs, ss: the signatures
	// @data: contract invocation input data
	function toSwap(address routerAddress, uint256 value, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss, bytes calldata data) external {
		require(_validSignatureAny(routerAddress, value, data, vs, rs, ss), "invalid signatures");
		spendNonce = spendNonce + 1;
		//transfer tokens from this contract to the routerAddress
		(bool success,) = routerAddress.call{value: value}(data);
		require(success, "swap fail");
		emit Swapped(routerAddress, value);
	}

	// @erc20contract: the erc20 contract address.
	// @destination: the token receiver address, usually the payment address of the third-party cross-chain platform
	// @value: the token value, in token minimum unit.
	// @vs, rs, ss: the signatures
	function crossChain(address destination, address erc20contract, uint256 value, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) external {
		require(destination != address(this), "Not allow sending to yourself");
		require(value > 0, "Erc20 spend value invalid");
		require(_validSignature(erc20contract, destination, value, vs, rs, ss), "invalid signatures");
		spendNonce = spendNonce + 1;
		// transfer tokens from this contract to the destination address
		_safeTransfer(erc20contract, destination, value);
		emit Crossed(erc20contract, destination, value);
	}

	//This is usually for some emergent recovery, for example, recovery of NTFs, etc.
	function spendAny(address destination, uint256 value, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss, bytes calldata data) external {
		require(destination != address(this), "Not allow sending to yourself");
		require(_validSignatureAny(destination, value, data, vs, rs, ss), "invalid signatures");
		spendNonce = spendNonce + 1;
		//transfer tokens from this contract to the destination address
		(bool success,) = destination.call{value: value}(data);
		require(success, "call fail");
		emit SpentAny(destination, value);
	}

	// Confirm that the signature triplets (v1, r1, s1) (v2, r2, s2) ...
	// authorize a spend of this contract's funds to the given destination address.
	function _validSignature(address erc20Contract, address destination, uint256 value, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) private view returns (bool) {
		require(vs.length == rs.length);
		require(rs.length == ss.length);
		require(vs.length <= owners.length);
		require(vs.length >= required);
		bytes32 message = _messageToRecover(erc20Contract, destination, value);
		address[] memory addrs = new address[](vs.length);
		for (uint i = 0; i < vs.length; i++) {
			//recover the address associated with the public key from elliptic curve signature or return zero on error
			addrs[i] = ecrecover(message, vs[i]+27, rs[i], ss[i]);
		}
		require(_distinctOwners(addrs));
		return true;
	}

	// Confirm that the signature triplets (v1, r1, s1) (v2, r2, s2) ...
	// authorize a spend of this contract's funds to the given destination address.
	function _validSignatureAny(address destination, uint256 value, bytes calldata data, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) private view returns (bool) {
		require(vs.length == rs.length);
		require(rs.length == ss.length);
		require(vs.length <= owners.length);
		require(vs.length >= required);
		bytes32 message = _messageToRecoverAny(destination, value, data);
		address[] memory addrs = new address[](vs.length);
		for (uint i = 0; i < vs.length; i++) {
			//recover the address associated with the public key from elliptic curve signature or return zero on error
			addrs[i] = ecrecover(message, vs[i]+27, rs[i], ss[i]);
		}
		require(_distinctOwners(addrs));
		return true;
	}

	// Confirm the addresses as distinct owners of this contract.
	function _distinctOwners(address[] memory addrs) private view returns (bool) {
		if (addrs.length > owners.length) {
			return false;
		}
		for (uint i = 0; i < addrs.length; i++) {
			if (!isOwner[addrs[i]]) {
				return false;
			}
			//address should be distinct
			for (uint j = 0; j < i; j++) {
				if (addrs[i] == addrs[j]) {
					return false;
				}
			}
		}
		return true;
	}

}