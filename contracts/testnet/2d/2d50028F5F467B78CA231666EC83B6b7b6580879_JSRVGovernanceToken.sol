// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


abstract contract BaseToken {
    event TokenCreated(
        address indexed owner,
        address indexed token,
        uint256 version
    );
}

interface iBlacklist {
    function getBlacklist(address _address, address _contract) external view returns (uint256 is_blacklisted);
}

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract JSRVGovernanceToken is IERC20, Ownable, BaseToken, Pausable, ReentrancyGuard {
    using Address for address payable;

    struct HolderData {
        uint256[4] _pendingTokens;
        uint256[4] _eligibleTokens;
        uint256[4] _profitShare;
        uint256[4] _tokensRedeemed;
    }

    mapping(address => mapping(uint256 => HolderData)) private _holder;
    mapping(address => uint256) private _holderLastUpdated;
    mapping(address => uint256) private _holderLastRedeemed;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(uint256 => uint256) public _totalSoldTokens;
    mapping(uint256 => uint256) public _totalEligibleTokens;
    mapping(uint256 => uint256) public _eligibleProfitShare;
    mapping(uint256 => uint256) public _activeProfitShare;


    address public blacklistContract;

    uint256 public constant VERSION = 1;

    string private _name;
    string private _symbol;
    string public TokenType = "JSRV_Governance_Token";
    uint8 private _decimals;
    uint256 private _totalSupply;
    uint256 private _totalSold;
    uint256[] public _rate;
    uint256[] public _threshold;
    uint256 public _recycleRate;

    uint256 minted = 0;

    uint256 public _tokenPayout;
    uint256 private _previousTokenPayout = _tokenPayout;

    uint256 public _profitShareMax;

    uint256 public _minPurchase;
    uint256 public _maxPurchase;
    uint256 public _maxHold;
    uint256 public _purchaseCutOff;
    uint256 public _profitShareStart;
    uint256 public _profitSharePeriod;

    bool recycleAllowed = false;


    event Received(address _Sender, uint256 _Amount);
    event Mint(address _Sender, uint256 _Amount);
    event RecycleMint(address _Sender, uint256 _Amount);
    event RefundSent(address _Sender, uint256 _Amount);
    event IncreaseAllowance(address _Sender, address _Spender, uint256 _AddedValue);
    event DecreaseAllowance(address _Sender, address _Spender, uint256 _SubtractedValue);
    event TransferEvent(address _Sender, address _Recipient, uint256 _Amount);
    event TransferFromEvent(address _Sender, address _Recipient, uint256 _Amount);
    event BlacklistAddressChanged(address _PrevAddr, address _BlacklistAddress_);
    event SetNewRate(uint256[] _NewRate);
    event SetNewRecycleRate(uint256 _NewRecycleRate);
    event SetNewThreshold(uint256[] _NewThresholdRate);
    event SetNewMinPurchase(uint256 _SetNewMinPurchase);
    event SetNewMaxPurchase(uint256 _SetNewMaxPurchase);
    event SetNewMaxHold(uint256 _SetNewMaxHold);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    constructor(
        string[2] memory tokenDetails_,
        uint256 totalSupply_,
        uint8 decimals_,
        uint256[4] memory rate_,
        uint256[3] memory threshold_,
        address[2] memory addresses_,
        uint256[8] memory limits_
    ) payable {
        require(threshold_[0] + threshold_[1] + threshold_[2] == totalSupply_, "Invalid threshold amounts");
        _name = tokenDetails_[0];
        _symbol = tokenDetails_[1];
        _decimals = decimals_;
        _totalSupply = totalSupply_;

        _rate = rate_;
        _threshold = threshold_;
        _recycleRate = rate_[3];

        _tokenPayout = limits_[0];
        _profitShareMax = limits_[1];
        _minPurchase = limits_[2];
        _maxPurchase = limits_[3];
        _maxHold = limits_[4];
        _purchaseCutOff = limits_[5];
        _profitShareStart = limits_[6];
        _profitSharePeriod = limits_[7] * 1 hours;

        transferOwnership(addresses_[0]);

        _tOwned[address(this)] = _totalSupply;

        blacklistContract = addresses_[1];

        emit TokenCreated(
            owner(),
            address(this),
            VERSION
        );

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
        return _tOwned[account];
    }

    function toggleRecycle() public onlyOwner {
        recycleAllowed = !recycleAllowed;
    }

    function allowance(address owner, address spender)
        public
        view
        override whenNotPaused()
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual whenNotPaused()
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        emit IncreaseAllowance(msg.sender, spender, addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual whenNotPaused()
        returns (bool)
    {
        require(_allowances[_msgSender()][spender]>0, "ERC20: decreased allowance below zero");
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        emit DecreaseAllowance(msg.sender, spender, subtractedValue);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        override whenNotPaused()
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
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

    function transfer(address recipient, uint256 amount)
        public
        override whenNotPaused()
        returns (bool)
    {
        require(iBlacklist(blacklistContract).getBlacklist(msg.sender, address(this)) == 0, 'You are blacklisted!');
        require(amount + balanceOf(msg.sender) <= _maxHold, "You are trying to hold too many tokens");
        emit Transfer(_msgSender(), recipient, amount);
        _tOwned[recipient] = _tOwned[recipient] + amount;
        _tOwned[msg.sender] = _tOwned[msg.sender] - amount;

        updateData(1, [uint256(0),0,0,0], amount);

        emit TransferEvent(msg.sender, recipient, amount);

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override whenNotPaused() returns (bool) {
        require(iBlacklist(blacklistContract).getBlacklist(msg.sender, address(this)) == 0, 'You are blacklisted!');
        require(_allowances[sender][_msgSender()] > 0, "ERC20: transfer amount exceeds allowance");
        require(amount + balanceOf(msg.sender) <= _maxHold, "You are trying to hold too many tokens");
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()]-amount
        );
        emit Transfer(sender, recipient, amount);
        _tOwned[recipient] = _tOwned[recipient] + amount;
        _tOwned[sender] = _tOwned[sender] - amount;

        updateData(1, [uint256(0),0,0,0], amount);

        emit TransferFromEvent(sender, recipient, amount);

        return true;
    }

    function _mint(uint256 _amount) public payable nonReentrant {
        require(_totalSold < _totalSupply, "All sold out");
        require(_amount >= _minPurchase && _amount <= _maxPurchase, "You need to buy the right amounts");
        require(_amount + balanceOf(msg.sender) <= _maxHold, "You are trying to hold too many tokens");
        uint256[4] memory roundAmount = [uint256(0),0,0,0];
        uint256[3] memory roundFee;
        uint256 remainAmount = 0;

        (roundAmount[0], roundFee[0], remainAmount) = getRates(0,_amount);
        _totalSold = _totalSold + roundAmount[0];

        (roundAmount[1], roundFee[1], remainAmount) = getRates(1,remainAmount);
        _totalSold = _totalSold + roundAmount[1];

        (roundAmount[2], roundFee[2], remainAmount) = getRates(2,remainAmount);
        _totalSold = _totalSold + roundAmount[2];

        require(msg.value >= (roundFee[0] + roundFee[1] + roundFee[2]), "Not enough value added");

        if(msg.value > (roundFee[0] + roundFee[1] + roundFee[2])) {
            refundExcessiveFee(((roundFee[0] + roundFee[1] + roundFee[2]) - msg.value));
        }

        require(_totalSold <= _totalSupply, "Minting too much");

        updateData(0, roundAmount, 0);

        transfer(msg.sender, roundAmount[0] + roundAmount[1] + roundAmount[2]);

        emit Mint(msg.sender, roundAmount[0] + roundAmount[1] + roundAmount[2]);

    }

    function getCurrentRound() public view returns(uint256 currentRound) {

        if(block.timestamp < _profitShareStart) {
            currentRound = 0;
        } else {
            currentRound = ((block.timestamp - _profitShareStart) / _profitSharePeriod) + 1;
        }

        return currentRound;
    }

    function updateData(uint8 updateType, uint256[4] memory addAmount, uint256 subAmount) internal {
        HolderData storage holder;
        uint256 lastChecked = _holderLastUpdated[msg.sender];
        uint256 currentRound = getCurrentRound();
        uint256 remain = subAmount;

        for(uint256 i = lastChecked; i < currentRound; i++) {
            holder = _holder[msg.sender][i];

            for(uint256 j = 0; j < 4; j++) {

                if(holder._pendingTokens[j] > 0) {
                    holder._eligibleTokens[j] = holder._eligibleTokens[j] + holder._pendingTokens[j];
                    holder._pendingTokens[j] = 0;
                }

                if(_totalSoldTokens[i] > 0 && holder._eligibleTokens[j] > 0) {
                    holder._profitShare[j] = holder._eligibleTokens[j] * 1000 / _totalEligibleTokens[i];
                } else {
                    holder._profitShare[j] = 0;
                }
            }
        }

        if(block.timestamp > (_purchaseCutOff + (currentRound * _profitSharePeriod))) {
            holder = _holder[msg.sender][currentRound + 1];
        } else {
            holder = _holder[msg.sender][currentRound];
        }

        if(updateType == 0) {
            for(uint256 i = 0; i < 4; i++) {
                if(addAmount[i] > 0){
                    holder._pendingTokens[i] = holder._pendingTokens[i] + addAmount[i];
                    _tOwned[msg.sender] = _tOwned[msg.sender] + addAmount[i];
                }
            }
        } else if(updateType == 1) {
            if(remain > 0) {
                for(uint256 i = 0; i < 4; i++) {
                    if(remain > 0){
                        if(remain >= holder._eligibleTokens[i]) {
                            remain = remain - holder._eligibleTokens[i];
                            holder._eligibleTokens[i] = 0;
                        } else {
                            holder._eligibleTokens[i] = holder._eligibleTokens[i] - remain;
                            remain = 0;
                        }
                    } else {
                        break;
                    }
                }
            }

            if(remain > 0) {
                for(uint256 i = 0; i < 4; i++) {
                    if(remain > 0){
                        if(remain >= holder._pendingTokens[i]) {
                            remain = remain - holder._pendingTokens[i];
                            holder._pendingTokens[i] = 0;
                        } else {
                            holder._pendingTokens[i] = holder._pendingTokens[i] - remain;
                            remain = 0;
                        }
                    } else {
                        break;
                    }
                }
            }

            _tOwned[msg.sender] = _tOwned[msg.sender] - subAmount;
        }

        _holderLastUpdated[msg.sender] = currentRound;
    }

    function calcProfitShareClaim() public view returns(uint256 redeemTokens, uint256 profitShare) {
        uint256 currentRound = getCurrentRound();
        require(_holderLastRedeemed[msg.sender] < (currentRound - 1), "Nothing to claim");
        HolderData memory holder;

        for(uint256 i = _holderLastRedeemed[msg.sender]; i < currentRound; i++) {
            holder = _holder[msg.sender][i];

            if(_activeProfitShare[i] == 1){
                for(uint256 j = 0; j < 4; j++){
                    uint256 tempProfitShare = 0;
                    uint256 tempRedeemTokens = 0;
                    if((holder._eligibleTokens[j] + holder._pendingTokens[j]) > 0) {
                        tempProfitShare = (_eligibleProfitShare[i] * holder._profitShare[j] / 1000);
                        tempRedeemTokens = tempProfitShare * _rate[j];

                        profitShare = profitShare + tempProfitShare;
                        redeemTokens = redeemTokens + tempRedeemTokens;
                    }
                }
            } else {
                break;
            }
        }

        return(redeemTokens, profitShare);
    }

    function redeemProfitShare() public {
        uint256 currentRound = getCurrentRound();
        require(_holderLastRedeemed[msg.sender] < (currentRound - 1), "Nothing to claim");
        HolderData storage holder;
        uint256 redeemTokens = 0;
        uint256 profitShare = 0;
        updateData(0, [uint256(0),0,0,0], 0);

        for(uint256 i = _holderLastRedeemed[msg.sender]; i < currentRound; i++) {
            holder = _holder[msg.sender][i];

            if(_activeProfitShare[i] == 1){
                for(uint256 j = 0; j < 4; j++){
                    uint256 tempProfitShare = 0;
                    uint256 tempRedeemTokens = 0;
                    if(holder._eligibleTokens[j] > 0) {
                        tempProfitShare = (_eligibleProfitShare[i] * holder._profitShare[j] / 1000);
                        tempRedeemTokens = tempProfitShare * _rate[j];

                        profitShare = profitShare + tempProfitShare;
                        redeemTokens = redeemTokens + tempRedeemTokens;
                    }
                }

                _holderLastRedeemed[msg.sender] == (i);
            } else {
                break;
            }
        }

        require(redeemTokens <= balanceOf(msg.sender), "You don't have enough tokens");
        require(profitShare <= address(this).balance, "Not enought funds to withdraw");

        payable(msg.sender).transfer(profitShare);
        transfer(address(this), redeemTokens);

        _holderLastRedeemed[msg.sender] = currentRound - 1;
    }

    function depositProfitShare(uint256 _round, uint256 _active) public payable onlyOwner {
        require(_activeProfitShare[_round] == 0, "Round is active");
        _eligibleProfitShare[_round] = _eligibleProfitShare[_round] + msg.value;
        _activeProfitShare[_round] = _active;
    }

    function _setNewRecycleRate(uint256 _newRecycleRate) public onlyOwner {
        _recycleRate = _newRecycleRate;

        emit SetNewRecycleRate(_newRecycleRate);
    }

    function setNewRate(uint256[] memory _newRate) public onlyOwner {
        _rate = _newRate;

        emit SetNewRate(_newRate);
    }

    function setNewThreshold(uint256[] memory _newThreshold) public onlyOwner {
        _threshold = _newThreshold;

        emit SetNewThreshold(_newThreshold);
    }

    function setNewMinPurchase(uint256 _newMinPurchase) public onlyOwner {
        _minPurchase = _newMinPurchase;

        emit SetNewMinPurchase(_newMinPurchase);
    }

    function setNewMaxPurchase(uint256 _newMaxPurchase) public onlyOwner {
        _maxPurchase = _newMaxPurchase;

        emit SetNewMaxPurchase(_newMaxPurchase);
    }

    function setNewMaxHold(uint256 _newMaxHold) public onlyOwner {
        _maxHold = _newMaxHold;

        emit SetNewMaxHold(_newMaxHold);
    }

    function _recycleMint(uint256 _amount) public payable {
        require(_totalSold >= _totalSupply, "Recycle not yet available");
        require(balanceOf(address(this)) > 0, "There are no tokens to recycle");
        require(recycleAllowed,"Recycling of tokens not allowed");
        require(msg.value == _recycleRate * _amount, "You need to send enough");

        updateData(0, [uint256(0),0,0, _amount], 0);

        transfer(msg.sender, _amount);

        emit RecycleMint(msg.sender, _amount);
    }

    function getRates(uint256 _round, uint256 _amount) internal view returns(uint256 , uint256 , uint256) {
        if(_totalSold >= _threshold[_round]) {
            return(0, 0, _amount);
        } else {
            if((_totalSold + _amount) <= _threshold[_round]) {
                return(_amount, (_amount / _rate[_round]), 0);
            } else {
                return((_threshold[_round] - _totalSold), ((_threshold[_round] - _totalSold) / _rate[_round]), (_amount - (_threshold[_round] - _totalSold)));
            }
        }
    }

    function refundExcessiveFee(uint256 _amount) internal {
      payable(msg.sender).sendValue(_amount);

      emit RefundSent(msg.sender, _amount);
    }

    function setBlacklistAddress(address blacklistAddress_) external onlyOwner {
        address prevAddr = blacklistContract;

        blacklistContract = blacklistAddress_;

        emit BlacklistAddressChanged(prevAddr, blacklistAddress_);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
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
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}