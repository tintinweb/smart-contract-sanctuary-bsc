/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

contract BSCRecharge is Ownable {
    using SafeMath for uint256;

    address public ETH = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address public BTC = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address public USDT = 0xEdA5dA0050e21e9E34fadb1075986Af1370c7BDb;
    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public DAI = 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3;
    uint256 public multiMaxLength = 500;

    mapping (address => mapping (address => uint256)) public balanceOfToken;
    mapping (address => bool) public isWhiteList;

    modifier onlyWhiteList() {
        require(owner() == _msgSender() || isWhiteList[_msgSender()], "No Access");
        _;
    }

    event Recharge(address token_, address from, uint256 amount_);
    event RechargeBNB(address from, uint256 amount_);
    event Refund(address token_, address account_, uint256 amount_);
    event RefundBNB(address account_, uint256 amount_);

    constructor()  {}

    function setWhiteList(address account, bool included) public onlyOwner {
        require(isWhiteList[account] != included, "Cannot set same value");
        isWhiteList[account] = included;
    }

    function setMultiMaxLength(uint256 num_) public onlyOwner {
        require(multiMaxLength != num_, "Cannot set same value");
        multiMaxLength = num_;
    }

    receive() external payable {
        balanceOfToken[address(0)][msg.sender] = balanceOfToken[address(0)][msg.sender].add(msg.value);
        emit RechargeBNB(_msgSender(), msg.value);
    }

    function rechargeETH(uint256 amount_) public {
        _recharge(ETH, msg.sender, amount_);
    }

    function rechargeETHFrom(address from_, uint256 amount_) public onlyWhiteList{
        _recharge(ETH, from_, amount_);
    }

    function rechargeBTC(uint256 amount_) public {
        _recharge(BTC, msg.sender, amount_);
    }

    function rechargeBTCFrom(address from_, uint256 amount_) public onlyWhiteList{
        _recharge(BTC, from_, amount_);
    }

    function rechargeUSDT(uint256 amount_) public {
        _recharge(USDT, msg.sender, amount_);
    }

    function rechargeUSDTFrom(address from_, uint256 amount_) public onlyWhiteList{
        _recharge(USDT, from_, amount_);
    }

    function rechargeBUSD(uint256 amount_) public {
        _recharge(BUSD, msg.sender, amount_);
    }

    function rechargeBUSDFrom(address from_, uint256 amount_) public onlyWhiteList{
        _recharge(BUSD, from_, amount_);
    }

    function rechargeDAI(uint256 amount_) public {
        _recharge(DAI, msg.sender, amount_);
    }

    function rechargeDAIFrom(address from_, uint256 amount_) public onlyWhiteList{
        _recharge(DAI, from_, amount_);
    }

    function _recharge(address token_, address from_, uint256 amount_) internal {
        IERC20(token_).transferFrom(from_, address(this), amount_);
        balanceOfToken[token_][from_] = balanceOfToken[token_][from_].add(amount_);
        emit Recharge(token_, from_, amount_);
    }

    function refundBNB(uint256 amount_) public {
        require(balanceOfToken[address(0)][msg.sender] >= amount_, "Invalid BNB Amount" );
        balanceOfToken[address(0)][msg.sender] = balanceOfToken[address(0)][msg.sender].sub(amount_);
        payable(msg.sender).transfer(amount_);
        emit RefundBNB(msg.sender, amount_);
    }

    function refundETH(uint256 amount_) public {
        _refund(ETH, msg.sender, amount_);
    }

    function refundETHTo(address to_, uint256 amount_) public onlyWhiteList{
        _refund(ETH, to_, amount_);
    }

    function refundBTC(uint256 amount_) public {
        _refund(BTC, msg.sender, amount_);
    }

    function refundBTCTo(address to_, uint256 amount_) public onlyWhiteList{
        _refund(BTC, to_, amount_);
    }

    function refundUSDT(uint256 amount_) public {
        _refund(USDT, msg.sender, amount_);
    }

    function refundUSDTTo(address to_, uint256 amount_) public onlyWhiteList{
        _refund(USDT, to_, amount_);
    }

    function refundBUSD(uint256 amount_) public {
        _refund(BUSD, msg.sender, amount_);
    }

    function refundBUSDTo(address to_, uint256 amount_) public onlyWhiteList{
        _refund(BUSD, to_, amount_);
    }

    function refundDAI(uint256 amount_) public {
        _refund(DAI, msg.sender, amount_);
    }

    function refundDAITo(address to_, uint256 amount_) public onlyWhiteList{
        _refund(DAI, to_, amount_);
    }

    function _refund(address token_, address account_, uint256 amount_) internal {
        require(balanceOfToken[token_][account_] >= amount_, "Invalid Token Amount" );
        balanceOfToken[token_][account_] = balanceOfToken[token_][account_].sub(amount_);
        IERC20(token_).transfer(account_, amount_);
        emit Refund(token_, account_, amount_);
    }

    function MulticollectETH(address[] memory accounts, uint256[] memory amounts) public onlyWhiteList {
        _multicollect(ETH, accounts, amounts);
    }

    function MultisendETH(address[] memory accounts, uint256[] memory amounts) public onlyWhiteList {
        _multisend(ETH, accounts, amounts);
    }

    function MulticollectBTC(address[] memory accounts, uint256[] memory amounts) public onlyWhiteList {
        _multicollect(BTC, accounts, amounts);
    }

    function MultisendBTC(address[] memory accounts, uint256[] memory amounts) public onlyWhiteList {
        _multisend(BTC, accounts, amounts);
    }

    function MulticollectUSDT(address[] memory accounts, uint256[] memory amounts) public onlyWhiteList {
        _multicollect(USDT, accounts, amounts);
    }

    function MultisendUSDT(address[] memory accounts, uint256[] memory amounts) public onlyWhiteList {
        _multisend(USDT, accounts, amounts);
    }

    function MulticollectBUSD(address[] memory accounts, uint256[] memory amounts) public onlyWhiteList {
        _multicollect(BUSD, accounts, amounts);
    }

    function MultisendBUSD(address[] memory accounts, uint256[] memory amounts) public onlyWhiteList {
        _multisend(BUSD, accounts, amounts);
    }

    function MulticollectDAI(address[] memory accounts, uint256[] memory amounts) public onlyWhiteList {
        _multicollect(DAI, accounts, amounts);
    }   

    function MultisendDAI(address[] memory accounts, uint256[] memory amounts) public onlyWhiteList {
        _multisend(DAI, accounts, amounts);
    }
    
    function _multicollect(address token_, address[] memory accounts, uint256[] memory amounts) internal {
        require(accounts.length == amounts.length, "invalid accounts and amounts");
        require(accounts.length > 0 && accounts.length <= multiMaxLength, "invalid address length");
        for(uint256 i = 0; i < accounts.length; i++) {
            IERC20(token_).transferFrom(accounts[i], address(this), amounts[i]);
            balanceOfToken[token_][accounts[i]] = balanceOfToken[token_][accounts[i]].add(amounts[i]);
        }
    }

    function _multisend(address token_, address[] memory accounts, uint256[] memory amounts) internal {
        require(accounts.length == amounts.length, "invalid accounts and amounts");
        require(accounts.length > 0 && accounts.length <= multiMaxLength, "invalid address length");
        for(uint256 i = 0; i < accounts.length; i++) {
            IERC20(token_).transfer(accounts[i], amounts[i]);
        }
    }

    function withdraETH(address account_, uint256 amount_) public onlyOwner {
        require(address(this).balance >= amount_ , "Invalid  Amount");
        payable(account_).transfer(amount_);
    }

    function withdrawToken(address token_, address account_, uint256 amount_) public onlyOwner {
        require(IERC20(token_).balanceOf(address(this)) >= amount_ , "Invalid Amount");
        IERC20(token_).transfer(account_, amount_);
    }

}