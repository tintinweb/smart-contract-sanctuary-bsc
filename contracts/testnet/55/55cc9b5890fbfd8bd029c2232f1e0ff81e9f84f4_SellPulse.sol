// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <=0.8.0;
pragma abicoder v2;

import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IERC20.sol";
import "./ReentrancyGuard.sol";
import "./Pausable.sol";

contract SellPulse is Ownable, Pausable, ReentrancyGuard{

    using SafeMath for uint256;

    uint256 public MIN_BUY;
    uint256 public MAX_BUY;

    address payable public SALE_WALLET_LOCK_LOAD;
    address payable public SALE_WALLET_PRE_SALE;

    IERC20 public BUY_TOKEN;

    struct Package {
        uint256 totalToken;
        uint256 price;
        uint256 startTime;
        uint256 finishTime;
    }

    struct User {
        uint256 totalBuyAmount;
    }

    mapping(address => User) public userInfos;
    mapping(uint256 => Package) public packages;

    event TokenPurchase(address indexed purchaser, uint256 packageId, uint256 amountNative, uint256 amountToken);

    constructor(address _buyToken) {
        MIN_BUY = 0.1 ether;
        MAX_BUY = 4 ether;
        
        BUY_TOKEN = IERC20(_buyToken);
        packages[1] = Package(250000 ether, 0.000004000 ether, block.timestamp, block.timestamp.add(2592000));
        packages[2] = Package(125000 ether, 0.000008000 ether, block.timestamp, block.timestamp.add(2592000));
        SALE_WALLET_LOCK_LOAD = 0xaABa2D2a2078ec9cd47a530a6a1E824390727Df8;
        SALE_WALLET_PRE_SALE = 0x9a47142aacB5127Cde57b1d9940A547578C3c990;
    }
    
    function setMinBuy(uint256 _fee) public onlyOwner {
        MIN_BUY = _fee;
    }

    function setMaxBuy(uint256 _fee) public onlyOwner {
        MAX_BUY = _fee;
    }

    function setBuyToken(address _address) public onlyOwner {
        BUY_TOKEN = IERC20(_address);
    }

    function setSaleWalletLock(address payable _wallet) public onlyOwner {
        SALE_WALLET_LOCK_LOAD = _wallet;
    }

    function setSaleWalletPre(address payable _wallet) public onlyOwner {
        SALE_WALLET_PRE_SALE = _wallet;
    }

    function updatePackage(uint256 packageId, Package memory package) public onlyOwner {
        packages[packageId] = package;
    }

    /**
     * @dev buyToken
     */
    function buyToken(uint256 packageId, uint256 _amountBuyToken)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        _buy(packageId, _msgSender(), _amountBuyToken);
    }

    /**
     * @dev _buy
     */
    function _buy(
        uint256 packageId,
        address _beneficiary,
        uint256 _amountBuyToken
    ) internal {
        require(
            block.timestamp >= packages[packageId].startTime,
            "Sale has not started yet."
        );
        require(
            block.timestamp <= packages[packageId].finishTime,
            "Sale already ended"
        );
        require(msg.value == _amountBuyToken, "Amount not correct");
        require(_amountBuyToken >= MIN_BUY, "Amount too low");
        User storage user = userInfos[_beneficiary];
        Package memory package = packages[packageId];
        require(_amountBuyToken.add(user.totalBuyAmount) <= MAX_BUY, "Amount too hight");
        user.totalBuyAmount = user.totalBuyAmount.add(_amountBuyToken);
        _deliverTokens(packageId);
        emit TokenPurchase(_beneficiary, packageId, _amountBuyToken, _amountBuyToken.div(package.price));
    }

    function _deliverTokens(uint256 packageId)
        internal
    {
        if(packageId == 1) {
            SALE_WALLET_LOCK_LOAD.transfer(msg.value);
        }
        if(packageId == 2) {
            SALE_WALLET_PRE_SALE.transfer(msg.value);
        }
    }

    function getUserInfo(address _userAddress)
        public
        view
        returns (User memory user)
    {
        user = userInfos[_userAddress];
    }

    /**
     * @dev Withdraw bnb from this contract (Callable by owner only)
     */
    function handleForfeitedBalance(
        address coinAddress,
        uint256 value,
        address payable to
    ) public onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }
}