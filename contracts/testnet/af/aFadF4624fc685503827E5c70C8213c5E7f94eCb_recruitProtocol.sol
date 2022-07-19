/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// Sources flattened with hardhat v2.9.7 https://hardhat.org

// File contracts/IERC20.sol

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


// File contracts/recruitTeam.sol

// File contracts/recruitProtocol.sol
pragma solidity ^0.8.0;


contract recruitProtocol {
    IERC20 public token;
    address public owner;
    uint256 THREE_MONTH = 400; //90 days; //3 months

    constructor()  {
        token = IERC20(0x984DCD047FC94E7407efEC001ECE4ca214925f07);
        owner = msg.sender;
        setRecruitingProcessTokens("sign_up",10 ether);
        setRespondProcessTokens("training",5 ether);

    }
    struct User{
        uint256 pendingTokens;
        uint256 claimTokens;
        uint256 claimAt;
        mapping(string => uint256) amountLockAT;
    }
    mapping(string => User) public userInfo;
    mapping(string => uint256) public recruitDefaultTokens;
    mapping(string => uint256) public responseDefaultTokens;

    event PendingTokens(string uuid,uint256 _amount);
    event ClaimTokens(string uuid,uint256 _amount);

    modifier LockTime(string memory uuid,string memory _responseOn) {
        require(getTimeToLockAmount(uuid,_responseOn) >= THREE_MONTH);
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //Set recruit Default Tokens
    function setRecruitingProcessTokens(string memory _recruitAt,uint256 _amount) public onlyOwner returns (bool) {
        recruitDefaultTokens[_recruitAt] =  _amount;
        return true;
    }

    function setRespondProcessTokens(string memory _responseOn,uint256 _amount) public onlyOwner returns (bool) {
        responseDefaultTokens[_responseOn] =  _amount;
        return true;
    }

    function assignRecruitingTokens(string memory uuid,string memory _poistion) public {
        User storage  _user =  userInfo[uuid];
        _user.amountLockAT[_poistion] = block.timestamp;
        _user.pendingTokens += recruitDefaultTokens[_poistion];
        emit PendingTokens(uuid,recruitDefaultTokens[_poistion]);
    }

    function transferOnResponseTokens(string memory uuid,string memory _responseOn) public

    {
        User storage  _user =  userInfo[uuid];
        _user.amountLockAT[_responseOn] = block.timestamp;
        _user.pendingTokens -= responseDefaultTokens[_responseOn];
        require(token.balanceOf(msg.sender) >  0 ,"Zero Balance!");
        token.approve(address(this),token.balanceOf(msg.sender));
        token.transferFrom(msg.sender,address(this),responseDefaultTokens[_responseOn]);
        emit PendingTokens(uuid,responseDefaultTokens[_responseOn]);
    }

    function claim(string memory uuid,string memory _responseOn) public LockTime(uuid,_responseOn) {
        User storage  _user =  userInfo[uuid];
        _user.amountLockAT[_responseOn] = block.timestamp;
        _user.pendingTokens -= responseDefaultTokens[_responseOn];
        _user.claimTokens   += responseDefaultTokens[_responseOn];
        token.transfer(msg.sender,recruitDefaultTokens[_responseOn]);
    }

    function getTimeToLockAmount(string memory uuid,string memory _responseOn) public view returns(uint256){
        User storage  _user =  userInfo[uuid];
        uint256 timeDifferance = block.timestamp - _user.amountLockAT[_responseOn];
        return  timeDifferance;
    }

}