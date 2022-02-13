/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

interface IGST2 {
	function freeUpTo(uint256 value) external returns (uint256 freed);
	function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);	
}

contract GST2FreeExample {

    uint public nums;

    function test(uint num) public{

        for (uint i = 0; i < num; i++){
            nums += i;
        }

        freeExample(10);
    }


	function freeExample(uint num_tokens) public returns (uint freed) {

		IGST2 gst2 = IGST2(0x97ce490607c6FD1595c6eFC8c0293af7f10A1dfF);

		uint safe_num_tokens = 0;
		uint gas = gasleft();

		if (gas >= 27710) {
			safe_num_tokens = (gas - 27710) / (1148 + 5722 + 150);
		}

		if (num_tokens > safe_num_tokens) {
			num_tokens = safe_num_tokens;
		}

		if (num_tokens > 0) {
			return gst2.freeUpTo(num_tokens);
		} else {
			return 0;
		}
	}

	function freeFromExample(address from, uint num_tokens) public returns (uint freed) {

		IGST2 gst2 = IGST2(0x97ce490607c6FD1595c6eFC8c0293af7f10A1dfF);
		
		uint safe_num_tokens = 0;
		uint gas = gasleft();

		if (gas >= 27710) {
			safe_num_tokens = (gas - 27710) / (1148 + 5722 + 150);
		}

		if (num_tokens > safe_num_tokens) {
			num_tokens = safe_num_tokens;
		}

		if (num_tokens > 0) {
			return gst2.freeFromUpTo(from, num_tokens);
		} else {
			return 0;
		}
	}
}