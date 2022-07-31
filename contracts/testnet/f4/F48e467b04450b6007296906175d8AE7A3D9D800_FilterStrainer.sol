/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

//SPDX-License-Identifier: UNLICENSED

/*

FilterStrainer rules

Token A launches with 1,000,000 total supply

500,000 goes to FilterSwap

if initialExchangeSupply[tokenAddr] == 0 then
    initialExchangeSupply = 500k

Threats:
Honeypot (buy but can't sell)
Heavy tax (buy but amountOut is less than 50% of getAmountOut)
Heavy selling


variables:
    mapping(address => bool) public isFlaggedAsScam
    uint maxAllowableTxSellImpact = 30 (percent)
    uint maxAllowableTxTaxAmount = 50 (percent)
    uint minSellLimitCooldownTime = 60 (seconds)


Things to consider:

Honeypot:
    Can't sell: is this bc the token is a scam? Or bc the user hasn't approved it
    So check what the approval amount is for the token: if approval amount is less than amount to sell then it's not flagged as a scam
    Also consider 

    If user is unable to sell and has approved correct amount: flagged as scam

Heavy tax:
    If actual amount out is less than 50% of expectedAmountOut: flagged as scam

Heavy selling:
    Any user cannot sell so much tokens at once that it causes the price to decrease by more than 30%
    If so, then that sell is blocked, but it won't be flagged as a scam

    Any other selling is recorded, and if a user causes price impact to go down by maxAllowableTxSellImpact within minSellLimitCooldownTime period,
    then selling is throttled until one minute later

    consider that users may get gifted tokens that are not accounted for

Block extremely small sells (where expected amountOut is less than 0.0001 BNB, it could mess with output, but consider other token pairs)

how does swapExactTokensForTokens etc work then?

    get expectedAmountOut

    try selling

    if cannot sell but has been approved then revert
    AND flag as scam

    if actualAmountOut < expectedAmountOut * (maxAllowableTxSellImpact / 100) then revert
    AND flag as scam

    if priceImpact > maxAllowableTxSellImpact then revert
    but nothing else


what happens when flagged as scam?
    - isFlaggedAsScam set to True
    - UI prevents from swapping (prohibited, give a warning)
    - buying and selling are prohibited

    - Both pairs from pair contract (eg. WBNB and shitcoin) are both transferred to the FilterTank contract
    - users can claim back tokens based on their balance? or last recorded balance on contract? think that thru


voting (governance) system

users can change above params depending on how many SIEVE tokens they own

IMPORTANT!!!!!!!!!! FEE FOR DEPLOYER EITHER FIXED OR PERCENTAGE OF LIQ

--------------

What are the problems with stopping these threats?

- Honeypot: if TRANSFER_FAILED or TRANSFER_FROM_FAILED but approval is good then it can be marked as a honeypot. 
BUT: what if buy fee is 99% ? and sell fee is 0 % ?


- Heavy tax: Need to consider slippage. That messes things up, could be bc of genuine buying / selling activity

Imagine there is a token with no tax. You submit a buy TX -> huge buy from another wallet -> your buy: you get alot less tokens than you would expect to get
Is this because the token is a honeypot? Or is this because of normal trading?

- Heavy selling: owner could just mint tokens, split them across different accounts and sell at same time?


---------------

Conditions that guarantee the token is a scam and are foolproof

- Honeypot: if TRANSFER_FAILED or TRANSFER_FROM_FAILED but approval is good then it can be marked as a honeypot. 
- This will stop: all honeypots, and tokens that have blacklist functionality



-------------



If token is verified, no rules apply

If token is unverified, all rules apply

Banned token contracts:
- Tokens that are honeypots
- Tokens that mint extra supply
- Tokens that have over 50% buy/sell fee



BUT: consider slippage. It's difficult to measure the true fee of a token

*/


// DESIGNED ONLY FOR TOKEN THAT HAVE WETH AS BASE PAIR ATM

pragma solidity ^0.8;

interface IFilterManager {
    function adminAddress() external view returns (address);
    function feeToAddress() external view returns (address);

    function factoryAddress() external view returns (address);
    function routerAddress() external view returns (address);
    function deployerAddress() external view returns (address);
    function strainerAddress() external view returns (address);

    function wethAddress() external view returns (address);

    function liquidityUnlockTimes(address, address) external view returns (uint);
    function isVerifiedSafe(address) external view returns (bool);
    function isFlaggedAsScam(address) external view returns (bool);

    function minLiquidityLockTime() external view returns (uint);
    function tokenMintFee() external view returns (uint);

    function tokenTemplateAddresses() external view returns (address);

    function setVerifiedSafe(address) external;
    function setFlaggedAsScam(address) external;

    function strainerRecoveryFee() external view returns (uint);
}

interface IFilterPair {
    function transferReserves() external;
    function token0() external returns (address);
    function token1() external returns (address);
    function getReserves() external view returns (uint112, uint112, uint32);
}

interface IERC20 {
    function balanceOf(address) external view returns (uint);
    function transfer(address, uint) external returns (bool);
}

interface IWETH {
    function withdraw(uint) external;
}

