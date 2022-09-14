//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";

interface IListingManager {
    function fetchAllAvailableTokens() external view returns (address[] memory);
}

interface IOTC {
    function ListingManager() external view returns (address);
}

interface ILottoManager {
    function currentLotto() external view returns (address);
}

interface IOracle {
    function priceOf(address token) external view returns (uint256);
    function priceOfBNB() external view returns (uint256);
}

contract BalanceFetcher is Ownable {

    address public otc;
    address public oracle;
    address public lottoManager;

    constructor(address otc_, address oracle_, address lottoManager_) {
        otc = otc_;
        oracle = oracle_;
        lottoManager = lottoManager_;
    }

    function setOTC(address otc_) external onlyOwner {
        otc = otc_;
    }

    function setOracle(address oracle_) external onlyOwner {
        oracle = oracle_;
    }

    function setLottoManager(address lottoManager_) external onlyOwner {
        lottoManager = lottoManager_;
    }

    function priceOf(address token) public view returns (uint256) {
        return IOracle(oracle).priceOf(token);
    }

    function priceOfBNB() public view returns (uint256) {
        return IOracle(oracle).priceOfBNB();
    }

    function pricesOf(address[] calldata tokens) external view returns (uint256[] memory) {
        uint len = tokens.length;
        uint256[] memory prices = new uint256[](len);
        for (uint i = 0; i < len;) {
            prices[i] = IOracle(oracle).priceOf(tokens[i]);
            unchecked { ++i; }
        }
        return prices;
    }

    function valueOfDestination(address token, address destination) public view returns (uint256) {
        return valueOfAmount(token, IERC20(token).balanceOf(destination));
    }

    function valueOfETHDestination(address destination) public view returns (uint256) {
        return ( priceOfBNB() * address(destination).balance ) / 10**18;
    }

    function valueOfETHInLotto() public view returns (uint256) {
        return valueOfETHDestination(currentLotto());
    }

    function valueOfAmount(address token, uint256 amount) public view returns (uint256) {
        return ( amount * priceOf(token) ) / 10**IERC20(token).decimals();
    }

    function combinedValueOf(address[] calldata tokens, address destination) public view returns (uint256 total) {
        uint len = tokens.length;
        for (uint i = 0; i < len;) {
            total += valueOfDestination(tokens[i], destination);
            unchecked { ++i; }
        }
    }

    function combinedValueOfLotto(address[] calldata tokens) external view returns (uint256 total) {
        return combinedValueOf(tokens, currentLotto());
    }

    function valueOfLotto() external view returns (uint256 total) {
        address[] memory tokens = allAvailableTokens();
        uint len = tokens.length;
        total = valueOfETHInLotto();
        for (uint i = 0; i < len;) {
            total += valueOfDestination(tokens[i], currentLotto());
            unchecked { ++i; }
        }
    }

    function getBalances() external view returns (uint256[] memory) {
        return _getBalancesForListAtDestination(currentLotto(), allAvailableTokens());
    }

    function getBalancesForList(address[] calldata tokens) public view returns (uint256[] memory) {
        return getBalancesForListAtDestination(currentLotto(), tokens);
    }

    function currentLotto() public view returns (address) {
        return ILottoManager(lottoManager).currentLotto();
    }

    function allAvailableTokens() public view returns (address[] memory) {
        return IListingManager(IOTC(otc).ListingManager()).fetchAllAvailableTokens();
    }

    function getBalancesForListAtDestination(address destination, address[] calldata tokens) public view returns (uint256[] memory) {

        uint len = tokens.length + 1;
        uint256[] memory balances = new uint256[](len);
        balances[0] = address(destination).balance;
        for (uint i = 0; i < len-1;) {
            balances[i+1] = IERC20(tokens[i]).balanceOf(address(destination));
            unchecked { ++i; }
        }
        return balances;
    }

    function _getBalancesForListAtDestination(address destination, address[] memory tokens) internal view returns (uint256[] memory) {
        uint len = tokens.length + 1;
        uint256[] memory balances = new uint256[](len);
        balances[0] = address(destination).balance;
        for (uint i = 0; i < len-1;) {
            balances[i+1] = IERC20(tokens[i]).balanceOf(address(destination));
            unchecked { ++i; }
        }
        return balances;
    }

}