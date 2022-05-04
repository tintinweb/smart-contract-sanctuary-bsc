pragma solidity ^0.8.9;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./Interfaces/IDex.sol";
import "./Interfaces/IStruct.sol";

interface ILPLockerFactory{
    function lockLP(
        address _lpAddress,
        uint256 _amount,
        uint256 _unlockDate,
        address _lpOwner
    ) external payable returns (bool);
}

interface IPresaleFactory {
    function addUserContribution(address _user, address _presaleAddress) external;
}

contract Presale is ReentrancyGuard, Initializable, IStruct {
    using Address for address payable;

    mapping(address => Contributions) private _contributions;
    mapping(address => UserVesting) private usersVesting;
    mapping(address => bool) private _isWhitelisted;

    struct Contributions {
        uint256 weiContribution;
        uint256 tokensPurchased;
        bool claimed;
    }

    struct UserVesting {
        uint256 tokensWithdrawn;
        uint256 lastCycleClaimed;
    }

    struct TokenInfo {
        IERC20Metadata token;
        string name;
        string symbol;
        uint8 decimals;
        uint256 totSupply;
    }

    TokenInfo private tokenInfo;

    address public pair;
    address public presaleFactory;
    string private utilsLink;

    MembershipInfo public membershipInfo;

    modifier onlyPresaleFactory() {
        require(msg.sender == presaleFactory);
        _;
    }

    modifier onlyPresaleCreator() {
        require(msg.sender == presaleCreator);
        _;
    }

    enum Status { NOT_STARTED, STARTED, FAILED, FILLED }
    enum Result { PENDING, CANCELLED, FINALIZED }

    Result public result;

    PresaleInfo private presaleInfo;
    RoundsTimer public roundsTimer;

    uint256 public fundsRaised;
    uint256 public tokensSold;
    uint256 public tokensClaimed;
    uint256 public finalizeTax;
    uint256 public presaleFinalizedTimestamp;
    bool public whitelistEnabled;
    address payable public presaleCreator;

    ListingInfo private listingInfo;
    InvestorsVesting private investorsVesting;

    event TokensPurchased(
        address user,
        uint256 weiAmount,
        uint256 tokensAmount
    );
    event ContributionWithdrawn(address user, uint256 weiAmount);
    event TokensClaimed(address user, uint256 tokensAmount);

    function initialize(PresaleInfo calldata _presaleInfo, ListingInfo calldata _listingInfo,InvestorsVesting calldata _investorsVesting, RoundsTimer calldata _roundsTimer,  
        MembershipInfo calldata _membershipInfo, bool _whitelistEnabled, address payable _presaleCreator, address _token, string calldata _utilsLink, uint256 _finalizeTax) public initializer  returns (bool) {

        presaleFactory = msg.sender;
        presaleInfo = PresaleInfo(
            _presaleInfo.presaleRate,
            _presaleInfo.minPurchase,
            _presaleInfo.maxPurchase,
            _presaleInfo.softCap,
            _presaleInfo.hardCap,
            _presaleInfo.startDate,
            _presaleInfo.endDate
        );

        if (_investorsVesting.vestingEnabled) {
            investorsVesting.vestingEnabled = true;
            setInvestorsVesting(
                _investorsVesting.vestingFirstPercentage,
                _investorsVesting.vestingCycle,
                _investorsVesting.vestingTokensPerCyclePercentage
            );
        }
        utilsLink = _utilsLink;

        listingInfo.router = IRouter(_listingInfo.router);
        listingInfo.liquidityLockTime = _listingInfo.liquidityLockTime;
        listingInfo.listingRate = _listingInfo.listingRate;
        listingInfo.liquidityPercentage = _listingInfo.liquidityPercentage;
        listingInfo.LPLockerFactory = _listingInfo.LPLockerFactory;
        roundsTimer = _roundsTimer;
        whitelistEnabled = _whitelistEnabled;
        presaleCreator = _presaleCreator;
        finalizeTax = _finalizeTax;
        membershipInfo = _membershipInfo;
        tokenInfo = TokenInfo(IERC20Metadata(_token), IERC20Metadata(_token).name(), IERC20Metadata(_token).symbol(),IERC20Metadata(_token).decimals(), IERC20Metadata(_token).totalSupply());
        result = Result.PENDING;
        return true;
    }

    function setInvestorsVesting(
        uint256 _vestingFirstPercentage,
        uint256 _vestingCycle,
        uint256 _vestingTokensPerCyclePercentage
    ) internal {
        require(
            _vestingFirstPercentage < 100 &&
                _vestingTokensPerCyclePercentage < 100 &&
                _vestingFirstPercentage + _vestingTokensPerCyclePercentage <= 100,
            "First release for presale and Percent token release each cycle must <= 100%"
        );
        require( _vestingCycle >= 1 days && _vestingCycle <= 31 days,"Vesting period each cycle must be > 1 day and <= 31 days");
        investorsVesting.vestingFirstPercentage = _vestingFirstPercentage;
        investorsVesting.vestingCycle = _vestingCycle;
        investorsVesting.vestingTokensPerCyclePercentage = _vestingTokensPerCyclePercentage;
    }

    function getTimeStamp() public view returns (uint256){ 
        return block.timestamp;
    }

    function checkCurrentRound() public view returns(uint256){
        uint256 timePassed = block.timestamp - presaleInfo.startDate;
        if(timePassed <= roundsTimer.round1Timer){
            if(whitelistEnabled) return 1;
            else return 2;
        }
        else if(timePassed > roundsTimer.round1Timer && timePassed <= roundsTimer.round2Timer) return 2;
        else return 3;
    }

    function checkCurrentStatus() public view returns (Status output) {
        if (block.timestamp >= presaleInfo.startDate && block.timestamp < presaleInfo.endDate && result == Result.PENDING) {
            if (fundsRaised < presaleInfo.hardCap) return Status.STARTED;
            else if (fundsRaised == presaleInfo.hardCap) return Status.FILLED;
        } else if (block.timestamp >= presaleInfo.endDate && fundsRaised < presaleInfo.softCap)
            return Status.FAILED;
        else if (block.timestamp >= presaleInfo.endDate && fundsRaised >= presaleInfo.softCap)
            return Status.FILLED;
    }

    function buyTokens() external payable nonReentrant {
        require( checkCurrentStatus() == Status.STARTED, "Presale must be started");
        uint256 currentRound = checkCurrentRound();
        if(currentRound == 1) require(_isWhitelisted[msg.sender], "Only whitelisted users can partecipate");
        else if(currentRound == 2){
            require(IERC20(membershipInfo.membershipToken).balanceOf(msg.sender) >= membershipInfo.minMembershipBalance, "You must hold minMembershipBalance to partecipate in this round");
        }
        require(msg.sender != presaleCreator, "Presale creator can't buy tokens");
        buyTokensBNB(msg.sender, msg.value);
        IPresaleFactory(presaleFactory).addUserContribution(msg.sender, address(this));
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return (weiAmount * presaleInfo.presaleRate) / 10**18;
    }

    function _preValidateBNBPurchase(address beneficiary, uint256 weiAmount) internal view { 
        require( beneficiary != address(0), "Presale: beneficiary is the zero address" );
        require( weiAmount != 0, "Presale: weiAmount is 0");
        require( weiAmount >= presaleInfo.minPurchase, "have to send at least: minPurchase");
        require( _contributions[beneficiary].weiContribution + weiAmount <= presaleInfo.maxPurchase, "can't buy more than: maxPurchase" );
        require( (fundsRaised + weiAmount) <= presaleInfo.hardCap, "Hard Cap reached");
    }

    function buyTokensBNB(address beneficiary, uint256 weiAmount) internal { 
        _preValidateBNBPurchase(beneficiary, weiAmount);
        uint256 tokensAmt = _getTokenAmount(weiAmount);
        fundsRaised += weiAmount;
        _contributions[beneficiary].weiContribution += weiAmount;
        _contributions[beneficiary].tokensPurchased += tokensAmt;
        tokensSold += tokensAmt;
        emit TokensPurchased(beneficiary, weiAmount, tokensAmt);
    }

    function withdrawContribution() external nonReentrant { 
        require( checkCurrentStatus() == Status.FAILED || result == Result.CANCELLED, "Presale not cancelled yet" );
        uint256 toWithdraw = _contributions[msg.sender].weiContribution;
        uint256 tokensPurchased = _contributions[msg.sender].tokensPurchased;
        _contributions[msg.sender].weiContribution = 0;
        _contributions[msg.sender].tokensPurchased = 0;
        tokensSold -= tokensPurchased;
        payable(msg.sender).sendValue(toWithdraw);
        emit ContributionWithdrawn(msg.sender, toWithdraw);
    }
    
    function finalizePresale() external onlyPresaleCreator { 
        require(checkCurrentStatus() == Status.FILLED && result == Result.PENDING, "Presale has not been filled" );
        result = Result.FINALIZED;

        uint256 bnbForPresaleCreator = (( fundsRaised *  (100 - listingInfo.liquidityPercentage)) / 100);
        uint256 bnbForLiquidity = fundsRaised - bnbForPresaleCreator;
        uint256 bnbForFee = bnbForPresaleCreator * finalizeTax / 100;
        bnbForPresaleCreator -= bnbForFee;
        
        uint256 tokensForLiquidity = (listingInfo.listingRate * bnbForLiquidity / 10**18);

        // Check if a pair already exist, if not, create the pair
        address get_pair;
        uint256 lpAmount;
        get_pair = IFactory(listingInfo.router.factory()).getPair(address(tokenInfo.token),listingInfo.router.WETH() );
        if (get_pair == address(0)) {
            pair = IFactory(listingInfo.router.factory()).createPair(address(tokenInfo.token),listingInfo.router.WETH() );
        } else {
            pair = get_pair;
            // Check if the pair already hold WBNB,if yes, rebalance the pool
            IERC20 WBNB = IERC20(listingInfo.router.WETH());
            uint256 wbnbBalance = WBNB.balanceOf(pair);
            if(wbnbBalance > 0){
                uint256 tokens_to_rebalance = (wbnbBalance * listingInfo.listingRate / 10**18) ;
                tokenInfo.token.transfer(pair, tokens_to_rebalance);
                IPair(pair).sync();
            }
        }

        tokenInfo.token.approve(address(listingInfo.router), tokensForLiquidity);
        (,, lpAmount) = listingInfo.router.addLiquidityETH{value: bnbForLiquidity}(
            address(tokenInfo.token),
            tokensForLiquidity,
            tokensForLiquidity - (tokensForLiquidity * 10 / 100),
            bnbForLiquidity - (bnbForLiquidity * 10/100),
            address(this),
            block.timestamp
        );

        // take BNB and tokens fees
        payable(presaleFactory).sendValue(bnbForFee);

        // send BNB to presale creator
        if (bnbForPresaleCreator > 0) presaleCreator.sendValue(bnbForPresaleCreator);

        IERC20(pair).approve(listingInfo.LPLockerFactory, lpAmount);
        require(ILPLockerFactory(listingInfo.LPLockerFactory).lockLP(pair,lpAmount,listingInfo.liquidityLockTime + block.timestamp,presaleCreator),"Failed to lock LP");

        // burn remaining tokens
        uint256 tokensToBurn = tokenInfo.token.balanceOf(address(this)) - tokensSold;
        try tokenInfo.token.transfer(address(0xdead), tokensToBurn) {} catch {}

        presaleFinalizedTimestamp = block.timestamp;
    }

    function cancelPresale() external onlyPresaleCreator {
        require(result == Result.PENDING, "Presale should be pending");
        result = Result.CANCELLED;
        tokenInfo.token.transfer(presaleCreator, tokenInfo.token.balanceOf(address(this)));
    }

    function checkContribution(address addr) public view returns (uint256, uint256 tokensToClaim, bool){
        if(_contributions[addr].claimed) return ( _contributions[addr].weiContribution, 0, _contributions[addr].claimed);
        if( _contributions[addr].weiContribution == 0) return ( _contributions[addr].weiContribution, 0, _contributions[addr].claimed);

        uint256 tokensRemainingDenominator = tokensSold - tokensClaimed;

        if(tokensRemainingDenominator == 0){
            tokensToClaim = 0;
        }
        else{
            tokensToClaim = (tokenInfo.token.balanceOf(address(this))  * _contributions[addr].tokensPurchased) / tokensRemainingDenominator;   
        }
        return (_contributions[addr].weiContribution, tokensToClaim, _contributions[addr].claimed);
    }

    // Use this only to calculate withdrawable tokens with vesting
    function getUserTokensWithdrawable(address _user)public view returns (uint256, uint256) {
        // Re-calculate tokens available in case a rebase happened
        (, uint256 tokensToClaim, ) = checkContribution(_user);

        // Check current cycle and in case there are withdrawble tokens,add them to totalTokensWithdrawable
        uint256 currCycle = (block.timestamp - presaleFinalizedTimestamp) / investorsVesting.vestingCycle;
        // Calculate the first release based on vestingFirstPercentage
        uint256 firstVesting;
        if( usersVesting[_user].tokensWithdrawn == 0 ){ 
            firstVesting = tokensToClaim * investorsVesting.vestingFirstPercentage / 100;
        }

        uint256 cycleVesting = (investorsVesting.vestingTokensPerCyclePercentage * tokensToClaim / 100) * (currCycle - usersVesting[_user].lastCycleClaimed);
        // Check current cycle and in case there are withdrawble tokens,add them to totalTokensWithdrawable
        
        if( tokensToClaim == 0 ) return ( 0, currCycle);
        else if ( usersVesting[_user].tokensWithdrawn + cycleVesting > tokensToClaim ){
            return (  tokensToClaim - usersVesting[_user].tokensWithdrawn, currCycle );
        } else {
            if( firstVesting + cycleVesting > tokensToClaim ) return ( tokensToClaim, currCycle );
            return ( firstVesting + cycleVesting, currCycle );
        }
        
    }

    // Use this only if vesting is enabled
    function claimVestingTokens() external nonReentrant {
        require( investorsVesting.vestingEnabled, "VESTING DISABLED: You must use claimTokens" );
        require(result == Result.FINALIZED, "Presale must be finalized");
        (uint256 tokensClaimable,uint256 currentCycle) = getUserTokensWithdrawable(msg.sender);
        require(tokensClaimable > 0, "Insufficient amount");
        tokensClaimed += tokensClaimable;
        usersVesting[msg.sender].tokensWithdrawn += tokensClaimable;
        usersVesting[msg.sender].lastCycleClaimed = currentCycle;
        tokenInfo.token.transfer(msg.sender, tokensClaimable);
        emit TokensClaimed(msg.sender, tokensClaimable);
    }

    // Use this only if vesting is disabled
    function claimTokens() external nonReentrant {
        require(!investorsVesting.vestingEnabled,"VESTING ENABLED: You must use claimVestingTokens");
        require(result == Result.FINALIZED, "Presale must be finalized");
        require(_contributions[msg.sender].claimed == false, "You have already claimed");
        (, uint256 tokensToClaim, ) = checkContribution(msg.sender);
        _contributions[msg.sender].claimed = true;
        require(tokensToClaim > 0, "Nothing to claim");
        tokensClaimed += tokensToClaim;
        tokenInfo.token.transfer(msg.sender, tokensToClaim);
        emit TokensClaimed(msg.sender, tokensToClaim);
    }

    function endRound1() external onlyPresaleCreator{
        require(checkCurrentRound() == 1, "Round 1 already end");
        whitelistEnabled = false;
    }

    function setBulkWhitelist(address[] memory accounts, bool value) external  onlyPresaleCreator{
        require(whitelistEnabled, "Whitelist is not enabled");
        for(uint256 i = 0; i < accounts.length; i++){
            _isWhitelisted[accounts[i]] = value;
        }
    }

    function setUserWhitelisted(address account, bool value) external onlyPresaleCreator{
        require(whitelistEnabled, "Whitelist is not enabled");
        require(_isWhitelisted[account] != value, "Value already set");
        _isWhitelisted[account] = value;  
    }

    function checkWhitelistedAccount(address account) external view returns(bool isWhitelisted){
        if(whitelistEnabled) isWhitelisted = _isWhitelisted[account];
        else return false;
    }

    function setUtilsLink(string memory newLink) external onlyPresaleCreator{
        utilsLink = newLink;
    }

    function getInvestorsVesting() external view returns(uint256, uint256, uint256, bool){
        return (
            investorsVesting.vestingCycle,
            investorsVesting.vestingFirstPercentage,
            investorsVesting.vestingTokensPerCyclePercentage,
            investorsVesting.vestingEnabled
            );
    }

    function getListingInfo() external view returns(uint256, uint256, uint256, address, address){
        return (
            listingInfo.listingRate, 
            listingInfo.liquidityPercentage, 
            listingInfo.liquidityLockTime,
            listingInfo.LPLockerFactory,
            address(listingInfo.router)
            );
    }

    function getPresaleInfo() external view returns(
        TokenInfo memory, PresaleInfo memory, ListingInfo memory, InvestorsVesting memory,
        string memory, address ,bool , uint256 , uint256, uint256  ){
        return (
            tokenInfo, presaleInfo, listingInfo, investorsVesting, utilsLink,
            presaleCreator, whitelistEnabled, 
            fundsRaised, tokensSold, presaleFinalizedTimestamp
        );
    }

    function emergencyWithdraw(address tokenAddress) external onlyPresaleFactory{
        if(address(this).balance > 0) payable(presaleFactory).sendValue(address(this).balance);
        IERC20(tokenAddress).transfer(presaleFactory, IERC20(tokenAddress).balanceOf(address(this)));
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
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

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

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
     * by making the `nonReentrant` function external, and make it call a
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

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPair{
    function token0() external view returns (address);
    function token1() external view returns (address);
    function sync() external;
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountATokenDesired,
        uint amountBTokenDesired,
        uint amountATokenMin,
        uint amountBTokenMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

//SPDX-License-Identifier: MIT
import "./IDex.sol";

pragma solidity ^0.8.9;

interface IStruct{

    //Presale
    struct PresaleInfo {
        uint256  presaleRate; // in token decimals
        uint256  minPurchase; // in wei
        uint256  maxPurchase; // in wei
        uint256  softCap; // in wei
        uint256  hardCap; // in wei
        uint256  startDate; // in timestamp
        uint256  endDate; // in timestamp
    }
    
    //Listing
    struct ListingInfo {
        uint256 listingRate; // in token decimals
        uint256 liquidityPercentage;
        uint256 liquidityLockTime; // in timestamp
        address LPLockerFactory;
        IRouter router;
    }

    //Vesting: Investors
    struct InvestorsVesting{
        uint256 vestingCycle; // Investors will need to wait for this amount of time (seconds) to receive their tokens
        uint256 vestingFirstPercentage; // The first batch of the total presale tokens that will be released 
        uint256 vestingTokensPerCyclePercentage; // How many tokens will be released each cycle
        bool vestingEnabled;
    }

    //Rounds
    struct RoundsTimer{
        uint256 round1Timer;
        uint256 round2Timer;
    }

    // Membership
    struct MembershipInfo {
        address membershipToken;
        uint256 minMembershipBalance;
    }
}