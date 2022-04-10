/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

/**
* @title Send Back Token (SDBK)
* @author Frank Zielen, [email protected]
* @notice SPDX-License-Identifier: (c) Frank Zielen
* @notice SDBK is an ERC20 / BEP20 token equipped with a redeem functionality that randomly rewards token holders for burning tokens
* @notice Version 1.0.12
*/
pragma solidity ^0.8.4;

/**
* @dev ERC20 / BEP20 Send Back Token (SDBK)
*/
contract SendBackToken {

    using SafeMath for uint256;

    /// @dev Core token parameter
    string public constant name = "Send Back Token";
    /// @dev Core token parameter
    string public constant symbol = "SDBK";
    /// @dev Core token parameter
    uint8 public constant decimals = 0;

    /// @dev Owner of contract
    address public contractOwner;

    /// @dev Total supply of tokens (variable because tokens can be redeemed = burned)
    uint256 public totalSupply = 0;
    /// @dev Token balances
    mapping(address => uint256) balances;
    /// @dev Tokens allowed to be transferred from address owners by delegates 
    mapping(address => mapping (address => uint256)) allowed;

    /// @dev Whenever ETH/BNB is transfered to contract address tokens are minted and supplied to the sender
    /// @dev Number of minted tokens is given by spent ETH/BNB and tokenCost 
    /// @dev All cost of token are collected in the balance of the contract
    /// @dev Cost of token in WEI
    uint256 public tokenCost;
    /// @dev Token holders can redeem tokens by transfering them (back) to contract
    /// @dev In this case one token is selected randomly among all tokens
    /// @dev If the redeemed token is selected the token holder gets a reward
    /// @dev The redeemed token is burned in any case
    /// @dev Reward is given as share in per thousand of current contract balance minus fees
    uint256 public prizeShare;

    /// @dev Fee per token given per thousand of cost of token (e.g. 25 = 0.025 = 2.5%) for creator of contract
    uint256 public tokenFee;
    /// @dev Cumulated number of fees gathered and to be disbursed
    uint256 totalNumFees = 0;

    /// @dev Time of last activity (=token minted or redeemed)
    uint256 public lastAction = 0;
    /// @dev Inactivity time threshhold - after this time of inactivity creator of contract can withdraw balance of contract
    /// @dev This is an "exit" option in case the token is dead and not used anymore
    uint256 public inactivityTimeThreshhold;

    /// @dev Seed for random number
    uint256 seedRandomNumber = 0;

    /// @dev Approval event
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    /// @dev Transfer event
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    /// @dev Minted event fired when ETH/BNB is received by contract and tokens are minted (zero tokens also possible)
    event Minted(address indexed from, uint256 amount, uint256 tokens);
    /// @dev Redeemed event fired when tokens are redeemed
    event Redeemed(address indexed from, uint256 tokens, uint256 price);
    /// @dev Withdrawn event fired when contract owner withdraws from contract
    event Withdrawn(bytes typeofwithdrawal, uint256 tokens);

    /// @dev Initialize token
    constructor() payable {
        contractOwner = msg.sender;

        tokenCost = 10**16; // 0.01 ETH/BNB
        prizeShare = 500; // 50%
        tokenFee = 50; // 5%

        lastAction = block.timestamp;
        inactivityTimeThreshhold = 90 days;
    }

    /**
    * @dev Modifier to restrict to contract owner
    */
    modifier onlyOwner {
        require(msg.sender == contractOwner, "Executable by contract owner only");
        _;
    }

    /**
    * @dev Change owner of contract
    */
    function changeOwner(address newOwner) public onlyOwner {
        contractOwner = newOwner;
    }

    /**
    * @dev Get balance of contract in WEI (ETH/BNB)
    */
    function balanceOfContract() public view returns (uint256) {
        return address(this).balance;
    }

    /**
    * @dev Send WEI (ETH/BNB) to contract to mint & get tokens (receive needed for sendings without msg.data)
    */
    receive() external payable {  
        uint256 tokens = msg.value / tokenCost;
        if (tokens > 0) {
            mintTokens(tokens);
        }
        emit Minted(msg.sender, msg.value, tokens);
        emit Transfer(address(this), msg.sender, tokens);
    }

    /**
    * @dev Send WEI (ETH/BNB) to contract to mint & get tokens (fallback needed for sendings with msg.data or if undefined function is called)
    */
    fallback() external payable {
        require(msg.value > 0);
        uint256 tokens = msg.value / tokenCost;
        if (tokens > 0) {
            mintTokens(tokens);
        }
        emit Minted(msg.sender, msg.value, tokens);
        emit Transfer(address(this), msg.sender, tokens);
    }

    /**
    * @dev Mint & get "numTokens" tokens
    */
    function mintTokens(uint256 numTokens) internal {
        totalSupply=totalSupply.add(numTokens);
        totalNumFees=totalNumFees.add(numTokens);
        balances[msg.sender]=balances[msg.sender].add(numTokens);
        lastAction = block.timestamp;
    }

    /**
    * @dev Get balance of tokens for "tokenOwner"
    */
    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    /**
    * @dev Transfer "numTokens" tokens (from caller of function) to "receiver"
    * @dev If "receiver" is this contract tokens are redeemed (burnt) and granted ETH/BNB in WEI (prize) is transferred from contract (to caller of function)
    */
    function transfer(address receiver, uint256 numTokens) public returns (bool) {
        require(numTokens > 0);
        require(numTokens <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(numTokens);

        // Transfer tokens if sent to externally owned address (or even other contract address)
        if (receiver != address(this)) {
            balances[receiver] = balances[receiver].add(numTokens);
            emit Transfer(msg.sender, receiver, numTokens);
        }

        // Redeem tokens if and only if sent to this contract address
        else {
            uint256 totalPrize = 0;
            uint256 contractbalance = address(this).balance;
            uint256 _totalSupply = totalSupply;
            uint256 randomnumber = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, blockhash(0), seedRandomNumber)));
            seedRandomNumber = seedRandomNumber.infiniteInc();

            for (uint256 i=0; i<numTokens; i++) {
                if (randomnumber % _totalSupply == 0) {
                    uint256 prize = currentPrize(contractbalance);
                    contractbalance = contractbalance.sub(prize);
                    totalPrize = totalPrize.add(prize);
                }
                randomnumber = uint256(keccak256(abi.encodePacked(randomnumber, i)));
                _totalSupply--;
            }
            totalSupply = _totalSupply;

            if (totalPrize > 0) {
                (bool sent, ) = msg.sender.call{value: totalPrize}("");
                require(sent, "Failed to send ETH/BNB");
            }
            
            lastAction = block.timestamp;
            emit Redeemed(msg.sender, numTokens, totalPrize);
            emit Transfer(msg.sender, address(this), numTokens);
        }

        return true;
    }

    /**
    * @dev Allow "delegate" to transfer "numTokens" token (from caller of function)
    */
    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    /**
    * @dev Get number of tokens from "owner" allowed to be transferred by "delegate"
    */
    function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    }

    /**
    * @dev Transfer "numTokens" tokens from "owner" to "buyer"
    * @dev For this, approval has to be given to caller of function in advance
    * @dev Especially, caller of function cannot act as "owner" without allowing himself before (-> for this case just use "transfer" function)
    */
    function transferFrom(address owner, address buyer, uint256 numTokens) public returns (bool) {
        require(numTokens > 0);
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);

        // Transfer tokens if sent to externally owned address (or other contract address)
        if (buyer != address(this)) {
            balances[buyer] = balances[buyer].add(numTokens);
            emit Transfer(owner, buyer, numTokens);
        }

        // Redeem tokens if and only if sent to this contract address
        else {
            uint256 totalPrize = 0;
            uint256 contractbalance = address(this).balance;
            uint256 _totalSupply = totalSupply;
            uint256 randomnumber = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, blockhash(0), seedRandomNumber)));
            seedRandomNumber = seedRandomNumber.infiniteInc();
            
            for (uint256 i=0; i<numTokens; i++) {
                if (randomnumber % _totalSupply == 0) {
                    uint256 prize = currentPrize(contractbalance);
                    contractbalance = contractbalance.sub(prize);
                    totalPrize = totalPrize.add(prize);
                }
                randomnumber = uint256(keccak256(abi.encodePacked(randomnumber, i)));
                _totalSupply--;
            }
            totalSupply = _totalSupply;

            if (totalPrize > 0) {
                (bool sent, ) = owner.call{value: totalPrize}("");
                require(sent, "Failed to send ETH/BNB");
            }

            lastAction = block.timestamp;
            emit Redeemed(owner, numTokens, totalPrize);
            emit Transfer(owner, address(this), numTokens);
        }
        
        return true;
    }

    /**
    * @dev Determine current prize ("jackpot") in case of successful token redemption
    * @dev prize must exceed tokenCost (to avoid micro transfers)
    */
    function currentPrize(uint256 contractbalance) private view returns (uint256) {
        if (contractbalance <= totalFees()) {
            return 0;
        }
        else {
            uint256 prize = (contractbalance - totalFees()) * prizeShare / 1000;
            return prize > tokenCost ? prize : 0;
        }
    }

    function currentPrize() public view returns (uint256) {
        return currentPrize(address(this).balance);
    }

    /**
    * @dev Determine fees still included in balance of contract and available for withdrawal by TransferTotalFees
    */
    function totalFees() public view returns (uint256) {
        return totalNumFees.mul(tokenCost*tokenFee/1000);
    }

    /**
    * @dev Transfer / withdraw fees still included in balance of contract to creator of contract
    */
    function withdrawFees() public onlyOwner returns (bool) {
        uint256 fees = totalFees();
        require(fees > 0);
        // Following case should never be happen!
        assert(address(this).balance >= fees); 

        (bool sent, ) = contractOwner.call{value: fees}("");
        require(sent, "Failed to send ETH/BNB");

        totalNumFees = 0;
        emit Withdrawn("fees", fees);

        return true;
    }

    /**
    * @dev Transfer / withdraw total balance of contract (including total fees) to creator of contract
    */
    function withdrawContractBalance() public onlyOwner returns (bool) {
        uint256 amount = address(this).balance;
        require(amount > 0);
        require(block.timestamp >= lastAction + inactivityTimeThreshhold, "Inactivity time threshhold hasn't been reached");

        (bool sent, ) = contractOwner.call{value: amount}("");
        require(sent, "Failed to send ETH/BNB");
        
        totalNumFees = 0;
        emit Withdrawn("total", amount);

        return true;
    }
}

/**
* @dev Mathematical support functions
*/
library SafeMath {

    /**
    * @dev Multiply two numbers
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        if (_a == 0) {
            return 0;
        }
        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    /**
    * @dev Divide two numbers
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a / _b;
    }

    /**
    * @dev Subtract two numbers
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    /**
    * @dev Add two numbers
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }

    /**
    * @dev Increment number and start with 0 if upper limit is reached
    */
    function infiniteInc(uint256 _a) internal pure returns (uint256) {
        if (_a < type(uint256).max)
            return _a+1;
        else
            return 0;
    }
}