/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract Presale is ReentrancyGuard, Context, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public _contributions;

    IERC20 private _token;
    uint256 private _tokenDecimals;
    // кошелек куда будет списываться бабки
    address payable public _wallet;
    // количество токенов за 1 wei
    uint256 private _rate;
    // собранные средства в веях 1б=10 10_18
    uint256 private _weiRaised;
    // дата конца ико
    uint256 private endICO;
    // минимальная цена покупки в веях
    uint256 private minPurchase;
    // максимальная цена покупки в веях
    uint256 private maxPurchase;
    // максимально возможный сбор средств
    uint256 private hardCap;
    // минимальный сбор средств
    uint256 private softCap;
    uint256 private availableTokens;

    function getTotalAvailableTokens() external view returns(uint256)
    {
        return _getTokenAmount(_weiRaised) + availableTokens;
    }

    function getAvailableTokens() external view returns(uint256)
    {
        return availableTokens;
    }

    // начать возврат
    bool public startRefund = false;
    //
    uint256 public refundStartDate;

    event TokensPurchased(
        address purchaser,
        address beneficiary,
        uint256 value,
        uint256 amount
    );
    
    event Refund(address recipient, uint256 amount);

    constructor(address payable wallet, IERC20 token) {
        require(wallet != address(0), "Pre-Sale: wallet is the zero address");
        require(
            address(token) != address(0),
            "Pre-Sale: token is the zero address"
        );

        _wallet = wallet;
        _token = token;
        _tokenDecimals = IERC20Metadata(address(token)).decimals();
    }

    receive() external payable {
        if (endICO > 0 && block.timestamp < endICO) {
            buyTokens(_msgSender());
        } else {
            endICO = 0;
            revert("Pre-Sale is closed");
        }
    }

    // создается токен сразу с чеканенными монетами
    // со смарта токены для пресэйла начисляются на контракт пресэйла (трансфер функция)
    // на смарте пресейла вызывается функция с руки старт ИКО
    // по окончанию пресейла заливается ликвиндность
    // на смарте вызывается метод клаимТокен (всем кто купил токены, отправляются токены на кошельки, если токенов было куплено больше софткапа)
    // пользователи могут вернуть средства? метод рефюд

    // токен торгуется, нельза давать продавать больше

    //tge

    //Start Pre-Sale
    // all in wei
    // 1670226222 Monday, 5 December 2022 г., 7:43:42
    // 300000000000000000
    // 5000000000000000000
    // 86200000000000000000
    // 172000000000000000000

    // rate 370 370
    // for prod 1670226222,370370, 300000000000000000,5000000000000000000,86200000000000000000,172000000000000000000
    // for dev  1670078452,370370000000000000000000,100000000000000,5000000000000000000,862000000000000,172000000000000000000
    
    
    function startICO(
        uint256 endDate,
        uint256 rate,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        uint256 _softCap,
        uint256 _hardCap
    ) external onlyOwner icoNotActive {
        startRefund = false;
        refundStartDate = 0;
        availableTokens = _token.balanceOf(address(this));
        require(rate > 0, "Pre-Sale: rate is 0");
        require(endDate > block.timestamp, "duration should be > 0");
        require(_softCap < _hardCap, "Softcap must be lower than Hardcap");
        require(
            _minPurchase < _maxPurchase,
            "minPurchase must be lower than maxPurchase"
        );
        require(availableTokens > 0, "availableTokens must be > 0");
        require(_minPurchase > 0, "_minPurchase should > 0");
        endICO = endDate;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        softCap = _softCap;
        hardCap = _hardCap;
        _rate = rate;
        _weiRaised = 0;
    }

    function stopICO() external onlyOwner icoActive {
        endICO = 0;
        if (_weiRaised >= softCap) {
            _forwardFunds();
        } else {
            startRefund = true;
            refundStartDate = block.timestamp;
        }
    }

    //Pre-Sale
    function buyTokens(address beneficiary)
        public
        payable
        nonReentrant
        icoActive
    {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount);
        _weiRaised = _weiRaised.add(weiAmount);
        availableTokens = availableTokens - tokens;
        _contributions[beneficiary] = _contributions[beneficiary].add(
            weiAmount
        );
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        view
    {
        require(
            beneficiary != address(0),
            "Crowdsale: beneficiary is the zero address"
        );
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        require(weiAmount >= minPurchase, "have to send at least: minPurchase");
        require(
            _contributions[beneficiary].add(weiAmount) <= maxPurchase,
            "can't buy more than: maxPurchase"
        );
        require((_weiRaised + weiAmount) <= hardCap, "Hard Cap reached");
        this;
    }

    function claimTokens() external icoNotActive {
        require(startRefund == false);

        uint256 tokensAmt = _getTokenAmount(_contributions[msg.sender]);
        _contributions[msg.sender] = 0;
        _token.transfer(msg.sender, tokensAmt);
    }

   function showAmountTokens() public view returns (uint256) {
        return _getTokenAmount(_contributions[msg.sender]);
    }

    function canClaimTokens() public view returns(bool)
    {
        return startRefund;
    }

    function _getTokenAmount(uint256 weiAmount)
        internal
        view
        returns (uint256)
    {
        return weiAmount.mul(_rate).div(10**_tokenDecimals);
    }

    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }

    function withdraw() external onlyOwner icoNotActive {
        require(
            startRefund == false || (refundStartDate + 3 days) < block.timestamp
        );
        require(address(this).balance > 0, "Contract has no money");
        _wallet.transfer(address(this).balance);
    }

    function checkContribution(address addr) public view returns (uint256) {
        return _contributions[addr];
    }

    function setRate(uint256 newRate) external onlyOwner icoNotActive {
        _rate = newRate;
    }

    function setAvailableTokens(uint256 amount) public onlyOwner icoNotActive {
        availableTokens = amount;
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    function setWalletReceiver(address payable newWallet) external onlyOwner {
        _wallet = newWallet;
    }

    function setHardCap(uint256 value) external onlyOwner {
        hardCap = value;
    }

    function setSoftCap(uint256 value) external onlyOwner {
        softCap = value;
    }

    function setMaxPurchase(uint256 value) external onlyOwner {
        maxPurchase = value;
    }

    function setMinPurchase(uint256 value) external onlyOwner {
        minPurchase = value;
    }

    function takeTokens(IERC20 tokenAddress) public onlyOwner icoNotActive {
        IERC20 tokenBEP = tokenAddress;
        uint256 tokenAmt = tokenBEP.balanceOf(address(this));
        require(tokenAmt > 0, "BEP-20 balance is 0");
        tokenBEP.transfer(_wallet, tokenAmt);
    }

    function refundMe() public icoNotActive {
        require(startRefund == true, "no refund available");
        uint256 amount = _contributions[msg.sender];
        if (address(this).balance >= amount) {
            _contributions[msg.sender] = 0;
            if (amount > 0) {
                address payable recipient = payable(msg.sender);
                recipient.transfer(amount);
                emit Refund(msg.sender, amount);
            }
        }
    }

    modifier icoActive() {
        require(
            endICO > 0 && block.timestamp < endICO && availableTokens > 0,
            "ICO must be active"
        );
        _;
    }

    modifier icoNotActive() {
        require(endICO < block.timestamp, "ICO should not be active");
        _;
    }
}