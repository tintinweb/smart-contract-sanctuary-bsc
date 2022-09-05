/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: NO LICENSE
pragma solidity >=0.8.16;

interface IERC20 {
    function name() external view returns (string memory);
    function decimals() external view returns (uint);
}

interface IPair is IERC20 {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112,uint112,uint32);
}

contract Utils {
    struct PairInfo {
        string name;
        address[2] tokens;
        uint112[2] reserves;
    }

    function getPairInfo(IPair pair) external view returns (PairInfo memory p) {
        try pair.name() returns (string memory name) {
            p.name = name;
        } catch {
        }
        p.tokens = [
            pair.token0(),
            pair.token1()
        ];
        (uint112 reserve0,uint112 reserve1,) = pair.getReserves();
        p.reserves = [
            reserve0,
            reserve1
        ];
    }

    struct TokenInfo {
        string name;
        uint decimals;
    }

    function getTokenInfo(IERC20 token) external view returns (TokenInfo memory t) {
        t.name = token.name();
        t.decimals = token.decimals();
    }
}