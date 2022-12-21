/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier:MIT

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
contract CIRAV1toV2 is Ownable, ReentrancyGuard {
    //using SafeMath for uint256;

    struct UserInfo {
        uint256 depositeddAmountV1;
        bool claimed;
    }

    mapping(address => UserInfo) public userInfo;

    event Log(string, uint256);
    event AuditLog(string, address);

    uint256 public totalDepositedAmountV1;
    uint256 public totalClaimedAmountV2;
    uint256 public rate = 1;
    bool public openForDeposit = false;

    uint256 public treasureAmountV2;
    
    IBEP20 public tokenV1 = IBEP20(0xF0d872671284E7ffeA3cb7aF1BE42Dc05e57f47b);
    IBEP20 public tokenV2 = IBEP20(0x8573bAe2a919DC9B382688041595F548E71B467B);
    address public tokenV2Pair = 0x4046B7605D904A147F2Ae540fBFAb4615386a2F4;


    function depositV1(uint256 amount) external nonReentrant{
        require((totalDepositedAmountV1 + amount / rate) <= treasureAmountV2, "Owner need to deposit more v2 token");
        require(openForDeposit, "Not in deposit period");

        tokenV1.transferFrom(msg.sender, address(this), amount);
        totalDepositedAmountV1 = totalDepositedAmountV1 + amount;
        userInfo[msg.sender].depositeddAmountV1 = userInfo[msg.sender].depositeddAmountV1 + amount;
        userInfo[msg.sender].claimed = false;
        emit AuditLog("The deposit has been successfull for the holder:",msg.sender);
        emit Log("They have deposited a total of:",amount);
    }

    function claimV2() external nonReentrant{
        require(userInfo[msg.sender].depositeddAmountV1 > 0, "You haven't deposit V1 yet");
        require(userInfo[msg.sender].claimed == false, "You already claimed");
        
        uint256 claimAmount = userInfo[msg.sender].depositeddAmountV1 * (1 * 10**13) / rate;
        tokenV2.transfer(msg.sender, claimAmount);
        userInfo[msg.sender].claimed = true;
        userInfo[msg.sender].depositeddAmountV1 = userInfo[msg.sender].depositeddAmountV1 - claimAmount;
        treasureAmountV2 = treasureAmountV2 - claimAmount;
        totalClaimedAmountV2 = totalClaimedAmountV2 + claimAmount;
        emit AuditLog("The claim has been successfull for the holder:",msg.sender);
        emit Log("They have claimed a total of:",claimAmount);
    }

    function claimableV2Amount(address account) public view returns (uint256) {
        if(userInfo[account].claimed){
            return 0;
        }
        return userInfo[account].depositeddAmountV1 * (1 * 10**13) / rate;
    }

    function addV2Token(uint256 amount) external nonReentrant {
        require(amount > 0, "You need to deposit more than 0 tokens.");
        tokenV2.transferFrom(msg.sender, address(this), amount);
        treasureAmountV2 = treasureAmountV2 + amount;
        emit AuditLog("The admin has successfully added tokens to the contract:",msg.sender);
        emit Log("The total added to the treasure is:",amount);
    }

    function depositOpen() external onlyOwner{
        require(openForDeposit != true, "Deposit is already open.");
        openForDeposit = true;
        emit AuditLog("The migration has been opened for deposits.",msg.sender);
    }

    function depositClose() external onlyOwner{
        require(openForDeposit != false, "Deposit is already closed.");
        openForDeposit = false;
        emit AuditLog("The migration has been closed for deposits.",msg.sender);
    }

    function withdrawV1() external onlyOwner{
        tokenV1.transfer(msg.sender, tokenV1.balanceOf(address(this)));
        emit AuditLog("The owner has successfully withdraw V1 Tokens.",msg.sender);
        emit Log("The total withdraw from contract is:",tokenV1.balanceOf(address(this)));
    }

    function withdrawV2() external onlyOwner{
        uint256 withdrawableAmount = treasureAmountV2 - totalDepositedAmountV1 / rate;
        treasureAmountV2 = treasureAmountV2 - withdrawableAmount;
        tokenV2.transfer(msg.sender, withdrawableAmount);
        emit AuditLog("The owner has successfully withdraw V2 Tokens.",msg.sender);
        emit Log("The total withdraw from contract is:",withdrawableAmount);
    }
    function updateSetup(address _tokenV2, address _v2Pair, address _migrationV1) external onlyOwner{
    require( _tokenV2 != address(0),"Token V2 Address need to start with : ZERO");
    require( _v2Pair != address(0),"Token V2 Pair Address need to start with : ZERO");
    require( _migrationV1 != address(0),"Token V2 Pair Address need to start with : ZERO");
        tokenV2 = IBEP20(_tokenV2);
        tokenV2Pair = _v2Pair;
        tokenV1 = IBEP20(_migrationV1);
        emit AuditLog("The Setup has been updated.",msg.sender);
    }
    function updateClaim (address _holder, bool _status) external onlyOwner {
        require(userInfo[msg.sender].claimed == true, "User can claim!, no need for update");
        userInfo[_holder].claimed = _status;
        emit AuditLog("The user claim has been updated.",msg.sender);
    }
}