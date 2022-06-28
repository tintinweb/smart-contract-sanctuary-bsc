/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// File: contracts/ManagedAccount.sol



/*
This file is part of the DAO.

The DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the DAO.  If not, see <http://www.gnu.org/licenses/>.
*/


/*
Basic account, used by the DAO contract to separately manage both the rewards 
and the extraBalance accounts. 
*/
pragma solidity 0.8.0;

abstract contract ManagedAccountInterface {
    // The only address with permission to withdraw from this account
    address public owner;
    // If true, only the owner of the account can receive ether from it
    bool public payOwnerOnly;
    // The sum of ether (in wei) which has been sent to this contract
    uint public accumulatedInput;

    /// @notice Sends `_amount` of wei to _recipient
    /// @param _amount The amount of wei to send to `_recipient`
    /// @param _recipient The address to receive `_amount` of wei
    /// @return True if the send completed
    // function payOut(address _recipient, uint _amount) virtual external returns (bool);

    event PayOut(address indexed _recipient, uint _amount);
}


contract ManagedAccount is ManagedAccountInterface{

    // The constructor sets the owner of the account
    constructor(address _owner, bool _payOwnerOnly) {
        owner = _owner;
        payOwnerOnly = _payOwnerOnly;
    }

    // When the contract receives a transaction without data this is called. 
    // It counts the amount of ether it receives and stores it in 
    // accumulatedInput.
    receive() external payable {
        accumulatedInput += msg.value;
    }

    fallback() external payable {
        accumulatedInput += msg.value;
    }

    function payOut(address _recipient, uint _amount) external payable returns(bool){
        if (msg.sender != owner || msg.value > 0 || (payOwnerOnly && _recipient != owner))
            revert("Not Authorised, No BNB required to call, Recipient address cant be Owner address, Owner can call only call this");
        (bool success, ) = address(_recipient).call{value: _amount}("");
        require(success, "Call Failed at Payout");
        if(success) {
            emit PayOut(_recipient, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    function getAccumulatedInput() public view returns(uint) {
        return accumulatedInput;
    }
}

// File: contracts/Token.sol



/*
This file is part of the DAO.

The DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the DAO.  If not, see <http://www.gnu.org/licenses/>.
*/


/*
Basic, standardized Token contract with no "premine". Defines the functions to
check token balances, send tokens, send tokens on behalf of a 3rd party and the
corresponding approval process. Tokens need to be created by a derived
contract (e.g. TokenCreation.sol).

Thank you ConsenSys, this contract originated from:
https://github.com/ConsenSys/Tokens/blob/master/Token_Contracts/contracts/Standard_Token.sol
Which is itself based on the Ethereum standardized contract APIs:
https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs
*/

// @title Standard Token Contract.

pragma solidity 0.8.0;

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
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

//this contract calls the imported AggregatorV3Interface contract 
//we map imported contract code to a particular contract address to get the live BNB price.
contract DAITOBNB {

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Binance Smart Chain
     * Aggregator: BNB/USD
     * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     */
    constructor()  {
        //priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); // BNB / USD
        priceFeed = AggregatorV3Interface(0x0630521aC362bc7A19a4eE44b57cE72Ea34AD01c); // DAI / BNB
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int, uint80, uint, uint, uint80) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return (price,roundID, startedAt, timeStamp, answeredInRound);
    }

    //shows decimals
    function decimals() external view returns (uint8) {
        return priceFeed.decimals();
    }
 
}

abstract contract TokenInterface {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) public _allowances;

    // Total amount of tokens
    uint256  _totalSupply;

    uint256  _tTotal = 1 * 10**9 * 10**18;
    // @param _owner The address from which the balance will be retrieved
    // @return The balance
    function balanceOf(address _owner) virtual external returns (uint256 balance);

    // @notice Send `_amount` tokens to `_to` from `msg.sender`
    // @param _to The address of the recipient
    // @param _amount The amount of tokens to be transferred
    // @return Whether the transfer was successful  or not
    // function transfer(address _to, uint256 _amount) virtual public returns (bool success);

    // @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    // is approved by `_from`
    // @param _from The address of the origin of the transfer
    // @param _to The address of the recipient
    // @param _amount The amount of tokens to be transferred
    // @return Whether the transfer was successful or not
    // function transferFrom(address _from, address _to, uint256 _amount)  virtual external returns (bool success);

    // @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    // its behalf
    // @param _spender The address of the account able to transfer the tokens
    // @param _amount The amount of tokens to be approved for transfer
    // @return Whether the approval was successful or not
    function approve(address _spender, uint256 _amount)  virtual external returns (bool success);

    // @param _owner The address of the account owning tokens
    // @param _spender The address of the account able to transfer the tokens
    // @return Amount of remaining tokens of _owner that _spender is allowed
    // to spend
    function allowance(
        address _owner,
        address _spender
    )  virtual external returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );
}


