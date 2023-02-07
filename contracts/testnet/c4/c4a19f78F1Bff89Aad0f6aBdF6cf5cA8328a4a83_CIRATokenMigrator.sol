/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

// BEP20 token standard interface
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

// Main Contract
contract CIRATokenMigrator is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 depositeddAmountV1;
        bool claimed;
    }
    mapping(address => UserInfo) public userInfo;

    uint256 public totalDepositedAmountV1;
    uint256 public rate = 1;
    bool public openForDeposit = false;

    uint256 public treasureAmountV2;
    
    IBEP20 public tokenV1 = IBEP20(0xF0d872671284E7ffeA3cb7aF1BE42Dc05e57f47b);
    IBEP20 public tokenV2 = IBEP20(0x8573bAe2a919DC9B382688041595F548E71B467B);
    address public tokenV2Pair = 0x4046B7605D904A147F2Ae540fBFAb4615386a2F4;


    function depositV1(uint256 amount) public nonReentrant{
        require((totalDepositedAmountV1.add(amount)).div(rate) <= treasureAmountV2, "Owner need to deposit more v2 token");
        require(openForDeposit, "Not in deposit period");

        tokenV1.transferFrom(msg.sender, address(this), amount);
        totalDepositedAmountV1 = totalDepositedAmountV1.add(amount);
        userInfo[msg.sender].depositeddAmountV1 = userInfo[msg.sender].depositeddAmountV1.add(amount);
    }

    function claimV2() public nonReentrant{
        require(tokenV2.balanceOf(tokenV2Pair) > 0, "Token hasn't launched yet");
        require(userInfo[msg.sender].depositeddAmountV1 > 0, "You haven't deposit V1 yet");
        require(userInfo[msg.sender].claimed == false, "You already claimed");
        
        uint256 claimAmount = userInfo[msg.sender].depositeddAmountV1.mul(10**(18-5)).div(rate);

        tokenV2.transfer(msg.sender, claimAmount);
        userInfo[msg.sender].claimed = true;
    }

    function claimableV2Amount(address account) public view returns (uint256) {
        if(userInfo[account].claimed){
            return 0;
        }
        return userInfo[account].depositeddAmountV1.div(rate);
    }

    function addV2Token(uint256 amount) public {
        tokenV2.transferFrom(msg.sender, address(this), amount);
        treasureAmountV2 = treasureAmountV2.add(amount);
    }

    function depositOpen() public onlyOwner{
        openForDeposit = true;
    }

    function depositClose() public onlyOwner{
        openForDeposit = false;
    }

    function withdrawV1() public onlyOwner{
        tokenV1.transfer(msg.sender, tokenV1.balanceOf(address(this)));
    }

    function withdrawV2() public onlyOwner{
        uint256 withdrawableAmount = treasureAmountV2.sub(totalDepositedAmountV1.div(rate));
        treasureAmountV2 = treasureAmountV2.sub(withdrawableAmount);
        tokenV2.transfer(msg.sender, withdrawableAmount);
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}