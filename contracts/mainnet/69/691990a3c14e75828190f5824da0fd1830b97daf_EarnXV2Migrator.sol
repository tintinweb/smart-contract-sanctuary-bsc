/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



interface IERC20 {

    function balanceOf(address who) external view returns (uint256 balance);

    function allowance(address owner, address spender) external view returns (uint256 remaining);

    function transfer(address to, uint256 value) external returns (bool success);

    function approve(address spender, uint256 value) external returns (bool success);

    function transferFrom(address from, address to, uint256 value) external returns (bool success);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() public whenNotPaused onlyOwner {
        paused = true;
        emit Pause();
    }

    function unpause() public whenPaused onlyOwner {
        paused = false;
        emit Unpause();
    }
}



contract EarnXV2Migrator is Ownable, Pausable {
    using SafeERC20 for IERC20;
    using Address for address;

    mapping (address => bool) public blocklist;

    address private tokenPool;
    address private oldToken;
    address private newToken;
    uint256 public blocked;

    constructor(address _tokenPool, address _oldToken, address _newToken) {
        tokenPool = _tokenPool;
        oldToken = _oldToken;
        newToken = _newToken;
    }


    function poolAddress() external view virtual returns (address) {
        return tokenPool;
    }

    function oldTokenAddress() external view virtual returns (address) {
        return oldToken;
    }

    function newTokenAddress() external view virtual returns (address) {
        return newToken;
    }

    function switchPool(address _tokenPool) public onlyOwner {
        tokenPool = _tokenPool;
    }

    function changeOldToken(address _oldToken) public onlyOwner {
        oldToken = _oldToken;
    }

    function changeNewToken(address _newToken) public onlyOwner {
        newToken = _newToken;
    }

    function receiveEther() public payable {
        revert();
    }

    function swap() public {
        uint256 _amount = IERC20(oldToken).balanceOf(_msgSender());
        require(_amount > 0,"No balance of Old EarnX tokens");
        _swap(_amount);
    }

    function _swap(uint256 _amount) internal {
        IERC20(oldToken).safeTransferFrom(address(_msgSender()), tokenPool, _amount);
        if (blocklist[_msgSender()]) {
            blocked += _amount;
        } else {
            IERC20(newToken).safeTransferFrom(tokenPool, address(_msgSender()), _amount / 100000);
        }
        emit Swapped(_amount);
    }

    function blockAddress(address _address, bool _state) external onlyOwner returns (bool) {
        blocklist[_address] = _state;
        return true;
    }

    function rescue(address to) external payable onlyOwner {
        require(payable(to).send(address(this).balance));
    }

    function rescueToken(address tokenAddress, address to) external onlyOwner {
        uint256 amount = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).safeTransfer(to,amount);
    }

    event Swapped(uint256 indexed amount);
}