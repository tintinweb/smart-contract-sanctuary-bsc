/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
interface token{
    function claimPresale(address user, uint amount) external;
}

contract Presale1 {

    address public owner;
    address public tokenContract;

    function setTokenContract(address _tokenContract) public onlyOwner {
        tokenContract = _tokenContract;
    }

    IERC20 USDC = IERC20(0x64544969ed7EBf5f083679233325356EbE738930); //TESTNET BSC

    function setUSDCAddress(address _usdcAddress) public onlyOwner {
        USDC = IERC20(_usdcAddress);
    }

    uint public maxAmount = 200 * 10**6;
    uint public minAmount = 50 * 10**6;
    uint public maxCap = 15000 * 10**6;
    uint public totalAmount = 0;

    bool public presaleEnable = false;
    bool public claimEnable = false;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    address[] public users;
    mapping (address => uint) public amounts;
    mapping (address => bool) public claimed;

    function transferUSDC() external onlyOwner {
        USDC.transfer(owner, USDC.balanceOf(address(this)));
    }

    function setMaxAmount(uint _maxAmount) public onlyOwner {
        maxAmount = _maxAmount;
    }

    function setMinAmount(uint _minAmount) public onlyOwner {
        minAmount = _minAmount;
    }

    function setMaxCap(uint _maxCap) public onlyOwner {
        maxCap = _maxCap;
    }

    function setPresaleEnable(bool _presaleEnable) public onlyOwner {
        presaleEnable = _presaleEnable;
    }

    function setClaimEnable(bool _claimEnable) public onlyOwner {
        claimEnable = _claimEnable;
    }

    function mintNodePresale(uint amount) external {
        address user = msg.sender; 
        require(presaleEnable, "Presale not enabled");
        require(amount >= minAmount, "Amount too low");
        require(amount <= maxAmount, "Amount too high");
        require(amounts[user] + amount <= maxAmount, "Amount too high");
        require(totalAmount + amount <= maxCap, "Max cap reached");
        
        USDC.transferFrom(msg.sender, owner, amount);
        if (amounts[user] < minAmount){
            users.push(user);
        }
        amounts[user] += amount;
        totalAmount += amount;
        claimed[user] = false;
    }

    function claimPresale() external {
        require(claimed[msg.sender] == false, "You have already claimed");
        require(claimEnable, "Claim not enabled");
        token(tokenContract).claimPresale(msg.sender, amounts[msg.sender] * 10 ** 6);
        claimed[msg.sender] = true;
    }

    function getInfoPresale(address user) external view returns (uint) {
        return amounts[user];
    }

    function getUSDCBalance() external view returns (uint) {
        return totalAmount;
    }

    function getParticipants() external view returns (uint) {
        return users.length;
    }

    function resetPresale() external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            claimed[users[i]] = false;
        }
    }
}