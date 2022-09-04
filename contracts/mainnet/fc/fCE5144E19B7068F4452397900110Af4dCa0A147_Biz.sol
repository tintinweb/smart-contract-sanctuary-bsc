/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT

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

    function resetValue(Counter storage counter,uint256 value) internal {
        counter._value = value;
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

interface INFT {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function ownerOf2(uint256 tokenId) external view returns (address owner);
    function mintTo(address _to, uint _level) external;
}

abstract contract AbsBizVarUtil is Ownable, Context {
    using Counters for Counters.Counter;

    address public collectWallet;
    address public withdrawWallet;
    address public token;
    uint256 public tokenDecimals = 18;
    uint256 public usdtDecimals = 18;
    address public usdt;

    uint256 public tokenRewardTime = block.timestamp;
    uint256 public idoEndTime = 1662984000;

    uint256 public nftTotalSupply = 10000;
    uint public nftLottyWinningRandom = 50;

    uint256 public level1UsdtQuantity = 28 * 10 ** uint256(usdtDecimals);
    uint256 public level1TokenQuantity = 56 * 10 ** uint256(tokenDecimals);
    uint256 public level2UsdtQuantity = 128 * 10 ** uint256(usdtDecimals);
    uint256 public level2TokenQuantity = 256 * 10 ** uint256(tokenDecimals);

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

    INFT public nft;
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

    function _withdrawToken(address transferToken,address to,uint256 amount) internal returns(bool){
        require(IERC20(transferToken).balanceOf(withdrawWallet) >= amount, "token balanceOf error 3");
        require(IERC20(transferToken).allowance(withdrawWallet, address(this))  >= amount, "token allowance error 4");

        uint256 balance1 = 0;
        if (transferToken == usdt) {
            balance1 = level2UsdtBalance[to];
        } else if (transferToken == token) {
            balance1 = tokenBalance[to];
        }

        require(balance1 > 0, "token balance1 error 2");
        require(amount == balance1, "amount not eq balance1 5");

        if (transferToken == usdt) {
            level2UsdtBalance[to] = 0;
        } else if (transferToken == token) {
            tokenBalance[to] = 0;
        }

        if (IERC20(transferToken).transferFrom(withdrawWallet, to, balance1)) {
            emit WithdrawSuccess(transferToken, withdrawWallet, to, balance1);
            return true;
        } else {
            emit WithdrawFail(transferToken, withdrawWallet, to, balance1);
            return false;
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

    function setLevel1UsdtQuantity(uint256 amount) external onlyOwner {
        level1UsdtQuantity = amount;
    }

    function setLevel2UsdtQuantity(uint256 amount) external onlyOwner {
        level2UsdtQuantity = amount;
    }

    function setLevel1TokenQuantity(uint256 amount) external onlyOwner {
        level2UsdtQuantity = amount;
    }

    function setCollectWallet(address _collectWallet) external onlyOwner {
        collectWallet = _collectWallet;
    }

    function setWithdrawWallet(address _withdrawWallet) external onlyOwner {
        withdrawWallet = _withdrawWallet;
    }

    function addTokenBalance(address account, uint256 amount) external onlyOwner {
        _addTokenBalance(account, amount);
    }

    function addBoxBalance(address account, uint256 amount) external onlyOwner {
        _addBoxBalance(account, amount);
    }

    function addLevel2UsdtBalance(address account,uint256 amount) external onlyOwner {
        _addLevel2UsdtBalance(account,amount);
    }

    function setNftLottyWinningRandom(uint256 value) external onlyOwner  {
        nftLottyWinningRandom = value;
    }

    function setUsdt(address _usdt) external onlyOwner {
        usdt = _usdt;
    }

    function setToken(address _token) external onlyOwner {
        token = _token;
    }

    function setNFT(address _nft) external onlyOwner {
        nft = INFT(_nft);
    }

    function setNftTotalSupply(uint256 _nftTotalSupply) external onlyOwner {
        nftTotalSupply = _nftTotalSupply;
    }

    function resetTokenIdCounterValue(uint256 value) external onlyOwner {
        _tokenIdCounter.resetValue(value);
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

    function setIdoEndTime(uint256 _idoEndTime) external onlyOwner {
        idoEndTime = _idoEndTime;
    }

    function setTokenRewardTime(uint256 _tokenRewardTime) external onlyOwner {
        tokenRewardTime = _tokenRewardTime;
    }
}

contract Random {
    function random(uint number,address account) public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,account))) % number;
    }
}

