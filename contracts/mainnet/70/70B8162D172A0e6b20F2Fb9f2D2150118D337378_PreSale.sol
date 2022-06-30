/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface INFT {
    function batchMint(address to, uint256 num, uint256 property) external;
}

interface IToken {
    function bindInvitor(address account, address invitor) external;
}

abstract contract AbsPreSale is Ownable {
    struct PresaleInfo {
        uint256 price;
        uint256 qty;
        uint256 soldCount;
        uint256 perTokenAmount;
        uint256 saleTokenTotal;
        uint256 inviteTokenTotal;

        uint256 partnerPrice;
        uint256 partnerQty;
        uint256 partnerSoldCount;
        uint256 partnerTokenAmount;
        uint256 partnerExitBinder;
    }

    struct UserInfo {
        bool active;
        uint256 presaleAmount;
        uint256 presaleTokenAmount;
        uint256 partnerAmount;
        uint256 partnerTokenAmount;
        bool partnerExit;
        bool partnerTokenBuy;
        uint256 pendingTokenAmount;
        uint256 claimedTokenAmount;
        uint256 inviteTokenAmount;
        uint256 teamTokenAmount;
    }

    address private _usdtAddress;
    address public _cashAddress;
    address private _tokenAddress;

    bool private _pauseBuy = false;
    bool private _pauseClaim = true;

    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;

    address[] public _userList;

    PresaleInfo private _presaleInfo;
    mapping(address => UserInfo) private _userInfo;
    uint256 private _inviteFee = 5;

    INFT public _NFT;
    uint256 private _endTime;

    constructor(address UsdtAddress, address TokenAddress, address NFTAddress, address CashAddress){
        _usdtAddress = UsdtAddress;
        _cashAddress = CashAddress;
        _tokenAddress = TokenAddress;
        _NFT = INFT(NFTAddress);

        uint256 usdtDecimals = 10 ** IERC20(UsdtAddress).decimals();
        uint256 tokenDecimals = 10 ** IERC20(TokenAddress).decimals();

        _presaleInfo.price = 20 * usdtDecimals;
        _presaleInfo.perTokenAmount = 2600 * tokenDecimals;
        _presaleInfo.qty = 50000;

        _presaleInfo.partnerPrice = 50 * usdtDecimals;
        _presaleInfo.partnerTokenAmount = 6500 * tokenDecimals;
        _presaleInfo.partnerQty = 5000;

        _presaleInfo.partnerExitBinder = 10;

        _endTime = block.timestamp + 864000;
    }

    function buy(address invitor) external _onlyNonContract {
        require(!_pauseBuy, "pauseBuy");
        require(_presaleInfo.qty > _presaleInfo.soldCount, "notQty");

        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(userInfo.presaleAmount == 0, "only1");

        if (!userInfo.active) {
            _userList.push(account);

            if (_userInfo[invitor].active) {
                _inviter[account] = invitor;
                _binders[invitor].push(account);
                IToken(_tokenAddress).bindInvitor(account, invitor);
            }
            userInfo.active = true;
        }

        _presaleInfo.soldCount += 1;

        uint256 price = _presaleInfo.price;
        userInfo.presaleAmount = price;
        IERC20 usdt = IERC20(_usdtAddress);
        usdt.transferFrom(account, _cashAddress, price);

        uint256 tokenAmount = _presaleInfo.perTokenAmount;
        _presaleInfo.saleTokenTotal += tokenAmount;

        invitor = _inviter[account];
        if (address(0) != invitor) {
            UserInfo storage invitorInfo = _userInfo[invitor];
            invitorInfo.teamTokenAmount += tokenAmount;
            uint256 inviterAmount = tokenAmount * _inviteFee / 100;
            if (inviterAmount > 0) {
                invitorInfo.inviteTokenAmount += inviterAmount;
                invitorInfo.pendingTokenAmount += inviterAmount;
                _presaleInfo.inviteTokenTotal += inviterAmount;
            }
            if (invitorInfo.partnerAmount > 0 && !invitorInfo.partnerExit && _presaleInfo.partnerExitBinder <= _binders[invitor].length) {
                invitorInfo.partnerExit = true;
                IERC20(_usdtAddress).transfer(invitor, invitorInfo.partnerAmount);
                _NFT.batchMint(invitor, 1, 1);
            }
        }
        userInfo.pendingTokenAmount += tokenAmount;
        userInfo.presaleTokenAmount += tokenAmount;
    }

    function joinPartner() external _onlyNonContract {
        require(!_pauseBuy, "notStart");
        require(_presaleInfo.partnerQty > _presaleInfo.partnerSoldCount, "notQty");

        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(userInfo.partnerAmount == 0, "only1");
        require(userInfo.active, "not active");

        uint256 partnerPrice = _presaleInfo.partnerPrice;
        userInfo.partnerAmount = partnerPrice;
        userInfo.partnerTokenAmount = _presaleInfo.partnerTokenAmount;

        _presaleInfo.partnerSoldCount += 1;

        IERC20 usdt = IERC20(_usdtAddress);
        usdt.transferFrom(account, address(this), partnerPrice);
    }

    function buyPartner() external {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        require(!userInfo.partnerTokenBuy, "bought");
        require(userInfo.partnerExit, "not partnerAmount");
        userInfo.partnerTokenBuy = true;
        uint256 partnerAmount = userInfo.partnerAmount;
        uint256 partnerTokenAmount = userInfo.partnerTokenAmount;
        userInfo.pendingTokenAmount += partnerTokenAmount;
        userInfo.presaleTokenAmount += partnerTokenAmount;
        IERC20 usdt = IERC20(_usdtAddress);
        usdt.transferFrom(account, _cashAddress, partnerAmount);
    }

    function claim() external {
        require(!_pauseClaim, "pauseClaim");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingToken = userInfo.pendingTokenAmount;
        userInfo.pendingTokenAmount = 0;
        userInfo.claimedTokenAmount += pendingToken;
        IERC20(_tokenAddress).transfer(account, pendingToken);
    }

    function getPresaleInfo() external view returns (
        uint256 price, uint256 perTokenAmount,
        uint256 qty, uint256 soldCount,
        bool pauseBuy, uint256 inviteFee,
        uint256 totalPresaleToken, uint256 totalInviteToken
    ) {
        price = _presaleInfo.price;
        perTokenAmount = _presaleInfo.perTokenAmount;
        qty = _presaleInfo.qty;
        soldCount = _presaleInfo.soldCount;
        pauseBuy = _pauseBuy;
        inviteFee = _inviteFee;
        totalPresaleToken = _presaleInfo.saleTokenTotal;
        totalInviteToken = _presaleInfo.inviteTokenTotal;
    }

    function getPartnerInfo() external view returns (
        uint256 partnerPrice, uint256 partnerTokenAmount,
        uint256 partnerQty, uint256 partnerSoldCount,
        bool pauseBuy, uint256 inviteFee, uint256 partnerExitBinder
    ) {
        partnerPrice = _presaleInfo.partnerPrice;
        partnerTokenAmount = _presaleInfo.partnerTokenAmount;
        partnerQty = _presaleInfo.partnerQty;
        partnerSoldCount = _presaleInfo.partnerSoldCount;
        pauseBuy = _pauseBuy;
        inviteFee = _inviteFee;
        partnerExitBinder = _presaleInfo.partnerExitBinder;
    }

    function infoExt() external view returns (
        address usdt, uint256 usdtDecimals, string memory usdtSymbol,
        address token, uint256 tokenDecimals, string memory tokenSymbol,
        uint256 endTime, uint256 blockTime
    ) {
        usdt = _usdtAddress;
        usdtDecimals = IERC20(usdt).decimals();
        usdtSymbol = IERC20(usdt).symbol();
        token = _tokenAddress;
        tokenDecimals = IERC20(token).decimals();
        tokenSymbol = IERC20(token).symbol();
        endTime = _endTime;
        blockTime = block.timestamp;
    }

    function getUserInfo(address account) external view returns (
        bool active, uint256 presaleAmount, uint256 partnerAmount,
        uint256 pendingTokenAmount, uint256 claimedTokenAmount,
        bool partnerExit, bool partnerBought, uint256 presaleTokenAmount
    ) {
        UserInfo storage userInfo = _userInfo[account];
        active = userInfo.active;
        presaleAmount = userInfo.presaleAmount;
        partnerAmount = userInfo.partnerAmount;
        pendingTokenAmount = userInfo.pendingTokenAmount;
        claimedTokenAmount = userInfo.claimedTokenAmount;
        partnerExit = userInfo.partnerExit;
        partnerBought = userInfo.partnerTokenBuy;
        presaleTokenAmount = userInfo.presaleTokenAmount;
    }

    function getUserExtInfo(address account) external view returns (
        uint256 inviteTokenAmount, uint256 fistBalance,
        uint256 partnerTokenAmount, uint256 teamTokenAmount,
        uint256 teamNum
    ) {
        UserInfo storage userInfo = _userInfo[account];
        inviteTokenAmount = userInfo.inviteTokenAmount;
        fistBalance = IERC20(_usdtAddress).balanceOf(account);
        partnerTokenAmount = userInfo.partnerTokenAmount;
        teamTokenAmount = userInfo.teamTokenAmount;
        teamNum = _binders[account].length;
    }

    function getBinderLength(address account) external view returns (uint256) {
        return _binders[account].length;
    }

    function getUserListLength() external view returns (uint256){
        return _userList.length;
    }

    modifier _onlyNonContract(){
        require(tx.origin == msg.sender);
        _;
    }

    receive() external payable {}

    function claimBalance(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }

    function withdrawToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20 erc20 = IERC20(token);
        erc20.transfer(to, amount);
    }

    function setCashAddress(address cashAddress) external onlyOwner {
        _cashAddress = cashAddress;
    }

    function setUsdtAddress(address usdtAddress) external onlyOwner {
        _usdtAddress = usdtAddress;
    }

    function setTokenAddress(address tokenAddress) external onlyOwner {
        _tokenAddress = tokenAddress;
    }

    function setPauseBuy(bool pauseBuy) external onlyOwner {
        _pauseBuy = pauseBuy;
    }

    function setPerTokenAmount(uint256 amount) external onlyOwner {
        _presaleInfo.perTokenAmount = amount * 10 ** IERC20(_tokenAddress).decimals();
    }

    function setQty(uint256 qty) external onlyOwner {
        _presaleInfo.qty = qty;
    }

    function setPrice(uint256 price) external onlyOwner {
        _presaleInfo.price = price * 10 ** IERC20(_usdtAddress).decimals();
    }

    function setPartnerPerTokenAmount(uint256 amount) external onlyOwner {
        _presaleInfo.partnerTokenAmount = amount * 10 ** IERC20(_tokenAddress).decimals();
    }

    function setPartnerQty(uint256 qty) external onlyOwner {
        _presaleInfo.partnerQty = qty;
    }

    function setPartnerPrice(uint256 price) external onlyOwner {
        _presaleInfo.partnerPrice = price * 10 ** IERC20(_usdtAddress).decimals();
    }

    function setPartnerExitBinder(uint256 count) external onlyOwner {
        _presaleInfo.partnerExitBinder = count;
    }

    function setNFT(address nft) external onlyOwner {
        _NFT = INFT(nft);
    }

    function setPauseClaim(bool pauseClaim) external onlyOwner {
        _pauseClaim = pauseClaim;
    }
}

contract PreSale is AbsPreSale {
    constructor() AbsPreSale(
    //USDT
        address(0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A),
    //Token
        address(0x016cb50075D5b45bb934dCEd60EA2D2Dd78635Ef),
    //NFT
        address(0x92Efd62351cb49eF9A54Ac225717871B0bd20531),
    //Cash
        address(0xE8751579CadC8D85fA33a345E8cdB5484FD987A0)
    ){

    }
}