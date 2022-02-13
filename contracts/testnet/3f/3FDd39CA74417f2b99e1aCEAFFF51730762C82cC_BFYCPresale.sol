// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


import "./Ownable.sol";
import "./Address.sol";
import "./IERC20.sol";
import "./Context.sol";

contract Whitelisted is Ownable {
    mapping(address => bool) public whitelist;
    bool public whitelistOnlyEnded;
  

    modifier onlyWhitelisted {
        require (isWhitelisted(msg.sender), "GenericPresale: Whitelisted accounts only");
        _;
    }
  
   function setWhitelistEnded (bool endWhitelist) external onlyOwner {
       whitelistOnlyEnded = endWhitelist;
   }
    
    function whitelistAddresses (address[] memory _purchaser) external onlyOwner {
        for (uint256 i; i < _purchaser.length; i++)
            whitelist[_purchaser[i]] = true;
    }
    
    function deleteFromWhitelist (address _purchaser) external onlyOwner {
        whitelist[_purchaser] = false;
    }
   
    function isWhitelisted (address _purchaser) public view returns (bool) {
        return whitelist[_purchaser] ? true : whitelistOnlyEnded ? true : false;
    }
}

contract BFYCPresale is Ownable, Whitelisted {
    using Address for address payable;
    
    event Swap (address indexed user, uint256 inAmount, uint256 owedAmount);
    event Claim (address indexed user, uint256 amount);
    event PayeeTransferred (address indexed previousPayee, address indexed newPayee);

    IERC20 public token;
    address public payee;
    
    bool public isSwapStarted;
    bool public canClaim;

    uint256 public swapRate = 1111111; //tokens per BNB
    uint256 public totalSold;
    uint256 public decimalsModifier;
    uint256 public minBuy = 200000000000000000; // 0.2 BNB
    uint256 public maxBuy = 3000000000000000000; // = 3 BNB
    
    mapping (address => uint256) public spent;
    mapping (address => uint256) public owed;
    mapping (address => uint256) public claimed;
   
    constructor (address _paymentWallet, IERC20 _token) {
        require (address(_token) != address(0), "GenericPresale: Can't set token to zero address");
        require (_paymentWallet != address(0), "GenericPresale: Can't set payee to zero address");

        token = _token; 
        payee = _paymentWallet;
        decimalsModifier = 10**18 * 10**_token.decimals();
    }

    function swap() external payable onlyWhitelisted {
        require (isSwapStarted == true, "GenericPresale: Swap not started");
        require (spent[msg.sender] + msg.value <= maxBuy, "GenericPresale: Reached Max Buy");

        uint256 quota = token.balanceOf (address(this));
        uint256 outAmount = (msg.value * swapRate * decimalsModifier) / 10**36;

        require (totalSold + outAmount <= quota, "GenericPresale: Not enough tokens remaining");
        
        totalSold += outAmount;
        payable(payee).sendValue (msg.value);
        spent[msg.sender] += msg.value;
        owed[msg.sender] += outAmount;
        emit Swap (msg.sender, msg.value, outAmount);
    }

    function claim() external onlyWhitelisted {
        require (canClaim == true, "GenericPresale: Can't claim yet");

        uint256 quota = token.balanceOf (address(this));
        uint256 owedNow = owed[msg.sender];

        if (owedNow > owed[msg.sender])
            owedNow = owed[msg.sender];

        require (owedNow - claimed[msg.sender] <= quota, "GenericPresale: Not enough tokens remaining");
        require (owedNow - claimed[msg.sender] > 0, "GenericPresale: No tokens left to claim");

        uint256 amount = owedNow - claimed[msg.sender];
        claimed[msg.sender] = owedNow;
        token.transfer (msg.sender, amount);

        emit Claim (msg.sender, amount);
    }

    function toggleSwap (bool enableSwap) external onlyOwner {
        isSwapStarted = enableSwap;
    }

    function setClaim (bool _canClaim) external onlyOwner {
        canClaim = _canClaim;
    }

    function setSwapRate (uint256 newRate) external onlyOwner {
        swapRate = newRate;
    }

    function setMinBuy (uint newMin) external onlyOwner {
        minBuy = newMin;
    }
    
    function setMaxBuy (uint256 newMax) external onlyOwner {
        maxBuy = newMax;
    }
    
    function transferPayee (address newPayee) external onlyOwner {
        require (newPayee != address(0), "GenericPresale: Can't set payee to zero address");
        emit PayeeTransferred (payee, newPayee);
        payee = newPayee;
    }

   function recoverLostBNB() external onlyOwner {
        payable(payee).sendValue (address(this).balance);
    }

    function withdrawOtherTokens(address _token, uint256 amount) external onlyOwner {
        IERC20(_token).transfer (msg.sender, amount);
    }
}