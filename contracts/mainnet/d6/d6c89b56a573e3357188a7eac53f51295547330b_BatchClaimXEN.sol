/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract BatchClaimXEN {
	// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1167.md
	bytes miniProxy;			  // = 0x363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3;
    address private constant XEN = 0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e;
    address public immutable original;
	address public immutable deployer;
    address public miner;
	mapping (address=>uint) public countClaimRank;
	mapping (address=>uint) public countClaimMint;
	
	constructor() {
		miniProxy = bytes.concat(bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73), bytes20(address(this)), bytes15(0x5af43d82803e903d91602b57fd5bf3));
		original = address(this);
		deployer = msg.sender;
	}

	function batchClaimRank(uint times, uint term) external {
		bytes memory bytecode = miniProxy;
		address proxy;
		uint N = countClaimRank[msg.sender];
		for(uint i=N; i<N+times; i++) {
	        bytes32 salt = keccak256(abi.encodePacked(msg.sender, i));
			assembly {
	            proxy := create2(0, add(bytecode, 32), mload(bytecode), salt)
			}
			BatchClaimXEN(proxy).claimRank(term);
		}
		countClaimRank[msg.sender] = N+times;
	}

	function claimRank(uint term) external {
        miner = tx.origin;
		IXEN(XEN).claimRank(term);
	}

    function proxyFor(address sender, uint i) public view returns (address proxy) {
        bytes32 salt = keccak256(abi.encodePacked(sender, i));
        proxy = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                address(this),
                salt,
                keccak256(abi.encodePacked(miniProxy))
            )))));
    }

	function batchClaimMintReward(uint times) external {
		uint M = countClaimMint[msg.sender];
		uint N = countClaimRank[msg.sender];
		N = M+times < N ? M+times : N;
		for(uint i=M; i<N; i++) {
	        address proxy = proxyFor(msg.sender, i);
			BatchClaimXEN(proxy).claimMintRewardToMiner();
		}
		countClaimMint[msg.sender] = N;
	}

	function claimMintRewardToMiner() external {
		IXEN(XEN).claimMintRewardAndShare(miner, 100);
		selfdestruct(payable(miner));
	}

}

interface IXEN {
	function claimRank(uint term) external;
	function claimMintReward() external;
	function claimMintRewardAndShare(address other, uint256 pct) external;
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}