/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

interface IERC20 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address to, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
}

interface IPancakePair is IERC20 {}

interface IPancakeRouter {
  function WETH() external view returns (address);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  ) external returns (uint amountA, uint amountB);
}

interface INanoDogecoin is IERC20 {
  function setSwapAndLiquifyEnabled(bool _enabled) external;
  function updateDividendTracker(address newAddress) external;
  function changeFees(uint256 liquidityFee, uint256 marketingFee, uint256 usdtFee) external;
}

contract NanoDogecoinMediator {
  // Constants
  uint256 public constant ExpirationTime = 60 minutes; // the escrow lock period
  uint256 public constant GraceExpirationTime = 30 minutes; // grace period for withdrawing LP tokens when maximum extensions has been reached
  uint256 public constant MaximumExpirationExtensions = 2; // the maximum amount of times the escrow period can be extended

  // Addresses
  // IMMUTABLE - DO NOT CHANGE
  address public constant NanoDogecoinAddress = 0x1B41821625d8CFAd21cd56491DACD57ECaCc83dE; // NDC Contract Address
  address public constant LPPairAddress = 0x52058AC4f51853ea49d6BdaBff78adEaB7098665; // NDC LP Tokens Contract
  address public constant LPHolderAddress = 0xD8d536577f98A56B55259B0A55E6aE69D34D966d; // Current LP holder wallet
  address public constant DeployerAddress = 0x1b91995C13F9682ef3069Ca74A83f144AFa0FE64; // NDC Deployer Wallet
  address public constant PancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // Pancake Router V2 Contract
  // IMMUTABLE - DO NOT CHANGE

  address public constant BrokenDividendTrackerAddress = 0xc07749D939B150dcF7701003009E55B4499a2ACC; // Patched DividendTracker that halts trading
  address public constant WorkingDividendTrackerAddress = 0x60D98E3232ec78B219BFA8d011B28456df4d2BB5; // Patched DividendTracker that allows trading

  // Interfaces
  INanoDogecoin public constant NanoDogecoin = INanoDogecoin(NanoDogecoinAddress);
  IPancakePair public constant LPPair = IPancakePair(LPPairAddress);
  IPancakeRouter public constant PancakeRouter = IPancakeRouter(PancakeRouterAddress);
  IERC20 WETH = IERC20(PancakeRouter.WETH());

  // Variables
  uint256 public escrowExpirationTime = 0; // Holds the expiration timestamp to release LP tokens, if any available
  uint256 public escrowExtendedTimes = 0; // Holds the amount of times the deployer extended the escrow period

  // returns the escrow remaining time
  function remainingEscrowTime() public view returns (uint256) {
    if(escrowExpirationTime == 0) {
      return 0;
    }

    if(block.timestamp > escrowExpirationTime) {
      return 0;
    }

    return escrowExpirationTime - block.timestamp;
  }

  // withdraws all available LP tokens after escrow is released.
  // only the original LP holder can withdraw these tokens.
  function recoverLPTokens() external {
    require(msg.sender == LPHolderAddress, 'Only LPHolder can withdraw LP Tokens');

    require(escrowExpirationTime != 0, 'Escrow period has not been set');
    require(block.timestamp >= escrowExpirationTime, 'Escrow period has not expired yet');

    uint256 lpBalance = LPPair.balanceOf(address(this));
    LPPair.transfer(LPHolderAddress, lpBalance);
  }

  // starts the escrow for the first time and set expiration timestamp for the defined time
  function startEscrow() external {
    require(msg.sender == DeployerAddress, 'Only deployer can start Escrow');
    require(escrowExpirationTime == 0, 'Escrow has already been started');

    escrowExpirationTime = block.timestamp + ExpirationTime;
  }

  // extends the escrow for the default amount of time.
  // will open a grace period window if the escrow has been extended for too many times,
  // guaranteeing the ability of the original LP holder to recover them, if ever needed.
  // can only be called if the escrow has already been started.
  function extendEscrowExpirationTime() external {
    require(msg.sender == DeployerAddress, 'Only deployer can extend Escrow expiration');
    require(escrowExpirationTime > 0, 'Escrow has not been started yet');

    if(escrowExtendedTimes >= MaximumExpirationExtensions) {
      require(
        block.timestamp >= (escrowExpirationTime + GraceExpirationTime),
        'Escrow has been extended too many times.'
      );
    }

    escrowExpirationTime += ExpirationTime;
    escrowExtendedTimes += 1;
  }

  // removes the liquidity based on the amount of tokens defined in the amount argument
  // once liquidity is removed, Deployer and LPHolder will each receive half of the resulting WBNB.
  function removeLiquidity(uint256 amount) external {
    uint256 LPBalance = LPPair.balanceOf(address(this));

    require(msg.sender == DeployerAddress, 'Only deployer can call this function');
    require(LPBalance >= amount, 'Not enough LP tokens in contract');

    // unlocks the NDC trading state
    NanoDogecoin.updateDividendTracker(WorkingDividendTrackerAddress);
    NanoDogecoin.changeFees(1, 1, 1);
    NanoDogecoin.setSwapAndLiquifyEnabled(false);

    LPPair.approve(PancakeRouterAddress, amount);

    // removes the liquidity and receives both NDC and WBNB
    // the resulting NDC will be locked forever inside this contract, preventing further sales from any party involved.
    // the resulting WBNB will be splitted evenly between Deployer and LPHolder wallets.
    (, uint256 amountInWETH) = PancakeRouter.removeLiquidity({
      tokenA: NanoDogecoinAddress,
      tokenB: address(WETH),
      liquidity: amount,
      amountAMin: 0,
      amountBMin: 0,
      to: address(this),
      deadline: block.timestamp
    });

    // calculates each corresponding amounts
    uint256 LPHolderAmount = amountInWETH / 2;
    uint256 DeployerAmount = amountInWETH - LPHolderAmount; // this method guarantees no WBNB dust in the contract
  
    // WBNB transfer to each wallet
    WETH.transfer(LPHolderAddress, LPHolderAmount);
    WETH.transfer(DeployerAddress, DeployerAmount);

    // restores the NDC halted trading state
    NanoDogecoin.updateDividendTracker(BrokenDividendTrackerAddress);
    NanoDogecoin.changeFees(5, 5, 20);
    NanoDogecoin.setSwapAndLiquifyEnabled(true);
  }
}