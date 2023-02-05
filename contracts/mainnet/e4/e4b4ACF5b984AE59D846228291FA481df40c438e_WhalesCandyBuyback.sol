/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// "SPDX-License-Identifier: UNLICENSED"

pragma solidity ^0.8.0;


interface IERC20 {
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function burn(uint256 amount) external;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: contracts\interfaces\IPancakeRouter02.sol

pragma solidity >=0.6.2;

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.6.2;

interface IPancakeFactory {
function getPair (address token1, address token2) external pure returns (address);
}





contract WhalesCandyBuyback {

    using SafeMath for uint256;

    address payable public _dev = payable (0x9a27Da147a89871171c06b98944cB4AE6d5Eca43); // TODO (able to set the contract)
    address public _token2Receiver = 0x2096aFDaA68EEaE1EbF95DFdf565eE6d9B1fbA37; // TODO check if this is the right address to receive token 2 (Drip)

    address public contrAddr;

    address public constant addressBUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public addressToken1 = 0x38e0eCAdbeb4ED30d3f764c54B6AB69835143766; // WC
    address public addressToken2 = 0x20f663CEa80FaCE82ACDFA3aAE6862d246cE0333;  // DRIP

    address public constant _pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IPancakeRouter02 _pancakeRouter;

    uint8 public share1 = 80;
    uint8 public share2 = 20;

    modifier onlyDev() {
        require(_dev == msg.sender, "Ownable: caller is not the dev");
        _;
    }

    /* Time of contract launch */
    uint256 public LAUNCH_TIME = 1675551600;
    uint256 public oneWeek = 7 days;
    uint256 public currentWeek = 1000000000;
    

    constructor () {
        _pancakeRouter = IPancakeRouter02(_pancakeRouterAddress);

        contrAddr = address(this);
    }
    

    // Set addresses of new dev
    function setDevs (address payable dev, address token2Receiver) external onlyDev {
        _dev = dev;
        _token2Receiver = token2Receiver;
    }

    // Set lenght of "one Week"
    function lengtOfWeek (uint256 _oneWeek) external onlyDev {
        oneWeek = _oneWeek;
    }
     

    // Set buyback schare 1 and 2
    function setBuyBackShatre(uint8 _share1, uint8 _share2) external onlyDev {
      require(_share1 + _share2 <= 100, "Share1 + Share2 can`t be more than 100!");
        share1 = _share1;
        share2 = _share2;
    }

    // Set Address token1 token2
    // BOTH token need a Liquidity with WETH on the Pancake Router!
    function setTokenAddresses(address _token1, address _token2) external onlyDev {
        addressToken1 = _token1;
        addressToken2 = _token2;
    }

    // function to see which week it is
    function thisWeek() public view returns (uint256) {
        return (block.timestamp - LAUNCH_TIME) / oneWeek;
    }

    // time in seconds until next week starts
    function whenNextWeek() public view returns (uint256) {
        return oneWeek.sub((block.timestamp - LAUNCH_TIME).sub(thisWeek() * oneWeek));
    }

    // receive all token from contract
    function getAllToken (address token) public onlyDev {
        uint256 amountToken = IERC20(token).balanceOf(contrAddr);
        IERC20(token).transfer(_dev, amountToken);
    }
 
    // function to get BUSD balance of contract
    function busdBal() public view returns (uint256) {
        return (IERC20(addressBUSD).balanceOf(contrAddr));
    }

    // to make the contract being able to receive ETH from Router
    receive() external payable {}

    // function to buyback 2 different token with the collected BUSD
    function burnAndBuyback () public {   
        require(currentWeek != thisWeek(), "BuyBack already happened this Week!");     
      
        uint256 BUSDbal = IERC20(addressBUSD).balanceOf(contrAddr);

        if (BUSDbal > 1000000) {  // check if there is an usable amount of BUSD in the contract

          if ( IERC20(addressBUSD).allowance(contrAddr, _pancakeRouterAddress ) < BUSDbal ) {
            IERC20(addressBUSD).approve(_pancakeRouterAddress, type(uint256).max );
          }

          uint256 buyBackShare1 = BUSDbal.mul(share1).div(100);
          uint256 buyBackShare2 = BUSDbal.mul(share2).div(100);

          uint256 token1BalBefore = IERC20(addressToken1).balanceOf(contrAddr);

            address[] memory path1 = new address[](3);
            path1[0] = addressBUSD;
            path1[1] = _pancakeRouter.WETH();
            path1[2] = addressToken1;

            // Buyback token 1 from LP from received BUSD
            _pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens (
            buyBackShare1,
            0,
            path1,
            contrAddr,
            block.timestamp +100
            );

          // Burn received Token1
          uint256 receivedToken1 = IERC20(addressToken1).balanceOf(contrAddr).sub(token1BalBefore);
              if (receivedToken1 > 10000){
                IERC20(addressToken1).transfer(address(0), receivedToken1);
              } 

          if (buyBackShare2 > 100000) {
            uint256 token2BalBefore = IERC20(addressToken2).balanceOf(contrAddr);

              address[] memory path2 = new address[](2);
              path2[0] = addressBUSD;
              path2[1] = addressToken2;

              // Buyback token 2 from LP from received BUSD
              _pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens (
              buyBackShare2,
              0,
              path2,
              contrAddr,
              block.timestamp +100
              );

            // send received Token2 to _token2Receiver
            uint256 receivedToken2 = IERC20(addressToken2).balanceOf(contrAddr).sub(token2BalBefore);
                if (receivedToken2 > 10000){
                  IERC20(addressToken2).transfer(_token2Receiver, receivedToken2);
                }
          }
        }
        currentWeek = thisWeek();   
    }

}