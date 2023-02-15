//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IToken is IERC20 {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

contract SellReceiver {

    // Main Token
    IToken public constant token = IToken(0x9cb949e8c256C3EA5395bbe883E6Ee6a20Db6045);

    // Router
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x39255DA12f96Bb587c7ea7F22Eead8087b0a59ae);

    // BUSD
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // Addresses
    address public constant addr0 = 0x661B941969e8e358E29461b60f451c9416336989;
    address public constant addr1 = 0x53D2351da23FC86a1aB64128Acc18dA6963EacbB;

    // has entered
    bool public hasEntered = false;

    modifier onlyOwner() {
        require(
            msg.sender == token.getOwner(),
            'Only Owner'
        );
        _;
    }

    function trigger() external {

        if (hasEntered) {
            return;
        } else {
            hasEntered = true;
        }
        
        // ensure there is balance to distribute
        uint256 balance = token.balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        // create swap path
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = BUSD;

        // approve and sell
        IERC20(token).approve(address(router), balance);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(balance, 1, path, address(this), block.timestamp + 1000);

        // new balance
        uint bal = IERC20(BUSD).balanceOf(address(this));

        // split up amount
        uint addr0Cut = bal * 7 / 15;
        uint addr1Cut = bal - addr0Cut;

        // send BUSD
        IERC20(BUSD).transfer(addr0, addr0Cut);
        IERC20(BUSD).transfer(addr1, addr1Cut);

        // clear memory
        delete path;

        // reset entry
        hasEntered = false;
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(IERC20 token_) external onlyOwner {
        token_.transfer(msg.sender, token_.balanceOf(address(this)));
    }

    receive() external payable {}
}