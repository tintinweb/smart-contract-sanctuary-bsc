/**
 *Submitted for verification at BscScan.com on 2022-09-11
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

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
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

struct ReceiveRecord {
    uint256 amount;
    uint time;
    address sender;
}

interface TdexMining {

    function getReleasedRevenueOf(address _sender) external view returns (uint256);

    function sendReceive() external returns (uint256);

    function getUserReceiveRecordLength(address _sender) external view returns (uint256);

    function getUserReceiveRecords(address _sender, uint[] memory __indexs) external view returns (ReceiveRecord[20] memory);

    function tokenContract() external view returns (address);
}

interface ChainLinkTrading {

    function get(address tokenContract) external view returns (uint256);
}

interface _dad {

    function getTdex() external view returns (address);

    function getPriceMachine() external view returns (address);
}

contract TdexToolsOriginal {

    address public constant_ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // address public constant_USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public constant_USDT = 0xA53DBF0C7b8B3e361395b9772dCEb2eB8697A5b4;

    address private _owner;
    address private _creater;

    address private _admin;

    address[] private _tradersList;

    address _trader;

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
        _creater = msg.sender;
    }

    modifier onlyCreater() {
        require(_creater == msg.sender, "Ownable: caller is not the creater");
        _;
    }

    function setOwnership(address ___owner) external onlyCreater
    {
        _owner = ___owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender || _creater == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setTraders(address __trader) external onlyOwner
    {
        _trader = __trader;
    }

    function getTrader() external view returns (address)
    {
        return _trader;
    }

    modifier onlyTrader() {
        require(_trader == msg.sender, "Ownable: caller is not the traders");
        _;
    }

    function tdex() internal view returns (TdexInterface)
    {
        return TdexInterface(_dad(_creater).getTdex());
    }

    function balanceOf(address _tokenContract) external view returns (uint256)
    {
        return tdex().balanceOf(_tokenContract, address(this));
    }

    function withdraw(address _tokenContract) external onlyOwner
    {
        uint256 balance = this.balanceOf(_tokenContract);
        if (_tokenContract == constant_ETH)
        {
            TransferHelper.safeTransferETH(msg.sender, balance);
        }
        else
        {
            TransferHelper.safeTransfer(_tokenContract, msg.sender, balance);
        }
    }

    function getReleasedRevenueOf() external view returns (uint256)
    {
        return TdexMining(tdex().mining()).getReleasedRevenueOf(address(this));
    }

    function SendReceive() external onlyOwner
    {
        address tokenContract = TdexMining(tdex().mining()).tokenContract();
        uint256 amount = TdexMining(tdex().mining()).sendReceive();
        IERC20(tokenContract).transfer(msg.sender, amount);
    }

    function getUserReceiveRecordLength() external view returns (uint256)
    {
        return TdexMining(tdex().mining()).getUserReceiveRecordLength(address(this));
    }

    function getUserReceiveRecords(uint[] memory __indexs) external view returns (ReceiveRecord[20] memory)
    {
        return TdexMining(tdex().mining()).getUserReceiveRecords(address(this), __indexs);
    }

    function Approve(address _tokenContract) internal
    {
        uint256 allowanceUSDT = IERC20(constant_USDT).allowance(address(this), address(tdex()));
        if (allowanceUSDT < 1e32)
        {
            IERC20(constant_USDT).approve(address(tdex()), 1e40);
        }
        if (_tokenContract != constant_ETH)
        {
            uint256 allowance = IERC20(_tokenContract).allowance(address(this), address(tdex()));
            if (allowance < 1e32)
            {
                IERC20(_tokenContract).approve(address(tdex()), 1e40);
            }
        }
    }

    function GetPrice(address _tokenContract) external view returns (uint256)
    {
        uint256 price =  ChainLinkTrading(_dad(_creater).getPriceMachine()).get(_tokenContract);
        if (price == 0)
        {
            Dish memory buyPublished = tdex().getBuyOrderPublished(_tokenContract, 1)[0];
            Dish memory sellPublished = tdex().getSellOrderPublished(_tokenContract, 1)[0];
            if (buyPublished.price == 0 || sellPublished.price == 0)
            {
                return tdex().getPrice(_tokenContract);
            }
            price = (sellPublished.price - buyPublished.price) / 2 + buyPublished.price;
        }
        return price;
    }

    function getBuyOrderPublished(address _tokenContract, uint count) external view returns (uint256[] memory prices, uint256[] memory numbers)
    {
        Dish[] memory list = tdex().getBuyOrderPublished(_tokenContract, count);
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
        Dish[] memory list = tdex().getSellOrderPublished(_tokenContract, count);
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
        return tdex().getBuyOrderPriceOrderIdList(_tokenContract, _price);
    }

    function getSellOrderPriceOrderIdList(address _tokenContract, uint256 _price) external view returns (uint256[] memory)
    {
        return tdex().getSellOrderPriceOrderIdList(_tokenContract, _price);
    }

    function getOrderUnmatchedList(address _tokenContract, uint256 start, uint256 end) external view returns (uint256[] memory)
    {
        return tdex().getOrderUnmatchedList(_tokenContract, address(this), start, end);
    }

    function getOrderUnmatchedListLength(address _tokenContract) external view returns (uint)
    {
        return tdex().getOrderUnmatchedListLength(_tokenContract, address(this));
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
        return tdex().getOrder(_tokenContract, _orderId);
    }

    function gasRecharge() internal
    {
        uint256 balance = this.balanceOf(_trader);
        if (balance < 5e16)
        {
            TransferHelper.safeTransferETH(_trader, 1e18);
        }
    }
 
    function cancelOrders(address _tokenContract, uint256[] memory _orderIds) external onlyTrader
    {
        gasRecharge();
        for (uint i=0; i<_orderIds.length; i++)
        {
            tdex().Cancel(_tokenContract, _orderIds[i]);
        }
    }

    function entrustOrders(address _tokenContract, bool[] memory _isBuy, uint256[] memory _prices, uint256[] memory _amount) external onlyTrader
    {
        gasRecharge();
        Approve(_tokenContract);
        require(_prices.length == _amount.length, "Parameter error");

        for (uint i=0; i<_prices.length; i++)
        {
            if (_isBuy[i] == true)
            {
                tdex().Buy(_tokenContract, _prices[i], _amount[i]);
            }
            else
            {
                tdex().Sell(_tokenContract, _prices[i], _amount[i]);
            }
        }
    }

    function entrustEthOrders(bool[] memory _isBuy, uint256[] memory _prices, uint256[] memory _amount) external onlyTrader
    {
        gasRecharge();
        address _tokenContract = constant_ETH;
        Approve(_tokenContract);
        require(_prices.length == _amount.length, "Parameter error");

        for (uint i=0; i<_prices.length; i++)
        {
            if (_isBuy[i] == true)
            {
                tdex().BuyETH(_prices[i], _amount[i]);
            }
            else
            {
                tdex().SellETH{value:_amount[i]}(_prices[i]);
            }
        }
    }

    function GetLiquidityPrice(address _tokenContract) internal view returns (uint256)
    {
        Dish memory buyPublished = tdex().getBuyOrderPublished(_tokenContract, 1)[0];
        Dish memory sellPublished = tdex().getSellOrderPublished(_tokenContract, 1)[0];
        require(sellPublished.price >= buyPublished.price + 2, "failure");
        uint256 mid_price = (sellPublished.price - buyPublished.price) / 2 + buyPublished.price;
        return mid_price;
    }

    function RunLiquidity(address _tokenContract, uint256 _usdtAmount) external onlyTrader
    {
        Approve(_tokenContract);
        uint256 price = GetLiquidityPrice(_tokenContract);
        uint256 _amount = _usdtAmount / price * 1e8;
        tdex().Buy(_tokenContract, price, _amount);
        tdex().Sell(_tokenContract, price, _amount);
    }

    function RunLiquidityEth(uint256 _usdtAmount) external onlyTrader
    {
        address _tokenContract = constant_ETH;
        Approve(_tokenContract);
        uint256 price = GetLiquidityPrice(_tokenContract);
        uint256 _amount = _usdtAmount / price * 1e8;
        tdex().BuyETH(price, _amount);
        tdex().SellETH{value:_amount}(price);
    }
}