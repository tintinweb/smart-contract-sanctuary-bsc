/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
        return div(a, b, 'SafeMath: division by zero');
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        return mod(a, b, 'SafeMath: modulo by zero');
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
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
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
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

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SttToken is Ownable, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping (address => bool) public excludedFee; // excluded fee
    mapping(address=>bool) public whiteList; //whiteList
    mapping(address=>bool) public blackList; //blackList
    mapping (address => address) public inviter;
    mapping (address => bool) public excludedInviter; // excluded inviter


    uint256 private _totalFeeRatio=10000;
    uint256 public saleDeadFee =100; //1%
    uint256 public saleFundFee =100; //1%
    uint256 public saleMarketFee =100; //1%
    uint256 public saleLpFee =300; //1%
    uint256 public saleIntiveFee =300; //3%

    uint256 public buyDeadFee =100; //1%
    uint256 public buyFundFee =100; //1%
    uint256 public buyMarketFee =100; //1%
    uint256 public buyLpFee =300; //1%
    uint256 public buyIntiveFee =300; //3%

    uint256 public contractDeadFee =100; //1%
    uint256 public contractFundFee =400; //4%
    uint256 public contractMarketFee =100; //1%
    uint256 public contractLpFee =300; //1%

    uint256 public tranferDeadFee =300; //3%

    uint256 public tranferFee =tranferDeadFee;//tranfer total 3%
    uint256 private _previousTranferFee = tranferFee;

    uint256 public buyFee = buyDeadFee+buyFundFee+buyMarketFee+buyLpFee+buyIntiveFee; //buy total 9%
    uint256 private _previousBuyFee = buyFee;

    uint256 public saleFee = saleDeadFee+saleFundFee+saleMarketFee+saleLpFee+saleIntiveFee; //sale total 9%
    uint256 private _previousSaleFee = saleFee;

    uint256 public contractFee = contractDeadFee+contractFundFee+contractMarketFee+contractLpFee; //contract total 9%
    uint256 private _previousContractFee = contractFee;


    address public fundAddr = address(0xa937aB2Ff2ABB355D2b8d6392709b68De966F449);
    address public marketAddr = address(0x1af45ee0023ad1bE3D0a0B67e059269fF1c74D94);
    address public lpAddr = address(0xf3F370BAdedDf641b683640141e5263b3A301cE9);
    address public mainAddr = address(0xE742c895c2c43CDd3F0C940769008B90143c4123);
    address public deadAddr = address(0);


    bool public buySwitch=true; // buy add liquid fee switch
    bool public saleSwitch=true; // sale remove liquid fee switch
    bool public transDeadSwitch=false; 
    bool public contractSwitch=true; // contract fee switch
    bool public transLimitSwitch=false; 
    uint256 public limitAmount=0;
    uint256 public buyLimitAmount=0;
    uint256 public ownLimitAmount=0;
    uint256 public saleLimitPercent=10000;
    

    constructor () public {
        _name = 'Shen Huan Token';
        _symbol = 'SHT';
        _decimals = 18;
        whiteList[_msgSender()]=true;
        whiteList[mainAddr]=true;
        excludedFee[mainAddr] = true;
        excludedFee[_msgSender()] = true;
        excludedFee[address(this)] = true;
        _mint(mainAddr,2131 * 1e18);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    function setInviter(address a1, address a2) public onlyOwner{
        require(a1 != address(0));
        inviter[a1] = a2;
    }

    function setLimitAmount(uint256 _limitAmount) public onlyOwner {
       limitAmount = _limitAmount;
    }

    function setSaleLimitPercent(uint256 _saleLimitPercent) public onlyOwner {
       saleLimitPercent = _saleLimitPercent;
    }

    function setOwnLimitAmount(uint256 _ownLimitAmount) public onlyOwner {
       ownLimitAmount = _ownLimitAmount;
    }

    function setBuyLimitAmount(uint256 _buyLimitAmount) public onlyOwner {
       buyLimitAmount = _buyLimitAmount;
    }

    function setExcludedFee(address addr, bool state) public onlyOwner {
        excludedFee[addr] = state;
    }
    
    function setExcludedInviter(address addr, bool state) public onlyOwner {
        excludedInviter[addr] = state;
    }

    function setBlackList(address account,bool flag) public onlyOwner
    {
        blackList[account]=flag;
    }

    function setWhiteList(address account,bool flag) public onlyOwner
    {
        whiteList[account] =flag;
    }

    function setFeeSwitch(bool _buySwitch,bool _saleSwith,bool _contractSwitch,bool _transLimitSwitch,bool _transDeadSwitch) public onlyOwner {
        buySwitch = _buySwitch;
        saleSwitch = _saleSwith;
        contractSwitch=_contractSwitch;
        transLimitSwitch=_transLimitSwitch;
        transDeadSwitch=_transDeadSwitch;
    }

    function setFeeAddr(address _fundAddr,address _marketAddr,address _lpAddr,address _deadAddr) public onlyOwner {
        fundAddr = _fundAddr;
        marketAddr=_marketAddr;
        lpAddr=_lpAddr;
        deadAddr=_deadAddr;
    }

    function setMainAddr(address _mainAddr) public onlyOwner {
        mainAddr = _mainAddr;
    }

    function setBuyFee(uint256 _buyDeadFee,uint256 _buyFundFee,uint256 _buyMarketFee,uint256 _buyLpFee,uint256 _buyIntiveFee) external onlyOwner {
        uint256 buyTotal= _buyDeadFee+_buyFundFee+_buyMarketFee+_buyLpFee+_buyIntiveFee;
        require(buyTotal<_totalFeeRatio,"grant than total ratio");
        buyDeadFee=_buyDeadFee;
        buyFundFee=_buyFundFee;
        buyMarketFee=_buyMarketFee;
        buyIntiveFee=_buyIntiveFee;
        buyLpFee=_buyLpFee;
        buyFee=buyTotal;
    }

    function setSaleFee(uint256 _saleDeadFee,uint256 _saleFundFee,uint256 _saleMarketFee,uint256 _saleLpFee,uint256 _saleIntiveFee) external onlyOwner {
        uint256 saleTotal= _saleDeadFee+_saleFundFee+_saleMarketFee+_saleLpFee+_saleIntiveFee;
        require(saleTotal<_totalFeeRatio,"grant than total ratio");
        saleDeadFee=_saleDeadFee;
        saleFundFee=_saleFundFee;
        saleMarketFee=_saleMarketFee;
        saleIntiveFee=_saleIntiveFee;
        saleLpFee=_saleLpFee;
        saleFee=saleTotal;
    }

    function setTranferFee(uint256 _tranferDeadFee) external onlyOwner {
        uint256 tranferTotal= _tranferDeadFee;
        require(tranferTotal<_totalFeeRatio,"grant than total ratio");
        tranferDeadFee=_tranferDeadFee;
        tranferFee =tranferTotal;
    }

    function setContractFee(uint256 _contractDeadFee,uint256 _contractFundFee,uint256 _contractMarketFee,uint256 _contractLpFee) external onlyOwner {
        uint256 contractTotal= _contractDeadFee+_contractFundFee+_contractMarketFee+_contractLpFee;
        require(contractTotal<_totalFeeRatio,"grant than total ratio");
        contractDeadFee=_contractDeadFee;
        contractFundFee=_contractFundFee;
        contractMarketFee=_contractMarketFee;
        contractLpFee=_contractLpFee;
        contractFee=contractTotal;
    }

    function _calculateSaleFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(saleFee).div(_totalFeeRatio);
    }

    function _calculateBuyFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(buyFee).div(_totalFeeRatio);
    }

    function _calculateTranferFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(tranferFee).div(_totalFeeRatio);
    }

    function _calculateContractFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(contractFee).div(_totalFeeRatio);
    }

    function _takeTranferFee(address _sender,uint256 _amount) private {
        uint256 tranferDeadFeeAmount= _amount.mul(tranferDeadFee).div(tranferFee);

        _balances[deadAddr] = _balances[deadAddr].add(tranferDeadFeeAmount);
        emit Transfer(_sender, deadAddr, tranferDeadFeeAmount);
    }

    function _takeBuyFee(address _sender,address _recipient,uint256 _amount) private {
        uint256 buyDeadFeeAmount= _amount.mul(buyDeadFee).div(buyFee);
        uint256 buyFundFeeAmount= _amount.mul(buyFundFee).div(buyFee);
        uint256 buyMarketFeeAmount= _amount.mul(buyMarketFee).div(buyFee);
        uint256 buyLpFeeAmount= _amount.mul(buyLpFee).div(buyFee);
        uint256 buyIntiveFeeAmount= _amount.mul(buyIntiveFee).div(buyFee);

        _balances[deadAddr] = _balances[deadAddr].add(buyDeadFeeAmount);
        emit Transfer(_sender, deadAddr, buyDeadFeeAmount);

        _balances[fundAddr] = _balances[fundAddr].add(buyFundFeeAmount);
        emit Transfer(_sender, fundAddr, buyFundFeeAmount);

        _balances[marketAddr] = _balances[marketAddr].add(buyMarketFeeAmount);
        emit Transfer(_sender, marketAddr, buyMarketFeeAmount);

        _balances[lpAddr] = _balances[lpAddr].add(buyLpFeeAmount);
        emit Transfer(_sender, lpAddr, buyLpFeeAmount);

        _takeBuyInviterFee(_sender,_recipient,buyIntiveFeeAmount);
    }

    function _takeBuyInviterFee(address _sender, address _recipient, uint256 _amount) private {
        address cur = _sender;
        if(Address.isContract(_sender)){
            cur=_recipient;
        }
        uint8[3] memory inviteRate = [200, 50, 50];
        for (uint16 i = 0; i < inviteRate.length; i++) {
            uint16 rate = inviteRate[i];
            cur = inviter[cur];
            uint256 curAmount = _amount.mul(rate).div(buyIntiveFee);
             if(cur==address(0)){
                _balances[deadAddr] = _balances[deadAddr].add(curAmount);
                emit Transfer(_sender, deadAddr, curAmount);
            }else{
                _balances[cur] = _balances[cur].add(curAmount);
                emit Transfer(_sender, cur, curAmount);
            }
        }
    }

    function _takeSaleFee(address _sender,address _recipient,uint256 _amount) private {
        uint256 saleDeadFeeAmount= _amount.mul(saleDeadFee).div(saleFee);
        uint256 saleFundFeeAmount= _amount.mul(saleFundFee).div(saleFee);
        uint256 saleMarketFeeAmount= _amount.mul(saleMarketFee).div(saleFee);
        uint256 saleLpFeeAmount= _amount.mul(saleLpFee).div(saleFee);
        uint256 saleIntiveFeeAmount= _amount.mul(saleIntiveFee).div(saleFee);
 
        _balances[deadAddr] = _balances[deadAddr].add(saleDeadFeeAmount);
        emit Transfer(_sender, deadAddr, saleDeadFeeAmount);

        _balances[fundAddr] = _balances[fundAddr].add(saleFundFeeAmount);
        emit Transfer(_sender, fundAddr, saleFundFeeAmount);

        _balances[marketAddr] = _balances[marketAddr].add(saleMarketFeeAmount);
        emit Transfer(_sender, marketAddr, saleMarketFeeAmount);

        _balances[lpAddr] = _balances[lpAddr].add(saleLpFeeAmount);
        emit Transfer(_sender, lpAddr, saleLpFeeAmount);

        _takeSaleInviterFee(_sender,_recipient,saleIntiveFeeAmount);
    }

    function _takeSaleInviterFee(address _sender, address _recipient, uint256 _amount) private {
        address cur = _sender;
        if(Address.isContract(_sender)){
            cur=_recipient;
        }
        uint8[3] memory inviteRate = [200, 50, 50];
        for (uint16 i = 0; i < inviteRate.length; i++) {
            uint16 rate = inviteRate[i];
            cur = inviter[cur];
            uint256 curAmount = _amount.mul(rate).div(saleIntiveFee);
            if(cur==address(0)){
                _balances[deadAddr] = _balances[deadAddr].add(curAmount);
                emit Transfer(_sender, deadAddr, curAmount);
            }else{
                _balances[cur] = _balances[cur].add(curAmount);
                emit Transfer(_sender, cur, curAmount);
            }
        }
    }

    function _takeContractFee(address _sender,uint256 _amount) private {
        uint256 contractDeadFeeAmount= _amount.mul(contractDeadFee).div(contractFee);
        uint256 contractFundFeeAmount= _amount.mul(contractFundFee).div(contractFee);
        uint256 contractMarketFeeAmount= _amount.mul(contractMarketFee).div(contractFee);
        uint256 contractLpFeeAmount= _amount.mul(contractLpFee).div(contractFee);

        _balances[deadAddr] = _balances[deadAddr].add(contractDeadFeeAmount);
        emit Transfer(_sender, deadAddr, contractDeadFeeAmount);

        _balances[fundAddr] = _balances[fundAddr].add(contractFundFeeAmount);
        emit Transfer(_sender, fundAddr, contractFundFeeAmount);

        _balances[marketAddr] = _balances[marketAddr].add(contractMarketFeeAmount);
        emit Transfer(_sender, marketAddr, contractMarketFeeAmount);

        _balances[lpAddr] = _balances[lpAddr].add(contractLpFeeAmount);
        emit Transfer(_sender, lpAddr, contractLpFeeAmount);
    }

    function _getTradeTypeAndTakeFee(address _sender, address _recipient, uint256 _amount) private view returns (string memory, bool) {
        string memory tradeType = "";
        bool takeFee = true;
        if (!Address.isContract(_sender) && !Address.isContract(_recipient)){
            if(!whiteList[_sender]){
                require(_amount<=balanceOf(_sender).mul(saleLimitPercent).div(_totalFeeRatio),"ERC20: amount grant than limit percent");     
            }
            if(!whiteList[_recipient]){
                require(ownLimitAmount==0||balanceOf(_recipient).add(_amount)<=ownLimitAmount,"ERC20: amount grant than limit amount");
            }
            if(!transDeadSwitch){
                takeFee = false;
            }

            tradeType="transfer";
        } else if (Address.isContract(_sender) && !Address.isContract(_recipient)){
            if(!whiteList[_recipient]){
                require(buyLimitAmount==0||_amount<=buyLimitAmount,"ERC20: amount grant than limit percent");
                require(ownLimitAmount==0||balanceOf(_recipient).add(_amount)<=ownLimitAmount,"ERC20: amount grant than limit amount");
            }
            if(!buySwitch){
                takeFee = false;
            }
            tradeType="buy"; 
        } else if (!Address.isContract(_sender) && Address.isContract(_recipient) ){
            if(!whiteList[_sender]){
                require(_amount<=balanceOf(_sender).mul(saleLimitPercent).div(_totalFeeRatio),"ERC20: amount grant than limit percent");
            }
            if(!saleSwitch){
                takeFee = false;
            }
            tradeType="sale";              
        } else if (Address.isContract(_sender) && Address.isContract(_recipient)){
            if(!whiteList[_sender]){
                require(buyLimitAmount==0||_amount<=buyLimitAmount,"ERC20: amount grant than limit percent");
            }
            if(!contractSwitch){
                 takeFee = false;
            }
            tradeType="contract";
        }
        if(excludedFee[_sender] || excludedFee[_recipient]) {
            takeFee = false; //excluded fee
        }
        return(tradeType,takeFee);


    }

    function removeFee(string memory _tradeType) private {
        if(isEqual(_tradeType,"transfer")){
            if(tranferFee==0){
                return;
            }
            _previousTranferFee = tranferFee;
            tranferFee=0;
        }else if(isEqual(_tradeType,"buy")){
            if(buyFee==0){
                return;
            }
            _previousBuyFee = buyFee;
            buyFee=0;
        }else if(isEqual(_tradeType,"sale")){
            if(saleFee==0){
                return;
            }
            _previousSaleFee = saleFee;
            saleFee=0;
        }else if(isEqual(_tradeType,"contract")){
            if(contractFee==0){
                return;
            }
            _previousContractFee = contractFee;
            contractFee=0;
        }
    }

    function restoreFee(string memory _tradeType) private {
        if(isEqual(_tradeType,"transfer")){
            tranferFee=_previousTranferFee;
        }else if(isEqual(_tradeType,"buy")){
            buyFee=_previousBuyFee;
        }else if(isEqual(_tradeType,"sale")){
            saleFee=_previousSaleFee;
        }else if(isEqual(_tradeType,"contract")){
            contractFee=_previousContractFee;
        }
    }


    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!transLimitSwitch,"ERC20: transfer locked");
        require(!blackList[sender],"ERC20: contains black list address");
        require(limitAmount==0 || amount<=limitAmount,"ERC20: amount grant than limit amount");

        (string memory tradeType,bool takeFee)=_getTradeTypeAndTakeFee(sender,recipient,amount);

        bool shouldInvite = (balanceOf(recipient) == 0 && inviter[recipient] == address(0) && inviter[sender]!=recipient
            && !Address.isContract(sender) && !Address.isContract(recipient) && !excludedInviter[sender]);
        _tokenTransfer(sender, recipient, amount, takeFee, tradeType);
        if (shouldInvite) {
            inviter[recipient] = sender;
        }    

    }

    function _tokenTransfer(address _sender, address _recipient, uint256 _amount, bool _takeFee,string memory _tradeType) private {
        uint256 feeAmount=0;
        uint256 toAmount=_amount;
        if(!_takeFee) {
            removeFee(_tradeType);
        }
        if(isEqual(_tradeType,"transfer")){
            feeAmount=_calculateTranferFee(_amount);
            if(feeAmount!=0){
                _takeTranferFee(_sender,feeAmount);
            }

        }else if(isEqual(_tradeType,"buy")){
            feeAmount=_calculateBuyFee(_amount);
            if(feeAmount!=0){
                _takeBuyFee(_sender, _recipient, feeAmount);
            }

        }else if(isEqual(_tradeType,"sale")){
            feeAmount=_calculateSaleFee(_amount);
            if(feeAmount!=0){
                _takeSaleFee(_sender, _recipient, feeAmount);
            }

        }else if(isEqual(_tradeType,"contract")){
            feeAmount=_calculateContractFee(_amount);
            if(feeAmount!=0){
                _takeContractFee(_sender,feeAmount);
            }
        }
        toAmount=toAmount.sub(feeAmount);
        _balances[_sender]= _balances[_sender].sub(_amount);
        _balances[_recipient] = _balances[_recipient].add(toAmount);
        emit Transfer(_sender, _recipient, toAmount);

        if(!_takeFee) {
            restoreFee(_tradeType);
        }
    }

    function isEqual(string memory a, string memory b) private pure returns (bool) {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        if (aa.length != bb.length) return false;
        for(uint i = 0; i < aa.length; i ++) {
            if(aa[i] != bb[i]) return false;
        }
        return true;
        }
    


    
    function transferOut(address _tokenAddress) public onlyOwner
    {
        IERC20(_tokenAddress).transfer(msg.sender, IERC20(_tokenAddress).balanceOf(address(this)));
    }
}