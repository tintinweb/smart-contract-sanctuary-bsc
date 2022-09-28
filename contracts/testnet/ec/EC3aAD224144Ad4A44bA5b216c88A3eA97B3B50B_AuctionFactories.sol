/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// File: contracts/dutchAuction.sol



pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

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

contract DutchAuction is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public _contributions;

    bool public immutable fee_option;
    bool public immutable isWhitelist;
    bool public immutable refundType;
    address public immutable tokenAddress;
    address public immutable payToken;
    address public immutable router;
    address payable public immutable seller;
    address[] public whitelist;
    mapping(address => bool) public existWhiteList;

    uint256 public sellingAmount;
    uint256 private _weiRaised;
    uint256 public immutable startingPrice;
    uint256 public immutable endPrice;
    uint256 public softcap;
    uint256 public hardcap;
    uint256 public immutable decreaseRate;
    uint256 public immutable liquidity;
    uint256 public immutable liqlock;
    uint256 public immutable startAt;
    uint256 public immutable expiresAt;

    string[] public sociallinks;

    event TokensPurchased(address purchaser, uint256 value, uint256 amount);

    // flags: [fee_option, isWhitelist, refundType]
    // addresses: [tokenAddress, payToken, router, seller]
    // initialInfo: [sellingAmount, startprice, endprice ,softcap,hardcap, decreaseRate, liquidity, liqlock, startat, expiresat]
    constructor(
        bool[] memory flags,
        address[] memory _addresses,
        uint256[] memory _initialInfo,
        string[] memory _siteInfo
    ) {
        fee_option = flags[0];
        isWhitelist = flags[1];
        refundType = flags[2];

        tokenAddress = _addresses[0];
        payToken = _addresses[1];
        router = _addresses[2];
        seller = payable(_addresses[3]);
        require(seller != address(0), "Seller can't be address 0");
        require(router != address(0), "Router can't be address 0");

        sellingAmount = _initialInfo[0];
        startingPrice = _initialInfo[1];
        endPrice = _initialInfo[2];
        softcap = _initialInfo[3];
        hardcap = _initialInfo[4];
        decreaseRate = _initialInfo[5];
        liquidity = _initialInfo[6];
        liqlock = _initialInfo[7];
        startAt = _initialInfo[8];
        expiresAt = _initialInfo[9];
        require(
            softcap * 5 >= hardcap,
            "Softcap must great than 20% of hardcap"
        );
        require(
            hardcap <= IERC20(tokenAddress).totalSupply() * startingPrice,
            "Hardcap can't great than max supply"
        );
        require(liquidity > 50);
        sociallinks = _siteInfo;
    }

    function addWhiteList(address[] memory _buyers)
        external
        onlyTokenOwner
        returns (bool)
    {
        require(isWhitelist, "you didn't sent whitelist option.");
        for (uint256 i; i < _buyers.length; i++) {
            whitelist.push(_buyers[i]);
            existWhiteList[_buyers[i]] = true;
        }
        return true;
    }

    function removeWhiteList(address[] memory _buyers)
        external
        onlyTokenOwner
        returns (bool)
    {
        require(isWhitelist, "you didn't sent whitelist option.");
        for (uint256 i; i < _buyers.length; i++) {
            for (uint256 j; j < whitelist.length; j++) {
                if (_buyers[i] == whitelist[j]) {
                    delete whitelist[j];
                    break;
                }
            }
            existWhiteList[_buyers[i]] = false;
        }
        return true;
    }

    function getPrice() public view activeAuction returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 discount = (decreaseRate * timeElapsed) / 60;
        uint256 earning = IERC20(tokenAddress).balanceOf(address(this)) +
            sellingAmount.mul(startingPrice - discount);
        if (earning >= softcap) return startingPrice - discount;
        else
            return
                (softcap - IERC20(tokenAddress).balanceOf(address(this))).div(
                    sellingAmount
                );
    }

    function getTokenAmount(uint256 weiAmount) public view returns (uint256) {
        return weiAmount.div(getPrice());
    }

    function buyToken() external payable nonReentrant {
        require(msg.value >= 0, "Value is zoer");
        require(
            isWhitelist && existWhiteList[msg.sender],
            "You are not whitelist"
        );
        require((_weiRaised + msg.value) <= hardcap, "Hard Cap reached");
        uint256 tokens = getTokenAmount(msg.value);
        _weiRaised = _weiRaised.add(msg.value);
        sellingAmount = sellingAmount - tokens;
        require(sellingAmount > 0, "Selling amount is zero");
        _contributions[msg.sender] = _contributions[msg.sender].add(tokens);
        IERC20(payToken).transferFrom(msg.sender, address(this), msg.value);
        emit TokensPurchased(_msgSender(), msg.value, tokens);
    }

    function claimTokens() external endAuction {
        require(_contributions[msg.sender] > 0, "Not enough amount to claim");
        uint256 tokensAmt = _contributions[msg.sender];
        _contributions[msg.sender] = 0;
        IERC20(tokenAddress).transfer(msg.sender, tokensAmt);
    }

    function withdraw() external onlyTokenOwner endAuction {
        require(address(this).balance > 0, "Contract has no money");
        seller.transfer(address(this).balance);
    }

    function takeTokens() public onlyTokenOwner endAuction {
        IERC20 token_ = IERC20(tokenAddress);
        uint256 tokenAmt = token_.balanceOf(address(this));
        require(tokenAmt > 0, "ERC20 balance is 0");
        token_.transfer(seller, tokenAmt);
    }

    modifier activeAuction() {
        require(block.timestamp <= expiresAt, "Expired");
        require(block.timestamp >= startAt, "Not started yet.");
        require(sellingAmount > 0, "Selleing amount is zera");
        _;
    }
    modifier endAuction() {
        require(block.timestamp >= expiresAt + liqlock);
        _;
    }
    modifier onlyTokenOwner() {
        require(msg.sender == seller, "Admin can withdraw only");
        _;
    }
}

// File: contracts/auctionFactory.sol



pragma solidity ^0.8.16;


contract AuctionFactories is Ownable {
    address private adminWallet;
    mapping(address => DutchAuction[]) public auctionsforOwner;
    DutchAuction[] public auctionList;
    uint256 private priceAuction = 0.01 ether;
    function setAdminWallet (address _wallet) public onlyOwner {
        adminWallet = _wallet;
    }
    function setPriceAuction(uint256 _price) public onlyOwner {
        priceAuction = _price;
    }

    function CreateNewAuction(
        address _token,
        uint256 _tokenDecimals,
        bool[] calldata flags,
        address[] calldata _addresses,
        uint256[] calldata initialInfo,
        string[] calldata siteInfo
    ) public payable returns (address) {
        require(msg.value >= priceAuction, "Amount is not enough");
        DutchAuction auction = new DutchAuction(
            flags, _addresses, initialInfo, siteInfo
        );
        IERC20(_token).transferFrom(msg.sender, address (auction), initialInfo[0]* 10** _tokenDecimals);
        auctionList.push(auction);
        auctionsforOwner[msg.sender].push(auction);
        return address(auction);
    }

    function getAuctionList() public view returns (DutchAuction[] memory) {
        return auctionList;
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "Contract has no money");
        payable (adminWallet).transfer(address(this).balance);
    }
}