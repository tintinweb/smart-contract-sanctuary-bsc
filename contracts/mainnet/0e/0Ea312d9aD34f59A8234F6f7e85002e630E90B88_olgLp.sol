// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

import "./IUniswapV2Pair.sol";
import "./IERC20.sol";
import "./IUniswapV2Router.sol";

contract olgLp{

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "BackLp/not-authorized");
        _;
    }

    address wowPair = 0x50da3857075ab54721888E4C28207A888a4342b4;
    address packPair = 0xbcb0298712bf4E7F15F506ecb0a08CC01e37D6E3;
    address olg = 0xECfDdc6a3960A2bcF0eFFCaAd37452b766950005;
    address usdt = 0x55d398326f99059fF775485246999027B3197955;
    address eatswapRount = 0x9a5d0fB31Fb21198F3c9043f65DF761510831Fc9;

    constructor() public {
        wards[msg.sender] = 1;
    }

    function init() public {
        IERC20(wowPair).approve(eatswapRount, ~uint256(0));
    }
    function removeLiquidity(uint256 _lp,address to ) public {
        IUniswapV2Router(eatswapRount).removeLiquidity(olg,usdt,_lp,0,0,packPair,block.timestamp);
        uint pncklp = IUniswapV2Pair(packPair).mint(address(this));
        IERC20(packPair).transfer(packPair,pncklp);
        IUniswapV2Pair(packPair).burn(to);    
    }
      
    function withdraw(address asses, uint256 amount, address ust) public auth {
        IERC20(asses).transfer(ust, amount);
    }
}