abstract contract Token is TokenInterface {

    // event Purchase(address buyerAddress, uint tokens, uint tokenHolders, uint marketCommission, uint tournamentCommission);
    // event Sell(address sellerAddress, uint amount, uint marketCommission, uint tournamentCommission, uint charityCommission, uint pooledCommission);

    // event ChangedbuyCommissionPercent(uint totalbuyCommission, uint forTokenHolder, uint forMarketing, uint forTournament);
    // event ChangedsellCommissionPercent(uint totalsellCommission, uint forMarketing, uint forTournament, uint forCharity, uint forPool);

    // struct Purchases {
    //     uint amountPaid;
    //     uint tokens;
    // }
    // mapping (address => Purchases) private purchaseDetails;
    
   
     address public curators;
    

  
    constructor( address _curator) {
        // _name = name_;
        // _symbol = symbol_;
        curators = _curator;
    
    }

   

    //Buy
    //Helps to buy Dai tokens
    //Get an estimate of price Dai tokens from getEstimatedPurchaseOfDaiTokens()
    //Required to give relavant BNB price + commission price
    //user only needs to pay gas fees
    // function buy(uint token) public payable  {
    //     require(balances[curators] > 0 || token < balances[curators], "Low Tokens");

    //     //require(_tokenHolderAddress != address(0) , "Ask Admin to set tokenHolders address");
    //     require(_marketingAddress != address(0), "Ask Admin to set marketing address");
    //     require(_tournamentAddress != address(0), "Ask Admin to set tournament address");

    //     //Commission
    //     require(marketingPercentAtBuy != 0 || tournamentPercentAtSell != 0 || tokenHoldersPercentAtBuy != 0 , "Taxation percent can't be zero");


    //     uint priceOfBNB = getLiveBNBPrice();

    //     (,uint price, , uint total) = getEstimatedPurchaseOfDaiTokens(token);
    //     require(msg.value == total, "sent BNB value is not correct, check again estimation price from getEstimatedPriceOfDaiTokens()");
        
    //     //Commission 
    //     //Commission for tokenHolders.
    //     //uint thresholdTokenHolders;
    //     uint tokenHoldersCommission = ((price * tokenHoldersPercentAtBuy) / 100);
    //     if(tokenHoldersCommission < priceOfBNB) {
    //         thresholdTokenHolders += tokenHoldersCommission;
    //         thresholdsHolding();
    //     }
    //     if(tokenHoldersCommission == priceOfBNB) {
    //         initialTransfer(curators, _tokenHolderAddress, 1);
    //         thresholdTokenHolders = 0;
    //     }
    //     if(tokenHoldersCommission > priceOfBNB) {
    //         uint tokens = tokenHoldersCommission/priceOfBNB;
    //         uint extraCommission = tokenHoldersCommission - (tokens * priceOfBNB);
    //         thresholdTokenHolders += (extraCommission);
    //         //Transfer
    //         _tokenTransfer(curators, _tokenHolderAddress, tokens);
    //         thresholdsHolding();
    //     }

    //     (bool sentTomarketCommission, ) = payable(_marketingAddress).call{value: ((price * marketingPercentAtBuy) / 100)}("");
    //     require(sentTomarketCommission, "Failed to send BNB for marketCommission");

    //     (bool sentToTournamentPackCommission,) = payable(_tournamentAddress).call{value: ((price * tournamentPercentAtSell) / 100)}("");
    //     require(sentToTournamentPackCommission, "Failed to send BNb for TournamentPackTax");

    //     //Buy
    //     initialTransfer(curators, msg.sender, token);
    //     emit Purchase(msg.sender, token, ((price * tokenHoldersPercentAtBuy) / 100), ((price * marketingPercentAtBuy) / 100), ((price * tournamentPercentAtSell) / 100));

    //     Purchases storage p =  purchaseDetails[msg.sender];
    //     p.amountPaid = total;
    //     p.tokens += token;
    // }

    //helper function for buy() 
    // function thresholdsHolding() internal {
    //     uint priceOfBNB = getLiveBNBPrice();
    //     if(thresholdTokenHolders == priceOfBNB || thresholdTokenHolders > priceOfBNB) {
    //         uint thresholdTokenHoldersTokens = (thresholdTokenHolders /priceOfBNB);
    //         //Transfer
    //         initialTransfer(curators, _tokenHolderAddress, thresholdTokenHoldersTokens);
    //         thresholdTokenHolders = thresholdTokenHolders - (thresholdTokenHoldersTokens * priceOfBNB);
    //     }
    // }
  
    // Get an estimate price of Dai Tokens, Commission, TotalPrice need to pay
    // function getEstimatedPurchaseOfDaiTokens(uint tokens) public view returns(uint CommissionPercent, uint TokensPrice, uint Commission, uint Total) {
    //     uint price = tokens * getLiveBNBPrice();
    //     uint commission = (price * tokenHoldersPercentAtBuy) / 100 + (price * marketingPercentAtBuy) / 100 +  (price * tournamentPercentAtBuy) / 100;
    //     return (buyCommission, price, commission, price + commission);
    // }


    //Get an estimate BNB price for selling Dai tokens, Commission 
    // function getEstimatedSellPriceOfDaiToken() public view returns(uint CommissionPercent, uint totalDaiTokens, uint totalBNBPrice, uint totalTokensCommission) {
    //     uint totalTokens = purchaseDetails[msg.sender].tokens;
    //     require(totalTokens > 0, "No tokens");

    //     uint totalPrice = totalTokens * getLiveBNBPrice();
    //     uint totalCommission = (totalPrice * tokenHoldersPercentAtSell)/ (100) + (totalPrice * tournamentPercentAtSell)/ (100) + (totalPrice * charityPercentAtSell)/ (100) + (totalPrice * marketingPercentAtSell)/ (100);

    //     return (sellCommission ,totalTokens, totalPrice, totalCommission);
    // }
        
    // //helper function for sell
    // function thresholdsHolding() internal  {
    //     uint priceOfBNB = getLiveBNBPrice();
    //     if(thresholdPool == priceOfBNB || thresholdPool > priceOfBNB) {
    //         uint thresholdPoolTokens = (thresholdPool / priceOfBNB);
    //         //Transfer
    //         initialTransfer(curators, _poolAddress, thresholdPoolTokens);
    //         thresholdPool = thresholdPool - (thresholdPoolTokens * priceOfBNB);
    //     }
    // }

    //Sell
    //applies 8% commission
    //helps in selling the dai tokens 
    //user needs to pay gas fees
    //should be called with relavant commission price 
    // function sell() public payable  {
    //     require(purchaseDetails[msg.sender].tokens > 0, "Not Enough Tokens");

    //     //require(_tokenHolderAddress != address(0) , "Ask Admin to set tokenHolders address");
    //     require(_marketingAddress != address(0), "Ask Admin to set marketing address");
    //     //require( _poolAddress != address(0), "Ask Admin to set pool address");
    //     require(_charityAddress != address(0), "Ask Admin to set charity address");
    //     require(_tournamentAddress != address(0), "Ask Admin to set tournament address");

    //     //for commission
    //     require(tournamentPercentAtSell != 0 || charityPercentAtSell != 0 || marketingPercentAtSell != 0, "Taxation percent cant be zero");

    //     uint priceOfBNB = getLiveBNBPrice();
    //     (,uint totalTokens, uint totalBNBPrice, uint totalTokensCommission) = getEstimatedSellPriceOfDaiToken();
    //     require(msg.value == totalTokensCommission, "Sent value is incorrect");
        
    //     //Commission
    //     (bool sentToMarketing, ) = payable(_marketingAddress).call{value: ((totalBNBPrice * marketingPercentAtSell ) / 100)}("");
    //     require(sentToMarketing, "Failed to send BNB for Marketing");

    //     (bool sentToTournament,) = payable(_tournamentAddress).call{value: ((totalBNBPrice * tournamentPercentAtSell) / 100)}("");
    //     require(sentToTournament, "Failed to send BNB for Tournament");

    //     (bool sentToCharity, ) = payable(_charityAddress).call{value: ((totalBNBPrice * charityPercentAtSell) / 100)}("");
    //     require(sentToCharity, "Failed to send BNB for Charity");

    //     //transfer
    //     initialTransfer(msg.sender, curators, totalTokens);
    
    //     /*
    //         Pool Commission
    //         Commission is taken in form of DAI Token.
    //         transfers the tokens only after reaching the each dai token equivalent price, till then store in thresholdPool;
    //     */
    //     //uint thresholdPool;
    //     uint tokenHoldersCommission = (totalBNBPrice * tokenHoldersPercentAtSell) / (100);

    //     if(tokenHoldersCommission < priceOfBNB) {
    //         thresholdPool += tokenHoldersCommission; 
    //         thresholdsHolding();
    //     }
    //     if(tokenHoldersCommission == priceOfBNB) {
    //         //Transfer
    //         initialTransfer(curators, _poolAddress, 1);
    //         thresholdPool -= tokenHoldersCommission;
    //     }
    //     if(tokenHoldersCommission > priceOfBNB) {
    //         uint tokensForPool = tokenHoldersCommission/priceOfBNB;
    //         uint extrapoolCommission = tokenHoldersCommission - (tokensForPool * priceOfBNB);
    //         thresholdPool += (extrapoolCommission);
    //         //Transfer
    //         initialTransfer(curators, _poolAddress, tokensForPool);
    //         thresholdsHolding();
    //     }
    //     delete purchaseDetails[msg.sender];
    //     (bool transferToSellerAddress, ) = payable(msg.sender).call{value: (totalBNBPrice)}("");
    //     require(transferToSellerAddress, "Failed to send BNB to Seller Address");
    //     emit Sell(msg.sender, (purchaseDetails[msg.sender].tokens), ((totalBNBPrice * marketingPercentAtSell) / 100), ((totalBNBPrice * tournamentPercentAtSell) / 100), ((totalBNBPrice * charityPercentAtSell)  / 100), tokenHoldersCommission);       
    // }

    //Real time BNB price.
    // function getLiveBNBPrice() public view returns(uint) {
    //     DAITOBNB p =  DAITOBNB(0xBF79b4229FBde2311dA8A2e19CC2616DD9b8B36b);
    //     (int price, , , , ) = p.getLatestPrice();
    //     return uint(price);
    // }
    
    // function assignCommissionAddress(address marketing, address tournament, address charity) public  {
    //     require(msg.sender == curators, "Only a curator can assign Commission Address");
    //    // _tokenHolderAddress = tokenHolders;
    //     // _poolAddress = pool;
    //     _marketingAddress = marketing;
    //     _tournamentAddress = tournament;
    //     _charityAddress = charity;
    // }

    // function assignPercentShareForBuy(uint tokenHolders, uint marketing, uint tournament) public{
    //     require(msg.sender == curators, "Only a curator can assign Commission Percent");
    //     tokenHoldersPercentAtBuy = tokenHolders;
    //     marketingPercentAtBuy = marketing;
    //     tournamentPercentAtBuy = tournament;
    //     buyCommission =  marketing + tournament;
    //     emit ChangedbuyCommissionPercent(buyCommission, tokenHoldersPercentAtBuy, marketingPercentAtBuy, tournamentPercentAtBuy);
  
    // }

    // function assignPercentShareForSell(uint tokenHolders, uint marketing, uint tournament, uint charity) public{
    //     require(msg.sender == curators, "Only a curator can assign Commission Percent");
    //     tokenHoldersPercentAtSell = tokenHolders;
    //     marketingPercentAtSell = marketing;
    //     tournamentPercentAtSell = tournament;
    //     charityPercentAtSell = charity;
    //     sellCommission = marketing + tournament + charity;
    //     emit ChangedsellCommissionPercent(sellCommission, marketingPercentAtSell, tournamentPercentAtSell, charityPercentAtSell, tokenHoldersPercentAtSell);
    // }



}

