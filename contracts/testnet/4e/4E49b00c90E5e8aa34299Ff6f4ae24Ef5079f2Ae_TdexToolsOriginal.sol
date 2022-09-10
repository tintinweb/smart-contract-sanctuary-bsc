/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

struct Token {
    string symbol;
    string name;
    address tokenContract;
    uint decimals;
}

struct Dish {
    uint256 price;
    uint256 number;
}

enum OrderType { Buy, Sell }
enum OrderStatus { None, Waiting, Finished, Cancelled }

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a >= b) return a;
        return b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >=0 && b>=0, "SafeMath: Cannot have negative numbers");
        if (a <= b) return a;
        return b;
    }
}

interface TdexInterface {

    function Buy(address _tokenContract, uint256 _price, uint256 _token_amount) external returns (uint256 orderId);

    function BuyETH(uint256 _price, uint256 _token_amount) external returns (uint256 orderId);

    function Sell(address _tokenContract, uint256 _price, uint256 _token_amount) external returns (uint256 orderId);

    function SellETH(uint256 _price) external payable returns (uint256 orderId);

    function Cancel(address _tokenContract, uint256 _orderId) external returns (bool);

    function balanceOf(address _tokenContract, address _sender) external view returns (uint256);

    function getBuyOrderPublished(address _tokenContract, uint count) external view returns (Dish[] memory list);

    function getSellOrderPublished(address _tokenContract, uint count) external view returns (Dish[] memory list);

    function getBuyOrderPriceOrderIdList(address _tokenContract, uint256 _price) external view returns (uint256[] memory);

    function getSellOrderPriceOrderIdList(address _tokenContract, uint256 _price) external view returns (uint256[] memory);

    function getOrderUnmatchedList(address _tokenContract, address _sender, uint256 start, uint256 end) external view returns (uint256[] memory);

    function getOrderUnmatchedListLength(address _tokenContract, address _sender) external view returns (uint);

    function getOrder(address _tokenContract, uint256 _orderId) external view returns (
        uint256 price,
        uint256 tokenTotal,
        uint256 tokenSurplus,
        uint256 tokenFee,
        uint256 usdtSurplus,
        uint256 usdtFee,
        uint256 createnTime,
        uint256 endTime,
        uint8 orderType,
        uint8 status,
        address sender
    );
                
    function getPrice(address _tokenContract) external view returns (uint256 price);

    function mining() external view returns (address);

    function getToken(address _tokenContract) external view returns (
        address tokenContract,
        string memory symbol,
        string memory name,
        uint decimals
    );
}

interface TdexMining {

    function sendReceive() external returns (uint256);

    function tokenContract() external view returns (address);
}

interface ChainLinkTrading {

    function get(address tokenContract) external view returns (uint256);
}


