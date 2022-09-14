/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that passes all calls to another contract using the EVM
 * instruction `call`.
 *
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/Proxy.sol
 */
abstract contract CallModifier {
    /**
     * @dev Passes the current call to `implementation`.
     */
    function _call(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := call(
                gas(),
                implementation,
                callvalue(),
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should call.
     */
    function _underlying() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _call(_underlying());
    }

    /**
     * @dev Fallback function that calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

/**
 * @dev This contract is going to take the administratorship
 * of the underlying contract.
 * Admin of this contract can call any function of the
 * underlying contract as admin.
 * Admin of this contract can renounce administratorship
 * of this contract to the underlying contract.
 */
contract AdminCallModifier is CallModifier {
    address public owner;
    mapping(address => bool) public whitelist;
    address public underlying;

    constructor (address underlying_) {
        owner = msg.sender;
        whitelist[owner] = true;
        underlying = underlying_;
    }

    /** @dev Change owner of this contract.
     * Change the function name if the 
     * underlying contract has the function of the same name.
    */
    function transferOwner(address to) external {
        require(msg.sender == owner);
        owner = to;
    }

    function setWhitelist(address caller, bool allow) public {
        require(msg.sender == owner);
        whitelist[caller] = allow;
    }

    function _underlying() internal view override returns (address) {
        return underlying;
    }

    /**
     * @dev Checks current msg.sender is this contract or from admin.
     * Change the function name if the
     * underlying contract has the function of the same name
     */
    function checkCaller() public view {
        require(whitelist[msg.sender]);
    }

    /**
     * @dev Only calls from this contract or from admin can fallback to underlying contract.
     */
    function _beforeFallback() internal view override {
        checkCaller();
    }
}