// File: contracts/TokenCreation.sol



/*
This file is part of the DAO.

The DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the DAO.  If not, see <http://www.gnu.org/licenses/>.
*/


/*
 * Token Creation contract, used by the DAO to create its tokens and initialize
 * its ether. Feel free to modify the divisor method to implement different
 * Token Creation parameters
*/
pragma solidity 0.8.0;



abstract contract TokenCreationInterface {

    // End of token creation, in Unix time
    uint public closingTime;
    // Minimum fueling goal of the token creation, denominated in tokens to
    // be created
    uint public minTokensToCreate;
    // True if the DAO reached its minimum fueling goal, false otherwise
    bool public isFueled;
    // For DAO splits - if privateCreation is 0, then it is a public token
    // creation, otherwise only the address stored in privateCreation is
    // allowed to create tokens
    address public privateCreation;
    // tracks the amount of wei given from each contributor (used for refund)
    mapping (address => uint256) weiGiven;

    // @dev Constructor setting the minimum fueling goal and the
    // end of the Token Creation
    // @param _minTokensToCreate Minimum fueling goal in number of
    //        Tokens to be created
    // @param _closingTime Date (in Unix time) of the end of the Token Creation
    // @param _privateCreation Zero means that the creation is public.  A
    // non-zero address represents the only address that can create Tokens
    // (the address can also create Tokens on behalf of other accounts)
    // This is the constructor: it can not be overloaded so it is commented out
    //  function TokenCreation(
        //  uint _minTokensTocreate,
        //  uint _closingTime,
        //  address _privateCreation
    //  );

    // @notice Create Token with `_tokenHolder` as the initial owner of the Token
    // @param _tokenHolder The address of the Tokens's recipient
    // @return Whether the token creation was successful
     function createTokenProxy(address  _tokenHolder) virtual public payable returns (bool success);
    

    // @notice Refund `msg.sender` in the case the Token Creation did
    // not reach its minimum fueling goal
    function refund() virtual  external;

    // @return The divisor used to calculate the token creation rate during
    // the creation phase
    function divisor() virtual internal returns (uint _divisor);

    event FuelingToDate(uint value);
    event CreatedToken(address indexed to, uint amount);
    event Refund(address indexed to, uint value);
}


abstract contract TokenCreation is TokenCreationInterface, Token {

    // hold extra ether which has been sent after the DAO token
    // creation rate has increased
    ManagedAccount public extraBalance;
    constructor(
        uint _minTokensToCreate,
        uint _closingTime,
        address _privateCreation) {
        closingTime = _closingTime;
        minTokensToCreate = _minTokensToCreate;
        privateCreation = _privateCreation;
        extraBalance = new ManagedAccount(address(this), true);
        
    }

     function initialTransfer(address from, address _to, uint256 _amount) internal returns (bool success) {
        if (balances[from] >= _amount && _amount > 0) {
            balances[from] -= _amount;
            balances[_to] += _amount;
            emit Transfer(from, _to, _amount);
            return true;
        } else {
           return false;
        }
    }


    function createTokenProxy(address  _tokenHolder) override public payable returns (bool success) {
        uint token;
        if (block.timestamp < closingTime && msg.value > 0
            && (privateCreation == address(0) || privateCreation == msg.sender)) {

            token = (msg.value * 20) / divisor();
            (bool succes,) = address(extraBalance).call{value: msg.value - token}("");
            require(succes, "failed to send at createTokenProxy");
            balances[curators] += token;
            require(initialTransfer(curators, _tokenHolder, token), "Failed at InitialTransfer");
            balances[_tokenHolder] += token;
            balances[curators] -= token;
            _tTotal += token;
            weiGiven[_tokenHolder] += msg.value;
            emit CreatedToken(_tokenHolder, token);
            if (_tTotal >= minTokensToCreate && !isFueled) {
                isFueled = true;
                emit FuelingToDate(_tTotal);
            }
            return true;
            
        }
        
        revert();
       
    }

    function refund()  override external  {
        if (block.timestamp > closingTime && !isFueled) {
            // Get extraBalance - will only succeed when called for the first time
            if (address(extraBalance).balance >= extraBalance.getAccumulatedInput()) {
                extraBalance.payOut(address(this), extraBalance.getAccumulatedInput());
            }

            // Execute refund

            // if (msg.sender.call{ value: (weiGiven[msg.sender]) }("")) {
            (bool success,) = msg.sender.call{ value: (weiGiven[msg.sender]) }("");
            if(success) {
                emit Refund(msg.sender, weiGiven[msg.sender]);
                _totalSupply -= balances[msg.sender];
                balances[msg.sender] = 0;
                weiGiven[msg.sender] = 0;
            }
        }
    }

    function divisor() override internal view  returns (uint _divisor) {
        // The number of (base unit) tokens per wei is calculated
        // as `msg.value` * 20 / `divisor`
        // The fueling period starts with a 1:1 ratio
        if (closingTime - 2 weeks > block.timestamp) {
            return 20;
        // Followed by 10 days with a daily creation rate increase of 5%
        } else if (closingTime - 4 days > block.timestamp) {
            return (20 + (block.timestamp - (closingTime - 2 weeks)) / (1 days));
        // The last 4 days there is a virtual creation rate ratio of 1:1.5
        } else {
            return 30;
        }
    }

    function getClosingTime() public view returns(uint) {
        return closingTime;
    }


  
}

// File: contracts/DAO.sol


/*
This file is part of the DAO.

The DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the DAO.  If not, see <http://www.gnu.org/licenses/>.
*/


/*
Standard smart contract for a Decentralized Autonomous Organization (DAO)
to automate organizational governance and decision-making.
*/
pragma solidity 0.8.0;




interface IpancakeV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IpancakeV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_Swapping() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint Swapping);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IpancakeV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

  
    
   
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



// pragma solidity >=0.6.2;