contract TdexToolsOriginal {

    address public constant_ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // address public constant_USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public constant_USDT = 0xA53DBF0C7b8B3e361395b9772dCEb2eB8697A5b4;

    TdexInterface _tdex;

    address private _owner;

    address private _admin;

    address private _marketmakers;

    address[] private _tradersList;

    mapping(address => bool) _tradersMap;

    ChainLinkTrading _priceMachine;

    fallback() external
    {

    }

    receive() external payable
    {
        if (msg.value > 0)
        {

        }
    }

    constructor () {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setAdmin(address __admin) external onlyOwner
    {
        _admin = __admin;
    }

    modifier onlyAdmin() {
        require(_admin == msg.sender, "Ownable: caller is not the administrator");
        _;
    }

    function setMarketmakers(address __marketmakers) external onlyAdmin
    {
        _marketmakers = __marketmakers;
    }

    modifier onlyMarketmakers() {
        require(_marketmakers == msg.sender, "Ownable: caller is not the marketmakers");
        _;
    }

    function setTdex(address __tdex) external onlyOwner
    {
        _tdex = TdexInterface(__tdex);
    }

    function setPriceMachine(address __priceMachine) external onlyOwner
    {
        _priceMachine = ChainLinkTrading(__priceMachine);
    }

    function addTraders(address __traders) external onlyAdmin
    {
        if (_tradersMap[__traders] == false)
        {
            _tradersMap[__traders] = true;

            {
                bool added = false;
                for (uint i=0; i<_tradersList.length;i++)
                {
                    if (_tradersList[i] == address(0))
                    {
                        _tradersList[i] = __traders;
                        added = true;
                    }
                }
                if (added == false)
                {
                    _tradersList.push(__traders);
                }
            }
        }
    }

    function removeTraders(address __traders) external onlyAdmin
    {
        if (_tradersMap[__traders] == true)
        {
            delete _tradersMap[__traders];

            {
                for (uint i=0; i<_tradersList.length; i++)
                {
                    if (_tradersList[i] == __traders)
                    {
                        _tradersList[i] = address(0);
                    }
                }
            }
        }
    }

    modifier onlyTraders() {
        require(_tradersMap[msg.sender] == true, "Ownable: caller is not the traders");
        _;
    }

    function balanceOf(address _tokenContract) external view returns (uint256)
    {
        return _tdex.balanceOf(_tokenContract, address(this));
    }

    function Withdraw(address _tokenContract) external onlyMarketmakers
    {
        uint256 balance = this.balanceOf(_tokenContract);
        if (_tokenContract == constant_ETH)
        {
            payable(msg.sender).transfer(balance);
        }
        else
        {
            IERC20(_tokenContract).transfer(msg.sender, balance);
        }
    }

    function SendReceive() external onlyMarketmakers
    {
        address tokenContract = TdexMining(_tdex.mining()).tokenContract();
        uint256 amount = TdexMining(_tdex.mining()).sendReceive();
        IERC20(tokenContract).transfer(msg.sender, amount);
    }

    function Approve(address _tokenContract) internal
    {
        uint256 allowanceUSDT = IERC20(constant_USDT).allowance(address(this), address(_tdex));
        if (allowanceUSDT < 1e32)
        {
            IERC20(constant_USDT).approve(address(_tdex), 1e40);
        }
        if (_tokenContract != constant_ETH)
        {
            uint256 allowance = IERC20(_tokenContract).allowance(address(this), address(_tdex));
            if (allowance < 1e32)
            {
                IERC20(_tokenContract).approve(address(_tdex), 1e40);
            }
        }
        
    }

    function GetPrice(address _tokenContract) external view returns (uint256)
    {
        uint256 price =  _priceMachine.get(_tokenContract);
        if (price == 0)
        {
            Dish memory buyPublished = _tdex.getBuyOrderPublished(_tokenContract, 1)[0];
            Dish memory sellPublished = _tdex.getSellOrderPublished(_tokenContract, 1)[0];
            if (buyPublished.price == 0 || sellPublished.price == 0)
            {
                return _tdex.getPrice(_tokenContract);
            }
            price = (sellPublished.price - buyPublished.price) / 2 + buyPublished.price;
        }
        return price;
    }

    function getBuyOrderPublished(address _tokenContract, uint count) external view returns (uint256[] memory prices, uint256[] memory numbers)
    {
        Dish[] memory list = _tdex.getBuyOrderPublished(_tokenContract, count);
        prices = new uint256[](list.length);
        numbers = new uint256[](list.length);
        for (uint i=0; i<list.length; i++)
        {
            prices[i] = list[i].price;
            numbers[i] = list[i].number;
        }
    }

    function getSellOrderPublished(address _tokenContract, uint count) external view returns (uint256[] memory prices, uint256[] memory numbers)
    {
        Dish[] memory list = _tdex.getSellOrderPublished(_tokenContract, count);
        prices = new uint256[](list.length);
        numbers = new uint256[](list.length);
        for (uint i=0; i<list.length; i++)
        {
            prices[i] = list[i].price;
            numbers[i] = list[i].number;
        }        
    }

    function getBuyOrderPriceOrderIdList(address _tokenContract, uint256 _price) external view returns (uint256[] memory)
    {
        return _tdex.getBuyOrderPriceOrderIdList(_tokenContract, _price);
    }

    function getSellOrderPriceOrderIdList(address _tokenContract, uint256 _price) external view returns (uint256[] memory)
    {
        return _tdex.getSellOrderPriceOrderIdList(_tokenContract, _price);
    }

    function getOrderUnmatchedList(address _tokenContract, uint256 start, uint256 end) external view returns (uint256[] memory)
    {
        return _tdex.getOrderUnmatchedList(_tokenContract, address(this), start, end);
    }

    function getOrderUnmatchedListLength(address _tokenContract) external view returns (uint)
    {
        return _tdex.getOrderUnmatchedListLength(_tokenContract, address(this));
    }

    function getOrder(address _tokenContract, uint256 _orderId) external view returns (
        uint256 price,
        uint256 tokenTotal,
        uint256 tokenSurplus,
        uint256 tokenFee,
        uint256 usdtSurplus,
        uint256 usdtFee,
        uint256 createnTime,
        uint256 endTime,
        uint8 orderType,
        uint8 status,
        address sender
    )
    {
        return _tdex.getOrder(_tokenContract, _orderId);
    }
 
    function cancelOrders(address _tokenContract, uint256[] memory _orderIds) external
    {
        for (uint i=0; i<_orderIds.length; i++)
        {
            _tdex.Cancel(_tokenContract, _orderIds[i]);
        }
    }

    function entrustBuyOrders(address _tokenContract, uint256[] memory _prices, uint256[] memory _amount) external
    { 
        Approve(_tokenContract);
        require(_prices.length == _amount.length, "Parameter error");

        for (uint i=0; i<_prices.length; i++)
        {
            _tdex.Buy(_tokenContract, _prices[i], _amount[i]);
        }
    }

    function entrustBuyEthOrders(uint256[] memory _prices, uint256[] memory _amount) external
    { 
        address _tokenContract = constant_ETH;
        Approve(_tokenContract);
        require(_prices.length == _amount.length, "Parameter error");

        for (uint i=0; i<_prices.length; i++)
        {
            _tdex.BuyETH(_prices[i], _amount[i]);
        }
    }

    function entrustSellOrders(address _tokenContract, uint256[] memory _prices, uint256[] memory _amount) external
    {
        Approve(_tokenContract);
        require(_prices.length == _amount.length, "Parameter error");

        for (uint i=0; i<_prices.length; i++)
        {
            _tdex.Sell(_tokenContract, _prices[i], _amount[i]);
        }
    }

    function entrustSellEthOrders(uint256[] memory _prices, uint256[] memory _amount) external
    { 
        require(_prices.length == _amount.length, "Parameter error");

        for (uint i=0; i<_prices.length; i++)
        {
            _tdex.SellETH{value:_amount[i]}(_prices[i]);
        }
    }
}