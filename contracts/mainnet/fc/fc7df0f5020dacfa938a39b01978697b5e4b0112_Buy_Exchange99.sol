/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


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

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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
}


contract Ownable  {
    address payable public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), msg.sender);
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface Token {
    function transfer(address to, uint256 value) external returns (bool);


    function balanceOf(address who) external view returns (uint256);

}


contract Buy_Exchange99 is Ownable,ReentrancyGuard{
    
    using SafeMath for uint;

    struct User {
        address upline;
        uint256 referralCount1;
        uint40 deposit_time;
        uint256 total_deposits;
        uint256 total_structure;
        uint256 referrals;
    }
    
    uint8[] public ref_bonuses;

    address public tokenAddr;
    uint256 public tokenPriceBnb = 1536280;    
    uint256 public level1 = 5;

    mapping(address => User) public users;

    event TokenTransfer(address beneficiary, uint amount);
    event Upline(address indexed addr, address indexed upline);
    event RewardClaimed(address beneficiary, uint amount);
    
    bool public reward = true;
    
    mapping (address => uint256) public balances;
    mapping(address => uint256) public tokenExchanged;
    mapping(address => uint256) public rewardEarned;


    constructor(address _tokenAddr) {
        tokenAddr = _tokenAddr;
        ref_bonuses.push(5);
    }
    

    function _setUpline(address _addr, address _upline) private {
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != _owner && (users[_upline].deposit_time > 0 || _upline == _owner)) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;
            users[_addr].deposit_time = uint40(block.timestamp);

            emit Upline(_addr, _upline);
            _addInvestor( _upline);

            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                if(_upline == address(0)) break;
                users[_upline].total_structure++;
                _upline = users[_upline].upline;
            }
        }
    }
    
    function _addInvestor(address _referrer) private {

        if (_referrer != address(0)) {
            address _ref1 = _referrer;            
            users[_ref1].referralCount1 = users[_ref1].referralCount1 + 1;
        }
    }
    

    
    
    receive() payable external {
        ExchangeBNBforTokenMannual(owner());
    }

    
    function ExchangeBNBforTokenMannual(address _upline) public payable nonReentrant{
        uint256 amount = msg.value;
        address userAdd = msg.sender;
       
        _setUpline(userAdd,_upline);
        
        uint256 tokenAmount = amount.mul(tokenPriceBnb);
        
        users[userAdd].deposit_time = uint40(block.timestamp);
        
        /* Send Referral Payout */
        if(reward){
            if(users[userAdd].upline != address(0)){
                uint256 rewardPayout = tokenAmount.mul(level1).div(100);
                rewardEarned[users[userAdd].upline] += rewardPayout;
                require(Token(tokenAddr).balanceOf(address(this)) >= rewardPayout, "There is low token balance in contract");
                require(Token(tokenAddr).transfer(users[userAdd].upline, rewardPayout));
                emit RewardClaimed(users[userAdd].upline, rewardPayout);

            }
        }
        
        users[msg.sender].total_deposits += msg.value;
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        tokenExchanged[msg.sender] = tokenExchanged[msg.sender].add(tokenAmount);

        _owner.transfer(amount);
        require(Token(tokenAddr).balanceOf(address(this)) >= tokenAmount, "There is low token balance in contract");
        require(Token(tokenAddr).transfer(userAdd, tokenAmount));
        emit TokenTransfer(userAdd, tokenAmount);

    }

    function updateTokenPrice(uint256 newTokenValue) public onlyOwner {
        tokenPriceBnb = newTokenValue;
    }
    
    
    function updateTokenAddress(address newTokenAddr) public onlyOwner {
        tokenAddr = newTokenAddr;
    }
    
    function updatePercentage(uint256 level1_) public onlyOwner {
        level1 = level1_;
    }

    function withdrawTokens(address beneficiary) public nonReentrant onlyOwner {
        require(Token(tokenAddr).transfer(beneficiary, Token(tokenAddr).balanceOf(address(this))));
    }

    function withdrawCrypto(address payable beneficiary) public nonReentrant onlyOwner {
        beneficiary.transfer(address(this).balance);
    }
    function tokenBalance() public view returns (uint256){
        return Token(tokenAddr).balanceOf(address(this));
    }
    function bnbBalance() public view returns (uint256){
        return address(this).balance;
    }
    
    function CommisionCheck() public onlyOwner returns (bool success)  {
        if (reward) {
            reward = false;
        } else {
            reward = true;
        }
        return true;
        
    }
}