/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
//
// 'AnonymityCash-MITY on Binance Smart Chain' - MITY
//
// Mineable Cash token using Proof of Work
//
// An adaptation of 0xBTC token from the Ethereum mainnet 
// to be compliant with the Binance Smart Chain. 
// Motivation: after the DeFi-related increase of gas costs on the Ethereum
// mainnet, an alternative for miners is needed.
// AnonymityCash embodies such alternative and it restores the original Satoshi 
// Nakamoto's project settings for the difficulty adjustment period (2 weeks)
// and max target.
// 
//
// Symbol       : MITY
//
// Name         : AnonymityCash - minable cash electronic on BSC
//
// Total supply : 21,000,000,000,000.00
//
// Decimals     : 14
//
//
//
// This code is licensed MIT.
//
// The original source code (see 0xbitcoin.foundation) is licensed MIT.
//
// Copyright (c) 2018 anonymityswap.com
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// ----------------------------------------------------------------------------
// Credits to infernal_toast, 0xBTC Contributors, Team and Supporters
// for the pioneering work on mineable tokens.
// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------

// Safe math and extended math libraries

// ----------------------------------------------------------------------------

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}



library ExtendedMath {


    //return the smaller of the two inputs (a or b)
    function limitLessThan(uint a, uint b) internal pure returns (uint c) {

        if(a > b) return b;

        return a;

    }
}

// ----------------------------------------------------------------------------

// BEP20 interface compatible methods available

// ----------------------------------------------------------------------------

contract BEP20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}



// ----------------------------------------------------------------------------

// Contract function to receive approval and execute function in one call

//

// Borrowed from MiniMeToken

// ----------------------------------------------------------------------------

contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}



// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    address public newOwner;


    event OwnershipTransferred(address indexed _from, address indexed _to);


    function Owned() public {

        owner = msg.sender;

    }


    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);

    }
    
    function getOwner() external view returns (address) {
        
        return owner;
        
    }

}


// ----------------------------------------------------------------------------

