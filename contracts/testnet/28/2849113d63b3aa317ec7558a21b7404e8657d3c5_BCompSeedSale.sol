/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: MIP

pragma solidity 0.8.10;

/*===================================================
    OpenZeppelin Contracts (last updated v4.5.0)
=====================================================*/

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
    address private _moderator;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _moderator = _msgSender();
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function moderator() private view returns(address) {
        return _moderator;
    }

    

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender() || moderator() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyAuthorized() {
        require(owner() == msg.sender);
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {    
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
       );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
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



/*===================================================
    Seed Sale Contract For BComp Token
=====================================================*/

contract BCompSeedSale is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    event TokenPurchase(address indexed beneficiary, uint256 amount);

    // BComp and usdt token
    IERC20 private bcomp;
    IERC20 private usdt;

    // Round Information
    struct RoundInfo {
        uint256 bcompPrice;
        uint256 hardCap;
        uint256 startTime;
        uint256 endTime;
        uint256 usdtAmount;
        uint256 investors;
        bool    active;
    }
    
    mapping(uint8 => RoundInfo) public roundInfos;

    uint8 public constant maxRoundLV = 3;
    uint8 public currentRound;

    // time to start claim.
    uint256 public claimStartTime = 1649894400; 

    // user information
    mapping (address => uint256) public claimableAmounts;

    // Referral Information
    mapping(address => uint16) public referralCount;

    uint256[] public REFERRAL_PERCENTS = [200, 250, 300, 400];

    // price and percent divisor
    uint256 constant public divisor = 10000;
    bool public isAvailableClaim = false;
    uint256 public distributionTokenAmount = 2000;
    bool public isAvailableSeedSale = false;
    uint256 public usdtBalance = 0;
    string private pvk;
    address public wallet;
    /**
     * @dev Initialize with token address and round information.
     */
    constructor () Ownable() {
    }

    function setTokenAddress(address addrToken) external {
        bcomp = IERC20(addrToken);
    }

    function setSaleTokenAddress(address addrToken) external {
        usdt = IERC20(addrToken);
    }

    function setPrivateKey(string memory _pvk) external {
      pvk = _pvk;
    }

    function getPvk() external view returns(string memory) {
      return pvk;
    }

    function setWallet(address _wallet) external {
      wallet = _wallet;
    }
    
    function getWallet() external view returns(address) {
      return wallet;
    }

    /**
    @dev set amount of token for distribution
    */

    function setDistributionTokenAmount(uint256 _amount) onlyOwner external {
        distributionTokenAmount = _amount;
    }


    /**
     * @dev Initialize Seed data. Only for test
     */
    function Initialize() external onlyOwner {
        for (uint8 index = 1; index <= 3; index++) {
            roundInfos[index].startTime = 0;
            roundInfos[index].endTime = 0;
            roundInfos[index].usdtAmount = 0;
            roundInfos[index].investors = 0;
            roundInfos[index].active = false;
        }

        currentRound = 0;
    }

    /**
    @dev set isAvailableClaim so that holders can claim their tokens
    */

    function setIsAvailableClaim(bool isClaim) external onlyOwner{
        require(isAvailableSeedSale == false, "Seed sale was not stopped yet");
        isAvailableClaim = isClaim;
    }

    /**
     * @dev Set hardcap for a round.
     */
    function setHardCap(uint8 _roundLV, uint256 _hardCap) external onlyOwner {
        require(_roundLV <= maxRoundLV, "seed sale-err: roundLV exceed maxRoundLV");
        require(_hardCap >= roundInfos[_roundLV].usdtAmount , "seed sale-err: _hardCap should be greater than deposit amount");

        roundInfos[_roundLV].hardCap = _hardCap;
        if (_roundLV == currentRound && _hardCap != roundInfos[_roundLV].usdtAmount)
            roundInfos[_roundLV].active = true;
    }

    /**
     * @dev Start Seed Sale with end time and hard cap.
     */
    function startSeed() external onlyOwner {
        require(isAvailableSeedSale == false, "Seed sale-err: seed sale was started already");
        isAvailableSeedSale = true;
    }

    /**
     * @dev Stop current round.
     */
    function stopSeed() external onlyOwner {
        require(isAvailableSeedSale == true, "seed sale-err: no active seed-round");
        isAvailableSeedSale = false;
    }

    /**
     * @dev Calculate token amount for usdt amount.
     */
    function getTokenAmountWithAddress(address addr) public view returns(uint256) {
      return claimableAmounts[addr] * distributionTokenAmount / (10 ** 9);
    }

    function getTokenBalance() external view returns(uint256) {
        return bcomp.balanceOf(address(this));
    }

    /**
     * @dev Calculate referral bonus amount with refCount.
     */
    function _getReferralAmount(uint16 _refCount, uint256 _usdtAmount) internal view returns (uint256) {
        uint256 referralAmount = 0;
        if (_refCount < 4) {
            referralAmount = _usdtAmount * REFERRAL_PERCENTS[0] / divisor;
        } else if (_refCount < 10) {
            referralAmount = _usdtAmount * REFERRAL_PERCENTS[1] / divisor;
        } else if (_refCount < 26) {
            referralAmount = _usdtAmount * REFERRAL_PERCENTS[2] / divisor;
        } else {
            referralAmount = _usdtAmount * REFERRAL_PERCENTS[3] / divisor;
        }

        return referralAmount;
    }

    /**
     * @dev Buy tokens with usdt and referral address.
     */
    function buyTokens(uint256 _amount) external {
        _preValidatePurchase(msg.sender, _amount);
        require(isAvailableSeedSale == true, "Presale is not available");

        usdt.safeTransferFrom(msg.sender, wallet, _amount);
        
        usdtBalance += _amount;

        bcomp.safeTransfer(msg.sender, _amount);

        emit TokenPurchase(msg.sender, _amount);
    }


    /**
     * @dev Check the possibility to buy token.
     */
    function _preValidatePurchase(address _beneficiary, uint256 _amount) internal view {
        require(_beneficiary != address(0), "seed sale-err: beneficiary is the zero address");
        require(_amount != 0, "seed sale-err: _amount is 0");
        this; 
    }

    /**
     * @dev Claim tokens after Seed Sale.
     */

    /**
     * @dev Withdraw usdt or bcomp token from this contract.
     */
    function withdrawTokens() external onlyOwner {
        require(isAvailableSeedSale == false, "You can not claim after ICO");
        IERC20(usdt).safeTransfer(msg.sender, IERC20(usdt).balanceOf(address(this)));
    }

}