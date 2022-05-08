/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

/**
* MetaCity token Presale
* https://mccash.com
* Version 1.0.2
* SPDX-License-Identifier: MIT
**/

pragma solidity 0.8.13;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContrac(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library Address {

    function isContrac(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /**
    * Also in memory of JPK, miss you Dad.
    */
}

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

    constructor () {
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

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

abstract contract Builder{    

    struct BuilderU {
        uint256 id;
        uint256 sharedId;
        address payable refBy;
        uint256 refsCount;
        uint256 teamCount;
        uint256 activations;
        uint256 dateJoined;
        bool isPioneer;
    }

    mapping(address => BuilderU) public users;
}

contract SmartPresale is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public claimOpen = false;

    bool public salesOpen = true;

    IERC20 public token;

    Builder public builder;

    struct User {
        uint256 id;
        address sponsor;
        address[] referrals;
        uint256 earnings; // bnb
        uint256 spent; // bnb
        uint256 purchased; // total token purchased
        uint256 instantClaim; // Claimable At launch
        uint256 vested; // Vested tokens
        uint256 claimed; // total claimed tokens
        uint256 lastClaimed;
    }

    uint256 public constant SUPPLY_ROUND_1 = 100e27; // Private 1
    uint256 public constant SUPPLY_ROUND_2 = 150e27; // Public 2

    uint256 public constant PRICE_ROUND_1 = 6e8; // Tokens per 1bnb Private
    uint256 public constant PRICE_ROUND_2 = 4e8; // Tokens per 1bnb Public

    uint256 public constant MIN_PURCHASE = 1e10; // 0.1 bnb 1e17
    uint256 public constant MAX_PURCHASE = 3e18; // 3 bnb

    uint256 public tokenSold; // Both Private / Public
    uint256 public tokenSoldPublic; // Public
    uint256 public tokenSoldPrivate; // Private
    uint256 public leftClaims = SUPPLY_ROUND_1.add(SUPPLY_ROUND_2);

    address payable private contract_;
    address payable public marketing;
    address payable public liquidity;

    uint256[] internal COMMISSION = [500, 300, 200];
    uint256 internal constant VESTING_10 = 4000;
    uint256 internal constant VESTING_1 = 6000;
    uint256 internal constant VESTING_2 = 5000;
    uint256 internal constant DIV = 10000;
    uint256 public lastUserId = 1;

    uint256 public startingDate_pri = block.timestamp;
    uint256 public startingDate_pub = block.timestamp;
    uint256 internal salesClosedAt = block.timestamp;

    mapping (address => User) public users;

    event onTokenPurchase(address indexed customerAddress, uint256 incomingBSC, uint256 tokensSold, address indexed referredBy);

    event onCommissionEarned(address indexed fromRef, uint256 earnedBSC, address indexed sponsor);

    modifier onlyContract(){
        require(msg.sender == contract_);
        _;
    }

    modifier canClaim(){
        require(claimOpen, 'Not Open');
        _;
    }

    modifier hasBalance(){
        require(token.balanceOf(address(this)) >= leftClaims, 'Pls Send tokens to Contract!');
        _;
    }

    modifier onlyBuilder(){
        _;
    }

    constructor(IERC20 _token, address _builder) {
        builder = Builder(_builder);
        token = _token;
        contract_ = payable(msg.sender);
    }

    function buyToken(address _ref) public payable{
        // Register User if not member
        purchase(msg.sender, _ref, msg.value);
    }

    function purchase(address _user, address _ref, uint256 _in) internal{
        require(liquidity != address(0), 'Set liquidity Address');
        require(_in >= MIN_PURCHASE && _in <= MAX_PURCHASE, 'MIN 0.10 BNB && MAX 3 BNB');
        // Private or Public Sale
        (uint256 _rate, bool privateBuyer, address _refBy) = getRate(_user, _ref);
        // Transfer tokens
        registerUser(_user, _refBy);
        uint256 _tokenIn = _rate.mul(_in);
        tokenSold += _tokenIn;
        users[_user].spent += _in; // bnb
        users[_user].purchased += _tokenIn; // tokens
        if(privateBuyer){
            users[_user].instantClaim += _tokenIn.mul(VESTING_10).div(DIV); // tokens
            users[_user].vested += _tokenIn.mul(VESTING_1).div(DIV); // tokens
            tokenSoldPrivate += _tokenIn;
        }
        else{
            users[_user].instantClaim += _tokenIn.mul(VESTING_2).div(DIV); // tokens
            users[_user].vested += _tokenIn.mul(VESTING_2).div(DIV); // tokens
            tokenSoldPublic += _tokenIn;
        }
        // Award Commissions
        salesReward(_user, _in);
    }

    function registerUser(address _user, address _ref) internal{
        User storage user = users[_user];
        user.sponsor = contract_;
        if(_ref != _user && _ref != address(0)){
            user.sponsor = _ref;
        }
        users[user.sponsor].referrals.push(_user);
    }

    function salesReward(address _user, uint256 _amount) internal{
        address _sponsor = users[_user].sponsor;
        uint256 toPay = _amount.div(10);
        uint256 _liquidity = _amount.mul(6468).div(DIV);
        uint256 _amountS = _amount.sub(toPay);
        uint256 _dev = _amount.mul(500).div(DIV);
        uint256 commission_ = 0;
        for(uint256 _int = 0; _int < 3; _int++){
            commission_ = _amount.mul(COMMISSION[_int]).div(DIV); // 2%
            if(_sponsor != address(0)){
                users[_sponsor].earnings = users[_sponsor].earnings.add(commission_);
                payable(_sponsor).transfer(commission_);
                toPay = toPay.sub(commission_);
            }
            uint256 _sponsorId = users[_sponsor].id;
            if(_sponsorId < 1){
                _sponsor = findUpline(_sponsor);
            }
            else{
                _sponsor = users[_sponsor].sponsor;
            }
        }
        
        contract_.transfer(toPay.add(_dev));

        liquidity.transfer(_liquidity);

        marketing.transfer(_amountS.sub(_liquidity).sub(_dev));
    }

    function findUpline(address _user) internal view returns(address payable _sponsor){
        (, , _sponsor, , , , ,) = builder.users(_user);
    }

    function viewUserReferral(address _user) public view returns(address[] memory) {
        return users[_user].referrals;
    }

    function getRate(address _user, address _ref) internal view returns(uint256 _rate, bool privateB, address _refBy){
        _rate = PRICE_ROUND_2;
        privateB = false;
        _refBy = _ref;
        // Private Sale Buyer
        (uint _id, , address payable _sponsor, , , , ,) = builder.users(_user);
        if(_id > 1){
            privateB = true;
            _rate = PRICE_ROUND_1;
            _refBy = _sponsor;
        }
        return(_rate, privateB, _refBy);
    }

    function setData(address payable _liquidity, address payable _marketing) public onlyContract {
        liquidity = _liquidity;
        marketing = _marketing;
    }

    function claim() public canClaim{
        address _user = msg.sender;
        if(users[_user].instantClaim > 0){
            token.safeTransfer(_user, users[_user].instantClaim);
            users[_user].claimed += users[_user].instantClaim;
            leftClaims = leftClaims.sub(users[_user].instantClaim);
            users[_user].instantClaim = 0;
            users[_user].lastClaimed = block.timestamp;
        }
        require(users[_user].instantClaim == 0 && users[_user].lastClaimed >= users[_user].lastClaimed.add(30 days), '30D Vesting');
        require(users[_user].vested > 0 && users[_user].claimed < users[_user].purchased, 'Exceed Pruchased');
        uint256 _tokenAmount = users[_user].vested.div(10); // 10% 
        users[_user].claimed = users[_user].claimed.add(_tokenAmount);
        users[_user].lastClaimed = block.timestamp;
        token.safeTransfer(_user, _tokenAmount);
        leftClaims = leftClaims.sub(_tokenAmount);
        if(users[_user].claimed >= users[_user].purchased){
            users[_user].vested = 0;
        }
    }

    function closeSales() public onlyContract{
        require(salesOpen, 'AlreadyClosed');
        claimOpen = true;
        salesOpen = false;
        salesClosedAt = block.timestamp;
    }

    function openCloseClaim() public onlyContract hasBalance{
        claimOpen = !claimOpen;
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent TRC20 tokens
    // ------------------------------------------------------------------------
    function missedTokens(address _tokenAddress) public onlyContract returns(bool success) {
        uint256 _value = IERC20(_tokenAddress).balanceOf(address(this));
        return IERC20(_tokenAddress).transfer(msg.sender, _value);
    }

    function avoidLock() public onlyContract returns(bool){
        return(contract_.send(address(this).balance));
    }

    receive() external payable {
        purchase(msg.sender, contract_, msg.value);
    }
}