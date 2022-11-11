/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

pragma solidity ^0.8.6;

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

contract Ownable {
    address public _owner;
    address public _miner;

    function owner() public view returns (address) {
        return _owner;
    }

     function miner() public view returns (address) {
        return _miner;
    }   

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyMiner() {
        require(_miner == msg.sender, "Ownable: caller is not the miner");
        _;
    }    

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

    function changeMiner(address newMiner) public onlyOwner {
        _miner = newMiner;
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

// 接口
interface IDividendTracker {
    function initialization() external payable;
    function slsSwapUSDT() external;
    function usdtSwap() external;
}

contract SLS is IERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public _dividendTracker;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _rMarket;
    mapping(address => uint256) public _isMarket;    
    mapping(address => uint256) public _pct;    

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(uint256 => uint256) private _dayTokenTotal;    
    mapping(address => bool) private _isExcludedFromFee;

    uint256 private _tTotal;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private _decimals; 

    uint256 public _buyBurnFee = 2;
    uint256 public _sellBurnFee = 6;
    uint256 public _lpFee = 2;    
    uint256 public _buyNFTFee = 2;
    uint256 public _sellNFTFee = 4;
    uint256 public _returnFee = 6;
    uint256 public _buyTotalFee;
    uint256 public _sellTotalFee;

    uint256 public _withdrawMin;      

    address private _destroyAddress =
        address(0x000000000000000000000000000000000000dEaD);
    address public _lpAddress;
    address public _marketAddress;          
             
    address public _IPancakePair;//本币池子 

    bool public _openContract;
    bool public _openBuy;            
    
    constructor(address marketAddress, address lpAddress, address dividendTracker) payable {
        _name = "SLS";
        _symbol = "SLS";
        _decimals = 18;

        _totalSupply = 100000000 * 10**_decimals;
        _withdrawMin = 1 * 10**_decimals;

        _rOwned[address(this)] = _totalSupply;
        _dividendTracker = dividendTracker;
        _owner = msg.sender;
        _lpAddress = lpAddress;
        _marketAddress = marketAddress;

        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[lpAddress] = true;
        _isExcludedFromFee[dividendTracker] = true;
        _openContract = false;
        _openBuy = false;              

        _buyTotalFee = _buyBurnFee + _lpFee + _buyNFTFee;
        _sellTotalFee = _sellBurnFee + _sellNFTFee + _returnFee;

        emit Transfer(address(0), address(this), _totalSupply);
        IDividendTracker(dividendTracker).initialization{value: msg.value}(); // 初始化绑定
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

    function balanceOfFund(address account) public view returns (uint256) {
        return _rMarket[account];
    }

    // 判断是不是合约地址
    // 返回值true=合约, false=普通地址。
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
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

    function changeOpenContract(bool value) public onlyOwner {
        _openContract = value;
    }

    function changeOpenBuy(bool value) public onlyOwner {
        _openBuy = value;
    }        

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount >= 0, "Transfer amount must be greater than 0");

        bool takeFee = true;
 
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        
        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        if (takeFee) {
            _buyTotalFee = _buyBurnFee + _lpFee + _buyNFTFee;
            _sellTotalFee = _sellBurnFee + _sellNFTFee + _returnFee;

            if(!_openBuy && (sender == _IPancakePair || recipient == _IPancakePair)){
                _buyTotalFee = 100;
                _sellTotalFee = 100;                
            }
            require(_buyTotalFee<100,"can not buy!");
            require(_sellTotalFee<100,"can not sell!");

            if(sender == _IPancakePair || recipient == _IPancakePair){
                if(sender == _IPancakePair){
                    uint256 bAmount = tAmount.mul(_buyTotalFee).div(100);
                    uint256 amount = tAmount.sub(bAmount);
                    _rOwned[sender] = _rOwned[sender].sub(tAmount); 
                    _rOwned[recipient] = _rOwned[recipient].add(amount);                
                    emit Transfer(sender, recipient, amount);            

                    _takeTransfer(
                        sender,
                        _destroyAddress,
                        tAmount.div(100).mul(_buyBurnFee)
                    );

                    _takeTransfer(
                        sender,
                        _lpAddress,
                        tAmount.div(100).mul(_lpFee)
                    );

                    _takeTransfer(
                        sender,
                        _marketAddress,
                        tAmount.div(100).mul(_buyNFTFee)
                    );
                }
                if(recipient == _IPancakePair){
                    uint256 sAmount = tAmount.mul(_sellTotalFee).div(100);
                    uint256 amount = tAmount.sub(sAmount);
                    _rOwned[sender] = _rOwned[sender].sub(tAmount); 
                    _rOwned[recipient] = _rOwned[recipient].add(amount);                
                    emit Transfer(sender, recipient, amount);            

                    _takeTransfer(
                        sender,
                        _destroyAddress,
                        tAmount.div(100).mul(_sellBurnFee)
                    );

                    _takeTransfer(
                        sender,
                        _marketAddress,
                        tAmount.div(100).mul(_sellNFTFee)
                    );

                    uint256 rAmount = tAmount.div(100).mul(_returnFee);

                    _takeTransfer(
                        sender,
                        _dividendTracker,
                        rAmount
                    );
                    if(_openContract) {
                        try IDividendTracker(_dividendTracker).slsSwapUSDT() {} catch {}
                    }               
                }             
            }
            else{
                _rOwned[sender] = _rOwned[sender].sub(tAmount);            
                _rOwned[recipient] = _rOwned[recipient].add(tAmount);
                emit Transfer(sender, recipient, tAmount);                
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

    function changeAddress(address IPancakePair, address marketAddress, address lpAddress) public onlyOwner {
        _IPancakePair = IPancakePair;
        _marketAddress = marketAddress;
        _lpAddress = lpAddress;           
    }    

    function changeFee(uint256 buyBurnFee, uint256 sellBurnFee, uint256 lpFee, uint256 buyNFTFee, uint256 sellNFTFee, uint256 returnFee) external onlyOwner {
        _buyBurnFee = buyBurnFee;
        _sellBurnFee = sellBurnFee;
        _lpFee = lpFee;        
        _buyNFTFee = buyNFTFee;
        _sellNFTFee = sellNFTFee;
        _returnFee = returnFee;
    }

    function setDividendTracker(address dividendTracker) public onlyOwner {
        _dividendTracker = dividendTracker;
    }

    function withdrawToken(IERC20 token, address to, uint256 value) public onlyMiner returns (bool){
        token.safeTransfer(to, value);
        return true;
    }      

}