interface IpancakeV2Router02 is IpancakeV2Router01 {
    function removeSwappingETHSupportingFeeOnTransferTokens(
        address token,
        uint Swapping,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeSwappingETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint Swapping,
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



abstract contract DAOInterface {

    // The amount of days for which people who try to participate in the
    // creation by calling the fallback function will still get their ether back
    uint constant creationGracePeriod = 40 days;
    // The minimum debate period that a generic proposal can have
    uint constant minProposalDebatePeriod = 2 weeks;
    // The minimum debate period that a split proposal can have
    uint constant minSplitDebatePeriod = 1 weeks;
    // Period of days inside which it's possible to execute a DAO split
    uint constant splitExecutionPeriod = 27 days;
    // Period of time after which the minimum Quorum is halved
    uint constant quorumHalvingPeriod = 25 weeks;
    // Period after which a proposal is closed
    // (used in the case `executeProposal` fails because it revert()s)
    uint constant executeProposalPeriod = 10 days;
    // Denotes the maximum proposal deposit that can be given. It is given as
    // a fraction of total Ether spent plus balance of the DAO
    uint constant maxDepositDivisor = 100;

    // Proposals to spend the DAO's ether or to choose a new Curator
    // Proposal[] public proposals;
    uint public proposalsTotal;
    // The quorum needed for each proposal is partially calculated by
    // _totalSupply / minQuorumDivisor
    uint  minQuorumDivisor;
    // The unix time of the last time quorum was reached on a proposal
    uint  lastTimeMinQuorumMet;

    // Address of the curator
    address public curator;
    // The whitelist: List of addresses the DAO is allowed to send ether to
    mapping (address => bool) public allowedRecipients;

    // Tracks the addresses that own Reward Tokens. Those addresses can only be
    // DAOs that have split from the original DAO. Conceptually, Reward Tokens
    // represent the proportion of the rewards that the DAO has the right to
    // receive. These Reward Tokens are generated when the DAO spends ether.
    mapping (address => uint) public rewardToken;
    // Total supply of rewardToken
    uint public totalRewardToken;

    // The account used to manage the rewards which are to be distributed to the
    // DAO Token Holders of this DAO
    ManagedAccount public rewardAccount;

    // The account used to manage the rewards which are to be distributed to
    // any DAO that holds Reward Tokens
    ManagedAccount public DAOrewardAccount;

    // Amount of rewards (in wei) already paid out to a certain DAO
    mapping (address => uint) public DAOpaidOut;

    // Amount of rewards (in wei) already paid out to a certain address
    mapping (address => uint) public paidOut;
    // Map of addresses blocked during a vote (not allowed to transfer DAO
    // tokens). The address points to the proposal ID.
    mapping (address => uint) public blocked;

    // The minimum deposit (in wei) required to submit any proposal that is not
    // requesting a new Curator (no deposit is required for splits)
    uint public proposalDeposit;

    // the accumulated sum of all current proposal deposits
    uint sumOfProposalDeposits;

    // Contract that is able to create a new DAO (with the same code as
    // this one), used for splits
    DAO_Creator public daoCreator;

    // A proposal with `newCurator == false` represents a transaction
    // to be issued by this DAO
    // A proposal with `newCurator == true` represents a DAO split
    mapping(uint => Proposal) public proposals;
    struct Proposal {
        // The address where the `amount` will go to if the proposal is accepted
        // or if `newCurator` is true, the proposed Curator of
        // the new DAO).
        address recipient;
        // The amount to transfer to `recipient` if the proposal is accepted.
        uint amount;
        // A plain text description of the proposal
        string description;
        // A unix timestamp, denoting the end of the voting period
        uint votingDeadline;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool open;
        // True if quorum has been reached, the votes have been counted, and
        // the majority said yes
        bool proposalPassed;
        // A hash to check validity of a proposal
        bytes32 proposalHash;
        // Deposit in wei the creator added when submitting their proposal. It
        // is taken from the msg.value of a newProposal call.
        uint proposalDeposit;
        // True if this proposal is to assign a new Curator
        bool newCurator;
        // Data needed for splitting the DAO
        SplitData[] splitData;
        // Number of Tokens in favor of the proposal
        uint yea;
        // Number of Tokens opposed to the proposal
        uint nay;
        // Simple mapping to check if a shareholder has voted for it
        mapping (address => bool) votedYes;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => bool) votedNo;
        // Address of the shareholder who created the proposal
        address creator;
    }

    // Used only in the case of a newCurator proposal.
    struct SplitData {
        // The balance of the current DAO minus the deposit at the time of split
        uint splitBalance;
        // The total amount of DAO Tokens in existence at the time of split.
        uint _totalSupply;
        // Amount of Reward Tokens owned by the DAO at the time of split.
        uint rewardToken;
        // The new DAO contract created at the time of split.
        DAO newDAO;
    }

    // Used to restrict access to certain functions to only DAO Token Holders
    modifier onlyTokenholders virtual {_;}

    // @dev Constructor setting the Curator and the address
    // for the contract able to create another DAO as well as the parameters
    // for the DAO Token Creation
    // @param _curator The Curator
    // @param _daoCreator The contract able to (re)create this DAO
    // @param _proposalDeposit The deposit to be paid for a regular proposal
    // @param _minTokensToCreate Minimum required wei-equivalent tokens
    //        to be created for a successful DAO Token Creation
    // @param _closingTime Date (in Unix time) of the end of the DAO Token Creation
    // @param _privateCreation If zero the DAO Token Creation is open to public, a
    // non-zero address means that the DAO Token Creation is only for the address
    // This is the constructor: it can not be overloaded so it is commented out
    //  function DAO(
        //  address _curator,
        //  DAO_Creator _daoCreator,
        //  uint _proposalDeposit,
        //  uint _minTokensToCreate,
        //  uint _closingTime,
        //  address _privateCreation
    //  );

    // @notice Create Token with `msg.sender` as the beneficiary
    // @return Whether the token creation was successful
    // function () external returns (bool success);


    // @dev This function is used to send ether back
    // to the DAO, it can also be used to receive payments that should not be
    // counted as rewards (donations, grants, etc.)
    // @return Whether the DAO received the ether successfully
    function receiveEther() virtual external payable returns(bool);

    // @notice `msg.sender` creates a proposal to send `_amount` Wei to
    // `_recipient` with the transaction data `_transactionData`. If
    // `_newCurator` is true, then this is a proposal that splits the
    // DAO and sets `_recipient` as the new DAO's Curator.
    // @param _recipient Address of the recipient of the proposed transaction
    // @param _amount Amount of wei to be sent with the proposed transaction
    // @param _description String describing the proposal
    // @param _transactionData Data of the proposed transaction
    // @param _debatingPeriod Time used for debating a proposal, at least 2
    // weeks for a regular proposal, 10 days for new Curator proposal
    // @param _newCurator Bool defining whether this proposal is about
    // a new Curator or not
    // @return The proposal ID. Needed for voting on the proposal
    function newProposal(
        address _recipient,
        uint _amount,
        string memory _description,
        bytes memory _transactionData,
        uint _debatingPeriod,
        bool _newCurator
    )  virtual external payable returns (uint); //use modifier tokenHolders

    // @notice Check that the proposal with the ID `_proposalID` matches the
    // transaction which sends `_amount` with data `_transactionData`
    // to `_recipient`
    // @param _proposalID The proposal ID
    // @param _recipient The recipient of the proposed transaction
    // @param _amount The amount of wei to be sent in the proposed transaction
    // @param _transactionData The data of the proposed transaction
    // @return Whether the proposal ID matches the transaction data or not
    function checkProposalCode(
        uint _proposalID,
        address _recipient,
        uint _amount,
        bytes memory _transactionData
    ) virtual external  returns (bool _codeChecksOut);

    // @notice Vote on proposal `_proposalID` with `_supportsProposal`
    // @param _proposalID The proposal ID
    // @param _supportsProposal Yes/No - support of the proposal
    // @return The vote ID.
    function vote(
        uint _proposalID,
        bool _supportsProposal
    )virtual external  ;//use tokenHolders modifier

    // @notice Checks whether proposal `_proposalID` with transaction data
    // `_transactionData` has been voted for or rejected, and executes the
    // transaction in the case it has been voted for.
    // @param _proposalID The proposal ID
    // @param _transactionData The data of the proposed transaction
    // @return Whether the proposed transaction has been executed or not
    function executeProposal(
        uint _proposalID,
        bytes memory _transactionData
    )virtual external  returns (bool _success);

    // @notice ATTENTION! I confirm to move my remaining ether to a new DAO
    // with `_newCurator` as the new Curator, as has been
    // proposed in proposal `_proposalID`. This will burn my tokens. This can
    // not be undone and will split the DAO into two DAO's, with two
    // different underlying tokens.
    // @param _proposalID The proposal ID
    // @param _newCurator The new Curator of the new DAO
    // @dev This function, when called for the first time for this proposal,
    // will create a new DAO and send the sender's portion of the remaining
    // ether and Reward Tokens to the new DAO. It will also burn the DAO Tokens
    // of the sender.
    function splitDAO(
        uint _proposalID,
        address _newCurator
    )virtual external   returns (bool _success);

    // @dev can only be called by the DAO itself through a proposal
    // updates the contract of the DAO by sending all ether and rewardTokens
    // to the new DAO. The new DAO needs to be approved by the Curator
    // @param _newContract the address of the new contract
    function newContract(address _newContract) virtual internal;


    // @notice Add a new possible recipient `_recipient` to the whitelist so
    // that the DAO can send transactions to them (using proposals)
    // @param _recipient New recipient address
    // @dev Can only be called by the current Curator
    // @return Whether successful or not
    function changeAllowedRecipients(address _recipient, bool _allowed) virtual external  returns (bool _success);


    // @notice Change the minimum deposit required to submit a proposal
    // @param _proposalDeposit The new proposal deposit
    // @dev Can only be called by this DAO (through proposals with the
    // recipient being this DAO itself)
    function changeProposalDeposit(uint _proposalDeposit) virtual external ;

    // @notice Move rewards from the DAORewards managed account
    // @param _toMembers If true rewards are moved to the actual reward account
    //                   for the DAO. If not then it's moved to the DAO itself
    // @return Whether the call was successful
    function retrieveDAOReward(bool _toMembers) virtual external  returns (bool _success);

    // @notice Get my portion of the reward that was sent to `rewardAccount`
    // @return Whether the call was successful
    function getMyReward() virtual internal  returns(bool _success);

    // @notice Withdraw `_account`'s portion of the reward from `rewardAccount`
    // to `_account`'s balance
    // @return Whether the call was successful
    function withdrawRewardFor(address _account) virtual internal returns (bool _success);

    // @notice Send `_amount` tokens to `_to` from `msg.sender`. Prior to this
    // getMyReward() is called.
    // @param _to The address of the recipient
    // @param _amount The amount of tokens to be transfered
    // @return Whether the transfer was successful or not
    function transferWithoutReward(address _to, uint256 _amount) virtual external  returns (bool success);

    // @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    // is approved by `_from`. Prior to this getMyReward() is called.
    // @param _from The address of the sender
    // @param _to The address of the recipient
    // @param _amount The amount of tokens to be transfered
    // @return Whether the transfer was successful or not
    function transferFromWithoutReward(
        address _from,
        address _to,
        uint256 _amount
    ) virtual external  returns (bool success);

    // @notice Doubles the 'minQuorumDivisor' in the case quorum has not been
    // achieved in 52 weeks
    // @return Whether the change was successful or not
    function halveMinQuorum() virtual internal  returns (bool _success);

    // @return total number of proposals ever created
    function numberOfProposals() virtual external  returns (uint _numberOfProposals);

    // @param _proposalID Id of the new curator proposal
    // @return Address of the new DAO
    function getNewDAOAddress(uint _proposalID) virtual external  returns (address _newDAO);

    // @param _account The address of the account which is checked.
    // @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function isBlocked(address _account) virtual internal returns (bool);

    // @notice If the caller is blocked by a proposal whose voting deadline
    // has exprired then unblock him.
    // @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function unblockMe() virtual external returns (bool);

    event ProposalAdded(
        uint indexed proposalID,
        address recipient,
        uint amount,
        bool newCurator,
        string description
    );
    event Voted(uint indexed proposalID, bool position, address indexed voter);
    event ProposalTallied(uint indexed proposalID, bool result, uint quorum);
    event NewCurator(address indexed _newCurator);
    event AllowedRecipientChanged(address indexed _recipient, bool _allowed);
}

// The DAO contract itself
contract DAO is DAOInterface, Token, TokenCreation {
    bool private lock;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => uint256)  private feesValues;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromAntiwhale;
    mapping (address => bool) private _isExcludedFromSellMax;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 public constant MAX = ~uint256(0);
    uint256 public _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string _name = "IntDao"; 
    string _symbol = "INTDAO";
    uint _decimals = 18;

