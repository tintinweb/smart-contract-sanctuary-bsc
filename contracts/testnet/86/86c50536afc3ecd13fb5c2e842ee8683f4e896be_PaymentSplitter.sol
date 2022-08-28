/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

//SPDX-License-Identifier: MIT
/* 
A contract to Distribute the Payment as per Table given below:

60% to Main Wallet
03% to Development Team
12% to Marketing Team
01% To Owner
24% to Investor Contract which devide payment in multi wallet as per slab 3%, 2% and 1%

*/
pragma solidity 0.8.13;


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library Address {
    function isContract(address account) internal view returns (bool) {
 
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
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

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract PaymentSplitter is Ownable {
    event Received(address from, uint256 amount);
    event Withdraw(address to, uint256 amount);
    event WithdrawERC20(IERC20 indexed token, address to, uint256 amount);



    error PaymentFailed();
    error WrongShares();
    error WrongAddress();
    error NoBalance();
    error NotValidSender();

    struct Addresses {
        address addr1;
        address addr2;
        address addr3;
        address addr4;
        address addr5;
    }

    Addresses public addrs;

    uint256 public share1;
    uint256 public share2;
    uint256 public share3;
    uint256 public share4;
    uint256 public share5;

    constructor(
        address addr1_,
        address addr2_,
        address addr3_,
        address addr4_,
        address addr5_,
        uint256 share1_,
        uint256 share2_,
        uint256 share3_,
        uint256 share4_,
        uint256 share5_
    ) {
        if (addr1_ == address(0) || addr2_ == address(0) || addr3_ == address(0) || addr4_ == address(0) || addr5_ == address(0)) revert WrongAddress();
        if (share1_ + share2_ + share3_ + share4_ + share5_ != 100) revert WrongShares();
        if (share1_ == 0 || share2_ == 0 || share3_ == 0 || share4_ == 0 || share5_ == 0) revert WrongShares();

        addrs.addr1 = addr1_;
        addrs.addr2 = addr2_;
        addrs.addr3 = addr3_;
        addrs.addr4 = addr4_;
        addrs.addr5 = addr5_;
        share1 = share1_;
        share2 = share2_;
        share3 = share3_;
        share4 = share4_;
        share5 = share5_;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;

        if (balance == 0) revert NoBalance();

        address addr1 = addrs.addr1;
        address addr2 = addrs.addr2;
        address addr3 = addrs.addr3;
        address addr4 = addrs.addr4;
        address addr5 = addrs.addr5;

        uint256 addr1Amount = (balance * share1) / 100;
        uint256 addr2Amount = (balance * share2) / 100;
        uint256 addr3Amount = (balance * share3) / 100;
        uint256 addr4Amount = (balance * share4) / 100;
        uint256 addr5Amount = (balance * share5) / 100;

        (bool success1, ) = addr1.call{value: addr1Amount}("");
        (bool success2, ) = addr2.call{value: addr2Amount}("");
        (bool success3, ) = addr3.call{value: addr3Amount}("");
        (bool success4, ) = addr4.call{value: addr4Amount}("");
        (bool success5, ) = addr5.call{value: addr5Amount}("");

        if (!success1 || !success2 || !success3 || !success4 || !success5) revert PaymentFailed();

        emit Withdraw(addr1, addr1Amount);
        emit Withdraw(addr2, addr2Amount);
        emit Withdraw(addr3, addr3Amount);
        emit Withdraw(addr4, addr4Amount);
        emit Withdraw(addr5, addr5Amount);
    }

    function withdrawERC20(IERC20 token) external onlyOwner {
        uint256 balance = token.balanceOf(address(this));

        if (balance == 0) revert NoBalance();

        address addr1 = addrs.addr1;
        address addr2 = addrs.addr2;
        address addr3 = addrs.addr3;
        address addr4 = addrs.addr4;
        address addr5 = addrs.addr5;

        uint256 addr1Amount = (balance * share1) / 100;
        uint256 addr2Amount = (balance * share2) / 100;
        uint256 addr3Amount = (balance * share3) / 100;
        uint256 addr4Amount = (balance * share4) / 100;
        uint256 addr5Amount = (balance * share5) / 100;


        SafeERC20.safeTransfer(token, addr1, addr1Amount);
        SafeERC20.safeTransfer(token, addr2, addr2Amount);
        SafeERC20.safeTransfer(token, addr3, addr3Amount);
        SafeERC20.safeTransfer(token, addr4, addr4Amount);
        SafeERC20.safeTransfer(token, addr5, addr5Amount);

        emit WithdrawERC20(token, addr1, addr1Amount);
        emit WithdrawERC20(token, addr2, addr2Amount);
        emit WithdrawERC20(token, addr3, addr3Amount);
        emit WithdrawERC20(token, addr4, addr4Amount);
        emit WithdrawERC20(token, addr5, addr5Amount);
    }

    function changeAddr1(address newAddr_) public onlyOwner() {
        if (newAddr_ == address(0)) revert WrongAddress();
        addrs.addr1 = newAddr_;
    }

    function changeAddr2(address newAddr_) public onlyOwner() {
        if (newAddr_ == address(0)) revert WrongAddress();
        addrs.addr2 = newAddr_;
    }

    function changeAddr3(address newAddr_) public onlyOwner() {
        if (newAddr_ == address(0)) revert WrongAddress();
        addrs.addr3 = newAddr_;
    }

    function changeAddr4(address newAddr_) public onlyOwner() {
        if (newAddr_ == address(0)) revert WrongAddress();
        addrs.addr4 = newAddr_;
    }

    function changeAddr5(address newAddr_) public onlyOwner() {
        if (newAddr_ == address(0)) revert WrongAddress();
        addrs.addr5 = newAddr_;
    }

    function changeShare1(uint256 newShare_) public onlyOwner() {
        if (newShare_ == 0) revert WrongShares();
        if (newShare_ > 100) revert WrongShares();
        share1 = newShare_;
    }

    function changeShare2(uint256 newShare_) public onlyOwner() {
        if (newShare_ == 0) revert WrongShares();
        if (newShare_ > 100) revert WrongShares();
        share2 = newShare_;
    }

    function changeShare3(uint256 newShare_) public onlyOwner() {
        if (newShare_ == 0) revert WrongShares();
        if (newShare_ > 100) revert WrongShares();
        share3 = newShare_;
    }

    function changeShare4(uint256 newShare_) public onlyOwner() {
        if (newShare_ == 0) revert WrongShares();
        if (newShare_ > 100) revert WrongShares();
        share4 = newShare_;
    }

    function changeShare5(uint256 newShare_) public onlyOwner() {
        if (newShare_ == 0) revert WrongShares();
        if (newShare_ > 100) revert WrongShares();
        share5 = newShare_;
    }
}