/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

pragma solidity ^0.8.7;

// SPDX-License-Identifier: Unlicensed
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

contract Ownable {
    address public _owner;

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }   

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }    
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
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

contract DY is IERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public _dividendTracker;

    mapping(address => uint256) private _rOwned;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isBlackList;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private _decimals; 
  
    uint256 public _sellFee;
    uint256 public _buyFee;
    uint256 public _buyTeamFee = 18;
    uint256 public _buyMarketFee = 18;
    uint256 public _buyDestroyFee = 24;   
    uint256 public _sellTeamFee = 18;
    uint256 public _sellMarketFee = 18; 
    uint256 public _sellDestroyFee = 24;   

    address private _destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address public _swapAddress;
    address public _teamAddress;
    address public _marketAddress;                     
    address public _UPancakePair;
    
    constructor(address swapAddress, address teamAddress, address marketAddress) {
        _name = "Big Fish";
        _symbol = "DY";
        _decimals = 6;

        _totalSupply = 100000000 * 10**_decimals;
        _buyFee = _buyTeamFee + _buyMarketFee + _buyDestroyFee;
        _sellFee = _sellTeamFee + _sellMarketFee +_sellDestroyFee;

        _owner = msg.sender;
        _swapAddress = swapAddress;
        _teamAddress = teamAddress;
        _marketAddress = marketAddress;
        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_swapAddress] = true;
        _isExcludedFromFee[_teamAddress] = true;
        _isExcludedFromFee[_marketAddress] = true;

        _rOwned[swapAddress] = _totalSupply;

        emit Transfer(address(0), _swapAddress, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }          
    
    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
    }                    

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);     
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }                             

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {

        _transfer(sender, recipient, amount);
       
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isBlackList(address account) public view returns (bool) {
        return _isBlackList[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount >= 0, "Transfer amount must be greater than 0");
        require(!_isBlackList[from] && !_isBlackList[to], "Black List!");

        bool takeFee = true;
 
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        if(_rOwned[from] == amount){
            amount = _rOwned[from] - 1;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        if (takeFee && (recipient == _UPancakePair || sender == _UPancakePair)) {
            if (recipient == _UPancakePair) { 
                _sellFee = _sellTeamFee + _sellMarketFee +_sellDestroyFee;           
                uint256 cAmount = tAmount.mul(_sellFee).div(1000);
                uint256 amount = tAmount.sub(cAmount);
                _rOwned[sender] = _rOwned[sender].sub(tAmount); 
                _rOwned[recipient] = _rOwned[recipient].add(amount);                
                emit Transfer(sender, recipient, amount); 

                _takeTransfer(
                    sender,
                    _teamAddress,
                    tAmount.div(1000).mul(_sellTeamFee)
                );

                _takeTransfer(
                    sender,
                    _marketAddress,
                    tAmount.div(1000).mul(_sellMarketFee)
                );

                _takeTransfer(
                    sender,
                    _destroyAddress,
                    tAmount.div(1000).mul(_sellDestroyFee)
                );
                
            }
            else {
                _buyFee = _buyTeamFee + _buyMarketFee + _buyDestroyFee;
                uint256 cAmount = tAmount.mul(_buyFee).div(1000);
                uint256 amount = tAmount.sub(cAmount);
                _rOwned[sender] = _rOwned[sender].sub(tAmount); 
                _rOwned[recipient] = _rOwned[recipient].add(amount);                
                emit Transfer(sender, recipient, amount);  

                _takeTransfer(
                    sender,
                    _teamAddress,
                    tAmount.div(1000).mul(_buyTeamFee)
                );

                _takeTransfer(
                    sender,
                    _marketAddress,
                    tAmount.div(1000).mul(_buyMarketFee)
                );

                _takeTransfer(
                    sender,
                    _destroyAddress,
                    tAmount.div(1000).mul(_buyDestroyFee)
                );
                
            }
        }
        else{
            _rOwned[sender] = _rOwned[sender].sub(tAmount);            
            _rOwned[recipient] = _rOwned[recipient].add(tAmount);
            emit Transfer(sender, recipient, tAmount);
        }
    }


    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _rOwned[to] = _rOwned[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }


    function changeFeeAddress(address UPancakePair, address teamAddress, address marketAddress) external onlyOwner {
        _UPancakePair = UPancakePair;
        _teamAddress = teamAddress;
        _marketAddress = marketAddress;             
    }

    function changeFee(uint256 buyTeamFee, uint256 buyMarketFee, uint256 buyDestroyFee, uint256 sellTeamFee, uint256 sellMarketFee, uint256 sellDestroyFee) external onlyOwner {    
        _buyTeamFee = buyTeamFee;
        _buyMarketFee = buyMarketFee;
        _buyDestroyFee = buyDestroyFee;
        _sellTeamFee  = sellTeamFee;
        _sellMarketFee = sellMarketFee;
        _sellDestroyFee = sellDestroyFee;
    }

    function changeBlackList(bool value, address account) external onlyOwner returns(bool) {
        _isBlackList[account] = value;
        return true; 
    }
    
}