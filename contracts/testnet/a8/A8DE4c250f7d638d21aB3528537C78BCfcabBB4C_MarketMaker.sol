pragma solidity ^0.8.0;

interface IPositionMarketMaker {
    function marketMakerFill(
        address _positionManager,
        MarketMaker.MMFill[] memory _mmFills,
        uint256 _leverage
    ) external;
    function supplyFresh(
        address _positionManager,
        MarketMaker.MMCancelOrder[] memory _cOrders,
        MarketMaker.MMOrder[] memory _oOrders,
        uint256 _leverage
    ) external;
    function remove(
        address _positionManager,
        MarketMaker.MMCancelOrder[] memory _orders
    ) external;
    function supply(
        address _positionManager,
        MarketMaker.MMOrder[] memory _orders,
        uint16 _leverage
    ) external;
}

contract MarketMaker {

    struct MMCancelOrder {
        uint128 pip;
        uint64 orderId;
    }

    struct MMOrder {
        uint128 pip;
        int256 quantity;
    }

    struct MMFill {
        uint256 quantity;
        bool isBuy;
    }

    mapping(address => bool) public isWhitelist;
    address public owner;
    IPositionMarketMaker public positionHouse;

   constructor(){
       owner = msg.sender;
   }

    modifier onlyWhitelist {
        require(isWhitelist[msg.sender], "not WL");
        _;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "only owner");
        _;
    }

    function entrypoint221(address _positionManager, MMFill[] memory fillMarkets, MMOrder[] memory orders, MMCancelOrder[] memory cancelOrders, uint _leverage) public onlyWhitelist {
        // fill market
        // then supply orders imediately
        positionHouse.marketMakerFill(_positionManager, fillMarkets, _leverage);
        if(orders.length > 0)
            positionHouse.supply(_positionManager, orders, uint16(_leverage));
        if(cancelOrders.length >0)
            positionHouse.remove(_positionManager, cancelOrders);
    }

    function setWhitelist(address wl) public onlyOwner {
        isWhitelist[wl] = true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function changePositionHouse(address newPositionHouse) public onlyOwner {
        positionHouse = IPositionMarketMaker(newPositionHouse);
    }

}