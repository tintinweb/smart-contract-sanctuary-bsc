/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT
// author : saad sarwar


pragma solidity ^0.8.7;


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library Percentages {
    // Get value of a percent of a number
    function calcPortionFromBasisPoints(uint _amount, uint _basisPoints) public pure returns(uint) {
        if(_basisPoints == 0 || _amount == 0) {
            return 0;
        } else {
            uint _portion = _amount * _basisPoints / 10000;
            return _portion;
        }
    }

    // Get basis points (percentage) of _portion relative to _amount
    function calcBasisPoints(uint _amount, uint  _portion) public pure returns(uint) {
        if(_portion == 0 || _amount == 0) {
            return 0;
        } else {
            uint _basisPoints = (_portion * 10000) / _amount;
            return _basisPoints;
        }
    }
}

contract EZPriceConsumer is Ownable {

    using Percentages for uint;

    AggregatorV3Interface internal priceFeed;

    constructor(address aggregator) {
        priceFeed = AggregatorV3Interface(aggregator);
    }

    function getLatestEthPrice() public view returns (uint) {
        (
        /*uint80 roundID*/,
        int answer,
        /*uint startedAt*/,
        /*uint updatedAt*/,
        /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint(answer) * 10 ** 10;
    }

    function usdToBNB(uint _amountInUsd) public view returns (uint) {
        if(_amountInUsd == 0) {
            return 0;
        }

        uint _basisPoints = getLatestEthPrice().calcBasisPoints(_amountInUsd);
        uint _amountInEth = _basisPoints * (10 ** 14);

        return _amountInEth;
    }

}