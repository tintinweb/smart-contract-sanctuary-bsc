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
    IToken public immutable token;

    // Dev Fee Address
    address public treasury;
    address public xShare;

    // Allocations
    uint256 public treasuryCut = 2;
    uint256 public xShareCut   = 4;
    uint256 public burnCut     = 2;

    // Router
    IUniswapV2Router02 public immutable router;
    address[] private path;

    modifier onlyOwner() {
        require(
            msg.sender == token.getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor(
        address token_,
        address treasury_,
        address xShare_,
        address router_
    ) {
        require(
            token_ != address(0) &&
            treasury_ != address(0) &&
            xShare_ != address(0) &&
            router_ != address(0),
            'Zero Check'
        );
        token = IToken(token_);
        treasury = treasury_;
        xShare = xShare_;

        router = IUniswapV2Router02(router_);
        path = new address[](2);
        path[0] = token_;
        path[1] = router.WETH();
    }

    function trigger() external {
        
        // ensure there is balance to distribute
        uint256 balance = token.balanceOf(address(this));
        if (balance == 0) {
            return;
        }

        // split up dev and staking
        uint256 burnAmount = ( balance * burnCut ) / ( treasuryCut + burnCut + xShareCut );

        // burn remainder of tokens
        if (burnAmount > 0) {
            token.burn(burnAmount);
        }

        // sell remainder of tokens
        uint256 tokensToSell = token.balanceOf(address(this));
        if (tokensToSell > 0) {
            token.approve(address(router), tokensToSell);
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokensToSell, 0, path, address(this), block.timestamp + 100
            );
        }
        if (address(this).balance > 0) {
            _sendETH(treasury, ( address(this).balance * treasuryCut ) / ( treasuryCut + xShareCut ));
            _sendETH(xShare, address(this).balance);
        }
    }

    function setTreasury(address treasury_) external onlyOwner {
        require(
            treasury_ != address(0),
            'Zero Check'
        );
        treasury = treasury_;
    }

    function setXShare(address xShare_) external onlyOwner {
        require(
            xShare_ != address(0),
            'Zero Check'
        );
        xShare = xShare_;
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function withdrawToken(IERC20 token_) external onlyOwner {
        require(
            address(token_) != address(token),
            'Cannot Withdraw PTX Tokens'
        );
        token_.transfer(msg.sender, token_.balanceOf(address(this)));
    }

    function setAllocations(
        uint treasury_,
        uint xShare_,
        uint burn_
    ) external onlyOwner {
        require(
            (treasury_ > 0 || burn_ > 0) && xShare_ > 0,
            'Zero Check'
        );
        treasuryCut = treasury_;
        xShareCut = xShare_;
        burnCut = burn_;
    }

    function _send(address to, uint amount) internal {
        if (to == address(0)) {
            return;
        }
        if (amount > token.balanceOf(address(this))) {
            amount = token.balanceOf(address(this));
        }
        if (amount == 0) {
            return;
        }
        token.transfer(to, amount);
    }

    function _sendETH(address to, uint amount) internal {
        if (to == address(0)) {
            return;
        }
        if (amount > address(this).balance) {
            amount = address(this).balance;
        }
        if (amount == 0) {
            return;
        }
        (bool s,) = payable(to).call{value: amount}("");
        require(s, 'FAILURE ON SENDETH');
    }

    receive() external payable {}
}