/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// interface ITokenPrice_Oracle {
//     function requestBtcPrice() external;
//     function getBtcPrice() external view returns (uint256);
//     function requestEthPrice() external;
//     function getEthPrice() external view returns (uint256);
//     function requestBnbPrice() external;
//     function getBnbPrice() external view returns (uint256);
// }

contract TokenPrice_Orcale {
    address public owner;
    address public caller;

    uint256 public btcPrice;
    uint256 public ethPrice;
    uint256 public bnbPrice;

    constructor(address _owner, address _caller) {
        owner = _owner;
        caller = _caller;
    }

    // Modifier
    modifier onlyOracle {
        require(msg.sender == owner || msg.sender == caller, "Not authorized!");
        _;
    }

    // Events
    event callBtcPrice();
    event callEthPrice();
    event callBnbPrice();

    // Call function
    function requestBtcPrice() external {
        emit callBtcPrice();
    }

    function requestEthPrice() external {
        emit callEthPrice();
    }

    function requestBnbPrice() external {
        emit callBnbPrice();
    }


    // Update function - where the connection with the server is made
    function setBtcPrice(uint256 _newPrice) external onlyOracle {
        btcPrice = _newPrice;
    }

    function setEthPrice(uint256 _newPrice) external onlyOracle {
        ethPrice = _newPrice;
    }

    function setBnbPrice(uint256 _newPrice) external onlyOracle {
        bnbPrice = _newPrice;
    }

    // Return prices
    function getBtcPrice() external view returns (uint256) {
        return btcPrice;
    }

    function getEthPrice() external view returns (uint256) {
        return ethPrice;
    }

    function getBnbPrice() external view returns (uint256) {
        return bnbPrice;
    }
}