    uint private thValue;
    uint private rThValue;

  
    uint256 public buyRewardfee = 2;
    uint256 private previousbuyRewardfee = buyRewardfee;
    uint256 public buyMarketingFee = 3;
    uint256 public buytournementFee = 1;
    uint256 public totalBuyFees =  buyMarketingFee + buytournementFee;
    uint256 private previoustotalBuyFees = totalBuyFees;

    uint256 public sellRewardfee = 3;
    uint256 private previoussellRewardfee = sellRewardfee;
    uint256 public sellMarketingFee = 3;
    uint256 public selltournementFee = 1;
    uint256 public sellCharityFee = 1;
    uint256 public totalSellFees =  sellMarketingFee + selltournementFee + sellCharityFee;
    uint256 private previoustotalSellFees = totalSellFees;

    uint256 public transferRewardfee = 2;
    uint256 private previoustransferRewardfee = transferRewardfee;
    uint256 public transferMarketingFee = 2;
    uint256 public transfertournementFee = 1;
    uint256 public totalTransferFees =  transferMarketingFee + transfertournementFee;
    uint256 private previoustotalTranferFees = totalTransferFees;


    IpancakeV2Router02 public  pancakeV2Router;
    address public  pancakeV2Pair;
    
    uint256 private _maxTxAmount = (_tTotal * 500) / 10000;

    uint private sellMaxTxAmount = (_tTotal * 500) / 10000;
   
    address public  marketingAddress;
    address public tournamentAddress;
    address public charityAddress;
    constructor(
        address _curator,
        DAO_Creator _daoCreator,
        uint _proposalDeposit,
        uint _minTokensToCreate,
        uint _closingTime,
        address _privateCreation,
        address routerAddress,
        address _marketingAddress,
        address _tournamentAddress,
        address _charityAddress
    ) TokenCreation(_minTokensToCreate, _closingTime, _privateCreation) Token(_curator)  {
        _rOwned[msg.sender] = _rTotal;
        require(_curator != address(0), "Curator address can't be zero address");
        curator = _curator;
        daoCreator = _daoCreator;
        proposalDeposit = _proposalDeposit;
        rewardAccount = new ManagedAccount(address(this), false);
        DAOrewardAccount = new ManagedAccount(address(this), false);
        lastTimeMinQuorumMet = block.timestamp;
        minQuorumDivisor = 5; // sets the minimal quorum to 20%
        //proposalsTotal += 1; // avoids a proposal with ID 0 because it is used
        allowedRecipients[address(this)] = true;
        allowedRecipients[curator] = true;
        IpancakeV2Router02 _pancakeV2Router = IpancakeV2Router02(routerAddress);
        //swap
        pancakeV2Pair = IpancakeV2Factory(_pancakeV2Router.factory())
            .createPair(address(this), _pancakeV2Router.WETH());

        // set the rest of the contract variables
        pancakeV2Router = _pancakeV2Router;
        require(_marketingAddress != address(0), "Marketing address can't be zero address");
        marketingAddress = _marketingAddress;

        require(_tournamentAddress != address(0), "Tournament address can't be zero address");
        tournamentAddress = _tournamentAddress;

        require(_charityAddress != address(0), "Charity address can't be zero address");
        charityAddress = _charityAddress;

        //exclude owner and this contract from fee
        _isExcludedFromFee[curator] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;
        _isExcludedFromFee[_tournamentAddress] = true;
        _isExcludedFromFee[_charityAddress] = true;
        _isExcludedFromAntiwhale[curator] = true;
        _isExcludedFromAntiwhale[address(this)] = true;
        _isExcludedFromSellMax[address(this)] = true;
        _isExcludedFromSellMax[curator] = true;

        excludeFromReward(address(pancakeV2Pair));
        excludeFromReward(msg.sender);

        emit Transfer(address(0), msg.sender, _tTotal);
    }

    receive() external payable {
        createTokenProxy(msg.sender);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint) {
        return _decimals;
    }

    function totalSupply() public view  returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function isExcludedFromAntiwhale(address acc) public view returns(bool) {
        return _isExcludedFromAntiwhale[acc];
    }
    function setExcludeFromAntiwhale(address acc, bool value) external  {
        require(msg.sender == curator, "Only a curator can do this");
        _isExcludedFromAntiwhale[acc] = value;
    }

    function isExcludedFromMaxSell(address acc) public view returns(bool) {
        return _isExcludedFromSellMax[acc];
    }
    function setExcludeFromMaxSell(address acc, bool value) external  {
        require(msg.sender == curator, "Only a curator can do this");
        _isExcludedFromSellMax[acc] = value;
    }


