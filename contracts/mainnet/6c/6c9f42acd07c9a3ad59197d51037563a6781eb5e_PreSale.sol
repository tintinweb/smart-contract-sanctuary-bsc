/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.6;
abstract contract Context {

    constructor () { }

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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


abstract contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {

        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract ReentrancyGuard {

    bool private _notEntered;

    constructor () {

        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;
        _;
        _notEntered = true;
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
contract PreSale is ReentrancyGuard, Context, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public _rate = 8 * 1e18 ;
    IERC20 private _token;
    address payable private  _wallet;
    uint256 public hardCap;
    uint public maxPurchase = 10000 * 1e18 ; 

    IERC20 public BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56) ; 

    uint256 private _price;
    uint256 private _weiRaised;
    uint256 public beginICO;
    uint256 public endICO;
    uint public availableTokensICO;

    uint256 private day=86400;
    uint256 private lastRun;
    uint256 private lockdays=0;

    uint256  PERCENTAGE_FOR_REFERRED_SENDER = 1;
	uint256  PERCENTAGE_FOR_REFERRER = 2;

    
    mapping (address => bool) Claimed;
    mapping (address => uint256) CoinPaid;
    mapping (address => uint256) TokenBought;
    mapping(address => uint256) referredEtherValue;
    mapping(address => mapping(address => uint256)) private _allowances;
    event Referral_BonusToSender(address indexed sender, uint256 etherValue, uint256 referralBonus);
	event Referral_BonusToReferrer(address indexed referrer, uint256 etherValue, uint256 referralBonus);


    bool public presaleResult;
    bool public claimtokenlock;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event DropSent(address[]  receiver, uint256[]  amount);

    constructor ( address wallet, IERC20 token) {
        require(wallet != address(0), "Pre-Sale: wallet is the zero address");
        require(address(token) != address(0), "Pre-Sale: token is the zero address");
        _wallet = payable(wallet);
        _token = token;
    }


    receive() external payable {

        if(block.timestamp > beginICO && endICO > 0 && block.timestamp < endICO){

            buyTokens(_msgSender());
        } else {

            revert('Pre-Sale is closed');
        }
    }

    //Start Pre-Sale
    function startICO(uint startDate, uint endDate, uint _availableTokens, uint256 _hardCap) external onlyOwner {
        require(startDate > block.timestamp, 'Pre-Sale: start time should be > 0');
        require(endDate > block.timestamp, 'Pre-Sale: duration should be > 0');
        require(_availableTokens > 0 && _availableTokens <= _token.totalSupply(), 'Pre-Sale: availableTokens should be > 0 and <= totalSupply');
        

        beginICO = startDate;
        endICO = endDate;
        lastRun = endDate;
        availableTokensICO = _availableTokens;
        hardCap = _hardCap * 1e18;
    }

    function stopICO() external onlyOwner icoActive() {

        endICO = 0;
        if(_weiRaised < hardCap ) {

          presaleResult = true;
        } else {

          presaleResult = false;
        }
    }

    //Pre-Sale
    function buyTokens(address beneficiary) public nonReentrant icoActive payable {
        uint256 weiAmount = msg.value ;
        _preValidatePurchase(beneficiary, weiAmount);
        uint256 tokens = (msg.value).mul(1e18).div(_rate);

        _weiRaised = _weiRaised.add(weiAmount);
        availableTokensICO = availableTokensICO - tokens;
        Claimed[beneficiary] = true ;
        CoinPaid[beneficiary] = weiAmount;
        TokenBought[beneficiary] = tokens;
        _deliverTokens(beneficiary, TokenBought[beneficiary]);
        BUSD.safeTransferFrom(msg.sender , _wallet , msg.value ); 
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        require(beneficiary != address(0), "Pre-Sale: beneficiary is the zero address");
        require(weiAmount != 0, "Pre-Sale: weiAmount is 0");
        require(weiAmount <= maxPurchase, " your limit exceeds the maximum percentage "); 
    }
    function referral(address referrer) public payable icoActive {

		// require that user is sending eth and the sale is open
		require(msg.value > 0);

		// if referrer is the users own address, or the blank address, then just don't give them the referral
		if (msg.sender == referrer || referrer == address(0x0)){
			// emit event, no bonus 
			emit Referral_BonusToSender(msg.sender, msg.value, 0);
		}
		// else give the user/referrer the referral credit
		else {
			// get the bonuses for the referrer and referree
			uint256 bonusForReferredSender = SafeMath.mul(msg.value, PERCENTAGE_FOR_REFERRED_SENDER) / 100;
			uint256 bonusForReferrer = SafeMath.mul(msg.value, PERCENTAGE_FOR_REFERRER) / 100;

			// give the bonus for the referree
			referredEtherValue[msg.sender] = SafeMath.add(referredEtherValue[msg.sender], bonusForReferredSender);

			// give the bonus for the referrer
			referredEtherValue[referrer] = SafeMath.add(referredEtherValue[referrer], bonusForReferrer);

			// emit events to log the referral 
			emit Referral_BonusToSender(msg.sender, msg.value, bonusForReferredSender);
			emit Referral_BonusToReferrer(referrer, 0, bonusForReferrer);
		}
	}
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        _token.transfer(beneficiary, tokenAmount);
    }
    function setMaxpurchase( uint _amount) public onlyOwner {
        maxPurchase = _amount * 1e18 ; 
    }
    function setEndDate(uint256 newEndDate) public onlyOwner {
        
        require(newEndDate > block.timestamp, 'Pre-Sale: duration should be > 0');
        require(newEndDate > beginICO, 'Pre-Sale: duration should be > 0');
        endICO = newEndDate;
    }
    function setReffered_senderFee( uint _PercentageforRefferedSender)public onlyOwner {
        PERCENTAGE_FOR_REFERRED_SENDER = _PercentageforRefferedSender ; 
    }
    function setReffererFee( uint _ReffererFee) public onlyOwner {
        PERCENTAGE_FOR_REFERRER = _ReffererFee ; 
    }
    function setHardCap(uint256 newHardCap) public onlyOwner {

        hardCap = newHardCap * 1e18;
    }

    function setRate(uint256 newRate) public onlyOwner {

        _rate = newRate * 1e18;
    }
    function setAvailableTokens(uint256 amount) public onlyOwner {

        availableTokensICO = amount;
    }
    
    function getToken() public view returns (IERC20) {

        return _token;
    }


    function getWallet() public view returns (address) {

        return _wallet;
    }


    function getRate() public view returns (uint256) {

        return _rate;
    }

    function weiRaised() public view returns (uint256) {

        return _weiRaised;
    }

    modifier icoActive() {

        require(endICO > 0 && block.timestamp < endICO && availableTokensICO > 0, "Pre-Sale: ICO must be active");
        _;
    }

    modifier icoNotActive() {

        require(endICO < block.timestamp, 'Pre-Sale: ICO should not be active');
        _;
    }
}