contract FilterStrainer {
    IFilterManager filterManager;
    address public managerAddress;

    mapping(address => bool) public isFlaggedAsScam;
    event flaggedAsScam(address);

    mapping(address => uint) public currentExchangeSupply;
    mapping(address => bool) public hasAddedLiquidity;
    mapping(address => address) public pairBaseToken;
    mapping(address => uint) public tokenBasePairs;
    mapping(address => mapping(address => uint)) public userTokenBalances;
    mapping(address => mapping(address => bool)) public hasWithdrawnFunds;
    

    constructor(address _managerAddress) {
        managerAddress = _managerAddress;
    }

    modifier onlyRouter() {
        require(msg.sender == filterManager.routerAddress(), "FilterStrainer: FORBIDDEN");
        _;
    }

    function registerAddLiquidity(address _pairAddress, uint _tokenAmount) public onlyRouter {
        //check both pairs arent verified (done in router check)

        if (!hasAddedLiquidity[_pairAddress]) {
            currentExchangeSupply[_pairAddress] = _tokenAmount;
            hasAddedLiquidity[_pairAddress] = true;

            tokenBasePairs[IFilterPair(_pairAddress).token0()] += 1;
            tokenBasePairs[IFilterPair(_pairAddress).token1()] += 1;

            pairBaseToken[_pairAddress] = tokenBasePairs[IFilterPair(_pairAddress).token0()] > tokenBasePairs[IFilterPair(_pairAddress).token0()] ? IFilterPair(_pairAddress).token0() : IFilterPair(_pairAddress).token1();
        }

        else {
            currentExchangeSupply[_pairAddress] += _tokenAmount;
        }
    }

    function registerRemoveLiquidity(address _pairAddress, uint _tokenAmount) public onlyRouter {
        if(_tokenAmount < currentExchangeSupply[_pairAddress]) {
            currentExchangeSupply[_pairAddress] -= _tokenAmount;
        }
    }

    function registerBuy(address _userAddress, address _pairAddress, uint _tokenAmount) public onlyRouter { //called when user buys unverified tokens with verified tokens in pair
        userTokenBalances[_userAddress][_pairAddress] += _tokenAmount;
        currentExchangeSupply[_pairAddress] -= _tokenAmount;
    }

    function registerSell(address _userAddress, address _pairAddress, uint _tokenAmount) public onlyRouter { //called when user sells unverified tokens with verified tokens in pair
        if (_tokenAmount < userTokenBalances[_userAddress][_pairAddress]) {
            userTokenBalances[_userAddress][_pairAddress] -= _tokenAmount;
        }
        
        currentExchangeSupply[_pairAddress] += _tokenAmount;
    }

    function flagAsScam(address _pairAddress) public {
        require(msg.sender == filterManager.adminAddress(), "FilterStrainer: FORBIDDEN");
        require(!filterManager.isVerifiedSafe(IFilterPair(_pairAddress).token0()) && !filterManager.isVerifiedSafe(IFilterPair(_pairAddress).token1()), "FilterStrainer: BOTH_PAIRS_SAFE");
        isFlaggedAsScam[_pairAddress] = true;
        emit flaggedAsScam(_pairAddress); //emits event so FilterSwap bot can easily detect and call processScamToken() function
    }

    function processScamToken(address _pairAddress) public {
        require(isFlaggedAsScam[_pairAddress], "FilterStrainer: NOT_FLAGGED_AS_SCAM");
        IFilterPair(_pairAddress).transferReserves();
    }

    function recoverFunds(address _pairAddress) public {
        require(!hasWithdrawnFunds[msg.sender][_pairAddress], "FilterStrainer: ALREADY_CLAIMED");

        //get reserves
        (uint reserve0, uint reserve1, ) = IFilterPair(_pairAddress).getReserves();

        //get amounts that user is entitled to
        uint token0EntitledBalance = (userTokenBalances[msg.sender][_pairAddress] * reserve0 * (1000 - filterManager.strainerRecoveryFee())) / (currentExchangeSupply[_pairAddress] * 1000);
        uint token1EntitledBalance = (userTokenBalances[msg.sender][_pairAddress] * reserve1 * (1000 - filterManager.strainerRecoveryFee())) / (currentExchangeSupply[_pairAddress] * 1000);

        uint token0RecoveryFee = (userTokenBalances[msg.sender][_pairAddress] * reserve0 * filterManager.strainerRecoveryFee()) / (currentExchangeSupply[_pairAddress] * 1000);
        uint token1RecoveryFee = (userTokenBalances[msg.sender][_pairAddress] * reserve1 * filterManager.strainerRecoveryFee()) / (currentExchangeSupply[_pairAddress] * 1000);

        //get token0 and token1 addresses
        address token0Address = IFilterPair(_pairAddress).token0();
        address token1Address = IFilterPair(_pairAddress).token1();

        //transfer token0 to msg.sender
        if (token0Address == filterManager.wethAddress()) {
            IWETH(filterManager.wethAddress()).withdraw(token0EntitledBalance);
            payable(msg.sender).transfer(token0EntitledBalance);
            //transfer fee
            payable(filterManager.feeToAddress()).transfer(token0RecoveryFee);
        }

        else {
            //try transfer token0, but continue if it cannot (if it cannot, most likely a scam token)
            try IERC20(token0Address).transfer(msg.sender, token0EntitledBalance) {} catch {}
            //transfer fee
            try IERC20(token0Address).transfer(filterManager.feeToAddress(), token0RecoveryFee) {} catch {}
        }

        //transfer token1 to msg.sender

        if (token1Address == filterManager.wethAddress()) {
            IWETH(filterManager.wethAddress()).withdraw(token1EntitledBalance);
            payable(msg.sender).transfer(token1EntitledBalance);
            //transfer fee
            payable(filterManager.feeToAddress()).transfer(token1RecoveryFee);
        }
      
        else {
            //try transfer token1, but continue if it cannot (if it cannot, most likely a scam token)
            try IERC20(token1Address).transfer(msg.sender, token1EntitledBalance) {} catch {}
            //transfer fee
            try IERC20(token1Address).transfer(filterManager.feeToAddress(), token1RecoveryFee) {} catch {}
        }

        //mark as complete so user cannot withdraw funds again
        hasWithdrawnFunds[msg.sender][_pairAddress] = true;
    }
}