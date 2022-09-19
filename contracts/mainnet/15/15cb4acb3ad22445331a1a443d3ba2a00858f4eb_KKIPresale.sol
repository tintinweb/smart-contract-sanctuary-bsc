/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT

/**
 *                                                                                @
 *                                                                               @@@
 *                          @@@@@@@                     @@@@@@@@                @ @ @
 *                   @@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@           @@@
 *                @@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@@@@         @
 *
 *    @@@@@@@@     @@@@@@@@@    @@@@@@@@@@    @@@@@@@       @@@      @@@@@  @@     @@@@@@@@@@
 *    @@@@@@@@@@   @@@@@@@@@@   @@@@@@@@@@   @@@@@@@@@      @@@       @@@   @@@    @@@@@@@@@@
 *    @@@     @@@  @@@     @@@  @@@     @@  @@@     @@@    @@@@@      @@@   @@@@   @@@     @@
 *    @@@     @@@  @@@     @@@  @@@         @@@            @@@@@      @@@   @@@@   @@@
 *    @@@@@@@@@@   @@@@@@@@@@   @@@    @@    @@@@@@@      @@@ @@@     @@@   @@@@   @@@    @@
 *    @@@@@@@@     @@@@@@@@     @@@@@@@@@     @@@@@@@     @@@ @@@     @@@   @@@@   @@@@@@@@@
 *    @@@          @@@   @@@    @@@    @@          @@@   @@@   @@@    @@@   @@@@   @@@    @@
 *    @@@  @@@@    @@@   @@@    @@@                 @@@  @@@   @@@    @@@   @@@@   @@@
 *    @@@   @@@    @@@    @@@   @@@     @@  @@@     @@@  @@@@@@@@@    @@@   @@     @@@     @@
 *    @@@    @@    @@@    @@@   @@@@@@@@@@   @@@@@@@@    @@@   @@@    @@@      @@  @@@@@@@@@@
 *   @@@@@     @  @@@@@   @@@@  @@@@@@@@@@    @@@@@@    @@@@@ @@@@@  @@@@@@@@@@@@  @@@@@@@@@@
 *
 *                @@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@@@@@@
 *                   @@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@
 *                        @@@@@@@@@@                 @@@@@@@@@@@@
 *
 */


pragma solidity 0.8.4;

abstract contract Context {

    constructor () { }

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable is Context {

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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional

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

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


contract KKIPresale is ReentrancyGuard, Context, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 public _tokenKKI;
    
    address private _wallet;
    uint256 public MIN_LOCKTIME = 3 days;

    uint256 public softCap = 15 * 10 **18;      // 15 BNB
    uint256 public hardCap = 20 * 10 **18;      // 20 BNB

    uint256 private _weiRaised;                 // total amount of money that buyers spent here.
    uint256 public minPurchase = 150_000_000 * 10 ** 9;  // min amount = 0.15 BNB
    uint256 public maxPurchase = 3_000_000_000 * 10 **9; // max amount = 3 BNB
    uint256 public availableKKITokensIDO;       // number of kki token available (left)
    uint256 public totalKKITokens;              // number of initial kki

    mapping (address => bool) public    KKIClaimed;
    mapping (address => uint256) public KKITokenBought;

    bool public presaleResult;
    uint256 public startTime;

    event IDOStart(uint256 startTime, uint256 softCap, uint256 hardCap);
    event KKITokenPurchased(address indexed purchaser, uint256 value, uint256 amount);
    event KKITokenClaimed(address indexed purchaser, uint256 value);
    event DropSent(address[]  receiver, uint256[]  amount);
    event AirdropClaimed(address receiver, uint256 amount);

    event SetLockupTime(uint256 time);
    event WithDrawMoney(address _wallet, uint256 bnbBalance);

    constructor (address wallet, IERC20 tokenKKI) {

        require(wallet != address(0), "Pre-Sale: wallet is the zero address");
        require(address(tokenKKI) != address(0), "Pre-Sale: KKI token is the zero address");

        _wallet = wallet;
        _tokenKKI = tokenKKI;
        startTime = 0;
    }

    //Start Pre-Sale
    function startIDO(uint256 _availableKKITokens) external onlyOwner icoNotActive() {

        require(_availableKKITokens > 0 && _availableKKITokens <= _tokenKKI.totalSupply(), 'Pre-Sale: availableTokens should be > 0 and <= totalSupply');

        availableKKITokensIDO = _availableKKITokens;
        totalKKITokens = _availableKKITokens;
        startTime = block.timestamp;
        emit IDOStart(startTime, softCap, hardCap);
    }

    function stopIDO() external onlyOwner icoActive() {
        if(_weiRaised > softCap) {
          presaleResult = true;
        } else {
          presaleResult = false;
        }
    }


    //Pre-Sale
    function buyKKITokens() public nonReentrant icoActive payable {

        require(msg.value > 0, "required kki amount is greater than left tokens");
        uint256 kkiamount = getKKINumberFromBNB(msg.value);
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_msgSender(), weiAmount);

        _weiRaised = _weiRaised.add(weiAmount);
        availableKKITokensIDO = availableKKITokensIDO - kkiamount;

        KKIClaimed[_msgSender()] = false;
        KKITokenBought[_msgSender()] = KKITokenBought[_msgSender()] + kkiamount;

        emit KKITokenPurchased(_msgSender(), weiAmount, kkiamount);
    }

    function getKKINumberFromBNB(uint256 _bnbValue) private pure returns (uint256) {
        return _bnbValue.mul(650000);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        require(beneficiary != address(0), "Pre-Sale: beneficiary is the zero address");
        require(weiAmount != 0, "Pre-Sale: weiAmount is 0");
        require(weiAmount >= minPurchase, 'have to send at least: minPurchase');
        require(weiAmount <= maxPurchase, 'have to send max: maxPurchase');
        this;
    }

    function claimKKIToken() public icoNotActive() {

      require(KKIClaimed[msg.sender] == false, "Pre-Sale: You did claim your tokens!");
      KKIClaimed[msg.sender] = true;
      _tokenKKI.transfer(msg.sender, KKITokenBought[msg.sender]);
      emit KKITokenClaimed(_msgSender(), KKITokenBought[msg.sender]);
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, 'Pre-Sale: Contract has no money');
        payable(_wallet).transfer(address(this).balance);
        emit WithDrawMoney(_wallet, address(this).balance);
    }

    function withdrawTokenBack(uint256 amount) external onlyOwner {
        _tokenKKI.transfer(msg.sender, amount);
    }

    function setLockupTime(uint256 _locktime) external onlyOwner {
        MIN_LOCKTIME = _locktime;
        emit SetLockupTime(_locktime);
    }

    function isPresaleStopped() public view returns (bool) {
        if (block.timestamp > startTime + MIN_LOCKTIME) 
            return true;
        else
            return false;
    }


    function getTimediff() public view returns (uint256) {
        return startTime + MIN_LOCKTIME > block.timestamp ? startTime + MIN_LOCKTIME - block.timestamp : 0 ;
    }


    function getWallet() public view returns (address) {
        return _wallet;
    }

    function setWallet(address _newWallet) public onlyOwner {
        _wallet = _newWallet;
    }

    function setAvailableKKITokens(uint256 amount) public onlyOwner {
        availableKKITokensIDO = amount;
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    modifier icoActive() {
        require(block.timestamp < startTime + MIN_LOCKTIME && availableKKITokensIDO > 0, "Pre-Sale: ICO must be active");
        _;
    }

    modifier icoNotActive() {
        require(startTime + MIN_LOCKTIME < block.timestamp, 'Pre-Sale: ICO should not be active');
        _;
    }
}