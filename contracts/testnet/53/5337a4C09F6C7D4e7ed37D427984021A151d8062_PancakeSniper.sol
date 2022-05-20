// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./IUniswapV2Router02.sol"; //Для панкейка используется роутер юнисвапа
import "./SafeERC20.sol";
import "./Ownable.sol";

contract PancakeSniper is Ownable {
    
    using SafeERC20 for IERC20;


    address internal constant UNISWAP_ROUTER_ADDRESS = 0xdc4904b5f716Ff30d8495e35dC99c109bb5eCf81; //Pancake Router
    IUniswapV2Router02 public uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);

    event Received(address sender, uint amount);
    event TokensBuyedAmount(uint256 amount);
    event TokensSoldForBNBAmount(uint256 amount);
    
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    function buyToken(address targetContract) public onlyOwner {
        uint bnbAmount = address(this).balance / 10;
        uint deadline = block.timestamp + 30;


        address[] memory path = new address[](2);
        path = getPathForBNBtoToken(targetContract);

        uint[] memory tokenAmount = uniswapRouter.getAmountsOut(bnbAmount, path);
        tokenAmount[0] = tokenAmount[0] / 10;
        uniswapRouter.swapETHForExactTokens {
            value: bnbAmount
        }(tokenAmount[1], getPathForBNBtoToken(targetContract), address(this), deadline);
        emit TokensBuyedAmount(tokenAmount[0]);
    }

    function sellToken(address targetContract) public onlyOwner {
        IERC20 token = IERC20(targetContract);

        uint tokenAmount = token.balanceOf(address(this));
        uint deadline = block.timestamp + 30;

        address[] memory path = new address[](2);
        path = getPathForTokentoBNB(targetContract);

        uint[] memory bnbAmount = uniswapRouter.getAmountsOut(tokenAmount, path);
        bnbAmount[1] = bnbAmount[1] / 2;

        require(token.approve(address(uniswapRouter), tokenAmount), "Approve failed");

        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, bnbAmount[1], path, address(this), deadline);
        emit TokensSoldForBNBAmount(bnbAmount[1]);
    }

    function getPathForBNBtoToken(address _address) private view returns(address[] memory) {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = _address;
        return path;
    }

    function getPathForTokentoBNB(address _address) private view returns(address[] memory) {
        address[] memory path = new address[](2);
        path[0] = _address;
        path[1] = uniswapRouter.WETH();
        return path;
    }

    function withdraw(address payable to) public onlyOwner {
        to.transfer(address(this).balance);
    }

    function withdrawToken(address to, address _address) public onlyOwner {
        IERC20 token = IERC20(_address);
        token.safeTransfer(to, token.balanceOf(address(this)));
    }
}