/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

pragma solidity ^0.8.0;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
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

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
    unchecked {
        counter._value += 1;
    }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
    unchecked {
        counter._value = value - 1;
    }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface NFT {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract AbsUtil is Ownable, Context {
    using Counters for Counters.Counter;

    address public wallet;
    address public token;
    uint256 public tokenDecimals = 18;
    address  public usdt;
    uint256 public usdtDecimals = 18;
    uint256 public rewardTime;

    uint256 public level1UsdtQuantity = 22 * 10 ** uint256(usdtDecimals);
    uint256 public level1TokenQuantity = 1100 * 10 ** uint256(tokenDecimals);
    uint256 public level2UsdtQuantity = 228 * 10 ** uint256(usdtDecimals);
    uint256 public level2TokenQuantity = 11400 * 10 ** uint256(tokenDecimals);

    mapping(address=>uint256) public tokenBalance;
    mapping(address=>uint256) public boxBalance;
    mapping(address=>uint256) public nftBalance;

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => bool) public _level2;
    mapping(address => uint256) public level2UsdtBalance;
    mapping(address => address[]) public _validBinders;

    NFT public nft;
    Counters.Counter private _tokenIdCounter;

    event BindInvitor(address indexed from, address indexed to);
    event IDOLevel1(address indexed from, address indexed to, uint256 value,uint256 tokenAmt);
    event IDOLevel2(address indexed from, address indexed to, uint256 value,uint256 tokenAmt);

    constructor(address _wallet,address _token,address _nft,address _usdt) {
        wallet = _wallet;
        token = _token;
        usdt = _usdt;
        nft = NFT(_nft);
    }

    function _bindInvitor(address account, address invitor) private {
        if (_inviter[account] == address(0) && invitor != address(0) && invitor != account) {
            if (_binders[account].length == 0) {
                _inviter[account] = invitor;
                _binders[invitor].push(account);
            }
        }
    }

    function bindInvitor(address invitor) external {
        _bindInvitor(msg.sender, invitor);
        emit BindInvitor(msg.sender,invitor);
    }

    function upgradeLevel1() external returns (bool) {
        address account = msg.sender;
        _tokenTransfer(usdt, account, level1UsdtQuantity);
        _upgradeCommon(account,level1TokenQuantity);
        emit IDOLevel1(account, wallet, level1UsdtQuantity,level1TokenQuantity);
        return true;
    }

    function upgradeLevel2() external returns (bool) {
        address account = msg.sender;
        _tokenTransfer(usdt, account, level2UsdtQuantity);
        _upgradeCommon(account,level2TokenQuantity);
        _level2[account] = true;
        emit IDOLevel2(account, wallet, level2UsdtQuantity,level2TokenQuantity);
        return true;
    }

    function boxLottery() external {
        _addNFT(msg.sender,1);
    }

    function _addLevel2UsdtBalance(address account,uint256 amount) private {
        level2UsdtBalance[account] = level2UsdtBalance[account] + amount;
    }

    function _addValidBinder(address account,address invitor) private {
        _validBinders[invitor].push(account);
    }

    function _upgradeCommon(address user,uint256 tokenQuantity) private {
        _addTokenBalance(user, level1TokenQuantity);
        _addBoxBalance(user,1);

        address inviter = _inviter[user];
        if(inviter != address(0)) {
            _addValidBinder(user,inviter);
            if(_level2[inviter]) {
                _addLevel2UsdtBalance(inviter, level2UsdtQuantity / 10);
            }
        }

        if(_validBinders[inviter].length % 10 == 0){
            _addNFT(user,1);
        }
    }

    function transferNFT() external returns(bool) {
        address account = msg.sender;
        uint256 count = nftBalance[account];
        if (count == 0){
            return false;
        }

        for (uint256 i = 0; i < count; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            nft.transferFrom(owner(), account, tokenId);
        }
        return true;
    }

    function _tokenTransfer(address token,address user, uint256 amount)  private returns(bool) {
        return IERC20(token).transferFrom(user,wallet,amount);
    }

    function tokenApprove(address token,address spender, uint256 value) external {
        IERC20(token).approve(spender,value);
    }

    function _addTokenBalance(address user, uint256 amount)  private {
        tokenBalance[user] = tokenBalance[user] + amount;
    }

    function _addBoxBalance(address user, uint256 amount) private {
        boxBalance[user] = boxBalance[user] + amount;
    }

    function _addNFT(address user, uint256 amount)  private {
        nftBalance[user] = nftBalance[user] + amount;
    }

    function setLevel1UsdtQuantity(uint256 amount) external onlyOwner returns (bool){
        level1UsdtQuantity = amount;
        return true;
    }

    function setLevel2UsdtQuantity(uint256 amount) external onlyOwner returns (bool){
        level2UsdtQuantity = amount;
        return true;
    }

    function setLevel1TokenQuantity(uint256 amount) external onlyOwner returns (bool){
        level2UsdtQuantity = amount;
        return true;
    }

    function setWallet(address _wallet) external onlyOwner returns (bool) {
        wallet = _wallet;
        return true;
    }

    function setUsdt(address _usdt) external onlyOwner returns (bool){
        usdt = _usdt;
        return true;
    }

    function setToken(address _token) external onlyOwner returns (bool){
        token = _token;
        return true;
    }

    function setNFT(address _nft) external onlyOwner returns (bool){
        nft = NFT(_nft);
        return true;
    }

    function getTotalCount() external view returns (uint256) {
        return _binders[msg.sender].length;
    }

    function getValidCount() external view returns (uint256) {
        return _validBinders[msg.sender].length;
    }

    function getTokenIdCounterCurrent() external view returns (uint256){
        return _tokenIdCounter.current();
    }

    function claimToken(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(token).transfer(msg.sender, balance);
        }
    }
}

contract Util is AbsUtil {
    constructor() AbsUtil (
    //wallet
        address(0xF96450b3C042b4ABE4CBFa8AC8112BbF6e9209EB),
    //token
        address(0x8de03381b78Fab5d3e27c7F7618d4BB9AbC3f163),
    //nft
        address(0xF96450b3C042b4ABE4CBFa8AC8112BbF6e9209EB),
    //usdt
        address(0xbfA3855535Db097319b622eCb88083492FA16A5b)
    ){}
}