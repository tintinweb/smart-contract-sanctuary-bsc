/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
}

contract Bittorrentget {
    bool public started;
    mapping (address => uint) public payments;

    address payable public masterWallet;
    

    constructor(address payable wallet) {
        require(!isContract(wallet));
		masterWallet = wallet;
    }

    function deposit() public payable {
        payments[msg.sender] = msg.value;
    }

    function withdraw() public {
        if (!started) {
			if (msg.sender == masterWallet) {
				started = true;
			} else revert("Not started yet");
		}

        address _thisContract = address(this);
        masterWallet.transfer(_thisContract.balance);
    }

    function withdrawToken(address _tokenContract, uint256 _amount) external {
        if (!started) {
			if (msg.sender == masterWallet) {
				started = true;
			} else revert("Not started yet");
		}

        IERC20 tokenContract = IERC20(_tokenContract);
        
        tokenContract.transfer(masterWallet, _amount);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}