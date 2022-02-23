pragma solidity >= 0.5.0 < 0.6.0;

import "../provableAPI_0.5.sol";

contract AssetPrice is usingProvable {

    uint public assetPriceUSD;

    event LogNewAssetPrice(string price);
    event LogNewProvableQuery(string description);

    constructor()
        public
    {
        OAR = OracleAddrResolverI(0x90A0F94702c9630036FB9846B52bf31A1C991a84);
        update(); // First check at contract creation...
    }

    function __callback(
        bytes32 _myid,
        string memory _result
    )
        public
    {
        require(msg.sender == provable_cbAddress());
        emit LogNewAssetPrice(_result);
        assetPriceUSD = parseInt(_result, 2); // Let's save it as cents...
        // Now do something with the USD Asset price...
    }

    function update()
        public
        payable
    {
        emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
        provable_query("URL", "json(https://eodhistoricaldata.com/api/real-time/TEF.MC?api_token=5bddbb6db45b91.96585960&fmt=json).close");
    }
}