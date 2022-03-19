/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.12;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

// Standard ownable with renounce and transfer removed
abstract contract Ownable is Context {
  address private _owner;

  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
}

interface IERC20 {
  function balanceOf(address account) external view returns (uint256);
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  function totalSupply() external view returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);
  function transfer(address to, uint256 value) external returns (bool);
}

interface IWrapped {
  function deposit() external payable;
  function withdraw(uint) external;
}

interface IRouter {
  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint[] memory amounts);
}

contract HedgeFundV0 is Ownable {
  address constant private BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
  address constant private WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
  address constant private BUSD_BNB_LP = 0xe0e92035077c39594793e61802a350347c320cf2;
  address constant private ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
  uint256 constant private INFINITE = 2**256 - 1;

  bool private example = false;

  // Function to receive native funds
  // (For testing withdrawNative we need a way to get native funds into the contract)
  receive() external payable {
  }

  // Withdraws all native funds from the contract
  function withdrawNative() external onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "HedgeFund: nothing to withdraw");

    (bool success, ) = msg.sender.call{value: balance}("");
    require(success, "HedgeFund: unable to send native balance");
  }

  // Withdraws all of a specific ERC20 token from the contract
  function withdrawToken(address token) external onlyOwner {
    uint256 tokenBalance;
    try IERC20(token).balanceOf(address(this)) returns (uint256 balance) {
      tokenBalance = balance;
    } catch {
      require(false, "HedgeFund: Not a valid ERC20 token");
    }
  
    require(tokenBalance > 0, "HedgeFund: nothing to withdraw");

    IERC20(token).transfer(msg.sender, tokenBalance);
  }

  // Approves BUSD and WBNB for spending by ROUTER
  function testApprove() external onlyOwner {
    IERC20(BUSD).approve(ROUTER, INFINITE);
    IERC20(WBNB).approve(ROUTER, INFINITE);
    IERC20(BUSD_BNB_LP).approve(ROUTER, INFINITE);
  }

  function testRevoke() external onlyOwner {
    IERC20(BUSD).approve(ROUTER, 0);
    IERC20(WBNB).approve(ROUTER, 0);
    IERC20(BUSD_BNB_LP).approve(ROUTER, 0);
  }

  function testWrap() external onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "HedgeFund: no funds to wrap");

    IWrapped(WBNB).deposit{value: balance}();
    require(IERC20(WBNB).balanceOf(address(this)) == balance, "HedgeFund: amount mismatch");
  }

  function testUnwrap() external onlyOwner {
    uint256 balance = IERC20(WBNB).balanceOf(address(this));
    require(balance > 0, "HedgeFund: no funds to unwrap");

    IWrapped(WBNB).withdraw(balance);
    require(address(this).balance == balance, "HedgeFund: amount mismatch");
  }

  function testSwapToBUSD() external onlyOwner {
    // Swap all WBNB to BUSD
    uint256 balance = IERC20(WBNB).balanceOf(address(this));
    require(balance > 0, "HedgeFund: no WBNB to swap");

    address[] memory path = new address[](2);
    path[0] = WBNB;
    path[1] = BUSD;

    IRouter(ROUTER).swapExactTokensForTokens(
      balance,
      0,
      path,
      address(this),
      block.timestamp);
  }

  function testSwapToWBNB() external onlyOwner {
    // Swap all BUSD to WBNB
    uint256 balance = IERC20(BUSD).balanceOf(address(this));
    require(balance > 0, "HedgeFund: no BUSD to swap");

    address[] memory path = new address[](2);
    path[0] = BUSD;
    path[1] = WBNB;

    IRouter(ROUTER).swapExactTokensForTokens(
      balance,
      0,
      path,
      address(this),
      block.timestamp);
  }

  function addLiquidity() external onlyOwner {
    uint256 busdBalance = IERC20(BUSD).balanceOf(address(this));
    require(busdBalance > 0, "HedgeFund: no BUSD");

    uint256 wbnbBalance = IERC20(WBNB).balanceOf(address(this));
    require(wbnbBalance > 0, "HedgeFund: no WBNB");

    IRouter(ROUTER).addLiquidity(
      BUSD,
      WBNB,
      busdBalance,
      wbnbBalance,
      0,
      0,
      address(this),
      block.timestamp);
  }

  function removeLiquidity() external onlyOwner {
    uint256 lpBalance = IERC20(BUSD_BNB_LP).balanceOf(address(this));
    require(lpBalance > 0, "HedgeFund: no liquidity to remove");
    
    IRouter(ROUTER).removeLiquidity(
      BUSD,
      WBNB,
      lpBalance,
      0,
      0,
      address(this),
      block.timestamp);
  }

  // Returns true if we should call act() and false otherwise.
  // This should be called continuously so we can act immediately when we need to.
  function check(uint256 minBlockNumber) external view returns (
    uint256 blockNumber, bool needToAct) {
    // Check if the current block is larger than or equal to minimum. If not we
    // assume we have already done the check for this block.
    // (This is an optimization to not put unnecessary load on the RPC server.)
    if (block.number < minBlockNumber) {
      return (block.number, false);
    }

    // TODO
    return (block.number, true);
  }

  // Returns some status values
  function status() external pure returns (uint256 value) {
    return 42;
  }
}