/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SanwichArbitrage {
    bytes4 private constant _TOKEN_BALANCE_OF_CALL_SELECTOR = 0x70a08231;

    uint256 public v1;

    // 0x0a398278054aeb97af4acd46a2c94ad856294873cf598f928060d4dc55a4ee073bcb342b3a68d38406
    function bar (bytes memory data) public view returns(uint256 v, address token, address user) {
        assembly {
            v := and(mload(add(data, 1)), 0xff)
            token := mload(add(data,21))
            user := mload(add(data,41))
        }
    }

    function foo (bytes memory data) external view returns(uint _b) {
        (uint256 v, address _token, address _user) = bar(data);
        _b = getTokenBalance(_token, _user);
    }

    function _foo (bytes memory data) external {
        (uint256 v, address _token, address _user) = bar(data);
        v1 = getTokenBalance(_token, _user);
    }

    function foo2 (address token, address user) external view returns(uint _b) {
        _b = getTokenBalance(token, user);
    }

    function foo3 (bytes memory data) external view returns(uint _b) {
        (uint256 v, address _token, address _user) = bar(data);
        _b = getTokenBalance2(_token, _user);
    }

    function foo4 (bytes memory data, address __token, address __user) external view returns(uint _b) {
        (uint256 v, address _token, address _user) = bar(data);
        _b = getTokenBalance(_token, _user);
    }

    function foo5 (bytes memory data, address __token, address __user)  external view returns(uint _b) {
        (uint256 v, address _token, address _user) = bar(data);
        _b = getTokenBalance(__token, __user);
    }
    

    function getTokenBalance2(address _token, address _user) public view returns (uint256) {
        return IERC20(_token).balanceOf(_user);
    }

    function bar2(bytes memory data, address __token, address __user) public view returns (bool, bool) {
        (uint256 v, address _token, address _user) = bar(data);
        return (_token == __token, _user == __user);
    }

    function getTokenBalance(address tokenAddr, address userAddr) internal view returns (uint _balance) {
        assembly {
                function reRevert() {
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }
                let emptyPtr := mload(0x40)
                mstore(emptyPtr, _TOKEN_BALANCE_OF_CALL_SELECTOR)
                mstore(add(emptyPtr,0x04),userAddr)
                if iszero(staticcall(gas(), tokenAddr, emptyPtr, 0x24, emptyPtr, 0x20)) {
                    reRevert()
                }
                _balance := mload(emptyPtr)
            }
    }
}