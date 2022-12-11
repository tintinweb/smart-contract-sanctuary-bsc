// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./IERC20.sol";

interface PancakeSwapFactory
{
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface PancakeSwapRouter
{
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

}

contract SalePad
{
    bool public saleStarted;
    uint public softCap;
    uint public hardCap;
    uint public tokenRate;
    uint public currentProgress;
    uint public minBuy;
    uint public maxBuy;
    uint public saleLeftAmount;
    bool public softCapHit;
    bool public hardCapHit;
    bool public saleConcluded;
    bool public amountTransferred;
    bool public hasSaleBeenCancelled;
    bool public saleSuccessfullyFilled;
    bool public approveSuccessful;
    uint public softCapHCRatio;
    uint public saleTokenDecimals;
    uint public totalTBalanceIn;
    int public timeUntilstart;
    int public saleTimeLeft;
    int public saleTotalDuration;
    int public saleEndTime;
    uint public saleLiquidityPercentage;
    address payable public saleOwnerAddress;
    mapping(address=>uint) public tokenAllocation;
    mapping(address=>uint) public totalClaimed;
    mapping(address=>bool) public claimComplete;
    mapping(address=>uint) public totalBought;
    mapping(address=>bool) public boughtSale;
    address RouterAddress=0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address FactoryAddress=0x6725F303b657a9451d8BA641348b6761A6CC7a17;
    address public tokenMainAddress;
    PancakeSwapFactory factory;
    PancakeSwapRouter router;
    IERC20 token;
    //Public Sale Algorithm
    //Implement the token claim with ERC20 interface.

    constructor(address ownerAddress, uint startingRatePerBNB, uint sCap, uint hCap, uint minBuyAllowed, uint maxBuyAllowed,int startSaleIn, int saleDuration, uint liqPercentage, address tokenCAddress, uint tokenDecimals, uint256 totalTokenIn) public
    {
        //tokenRate will be equal to the rate per BNB
        //Min and Max buys values are linked to the algorithm of 1 BNB equal to 1000 Wei.
        tokenRate= startingRatePerBNB;
        softCap=sCap*10**15;
        hardCap=hCap*10**15; 
        saleLeftAmount=0 ether;
        totalTBalanceIn=totalTokenIn;
        softCapHit=false;
        hardCapHit=false;
        approveSuccessful=false;
        hasSaleBeenCancelled=false;
        saleSuccessfullyFilled=false;
        minBuy=minBuyAllowed*10**15;
        maxBuy=maxBuyAllowed*10**15;
        token=IERC20(tokenCAddress);
        tokenMainAddress=tokenCAddress;
        factory=PancakeSwapFactory(FactoryAddress);
        router=PancakeSwapRouter(RouterAddress);
        saleTokenDecimals=tokenDecimals;
        saleOwnerAddress=payable(ownerAddress);
        timeUntilstart=int(block.timestamp)+startSaleIn;
        saleTimeLeft=timeUntilstart-int(block.timestamp);
        saleTotalDuration=timeUntilstart+saleDuration;
        saleEndTime=saleTotalDuration-int(block.timestamp);
        saleLiquidityPercentage=liqPercentage;
    }

    modifier onlyOwner
    {
        require(msg.sender==saleOwnerAddress,"Caller is not authorized");
        _;
    }

    modifier onlyBuyer
    {
        require(boughtSale[msg.sender],"No buy has been made by the address");
        _;
    }

    modifier successfulApproval
    {
        require(approveSuccessful,"Tokens for Router have not been approved yet");
        _;
    }

    function web_BuySale() payable public 
    {
        saleTimeLeft=timeUntilstart-int(block.timestamp);
        //Launch the buy process, else revert the transaction based on the timestamp.
        require(!saleConcluded,"Sale has been already concluded");
        require(!hasSaleBeenCancelled,"The sale has been cancelled by the Pool owner");
        require(!saleSuccessfullyFilled,"The sale has been filled successfully already");
        require(saleTimeLeft<=0,"Sale has not started yet. Check the timer for the remaining time");
        saleStarted=true;
        require(saleStarted,"Sale has not started yet. Check the timer for the remaining time");
        saleEndTime=saleTotalDuration-int(block.timestamp);
        require(saleEndTime>0,"Sale has already ended.");
        require(currentProgress+msg.value<=hardCap,"Exceeds the HardCap amount");
        require(msg.value>=minBuy && msg.value<=maxBuy,"Minimum value needs to be matched");
        uint valueToWei=msg.value/10**15; //Converting the value to 10**15 ratio.
        uint tokenAllocated= tokenRate*(valueToWei/10**3);
        boughtSale[msg.sender]=true;
        totalBought[msg.sender]+=msg.value;
        tokenAllocation[msg.sender]+=tokenAllocated;
        currentProgress+=msg.value;
        saleLeftAmount=hardCap-currentProgress;
        if(currentProgress==hardCap)
        {
            saleSuccessfullyFilled=true;
        }
        else 
        {
            saleSuccessfullyFilled=false;
        }
        if(saleLeftAmount<minBuy)
        
        {
            minBuy=0 ether;
        }
        else 
        {
            //
        }
    }

    function concludeSale() public onlyOwner
    {
        if(currentProgress>=softCap)
        {
            softCapHit=true;
            if(currentProgress==hardCap)
            {
                hardCapHit=true;
            }
            else 
            {
                hardCapHit=false;
            }
        }
        else 
        {
            softCapHit=false;
        }
        require(!hasSaleBeenCancelled,"The sale has been already cancelled by the pool owner");
        require(softCapHit || hardCapHit,"Soft Cap has not been reached yet to conclude the sale");
        //Creating the Liquidity and then transferring the funds.
        uint percentageTransfer=100-saleLiquidityPercentage;
        uint amountInWeiToTransfer=currentProgress*percentageTransfer/100;
        saleOwnerAddress.transfer(amountInWeiToTransfer);
        uint amountLeftForLiquidity=currentProgress-amountInWeiToTransfer;
        saleConcluded=true;
        amountTransferred=true;
        //Create and add Liquidity
        approveContractTokens(totalTBalanceIn); //Approved Contract Tokens for usage.
        addLiquidityETHMethod(100000000000000000, tokenMainAddress, totalTBalanceIn*10**saleTokenDecimals, 0, 0, saleOwnerAddress, block.timestamp+1000);   
    }

    function cancelSale() public onlyOwner
    {
        hasSaleBeenCancelled=true;
    }


    function withdrawBuy(uint wAmount) public onlyBuyer
    {
        //wAmount to be input on the basis of 1000.
        uint wAmountToWei=wAmount*10**15;
        uint buyAmountThousand=totalBought[msg.sender]/10**15;
        require(!saleConcluded,"Sale has already been concluded");
        require(wAmount<=buyAmountThousand,"Withdraw amount exceeds the buy amount, recheck");
        uint tokenValuation=tokenRate*(wAmount/10**3);
        totalBought[msg.sender]-=wAmountToWei;
        currentProgress-=wAmountToWei;
        tokenAllocation[msg.sender]-=tokenValuation;
        payable(msg.sender).transfer(wAmountToWei);
    }

    function ownerSweepFunds() public onlyOwner
    {
        saleOwnerAddress.transfer(address(this).balance);
    }

    function getTimeUntilStart() public returns(int)
    {
        saleTimeLeft=timeUntilstart-int(block.timestamp);
        return saleTimeLeft;
    }

    function getTimeUntilConclusion() public returns(int)
    {
        saleEndTime=saleTotalDuration-int(block.timestamp);
        return saleEndTime;
    }

    function getCurentProgress() public view returns(uint)
    {
        return currentProgress/10**18;
    }

    function checkSaleSuccess() public view returns(bool)
    {
        return saleSuccessfullyFilled;
    }

    function claimTokens() public onlyBuyer
    {
        uint tokensToTransfer=tokenAllocation[msg.sender];
        totalClaimed[msg.sender]+=tokensToTransfer;
        tokenAllocation[msg.sender]-=tokensToTransfer;
        claimComplete[msg.sender]=true;
        token.transfer(msg.sender,tokensToTransfer*10**saleTokenDecimals);

    }

    function approveContractTokens(uint approveAmount) internal 
    {
        token.approve(RouterAddress, approveAmount*10**saleTokenDecimals);
        token.approve(FactoryAddress, approveAmount*10**saleTokenDecimals);
        approveSuccessful=true;
    }

    function addLiquidityETHMethod(uint msgValue, address tokenAddress, uint tAmountForLiquidity, uint tMin, uint ETHMin, address receiver, uint timestampdeadline) internal successfulApproval
    {
        router.addLiquidityETH {value:msgValue}(
            tokenAddress,
            tAmountForLiquidity,
            tMin, 
            ETHMin,
            receiver, 
            timestampdeadline
            );
    }

}

//Factory Code WEB3

contract SaleFactory
{
    SalePad[] public saleAddresses;
    address public factoryAddress;
    bool public tokenApproved;
    mapping(address=>address) public ownerRespectiveSale;
    address[] public existingERC;
    mapping(address=> uint) public salePerAddress;
    IERC20 token;
    
    constructor() public 
    {
        factoryAddress=address(this);
    }

    function createSale(uint startingRatePerBNB, uint sCap, uint hCap, uint minBuyAllowed, uint maxBuyAllowed,int startSaleIn, int saleDuration, uint liqPercentage, address tokenCAddress, uint tokenDecimals, uint256 totalTokenIn) public 
    {
       // Dual Token Check Code activation.
       /* bool ERCExist=false;
        for(uint i=0; i<existingERC.length;i++)
        {
            if(existingERC[i]==tokenCAddress)
            {
                ERCExist=true;
                revert("Sale with this particular token has already been created");
            }
        }
        require(!ERCExist,"Sale with this particular token has already been created");
        */
        require(salePerAddress[msg.sender]<1,"The address has already created a sale. Change address or Reset");
        token=IERC20(tokenCAddress);
        SalePad creation=new SalePad(msg.sender, startingRatePerBNB, sCap, hCap, minBuyAllowed, maxBuyAllowed, startSaleIn, saleDuration, liqPercentage, tokenCAddress, tokenDecimals, totalTokenIn);
        saleAddresses.push(creation);
        token.transferFrom(msg.sender,address(creation),totalTokenIn*10**tokenDecimals);
        ownerRespectiveSale[msg.sender]=address(creation);
        salePerAddress[msg.sender]+=1;
        existingERC.push(tokenCAddress);
    }

    //Decimals need to be put explicitly for any ERC20 based Transaction be it approve or TransferFrom.

    function getSaleAddress() public view returns(address)
    {
        return ownerRespectiveSale[msg.sender];
    }

}