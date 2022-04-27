//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

//import "hardhat/console.sol";

import { Swapper } from "./interfaces/Swapper.sol";
import { MINT } from "./interfaces/MINT.sol";

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Uniswapper is Swapper {

    modifier live {
        require(rate != 0, "Uniswapper/not-live");
        _;
    }

    uint256 public rate;
    address public sgUSDT; //Stargate USDT

    constructor(address sgUSDT_) {
        sgUSDT = sgUSDT_;
    }

    function setRate(uint256 rate_) external {
        rate = rate_;
    }

    function bridgeAsset() external view returns (address) {
        return sgUSDT;
    }

    function isTokenSupported(address token) external view returns(bool) {
        return true;
    }

    function toBridgeAsset(address token, uint256 amount) external live returns (uint256) {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        uint256 quote = amount * rate / 10**18;
        MINT(sgUSDT).mint(msg.sender, quote);
        return quote;
    }

    function fromUSDT(address token, uint256 amount) external live returns (uint256) {
        IERC20(sgUSDT).transferFrom(msg.sender, address(this), amount);
        uint256 quote = (amount * 10**18)/ rate;
        MINT(token).mint(msg.sender, quote);
        return quote;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface Swapper {
    function bridgeAsset() external view returns (address);
    function toBridgeAsset(address token, uint256 amount) external returns (uint256);
    function fromUSDT(address token, uint256 amount) external returns (uint256);
    function isTokenSupported(address token) external view returns(bool);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface MINT {
    function mint(address _to, uint256 _amount) external;
}