abstract  contract AbsBizUtil is Random,AbsBizVarUtil {
    using Counters for Counters.Counter;

    event BindInvitor(address indexed from, address indexed to);
    event IDOLevel1(address indexed from, address indexed to, uint256 value,uint256 amount);
    event IDOLevel2(address indexed from, address indexed to, uint256 value,uint256 amount);

    event NFTWithdrawToken(address indexed to, uint256 tokenId);
    event NFTWithdrawFail(address indexed from, address indexed to, uint256 tokenId);
    event BoxLottyWinning(address indexed user, uint256 amount);

    uint8[] public levelCount = [100, 100, 100];

    constructor(address _collectWallet, address _withdrawWallet, address _nft, address _token, address _usdt) {
        collectWallet = _collectWallet;
        withdrawWallet = _withdrawWallet;
        token = _token;
        usdt = _usdt;
        nft = INFT(_nft);

        IERC20(_token).approve(_withdrawWallet, 10000 * 10 * tokenDecimals);
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

    function upgradeLevel1() external {
        require(idoEndTime > block.timestamp, "ido end time 2");

        address account = msg.sender;
        require(!member[account], "user is upgraded");

        member[account] = true;

        _tokenTransfer(usdt, account, level1UsdtQuantity);
        _upgradeCommon(account,level1TokenQuantity,level1UsdtQuantity);
        emit IDOLevel1(account, collectWallet, level1UsdtQuantity,level1TokenQuantity);
    }

    function upgradeLevel2() external {
        require(idoEndTime > block.timestamp, "ido end time 2");

        address account = msg.sender;
        require(!member[account], "user is upgraded");

        member[account] = true;

        _tokenTransfer(usdt, account, level2UsdtQuantity);
        _upgradeCommon(account, level2TokenQuantity, level2UsdtQuantity);
        _level2[account] = true;
        emit IDOLevel2(account, collectWallet, level2UsdtQuantity, level2TokenQuantity);
    }

    function boxLottery() external {
        address account = msg.sender;
        require(boxBalance[account] > 0, "balance is zero 2");

        _subBoxBalance(account, 1);

        if (random(100,account) == nftLottyWinningRandom) {
            _addNFT(account, 1);
            emit BoxLottyWinning(account, 1);
        }
    }

    function _addValidBinder(address account,address invitor) private {
        _validBinders[invitor].push(account);
    }

    function _upgradeCommon(address account,uint256 tokenQuantity,uint256 usdtQuantity) private {
        _addTokenBalance(account, tokenQuantity);
        _addBoxBalance(account,1);

        address inviter = _inviter[account];
        if (inviter != address(0)) {
            _addValidBinder(account, inviter);
            if (_level2[inviter]) {
                _addLevel2UsdtBalance(inviter, usdtQuantity / 10);
            }

            if(member[inviter]){
                if (_validBinders[inviter].length != 0 && _validBinders[inviter].length % 10 == 0) {
                    _addNFT(inviter, 1);
                }
            }
        }
    }

    function miniNFT() external  {
        address account = msg.sender;
        require(nftBalance[account] > 0, "balance is zero 4");
        _miniNFT(account);
    }

    function _miniNFT(address account) private {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        require(nftTotalSupply > tokenId , "tokenId gt nftTotalSupply 2");
        require(nft.ownerOf2(tokenId) == address(0), "tokenId has owner 3");

        _subNFT(account, 1);

        //tokenId
        uint _tokenType = _miniTokenType(account);

        nft.mintTo(account, _tokenType);
        emit NFTWithdrawToken(account, tokenId);
    }

    function _miniTokenType(address _to) private returns (uint){
        uint _type = random(2, _to);

        if (levelCount[_type] == 0) {
            for (uint256 i = 0; i < 2; i++) {
                if (levelCount[i] > 0) {
                    _type = i;
                }
            }
        }

        levelCount[_type] = levelCount[_type] - 1;
        return _type;
    }

    function _tokenTransfer(address token, address from, uint256 amount) private returns (bool) {
        return IERC20(token).transferFrom(from, collectWallet, amount);
    }

    function withdrawToken() external {
        require(tokenRewardTime < block.timestamp, "token reward time is fail 7" );

        address account = msg.sender;
        uint256 balance = tokenBalance[account];

        require(balance > 0, "balance is zero 2");
        bool success = _withdrawToken(token, account, balance);

        require(success, "transfer fail is 6");
    }

    function claimToken(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(token).transfer(msg.sender, balance);
        }
    }

    function getInvitor(address owner)  view external returns (address){
        return _inviter[owner];
    }
}

contract Biz is AbsBizUtil {
    constructor() AbsBizUtil (
    //collect wallet
        address(0x5fcB1aBBc5A49FFC5c0dd0Fd0474B2B828280012),
    //withdraw wallet
        address(0x5fcB1aBBc5A49FFC5c0dd0Fd0474B2B828280012),
    //nft
        address(0xA9CACADEb80162496838435c0Db0E45B3A4cc4C0),
    //token
        address(0x586837c7C21325a0DD1DB5B3FACDE725Ae28A5bF),
    //usdt
        address(0x8e4D0f6B489376b8F3ffc4aBaeC103D6bD117778)
    ){
    }
}