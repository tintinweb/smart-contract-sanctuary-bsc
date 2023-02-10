// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface CallProxy {
    function anyCall(
        address _to,
        bytes calldata _data,
        uint256 _toChainID,
        uint256 _flags,
        bytes calldata _extdata
    ) external payable;

    function context()
        external
        view
        returns (
            address from,
            uint256 fromChainID,
            uint256 nonce
        );

    function executor() external view returns (address executor);
}

contract Anycalltestboth {
    AggregatorV3Interface internal priceFeed;
    string public message;

    address public anycallcontract;
    address public owneraddress;
    address public receivercontract;
    address public verifiedcaller;

    uint256 public destchain;
    uint256 public ethPrice;

    event NewMsg(string msg);
    event SetEthPrice(uint256 price);

    receive() external payable {}

    fallback() external payable {}

    constructor(address _anycallcontract, uint256 _destchain) {
        anycallcontract = _anycallcontract;
        owneraddress = msg.sender;
        destchain = _destchain;
        priceFeed = AggregatorV3Interface(
            0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7
        );
    }

    modifier onlyowner() {
        require(msg.sender == owneraddress, "only owner can call this method");
        _;
    }

    function changedestinationcontract(address _destcontract)
        external
        onlyowner
    {
        receivercontract = _destcontract;
    }

    function changeverifiedcaller(address _contractcaller) external onlyowner {
        verifiedcaller = _contractcaller;
    }

    function initiateAnyCall(string calldata _msg)
        external
        payable
    {
        emit NewMsg(_msg);
        if (msg.sender == owneraddress) {
            CallProxy(anycallcontract).anyCall{value: msg.value}(
                receivercontract,
                abi.encode(_msg),
                destchain,
                0,
                ""
            );
        }
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price / 1e8);
    }

    function setPrice() public {
        ethPrice = getLatestPrice();
        emit SetEthPrice(ethPrice);
    }

    event ContextEvent(address indexed _from, uint256 indexed _fromChainId);

    function anyExecute(bytes memory _data)
        external
        returns (bool success, bytes memory result)
    {
        string memory _msg = abi.decode(_data, (string));
        message = _msg;
        emit NewMsg(_msg);

        setPrice();

        success = true;
        result = "";
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}