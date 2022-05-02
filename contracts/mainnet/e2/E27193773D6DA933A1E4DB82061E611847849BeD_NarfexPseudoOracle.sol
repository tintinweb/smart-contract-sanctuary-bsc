// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

abstract contract PancakeFactory {
    function getPair(address _token0, address _token1) external view virtual returns (address pairAddress);
}

abstract contract PancakePair {
    address public token0;
    address public token1;
    function getReserves() public view virtual returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

/**
  * An oracle that looks to Pancakeswap contracts for token prices instead of external sources.
  * This cannot be called a real oracle, because the interaction takes place inside the blockchain.
  */
contract NarfexPseudoOracle {

    address public factoryAddress; // PancakeFactory for pairs getting
    address public USDT; // Tether address in current network
    address public WrappedNative; // Wrapped native coin address (like WBNB in BSC or WETH in Ether)
    uint constant WAD = 10 ** 18; // Decimal number with 18 digits of precision

    constructor(address _factory, address _USDT, address _WrappedNative) {
        factoryAddress = _factory;
        USDT = _USDT;
        WrappedNative = _WrappedNative;
    }

    // Returns pair address from PancakeFactory
    function getPair(address _token0, address _token1) public view returns (address pairAddress) {
        PancakeFactory factory = PancakeFactory(factoryAddress);
        return factory.getPair(_token0, _token1);
    }

    // Returns ratio in a decimal number with 18 digits of precision
    function getRatio(address _token0, address _token1) public view returns (uint) {
        PancakePair pair = PancakePair(getPair(_token0, _token1));
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = pair.getReserves();
        if (pair.token0() == _token0) {
            return reserve1 * WAD / reserve0;
        } else {
            return reserve0 * WAD / reserve1;
        }
    }

    // Returns token native price (in native coins of current network) in a decimal number with 18 digits of precision
    function getPrice(address _token) public view returns (uint) {
        if (_token == WrappedNative) {
            return WAD;
        } else {
            return getRatio(_token, WrappedNative);
        }
    }

    // Returns token USD price in a decimal number with 18 digits of precision
    function getUSDPrice(address _token) public view returns (uint) {
        if (_token == USDT) {
            return WAD;
        } else {
            return getRatio(_token, USDT);
        }
    }

}