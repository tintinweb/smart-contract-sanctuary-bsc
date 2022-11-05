/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

/**
 *Submitted for verification at BscScan.com on 2020-09-02
 */

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract TokenData {

    struct Datas {
        address Token0;
        string Name0;
        string Symbol0;
        uint8 Decimals0;
        uint256 TotalSupply0;
        address Token1;
        string Name1;
        string Symbol1;
        uint8 Decimals1;
        uint256 TotalSupply1;
    }

    function tokenData(address pair)
        public
        view
        returns (Datas memory)
    {   
        address token0 = IBEP20(pair).token0();
        address token1 = IBEP20(pair).token1();
        Datas memory ds = Datas(
            token0,
            IBEP20(token0).name(),
            IBEP20(token0).symbol(),
            IBEP20(token0).decimals(),
            IBEP20(token0).totalSupply(),
            token1,
            IBEP20(token1).name(),
            IBEP20(token1).symbol(),
            IBEP20(token1).decimals(),
            IBEP20(token1).totalSupply()
        );
        return ds;
    }
}