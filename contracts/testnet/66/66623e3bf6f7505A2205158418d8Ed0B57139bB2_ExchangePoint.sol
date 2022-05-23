/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
}

contract Ownable {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    address private _owner;

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: newOwner is zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Ceo {
    address public ceoAddress;

    constructor() {
        ceoAddress = msg.sender;
    }

    modifier onlyCeoAddress() {
        require(ceoAddress == msg.sender, "CEO: caller is not the ceo");
        _;
    }

    function isCeo() public view returns (bool) {
        return msg.sender == ceoAddress;
    }

    function changeCeo(address _address) public onlyCeoAddress {
        require(_address != address(0), "CEO: newAddress is the zero address");
        ceoAddress = _address;
    }
}

contract BusinessRole is Ownable, Ceo {
    address[] private _businesses;

    modifier onlyManager() {
        require(
            isOwner() || isCeo() || isBusiness(),
            "BusinessRole: caller is not business"
        );
        _;
    }

    function isBusiness() public view returns (bool) {
        for (uint256 i = 0; i < _businesses.length; i++) {
            if (_businesses[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function getBusinessAddresses() public view returns (address[] memory) {
        return _businesses;
    }

    function setBusinessAddress(address[] memory businessAddresses)
        public
        onlyOwner
    {
        _businesses = businessAddresses;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        require(
            value <= oldAllowance,
            "SafeERC20: decreased allowance below zero"
        );
        uint256 newAllowance = oldAllowance.sub(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

contract TokenProvider is Ownable {
    using SafeMath for uint256;

    event SetTokens(address[] _address, address _from);
    event RemoveTokens(address[] _address, address _from);

    struct Token {
        bool existed;
        uint256 index;
    }

    mapping(address => Token) private tokenMap;
    address[] private tokenList;

    modifier isValidToken(address _token) {
        require(tokenMap[_token].existed, "Token: token is not approved");
        _;
    }

    function getTokenList() public view returns (address[] memory) {
        return tokenList;
    }

    function setTokens(address[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (!tokenMap[_tokens[i]].existed) {
                tokenList.push(_tokens[i]);
                tokenMap[_tokens[i]].existed = true;
                tokenMap[_tokens[i]].index = tokenList.length - 1;
            }
        }
        emit SetTokens(_tokens, msg.sender);
    }

    function unsetTokens(address[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (tokenMap[_tokens[i]].existed) {
                uint256 indexFiat = tokenMap[_tokens[i]].index;
                tokenList[indexFiat] = tokenList[tokenList.length - 1];
                tokenList.pop();
                tokenMap[_tokens[indexFiat]].index = indexFiat;
                delete tokenMap[_tokens[i]];
            }
        }
        emit RemoveTokens(_tokens, msg.sender);
    }

    function resetTokens() public onlyOwner {
        for (uint256 i = 0; i < tokenList.length; i++) {
            delete tokenMap[tokenList[i]];
        }
        emit RemoveTokens(tokenList, msg.sender);
        delete tokenList;
    }
}

contract Withdrawable is BusinessRole {
    function _withdraw(uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Withdrawable: Insufficent balance to withdraw (coin)"
        );
        if (amount > 0) {
            payable(ceoAddress).transfer(amount);
        }
    }

    function _withdrawToken(IERC20 erc20, uint256 amount) internal {
        require(
            erc20.balanceOf(address(this)) >= amount,
            "Withdrawable: Insufficent balance to withdraw (token)"
        );

        if (amount > 0) {
            erc20.transfer(ceoAddress, amount);
        }
    }

    function withdraw(
        uint256 amount,
        address[] memory erc20s,
        uint256[] memory amountErc20s
    ) public onlyOwner {
        _withdraw(amount);
        for (uint256 i = 0; i < erc20s.length; i++) {
            _withdrawToken(IERC20(erc20s[i]), amountErc20s[i]);
        }
    }
}

contract ExchangePoint is TokenProvider, Withdrawable {
    event DepositToken(address sender, address token, uint256 amount);

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    function depositToken(address token, uint256 _amount) public isValidToken(token) {
        IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
        emit DepositToken(msg.sender, address(token), _amount);
    }
}