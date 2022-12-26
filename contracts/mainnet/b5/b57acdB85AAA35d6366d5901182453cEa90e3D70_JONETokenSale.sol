/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: GPL-3.0

/**
 *
 * URL: https://jonetoken.io/
 *
 */
pragma solidity >=0.8.0;

interface ERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

abstract contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, 'ReentrancyGuard: reentrant call');
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

abstract contract Ownable is Context {
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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            'Ownable: new owner is the zero address'
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract JONETokenSale is Context, ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    address public _usdc;
    address public _joneCoin;
    address public _admin;
    address public _settlementWallet;
    uint256 public _sendTokenPercentage = 25; // 100/4;
    uint256 public _sendVestingTokenPercentage = 25; // 100/4;
    uint256 public joneCoinPrice = 0.1 * 10**18; // 0.1 USD

    mapping(address => uint256) public totalTokens;
    mapping(address => uint256) public totalWithdrawnTokens;
    mapping(address => uint256) public lastWithdrawnAt;

    uint256 public deltaTimeToWithdraw = 30 days;
    uint256 public totalTokensSold = 0;

    uint256 public _minUSD = 1 * 10**18;
    uint256 public _maxUSD = 50000 * 10**18;


    bool public ICOOngoing = true;

    event Purchase(
        address indexed buyer,
        uint256 amount,
        uint256 onVesting,
        uint256 valueInPurchaseCurrency,
        string currency
    );

    event WithdrawnTokens(
        address indexed buyer,
        uint256 amount,
        uint256 time
    );

    event CheckedCanBuy(
        uint256 balance,
        uint256 allowance,
        uint256 totalCostInUSDC,
        uint256 tokenToSend,
        uint256 vestingToken
    );

    constructor(address _usdcAddress, address _joneCoinAddress, address settlementWallet) {
        _admin = _msgSender();
        _usdc = _usdcAddress;
        _joneCoin = _joneCoinAddress;
        _settlementWallet = settlementWallet;
    }

    function purchaseWithUSDC(uint256 _amount)
        public
        virtual
        nonReentrant
        returns (bool)
    {
        uint256 balance = ERC20(_usdc).balanceOf(_msgSender());
        uint256 allowance = ERC20(_usdc).allowance(
            _msgSender(),
            address(this)
        );

        uint256 totalCostInUSDC = joneCoinPrice.mul(_amount.div(10**8));
        uint256 tokenToSend = _amount.div(_sendTokenPercentage);
        uint256 vestingToken = _amount.sub(tokenToSend);

        require(ICOOngoing, 'Error: ICO halted');
        require(totalCostInUSDC >= _minUSD, 'Error: BUDS token should be min 100.');
        require(totalCostInUSDC <= _maxUSD, 'Error: BUSD token should be max 50000.');
        require(balance >= totalCostInUSDC, 'Error: insufficient USDC Balance');
        require(
            allowance >= totalCostInUSDC,
            'Error: allowance less than spending'
        );

        ERC20(_usdc).transferFrom(
            _msgSender(),
            _settlementWallet,
            totalCostInUSDC
        );
        ERC20(_joneCoin).transfer(
            _msgSender(),
            tokenToSend
        );

        totalTokens[_msgSender()] = totalTokens[_msgSender()].add(_amount);
        totalWithdrawnTokens[_msgSender()] = totalWithdrawnTokens[_msgSender()].add(tokenToSend);

        totalTokensSold = totalTokensSold.add(_amount);
        
        // update lastWithdrawnAt if 0 for given address
        if (lastWithdrawnAt[_msgSender()] == 0) {
            lastWithdrawnAt[_msgSender()] = block.timestamp;
        }

        emit Purchase(
            _msgSender(),
            tokenToSend,
            vestingToken,
            totalCostInUSDC,
            'USDC'
        );

        return true;
    }

    function updateUsdc(address newAddress) public virtual onlyOwner {
        require(newAddress != address(0), 'Error: address cannot be zero');
        _usdc = newAddress;
    }

    function updateJONECoinAddress(address newAddress)
        public
        virtual
        onlyOwner
    {
        require(newAddress != address(0), 'Error: address cannot be zero');
        _joneCoin = newAddress;
    }

    function updateSendTokenPercentage(uint256 sendTokenPercentage)
        public
        virtual
        onlyOwner
    {
        uint256 total = 100;
        _sendTokenPercentage = total.div(sendTokenPercentage);
    }

    function updateSettlementWallet(address newAddress)
        public
        virtual
        onlyOwner
    {
        require(newAddress != address(0), 'Error: not a valid address');
        _settlementWallet = newAddress;
    }

    function resumeICO() public virtual onlyOwner {
        ICOOngoing = true;
    }

    function stopICO() public virtual onlyOwner {
        ICOOngoing = false;
    }

    function changeJONEPrice(uint256 price) public virtual onlyOwner {
        joneCoinPrice = price;
    }

    function regainUnusedJONE(uint256 amount) public virtual onlyOwner {
        ERC20(_joneCoin).transfer(
            owner(),
            amount
        );
    }
    
    function changeDeltaTimeToWithdraw(uint256 _deltaTimeToWithdraw) public virtual onlyOwner {
        deltaTimeToWithdraw = _deltaTimeToWithdraw.mul(1 days);
    }

    function checkCanBuy(uint256 _amount) public returns (bool) {
        uint256 balance = ERC20(_usdc).balanceOf(_msgSender());
        uint256 allowance = ERC20(_usdc).allowance(
            _msgSender(),
            address(this)
        );

        uint256 totalCostInUSDC = joneCoinPrice.mul(_amount.div(10**18));
        uint256 tokenToSend = _amount.div(_sendTokenPercentage);
        uint256 vestingToken = _amount.sub(tokenToSend);

        require(ICOOngoing, 'Error: ICO halted');
        require(balance >= totalCostInUSDC, 'Error: insufficient USDC Balance');
        require(
            allowance >= totalCostInUSDC,
            'Error: allowance less than spending'
        );

        emit CheckedCanBuy(
            balance,
            allowance,
            totalCostInUSDC,
            tokenToSend,
            vestingToken
        );

        return true;
    }

    function withdrawVestingTokens() public {
        require(totalWithdrawnTokens[_msgSender()] < totalTokens[_msgSender()], "No vesting token founds");
        require(block.timestamp >= lastWithdrawnAt[_msgSender()] + deltaTimeToWithdraw, "Not able to withdraw");

        uint256 tokenToSend = totalTokens[_msgSender()].div(_sendVestingTokenPercentage);

        if (totalWithdrawnTokens[_msgSender()].add(tokenToSend) > totalTokens[_msgSender()]) {
            tokenToSend = totalWithdrawnTokens[_msgSender()];
        }

        // transfer tokens
        ERC20(_joneCoin).transfer(
            _msgSender(),
            tokenToSend
        );
        totalWithdrawnTokens[_msgSender()] = totalWithdrawnTokens[_msgSender()].add(tokenToSend);
        lastWithdrawnAt[_msgSender()] = lastWithdrawnAt[_msgSender()] + deltaTimeToWithdraw;

        emit WithdrawnTokens(_msgSender(), tokenToSend, block.timestamp);
    }

    function updateMinUsdc(uint256 minUSD) public virtual onlyOwner {
        _minUSD = minUSD;
    }
    
    function updateMaxUsdc(uint256 maxUSD) public virtual onlyOwner {
        _maxUSD = maxUSD;
    }
}