// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.8;

import "./IBEP20.sol";
import "./IPancakePair.sol";
import "./Ownable.sol";

contract Sale is Ownable {

    IPancakePair public PAIR_WBNB_BUSD;
    IPancakePair public PAIR_WBNB_LAND;
    address public TOKEN;
    address public BUSD;
    address public SECURITIES;

    uint256 public percentage = 100000;
    uint256 public percent;
    uint256 public basePrice;
    address public manager;
    bool public status;

    struct Order {
        uint256 securities;
        uint256 tokens;
        uint256 busd;
        string orderId;
        address payer;
    }

    Order[] public orders;
    uint256 public ordersCount;

    event BuyTokensEvent(address buyer, uint256 amountSecurities);

    constructor(address _pair, address _pair_busd, address _token, address _busd, address _securities) {
        percent = 10000;
        PAIR_WBNB_LAND = IPancakePair(_pair);
        PAIR_WBNB_BUSD = IPancakePair(_pair_busd);
        TOKEN = _token;
        BUSD = _busd;
        SECURITIES = _securities;
        manager = _msgSender();
        ordersCount = 0;
        basePrice = 1;
        status = true;
    }

    modifier onlyManager() {
        require(_msgSender() == manager, "Wrong sender");
        _;
    }

    modifier onlyActive() {
        require(status == true, "Sale: not active");
        _;
    }

    function changeManager(address newManager) public onlyOwner {
        manager = newManager;
    }

    function changeStatus(bool _status) public onlyOwner {
        status = _status;
    }

    function setPrice(uint256 priceInBUSD) public onlyManager {
        basePrice = priceInBUSD;
    }

    function buyToken(uint256 amountBUSD, string memory orderId) public onlyActive returns(bool) {
        uint256 amountSecurities = (amountBUSD / basePrice) / (10**IBEP20(BUSD).decimals());
        (uint256 amountA, uint256 amountB) = calculateAmounts(amountBUSD);
        Order memory order;
        require(IBEP20(BUSD).transferFrom(_msgSender(), address(this), amountA), "transferFrom: BUSD error");
        require(IBEP20(TOKEN).transferFrom(_msgSender(), address(this), amountB), "transferFrom: TOKEN error");
        require(IBEP20(SECURITIES).transfer(_msgSender(), amountSecurities), "transfer: SEC error");

        order.busd = amountA;
        order.tokens = amountB;
        order.securities = amountSecurities;
        order.orderId = orderId;
        order.payer = _msgSender();
        orders.push(order);
        ordersCount += 1;

        emit BuyTokensEvent(_msgSender(), amountSecurities);
        return true;
    }

    function sendBack(uint256 amount, address token) public onlyOwner returns(bool) {
        require(IBEP20(token).transfer(_msgSender(), amount), "Transfer: error");
        return true;
    }

    function buyTokenView(uint256 amountBUSD) public view returns(uint256 busd, uint256 token, uint256 securities) {
        uint256 amountSecurities = (amountBUSD / basePrice) / (10**IBEP20(BUSD).decimals());
        (uint256 amountA, uint256 amountB) = calculateAmounts(amountBUSD);
        return (
        amountA, amountB, amountSecurities
         );
    }

    function calculatePrice() public view returns(uint256){
       uint256 price_bnb = getWBNBPrice();
       uint256 price_land = getLANDPrice();
       uint256 price_land_busd = (price_land * price_bnb) / 1e18;
       return price_land_busd;
    }

    function getWBNBPrice() public view returns(uint256) {
       (uint256 reserve0, uint256 reserve1,) = PAIR_WBNB_BUSD.getReserves();
       uint res1 = reserve1*(10**18);
       uint256 price_bnb = res1 / reserve0;
       return price_bnb;
    }

    function getLANDPrice() public view returns(uint256) {
       (uint256 reserve2, uint256 reserve3,) = PAIR_WBNB_LAND.getReserves();
       uint res3 = reserve3*(10**IBEP20(TOKEN).decimals());
       uint256 price_land = res3 / reserve2;
       return price_land;
    }

    function calculateAmounts(uint256 amountToken) public view returns(uint256, uint256) {
        uint256 price = calculatePrice();
        uint256 amountB = (amountToken * percent) / percentage;
        uint256 amountA = amountToken - amountB;
        uint256 amountC = (amountB * 10**IBEP20(TOKEN).decimals()) / price ;
        return (amountA, amountC);
    }

}