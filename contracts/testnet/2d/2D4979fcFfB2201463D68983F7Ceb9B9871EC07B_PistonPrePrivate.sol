/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract PistonPrePrivate {
    using SafeMath for uint256;

    address public ownerAddress;
    
    address public presaleWalletAddress;
    mapping (address => uint256) public deposits;
    mapping (address => uint256) public whitelist;
    mapping (address => uint256) public claimed;
    mapping(uint256 => address) public id2Address;
    
    IERC20 public BUSD;
    IERC20 public PISTON;
    using SafeMath for uint256;
    address token_BUSD = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); //BUSD TESTNET
    address token_PISTON = address(0xccd40212f489CaB747b02a82b802F551b13f3e10); //PISTON TESTNET

    bool public started;
    uint256 public totalInvested_BUSD;
    uint256 public maxUserDeposits = 1600000000000000000000; // 1600 BUSD
    uint256 public pistonTokenPrice = 0;
    uint256 spots = 0;
  
    /*
        initial setup

        1. set presale wallet 
        2. set max amount
        3. start contract

        4. Presale contract on Token whitelist!!!
        
        ================= after launch ============

        5. add tokens to contract
        6. set token price (enables claim) (discount for presale level!!)


    */

    constructor() {
        ownerAddress = msg.sender;
        BUSD = IERC20(token_BUSD);
        PISTON = IERC20(token_PISTON);
    }
    
    function deposit(
        uint256 amount
    ) public {
        require(started, "Not started yet");
        require(presaleWalletAddress != address(0), "missing presale wallet");        

        uint256 maxDeposit = maxUserDeposits; // default max limit
        uint256 userSpecialLimit = whitelist[msg.sender];
        if(userSpecialLimit > 1){
            // user has special limit
            maxDeposit = userSpecialLimit;
        }

        require(userSpecialLimit > 0, "not whitelisted");
        require(getMyDeposits(msg.sender).add(amount) <= maxDeposit, "maximum reached");        

        if( amount > 0){
            BUSD.transferFrom(msg.sender, presaleWalletAddress, amount); // send to Presale wallet
            totalInvested_BUSD = totalInvested_BUSD.add(amount);
            
            deposits[address(msg.sender)] += amount;
        }
    }

    function claim() external {
        require(whitelist[msg.sender] > 0, "not whitelisted");
        require(pistonTokenPrice > 0, "token price not set");
        require(claimed[msg.sender] == 0, "nothing to claim");

        uint256 myDeposits = deposits[address(msg.sender)];
        uint256 myTokenAmount = pistonTokenPrice.mul(myDeposits).div(1 ether);

        claimed[msg.sender] = myTokenAmount;

        PISTON.transfer(msg.sender, myTokenAmount);
    }

    function getClaimActive() public view returns(bool) {
        return pistonTokenPrice > 0;
    }

    function getHardCap() public view returns(uint256) {
        uint256 hc;

        for(uint256 i = 0; i < spots; i++) {
            uint256 limit = maxUserDeposits;
            address whitelistedWallet = id2Address[i];
            if(whitelist[whitelistedWallet] > 1){
                limit = whitelist[whitelistedWallet];
            }

            hc += limit;
        }

        return hc;
    }
    
    function getMyDeposits(address wallet) public view returns(uint256) {
        return deposits[wallet];
    }
    
    function getPresaleWalletBalance() public view returns(uint256) {
        require(started == true);
        return BUSD.balanceOf(presaleWalletAddress);
    }
    
    function setPresaleWallet(address value) external {
        require(msg.sender == ownerAddress);
        presaleWalletAddress = value;
    }
    
    function setMaxDeposit(uint256 value) external {
        require(msg.sender == ownerAddress);
        maxUserDeposits = value;
    }

    function setPistonTokenPrice(uint256 value) external {
        require(msg.sender == ownerAddress);
        pistonTokenPrice = value;
    }

    function setOwner(address value) external {
        require(msg.sender == ownerAddress);
        ownerAddress = value;
    }

    function addWalletToWhitelist(address wallet, uint256 value) external {
        require(msg.sender == ownerAddress);

        bool spotExisted = false;
        if(whitelist[wallet] > 0){
            spotExisted = true;
        }
        if(spotExisted == false){
            id2Address[spots] = wallet;
            spots++; // new wallet in whitelist
        }
        whitelist[wallet] = value;
    }

    
   function start() external {
        require(msg.sender == ownerAddress);
        started = true;
    }
    
    function stop() external {
        require(msg.sender == ownerAddress);
        started = false;
    }
  
}







interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}