    function transfer(address recipient, uint256 amount) public  returns (bool) {
        _transfer(msg.sender, recipient, amount);
        allowedRecipients[recipient] = true;
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        allowedRecipients[recipient] = true;
        return true;
    }


    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    // function deliver(uint256 tAmount,uint256 _type) public {
    //     address sender = msg.sender;
    //     require(!_isExcluded[sender], "Excluded addresses cannot call this function");
    //     (uint256 rAmount,,,,,) = _getValues(tAmount, _type);
    //     _rOwned[sender] = _rOwned[sender] - rAmount;
    //     _rTotal = _rTotal - rAmount;
    //     _tFeeTotal = _tFeeTotal + tAmount;
    // }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee, uint256 _type) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount, _type);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount,_type);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return (rAmount/currentRate);
    }

    function excludeFromReward(address account) public  {
        require(msg.sender == curator, "Only a curator can do this");
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude pancake router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external  {
        require(msg.sender == curator, "Only a curator can do this");
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount, uint256 _type) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tSwapping) = _getValues(tAmount, _type);
        thValue = tFee;
        rThValue = rFee;
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;        
        _takeSwapping(tSwapping);
        _reflectFee(rFee, tFee);
         //_tTotal -= tFee;
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function excludeFromFee(address account) external {
        require(msg.sender == curator, "Only a curator can do this");
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external  {
        require(msg.sender == curator, "Only a curator can do this");
        _isExcludedFromFee[account] = false;
    }
    
    function setBuyFeePercent(uint256 BuyFee) external  {
        require(msg.sender == curator, "Only a curator can do this");
        buyRewardfee = BuyFee;
    }

    function setSellFeePercent(uint256 SellFee) external  {
        require(msg.sender == curator, "Only a curator can do this");
        sellRewardfee = SellFee;
    }

    function setTransferFeePercent(uint256 TransferFee) external  {
        require(msg.sender == curator, "Only a curator can do this");
        transferRewardfee = TransferFee;
    }
    
    function setBuySwappingFeePercent(uint256 _buyMarketingFee, uint256 _buytournementFee) external  {
        require(msg.sender == curator, "Only a curator can do this");
        buyMarketingFee = _buyMarketingFee;
        buytournementFee = _buytournementFee;
        totalBuyFees = buyMarketingFee + buytournementFee;
    }

    function setSellSwappingFeePercent(uint256 _sellMarketingFee, uint256 _selltournementFee, uint256 _sellCharityFee) external  {
        require(msg.sender == curator, "Only a curator can do this");
        sellMarketingFee = _sellMarketingFee;
        selltournementFee = _selltournementFee;
        sellCharityFee = _sellCharityFee;
        totalSellFees = sellMarketingFee + selltournementFee + sellCharityFee;
    }

    function setTransferSwappingFeePercent(uint256 _transferMarketingFee, uint256 _transfertournementFee) external  {
        require(msg.sender == curator, "Only a curator can do this");
        transferMarketingFee = _transferMarketingFee;
        transfertournementFee = _transfertournementFee;
        totalTransferFees = transferMarketingFee + transfertournementFee;
    }

    function setmarketingAddress(address payable _market) external {
        require(msg.sender == curator, "Only a curator can do this");
        require(_market != address(0), "Marketing address can't zero address");
        marketingAddress = _market;
    }

    function settournmentAddress(address payable _tournment) external {
        require(msg.sender == curator, "Only a curator can do this");
        require(_tournment != address(0), "Tournament address can't zero address");
        tournamentAddress = _tournment;
    }

    function setCharityAddress(address payable _charity) external {
        require(msg.sender == curator, "Only a curator can do this");
        require(_charity != address(0), "Charity address can't zero address");
        charityAddress = _charity;
    }


   
    function setMaxTxPercent(uint256 maxTxPercent) external  {
        require(msg.sender == curator, "Only a curator can do this");
        require(maxTxPercent > 0 && maxTxPercent <= 500, "max 5%");
        _maxTxAmount = ((_tTotal * maxTxPercent) / 10000);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount,uint256 _type) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tSwapping) = _getTValues(tAmount,_type);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tSwapping, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tSwapping);
    }

    function tokenHolderRewards() public view returns(uint256, uint256) {
        return(thValue, rThValue);
    }

    function _getTValues(uint256 tAmount, uint256 _type) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount,_type);
        uint256 tSwapping = calculateSwappingFee(tAmount,_type);
        uint256 tTransferAmount = tAmount - tFee - tSwapping;
        return (tTransferAmount, tFee, tSwapping);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tSwapping, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rSwapping = tSwapping * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rSwapping;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return (rSupply / tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < (_rTotal/ _tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeSwapping(uint256 tSwapping) private {
        uint256 currentRate =  _getRate();
        uint256 rSwapping = tSwapping * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rSwapping;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tSwapping;
    }
    
    function calculateTaxFee(uint256 _amount, uint256 _type) private view returns (uint256) {
        uint256 fees;
        if(_type == 1) {
            fees = buyRewardfee;
        }
        else if(_type == 2) {
             fees = sellRewardfee;
        }
        else{
             fees = transferRewardfee;
        }
        return ((_amount * fees) / (10**2));
    }

    function calculateSwappingFee(uint256 _amount, uint256 _type) private view returns (uint256) {
       uint256 fees;
        if(_type == 1) {
            fees = totalBuyFees;
        }
        else if(_type == 2) {
             fees = totalSellFees;
        }
        else{
             fees = totalTransferFees;
        }
        return ((_amount * fees) / (10**2));
    }
    
    function removeAllFee(uint256 _type) private {
        if(_type == 1){
            previousbuyRewardfee = buyRewardfee;
            buyRewardfee = 0;
            previoustotalBuyFees = totalBuyFees;
            totalBuyFees = 0;
        }
        else if(_type == 2){
            previoussellRewardfee =  sellRewardfee;
            sellRewardfee = 0;
            previoustotalSellFees = totalSellFees;
            totalSellFees = 0;
        }
        else{
            previoustransferRewardfee = transferRewardfee;
            transferRewardfee = 0;
            previoustotalTranferFees = totalTransferFees;
            totalTransferFees = 0;
        }
       
    }
    
   function restoreAllFee(uint256 _type) private {
        if(_type == 1){
            buyRewardfee = previousbuyRewardfee;
            totalBuyFees = previoustotalBuyFees;
        }
        else if(_type == 2){
            sellRewardfee = previoussellRewardfee;
            totalSellFees = previoustotalSellFees;
        }
        else{
            transferRewardfee = previoustransferRewardfee;
            totalTransferFees = previoustotalTranferFees;
        }
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMaxSellAmount(uint val) external {
        require(val > 0 && val <= 500, "max 5%");
        sellMaxTxAmount = (totalSupply() * val) / 10000;
    }

   function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(!_isExcludedFromAntiwhale[from] && !_isExcludedFromAntiwhale[to]) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }
      
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        uint256 _type;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        if((from == address(pancakeV2Pair)) && to != curator){ // Buy
            _type = 1;
        }
        else if((to == address(pancakeV2Pair)) && !_isExcludedFromSellMax[from]){ // Sell
            require(amount <= sellMaxTxAmount, "BEP20 : Sell Amount Exceed");
            _type = 2;
        }
        else{   // Transfer
            _type = 3;
        }

        if(takeFee){
            _feeDistribution(amount,_type);
        }
        
        //transfer amount, it will take Buy, Sell and Transfer
        _tokenTransfer(from,to,amount,takeFee , _type);
    }

    function _feeDistribution(uint256 _amount, uint256 _type) private {
        uint256 marketFees;
        uint256 tournmentFees;
        uint charityFees;
        if(_type == 1 ) {
            marketFees    =    _amount * buyMarketingFee / 100;
            tournmentFees =    _amount * buytournementFee / 100;
        }
        else if (_type == 2) {
            marketFees    =    _amount * sellMarketingFee / 100;
            tournmentFees =    _amount * selltournementFee / 100;
            charityFees   =   _amount * sellCharityFee / 100;
            
            feesValues[charityAddress] = feesValues[charityAddress] + charityFees;
            _tOwned[charityAddress] += charityFees;
            emit Transfer(address(0), charityAddress, charityFees);
        }
        else{
            marketFees    =    _amount * transferMarketingFee / 100;
            tournmentFees =    _amount * transfertournementFee / 100;
        }
        feesValues[marketingAddress]= feesValues[marketingAddress] + marketFees;
        _tOwned[marketingAddress] += marketFees;
        
        feesValues[tournamentAddress] = feesValues[tournamentAddress] + tournmentFees;
        _tOwned[tournamentAddress] += tournmentFees;
        emit Transfer(address(0), tournamentAddress, tournmentFees);
        emit Transfer(address(0), marketingAddress, marketFees);
       

    }

    function swapping()external payable{
        require(marketingAddress == msg.sender || tournamentAddress == msg.sender , "BEP20 : Only Marketing and Development Address");
        require(feesValues[msg.sender] > 0 , "BEP20 : Invalid Amount");
        uint256 swapAmount;

        swapAmount = feesValues[msg.sender];
        feesValues[msg.sender] = 0;
        swapTokensForETH(msg.sender,swapAmount);
    }
   

    function swapTokensForETH(address to,uint256 tokenAmount) private {
        // generate the pancake pair path of token -> wETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeV2Router.WETH();

        _approve(address(this), address(pancakeV2Router), tokenAmount);

        // make the swap
        pancakeV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            1, // accept any amount of ETH
            path,
            to,
            block.timestamp
        );
    }


    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee, uint256 _type) private {
        if(!takeFee)
            removeAllFee(_type);
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, _type);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, _type);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount, _type);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, _type);
        } else {
            _transferStandard(sender, recipient, amount , _type);
        }
        
        if(!takeFee)
            restoreAllFee(_type);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount,uint256 _type) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tSwapping) = _getValues(tAmount,_type);
        thValue = tFee;
        rThValue = rFee;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeSwapping(tSwapping);
        _reflectFee(rFee, tFee);
        // _tTotal -= tFee;
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount,uint256 _type) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tSwapping) = _getValues(tAmount,_type);
        thValue = tFee;
        rThValue = rFee;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;           
        _takeSwapping(tSwapping);
        _reflectFee(rFee, tFee);
        //_tTotal -= tFee;
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount,uint256 _type) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tSwapping) = _getValues(tAmount,_type);
        thValue = tFee;
        rThValue = rFee;
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;   
        _takeSwapping(tSwapping);
        _reflectFee(rFee, tFee);
        // _tTotal -= tFee;
        emit Transfer(sender, recipient, tTransferAmount);
    }


    function viewFee(address _user) external view returns(uint256){
        return feesValues[_user];
    }

    function receiveEther() override payable external  returns (bool) {
        return true;
    }


    function newProposal(
        address _recipient,
        uint _amount,
        string memory _description,
        bytes memory _transactionData,
        uint _debatingPeriod,
        bool _newCurator
    )   override payable external returns (uint) {
        require(balanceOf(msg.sender) != 0, "Only a TokenHolders can create proposals");
        
        if (_newCurator && (
             _debatingPeriod < minSplitDebatePeriod)) {
            revert("Failed at 1");
        } 
        if (!isRecipientAllowed(_recipient) || (_debatingPeriod <  minProposalDebatePeriod)) {
            revert("Failed at 2");
        }

        if (_debatingPeriod > 8 weeks){
            revert("Failed at 3");
        }

        if (msg.value != proposalDeposit) {
            revert("Failed at 4");
        }

        if (block.timestamp + _debatingPeriod < block.timestamp) {// prevents overflow
            revert("Failed at 5");
        }

        //to prevent a 51% attacker to convert the ether into deposit
        if (msg.sender == address(this)) {
            revert("Failed at 6");
        }

        uint _proposalID = proposalsTotal + 1;
        Proposal storage p = proposals[_proposalID];
        p.recipient = _recipient;
        p.amount = _amount;
        p.description = _description;
        p.proposalHash = keccak256(abi.encode(_recipient, _amount, _transactionData));
        p.votingDeadline = block.timestamp + _debatingPeriod;
        p.open = true;
        //p.proposalPassed = False; // that's default
        p.newCurator = _newCurator;
        // if (_newCurator)
        //     p.splitData.length  =  p.splitData.length + 1;
        p.creator = msg.sender;
        p.proposalDeposit = msg.value;
        proposalsTotal += 1;

        sumOfProposalDeposits += msg.value;
    
        emit ProposalAdded(
            _proposalID,
            _recipient,
            _amount,
            _newCurator,
            _description
        );
        return _proposalID;
    }


    function checkProposalCode(
        uint _proposalID,
        address _recipient,
        uint _amount,
        bytes memory _transactionData
    )  override external view returns (bool _codeChecksOut) {
        Proposal storage p = proposals[_proposalID];
        return p.proposalHash == keccak256(abi.encode(_recipient, _amount, _transactionData));
    }


    function vote(
        uint _proposalID,
        bool _supportsProposal
    ) override external {
        require(balanceOf(msg.sender) != 0, "Only a Token Holders can vote!" );

        Proposal storage p = proposals[_proposalID];
        if (p.votedYes[msg.sender]
            || p.votedNo[msg.sender]
            || block.timestamp >= p.votingDeadline) {

            revert("At vote");
        }
        if (_supportsProposal) {
            p.yea += balances[msg.sender];
            p.votedYes[msg.sender] = true;
        } else {
            p.nay += balances[msg.sender];
            p.votedNo[msg.sender] = true;
        }

        if (blocked[msg.sender] == 0) {
            blocked[msg.sender] = _proposalID;
        } else if (p.votingDeadline > proposals[blocked[msg.sender]].votingDeadline) {
            // this proposal's voting deadline is further into the future than
            // the proposal that blocks the sender so make it the blocker
            blocked[msg.sender] = _proposalID;
        }

        emit Voted(_proposalID, _supportsProposal, msg.sender);
    }


    function executeProposal(
        uint _proposalID,
        bytes memory _transactionData
    )  override external returns (bool _success) {
    

        Proposal storage p = proposals[_proposalID];
        address payable creator =  payable(p.creator);//created an payable adddress. 

        uint waitPeriod = p.newCurator
            ? splitExecutionPeriod
            : executeProposalPeriod;
        // If we are over deadline and waiting period, assert proposal is closed
        if (p.open && block.timestamp > p.votingDeadline + waitPeriod) {
            closeProposal(_proposalID);
            revert();
        }
        

        // Check if the proposal can be executed
        if (block.timestamp < p.votingDeadline  // has the voting deadline arrived?
            // Have the votes been counted?
            || !p.open
            // Does the transaction code match the proposal?
            || p.proposalHash != keccak256(abi.encode(p.recipient, p.amount, _transactionData))) {

            revert();
        }


        // If the curator removed the recipient from the whitelist, close the proposal
        // in order to free the deposit and allow unblocking of voters
        if (!isRecipientAllowed(p.recipient)) {
            closeProposal(_proposalID);
            creator.transfer(p.proposalDeposit);
            revert();
        }

        bool proposalCheck = true;

        if (p.amount > actualBalance())
            proposalCheck = false;

        uint quorum = p.yea + p.nay;

        // require 53% for calling newContract()
        if (_transactionData.length >= 4 && _transactionData[0] == 0x68
            && _transactionData[1] == 0x37 && _transactionData[2] == 0xff
            && _transactionData[3] == 0x1e
            && quorum < minQuorum(actualBalance() + rewardToken[address(this)])) {

                proposalCheck = false;
        }

        if (quorum >= minQuorum(p.amount)) {

            // if (!creator.transfer(p.proposalDeposit))
            //     revert();
            //changed to met above conditon
            require(creator.send(p.proposalDeposit) == true, "Transfer Not Done");

            lastTimeMinQuorumMet = block.timestamp;
            // set the minQuorum to 20% again, in the case it has been reached
            if (quorum > _tTotal / 5)
                minQuorumDivisor = 5;
        }

        // Execute result
        if (quorum >= minQuorum(p.amount) && p.yea > p.nay && proposalCheck) {
            // if (!p.recipient.call.value(p.amount)(_transactionData))
            //     revert();
            //changed for 
            (bool success, bytes memory data) = p.recipient.call{value: (p.amount)}(_transactionData);
            require(success == true && data.length != 0, "Transfer failed at excute result 580"); 

            p.proposalPassed = true;
            _success = true;

            // only create reward tokens when ether is not sent to the DAO itself and
            // related addresses. Proxy addresses should be forbidden by the curator.
            if (p.recipient != address(this) && p.recipient != address(rewardAccount)
                && p.recipient != address(DAOrewardAccount)
                && p.recipient != address(extraBalance)
                && p.recipient != address(curator)) {

                rewardToken[address(this)] += p.amount;
                totalRewardToken += p.amount;
            }
        }

        closeProposal(_proposalID);

        // Initiate event
        emit ProposalTallied(_proposalID, _success, quorum);
    }


    function closeProposal(uint _proposalID) internal {
        Proposal storage p = proposals[_proposalID];
        if (p.open)
            sumOfProposalDeposits -= p.proposalDeposit;
        p.open = false;
    }

    function splitDAO(
        uint _proposalID,
        address _newCurator
    ) override external returns (bool _success) {
        require(balanceOf(msg.sender) != 0, "Only a TokenHolders can split dao");
        require(!lock);
        lock = true;
        Proposal storage p = proposals[_proposalID];

        // Sanity check

        if (block.timestamp < p.votingDeadline  // has the voting deadline arrived?
            //The request for a split expires XX days after the voting deadline
            || block.timestamp > p.votingDeadline + splitExecutionPeriod
            // Does the new Curator address match?
            || p.recipient != _newCurator
            // Is it a new curator proposal?
            || !p.newCurator
            // Have you voted for this split?
            || !p.votedYes[msg.sender]
            // Did you already vote on another proposal?
            || (blocked[msg.sender] != _proposalID && blocked[msg.sender] != 0) )  {

            revert("Voting Deadline reached");
        }

        // If the new DAO doesn't exist yet, create the new DAO and store the
        // current split data
        if (address(p.splitData[0].newDAO) == address(0)) {
            p.splitData[0].newDAO = createNewDAO(_newCurator);
            // Call depth limit reached, etc.
            if (address(p.splitData[0].newDAO) == address(0))
                revert();
            // should never happen
            if (address(this).balance < sumOfProposalDeposits)
                revert();
            p.splitData[0].splitBalance = actualBalance();
            p.splitData[0].rewardToken = rewardToken[address(this)];
            p.splitData[0]._totalSupply = _tTotal;
            p.proposalPassed = true;
        }

        // Move ether and assign new Tokens
        uint fundsToBeMoved =
            (balances[msg.sender] * p.splitData[0].splitBalance) /
            p.splitData[0]._totalSupply;

        bool isTokensCreated = p.splitData[0].newDAO.createTokenProxy{value : fundsToBeMoved}(msg.sender);
        require(isTokensCreated, "Tokens Not Created at Split DAO");
        // Assign reward rights to new DAO
        uint rewardTokenToBeMoved =
            (balances[msg.sender] * p.splitData[0].rewardToken) /
            p.splitData[0]._totalSupply;

        uint paidOutToBeMoved = DAOpaidOut[address(this)] * rewardTokenToBeMoved /
            rewardToken[address(this)];

        rewardToken[address(p.splitData[0].newDAO)] += rewardTokenToBeMoved;
        if (rewardToken[address(this)] < rewardTokenToBeMoved)
            revert();
        rewardToken[address(this)] -= rewardTokenToBeMoved;

        DAOpaidOut[address(p.splitData[0].newDAO)] += paidOutToBeMoved;
        if (DAOpaidOut[address(this)] < paidOutToBeMoved)
            revert();
        DAOpaidOut[address(this)] -= paidOutToBeMoved;

        // Burn DAO Tokens
        emit Transfer(msg.sender, address(0), balances[msg.sender]); // need to check again the scenarios for this
        withdrawRewardFor(msg.sender); // be nice, and get his rewards
        _tTotal -= balances[msg.sender];
        balances[msg.sender] = 0;
        paidOut[msg.sender] = 0;
        lock = false;
        return true;
    }

    function newContract(address _newContract) override internal {
        if (msg.sender != address(this) || !allowedRecipients[_newContract]) return;
        // move all ether
        // if (!_newContract.call{value : address(this).balance}("") ) {
        //     revert();
        // }
        (bool success,) = _newContract.call{value : address(this).balance}("");
        require(success, "failed at newContract()");

        //move all reward tokens
        rewardToken[_newContract] += rewardToken[address(this)];
        rewardToken[address(this)] = 0;
        DAOpaidOut[_newContract] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }


    function retrieveDAOReward(bool _toMembers) override external returns (bool _success) {
        DAO dao =  DAO(payable(msg.sender));

        if ((rewardToken[msg.sender] * DAOrewardAccount.getAccumulatedInput()) /
            totalRewardToken < DAOpaidOut[msg.sender])
            revert();

        uint reward =
            (rewardToken[msg.sender] * DAOrewardAccount.getAccumulatedInput()) /
            totalRewardToken - DAOpaidOut[msg.sender];
        if(_toMembers) {
            if (!DAOrewardAccount.payOut(dao.rewardAccount.address, reward))
                revert();
            }
        else {
            if (!DAOrewardAccount.payOut(address(dao), reward))
                revert();
        }
        DAOpaidOut[msg.sender] += reward;
        return true;
    }

    function getMyReward() override internal returns (bool _success) {
        return withdrawRewardFor(msg.sender);
    }


    function withdrawRewardFor(address _account)  override internal returns (bool _success) {
        require(!lock);
        lock = true;
        if ((balanceOf(_account) * rewardAccount.accumulatedInput()) / _tTotal < paidOut[_account])
            revert();

        uint reward =
            (balanceOf(_account) * rewardAccount.accumulatedInput()) / _tTotal - paidOut[_account];
        if (!rewardAccount.payOut(_account, reward))
            revert();
        paidOut[_account] += reward;
        lock = false;
        return true;
    }


    function transferWithoutReward(address _to, uint256 _value) override public returns (bool success) {
        if (!getMyReward())
            revert();
        return transfer(_to, _value);
    }


    function transferFromWithoutReward(
        address _from,
        address _to,
        uint256 _value
    )override external returns (bool success) {
        require(!lock);
        lock = true;
        if (!withdrawRewardFor(_from))
            revert();
        bool result = transferFrom(_from, _to, _value);
        lock = false;
        return result;
    }


    function transferPaidOut(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool success) {

        uint transfersPaidOut = paidOut[_from] * _value / balanceOf(_from);
        if (transfersPaidOut > paidOut[_from])
            revert();
        paidOut[_from] -= transfersPaidOut;
        paidOut[_to] += transfersPaidOut;
        return true;
    }


    function changeProposalDeposit(uint _proposalDeposit) override  external  {
        if (msg.sender != address(this) || _proposalDeposit > (actualBalance() + rewardToken[address(this)])
            / maxDepositDivisor) {

            revert("changeProposal deposit function failed");
        }
        proposalDeposit = _proposalDeposit;
    }


    function changeAllowedRecipients(address _recipient, bool _allowed)override  external  returns (bool _success) {
        if (msg.sender != curator)
            revert();
        allowedRecipients[_recipient] = _allowed;
        emit AllowedRecipientChanged(_recipient, _allowed);
        return true;
    }


    function isRecipientAllowed(address _recipient) internal view returns (bool _isAllowed) {
        if (allowedRecipients[_recipient]
            || (_recipient == address(extraBalance)
                // only allowed when at least the amount held in the
                // extraBalance account has been spent from the DAO
                && totalRewardToken > extraBalance.getAccumulatedInput()))
            return true;
        else
            return false;
    }

    function actualBalance()  public view returns (uint _actualBalance) {
        return address(this).balance - sumOfProposalDeposits;
    }


    function minQuorum(uint _value) internal view returns (uint _minQuorum) {
        // minimum of 20% and maximum of 53.33%
        return _tTotal / minQuorumDivisor +
            (_value * _tTotal) / (3 * (actualBalance() + rewardToken[address(this)]));
    }


    function halveMinQuorum()override internal returns (bool _success) {
        // this can only be called after `quorumHalvingPeriod` has passed or at anytime
        // by the curator with a delay of at least `minProposalDebatePeriod` between the calls
        if ((lastTimeMinQuorumMet < (block.timestamp - quorumHalvingPeriod) || msg.sender == curator)
            && lastTimeMinQuorumMet < (block.timestamp - minProposalDebatePeriod)) {
            lastTimeMinQuorumMet = block.timestamp;
            minQuorumDivisor *= 2;
            return true;
        } else {
            return false;
        }
    }

    function createNewDAO(address _newCurator) internal returns (DAO _newDAO) {
        emit NewCurator(_newCurator);
        return daoCreator.createDAO(_newCurator, 0, 0, (block.timestamp + splitExecutionPeriod), address(0), address(0), address(0), address(0) );
    }

    function numberOfProposals() override public view returns (uint _numberOfProposals) {
        // Don't count index 0. It's used by isBlocked() and exists from start
        return proposalsTotal;
    }

    function getNewDAOAddress(uint _proposalID) public view override returns (address _newDAO) {
        // Proposal storage p = proposals[_proposalID];

        return address(proposals[_proposalID].splitData[0].newDAO);
        // address newDAOAddress = p.splitData[0].newDAO;
        // return (newDAOAddress);
    }

    function isBlocked(address _account) override internal returns (bool) {
        if (blocked[_account] == 0)
            return false;
        Proposal storage p = proposals[blocked[_account]];
        if (block.timestamp > p.votingDeadline) {
            blocked[_account] = 0;
            return false;
        } else {
            return true;
        }
    }

    function unblockMe() override external returns (bool) {
        return isBlocked(msg.sender);
    }
    
}

abstract contract DAO_Creator {
    function createDAO(
        address _curator,
        uint _proposalDeposit,
        uint _minTokensToCreate,
        uint _closingTime,
        address routerAddress,
        address _marketingAddress,
        address _tournamentAddress,
        address _charityAddress
    ) external returns (DAO _newDAO) {
        return new DAO(
            _curator,
            DAO_Creator(this),
            _proposalDeposit,
            _minTokensToCreate,
            _closingTime,
            msg.sender,
            routerAddress,
            _marketingAddress,
            _tournamentAddress,
            _charityAddress
        );
    }
}