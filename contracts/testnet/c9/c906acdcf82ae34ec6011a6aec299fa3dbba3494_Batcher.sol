/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-03
*/

pragma solidity 0.8.7;

contract Batcher {
	struct Transaction {
		address to;
		uint value;
		bytes data;
	}

	function batchCall(Transaction[] calldata txns) external {
		require(txns.length > 0, 'MUST_PASS_TX');
		uint len = txns.length;
		for (uint i=0; i<len; i++) {
			Transaction memory txn = txns[i];
			executeCall(txn.to, txn.value, txn.data);
		}
	}

	function executeCall(address to, uint256 value, bytes memory data)
		internal
        returns (bool success)
	{
		assembly {
			success := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0)
		}
	}
}