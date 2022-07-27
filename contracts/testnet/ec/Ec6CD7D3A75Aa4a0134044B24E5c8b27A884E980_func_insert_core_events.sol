/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library core_events {
    // -- Core Borrowing Events --
    event Borrow(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        address borrowTokenAddress,
        address collateralTokenAddress,
        uint256 borrowAmount,
        uint256 collateralAmount,
        uint256 owedPerDay,
        uint256 minInterest,
        uint8 newLoan,
        uint64 rolloverTimestamp
    );

    event CloseLoan(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        uint256 borrowPaid,
        uint256 interestPaid,
        uint256 collateralAmountwithdraw
    );
    event Repay(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        bool closeLoan,
        uint256 borrowPaid,
        uint256 interestPaid,
        uint256 collateralAmountwithdraw
    );
    event AdjustCollateral(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        bool isAdd,
        uint256 collateralAdjustAmount
    );
    event Rollover(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        address bountyHunter,
        uint256 delayInterest,
        uint256 bountyReward,
        address bountyRewardTokenAddress,
        uint256 newInterestOwedPerDay
    );
    event Liquidate(
        address indexed owner,
        uint256 indexed nftId,
        uint256 indexed loanId,
        address liquidator,
        uint256 swapPrice,
        uint256 tokenAmountFromSwap,
        uint256 bountyReward,
        address bountyRewardTokenAddress,
        uint256 tokenSentBackToUser
    );
    event SettleForwInterest(
        address indexed coreAddress,
        address indexed interestVaultAddress,
        address forwDistributionAddress,
        address forwTokenAddress,
        uint256 amount
    );
    // -- Core Borrowing Events --

    // -- Core Setting Events --
    event SetMembershipAddress(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event SetPriceFeedAddress(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event SetRouterAddress(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event SetCoreBorrowingAddress(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event SetFeeController(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event SetForwDistributorAddress(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event SetWETHHandler(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event SetLoanDuration(
        address indexed sender,
        uint256 oldValue,
        uint256 newValue
    );
    event SetAdvancedInterestDuration(
        address indexed sender,
        uint256 oldValue,
        uint256 newValue
    );
    event SetFeeSpread(
        address indexed sender,
        uint256 oldValue,
        uint256 newValue
    );
    event RegisterNewPool(address indexed sender, address poolAddress);
    event SetupLoanConfig(
        address indexed sender,
        address indexed borrowTokenAddress,
        address indexed collateralTokenAddress,
        uint256 oldSafeLTV,
        uint256 oldMaxLTV,
        uint256 oldLiquidationLTV,
        uint256 oldBountyFeeRate,
        uint256 newSafeLTV,
        uint256 newLMaxLTV,
        uint256 newLiquidationLTV,
        uint256 newBountyFeeRate
    );
    event SetFowPerBlock(
        address indexed sender,
        uint256 amount,
        uint256 targetBlock
    );
    event ApprovedForRouter(
        address indexed sender,
        address asset,
        address router
    );
    // -- Core Setting Events --

    // -- Membership Events --
    event SetNewPool(address indexed sender, address newPool);
    event SetBaseURI(address indexed sender, string baseTokenURI);
    event SetDefaultMembership(address indexed sender, uint256 tokenId);
    event UpdateRank(address indexed sender, uint256 tokenId, uint8 newRank);
    // -- Membership Events --

    // -- Timelock Events --
    event CallScheduled(
        bytes32 indexed id,
        uint256 indexed index,
        address target,
        uint256 value,
        bytes data,
        bytes32 predecessor,
        uint256 delay
    );
    event CallExecuted(
        bytes32 indexed id,
        uint256 indexed index,
        address target,
        uint256 value,
        bytes data
    );
    event Cancelled(bytes32 indexed id);
    event MinDelayChange(uint256 oldDuration, uint256 newDuration);
    // -- Timelock Events --

    // -- Interest Vault Events --
    event SetTokenAddress(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event SetForwAddress(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event SetProtocolAddress(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event OwnerApprove(
        address indexed sender,
        address tokenAddress,
        address forwAddress,
        uint256 amount
    );
    event SettleInterest(
        address indexed sender,
        uint256 claimableTokenInterest,
        uint256 heldTokenInterest,
        uint256 claimableForwInterest
    );
    event WithdrawTokenInterest(
        address indexed sender,
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    );
    event WithdrawForwInterest(address indexed sender, uint256 claimable);
    event WithdrawActualProfit(address indexed sender, uint256 profitWithdraw);
    // -- Interest Vault Events --

    // -- Pool Lending Events --
    event Deposit(
        address indexed owner,
        uint256 indexed nftId,
        uint256 depositAmount,
        uint256 mintedP,
        uint256 mintedItp,
        uint256 mintedIfp
    );
    event Withdraw(
        address indexed owner,
        uint256 indexed nftId,
        uint256 withdrawAmount,
        uint256 burnedP,
        uint256 burnedItp,
        uint256 burnedIfp
    );
    event ClaimTokenInterest(
        address indexed owner,
        uint256 indexed nftId,
        uint256 interestTokenClaimed,
        uint256 interestTokenBonus,
        uint256 burnedItp
    );
    event ClaimForwInterest(
        address indexed owner,
        uint256 indexed nftId,
        uint256 interestForwClaimed,
        uint256 interestForwBonus,
        uint256 burnedIfp
    );
    event ActivateRank(
        address indexed owner,
        uint256 indexed nftId,
        uint8 oldRank,
        uint8 newRank
    );
    // -- Pool Lending Events --

    // -- Pool Setting Events --
    event SetBorrowInterestParams(
        address indexed sender,
        uint256[] rates,
        uint256[] utils,
        uint256 targetSupply
    );
    event SetLoanConfig(
        address indexed sender,
        address collateralTokenAddress,
        uint256 safeLTV,
        uint256 maxLTV,
        uint256 liqLTV,
        uint256 bountyFeeRate
    );
    event SetPoolLendingAddress(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event SetPoolBorrowingAddress(
        address indexed sender,
        address oldValue,
        address newValue
    );
    event Initialize(
        address indexed manager,
        address indexed coreAddress,
        address interestVaultAddress,
        address membershipAddress
    );
    // -- Pool Setting Events --

    // -- Pool Token Events --
    event MintPToken(
        address indexed minter,
        uint256 indexed nftId,
        uint256 amount
    );
    event MintItpToken(
        address indexed minter,
        uint256 indexed nftId,
        uint256 amount,
        uint256 price
    );
    event MintIfpToken(
        address indexed minter,
        uint256 indexed nftId,
        uint256 amount,
        uint256 price
    );
    event BurnPToken(
        address indexed burner,
        uint256 indexed nftId,
        uint256 amount
    );
    event BurnItpToken(
        address indexed burner,
        uint256 indexed nftId,
        uint256 amount,
        uint256 price
    );
    event BurnIfpToken(
        address indexed burner,
        uint256 indexed nftId,
        uint256 amount,
        uint256 price
    );
    // -- Pool Token Events --

    // -- Stake Pool Events --
    event Stake(address indexed sender, uint256 indexed nftId, uint256 amount);
    event UnStake(
        address indexed sender,
        uint256 indexed nftId,
        uint256 amount
    );
    event DeprecateStakeInfo(address indexed sender, uint256 indexed nftId);
    event SetPoolStartTimestamp(
        address indexed sender,
        uint64 indexed timestamp
    );
    event SetNextPool(address indexed sender, address newPool);
    event SetSettleInterval(address indexed sender, uint256 interval);
    event SetSettlePeriod(address indexed sender, uint256 period);
    event SetRankInfo(
        address indexed sender,
        uint256[] interestBonusLending,
        uint256[] forwardBonusLending,
        uint256[] minimumstakeAmount,
        uint256[] maxLTVBonus,
        uint256[] tradingFee
    );
    // -- Stake Pool Events --

    // -- Utils Events --
    event FaucetTransfer(
        address indexed to,
        address tokenAddress,
        uint256 value,
        uint256 timestamp
    );
    event GlobalPricingPaused(address indexed sender, bool isPaused);
    event SetPriceFeed(
        address indexed sender,
        address[] tokens,
        address[] feeds
    );
    event SetDecimals(address indexed sender, address[] tokens);
    event OwnerApproveVault(
        address indexed sender,
        address pool,
        uint256 amount
    );
    event ApproveInterestVault(
        address indexed sender,
        address core,
        uint256 amount
    );
    // -- Utils Events --
    
}

contract func_insert_core_events {
    // -- function insert : core borrowing events --
    function insert_borrow (
        address owner,
        uint256 nftId,
        uint256 loanId,
        address borrowTokenAddress,
        address collateralTokenAddress,
        uint256 borrowAmount,
        uint256 collateralAmount,
        uint256 owedPerDay,
        uint256 minInterest,
        uint8 newLoan,
        uint64 rolloverTimestamp
    ) public {
        emit core_events.Borrow(owner,nftId,loanId,borrowTokenAddress,collateralTokenAddress,borrowAmount,collateralAmount,owedPerDay,minInterest,newLoan,rolloverTimestamp);
    }
    function insert_close_loan (
        address owner,
        uint256 nftId,
        uint256 loanId,
        uint256 borrowPaid,
        uint256 interestPaid,
        uint256 collateralAmountwithdraw
     ) public {
        emit core_events.CloseLoan(owner,nftId,loanId,borrowPaid,interestPaid,collateralAmountwithdraw);
    }
    function insert_repay (
        address owner,
        uint256 nftId,
        uint256 loanId,
        bool closeLoan,
        uint256 borrowPaid,
        uint256 interestPaid,
        uint256 collateralAmountwithdraw
     ) public {
        emit core_events.Repay(owner,nftId,loanId,closeLoan,borrowPaid,interestPaid,collateralAmountwithdraw);
    }
    function insert_adjust_collateral (
        address owner,
        uint256 nftId,
        uint256 loanId,
        bool isAdd,
        uint256 collateralAdjustAmount
     ) public {
        emit core_events.AdjustCollateral(owner,nftId,loanId,isAdd,collateralAdjustAmount);
    }
    function insert_rollover (
        address owner,
        uint256 nftId,
        uint256 loanId,
        address bountyHunter,
        uint256 delayInterest,
        uint256 bountyReward,
        address bountyRewardTokenAddress,
        uint256 newInterestOwedPerDay
    ) public {
        emit core_events.Rollover(owner,nftId,loanId,bountyHunter,delayInterest,bountyReward,bountyRewardTokenAddress,newInterestOwedPerDay);
    }
    function insert_liquidate(
        address owner,
        uint256 nftId,
        uint256 loanId,
        address liquidator,
        uint256 swapPrice,
        uint256 tokenAmountFromSwap,
        uint256 bountyReward,
        address bountyRewardTokenAddress,
        uint256 tokenSentBackToUser
    ) public {
        emit core_events.Liquidate(owner,nftId,loanId,liquidator,swapPrice,tokenAmountFromSwap,bountyReward,bountyRewardTokenAddress,tokenSentBackToUser);
    }
    function insert_settle_forw_interest(
        address coreAddress,
        address interestVaultAddress,
        address forwDistributionAddress,
        address forwTokenAddress,
        uint256 amount
    ) public {
        emit core_events.SettleForwInterest(coreAddress,interestVaultAddress,forwDistributionAddress,forwTokenAddress,amount);
    }

    // -- function insert : core setting events --
    function insert_set_membership_address(
        address sender,
        address oldValue,
        address newValue
    ) public {
        emit core_events.SetMembershipAddress(sender,oldValue,newValue);
    }
    function insert_set_price_feed_address(
        address sender,
        address oldValue,
        address newValue
    ) public {
        emit core_events.SetPriceFeedAddress(sender,oldValue,newValue);
    }
    function insert_set_router_address(
        address sender,
        address oldValue,
        address newValue
    ) public {
        emit core_events.SetRouterAddress(sender,oldValue,newValue);
    }
    function insert_set_core_borrowing_address(
        address sender,
        address oldValue,
        address newValue
    ) public{
        emit core_events.SetCoreBorrowingAddress(sender,oldValue,newValue);
    }
    function insert_set_fee_controller(
        address sender,
        address oldValue,
        address newValue
    ) public {
        emit core_events.SetFeeController(sender,oldValue,newValue);
    }
    function insert_set_forw_distributor_address(
        address sender,
        address oldValue,
        address newValue
    ) public {
        emit core_events.SetForwDistributorAddress(sender,oldValue,newValue);
    }
    function insert_set_weth_handler(
        address sender,
        address oldValue,
        address newValue
    ) public {
        emit core_events.SetWETHHandler(sender,oldValue,newValue);
    }
    function insert_set_loan_duration(
        address sender,
        uint256 oldValue,
        uint256 newValue
    ) public {
        emit core_events.SetLoanDuration(sender,oldValue,newValue);
    }
    function insert_set_advanced_interest_duration(
        address sender,
        uint256 oldValue,
        uint256 newValue
    ) public {
        emit core_events.SetAdvancedInterestDuration(sender,oldValue,newValue);
    }
    function insert_set_fee_spread(
        address sender,
        uint256 oldValue,
        uint256 newValue
    ) public {
        emit core_events.SetFeeSpread(sender,oldValue,newValue);
    }
    function insert_register_new_pool(
        address sender, 
        address poolAddress
    ) public {
        emit core_events.RegisterNewPool(sender,poolAddress);
    }
    function insert_setup_loan_config(
        address sender,
        address borrowTokenAddress,
        address collateralTokenAddress,
        uint256 oldSafeLTV,
        uint256 oldMaxLTV,
        uint256 oldLiquidationLTV,
        uint256 oldBountyFeeRate,
        uint256 newSafeLTV,
        uint256 newLMaxLTV,
        uint256 newLiquidationLTV,
        uint256 newBountyFeeRate
    ) public {
        emit core_events.SetupLoanConfig(sender,borrowTokenAddress,collateralTokenAddress,oldSafeLTV,oldMaxLTV,oldLiquidationLTV,oldBountyFeeRate,newSafeLTV,newLMaxLTV,newLiquidationLTV,newBountyFeeRate);
    }
    function insert_set_fow_per_block(
        address sender,
        uint256 amount,
        uint256 targetBlock
    ) public {
        emit core_events.SetFowPerBlock(sender,amount,targetBlock);
    }
    function insert_approved_for_router(
        address sender,
        address asset,
        address router
    ) public {
        emit core_events.ApprovedForRouter(sender,asset,router);
    }

    // -- function insert : membership events --
    function insert_set_new_pool(
        address sender, 
        address newPool
    ) public {
        emit core_events.SetNewPool(sender,newPool);
    }
    function insert_set_base_uri(
        address sender, 
        string memory baseTokenURI
    ) public {
        emit core_events.SetBaseURI(sender,baseTokenURI);
    }
    function insert_set_default_membership(
        address sender, 
        uint256 tokenId
    ) public {
        emit core_events.SetDefaultMembership(sender,tokenId);
    }
    function insert_UpdateRank(
        address sender, 
        uint256 tokenId, 
        uint8 newRank
    ) public {
        emit core_events.UpdateRank(sender,tokenId,newRank);
    }

    // -- function insert : timelock events --
    function insert_call_scheduled(
        bytes32 id,
        uint256 index,
        address target,
        uint256 value,
        bytes memory data,
        bytes32 predecessor,
        uint256 delay
    ) public {
        emit core_events.CallScheduled(id,index,target,value,data,predecessor,delay);
    }
    function insert_call_executed(
        bytes32 id,
        uint256 index,
        address target,
        uint256 value,
        bytes memory data
    ) public {
        emit core_events.CallExecuted(id,index,target,value,data);
    }
    function insert_cancelled(
        bytes32 id
    ) public {
        emit core_events.Cancelled(id);
    }
    function insert_min_delay_change(
        uint256 oldDuration,
        uint256 newDuration
    ) public {
        emit core_events.MinDelayChange(oldDuration,newDuration);
    }

    // -- function insert : interest vault events --
    function insert_set_token_address(
        address sender,
        address oldValue,
        address newValue
    ) public {
        emit core_events.SetTokenAddress(sender,oldValue,newValue);
    }
    function insert_set_forw_address(
        address sender,
        address oldValue,
        address newValue
    ) public {
        emit core_events.SetForwAddress(sender,oldValue,newValue);
    }
    function insert_set_protocol_address(
        address sender,
        address oldValue,
        address newValue
    ) public {
        emit core_events.SetProtocolAddress(sender,oldValue,newValue);
    }
    function insert_owner_approve(
        address sender,
        address tokenAddress,
        address forwAddress,
        uint256 amount
    ) public {
        emit core_events.OwnerApprove(sender,tokenAddress,forwAddress,amount);
    }
    function insert_settle_interest(
        address sender,
        uint256 claimableTokenInterest,
        uint256 heldTokenInterest,
        uint256 claimableForwInterest
    ) public {
        emit core_events.SettleInterest(sender,claimableTokenInterest,heldTokenInterest,claimableForwInterest);
    }
    function insert_withdraw_token_interest(
        address sender,
        uint256 claimable,
        uint256 bonus,
        uint256 profit
    ) public {
        emit core_events.WithdrawTokenInterest(sender,claimable,bonus,profit);
    }
    function insert_withdraw_forw_interest(
        address sender, 
        uint256 claimable
    ) public {
        emit core_events.WithdrawForwInterest(sender,claimable);
    }
    function insert_WithdrawActualProfit(
        address sender, 
        uint256 profitWithdraw
    ) public {
        emit core_events.WithdrawActualProfit(sender,profitWithdraw); 
     }

    // -- function insert : poll lending events --
    function insert_deposit(
        address owner,
        uint256 nftId,
        uint256 depositAmount,
        uint256 mintedP,
        uint256 mintedItp,
        uint256 mintedIfp
    ) public {
        emit core_events.Deposit(owner,nftId,depositAmount,mintedP,mintedItp,mintedIfp);
    }
    function insert_withdraw(
        address owner,
        uint256 nftId,
        uint256 withdrawAmount,
        uint256 burnedP,
        uint256 burnedItp,
        uint256 burnedIfp
    ) public {
        emit core_events.Withdraw(owner,nftId,withdrawAmount,burnedP,burnedItp,burnedIfp);
    }
    function insert_claim_token_interest(
        address owner,
        uint256 nftId,
        uint256 interestTokenClaimed,
        uint256 interestTokenBonus,
        uint256 burnedItp
    ) public {
        emit core_events.ClaimTokenInterest(owner,nftId,interestTokenClaimed,interestTokenBonus,burnedItp);
    }
    function insert_claim_forw_interest(
        address owner,
        uint256 nftId,
        uint256 interestForwClaimed,
        uint256 interestForwBonus,
        uint256 burnedIfp
    ) public {
        emit core_events.ClaimForwInterest(owner,nftId,interestForwClaimed,interestForwBonus,burnedIfp);
    }
    function insert_activate_rank(
        address owner,
        uint256 nftId,
        uint8 oldRank,
        uint8 newRank
    ) public {
        emit core_events.ActivateRank(owner,nftId,oldRank,newRank);
    }

    // -- function insert : poll setting events --
    function insert_set_borrow_interest_params(
        address sender,
        uint256[] memory rates,
        uint256[] memory utils,
        uint256 targetSupply
    ) public {
        emit core_events.SetBorrowInterestParams(sender,rates,utils,targetSupply);
    }
    function insert_set_loan_config(
        address sender,
        address collateralTokenAddress,
        uint256 safeLTV,
        uint256 maxLTV,
        uint256 liqLTV,
        uint256 bountyFeeRate
    ) public {
        emit core_events.SetLoanConfig(sender,collateralTokenAddress,safeLTV,maxLTV,liqLTV,bountyFeeRate);
    }
    function insert_set_pool_lending_address(
        address sender,
        address oldValue,
        address newValue
    ) public {
        emit core_events.SetPoolLendingAddress(sender,oldValue,newValue);
    }
    function insert_set_pool_borrowing_address(
        address sender,
        address oldValue,
        address newValue
    ) public {
        emit core_events.SetPoolBorrowingAddress(sender,oldValue,newValue);
    }
    function insert_initialize(
        address manager,
        address coreAddress,
        address interestVaultAddress,
        address membershipAddress
    ) public {
        emit core_events.Initialize(manager,coreAddress,interestVaultAddress,membershipAddress);
    }

    // -- function insert : poll token events --
    function insert_mint_p_token(
        address minter,
        uint256 nftId,
        uint256 amount
    ) public {
        emit core_events.MintPToken(minter,nftId,amount);
    }
    function insert_mint_itp_token(
        address minter,
        uint256 nftId,
        uint256 amount,
        uint256 price
    ) public {
        emit core_events.MintItpToken(minter,nftId,amount,price);
    }
    function insert_MintIfpToken(
        address minter,
        uint256 nftId,
        uint256 amount,
        uint256 price
    ) public {
        emit core_events.MintIfpToken(minter,nftId,amount,price);
    }
    function insert_BurnPToken(
        address burner,
        uint256 nftId,
        uint256 amount
    ) public {
        emit core_events.BurnPToken(burner,nftId,amount);
    }
    function insert_BurnItpToken(
        address burner,
        uint256 nftId,
        uint256 amount,
        uint256 price
    ) public {
        emit core_events.BurnItpToken(burner,nftId,amount,price);
    }
    function insert_BurnIfpToken(
        address burner,
        uint256 nftId,
        uint256 amount,
        uint256 price
    ) public {
        emit core_events.BurnIfpToken(burner,nftId,amount,price);
    }

    // -- function insert : stake poll events --
    function insert_stake(
        address sender, 
        uint256 nftId, 
        uint256 amount
    ) public {
        emit core_events.Stake(sender,nftId,amount);
    }
    function insert_un_stake(
        address sender,
        uint256 nftId,
        uint256 amount
    ) public {
        emit core_events.UnStake(sender,nftId,amount);
    }
    function insert_deprecate_stake_info(
        address sender, 
        uint256 nftId
    ) public {
        emit core_events.DeprecateStakeInfo(sender,nftId);
    }
    function insert_set_pool_start_timestamp(
        address sender,
        uint64 timestamp
    ) public {
        emit core_events.SetPoolStartTimestamp(sender,timestamp);
    }
    function insert_set_next_pool(
        address sender, 
        address newPool
    ) public {
        emit core_events.SetNextPool(sender,newPool);
    }
    function insert_set_settle_interval(
        address sender, 
        uint256 interval
    ) public {
        emit core_events.SetSettleInterval(sender,interval);
    }
    function insert_set_settle_period(
        address sender, 
        uint256 period
    ) public {
        emit core_events.SetSettlePeriod(sender,period);
    }
    function insert_set_rank_info(
        address sender,
        uint256[] memory interestBonusLending,
        uint256[] memory forwardBonusLending,
        uint256[] memory minimumstakeAmount,
        uint256[] memory maxLTVBonus,
        uint256[] memory tradingFee
    ) public {
        emit core_events.SetRankInfo(sender,interestBonusLending,forwardBonusLending,minimumstakeAmount,maxLTVBonus,tradingFee);
    }

    // -- function insert : utils events --
    function insert_FaucetTransfer(
        address to,
        address tokenAddress,
        uint256 value,
        uint256 timestamp
    ) public {
        emit core_events.FaucetTransfer(to,tokenAddress,value,timestamp);
    }
    function insert_GlobalPricingPaused(
        address sender, 
        bool isPaused
    ) public {
        emit core_events.GlobalPricingPaused(sender,isPaused);
    }
    function insert_SetPriceFeed(
        address sender,
        address[] memory tokens,
        address[] memory feeds
    ) public {
        emit core_events.SetPriceFeed(sender,tokens,feeds);
    }
    function insert_SetDecimals(
        address sender, 
        address[] memory tokens
    ) public {
        emit core_events.SetDecimals(sender,tokens);
    }
    function insert_OwnerApproveVault(
        address sender,
        address pool,
        uint256 amount
    ) public {
        emit core_events.OwnerApproveVault(sender,pool,amount);
    }
    function insert_ApproveInterestVault(
        address sender,
        address core,
        uint256 amount
    ) public {
        emit core_events.ApproveInterestVault(sender,core,amount);
    }
}