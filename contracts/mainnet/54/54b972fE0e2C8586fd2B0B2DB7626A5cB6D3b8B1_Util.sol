/**
 *Submitted for verification at BscScan.com on 2022-07-09
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
    function ownerOf2(uint256 tokenId) external view returns (address owner);
    function mintIdo(address _to, uint256 _tokenId) external;
}

contract Random {
    function rand(uint256 number) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,msg.sender))) % number;
    }
}

abstract contract AbsBizVarUtil is Ownable, Context, Random {
    using Counters for Counters.Counter;

    address public collectWallet;
    address public withdrawWallet;
    address public token;
    uint256 public tokenDecimals = 18;
    address public usdt;
    uint256 public usdtDecimals = 18;
    uint256 public tokenRewardTime = block.timestamp;

    uint256 public nftTotalSupply = 10000;
    uint256 public nftLottyWinningRandom = 50;
    uint256 public nftOnceMintTotal = 50;

    uint256 public level1UsdtQuantity = 68 * 10 ** uint256(usdtDecimals);
    uint256 public level1TokenQuantity = 3400 * 10 ** uint256(tokenDecimals);
    uint256 public level2UsdtQuantity = 228 * 10 ** uint256(usdtDecimals);
    uint256 public level2TokenQuantity = 11400 * 10 ** uint256(tokenDecimals);

    mapping(address=>uint256) public tokenBalance;
    mapping(address=>uint256) public boxBalance;
    mapping(address=>uint256) public nftBalance;

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    mapping(address => address[]) public _validBinders;

    mapping(address => bool) public _level2;
    mapping(address => uint256) public level2UsdtBalance;

    mapping(address => bool) public member;

    uint256 public idoTokenTotal;
    uint256 public idoNftTotal;

    NFT public nft;
    Counters.Counter internal _tokenIdCounter;

    event WithdrawSuccess(address indexed token, address indexed from, address indexed to, uint256 amount);
    event WithdrawFail(address indexed token, address indexed from, address indexed to, uint256 amount);

    function _addTokenBalance(address user, uint256 amount)  internal {
        tokenBalance[user] = tokenBalance[user] + amount;
        idoTokenTotal = idoTokenTotal + amount;
    }

    function _addBoxBalance(address user, uint256 amount) internal {
        boxBalance[user] = boxBalance[user] + amount;
    }

    function _subBoxBalance(address user, uint256 amount) internal {
        boxBalance[user] = boxBalance[user] - amount;
    }

    function _addNFT(address user, uint256 amount)  internal {
        nftBalance[user] = nftBalance[user] + amount;
        idoNftTotal = idoNftTotal + amount;
    }

    function _subNFT(address user, uint256 amount)  internal {
        nftBalance[user] = nftBalance[user] - amount;
    }

    function _addLevel2UsdtBalance(address account,uint256 amount) internal {
        level2UsdtBalance[account] = level2UsdtBalance[account] + amount;
    }

    function _withdrawToken(address transferToken,address to,uint256 amount) internal returns(uint256){
        if(IERC20(transferToken).balanceOf(withdrawWallet) < amount){
            return 3;
        }

        if (IERC20(transferToken).allowance(withdrawWallet, address(this))  < amount) {
            return 4;
        }

        uint256 balance1 = 0;
        if (transferToken == usdt) {
            balance1 = level2UsdtBalance[to];
        } else if (transferToken == token) {
            balance1 = tokenBalance[to];
        }

        if (balance1 <= 0) {
            return 2;
        }

        if(amount != balance1){
            return 5;
        }

        if (transferToken == usdt) {
            level2UsdtBalance[to] = 0;
        } else if (transferToken == token) {
            tokenBalance[to] = 0;
        }

        if (IERC20(transferToken).transferFrom(withdrawWallet, to, balance1)) {
            emit WithdrawSuccess(transferToken, withdrawWallet, to, balance1);
            return 1;
        } else {
            emit WithdrawFail(transferToken, withdrawWallet, to, balance1);
            return 4;
        }
    }

    function getBinders(address account) external view returns (address[] memory){
        return _binders[account];
    }

    function getValidBinders(address account) external view returns (address[] memory){
        return _validBinders[account];
    }

    function addNFT(address user, uint256 amount)  external onlyOwner {
        nftBalance[user] = nftBalance[user] + amount;
        idoNftTotal = idoNftTotal + amount;
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

    function setCollectWallet(address _collectWallet) external onlyOwner returns (bool) {
        collectWallet = _collectWallet;
        return true;
    }

    function setWithdrawWallet(address _withdrawWallet) external onlyOwner returns (bool) {
        withdrawWallet = _withdrawWallet;
        return true;
    }

    function addTokenBalance(address account, uint256 amount) external onlyOwner returns (bool) {
        _addTokenBalance(account, amount);
        return true;
    }

    function addLevel2UsdtBalance(address account,uint256 amount) external onlyOwner returns (bool) {
        _addLevel2UsdtBalance(account,amount);
        return true;
    }

    function setNftLottyWinningRandom(uint256 value) external onlyOwner returns (bool) {
        nftLottyWinningRandom = value;
        return true;
    }

    function setNftOnceMintTotal(uint256 value) external onlyOwner returns (bool) {
        nftOnceMintTotal = value;
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

    function setNftTotalSupply(uint256 _nftTotalSupply) external onlyOwner returns (bool){
        nftTotalSupply = _nftTotalSupply;
        return true;
    }

    function getTotalCount(address account) external view returns (uint256) {
        return _binders[account].length;
    }

    function getValidCount(address account) external view returns (uint256) {
        return _validBinders[account].length;
    }

    function getTokenIdCounterCurrent() external view returns (uint256){
        return _tokenIdCounter.current();
    }
}

abstract  contract AbsBizUtil is AbsBizVarUtil {
    using Counters for Counters.Counter;

    event BindInvitor(address indexed from, address indexed to);
    event IDOLevel1(address indexed from, address indexed to, uint256 value,uint256 amount);
    event IDOLevel2(address indexed from, address indexed to, uint256 value,uint256 amount);

    event NFTWithdrawToken(address indexed to, uint256 tokenId);
    event NFTWithdrawFail(address indexed from, address indexed to, uint256 tokenId);
    event NFTWithdrawMaxTokenId(address indexed to, uint256 tokenId);
    event BoxLottyWinning(address indexed user, uint256 amount);

    constructor(address _collectWallet, address _withdrawWallet, address _nft, address _token, address _usdt) {
        collectWallet = _collectWallet;
        withdrawWallet = _withdrawWallet;
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
        if(member[account]){
            return false;
        }

        member[account] = true;

        _tokenTransfer(usdt, account, level1UsdtQuantity);
        _upgradeCommon(account,level1TokenQuantity);
        emit IDOLevel1(account, collectWallet, level1UsdtQuantity,level1TokenQuantity);
        return true;
    }

    function upgradeLevel2() external returns (bool) {
        address account = msg.sender;

        if (member[account]) {
            return false;
        }
        member[account] = true;

        _tokenTransfer(usdt, account, level2UsdtQuantity);
        _upgradeCommon(account, level2TokenQuantity);
        _level2[account] = true;
        emit IDOLevel2(account, collectWallet, level2UsdtQuantity, level2TokenQuantity);
        return true;
    }

    function boxLottery() external returns (uint256){
        address account = msg.sender;
        if (boxBalance[account] > 0) {
            return 2;
        }

        _subBoxBalance(account, 1);
        if (rand(100) == nftLottyWinningRandom) {
            _addNFT(account, 1);
            emit BoxLottyWinning(account, 1);
            return 1;
        }
        return 3;
    }

    function _addValidBinder(address account,address invitor) private {
        _validBinders[invitor].push(account);
    }

    function _upgradeCommon(address account,uint256 tokenQuantity) private {
        _addTokenBalance(account, tokenQuantity);
        _addBoxBalance(account,1);

        address inviter = _inviter[account];
        if (inviter != address(0)) {
            _addValidBinder(account, inviter);
            if (_level2[inviter]) {
                _addLevel2UsdtBalance(inviter, level2UsdtQuantity / 10);
            }

            if (_validBinders[inviter].length != 0 && _validBinders[inviter].length % 10 == 0) {
                _addNFT(inviter, 1);
            }
        }
    }

    function miniNFT() external returns(bool) {
        address account = msg.sender;
        uint256 count = nftBalance[account];
        if (count == 0) {
            return false;
        }
       uint256 currentTotal = count > nftOnceMintTotal ? nftOnceMintTotal : count;
        _subNFT(account, currentTotal);
        nftBalance[account] = 0;
        for (uint256 i = 0; i < currentTotal; i++) {
            _miniNFT(account);
        }
        return true;
    }

    function _miniNFT(address account) internal returns (bool) {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        if (tokenId > nftTotalSupply) {
            emit NFTWithdrawMaxTokenId( account, tokenId);
            return false;
        }
        if (nft.ownerOf2(tokenId) == address(0)) {
            nft.mintIdo(account, tokenId);
            emit NFTWithdrawToken(account, tokenId);
        }
        return _miniNFT(account);
    }

    function _tokenTransfer(address token, address from, uint256 amount) internal returns (bool) {
        return IERC20(token).transferFrom(from, collectWallet, amount);
    }

    function withdrawToken() external returns (uint256){
        require(tokenRewardTime > block.timestamp, "token reward time is fail " );

        address account = msg.sender;
        uint256 balance = tokenBalance[account];
        if (balance <= 0) {
            return 2;
        }
        return _withdrawToken(token, account, balance);
    }

    function withdrawUsdt() external returns (uint256){
        address account = msg.sender;
        uint256 balance = level2UsdtBalance[account];
        if (balance <= 0) {
            return 2;
        }
        return _withdrawToken(usdt, account, balance);
    }

    function claimToken(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(token).transfer(msg.sender, balance);
        }
    }
}

contract Util is AbsBizUtil {
    constructor() AbsBizUtil (
    //collect wallet
        address(0x5C74486e22c2E5C4F2D2514F5B294b11d5d0aBC4),
    //withdraw wallet
        address(0x0D1929c58aF88AD2EcfF7FEC715b6B5A9c1228d0),
    //nft
        address(0x12E49021C4dbCa6aDe18d06b4aff530eC1813C26),
    //token
        address(0x8de03381b78Fab5d3e27c7F7618d4BB9AbC3f163),
    //usdt
        address(0xbfA3855535Db097319b622eCb88083492FA16A5b)
    ){}
}