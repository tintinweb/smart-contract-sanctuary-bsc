/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns(uint8);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}
contract presale is Context, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 private _token;
    address private _preOwner;
    address private _owner;
    uint256 private _tokenValue;

    mapping(address=>bool) public listOfBlacklistAddress;

    event BlacklistAddress(
        address userAddress,
        address owner
    );
    event unBlacklistAddress(
        address userAddress,
        address owner
    );

    event OwnerAddressUpdate(
        address newOwnerAddress,
        address oldOwnerAddress
    );

    event TokenTransfer(
        address tokenBuyer,
        address tokenSeller,
        uint256 tokenAmount
    );

    event TokenValueUpdate(
        uint256 tokenValue,
        address owner
    );

    event TokenWithdraw(
        address owner,
        uint256 amount
    );

    modifier isBlacklistAddress(
       address _buyerAddress
    )
    {
       require(!listOfBlacklistAddress[_buyerAddress],"black Address not allowed");
       _;
    }

    modifier isContractEnoughToken(
       uint256 _buyingAmount
    )
    {
      uint256 tokenAmount =  _calculatingTokenTransfer(_buyingAmount); 
      require(_token.balanceOf(address(this)) >= tokenAmount,"not enough token");
      _;
    }
    modifier onlyAdmin(){
        require((_owner == _msgSender())||(_preOwner == _msgSender()), "Function called from non admin wallet.");
        _;
    }

    modifier priceGreaterThanZero(
        uint256 _price
    ) 
    {
        require(_price > 0, "Price cannot be 0");
        _;
    }

    modifier zeroAddressNotAllowed(
        address _address
    )
    {
        require(_address != address(0),"zero address not allowed");
        _;
    }
    constructor(
        uint256 tokenValue_, 
        IERC20 token_
    )
    {
        require(address(token_) != address(0), "Crowdsale: token is the zero address");
        _token = token_;
        _owner = _msgSender();
        _preOwner = _owner;
        _tokenValue = tokenValue_ * 1000000000; 

    }

    receive() payable external {}

    function addBlacklistAddress(
        address _userAddress
    ) external
      onlyAdmin()
      zeroAddressNotAllowed(_userAddress)
    {   
        require(listOfBlacklistAddress[_userAddress] == true, "User is already Blacklisted");
        listOfBlacklistAddress[_userAddress] = true;
        emit BlacklistAddress(_userAddress, _owner);
    }

    function RemoveBlacklistAddress(
        address _userAddress
    ) external
      onlyAdmin()
      zeroAddressNotAllowed(_userAddress)
    {
        require(listOfBlacklistAddress[_userAddress] == false, "User is not Blacklisted");
        listOfBlacklistAddress[_userAddress] = false;
        emit unBlacklistAddress(_userAddress, _owner);
    }

    function TransferOwnership(
        address owner_
    ) external 
      onlyAdmin()
      zeroAddressNotAllowed(_owner)
    {
        _owner = owner_;
        emit OwnerAddressUpdate(owner_, msg.sender);
    }
        
    function updatePrice(
        uint256 tokenValue_
    ) external
      onlyAdmin()
      priceGreaterThanZero(tokenValue_)
    {
       _tokenValue = tokenValue_ * 1000000000;
       emit TokenValueUpdate(_tokenValue, _owner);
    }

    function withdrawToken(
        uint256 _tokenAmount
    )
       external
       onlyAdmin()
       priceGreaterThanZero(_tokenAmount)
    {
       _token.transfer(_owner,_tokenAmount); 
       emit TokenWithdraw(_owner, _tokenAmount);
    }

    function withdrawBNB(
        uint256 _amount
    ) external
      onlyAdmin()
    {
        _amountTransfer(_owner, _amount);
    }

    function _amountTransfer(
        address _tokenSeller,
        uint256 _buyAmount
    ) internal
    {
        (bool success,)  = _tokenSeller.call{value: _buyAmount}("");
        require(success, "refund failed");
    }

    function buyToken() 
      external 
      payable
      nonReentrant
      isBlacklistAddress(msg.sender)
      priceGreaterThanZero(msg.value)
      isContractEnoughToken(msg.value) 
    {   
        uint256 weiAmount = msg.value;
       uint256 tokenAmount =  _calculatingTokenTransfer(weiAmount); 
       _token.transfer(msg.sender, tokenAmount); 

        _amountTransfer(_owner, msg.value); 
        emit TokenTransfer(msg.sender, _owner, tokenAmount);
    }

    function _calculatingTokenTransfer(uint256 _amount) 
       internal
       view
       returns(uint256)
    {   
        uint256 dividedAmount = _tokenValue.div(1000000000);
        uint256 tokenAmount = _amount.mul(dividedAmount);
        return tokenAmount;
    }

    function rate() public view returns(uint256){
        return _tokenValue;
    }

    function changeToken(IERC20 token_) public onlyAdmin {
        _token = token_;
    }
    
    function owner() public view returns(address){
        return _owner;
    }
    
}