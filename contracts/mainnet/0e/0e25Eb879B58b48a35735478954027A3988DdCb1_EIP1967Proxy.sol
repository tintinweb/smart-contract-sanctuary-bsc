/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: None
pragma solidity 0.8.7;

contract EIP1967Proxy {
	/* Modifiers */
	modifier onlyOwner() {
		require( msg.sender == _getProxyOwner() , "Restricted for owner");
		_;
	}

	/* Constructor */
	constructor(address _owner, address _lib) {
		_setProxyOwner(_owner);
		_setProxyLib(_lib);
	}
	
	/* Externals */
	function _changeProxyOwner(address _owner) external onlyOwner returns(bool) {
		_setProxyOwner(_owner);
		return true;
	}
	function _changeProxyLib(address _lib) external onlyOwner returns(bool) {
		_setProxyLib(_lib);
		return true;
	}
	function _getProxyOwner() public view returns (address addr) {
		assembly {
			addr := sload(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103)
		}
	}
	function _getProxyLib() public view returns (address addr) {
		assembly {
			addr := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
		}
	}
	
	/* Privates */
	function _setProxyOwner(address _owner) private {
		require( _owner != address(0) , "Owner need to have valid address");
		address oldOwner = _getProxyOwner();
		assembly {
			sstore(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103, _owner)
		}
		emit AdminChanged(oldOwner, _owner);
	}
	function _setProxyLib(address _lib) private {
		assembly {
			sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, _lib)
		}
		emit Upgraded(_lib);
	}
	
	/* Fallback */
	fallback() external payable {
		address libAddress = _getProxyLib();
		assembly {
			calldatacopy(0, 0, calldatasize())
			let result := delegatecall(gas(), libAddress, 0, calldatasize(), 0, 0)
			returndatacopy(0, 0, returndatasize())
			switch result case 0 {
				revert(0, returndatasize())
			}
			default {
				return(0, returndatasize())
			}
		}
	}

	/* Events */
	event Upgraded(address indexed implementation);
	event AdminChanged(address previousAdmin, address newAdmin);
}