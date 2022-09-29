/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

/**
 *Submitted for verification at BscScan.com on 2021-08-07
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

contract GrowPresale {
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
    }
    

    using SafeMath for uint256;
    uint public totalInvestors;
    uint public totalInvested;
    uint public lastUserId = 2;

    using Address for address;
   // IBEP20 public baseToken;
    IBEP20 public presaleToken;
   // IBEP20 private BUSD; 
    address public _owner;
    uint256 private _referToken =   300;
    uint256 private _liqudityToken =   200;
    
    uint256 private _salePrice = 100;

        mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;

    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);

    constructor(address _presaleToken) {
       // require(_baseToken != address(0) && _baseToken.isContract(), "PresaleSwap: Invalid token contract address");
        require(_presaleToken != address(0) && _presaleToken.isContract(), "PresaleSwap: Invalid token contract address");
      //  baseToken = IBEP20(_baseToken);
        presaleToken = IBEP20(_presaleToken);

        _owner = msg.sender;
        //owner = _ownerAddress;
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0)
        });
        users[msg.sender] = user;
        idToAddress[1] = msg.sender;
        userIds[1] = msg.sender;

       // owners = ownerAddress;  
        //BUSD = _BUSD;
    }

    function Deposit(uint investment) public payable
	{
	    presaleToken.transferFrom(msg.sender ,address(this), investment);
	//	emit Registration(msg.sender, referralId,investment);
    }

    function owner() public view  returns (address) {
        return _owner;
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function currentPrice() public view  returns (uint256) {
        return _salePrice;
    }

    function setPrice(uint256 newPrice) public onlyOwner  {
         require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _salePrice = newPrice;
     }

    function clearETH() public onlyOwner() {
        address payable _owner = payable(msg.sender);
        _owner.transfer(address(this).balance);
    }

    function transferOwnership(address newOwner) public onlyOwner{
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
     }

    function withdrawPresaleToken(address _recipient, uint256 _amount) external onlyOwner {
        require(presaleToken.transfer(_recipient, _amount), "PresaleSwap: Failed to transfer Presale Token");
    }

    	function registration(address _userAddress, address _referrerAddress) private {
        uint32 size;
        assembly {
            size := extcodesize(_userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: _referrerAddress,
            partnersCount: 0
        });
        users[_userAddress] = user;
        idToAddress[lastUserId] = _userAddress;
        users[_userAddress].referrer = _referrerAddress;
        userIds[lastUserId] = _userAddress;
        lastUserId++;
        users[_referrerAddress].partnersCount++;
        emit Registration(_userAddress, _referrerAddress, users[_userAddress].id, users[_referrerAddress].id);
    }


   function isUserExists(address _user) public view returns (bool) {
        return (users[_user].id != 0);
    }

    function buy(address _refer) payable public returns(bool){
        require(isUserExists(_refer),"Refereral user Not Exist");
        require(msg.value >= 0.1 ether,"Transaction recovery");
        require(msg.value <= 50 ether,"Transaction recovery");
        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(_salePrice);

       // _mint(_msgSender(),_token);
        if(_msgSender()!=_refer){
            
            uint refToken = _token.mul(_referToken).div(10000);
   //         uint burnToken = _token.mul(_burnToken).div(10000);
            //uint liqToken = _token.mul(_liqudityToken).div(10000);
       
         //   _burn(_msgSender(),burnToken);
            //transfer( _refer,refToken);
            require(presaleToken.transfer(_msgSender(), _token), "PresaleSwap: Failed to transfer Presale Token");
            require(presaleToken.transfer(_refer, refToken), "PresaleSwap: Failed to transfer Presale Token");
          //  transfer( owner(),liqToken);
        }
        registration(msg.sender, _refer);
        return true;
    }
}