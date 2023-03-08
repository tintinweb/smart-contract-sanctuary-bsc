//SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import "linkAggregatorV3Interface.sol";

interface Presale{
    function transferPresale(address recipient, uint256 amount) external  returns (bool);
}

contract MGUPreSale {
   constructor(){
       owner=payable(msg.sender);
       remainingtoken=234_000_000 * 10 ** 18;
    }

    /**
    *@dev sets The MGU Token Contract Address.
    */
    address private tokenAddress;
    address payable private owner;

    /**
    *@dev sets MIN and MAX BNB Amount for Purchasing MGU at Preslae.
    */
    uint256 private minValue=1*10**17;
    uint256 private maxValue=10*10**18;

    /**
    *@dev sets the MGU Token Price equivalent in wei format. 
    */
    uint256 private tkPriceInWei=1*10**16;

    /**
    *@dev sets the start and ending time for presale. 
    */
    uint256 private _startAt;
    uint256 private _endAt;

    /**
    *@dev calculates the remaining Token for presale and airdrop. 
    */
    uint256 public remainingtoken;

    /**
    *@dev chainlink's contract base Realtime BNBUSD PriceFeed.
    */
    address BNBUSD=0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;//bnbusd testnet
    // address BNBUSD=0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;  mainnet

    
    // modifiers:
    modifier onlyOwner{
        require(msg.sender==owner,"Not Allowed!");
        _;
    }
    modifier inpreslaetime{
        require(block.timestamp>=_startAt,"PreSale Not Started Yet!");
        require(block.timestamp<=_endAt,"PreSale Ended!");
        _;
    }
    // setters:
    /**
    *@dev Sets Presale Start date and also End date. callable by onlyOwner.
    *@param _startTime presale start time.
    */
    function setPresaleStartEnd(uint256 _startTime)external onlyOwner{
        _startAt=_startTime;
        _endAt=_startTime+30 days;
    }

    /**
    *@dev Sets Presale Token Contract Address. callable by onlyOwner.
    *@param Contract MGU Token Contract Address.
    */
    function setTokenContract(address Contract) external onlyOwner returns(bool){
        require(Contract!=address(0),"Zero Address!");
        tokenAddress=Contract;
        return true;
    }

    /**
    *@dev Calls transferPresale function from MGU Contract. callable by onlyOwner inside presale time.
    *@param recipient purchaser address.
    *@param amount amount MGU Token for purchase.
    */
    function preSaleGiveAway(address recipient,uint256 amount)private onlyOwner inpreslaetime returns(bool){
        return Presale(tokenAddress).transferPresale(recipient,amount);
    } 
    
    /**
    *@dev returns equivallent amount of MGU for BNB value.
    *@param value msg.sender's BNB value.
    */
    function getamount(uint256 value)public view returns(uint256){
        uint256 price=getPrice()*value/10**8;
        return price/(tkPriceInWei);
    }

    /**
    *@dev trigger when purchaser wants to buy MGU.
    *     1-calls getamount function to calculate MGU amount
    *     2-calls preSaleGiveAway function to mint amount token
    *     3-subtract amount from remainingtoken 
    */
    function preSaleFund()external inpreslaetime payable {
        require(msg.value>=minValue,"Minimun Amount Exception!");
        require(msg.value<=maxValue,"Maximun Amount Exception!");
        preSaleGiveAway(msg.sender,getamount(msg.value));
        remainingtoken-=getamount(msg.value)*10**18;
    }

    // getters:

    /**
    *@dev returns presale start and end time.
    */
    function getPresaleTime()external view returns(uint256,uint256){
        return (_startAt,_endAt);
    }

    /**
    *@dev returns BNB Realtime Price in wei format
    */
    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(BNBUSD);
        (,int256 price,,,) = priceFeed.latestRoundData(); 
        return uint256(price);
    }

    /**
    *@dev returns owner.
    */
    function getowner() external view returns(address){
        return owner;
    }

    /**
    *@dev returns MGU Token contract address.
    */
    function getTokenContract() external view returns(address){
        return tokenAddress;
    }
    /**
    *@dev returns balance of BNB . callable by onlyOwner.
    */
    function getbalance()external view onlyOwner returns(uint256){
        return address(this).balance;
    }

    /**
    *@dev withdrow Funds to Owner. callable by onlyOwner.
    */
    function withdrow() public payable onlyOwner{
        payable(owner).transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}