contract _AnonymityCash is BEP20Interface, Owned {

    using SafeMath for uint;
    using ExtendedMath for uint;


    string public symbol;

    string public name;

    uint8 public decimals;

    uint public _totalSupply;



    uint public latestDifficultyPeriodStarted;



    uint public epochCount;//number of 'blocks' mined


    uint public _BLOCKS_PER_READJUSTMENT = 2016;


    //a little number
    uint public  _MINIMUM_TARGET = 2**16;


    //a big number is easier ; just find a solution that is smaller
    uint public  _MAXIMUM_TARGET = 2**224;


    uint public miningTarget;

    bytes32 public challengeNumber;   //generate a new one when a new reward is minted



    uint public rewardEra;
    uint public maxSupplyForEra;


    address public lastRewardTo;
    uint public lastRewardAmount;
    uint public lastRewardBscBlockNumber;

    bool locked = false;

    mapping(bytes32 => bytes32) solutionForChallenge;

    uint public tokensMinted;

    mapping(address => uint) balances;


    mapping(address => mapping(address => uint)) allowed;


    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    function _AnonymityCash() public onlyOwner{



        symbol = "MITY";

        name = "AnonymityCash - minable cash electronic on BSC";

        decimals = 14;

        _totalSupply = 21000000000000 * 16**uint(decimals);

        if(locked) revert();
        locked = true;

        tokensMinted = 0;

        rewardEra = 0;
        maxSupplyForEra = _totalSupply.div(2);

        miningTarget = _MAXIMUM_TARGET;

        latestDifficultyPeriodStarted = block.number;

        _startNewMiningEpoch();


    }




        function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success) {


            //the PoW must contain work that includes a recent BSC block hash (challenge number) and the msg.sender's address to prevent MITM attacks
            bytes32 digest =  keccak256(challengeNumber, msg.sender, nonce );

            //the challenge digest must match the expected
            if (digest != challenge_digest) revert();

            //the digest must be smaller than the target
            if(uint256(digest) > miningTarget) revert();


            //only allow one reward for each challenge
             bytes32 solution = solutionForChallenge[challengeNumber];
             solutionForChallenge[challengeNumber] = digest;
             if(solution != 0x0) revert();  //prevent the same answer from awarding twice


            uint reward_amount = getMiningReward();

            balances[msg.sender] = balances[msg.sender].add(reward_amount);

            tokensMinted = tokensMinted.add(reward_amount);


            //Cannot mint more tokens than there are
            assert(tokensMinted <= maxSupplyForEra);

            //set readonly diagnostics data
            lastRewardTo = msg.sender;
            lastRewardAmount = reward_amount;
            lastRewardBscBlockNumber = block.number;


             _startNewMiningEpoch();

              Mint(msg.sender, reward_amount, epochCount, challengeNumber );

           return true;

        }


    //a new 'block' to be mined
    function _startNewMiningEpoch() internal {

      //if max supply for the era will be exceeded next reward round then enter the new era before that happens

      //40 is the final reward era, almost all tokens minted
      //once the final era is reached, more tokens will not be given out because the assert function
      if( tokensMinted.add(getMiningReward()) > maxSupplyForEra && rewardEra < 39)
      {
        rewardEra = rewardEra + 1;
      }

      //set the next minted supply at which the era will change
      // total supply is 2100000000000000  because of 16 decimal places
      maxSupplyForEra = _totalSupply - _totalSupply.div( 2**(rewardEra + 1));

      epochCount = epochCount.add(1);

      //every so often, readjust difficulty. Dont readjust when deploying
      if(epochCount % _BLOCKS_PER_READJUSTMENT == 0)
      {
        _reAdjustDifficulty();
      }


      //make the latest BSC block hash a part of the next challenge for PoW to prevent pre-mining future blocks
      //do this last since this is a protection mechanism in the mint() function
      challengeNumber = block.blockhash(block.number - 1);






    }



    // Difficulty:
    //https://en.bitcoin.it/wiki/Difficulty#What_is_the_formula_for_difficulty.3F

    //readjust the target by 5 percent
    function _reAdjustDifficulty() internal {

        uint bscBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;
		// One BSC block = 3 sec. --> assuming 1200 BSC blocks per hour

		// we want miners to spend 10 minutes to mine each 'block', about 200 BSC blocks = one AnonymityCash epoch
        uint epochsMined = _BLOCKS_PER_READJUSTMENT;

        uint targetBscBlocksPerDiffPeriod = epochsMined * 200; //should be 200 times slower than BSC

        //if, hypotetically, there were less BSC blocks passed in time than expected
        if( bscBlocksSinceLastDifficultyPeriod < targetBscBlocksPerDiffPeriod )
        {
          uint excess_block_pct = (targetBscBlocksPerDiffPeriod.mul(100)).div( bscBlocksSinceLastDifficultyPeriod );

          uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(1000);
          // If there were 5% more blocks mined than expected then this is 5.  If there were 100% more blocks mined than expected then this is 100.

          //make it harder
          miningTarget = miningTarget.sub(miningTarget.div(2000).mul(excess_block_pct_extra));   //by up to 50 %
        }else{
          uint shortage_block_pct = (bscBlocksSinceLastDifficultyPeriod.mul(100)).div( targetBscBlocksPerDiffPeriod );

          uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(1000); //always between 0 and 1000

          //make it easier
          miningTarget = miningTarget.add(miningTarget.div(2000).mul(shortage_block_pct_extra));   //by up to 50 %
        }



        latestDifficultyPeriodStarted = block.number;

        if(miningTarget < _MINIMUM_TARGET) //very difficult
        {
          miningTarget = _MINIMUM_TARGET;
        }

        if(miningTarget > _MAXIMUM_TARGET) //very easy
        {
          miningTarget = _MAXIMUM_TARGET;
        }
    }


    //this is a recent BSC block hash, used to prevent pre-mining future blocks
    function getChallengeNumber() public constant returns (bytes32) {
        return challengeNumber;
    }

    //the number of zeroes the digest of the PoW solution requires.  Auto adjusts
     function getMiningDifficulty() public constant returns (uint) {
        return _MAXIMUM_TARGET.div(miningTarget);
    }

    function getMiningTarget() public constant returns (uint) {
       return miningTarget;
   }



    //21t coins total
    //reward begins at 50000000 and is cut in half every reward era (as tokens are mined)
    function getMiningReward() public constant returns (uint) {
        //once we get half way thru the coins, only get 25000000 per block

         //every reward era, the reward amount halves.

         return (50000000 * 16**uint(decimals) ).div( 2**rewardEra ) ;

    }

    //help debug mining software
    function getMintDigest(uint256 nonce, bytes32 challenge_number) public view returns (bytes32 digesttest) {

        bytes32 digest = keccak256(challenge_number,msg.sender,nonce);

        return digest;

      }

        //help debug mining software
      function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns (bool success) {

          bytes32 digest = keccak256(challenge_number,msg.sender,nonce);

          if(uint256(digest) > testTarget) revert();

          return (digest == challenge_digest);

        }



    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public constant returns (uint) {

        return _totalSupply  - balances[address(0)];

    }



    // ------------------------------------------------------------------------

    // Get the token balance for account `tokenOwner`

    // ------------------------------------------------------------------------

    function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return balances[tokenOwner];

    }



    // ------------------------------------------------------------------------

    // Transfer the balance from token owner's account to `to` account

    // - Owner's account must have sufficient balance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(msg.sender, to, tokens);

        return true;

    }



    // ------------------------------------------------------------------------

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

    // from the token owner's account

    //

    // Warning: there are no checks for the approval double-spend attack

    // as this should be implemented in user interfaces

    // ------------------------------------------------------------------------

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        return true;

    }



    // ------------------------------------------------------------------------

    // Transfer `tokens` from the `from` account to the `to` account

    //

    // The calling account must already have sufficient tokens approve(...)-d

    // for spending from the `from` account and

    // - From account must have sufficient balance to transfer

    // - Spender must have sufficient allowance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(from, to, tokens);

        return true;

    }



    // ------------------------------------------------------------------------

    // Returns the amount of tokens approved by the owner that can be

    // transferred to the spender's account

    // ------------------------------------------------------------------------

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }



    // ------------------------------------------------------------------------

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

    // from the token owner's account. The `spender` contract function

    // `receiveApproval(...)` is then executed

    // ------------------------------------------------------------------------

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

        return true;

    }



    // ------------------------------------------------------------------------

    // The contract does not accept BNB directly

    // ------------------------------------------------------------------------

    function () public payable {

        revert();

    }



    // ------------------------------------------------------------------------

    // Any BEP20 standard token accidentally sent to the contract can be transferred out

    // ------------------------------------------------------------------------

    function transferAnyBEP20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return BEP20Interface(tokenAddress).transfer(owner, tokens);

    }

}